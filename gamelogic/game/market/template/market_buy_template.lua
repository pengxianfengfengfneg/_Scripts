local MarketBuyTemplate = Class(game.UITemplate)

local PageIndex = {
    Tag = 0,
    Item = 1,
    None = 2,
    Default = 3,
    EquipTag = 4,
}

local PageLevel = {
    [PageIndex.Default] = 1,
    [PageIndex.Tag] = 2,
    [PageIndex.EquipTag] = 3,
    [PageIndex.Item] = 4,
    [PageIndex.None] = 4,
}

local SearchType = 2

function MarketBuyTemplate:_init()
    self.ctrl = game.MarketCtrl.instance   
end

function MarketBuyTemplate:OpenViewCallBack()
    self:Init()
    self:InitHotList()
    self:InitCateList()
    self:RegisterAllEvents()
    self:SetPageIndex(PageIndex.Default)
end

function MarketBuyTemplate:CloseViewCallBack()
    
end

function MarketBuyTemplate:RegisterAllEvents()
    local events = {
        {game.MarketEvent.OnMarketSearchInfo, handler(self, self.OnMarketSearchInfo)},
        {game.MarketEvent.OnMarketBuy, handler(self, self.OnMarketBuy)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MarketBuyTemplate:Init()
    self.page_list = {}

    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
    self.ctrl_cate = self:GetRoot():AddControllerCallback("ctrl_cate", function(idx)
        self:OnCateClick(idx+1)
    end)
    self.ctrl_cate_state = self:GetRoot():GetController("ctrl_cate_state")

    self.btn_search = self._layout_objs["btn_search"]
    self.btn_search:AddClickCallBack(function()
        self.ctrl:OpenMarketSearchView()
    end)

    self.list_item = self:CreateList("list_item", "game/market/item/market_goods_item")
    self.list_item:SetRefreshItemFunc(function(item, idx)
        local item_info = self.item_list_data[idx]
        item_info.rare = self.ctrl:IsRare(self.cate_id, item_info.tag)
        item_info.cate = self.cate_id
        item_info.tag = item_info.tag
        item:SetItemInfo(item_info)
        item:AddClickEvent(function()
            self.ctrl:OpenMarketBuyView(item_info)
        end)
    end)

    self.list_tag = self._layout_objs["list_tag"]
    self.list_cate = self._layout_objs["list_cate"]

    self.list_equip = self:CreateList("list_equip", "game/market/item/market_third_tag_item")
    self.list_equip:SetRefreshItemFunc(function(item, idx)
        local item_info = self.equip_list_data[idx]
        item:SetItemInfo(item_info, SearchType)
        item:AddClickEvent(function()
            self:OnEquipTagClick(idx)
        end)
    end)
end

function MarketBuyTemplate:InitHotList()
    self.hot_list_data = self.ctrl:GetHotList()
    self.list_hot = self:CreateList("list_hot", "game/market/item/market_hot_item")
    self.list_hot:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo(self.hot_list_data[idx])
    end)
    self.list_hot:SetItemNum(#self.hot_list_data)
end

function MarketBuyTemplate:InitCateList()
    self.cate_list_data = self.ctrl:GetCateList()

    local cate_num = #self.cate_list_data
    
    self.list_cate:SetItemNum(cate_num)
    self.ctrl_cate:SetPageCount(cate_num)

    for i=1, cate_num do
        local id = self.cate_list_data[i].id
        local cate = self.list_cate:GetChildAt(i-1)
        cate:SetText(self.cate_list_data[i].name)
        cate:AddClickCallBack(function()
            self.ctrl_cate:SetSelectedIndexEx(i-1)
        end)
        cate:GetChild("n8"):SetSprite("ui_market", "icon_"..string.format("%02d", id))
        cate:GetChild("n9"):SetSprite("ui_market", "icon_"..string.format("%02d", id).."_1")
    end
end

function MarketBuyTemplate:OnCateClick(idx)
    local cate_id = self.cate_list_data[idx].id
    self.cate_id = cate_id
    self.tag_list_data = self.ctrl:GetTagList(cate_id)

    local tag_num = #self.tag_list_data
    if tag_num > 1 then
        self.list_tag:SetItemNum(#self.tag_list_data)
        for i=1, #self.tag_list_data do
            local tag = self.list_tag:GetChildAt(i-1)
            tag:SetText(self.tag_list_data[i].name)
            tag:AddClickCallBack(function()
                self:OnTagClick(i)
            end)
        end
    else
        self.list_tag:SetItemNum(0)
    end

    local tag_num = #self.tag_list_data
    if tag_num == 1 then
        self:OnTagClick(1)
    else
        self:SetPageIndex(PageIndex.Tag)
    end
end

function MarketBuyTemplate:OnTagClick(idx)
    local tag_data = self.tag_list_data[idx]
    self.tag_id = tag_data.id
    self.ctrl:SendMarketSearch(self.tag_id, nil, SearchType)
end

function MarketBuyTemplate:OnMarketSearchInfo(data)
    if data.tag == self.tag_id and data.id == 0 and data.stat == SearchType then
        if self.refresh_items then
            self:RefreshItems(self.cate_id, self.tag_id, self.equip_tag)
            self.refresh_items = nil
            return
        end

        local eq_list = self.ctrl:GetEquipTagList(self.tag_id)
        if #eq_list > 0 then
            self:SetPageIndex(PageIndex.EquipTag)
            self:ShowEquipTagList()
        else    
            self.item_list_data = self.ctrl:GetMarketSearchItems(self.tag_id, SearchType)

            local item_num = #self.item_list_data
            self.list_item:SetItemNum(item_num)
            if item_num == 0 then
                self:SetPageIndex(PageIndex.None)
            else
                self:SetPageIndex(PageIndex.Item)
            end
        end
    end
end

function MarketBuyTemplate:ShowEquipTagList()
    self.equip_list_data = self.ctrl:GetEquipTagList(self.tag_id)
    self.list_equip:SetItemNum(#self.equip_list_data)

    if self.refresh_eq_tag then
        if self.refresh_tag == self.tag_id and self.refresh_eq_tag ~= 0 then
            self:OnEquipTagClick(self.ctrl:GetEquipTagIndex(self.refresh_tag, self.refresh_eq_tag))
        end
        self.refresh_tag = nil
        self.refresh_eq_tag = nil
    end
end

function MarketBuyTemplate:OnEquipTagClick(idx)
    self.equip_tag = self.equip_list_data[idx].id
    self.item_list_data = self.ctrl:GetMarketSearchEquipItems(self.tag_id, self.equip_tag, SearchType)
    local item_num = #self.item_list_data
    self.list_item:SetItemNum(item_num)
    if item_num == 0 then
        self:SetPageIndex(PageIndex.None)
    else
        self:SetPageIndex(PageIndex.Item)
    end
end

function MarketBuyTemplate:RefreshView(cate, tag, eq_tag)
    self.ctrl_cate:SetSelectedIndexEx(self.ctrl:GetCateIndex(cate)-1)
    if tag and tag ~= 0 then
        self.refresh_tag = tag
        if #self.tag_list_data > 1 then
            self:OnTagClick(self.ctrl:GetTagIndex(tag))
        end
    end
    if eq_tag and eq_tag ~= 0 then
        self.refresh_eq_tag = eq_tag
    end
end

function MarketBuyTemplate:RefreshItems(cate, tag, eq_tag)
    self.ctrl_cate:SetSelectedIndexEx(self.ctrl:GetCateIndex(cate)-1)

    if eq_tag and eq_tag ~= 0 then
        self.item_list_data = self.ctrl:GetMarketSearchEquipItems(tag, eq_tag, SearchType)
    else
        self.item_list_data = self.ctrl:GetMarketSearchItems(tag, SearchType)
    end

    local item_num = #self.item_list_data
    self.list_item:SetItemNum(item_num)
    if item_num == 0 then
        self:SetPageIndex(PageIndex.None)
    else
        self:SetPageIndex(PageIndex.Item)
    end
end

function MarketBuyTemplate:OnMarketBuy()
    if self.tag_id then
        if self.page_index == PageIndex.Item then
            self.refresh_items = true
        end
        if self.page_index == PageIndex.Tag or self.page_index == PageIndex.Item or self.page_index == PageIndex.None then
            self.ctrl:SendMarketSearch(self.tag_id, nil, SearchType)
        end
    end
end

function MarketBuyTemplate:SetPageIndex(index)
    self.ctrl_page:SetSelectedIndexEx(index)
    self.page_index = index

    local page_lv = PageLevel[index]
    for i=#self.page_list, 1, -1 do
        local page_index = self.page_list[i]
        local level = PageLevel[page_index]
        if page_lv <= level then
            table.remove(self.page_list, i)
        else
            break
        end
    end
    table.insert(self.page_list, index)
end

function MarketBuyTemplate:BackPage()
    local page_num = #self.page_list
    if page_num > 1 then
        local back_page = self.page_list[page_num-1]
        table.remove(self.page_list, page_num)
        self.ctrl_page:SetSelectedIndexEx(back_page)
        return true
    else
        return false
    end
end

return MarketBuyTemplate