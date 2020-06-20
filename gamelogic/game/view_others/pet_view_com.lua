local PetView = Class(game.UITemplate)

function PetView:OpenViewCallBack()
    self:InitBtns()
    self:InitModel()

    self.pet_power = self._layout_objs["role_fight_com/txt_fight"]
    self._layout_objs["role_fight_com/btn_look"]:SetVisible(false)
end

function PetView:CloseViewCallBack()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function PetView:InitBtns()
    self._layout_objs.btn_tip:AddClickCallBack(function()
        if self.cur_select_pet then
            game.PetCtrl.instance:OpenSkillSuitView(self.cur_select_pet)
        end
    end)
end

function PetView:SetPetInfo(info)
    self.cur_select_pet = info
    if info then
        local pet_cfg = config.pet[info.cid]

        self._layout_objs.carry_level:SetText(pet_cfg.carry_lv .. config.words[1217])
        self._layout_objs.grow:SetText(config.words[1520 + info.growup_lv] .. info.growup_rate)
        local color = cc.GoodsColor[info.growup_lv]
        self._layout_objs.grow:SetColor(color.x, color.y, color.z, color.w)
        self.pet_scale = pet_cfg.scale
        self.pet_height = pet_cfg.height
        self.model:SetModel(game.ModelType.Body, game.PetCtrl.instance:GetPetModel(info))
        self.model:PlayAnim(game.ObjAnimName.Idle)
        self._layout_objs.awake_text:SetVisible(pet_cfg.quality == 2)
        self._layout_objs.awake_lv:SetVisible(pet_cfg.quality == 2)
        self._layout_objs.awake_lv:SetText(info.awaken .. "/3")

        local skill_suit = {}
        for _, v in pairs(info.skills) do
            for j = 1, v.lv do
                if skill_suit[j] then
                    skill_suit[j] = skill_suit[j] + 1
                else
                    skill_suit[j] = 1
                end
            end
        end
        local suit_lv = 0
        for _, v in ipairs(config.pet_skill_suit_cond) do
            if skill_suit[v.level] and skill_suit[v.level] >= v.num then
                suit_lv = v.suit_lv
            end
        end
        self._layout_objs.num_text:SetText(suit_lv)
        self.pet_power:SetText(self:CalcFight(info))
    else
        self:Reset()
    end
end

function PetView:InitModel()
    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.wrapper, game.BodyType.Monster)
    self.model:SetPosition(0, -1, 3)
    self.model:SetModelChangeCallBack(function()
        self.model:SetRotation(0, 140, 0)
        self.model:SetPosition(0, 0 - self.pet_height, 3)
        self.model:SetScale(self.pet_scale)
    end)
end

function PetView:Reset()
    self._layout_objs.grow:SetText("")
    self.pet_power:SetText(0)
    self._layout_objs.carry_level:SetText("")
    self._layout_objs.awake_text:SetVisible(false)
    self._layout_objs.awake_lv:SetVisible(false)
    self._layout_objs.num_text:SetText(0)
end

function PetView:CalcFight(pet_info)
    local fight = 0
    for _, v in pairs(pet_info.bt_attr) do
        fight = fight + v.value * config.combat_power_battle[v.type].pet
    end

    for _, v in pairs(pet_info.skills) do
        fight = fight + config.skill[v.id][v.lv].power
    end

    return math.floor(fight)
end

return PetView
