local NeidanItem = Class(game.UITemplate)

function NeidanItem:OpenViewCallBack()
    self:GetRoot():AddClickCallBack(function()
        if self.click_func then
            self.click_func()
        end
    end)
end

function NeidanItem:SetItemInfo(info)
    self.info = info

    local dan_cfg = config.pet_internal[info.internal]
    self._layout_objs.bg:SetSprite("ui_common", "ndk_0" .. dan_cfg.quality)
    self._layout_objs.level:SetText(info.lv)
    self._layout_objs.icon:SetVisible(true)
    self._layout_objs.icon:SetSprite("ui_item", config.goods[dan_cfg.material].icon, true)
    self._layout_objs.btn_add:SetVisible(false)
end

function NeidanItem:SetPetInfo(pet_grid)
    local pet_info = game.PetCtrl.instance:GetPetInfoById(pet_grid)
    self._layout_objs.active:SetVisible(false)
    self._layout_objs.icon:SetGray(false)
    if pet_info then
        local pet_cfg = config.pet[pet_info.cid]
        if pet_cfg.quality ~= 2 and pet_cfg.carry_lv < config.internal_hole[self.info.grid] then
            self._layout_objs.active:SetVisible(true)
            self._layout_objs.icon:SetGray(true)
        end
    end
end

function NeidanItem:ResetItem()
    self.info = nil
    self.click_func = nil
    self._layout_objs.bg:SetSprite("ui_common", "ndk_01")
    self._layout_objs.level:SetText("")
    self._layout_objs.btn_add:SetVisible(false)
    self._layout_objs.icon:SetVisible(false)
    if self._layout_objs.active then
        self._layout_objs.active:SetVisible(false)
    end
end

function NeidanItem:SetBtnAddVisible(val)
    self._layout_objs.btn_add:SetVisible(val)
end

function NeidanItem:GetItemInfo()
    return self.info
end

function NeidanItem:AddClickEvent(func)
    self.click_func = func
end

return NeidanItem