local BagView = Class(game.BaseView)

function BagView:_init(ctrl)
    self._package_name = "ui_bag"
    self._com_name = "bag_view"
    self._show_money = true

    self.ctrl = ctrl
end

function BagView:OpenViewCallBack(open_idx)
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[1673])

    self:InitBtn()

    self:InitTemplate()

    self:BindEvent(game.BagEvent.BagItemChange, function()
        self:RefreshBag()
    end)

    self:BindEvent(game.BagEvent.BagChange, function()
        self:RefreshBag()
    end)

    self.tab_controller = self:GetRoot():GetController("tab_bag")
    open_idx = open_idx or 1
    self.tab_controller:SetSelectedIndexEx(open_idx - 1)

    self:RefreshBag()
end

function BagView:InitBtn()
    local btn = self._layout_objs.tab_list:GetChildAt(0)
    btn:SetText(config.words[1561])
    for i = 1, 3 do
        btn = self._layout_objs.tab_list:GetChildAt(i)
        btn:SetText(config.bag_type[i].name)
    end

    self._layout_objs.btn_shop:AddClickCallBack(function()
        self.ctrl:OpenBagShopView()
    end)

    self._layout_objs.btn_storage:AddClickCallBack(function()
        self.ctrl:OpenStorageView()
    end)

    self._layout_objs.btn_tidy:AddClickCallBack(function()
        self.ctrl:SendBagReset(1)
    end)
end

function BagView:InitTemplate()
    self.bag_lists = {}
    for i = 0, 3 do
        local template = self:GetTemplateByObj("game/bag/bag_goods_list", self._layout_objs.list:GetChildAt(i))
        table.insert(self.bag_lists, template)
    end

    self._layout_objs.list:SetHorizontalBarTop(true)
end

function BagView:RefreshBag()
    local bag_info = self.ctrl:GetGoodsBagByBagId(1)
    local all_goods = {}
    for _, v in pairs(bag_info.goods) do
        all_goods[v.goods.pos] = v.goods
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

function BagView:RefreshView(index)
    self.tab_controller:SetSelectedIndexEx(index - 1)
end

return BagView
