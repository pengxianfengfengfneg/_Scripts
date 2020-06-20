local GodPetAwakeView = Class(game.BaseView)

local type_image = { "zs_wai", "zs_nei", "zs_ping" }

function GodPetAwakeView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "pet_awake_view"
    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function GodPetAwakeView:OnEmptyClick()
    self:Close()
end

function GodPetAwakeView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1528])

    self:BindEvent(game.PetEvent.PetChange, function(data)
        if self.cur_pet and data.grid == self.cur_pet.grid then
            self:SetItemNum(data)
        end
    end)

    self:InitModel()

    self._layout_objs.btn:SetText(config.words[1528])
    self._layout_objs.btn:AddClickCallBack(function()
        if self.cur_pet then
            self.ctrl:SendAwakeGodPet(self.cur_pet.grid)
        end
    end)

    self.list = self:CreateList("list", "game/pet/item/pet_icon_item")
    self.list:AddClickItemCallback(function(obj)
        self:SetSelectPet(obj:GetItemInfo())
    end)

    self:SetPetList()
end

function GodPetAwakeView:CloseViewCallBack()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
    self.cur_pet = nil
end

function GodPetAwakeView:SetPetList()
    local pet_list = {}
    local pets = game.PetCtrl.instance:GetPetInfo()
    for i, v in pairs(pets) do
        local pet_cfg = config.pet[v.pet.cid]
        if pet_cfg.quality == 2 then
            table.insert(pet_list, v)
        end
    end
    self.list:SetRefreshItemFunc(function(item, index)
        local info = pet_list[index].pet
        item:SetItemInfo(info)
    end)
    self.list:SetItemNum(#pet_list)

    if pet_list[1] then
        self:SetSelectPet(pet_list[1].pet)
    end
end

function GodPetAwakeView:SetSelectPet(info)
    if self.cur_pet and self.cur_pet.grid == info.grid then
        return
    end
    self.cur_pet = info
    self._layout_objs.name:SetText(info.name)
    local pet_cfg = config.pet[info.cid]
    self._layout_objs.type:SetSprite("ui_common", type_image[pet_cfg.type])
    self._layout_objs.level:SetText(pet_cfg.carry_lv .. config.words[1217])
    self.pet_scale = pet_cfg.scale
    self.pet_height = pet_cfg.height
    self:SetModel(game.PetCtrl.instance:GetPetModel(info))

    self.list:Foreach(function(obj)
        local pet_info = obj:GetItemInfo()
        obj:SetSelect(info.grid == pet_info.grid)
    end)

    self:SetItemNum(info)
end

function GodPetAwakeView:SetItemNum(info)
    self._layout_objs.awake_lv:SetText(info.awaken .. config.words[1520])
    if info.awaken >= #config.pet_god_awake[info.cid] then
        self._layout_objs.btn:SetTouchEnable(false)
        self._layout_objs.text:SetText(config.words[1526])
    else
        local awake_cfg = config.pet_god_awake[info.cid][info.awaken + 1]
        local own = game.BagCtrl.instance:GetNumById(awake_cfg.item_id)
        self._layout_objs.text:SetText(string.format("%s(%d/%d)", config.goods[awake_cfg.item_id].name, own, awake_cfg.num))
        self._layout_objs.savvy:SetText(awake_cfg.need_savvy_lv .. config.words[1217])
print(self.cur_pet.savvy_lv)
        self._layout_objs.btn:SetGray(own < awake_cfg.num or self.cur_pet.savvy_lv < awake_cfg.need_savvy_lv)
        self._layout_objs.btn:SetTouchEnable(own >= awake_cfg.num and self.cur_pet.savvy_lv >= awake_cfg.need_savvy_lv)
    end
end

function GodPetAwakeView:SetModel(model_id)
    self.model:SetModel(game.ModelType.Body, model_id)
    self.model:PlayAnim(game.ObjAnimName.Idle)
end

function GodPetAwakeView:InitModel()
    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.pet, game.BodyType.Monster)
    self.model:SetPosition(0, -0.85, 2.5)
    self.model:SetModelChangeCallBack(function()
        self.model:SetRotation(0, 140, 0)
        self.model:SetPosition(0, 0 - self.pet_height, 3)
        self.model:SetScale(self.pet_scale)
    end)
end

return GodPetAwakeView
