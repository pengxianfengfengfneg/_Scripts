local MentorPostView = Class(game.BaseView)

function MentorPostView:_init(ctrl)
    self._package_name = "ui_mentor"
    self._com_name = "post_view"
    self.ctrl = ctrl

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full
end

function MentorPostView:OpenViewCallBack(info)
    self:Init(info)
    self:InitBg()
end

function MentorPostView:Init(info)
    self._layout_objs["txt_gender"]:SetText(self:GetOption(1, info.gender))
    self._layout_objs["txt_time"]:SetText(self:GetOption(3, info.time))
    self._layout_objs["txt_type"]:SetText(self:GetOption(5, info.type))
    self._layout_objs["txt_fight"]:SetText(info.fight)
    self._layout_objs["txt_notice"]:SetText(info.notice)

    self._layout_objs["btn_close"]:AddClickCallBack(function()
        self:Close()
    end)
end

function MentorPostView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6422])
end

function MentorPostView:GetOption(quest_idx, option_idx)
    if quest_idx and option_idx then
        local bank_info = self.ctrl:GetRegisterBankInfo()
        return bank_info[quest_idx].prent_info.option_list[option_idx]
    end
end

return MentorPostView
