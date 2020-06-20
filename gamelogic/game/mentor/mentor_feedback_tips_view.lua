local MentorFeedbackTipsView = Class(game.BaseView)

function MentorFeedbackTipsView:_init(ctrl)
    self._package_name = "ui_mentor"
    self._com_name = "feedback_tips_view"
    self.ctrl = ctrl

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.None
end

function MentorFeedbackTipsView:OpenViewCallBack()
    self:Init()
end

function MentorFeedbackTipsView:Init()
    local str = ""
    local lv_list = config.mentor_base.comment_timing
    table.sort(lv_list, function(m, n)
        return m < n
    end)
    if #lv_list > 0 then
        str = lv_list[1]
        for i=2, #lv_list do
            str = str .. string.format("、%s", lv_list[i])
        end
    end
    self._layout_objs["txt_content"]:SetText(string.format(config.words[6444], str))
    self:GetRoot():AddClickCallBack(function()
        self:Close()
    end)
end

return MentorFeedbackTipsView
