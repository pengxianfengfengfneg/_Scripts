local PetHandbookTemplate = Class(game.UITemplate)

local type_image = { "zs_wai", "zs_nei", "zs_ping" }

function PetHandbookTemplate:_init(parent, param)
    self.parent_view = parent
    self.idx = param
end

function PetHandbookTemplate:OpenViewCallBack()

    self._layout_objs.btn_grow:AddClickCallBack(function()
        game.PetCtrl.instance:OpenQualityView(self.cur_pet)
    end)

    self:InitModel()

    self:SetHandbook()
end

function PetHandbookTemplate:CloseViewCallBack()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
    self.list = nil
end

function PetHandbookTemplate:SetHandbook()
    self.list = self:CreateList("list", "game/pet/item/pet_icon_item")
    self.list:AddClickItemCallback(function(obj)
        self:SetSelectPet(obj:GetItemInfo())
    end)
    local pet_list = {}
    for _, v in pairs(config.pet) do
        if v.quality == self.idx then
            table.insert(pet_list, v)
        end
    end
    table.sort(pet_list, function(a, b)
        return a.carry_lv < b.carry_lv
    end)
    for _, v in pairs(pet_list) do
        v.level = v.carry_lv
    end
    self.list:SetRefreshItemFunc(function(item, index)
        local info = pet_list[index]
        item:SetItemInfo(info)
    end)
    self.list:SetItemNum(#pet_list)

    self:SetSelectPet(pet_list[1])
end

function PetHandbookTemplate:SetSelectPet(info)
    self.cur_pet = info
    self:SetName(info)
    self.pet_scale = info.scale
    self.pet_height = info.height
    self:SetModel(info.model_id)

    self:SetGetWay(info.get_way)

    self.list:Foreach(function(obj)
        local pet_info = obj:GetItemInfo()
        obj:SetSelect(info.id == pet_info.id)
    end)
end

function PetHandbookTemplate:SetName(info)
    self._layout_objs.type:SetSprite("ui_common", type_image[info.type])
    self._layout_objs.level:SetText(info.carry_lv .. config.words[1217])
    self._layout_objs.name:SetText(info.name)
end

function PetHandbookTemplate:SetModel(model_id)
    self.model:SetModel(game.ModelType.Body, model_id[1])
    self.model:PlayAnim(game.ObjAnimName.Idle)
end

function PetHandbookTemplate:SetGetWay(get_way)
    if get_way[1] == 0 then
        self._layout_objs.way_text:SetText(get_way[2])
        self._layout_objs.btn_get:SetVisible(false)
    else
        self._layout_objs.way_text:SetText("")
        self._layout_objs.btn_get:SetVisible(true)
        self._layout_objs.btn_get:SetText(get_way[2])
        self._layout_objs.btn_get:AddClickCallBack(function()
            config.goods_get_way[get_way[1]].click_func(self.cur_pet)
        end)
    end
end

function PetHandbookTemplate:InitModel()
    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.pet, game.BodyType.Monster)
    self.model:SetPosition(0, -1, 3)
    self.model:SetModelChangeCallBack(function()
        self.model:SetRotation(0, 140, 0)
        self.model:SetPosition(0, 0 - self.pet_height, 3)
        self.model:SetScale(self.pet_scale)
    end)
end

return PetHandbookTemplate
