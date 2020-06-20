local DailyTaskJhexpTipsView = Class(game.BaseView)

function DailyTaskJhexpTipsView:_init(ctrl)
    self._package_name = "ui_daily_task"
    self._com_name = "daily_task_jhexp_tips_view"
    self.ctrl = ctrl
    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function DailyTaskJhexpTipsView:_delete()
    
end

function DailyTaskJhexpTipsView:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
end

function DailyTaskJhexpTipsView:CloseViewCallBack()
end

function DailyTaskJhexpTipsView:Init()
    self:SetContnetText()
    self._layout_objs["txt_title"]:SetText(config.words[1911])
    self._layout_objs["btn_concern"]:AddClickCallBack(function()
        self.ctrl:SendFinishKillMonRewardReq()
    end)
    self._layout_objs["btn_back"]:AddClickCallBack(function()
        self:Close()
    end)
end

function DailyTaskJhexpTipsView:SetContnetText(state)
    state = state or self.ctrl:GetKillMonRewardState()
    local finish_money = config.sys_config["daily_kill_mons_finish"].value
    local cost = finish_money[3 - state] or 0
    self._layout_objs["txt_content"]:SetText(string.format(config.words[1912], cost))
end

function DailyTaskJhexpTipsView:RegisterAllEvents()
    self:BindEvent(game.DailyTaskEvent.UpdateJhexpRewardState, function(state)
        if state >= 3 then
            self:Close()
        end
        self:SetContnetText(state)
    end)
end

function DailyTaskJhexpTipsView:OnEmptyClick()
    self:Close()
end

return DailyTaskJhexpTipsView
