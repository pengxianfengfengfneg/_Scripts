local PetStorageView = Class(game.BaseView)

function PetStorageView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "pet_storage_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function PetStorageView:OnEmptyClick()
    self:Close()
end

function PetStorageView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1505])

    self:BindEvent(game.PetEvent.StorageChange, function()
        self:SetStorageList()
    end)
    self:BindEvent(game.PetEvent.StoragePetDelete, function()
        self:SetStorageList()
    end)
    self:BindEvent(game.PetEvent.PetAdd, function()
        self:SetBagList()
    end)
    self:BindEvent(game.PetEvent.BagPetDelete, function()
        self:SetBagList()
    end)

    --ÕäÊÞ²Ö¿âµã»÷´æ·Å
    self._layout_objs.btn_in:AddClickCallBack(function()
        if self.bag_pet then
            self.ctrl:SendInStorage(self.bag_pet.grid)
        end
    end)

    --ÕäÊÞ²Ö¿âµã»÷È¡³ö
    self._layout_objs.btn_out:AddClickCallBack(function()
        if self.storage_pet then
            self.ctrl:SendOutStorage(self.storage_pet.grid)
        end
    end)

    self.storage_list = self:CreateList("storage_list", "game/pet/item/pet_item")
    self.storage_list:AddClickItemCallback(function(obj)
        self:SetStoragePet(obj:GetItemInfo())
    end)

    self.bag_list = self:CreateList("bag_list", "game/pet/item/pet_item")
    self.bag_list:AddClickItemCallback(function(obj)
        self:SetBagPet(obj:GetItemInfo())
    end)

    self:SetStorageList()
    self:SetBagList()
end

function PetStorageView:SetStorageList()
    local pet_list = self.ctrl:GetPetStorage()
    self._layout_objs.storage_num:SetText(string.format(config.words[1508], #pet_list.dpet_list, pet_list.depot_size + config.pet_common.init_depot_size))
    pet_list = pet_list.dpet_list
    self.storage_list:SetRefreshItemFunc(function(item, index)
        local pet = pet_list[index].dpet
        item:SetItemInfo(pet)
        item:UnBindIconEvents()
    end)
    self.storage_list:SetItemNum(#pet_list)
    self:SetStoragePet()
end

function PetStorageView:SetBagList()
    local pet_list = self.ctrl:GetPetInfo()
    self._layout_objs.bag_num:SetText(string.format(config.words[1509], #pet_list, config.pet_common.carry_pet_num))
    self.bag_list:SetRefreshItemFunc(function(item, index)
        local pet = pet_list[index].pet
        item:SetItemInfo(pet)
    end)
    self.bag_list:SetItemNum(#pet_list)
    self:SetBagPet()
end

function PetStorageView:SetStoragePet(info)
    self.storage_pet = info
    self.storage_list:Foreach(function(obj)
        local item_info = obj:GetItemInfo()
        obj:SetSelect(info and item_info.grid == info.grid or false)
    end)
end

function PetStorageView:SetBagPet(info)
    self.bag_pet = info
    self.bag_list:Foreach(function(obj)
        local item_info = obj:GetItemInfo()
        obj:SetSelect(info and item_info.grid == info.grid or false)
    end)
end

return PetStorageView
