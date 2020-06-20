local QuickUseView = Class(game.BaseView)

function QuickUseView:_init()
    self._package_name = "ui_main"
    self._com_name = "quick_use_view"
    self.add_to_view_mgr = false
    self.not_add_mgr = true
    self._ui_order = game.UIZOrder.UIZOrder_Main_UI+1
    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone
end

function QuickUseView:OpenViewCallBack()
    self._layout_objs.btn_close:AddClickCallBack(function()
        game.BagCtrl.instance:RemoveQuickUseList(self.cur_item)
        self:UpdateUseItem()
    end)

    self.goods_item = self:GetTemplate("game/bag/item/goods_item", "item")
    self.goods_item:SetShowTipsEnable(true)

    self:BindEvent(game.BagEvent.BagItemChange, function()
        self:UpdateUseItem()
    end)

    self:UpdateUseItem()
end

function QuickUseView:UpdateUseItem()
    local use_list = game.BagCtrl.instance:GetQuickUseList()
    if #use_list == 0 then
        self:Close()
        return
    end
    local item_info = use_list[1]
    self.cur_item = item_info
    self.goods_item:SetItemInfo(item_info)
    local cfg = config.goods[item_info.id]
    if cfg.pos >= 1 and cfg.pos <= 8 then
        local power = game.FoundryCtrl.instance:CalEquipOffsetScore(item_info)
        self._layout_objs.name:SetText(string.format(config.words[1573], power))
        self._layout_objs.btn:SetText(config.words[5643])
        self._layout_objs.touch:AddClickCallBack(function()
            game.BagCtrl.instance:RemoveQuickUseList(item_info)
            game.FoundryCtrl.instance:CsEquipWear(item_info.pos)
            self:UpdateUseItem()
        end)
    else
        self._layout_objs.name:SetText(cfg.name)
        self._layout_objs.btn:SetText(config.words[1572])
        self._layout_objs.touch:AddClickCallBack(function()
            game.BagCtrl.instance:RemoveQuickUseList(item_info)
            game.GoodsUseUtils.Use(item_info)
            self:UpdateUseItem()
        end)
    end
end

return QuickUseView