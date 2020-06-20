local PlatformPersonTemplate = Class(game.UITemplate)

function PlatformPersonTemplate:_init(view)
    self.parent = view
    self.ctrl = game.SwornCtrl.instance   
    self.type = 1
end

function PlatformPersonTemplate:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
end

function PlatformPersonTemplate:Init()
    self.list_person = self:CreateList("list_person", "game/sworn/item/platform_person_item")
    self.list_person:SetRefreshItemFunc(function(item, idx)
        local item_info = self.person_list_data[idx].person
        item_info.type = self.type
        item:SetItemInfo(item_info, idx)
    end)
end

function PlatformPersonTemplate:RegisterAllEvents()
    local events = {
        {game.SwornEvent.UpdatePlatformInfo, handler(self, self.UpdateMemberList)},
        {game.SwornEvent.OnSwornGreet, handler(self, self.UpdateMemberList)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function PlatformPersonTemplate:UpdateMemberList()
    local info = self.ctrl:GetPlatformInfo()
    if not self.person_list_data or table.nums(info.person_list) > 0 then
        self.person_list_data = info.person_list
        self.list_person:SetItemNum(#self.person_list_data)
    end
end

return PlatformPersonTemplate