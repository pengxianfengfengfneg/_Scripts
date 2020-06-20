local HonorItem = Class(game.UITemplate)

function HonorItem:OpenViewCallBack()
end

function HonorItem:SetItemInfo(info)
    self._layout_objs.image:SetSprite("ui_title", info.icon, true)
end

return HonorItem