local ActionItem = Class(game.UITemplate)

function ActionItem:OpenViewCallBack()
    
end

function ActionItem:SetItemInfo(act_cfg)
    self.item_info = act_cfg
    self._layout_objs.txt_name:SetText(act_cfg.name)
    local goods_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")
    goods_item:SetItemInfo({id = act_cfg.item})

    local state = game.ExteriorCtrl.instance:GetActionState(act_cfg.id)
    goods_item:SetGray(not state)
    if state then
        self._layout_objs.txt_expire:SetText(config.words[2011])
    else
        self._layout_objs.txt_expire:SetText(config.words[2009])
    end
end

function ActionItem:GetItemInfo()
    return self.item_info
end

return ActionItem
