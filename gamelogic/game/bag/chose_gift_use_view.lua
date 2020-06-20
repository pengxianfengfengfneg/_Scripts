local ChoseGiftUseView = Class(game.BaseView)

function ChoseGiftUseView:_init(ctrl)
    self._package_name = "ui_bag"
    self._com_name = "chose_gift_use_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function ChoseGiftUseView:OpenViewCallBack(info)
    self.info = info
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1576])

    self:InitBtn()

    self:BindEvent(game.NumberKeyboardEvent.Number, function(key)
        local num = tonumber(self._layout_objs.num:GetText())
        if key >= 0 then
            self:SetNum(num * 10 + key)
        else
            self:SetNum(math.floor(num / 10))
        end
    end)

    local list = self:CreateList("list", "game/bag/item/chose_gift_item")
    local cfg = config.goods_effect[info.id]
    list:SetRefreshItemFunc(function(item, idx)
        local item_id = cfg.effect[idx]
        item:SetItemInfo(item_id)
        item:SetIndex(idx)
        item:SetSelect(idx == 1)
    end)
    self.select_index = 1
    list:SetItemNum(table.nums(cfg.effect))
    list:AddClickItemCallback(function(obj)
        self.select_index = obj:GetIndex()
        list:Foreach(function(v)
            v:SetSelect(v == obj)
        end)
    end)

    self:SetNum(info.num)
end

function ChoseGiftUseView:InitBtn()
    self._layout_objs.num:AddClickCallBack(function()
        game.MainUICtrl.instance:OpenNumberKeyboard(nil, 770)
    end)

    self._layout_objs.btn_get:AddClickCallBack(function()
        local num = tonumber(self._layout_objs.num:GetText())
        game.BagCtrl.instance:SendUseGoods(self.info.pos, num, self.select_index)
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

function ChoseGiftUseView:SetNum(num)
    local own = self.ctrl:GetNumByPos(self.info.pos)
    num = math.min(own, num)
    num = math.max(0, num)
    self._layout_objs.num:SetText(num)
end

function ChoseGiftUseView:OnEmptyClick()
    self:Close()
end

return ChoseGiftUseView
