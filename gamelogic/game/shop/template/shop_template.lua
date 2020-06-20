local ShopTemplate = Class(game.UITemplate)

local PageState = {
    Cate = 1,
    Items = 2,
}

local MoneyConfig = {
    [game.MoneyType.BackupGoldFirst] = {
        change = function(change_list)
            if change_list[game.MoneyType.Gold] or change_list[game.MoneyType.BackupGold] then
                return true
            end
            return false
        end,
    },
    [game.MoneyType.BindGoldFirst] = {
        change = function(change_list)
            if change_list[game.MoneyType.Gold] or change_list[game.MoneyType.BindGold] or change_list[game.MoneyType.BackupGold] then
                return true
            end
            return false
        end,
        types = {
            game.MoneyType.BindGold,
            game.MoneyType.BackupGoldFirst,
        }
    }
}

function ShopTemplate:_init(view)
    self.parent = view
    self.ctrl = game.ShopCtrl.instance   
end

function ShopTemplate:OpenViewCallBack()
    self.txt_info = self._layout_objs["txt_info"]
    self.list_tag = self._layout_objs["list_tag"]

    self.ctrl_tag = self:GetRoot():AddControllerCallback("ctrl_tag", function(idx)
        self:OnTagClick(idx+1)
    end)
    self.ctrl_type = self:GetRoot():GetController("ctrl_type")
    self.ctrl_height = self:GetRoot():GetController("ctrl_height")
    self.ctrl_item = self:GetRoot():GetController("ctrl_item")

    self.list_item = self:CreateList("list_item", "game/shop/item/shop_item")
    self.list_item:SetRefreshItemFunc(function(item, idx)
        local item_info = self.item_list_data[idx]
        item:SetItemInfo(item_info)
    end)

    self.list_cate = self:CreateList("list_cate", "game/shop/item/shop_cate_item")
    self.list_cate:SetRefreshItemFunc(function(item, idx)
        local item_info = self.cate_list_data[idx]
        item:SetItemInfo(item_info)
        item:AddClickFunc(function()
            self:OnCateClick(idx)
        end)
    end)

    self.txt_cond = self._layout_objs["txt_cond"]

    self.txt_money1 = self._layout_objs["txt_money1"]
    self.img_money1 = self._layout_objs["img_money1"]

    self.txt_money2 = self._layout_objs["txt_money2"]
    self.img_money2 = self._layout_objs["img_money2"]

    self.ctrl_money = self:GetRoot():GetController("ctrl_money")    
end

function ShopTemplate:CloseViewCallBack()

end

