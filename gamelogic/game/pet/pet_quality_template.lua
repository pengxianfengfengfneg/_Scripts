local PetQualityTemplate = Class(game.UITemplate)

local type_image = { "zs_wai", "zs_nei", "zs_ping" }
local star_range = config.pet_common.star_range

function PetQualityTemplate:_init(parent, params)
    self.parent_view = parent
    self.cur_pet = params[1]
    self.index = params[2]
end

function PetQualityTemplate:OpenViewCallBack()
    self:InitModel()

    self.skill_item = {}
    for i = 0, 4 do
        self.skill_item[i + 1] = self:GetTemplate("game/skill/item/skill_item_rect", "skill" .. i)
    end

    self:SetName()

    self:SetQuality()
end

function PetQualityTemplate:CloseViewCallBack()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function PetQualityTemplate:SetName()
    self._layout_objs.type:SetSprite("ui_common", type_image[self.cur_pet.type])
    self._layout_objs.level:SetText(self.cur_pet.carry_lv .. config.words[1217])
    self._layout_objs.name:SetText(self.cur_pet.name)
    self._layout_objs.desc:SetText(self.cur_pet.desc)
end

function PetQualityTemplate:SetModel(model_id)
    self.model:SetModel(game.ModelType.Body, model_id)
    self.model:PlayAnim(game.ObjAnimName.Idle)
end

function PetQualityTemplate:InitModel()
    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.pet, game.BodyType.Monster)
    self.model:SetPosition(0, -1, 3)
    self.model:SetRotation(0, 140, 0)
    self.model:SetModelChangeCallBack(function()
        self.model:SetPosition(0, 0 - self.pet_height, 3)
        self.model:SetScale(self.pet_scale)
    end)
end

function PetQualityTemplate:SetQuality()
    local star = star_range[self.index]
    if self.cur_pet.quality == 2 then
        self._layout_objs.star:SetText(star_range[4][2])
    else
        if star[1] == star[2] then
            self._layout_objs.star:SetText(star[1])
        else
            self._layout_objs.star:SetText(star[1] .. "-" .. star[2])
        end
    end

    local r1 = config.pet_star[star[1]] or 0
    local r2 = config.pet_star[star[2]] or 0

    local len = #self.cur_pet.power[2]
    local q1 = math.floor(self.cur_pet.power[2][1][1] * (r1 / 10000 + 1))
    local q2 = math.floor(self.cur_pet.power[2][len][2] * (r2 / 10000 + 1))
    self._layout_objs.quality1:SetText(q1 .. "-" .. q2)

    len = #self.cur_pet.anima[2]
    q1 = math.floor(self.cur_pet.anima[2][1][1] * (r1 / 10000 + 1))
    q2 = math.floor(self.cur_pet.anima[2][len][2] * (r2 / 10000 + 1))
    self._layout_objs.quality2:SetText(q1 .. "-" .. q2)

    len = #self.cur_pet.energy[2]
    q1 = math.floor(self.cur_pet.energy[2][1][1] * (r1 / 10000 + 1))
    q2 = math.floor(self.cur_pet.energy[2][len][2] * (r2 / 10000 + 1))
    self._layout_objs.quality3:SetText(q1 .. "-" .. q2)

    len = #self.cur_pet.concent[2]
    q1 = math.floor(self.cur_pet.concent[2][1][1] * (r1 / 10000 + 1))
    q2 = math.floor(self.cur_pet.concent[2][len][2] * (r2 / 10000 + 1))
    self._layout_objs.quality4:SetText(q1 .. "-" .. q2)

    len = #self.cur_pet.method[2]
    q1 = math.floor(self.cur_pet.method[2][1][1] * (r1 / 10000 + 1))
    q2 = math.floor(self.cur_pet.method[2][len][2] * (r2 / 10000 + 1))
    self._layout_objs.quality5:SetText(q1 .. "-" .. q2)

    q1 = config.pet_growup[self.cur_pet.growup_id][1].growup
    q2 = config.pet_growup[self.cur_pet.growup_id][5].growup
    self._layout_objs.ratio:SetText(q1 .. "-" .. q2)

    for i, v in ipairs(self.cur_pet.show_skills) do
        self.skill_item[i]:SetItemInfo({ id = v })
        self.skill_item[i]:SetShowInfo()
    end

    self.pet_scale = self.cur_pet.scale
    self.pet_height = self.cur_pet.height
    self:SetModel(self.cur_pet.model_id[self.index])

end

return PetQualityTemplate
