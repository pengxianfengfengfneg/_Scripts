local GodPetCallView = Class(game.BaseView)

local type_image = { "zs_wai", "zs_nei", "zs_ping" }

function GodPetCallView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "pet_awake_view"
    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function GodPetCallView:OnEmptyClick()
    self:Close()
end

function GodPetCallView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1527])

    self:BindEvent(game.BagEvent.BagItemChange, function()
        self:SetItemNum(self.cur_pet)
    end)

    self:InitModel()

    self._layout_objs.btn:SetText(config.words[1527])
    self._layout_objs.btn:AddClickCallBack(function()
        if self.cur_pet then
            self.ctrl:SendCallGodPet(self.cur_pet.id)
        end
    end)

    self._layout_objs.awake_text:SetText("")
    self._layout_objs.awake_lv:SetText("")

    self.list = self:CreateList("list", "game/pet/item/pet_icon_item")
    self.list:AddClickItemCallback(function(obj)
        self:SetSelectPet(obj:GetItemInfo())
    end)

    self:SetPetList()
end

function GodPetCallView:CloseViewCallBack()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
    self.cur_pet = nil
end

function GodPetCallView:SetPetList()
    local pet_list = {}
    for i, v in pairs(config.pet_god) do
        table.insert(pet_list, v)
    end
    self.list:SetRefreshItemFunc(function(item, index)
        local info = pet_list[index]
        item:SetItemInfo(info)
    end)
    self.list:SetItemNum(#pet_list)

    self:SetSelectPet(pet_list[1])
end

function GodPetCallView:SetSelectPet(info)
    if self.cur_pet and self.cur_pet.id == info.id then
        return
    end
    self.cur_pet = info
    local pet_cfg = config.pet[info.id]
    self:SetName(pet_cfg)
    self.pet_scale = pet_cfg.scale
    self.pet_height = pet_cfg.height
    self:SetModel(pet_cfg.model_id)

    self.list:Foreach(function(obj)
        local pet_info = obj:GetItemInfo()
        obj:SetSelect(info.id == pet_info.id)
    end)

    self:SetItemNum(info)
end

function GodPetCallView:SetItemNum(info)
    local own = game.BagCtrl.instance:GetNumById(info.item_id)
    self._layout_objs.text:SetText(string.format("%s(%d/%d)", config.goods[info.item_id].name, own, info.num))

    self._layout_objs.btn:SetGray(own < info.num)
    self._layout_objs.btn:SetTouchEnable(own >= info.num)
end

function GodPetCallView:SetName(info)
    self._layout_objs.type:SetSprite("ui_common", type_image[info.type])
    self._layout_objs.level:SetText(info.carry_lv .. config.words[1217])
    self._layout_objs.name:SetText(info.name)
end

function GodPetCallView:SetModel(model_id)
    self.model:SetModel(game.ModelType.Body, model_id[1])
    self.model:PlayAnim(game.ObjAnimName.Idle)
end

function GodPetCallView:InitModel()
    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.pet, game.BodyType.Monster)
    self.model:SetPosition(0, -0.85, 2.5)
    self.model:SetModelChangeCallBack(function()
        self.model:SetRotation(0, 140, 0)
        self.model:SetPosition(0, 0 - self.pet_height, 3)
        self.model:SetScale(self.pet_scale)
    end)
end

return GodPetCallView
