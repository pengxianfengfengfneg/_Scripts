local DailyTaskCxdtTemplate = Class(game.UITemplate)

function DailyTaskCxdtTemplate:_init(view)
    self.parent = view
    self.ctrl = game.DailyTaskCtrl.instance   
end

function DailyTaskCxdtTemplate:OpenViewCallBack()

    --接受任务
    self._layout_objs["recv_btn"]:AddClickCallBack(function()
        self.ctrl:CsDailyRobberAcceptTask()
    end)

    --放弃任务
    self._layout_objs["give_up_btn"]:AddClickCallBack(function()
        self.ctrl:CsDailyRobberAbandonTask()
    end)

    --前往击杀
    self._layout_objs["go_btn"]:AddClickCallBack(function()
        if self.cxdt_data then
            self.parent:Close()
            local scene_id = self.cxdt_data.scene_id
            local mosnter_id = self.cxdt_data.mon_id
            local x = self.cxdt_data.x
            local y = self.cxdt_data.y
            game.Scene.instance:GetMainRole():GetOperateMgr():DoHangMonster(scene_id, mosnter_id, 1, x, y)
        end
    end)

    self:BindEvent(game.DailyTaskEvent.UpdateCxdtInfo, function()
        -- self:UpdateInfo()
    end)

    self.ctrl:CsDailyRobberInfo()
end

function DailyTaskCxdtTemplate:CloseViewCallBack()

end

function DailyTaskCxdtTemplate:UpdateInfo()

    local cxdt_data = self.ctrl:GetCxdtData()
    local used_times = cxdt_data.times
    local max_times = cxdt_data.max_times
    local state = cxdt_data.state
    local scene_id = cxdt_data.scene_id
    self.cxdt_data = cxdt_data

    self._layout_objs["left_time"]:SetText(tostring(max_times-used_times).."/"..tostring(max_times))

    if state == 0 then
        self._layout_objs["recv_btn"]:SetVisible(true)
        self._layout_objs["give_up_btn"]:SetVisible(false)
        self._layout_objs["go_btn"]:SetVisible(false)
        self._layout_objs["n92"]:SetText("")
    else
        -- local scene_name = config.scene[scene_id].name
        -- self._layout_objs["n92"]:SetText(string.format(config.words[5125], scene_name))

        self._layout_objs["recv_btn"]:SetVisible(false)
        self._layout_objs["give_up_btn"]:SetVisible(true)
        self._layout_objs["go_btn"]:SetVisible(true)
    end
end

return DailyTaskCxdtTemplate
