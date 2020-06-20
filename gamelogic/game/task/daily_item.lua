local DailyItem = Class(game.UITemplate)

local DailyTaskConfig = require("game/task/daily_task_config")

function DailyItem:_init(ctrl)
    self.ctrl = ctrl
end

function DailyItem:OpenViewCallBack()
	self:Init()
	
end

function DailyItem:CloseViewCallBack()
    
end

function DailyItem:Init()
    self.txt_task = self._layout_objs["txt_task"]
    self.rtx_desc = self._layout_objs["rtx_desc"]

    self.shape_click = self._layout_objs["shape_click"]
    self.shape_click:AddClickCallBack(function()
        self.ctrl:OpenTaskDetailView(self.task_id)
    end)

    --日常任务点击前往寻路
    self.btn_go = self._layout_objs["btn_go"]
    self.btn_go:AddClickCallBack(function()
        -- if self.click_func then
        --     self.click_func()
        -- else
        --     local main_role = game.Scene.instance:GetMainRole()
        --     main_role:GetOperateMgr():DoHangTask(self.task_id)
        -- end
        local main_role = game.Scene.instance:GetMainRole()
        main_role:GetOperateMgr():DoHangTask(self.task_id)
        game.TaskCom.instance:OnHangTask(self.task_id,true)
        self.ctrl:CloseView()
    end)

    self.btn_finish = self._layout_objs["btn_finish"]
    self.btn_finish:AddClickCallBack(function()
        self.ctrl:SendTaskGetReward(self.task_id)
    end)
end

function DailyItem:UpdateData(data)
    self.task_id = data.id

    self.name_func = data.name_func
    self.desc_func = data.desc_func
    self.click_func = data.click_func

    local is_finish = false
    if self.name_func then
        self.txt_task:SetText(self.name_func(true))
        self.rtx_desc:SetText(self:ReplaceDesc(self.desc_func()))
    else
        local task_info = game.TaskCtrl.instance:GetTaskInfoById(self.task_id)
        local task_cfg = game.TaskCtrl.instance:GetTaskCfg(self.task_id)
        local task_desc = task_cfg.desc
        local cond = task_info.masks[1]
        if cond then
            task_desc = string.format(config.words[2191], task_desc, string.format("(%s/%s)", cond.current, cond.total))
        end

        local task_name = self:GetTaskName(task_cfg.type, task_cfg.name)
        self.txt_task:SetText(task_name)
        self.rtx_desc:SetText(self:ReplaceDesc(task_desc))

        is_finish = self.ctrl:CheckTaskFinish(self.task_id) and (not self.ctrl:ShouldTaskFindNpc(self.task_id))
    end

    self.btn_go:SetVisible(not is_finish)
    self.btn_finish:SetVisible(is_finish)
end

function DailyItem:GetTaskName(task_type, name)
    return game.TaskTypeName[task_type] .. name
end

function DailyItem:ReplaceDesc(desc)
    local desc = string.gsub(desc, game.ColorString.Green, game.ColorString.DarkGreen)
    return string.gsub(desc, game.ColorString.PaleYellow, game.ColorString.Orange)
end

return DailyItem
