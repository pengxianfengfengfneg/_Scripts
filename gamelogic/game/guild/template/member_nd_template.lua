local MemberNdTemplate = Class(game.UITemplate)

local SortStyle = {
    High = 1,
    Low = 2,
}

local SortIndex

local ShowWay = {
    Default = {
        sort_func = function(m, n)
            local role_id = game.RoleCtrl.instance:GetRoleId()
            if m.id == role_id or n.id == role_id then
                return m.id == role_id
            elseif m.pos == n.pos then
                return m.id < n.id
            else
                return m.pos > n.pos
            end
        end,
    },
    Cont = {
        sort_func = function(m, n)
            local role_id = game.RoleCtrl.instance:GetRoleId()
            if m.id == role_id or n.id == role_id then
                return m.id == role_id
            elseif SortIndex == SortStyle.High then
                return m.contri > n.contri
            else
                return m.contri < n.contri
            end
        end,
    },
    WeekFunds = {
        sort_func = function(m, n)
            local role_id = game.RoleCtrl.instance:GetRoleId()
            if m.id == role_id or n.id == role_id then
                return m.id == role_id
            elseif SortIndex == SortStyle.High then
                return m.weekly_funds > n.weekly_funds
            else
                return m.weekly_funds < n.weekly_funds
            end
        end,
    },
    WeekMilitary = {
        sort_func = function(m, n)
            return false
        end,
    },
    Military = {
        sort_func = function(m, n)
            return false
        end,
    },
}

function MemberNdTemplate:_init(view)
    self.parent = view
    self.ctrl = game.GuildCtrl.instance
end

function MemberNdTemplate:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
end

function MemberNdTemplate:RegisterAllEvents()
    local events = {
        {game.GuildEvent.UpdateMemberList, handler(self, self.SetMemberList)},
        {game.GuildEvent.UpdateMemberOffline, handler(self, self.SetMemberList)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1],v[2])
    end
end

function MemberNdTemplate:Init(open_idx)
    self.btn_name = self._layout_objs.btn_name
    self.btn_cont = self._layout_objs.btn_cont
    self.btn_week_funds = self._layout_objs.btn_week_funds
    self.btn_week_military = self._layout_objs.btn_week_military
    self.btn_military = self._layout_objs.btn_military

    self.btn_cont:AddClickCallBack(function()
        self:DoSort(ShowWay.Cont)
    end)

    self.btn_week_funds:AddClickCallBack(function()
        self:DoSort(ShowWay.WeekFunds)
    end)

    self.btn_week_military:AddClickCallBack(function()
        self:DoSort(ShowWay.WeekMilitary)
    end)

    self.btn_military:AddClickCallBack(function()
        self:DoSort(ShowWay.Military)
    end)

    self.list_member = self:CreateList("list_member", "game/guild/item/member_nd_item")
    self.list_member:SetRefreshItemFunc(function(item, idx)
        local item_info = self.member_list_data[idx]
        item:SetItemInfo(item_info, idx)
    end)

    self.max_show_num = 13

    SortIndex = 0
end

function MemberNdTemplate:SetMemberList()
    if not self.ctrl:IsGuildMember() then
        return
    end

    local members = self.ctrl:GetGuildMembers()
    local role_id = game.Scene.instance:GetMainRoleID()

    self.member_list_data = {}
    for k, v in ipairs(members) do
        table.insert(self.member_list_data, v.mem)
    end

    self:UpdateMemberList()
end

function MemberNdTemplate:UpdateMemberList(show_way, switch)
    self:SetShowWay(show_way or self.show_way, switch)
    local item_num = #self.member_list_data
    self.list_member:SetItemNum(item_num)
    self.list_member:ResizeToFit(math.min(item_num, self.max_show_num))

    -- local btn_size = self.btn_name:GetSize()
    -- local list_size = self._layout_objs.list_member:GetSize()
    -- self.parent:SetListSize(list_size[1], btn_size[2] + list_size[2])
end

function MemberNdTemplate:SetShowWay(index, switch)
    if switch then
        SortIndex = (self.show_way == index) and (SortIndex % table.nums(SortStyle)) + 1 or SortStyle.High
    end
    self.show_way = index or ShowWay.Default
    table.sort(self.member_list_data, self.show_way.sort_func)
end

function MemberNdTemplate:DoSort(show_way)
    if self.member_list_data then
        self:UpdateMemberList(show_way, true)
    end
end

return MemberNdTemplate