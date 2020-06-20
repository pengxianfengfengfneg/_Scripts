local PlatformGroupTemplate = Class(game.UITemplate)

function PlatformGroupTemplate:_init(view, type)
    self.parent = view
    self.ctrl = game.SwornCtrl.instance
    self.type = 2 
end

function PlatformGroupTemplate:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
end

function PlatformGroupTemplate:Init()
    self.list_group = self:CreateList("list_group", "game/sworn/item/platform_group_item")
    self.list_group:SetRefreshItemFunc(function(item, idx)
        local item_info = self.group_list_data[idx].group
        item_info.type = self.type
        item:SetItemInfo(item_info, idx)
    end)
end

function PlatformGroupTemplate:RegisterAllEvents()
    local events = {
        {game.SwornEvent.UpdatePlatformInfo, handler(self, self.UpdateGroupList)},
        {game.SwornEvent.OnSwornGreet, handler(self, self.UpdateGroupList)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function PlatformGroupTemplate:UpdateGroupList()
    local info = self.ctrl:GetPlatformInfo()
    if not self.group_list_data or table.nums(info.group_list) > 0 then
        self.group_list_data = info.group_list
        self.list_group:SetItemNum(#self.group_list_data)
    end
end

return PlatformGroupTemplate