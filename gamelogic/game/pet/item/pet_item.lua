local PetItem = Class(game.UITemplate)

function PetItem:OpenViewCallBack()
    self.pet_icon = self:GetTemplate("game/pet/item/pet_icon_item", "item")
end

function PetItem:SetItemInfo(info)
    self.info = info

    self._layout_objs.name:SetText(info.name)
    self._layout_objs.quality:SetText(config.words[1506] .. info.savvy_lv)
    self._layout_objs.star:SetText(config.words[1507] .. info.star)

    self.pet_icon:SetItemInfo(info)
end

function PetItem:SetSelect(val)
    self._layout_objs.select:SetVisible(val)
end

function PetItem:GetItemInfo()
    return self.info
end

function PetItem:AddClickEvent(func)
    self.click_func = func
    self:GetRoot():AddClickCallBack(function()
        if self.click_func then
            self.click_func(self)
        end
    end)
end

function PetItem:UnBindIconEvents()
    self.pet_icon:UnBindAllEvents()
end

function PetItem:SetText1(str)
    self._layout_objs.quality:SetText(str)
end

function PetItem:SetText2(str)
    self._layout_objs.star:SetText(str)
end

return PetItem