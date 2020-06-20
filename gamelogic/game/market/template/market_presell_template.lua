local MarketPresellTemplate = Class(game.UITemplate)

local PageIndex = {
    Tag = 0,
    Item = 1,
    EquipTag = 2,
    None = 3,
}

local PageLevel = {
    [PageIndex.Tag] = 2,
    [PageIndex.EquipTag] = 3,
    [PageIndex.Item] = 4,
    [PageIndex.None] = 4,
}

local SearchType = 1

function MarketPresellTemplate:_init()
    self.ctrl = game.MarketCtrl.instance   
end

function MarketPresellTemplate:OpenViewCallBack()
    self:Init()
    self:InitCateList()
    self:RegisterAllEvents()
end

function MarketPresellTemplate:CloseViewCallBack()
    
end

function MarketPresellTemplate:RegisterAllEvents()
    local events = {
        {game.MarketEvent.OnMarketSearchInfo, handler(self, self.OnMarketSearchInfo)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MarketPresellTemplate:Init()
    self.page_list = {}

    self.list_item = self:CreateList("list_item", "game/market/item/market_goods_item")
    self.list_item:SetRefreshItemFunc(function(item, idx)
        local item_info = self.item_list_data[idx]
        item_info.presell = (item_info.stat == 1) and 1 or 0
        item:SetItemInfo(item_info, 1)
        item:AddClickEvent(function()
            self.ctrl:OpenMarketPresellView(item_info)
        end)
    end)

    self.btn_search = self._layout_objs.btn_search
    self.btn_search:AddClickCallBack(function()
        self.ctrl:OpenMarketSearchView()
    end)

    self.txt_collect = self._layout_objs.txt_collect
    self._layout_objs.txt_no_sell:SetText(config.words[5646])

    self.ctrl_cate = self:GetRoot():AddControllerCallback("ctrl_cate", function(idx)
        self:OnCateClick(idx+1)
    end)
    self.ctrl_page = self:GetRoot():GetController("ctrl_page")

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

function MarketPresellTemplate:InitCateList()
    self.cate_list_data = self.ctrl:GetRareCateList()
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

    self.ctrl_cate:SetSelectedIndexEx(0)
end

function MarketPresellTemplate:OnCateClick(idx)
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

function MarketPresellTemplate:OnTagClick(idx)
    local tag_data = self.tag_list_data[idx]
    self.tag_id = tag_data.id
    self.ctrl:SendMarketSearch(self.tag_id, nil, SearchType)
end

function MarketPresellTemplate:OnMarketSearchInfo(data)
    if data.tag == self.tag_id and data.id == 0 and data.stat == SearchType then
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

function MarketPresellTemplate:ShowEquipTagList()
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

function MarketPresellTemplate:OnEquipTagClick(idx)
    local equip_tag = self.equip_list_data[idx].id
    self.item_list_data = self.ctrl:GetMarketSearchEquipItems(self.tag_id, equip_tag, SearchType)

    local item_num = #self.item_list_data
    self.list_item:SetItemNum(item_num)
    if item_num == 0 then
        self:SetPageIndex(PageIndex.None)
    else
        self:SetPageIndex(PageIndex.Item)
    end
end

function MarketPresellTemplate:RefreshView(cate, tag, eq_tag)
    self.ctrl_cate:SetSelectedIndexEx(self.ctrl:GetCateIndex(cate)-1)
    if tag then
        self.refresh_tag = tag
        self:OnTagClick(self.ctrl:GetTagIndex(tag))
    end
    if eq_tag then
        self.refresh_eq_tag = eq_tag
    end
end

function MarketPresellTemplate:SetPageIndex(index)
    self.page_idx = index
    self.ctrl_page:SetSelectedIndexEx(index)

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

function MarketPresellTemplate:BackPage()
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

return MarketPresellTemplate