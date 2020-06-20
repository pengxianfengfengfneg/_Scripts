local PetAttrTemplate = Class(game.UITemplate)

function PetAttrTemplate:OpenViewCallBack()
    self:InitModel()
end

function PetAttrTemplate:CloseViewCallBack()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function PetAttrTemplate:InitModel()
    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.wrapper, game.BodyType.Monster)
    self.model:SetPosition(0, -1, 3.2)
    self.model:SetModelChangeCallBack(function()
        self.model:SetRotation(0, 140, 0)
    end)
end

function PetAttrTemplate:SetAttr(info)
    if info then
        local level_cfg = config.pet_level[info.level]
        self._layout_objs.bar_hp:SetValue(info.hp)
        self._layout_objs.bar_exp:SetMax(level_cfg.exp)
        self._layout_objs.bar_exp:SetValue(info.exp)
        self._layout_objs.grow:SetText(config.words[1520 + info.growup_lv] .. info.growup_rate)
        local color = cc.GoodsColor[info.growup_lv]
        self._layout_objs.grow:SetColor(color.x, color.y, color.z, color.w)

        table.sort(info.init_attr, function(a, b)
            return a.type < b.type
        end)
        local pet_cfg = config.pet[info.cid]
        local type_name = {"outer_attr", "inner_attr", "balance_attr"}
        for i, v in ipairs(info.init_attr) do
            self._layout_objs["base_text" .. i]:SetText(config.combat_power_base[v.type].name)
            local addition = level_cfg[type_name[pet_cfg.type]][v.type]
            addition = addition and addition[2] or 0
            self._layout_objs["base_attr" .. i]:SetText(v.value + addition)
        end

        local max_hp = 0
        local bt_attr = {}
        for _, v in pairs(info.bt_attr) do
            if v.type == 1 then
                max_hp = v.value
            else
                table.insert(bt_attr, v)
            end
        end
        self._layout_objs.bar_hp:SetMax(max_hp)
        table.sort(bt_attr, function(a, b)
            return a.type < b.type
        end)
        for i = 1, 8 do
            if bt_attr[i] then
                self._layout_objs["bt_text" .. i]:SetText(config.combat_power_battle[bt_attr[i].type].name)
                self._layout_objs["bt_attr" .. i]:SetText(bt_attr[i].value)
            end
        end

        self.model:SetModel(game.ModelType.Body, game.PetCtrl.instance:GetPetModel(info))
        self.model:PlayAnim(game.ObjAnimName.Idle)
    else
        self:Reset()
    end
end

function PetAttrTemplate:Reset()
    self._layout_objs.bar_hp:SetValue(1)
    self._layout_objs.bar_hp:SetMax(1)
    self._layout_objs.bar_exp:SetMax(1)
    self._layout_objs.bar_exp:SetValue(1)
    self._layout_objs.grow:SetText("")

    for i = 1, 8 do
        self._layout_objs["bt_attr" .. i]:SetText("")
    end

    for i = 1, 5 do
        self._layout_objs["base_attr" .. i]:SetText("")
    end
end

return PetAttrTemplate