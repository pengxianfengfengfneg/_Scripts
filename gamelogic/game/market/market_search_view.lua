local MarketSearchView = Class(game.BaseView)

function MarketSearchView:_init(ctrl)
    self._package_name = "ui_market"
    self._com_name = "market_search_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function MarketSearchView:_delete()
    
end

function MarketSearchView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:InitItemList()
end

function MarketSearchView:CloseViewCallBack()

end

function MarketSearchView:Init()
    self._layout_objs.txt_sell_state:SetText(config.words[5607])
    self._layout_objs.txt_sell:SetText(config.words[5608])
    self._layout_objs.txt_presell:SetText(config.words[5609])

    self.btn_search = self._layout_objs.btn_search
    self.btn_search:SetText(config.words[5610])
    self.btn_search:AddClickCallBack(function()
        self:SearchGoods()
    end)

    self.txt_name = self._layout_objs.txt_name

    self.btn_close = self._layout_objs.btn_close
    self.btn_close:AddClickCallBack(function()
        self.txt_name:SetText("")
        self.txt_name:RequestFocus()
    end)
end

function MarketSearchView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5606])
end

function MarketSearchView:InitItemList()
    self.list_item = self._layout_objs.list_item
    self.list_item:SetItemNum(0)
end

function MarketSearchView:SearchGoods()
    local name = self._layout_objs.txt_name:GetText()

    local item_list = {}
    for k, v in pairs(config.market_item) do
        local goods = config.goods[v.id]
        if goods and string.find(goods.name, name) then
            local item_data = {v, goods.name}
            table.insert(item_list, item_data)
        end
    end

    for k, v in pairs(config.market_pet) do
        local pet = config.pet[v.id]
        if pet and string.find(pet.name, name) then
            local item_data = {v, pet.name}
            table.insert(item_list, item_data)
        end
    end

    self.item_list = item_list

    self.list_item:SetItemNum(#item_list)
    for i=1, #item_list do
        local item = self.list_item:GetChildAt(i-1)
        item:SetText(item_list[i][2])
        item:AddClickCallBack(function()
            self:OnItemClick(i)
        end)
    end
end

function MarketSearchView:GetSearchState()
    if self._layout_objs.checkbox_sell:GetSelected() then
        return 1
    elseif self._layout_objs.checkbox_presell:GetSelected() then
        return 2
    end
end

function MarketSearchView:OnItemClick(i)
    local item_info = self.item_list[i][1]

    local eq_tag = item_info.eq_tag
    local tag = item_info.tag
    local cate = self.ctrl:GetTagCateId(tag)
    local search_state = self:GetSearchState()

    if search_state == 1 then
        self.ctrl:JumpToBuyPage(cate, tag, eq_tag)
    else
        self.ctrl:JumpToPresellPage(cate, tag, eq_tag)
    end

    self:Close()
end

return MarketSearchView
