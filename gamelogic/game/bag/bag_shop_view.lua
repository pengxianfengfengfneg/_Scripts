local BagShopView = Class(game.BaseView)

function BagShopView:_init(ctrl)
    self._package_name = "ui_bag"
    self._com_name = "bag_shop"
    self._view_level = game.UIViewLevel.Second
    self._show_money = true

    self.ctrl = ctrl
end

function BagShopView:OpenViewCallBack()
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[1677])

    self:InitBtn()

    self:InitTemplate()

    self:InitSellList()

    self:SetShopList()

    self:RegisterEvent()

    self.sell_goods_list = {}
    self:SetSellList()

    self:RefreshBag()

    self.shop_ctl = self:GetRoot():GetController("tab_shop")
end

function BagShopView:RegisterEvent()
    self:BindEvent(game.BagEvent.BagItemChange, function()
        self.sell_goods_list = {}
        self:SetSellList()
        self:RefreshBag()
    end)

    self:BindEvent(game.BagEvent.BagChange, function()
        self:RefreshBag()
    end)
end

function BagShopView:InitBtn()
    local btn = self._layout_objs.tab_list:GetChildAt(0)
    btn:SetText(config.words[1561])
    for i = 1, 3 do
        btn = self._layout_objs.tab_list:GetChildAt(i)
        btn:SetText(config.bag_type[i].name)
    end

    btn = self._layout_objs.shop_tab_list:GetChildAt(0)
    btn:AddClickCallBack(function()
        self.sell_goods_list = {}
        self:RefreshBag()
        self:SetSellList()
        self.shop_ctl:SetSelectedIndexEx(0)
    end)

    self._layout_objs.btn_tidy:AddClickCallBack(function()
        self.ctrl:SendBagReset(1)
    end)

    self._layout_objs.btn_storage:AddClickCallBack(function()
        self.ctrl:OpenStorageView()
    end)

    self._layout_objs.btn_sell:AddClickCallBack(function()
        local poses = {}
        for _, v in ipairs(self.sell_goods_list) do
            table.insert(poses, { pos = v.pos })
        end
        self.ctrl:SendBagSellItem(1, poses)
        self.sell_goods_list = {}
    end)
end

function BagShopView:InitTemplate()
    self.bag_lists = {}
    for i = 0, 3 do
        local template = self:GetTemplateByObj("game/bag/bag_goods_list_part", self._layout_objs.list:GetChildAt(i))
        template:SetSelectSell(function(goods_info)
            self.shop_ctl:SetSelectedIndexEx(1)
            table.insert(self.sell_goods_list, goods_info)
            self:SetSellList()
            self:RefreshBag()
        end)
        table.insert(self.bag_lists, template)
    end

    self._layout_objs.list:SetHorizontalBarTop(true)
end

function BagShopView:InitSellList()
    self.sell_list = self:CreateList("sell_list", "game/bag/item/goods_item")
    self.sell_list:SetRefreshItemFunc(function(item, idx)
        local info = self.sell_goods_list[idx]
        if info then
            item:SetItemInfo(info)
            item:AddClickEvent(function()
                self.ctrl.goods_info_view:OverrideSellEvent(config.words[101], function()
                    for i, v in ipairs(self.sell_goods_list) do
                        if v.pos == info.pos then
                            table.remove(self.sell_goods_list, i)
                            break
                        end
                    end
                    self:SetSellList()
                    self:RefreshBag()
                end)
                self.ctrl:OpenGoodsInfoView(info, 0)
            end)
            item:AddDoubleClickEvent(function()
                for i, v in ipairs(self.sell_goods_list) do
                    if v.pos == info.pos then
                        table.remove(self.sell_goods_list, i)
                        break
                    end
                end
                self:SetSellList()
                self:RefreshBag()
            end)
        else
            item:ResetItem()
        end
    end)
end

function BagShopView:RefreshBag()
    local bag_info = self.ctrl:GetGoodsBagByBagId(1)
    local all_goods = {}
    for _, v in pairs(bag_info.goods) do
        local flag = true
        for _, val in ipairs(self.sell_goods_list) do
            if v.goods.pos == val.pos then
                flag = false
                break
            end
        end
        if flag then
            all_goods[v.goods.pos] = v.goods
        end
    end
    self.bag_lists[1]:RefreshGoods(all_goods)

    local goods_cate = {}
    for i = 1, 3 do
        goods_cate[i] = {}
        local goods_type = config.bag_type[i].type
        for _, v in pairs(all_goods) do
            local goods_cfg = config.goods[v.id]
            for _, val in pairs(goods_type) do
                if goods_cfg.type == val then
                    table.insert(goods_cate[i], v)
                end
            end
        end
        self.bag_lists[i + 1]:RefreshGoods(goods_cate[i])
    end
end

function BagShopView:SetSellList()
    local item_nums = #self.sell_goods_list
    if item_nums < 20 then
        item_nums = 20
    elseif item_nums % 5 ~= 0 then
        item_nums = item_nums + 5 - item_nums % 5
    end
    self.sell_list:SetItemNum(item_nums)

    local total_price = {}
    for _, v in ipairs(self.sell_goods_list) do
        local cfg = config.goods[v.id]
        for _, val in ipairs(cfg.price) do
            if total_price[val[1]] then
                total_price[val[1]] = total_price[val[1]] + val[2] * v.num
            else
                total_price[val[1]] = val[2] * v.num
            end
        end
    end

    self._layout_objs.money1:SetText(0)
    self._layout_objs.money2:SetText(0)

    local index = 1
    for _, v in pairs(total_price) do
        self._layout_objs["money" .. index]:SetText(v)
        index = index + 1
    end
end

function BagShopView:SetShopList()
    local shop_items = game.ShopCtrl.instance:GetShopItems(12)
    local shop_list = self:CreateList("shop_list", "game/bag/item/shop_item")
    shop_list:SetRefreshItemFunc(function(item, idx)
        local info = shop_items[idx]
        item:SetItemInfo(info)
    end)
    shop_list:SetItemNum(#shop_items)
end

return BagShopView
