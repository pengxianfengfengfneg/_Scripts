local SwornSeniorView = Class(game.BaseView)

local PageIndex = {
    Vote = 0,
    Show = 1,
}

function SwornSeniorView:_init(ctrl)
    self._package_name = "ui_sworn"
    self._com_name = "senior_view"
    self.ctrl = ctrl

    self._show_money = true

    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
end 

function SwornSeniorView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
    self:UpdateSeniorSortInfo()
end

function SwornSeniorView:CloseViewCallBack()
    self:StopTimeCounter()
end

function SwornSeniorView:RegisterAllEvents()
    local events = {
        {game.SwornEvent.UpdateSeniorSortInfo, handler(self, self.UpdateSeniorSortInfo)},
        {game.SwornEvent.OnSwornVoteSenior, handler(self, self.OnSwornVoteSenior)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end
 
function SwornSeniorView:Init()
    self.txt_vote = self._layout_objs.txt_vote
    self.txt_time = self._layout_objs.txt_time

    self.list_vote = self:CreateList("list_vote", "game/sworn/item/senior_vote_item")
    self.list_vote:SetRefreshItemFunc(function(item, idx)
        local item_info = self.vote_list_data[idx].info
        item:SetItemInfo(item_info, idx)
        item:AddClickEvent(handler(self, self.OnVoteClick))
        item:SetVoteEnable(self:CanVote())
    end)

    for i=1, config.sworn_base.num_limit do
        self["senior_item"..i] = self:GetTemplate("game/sworn/item/senior_item", "senior_item"..i)
    end

    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
    self.vote_role_id = nil
    self.vote_close_time = nil
end

function SwornSeniorView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6268])
end

function SwornSeniorView:UpdateSeniorSortInfo()
    local info = self.ctrl:GetSeniorSortInfo()
    if info then
        self.senior_info = info

        local page_idx = PageIndex.Show
        if info.cur_senior ~= 0 then
            self:StartTimeCounter(info.close_time)
            self:UpdateVoteList(info.raw_list)
            self:SetVoteText(info.cur_senior)
            page_idx = PageIndex.Vote
        else
            self:StopTimeCounter()
        end

        self.ctrl_page:SetSelectedIndexEx(page_idx)
        self:UpdateSeniorList(info.sorted_list)
    end
end

function SwornSeniorView:UpdateVoteList(vote_list)
    self.vote_list_data = vote_list
    self.list_vote:SetItemNum(#vote_list)
end

function SwornSeniorView:OnSwornVoteSenior(role_id)

end

function SwornSeniorView:UpdateSeniorList(sorted_list)
    table.sort(sorted_list, function(m, n)
        return m.info.senior < n.info.senior
    end)
    for i=1, config.sworn_base.num_limit do
        local senior_info = sorted_list[i] or game.EmptyTable
        self["senior_item"..i]:SetItemInfo(senior_info.info, i)
    end
end

function SwornSeniorView:SetVoteText(senior_id)
    local senior_name = config.sworn_senior_name[senior_id].name
    self.txt_vote:SetText(string.format(config.words[6275], senior_name))
end

function SwornSeniorView:StartTimeCounter(close_time)
    self:StopTimeCounter()
    self.tween_time = DOTween:Sequence()
    self.tween_time:AppendCallback(function()
        local time = close_time - global.Time:GetServerTime()
        time = math.max(0, time)
        self.txt_time:SetText(string.format(config.words[6271], time))
        if time == 0 then
            self:StopTimeCounter()
            self:Close()
        end
    end)
    self.tween_time:AppendInterval(1)
    self.tween_time:SetLoops(-1)
end

function SwornSeniorView:StopTimeCounter()
    if self.tween_time then
        self.tween_time:Kill(false)
        self.tween_time = nil
    end
end

function SwornSeniorView:OnVoteClick(role_id)
    self.ctrl:SendSwornVoteSenior(role_id)
    self.vote_close_time = self.senior_info.close_time
    self.vote_role_id = role_id
    self.list_vote:Foreach(function(item)
        item:SetVoteEnable(self:CanVote())
    end)
end

function SwornSeniorView:CanVote()
    for k, v in pairs(self.senior_info.raw_list) do
        if v.info.role_id == self.vote_role_id then
            if self.vote_close_time == self.senior_info.close_time then
                return false
            end
            break
        end
    end
    return true
end

return SwornSeniorView