function ShopTemplate:InitPage(shop_id, page)
    self.tag_list_data = self.ctrl:GetTagList(shop_id, page)

    self.list_tag:SetItemNum(#self.tag_list_data)
    for k, tag in ipairs(self.tag_list_data) do
        local tag_obj = self.list_tag:GetChildAt(k-1)
        tag_obj:SetText(tag.name)

        if tag.icon ~= "" then
            local next_icon = self:GetHighlightName(tag.icon)
            tag_obj:GetChild("img_icon"):SetSprite("ui_shop", tag.icon)
            tag_obj:GetChild("img_icon2"):SetSprite("ui_shop", next_icon)
        end
    end
    self.ctrl_tag:SetPageCount(#self.tag_list_data)
    self.list_tag:SetVisible(#self.tag_list_data > 1)

    self:RefreshView(1)
    self.ctrl_height:SetSelectedIndexEx(#self.tag_list_data <= 5 and 0 or 1)

    self.price_type = config.shop[shop_id].price_type
    self:SetMoneyInfo(self.price_type, true)

    self:RegisterAllEvents()
end

function ShopTemplate:OnTagClick(idx)
    local tag_data = self.tag_list_data[idx]
    self.shop_id = tag_data.shop_id
    self.tag_id = tag_data.tag_id
    self.cate_list_data = self.ctrl:GetCateList(self.tag_id)

    if self.ctrl:HaveCate(tag_data.tag_id) then
        if self.cate_idx then
            self:ShowItems(self.cate_idx)
            self.cate_idx = nil
        else
            self:ShowCateList()
        end
    else
        self:ShowItems(1)
    end
end

function ShopTemplate:OnCateClick(idx)
    self:ShowItems(idx)
end

function ShopTemplate:ShowCateList()
    self.list_cate:SetItemNum(#self.cate_list_data)
    self.item_list_data = nil
    self.cate_id = nil
    self.ctrl_type:SetSelectedIndexEx(0)
    self:SetCondText()
    self.page_state = PageState.Cate
end

function ShopTemplate:ShowItems(cate_idx)
    local cate_data = self.cate_list_data[cate_idx]
    self.cate_id = cate_data.cate_id
    self.item_list_data = self.ctrl:GetItems(cate_data.cate_id)

    local item_num = #self.item_list_data
    self.list_item:SetItemNum(item_num)
    self.ctrl_item:SetPageCount(item_num)

    self.ctrl_type:SetSelectedIndexEx(1)
    self:SetCondText()
    self:ScrollToItem()
    self.page_state = PageState.Items
end

function ShopTemplate:RefreshView(tag_idx, cate_idx, item_id)
    self.cate_idx = cate_idx
    self.item_id = item_id
    self.ctrl_tag:SetSelectedIndexEx(tag_idx-1)
end

function ShopTemplate:SetCondText()
    if self.item_list_data and #self.item_list_data > 0 then
        local item = self.item_list_data[1]
        self.txt_cond:SetText(self.ctrl:GetCondMsg(item.conds[1]))

        local color = self.ctrl:IsMeetCond(item.conds[1]) and game.Color.GrayBrown or game.Color.Red
        self.txt_cond:SetColor(table.unpack(color))
    else
        self.txt_cond:SetText("")
    end
end

function ShopTemplate:ScrollToItem()
    if self.item_id then
        local index = 0
        for k, v in ipairs(self.item_list_data) do
            if v.item_id == self.item_id then
                index = k
            end
        end
        if index ~= 0 then
            self.ctrl_item:SetSelectedIndexEx(index-1)
            local column_count = self._layout_objs["list_item"].columnCount
            index = (math.ceil(index / column_count) - 1) * column_count
            self.list_item:ScrollToView(index, false, true)
        end
        self.item_id = nil
    else
        if #self.item_list_data > 0 then
            self.list_item:ScrollToView(0)
            self.ctrl_item:SetSelectedIndexEx(-1)
        end
    end
end

function ShopTemplate:GetHighlightName(name)
    if name == "" then
        return ""
    end
    local index = string.match(name, "%d+")
    local prefix = string.sub(name, 1, string.find(name, index)-1)
    return prefix..string.format("%02d", tonumber(index)+1)
end

function ShopTemplate:RegisterAllEvents()
    local events = {
        [game.ShopEvent.BuySuccess] = function(data)
            if self.cate_id  == data.cate_id then
                self.item_list_data = self.ctrl:GetItems(self.cate_id)
                self.list_item:SetItemNum(#self.item_list_data)
            end
        end,
    }
    if self.ctrl:IsMoneyType(self.price_type) then
        events[game.MoneyEvent.Change] = function(change_list)
            local money_cfg = MoneyConfig[self.price_type]
            if money_cfg and money_cfg.change then
                if not money_cfg.change(change_list) then
                    return
                end
            else
                if not change_list[self.price_type] then
                    return
                end
            end
            self:SetMoneyInfo(self.price_type)
        end
    else
        events[game.BagEvent.BagItemChange] = function(change_list)
            if change_list[self.price_type] then
                self:SetMoneyInfo(self.price_type)
            end
        end
    end
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

function ShopTemplate:BackToCateList()
    if self.ctrl:HaveCate(self.tag_id) then
        self:ShowCateList()
        return true
    end
    return false
end

function ShopTemplate:GetPageState()
    return self.page_state
end

function ShopTemplate:SetMoneyInfo(price_type, init)
    local money_config = MoneyConfig[price_type]
    local types = money_config and money_config.types or {price_type}

    for id, type in ipairs(types) do
        self["txt_money"..id]:SetText(self.ctrl:GetMoneyByType(type))
        if init then
            local img_money = self["img_money"..id]
            if self.ctrl:IsMoneyType(type) then
                img_money:SetSprite("ui_common", config.money_type[type].icon, true)
            else
                img_money:SetSprite("ui_item", config.goods[type].icon)
                img_money:SetSize(42, 33)
            end
        end
    end

    if init then
        self.ctrl_money:SetSelectedIndexEx(#types-1)
    end
end

return ShopTemplate