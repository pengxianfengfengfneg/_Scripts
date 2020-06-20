local MentorFeedbackView = Class(game.BaseView)

function MentorFeedbackView:_init(ctrl)
    self._package_name = "ui_mentor"
    self._com_name = "feedback_view"
    self.ctrl = ctrl

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full
end

function MentorFeedbackView:OpenViewCallBack()
    self:Init()
    self:InitBg()
end

function MentorFeedbackView:CloseViewCallBack()
    self:DelTimer()
    self.ctrl:SendMentorComment(self.click_idx or 1)
end

function MentorFeedbackView:Init()
    self.ctrl_checkbox = self:GetRoot():AddControllerCallback("ctrl_checkbox", function(idx)
        self:OnItemClick(idx+1)
    end)
    self.ctrl_checkbox:SetSelectedIndexEx(0)

    self.btn_cancel = self._layout_objs["btn_cancel"]
    self.btn_cancel:AddClickCallBack(function()
        self:Close()
    end)

    self.btn_ok = self._layout_objs["btn_ok"]
    self.btn_ok:AddClickCallBack(function()
        self:Close()
    end)

    self:CreateCloseTimer()
end

function MentorFeedbackView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6277])
end

function MentorFeedbackView:OnItemClick(idx)
    self.click_idx = idx
end

function MentorFeedbackView:CreateCloseTimer()
    local time = config.mentor_base.confirm_cd1
    self:DelTimer()
    self.timer = global.TimerMgr:CreateTimer(1, function()
        time = time - 1
        self.btn_cancel:SetText(config.words[101] .. string.format("(%d)", time))
        if time <= 0 then
            self:Close()
            return true
        end
    end)
end

function MentorFeedbackView:DelTimer()
    if self.timer then
    	global.TimerMgr:DelTimer(self.timer)
    	self.timer = nil
    end
end

return MentorFeedbackView
