local GoodsInfoView = Class(game.BaseView)

local pet_exp_pill = config.pet_common.pet_exp_pill_id
local pet_exp_item = config.pet_common.pet_exp_item

function GoodsInfoView:_init(ctrl)
    self._package_name = "ui_bag"
    self._com_name = "goods_info_view"
    self._view_level = game.UIViewLevel.Fouth
    self._mask_type = game.UIMaskType.Full

    self._ui_order = game.UIZOrder.UIZOrder_Tips + 3

    self._layer_name = game.LayerName.UIDefault

    self.ctrl = ctrl

    self:InitFunc()
end

function GoodsInfoView:OnEmptyClick()
    self:Close()
end

function GoodsInfoView:OpenViewCallBack(info, bag_id)
    self.info = info
    self.bag_id = bag_id
    local goods_config = config.goods[info.id]
    local icon = self:GetTemplate("game/bag/item/goods_item", "icon")
    icon:SetItemInfo({ id = info.id })
    self._layout_objs.num:SetText(info.num or self.ctrl:GetNumById(info.id))
    local type_config = self:GetGoodsType(goods_config)
    self._layout_objs.type:SetText(type_config.name)
    local price = goods_config.price[1]
    if price then
        self._layout_objs.price:SetText(price[2])
    else
        self._layout_objs.price:SetText(0)
    end
    self._layout_objs.name:SetText(goods_config.name)
    local color = cc.GoodsColor_light[goods_config.color]
    self._layout_objs.name:SetColor(color.x, color.y, color.z, color.w)
    if info.id == pet_exp_pill and info.effect then
        self._layout_objs.desc:SetText(goods_config.desc .. "\n" .. string.format(config.words[1477], info.effect))
    elseif info.id == pet_exp_item then
        self._layout_objs.desc:SetText(goods_config.desc .. "\n" .. string.format(config.words[1477], config.goods_effect[info.id].effect))
    else
        self._layout_objs.desc:SetText(goods_config.desc)
    end

    local way_list = self:CreateList("list", "game/bag/item/get_way_item")
    way_list:SetRefreshItemFunc(function(item, idx)
        local way_info = config.goods_get_way[goods_config.acquire[idx]]
        if way_info then
            item:SetItemInfo(way_info, goods_config.id)
            item:AddClickEvent(way_info.click_func)
            item:SetGoVisible(way_info.go_visible ~= false)

            if game.IsZhuanJia then
                local hide_way_list = {3}
                item:SetGoVisible(not table.indexof(hide_way_list, way_info.type))
            end
        end
    end)
    way_list:SetItemNum(#goods_config.acquire)

    if bag_id then
        local btn_func_list = {}
        for _, v in ipairs(self.btn_func) do
            if v.btn_visible() then
                table.insert(btn_func_list, v)
            end
        end
        self._layout_objs.btn_list:SetItemNum(#btn_func_list)
        for i = 0, #btn_func_list - 1 do
            local btn = self._layout_objs.btn_list:GetChildAt(i)
            btn:SetText(btn_func_list[i + 1].btn_name())
            btn:AddClickCallBack(btn_func_list[i + 1].click_func)
        end
        local height = math.ceil(#btn_func_list / 3)
        self._layout_objs.btn_list:SetSize(453, 60 * height)
        self._layout_objs.btn_line:SetVisible(true)
    else
        self._layout_objs.btn_list:SetItemNum(0)
        self._layout_objs.btn_list:SetSize(453, 0)
        self._layout_objs.btn_line:SetVisible(false)
    end

    self:SetPosition(info.x, info.y)
end

function GoodsInfoView:CloseViewCallBack()
    self.btn_sell_text = nil
    self.btn_sell_func = nil
end

function GoodsInfoView:GetGoodsType(goods_cfg)
    if config.goods_cate[goods_cfg.type][0] then
        return config.goods_cate[goods_cfg.type][0]
    else
        return config.goods_cate[goods_cfg.type][goods_cfg.subtype]
    end
end

function GoodsInfoView:OverrideSellEvent(title, func)
    self.btn_sell_text = title
    self.btn_sell_func = func
end

function GoodsInfoView:SetPosition(x, y)
    self._layout_objs.group_tips:SetPosition(x or 115, y or 355)
end

function GoodsInfoView:InitFunc()
    self.btn_func = {
        [1] = {
            click_func = function()
                local goods_config = config.goods[self.info.id]
                local role_lv = game.RoleCtrl.instance:GetRoleLevel()
                if role_lv >= goods_config.lv then
                    game.GoodsUseUtils.Use(self.info)
                    self:Close()
                else
                    game.GameMsgCtrl.instance:PushMsg(string.format(config.words[1569], goods_config.lv))
                end
            end,
            btn_name = function()
                return config.words[1572]
            end,
            btn_visible = function()
                return game.GoodsUseUtils.CanUse(self.info.id)
            end
        },
        [2] = {
            click_func = function()
                if self.btn_sell_func then
                    self.btn_sell_func()
                else
                    self.ctrl:SendBagSellItem(self.bag_id, {{pos = self.info.pos}})
                end
                self:Close()
            end,
            btn_name = function()
                return self.btn_sell_text or config.words[1562]
            end,
            btn_visible = function()
                return true
            end,
        },
        [3] = {
            click_func = function()
                game.ChatCtrl.instance:ShareItem(self.info)
                self:Close()
            end,
            btn_name = function()
                return config.words[1579]
            end,
            btn_visible = function()
                return true
            end,
        },
        [4] = {
            click_func = function()
                game.FoundryCtrl.instance:OpenView(4)
                self:Close()
            end,
            btn_name = function()
                return config.words[1580]
            end,
            btn_visible = function()
                return config.compose[self.info.id] ~= nil
            end,
        },
        [5] = {
            click_func = function()
                local item_info = {}
                for k, v in pairs(self.info) do
                    item_info[k] = v
                end
                item_info.tag = config.market_item[self.info.id].tag
                game.MarketCtrl.instance:OpenMarketGoodsView(item_info)
                self:Close()
            end,
            btn_name = function()
                return config.words[1570]
            end,
            btn_visible = function()
                return self.info.bind == 0 and game.MarketCtrl.instance:IsValid(self.info.id)
            end,
        },
    }
end

return GoodsInfoView
