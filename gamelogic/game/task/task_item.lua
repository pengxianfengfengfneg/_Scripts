local TaskItem = Class(game.UITemplate)

local DailyTaskConfig = require("game/task/daily_task_config")

function TaskItem:_init(ctrl)
    self.ctrl = ctrl
end

function TaskItem:OpenViewCallBack()
	self:Init()
	
end

function TaskItem:CloseViewCallBack()
    
end

function TaskItem:Init()
    self.txt_task = self._layout_objs["txt_task"]
    self.rtx_desc = self._layout_objs["rtx_desc"]

    self.img_bg = self._layout_objs["img_bg"]

    self.shape_click = self._layout_objs["shape_click"]
    self.shape_click:AddClickCallBack(function()
        self.ctrl:OpenTaskDetailView(self.task_id)
    end)
    
    self.btn_go = self._layout_objs["btn_go"]
    self.btn_go:AddClickCallBack(function()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_task/task_view/task_template/task_item/btn_go"})
        
        game.GuideCtrl.instance:SetCurClickTaskId(self.task_id)
        game.ViewMgr:FireGuideEvent()

        local main_role = game.Scene.instance:GetMainRole()
        main_role:GetOperateMgr():DoHangTask(self.task_id)
        if self.cate == 1 then
            game.TaskCom.instance:OnHangTask(self.task_id,true)
        elseif self.cate == 2 then
            game.TaskComMenmbers.instance:RefreshTaskList(self.task_id)
        end

        self.ctrl:CloseView()
    end)

    self.btn_finish = self._layout_objs["btn_finish"]
    self.btn_finish:AddClickCallBack(function()
        self.ctrl:SendTaskGetReward(self.task_id)
    end)
end

function TaskItem:UpdateData(data)
    self.task_id = data.id
    self.task_info = data

    local cfg = config.task[data.id]
    self.cate = cfg[1].cate

    local task_cfg = self.ctrl:GetTaskCfg(self.task_id)

    local task_name = self:GetTaskName(task_cfg.type, task_cfg.name)
    self.txt_task:SetText(task_name)

    local task_desc = task_cfg.desc
    local cond = data.masks[1]
    if cond then
        local str_process = game.TaskStateWord[data.stat]

        if data.stat == game.TaskState.NotAcceptable then
            task_desc = string.format(config.words[2153], cond.total)
            str_process = ""
        elseif data.stat == game.TaskState.Acceptable then
            str_process = string.format("(%s)",config.words[2199])
        elseif data.stat == game.TaskState.Accepted then
            str_process = string.format("(%s/%s)", cond.current, cond.total)
        elseif data.stat == game.TaskState.Finished then
            str_process = string.format("(%s)", str_process)
        end
        task_desc = string.format(config.words[2191], task_desc, str_process)
    end

    self.rtx_desc:SetText(self:ReplaceDesc(task_desc))

    local can_accpet = (data.stat > game.TaskState.NotAcceptable)
    local is_finish = self:CheckTaskFinish()
    self.btn_go:SetVisible(not is_finish and can_accpet)
    self.btn_finish:SetVisible(is_finish and can_accpet)

    local res_name = "rw_01"
    if task_cfg.cate == game.TaskCate.Branch then
        res_name = "rw_02"
    end
    self.img_bg:SetSprite("ui_task", res_name)
end

function TaskItem:GetTaskName(task_type, name)
    return game.TaskTypeName[task_type] .. name
end

function TaskItem:CheckTaskFinish()
    local task_state = self.task_info.stat
    local task_cfg = self.ctrl:GetTaskCfg(self.task_id)

    if task_state == game.TaskState.Finished then
        if task_cfg.finish_talk > 0 then
            return false
        end

        if task_cfg.talk_id > 0 and (not self.ctrl:HasDoTaskTalk(self.task_id)) then
            return false
        end

        return true
    end
    return false
end

function TaskItem:ReplaceDesc(desc)
    local desc = string.gsub(desc, game.ColorString.Green, game.ColorString.DarkGreen)
    return string.gsub(desc, game.ColorString.PaleYellow, game.ColorString.Orange)
end

return TaskItem
