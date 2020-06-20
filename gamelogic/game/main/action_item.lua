local ActionItem = Class(game.UITemplate)

function ActionItem:OpenViewCallBack()
end

function ActionItem:SetItemInfo(act_cfg)
    self._layout_objs.image:SetSprite("ui_main", act_cfg.icon)
    local state = game.ExteriorCtrl.instance:GetActionState(act_cfg.id)
    self._layout_objs.image:SetGray(not state)
    self.item_info = act_cfg
    self._layout_objs.name:SetText(act_cfg.name)
end

function ActionItem:SetSelect(val)
    self._layout_objs.select:SetVisible(val)
end

function ActionItem:GetItemInfo()
    return self.item_info
end

return ActionItem
