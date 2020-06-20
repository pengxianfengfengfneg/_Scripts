local MentorRecommendView = Class(game.BaseView)

function MentorRecommendView:_init(ctrl)
    self._package_name = "ui_mentor"
    self._com_name = "recommend_view"
    self.ctrl = ctrl

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full
end

function MentorRecommendView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
    self.ctrl:SendMentorFind()
end

function MentorRecommendView:CloseViewCallBack()

end

function MentorRecommendView:RegisterAllEvents()
    local events = {
        {game.MentorEvent.OnMentorFind, handler(self, self.OnMentorFind)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MentorRecommendView:Init()
    self.btn_change = self._layout_objs["btn_change"]
    self.btn_change:AddClickCallBack(function()
        self.ctrl:SendMentorFind()
    end)

    self.list_member = self:CreateList("list_member", "game/mentor/template/recommend_item")
    self.list_member:SetRefreshItemFunc(function(item, idx)
        local item_info = self.member_list_data[idx].mentor
        item:SetItemInfo(item_info)
    end)
end

function MentorRecommendView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6419])
end

function MentorRecommendView:OnMentorFind(mentors)
    self.member_list_data = mentors
    self.list_member:SetItemNum(#mentors)
end

return MentorRecommendView
