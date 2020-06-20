local AttrItem = Class(game.UITemplate)

function AttrItem:OpenViewCallBack()
    self:GetRoot():AddClickCallBack(function()
        self:FireEvent(game.HeroEvent.HeroAttrSelect, self.info)
    end)
end

function AttrItem:SetItemInfo(cfg)
    self.info = cfg
    self._layout_objs.name:SetText(cfg.name)
end

function AttrItem:SetSelect(info)
    self._layout_objs.select:SetVisible(self.info.id == info.id)
end

return AttrItem