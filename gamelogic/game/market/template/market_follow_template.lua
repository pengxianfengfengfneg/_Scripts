local MarketFollowTemplate = Class(game.UITemplate)

local PageIndex = {
    Item = 0,
    Tag = 1,
    EquipTag = 2,
    None = 3,
}

local PageLevel = {
    [PageIndex.Tag] = 2,
    [PageIndex.EquipTag] = 3,
    [PageIndex.Item] = 4,
    [PageIndex.None] = 4,
}

local AllCateConfig = {
    id = 0,
    name = config.words[5669],
}

function MarketFollowTemplate:_init()
    self.ctrl = game.MarketCtrl.instance   
end

function MarketFollowTemplate:OpenViewCallBack()
    self:Init()
    self:InitCateList()
    self:RegisterAllEvents()
end

function MarketFollowTemplate:CloseViewCallBack()
    
end

function MarketFollowTemplate:RegisterAllEvents()
    local events = {
        {game.MarketEvent.OnMarketFollow, handler(self, self.OnMarketFollow)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MarketFollowTemplate:Init()
    self.page_list = {}

    self.list_item = self:CreateList("list_item", "game/market/item/market_goods_item")
    self.list_item:SetRefreshItemFunc(function(item, idx)
        local item_info = self.item_list_data[idx]
        local page_idx = (item_info.stat==1) and 1 or 0
        item:SetItemInfo(item_info, page_idx)
        item:AddClickEvent(function()
            if item_info.stat == 1 then
                self.ctrl:OpenMarketPresellView(item_info)
            elseif item_info.stat == 2 then
                self.ctrl:OpenMarketBuyView(item_info)
            end
        end)
    end)

    self.btn_search = self._layout_objs.btn_search
    self.btn_search:AddClickCallBack(function()
        self.ctrl:OpenMarketSearchView()
    end)

    self._layout_objs.txt_no_follow:SetText(config.words[5647])

    self.ctrl_cate = self:GetRoot():AddControllerCallback("ctrl_cate", function(idx)
        self:OnCateClick(idx+1)
    end)
    self.ctrl_page = self:GetRoot():GetController("ctrl_page")

    self.list_tag = self._layout_objs["list_tag"]
    self.list_cate = self._layout_objs["list_cate"]

    self.list_equip = self:CreateList("list_equip", "game/market/item/market_third_tag_item")
    self.list_equip:SetRefreshItemFunc(function(item, idx)
        local item_info = self.equip_list_data[idx]
        item:SetItemInfo(item_info)
        item:AddClickEvent(function()
            self:OnEquipTagClick(idx)
        end)
    end)

    self.txt_collect = self._layout_objs.txt_collect
end

function MarketFollowTemplate:InitCateList()
    self.cate_list_data = self.ctrl:GetRareCateList()
    table.insert(self.cate_list_data, 1, AllCateConfig)
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

function MarketFollowTemplate:OnCateClick(idx)
    local cate_id = self.cate_list_data[idx].id
    self.cate_id = cate_id

    if cate_id == 0 then
        self:UpdateFollowItemList()
        return
    end

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

function MarketFollowTemplate:OnTagClick(idx)
    local tag_data = self.tag_list_data[idx]
    self.tag_id = tag_data.id

    local eq_list = self.ctrl:GetEquipTagList(self.tag_id)
    if #eq_list > 0 then
        self:ShowEquipTagList()
        self:SetPageIndex(PageIndex.EquipTag)
    else    
        self:UpdateFollowItemList()
    end
end

function MarketFollowTemplate:ShowEquipTagList()
    self.equip_list_data = self.ctrl:GetEquipTagList(self.tag_id)
    self.list_equip:SetItemNum(#self.equip_list_data)
end

function MarketFollowTemplate:OnEquipTagClick(idx)
    local equip_tag = self.equip_list_data[idx].id
    self.item_list_data = self.ctrl:GetFollowEquipItems(self.tag_id, equip_tag)

    local item_num = #self.item_list_data
    self.list_item:SetItemNum(item_num)
    if item_num == 0 then
        self:SetPageIndex(PageIndex.None)
    else
        self:SetPageIndex(PageIndex.Item)
    end
end

function MarketFollowTemplate:UpdateFollowItemList()
    if self.cate_id == 0 then
        self.item_list_data = self.ctrl:GetFollowItems()
    else
        self.item_list_data = self.ctrl:GetFollowItems(self.tag_id)
    end
    local item_num = #self.item_list_data
    self.list_item:SetItemNum(item_num)
    if item_num == 0 then
        self:SetPageIndex(PageIndex.None)
    else
        self:SetPageIndex(PageIndex.Item)
    end
end

function MarketFollowTemplate:OnMarketFollow()
    if self.page_index == PageIndex.None or self.page_index == PageIndex.Item then
        self:UpdateFollowItemList()
    end
    self:SetCollectText()
end

function MarketFollowTemplate:SetPageIndex(index)
    self.ctrl_page:SetSelectedIndexEx(index)
    self.page_index = index
    self:SetCollectText()

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

function MarketFollowTemplate:BackPage()
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

function MarketFollowTemplate:SetCollectText()
    local follow_count = self.ctrl:GetFollowNum()
    self.txt_collect:SetText(string.format(config.words[5645], follow_count, config.sys_config["market_max_follow"].value))
end

return MarketFollowTemplate