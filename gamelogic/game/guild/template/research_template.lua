local ResearchTemplate = Class(game.UITemplate)

function ResearchTemplate:_init(view, type)
    self.parent = view
    self.ctrl = game.GuildCtrl.instance
    self.type = type
end

function ResearchTemplate:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
end

function ResearchTemplate:CloseViewCallBack()
    self.item_list = nil
    self.item_list_data = nil
end

function ResearchTemplate:RegisterAllEvents()
    local events = {
        {game.GuildEvent.UpdateGuildInfo, handler(self, self.UpdateResearchList)},
        {game.GuildEvent.UdpateResearchInfo, handler(self, self.UpdateResearchList)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function ResearchTemplate:Init()
    self.ctrl_skill = self:GetRoot():GetController("ctrl_skill")
    self.item_list = {}
    for i=1, 10 do
        local item = self:GetTemplate("game/guild/item/guild_research_item", "research_item_"..i)
        item:AddClickEvent(handler(self, self.OnItemClick))
        table.insert(self.item_list, item)
    end
    self:UpdateResearchList()
end

function ResearchTemplate:UpdateResearchList()
    self.item_list_data = self.ctrl:GetResearchInfoByType(self.type)
    local select_id = self.parent:GetClickItemId()

    for i=1, 10 do
        local item = self:GetTemplate("game/guild/item/guild_research_item", "research_item_"..i)
        local item_info = self.item_list_data[i]
        item:SetItemInfo(item_info, i)
        item:SetSelect(true)

        local info = config.guild_research_info[item_info.id]
        item:SetLock(self.ctrl:GetResearchBuildLevel() < info.need_lv)
        item:ShowCircle(true)

        if select_id == item_info.id then
            self:OnItemClick(item_info, i)
        end
    end

    if not self.parent:GetClickItemInfo() and self.parent:GetOpenIndex() == self.type then
        self:OnItemClick(self.item_list_data[1], 1)
    end
end

function ResearchTemplate:OnItemClick(item_info, idx)
    self.parent:OnItemClick(item_info)
    self.ctrl_skill:SetSelectedIndexEx(idx-1)
end

return ResearchTemplate