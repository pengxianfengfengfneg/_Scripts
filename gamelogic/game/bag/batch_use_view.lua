local BatchUseView = Class(game.BaseView)

function BatchUseView:_init(ctrl)
    self._package_name = "ui_bag"
    self._com_name = "batch_use_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function BatchUseView:OpenViewCallBack(info)
    self.info = info
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1568])

    self:InitBtn()

    local item = self:GetTemplate("game/bag/item/goods_item", "item")
    item:SetItemInfo(info)
    item:SetShowTipsEnable(true)

    self._layout_objs.item_name:SetText(config.goods[info.id].name)

    self:BindEvent(game.NumberKeyboardEvent.Number, function(key)
        local num = tonumber(self._layout_objs.num:GetText())
        if key >= 0 then
            self:SetNum(num * 10 + key)
        else
            self:SetNum(math.floor(num / 10))
        end
    end)

    self:SetNum(info.num)
end

function BatchUseView:InitBtn()
    self._layout_objs.num:AddClickCallBack(function()
        game.MainUICtrl.instance:OpenNumberKeyboard(nil, 770)
    end)

    self._layout_objs.btn_ok:AddClickCallBack(function()
        local num = tonumber(self._layout_objs.num:GetText())
        game.BagCtrl.instance:SendUseGoods(self.info.pos, num)
        self:Close()
    end)

    self._layout_objs.btn_minus:AddClickCallBack(function()
        local num = tonumber(self._layout_objs.num:GetText())
        if num > 1 then
            self:SetNum(num - 1)
        end
    end)
    self._layout_objs.btn_plus:AddClickCallBack(function()
        local num = tonumber(self._layout_objs.num:GetText())
        self:SetNum(num + 1)
    end)
    self._layout_objs.btn_max:AddClickCallBack(function()
        local own = self.ctrl:GetNumByPos(self.info.pos)
        self:SetNum(own)
    end)
end

function BatchUseView:SetNum(num)
    local own = self.ctrl:GetNumByPos(self.info.pos)
    local use_num = config.goods_effect[self.info.id].use_num
    num = math.min(num, own, use_num)
    num = math.max(num, 0)
    self._layout_objs.num:SetText(num)
end

function BatchUseView:OnEmptyClick()
    self:Close()
end

return BatchUseView
