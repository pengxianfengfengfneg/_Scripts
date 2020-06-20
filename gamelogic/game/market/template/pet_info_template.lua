local PetInfoTemplate = Class(game.UITemplate)

local type_image = { "zs_wai", "zs_nei", "zs_ping" }
local gen_type = { "zs_01", "zs_02", "zs_03" }

function PetInfoTemplate:_init(view, info)
    self.info = info
    self.ctrl = game.MarketCtrl.instance
end

function PetInfoTemplate:OpenViewCallBack()
    self:InitModel()
    self:Init(self.info)
end

function PetInfoTemplate:CloseViewCallBack()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function PetInfoTemplate:Init(info)
    local pet_cfg = config.pet[info.cid]
    self._layout_objs.txt_name:SetText(info.name)
    self._layout_objs.txt_level:SetText(string.format(config.words[5663], info.level))
    self._layout_objs.txt_carry_lv:SetText(string.format(config.words[5663], pet_cfg.carry_lv))

    self._layout_objs.txt_grow:SetText(config.words[1520 + info.growup_lv] .. info.growup_rate)
    local color = cc.GoodsColor[info.growup_lv]
    self._layout_objs.txt_grow:SetColor(color.x, color.y, color.z, color.w)

    self._layout_objs.list_star:SetItemNum(info.star)

    self._layout_objs.img_type:SetSprite("ui_common", type_image[pet_cfg.type])

    local pet_type = gen_type[1]
    if pet_cfg.quality == 2 then
        pet_type = gen_type[3]
    elseif info.star == 0 then
        pet_type = gen_type[2]
    end
    self._layout_objs.img_gen:SetSprite("ui_common", pet_type)
    self._layout_objs.txt_fight:SetText(game.PetCtrl.instance:CalcFight(info))

    self.skills = {}
    for i = 0, 8 do
        self.skills[i] = self:GetTemplate("game/skill/item/skill_item_rect", "skill" .. i)
    end

    for i = 0, 8 do
        self.skills[i]:ResetItem()
        self.skills[i]:AddClickEvent(nil)
    end
    for _, v in pairs(info.skills) do
        self.skills[v.grid]:SetItemInfo({ id = v.id, lv = v.lv })
        self.skills[v.grid]:SetShowInfo()
    end

    local savvy_cfg = config.pet_savvy[info.savvy_lv]
    for i = savvy_cfg.skill_grid + 1, 8 do
        self.skills[i]:SetLockVisible(true)
    end

    local model_id = game.PetCtrl.instance:GetPetModel(info)
    self.model:SetModel(game.ModelType.Body, model_id)
    self.model:PlayAnim(game.ObjAnimName.Idle)
end

function PetInfoTemplate:InitModel()
    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.wrapper, game.BodyType.Monster)
    self.model:SetPosition(0, -1, 3.2)
    self.model:SetModelChangeCallBack(function()
        self.model:SetRotation(0, 140, 0)
    end)
end

return PetInfoTemplate