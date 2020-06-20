local MentorGraduateView = Class(game.BaseView)

local PageIndex = {
    Mentor = 0,
    Prentice = 1,
}

function MentorGraduateView:_init(ctrl)
    self._package_name = "ui_mentor"
    self._com_name = "graduate_view"
    self.ctrl = ctrl

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full
end

function MentorGraduateView:OpenViewCallBack(info)
    self:Init(info)
    self:InitBg()
end

function MentorGraduateView:CloseViewCallBack()

end

function MentorGraduateView:Init(info)
    local page_idx = nil
    if info.role_id ~= game.RoleCtrl.instance:GetRoleId() then
        local graduate_lv = config.mentor_base.senior_lv
        local base_info = self.ctrl:GetBaseInfo(info.role_id)
        self._layout_objs["txt_info"]:SetText(string.format(config.words[6415], base_info.name, graduate_lv))

        self._layout_objs["txt_score"]:SetText(string.format(config.words[6416], base_info.name, info.mark))
        self._layout_objs["bar_progress"]:SetProgressValue(info.mark / self.ctrl:GetMaxStudyMark())

        self.list_mentor_reward = self:CreateList("list_mentor_reward", "game/mentor/template/graduate_item")
        self.list_mentor_reward:SetRefreshItemFunc(function(item, idx)
            local item_info = self.mentor_reward_data[idx]
            item:SetItemInfo(item_info)
            item:SetSelected(info.mark >= item_info.mark)
        end)
        self:UpdateMentorRewardList()
        page_idx = PageIndex.Mentor
    else
        local drop_id = config.mentor_base.tudi_finish_award
        local prentice_reward_data = config.drop[drop_id].client_goods_list
        self.list_prentice_reward = self:CreateList("list_prentice_reward", "game/bag/item/goods_item")
        self.list_prentice_reward:SetRefreshItemFunc(function(item, idx)
            local item_info = prentice_reward_data[idx]
            item:SetItemInfo({id = item_info[1], num = item_info[2]})
            item:SetShowTipsEnable(true)
        end)
        self.list_prentice_reward:SetItemNum(#prentice_reward_data)
        page_idx = PageIndex.Prentice
    end
    self:GetRoot():GetController("ctrl_page"):SetSelectedIndexEx(page_idx)
end

function MentorGraduateView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6414])
end

function MentorGraduateView:UpdateMentorRewardList()
    if not self.mentor_reward_data then
        local mentor_reward_data = {}
        for k, v in pairs(config.mentor_mark_award) do
            table.insert(mentor_reward_data, v)
        end
        table.sort(mentor_reward_data, function(m, n)
            return m.mark < n.mark
        end)
        self.mentor_reward_data = mentor_reward_data
    end
    self.list_mentor_reward:SetItemNum(#self.mentor_reward_data)
end

return MentorGraduateView
