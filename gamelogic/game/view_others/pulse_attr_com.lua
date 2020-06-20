local PulseAttrCom = Class(game.UITemplate)

local cfg_pulse = config.pulse

function PulseAttrCom:_init(parent, info)
    self.parent_view = parent
    self.pulse_info = info.channels
    self.info = info.info
end

function PulseAttrCom:OpenViewCallBack()
    self.hero_equips = {}
    self.pulse_equips = {}
    for i = 1, 4 do
        self._layout_objs["potential" .. i]:SetText(config.words[3110 + i])
        self.hero_equips[i] = self:GetTemplate("game/bag/item/goods_item", "hero_equip" .. i)
        self.hero_equips[i]:SetShowTipsEnable(true)
        self.pulse_equips[i] = self:GetTemplate("game/bag/item/goods_item", "pulse_equip" .. i)
        self.pulse_equips[i]:ResetItem()
    end

    self:InitBtns()
    self:InitModel()
    self:SelectPulse(1)
end

function PulseAttrCom:InitBtns()
    self._layout_objs.btn_left:AddClickCallBack(function()
        self:SelectPulse(self.cur_id - 1)
    end)
    self._layout_objs.btn_right:AddClickCallBack(function()
        self:SelectPulse(self.cur_id + 1)
    end)
end

function PulseAttrCom:SelectPulse(id)
    self._layout_objs.btn_left:SetVisible(id > 1)
    local role_lv = self.info.level
    self._layout_objs.btn_right:SetVisible(id < #cfg_pulse and role_lv >= cfg_pulse[id + 1].level)
    self.cur_id = id

    local pulse_cfg = cfg_pulse[id]
    local info = self:GetPulseInfoByID(id)
    self._layout_objs.group_hero:SetVisible(info ~= nil)
    if info then
        local hero_cfg = config.hero[info.hero]
        if hero_cfg then
            self._layout_objs.name_bg:SetSprite("ui_common", "yx_bg" .. hero_cfg.color)
            self.hero_scale = hero_cfg.zoom
            self.model:SetModel(game.ModelType.Body, hero_cfg.hero_bg)
            self.model:PlayAnim(game.ObjAnimName.Show1)
            self._layout_objs.hero_name:SetText(hero_cfg.name)
            local career = self.info.career
            local attr_pulse = config.hero_level[hero_cfg.id][info.level].attr_pulse[career]
            local text
            if attr_pulse[1] < 100 then
                text = config.combat_power_battle[attr_pulse[1]].name .. "+" .. attr_pulse[2]
            else
                text = config.combat_power_base[attr_pulse[1] - 100].name .. "+" .. attr_pulse[2]
            end
            self._layout_objs.hero_attr:SetText(text)
            for i, v in ipairs(hero_cfg.equip) do
                self.hero_equips[i]:SetItemInfo({ id = v })
                self.hero_equips[i]:ShowMask(true)
            end
        else
            self._layout_objs.group_hero:SetVisible(false)
        end

        local pulse_potential_info = {}
        for _, v in ipairs(info.potentials) do
            local potential_cfg = config.pulse_potential[v.id]
            self._layout_objs["attr" .. v.type]:SetText(potential_cfg.name .. "+" .. math.floor(v.val * potential_cfg.limit / 10000))
            pulse_potential_info[v.type] = v.id
        end
        for i = 1, 4 do
            self.pulse_equips[i]:ResetItem()
            self._layout_objs["equip_add" .. i]:SetText("")
        end
        local pos_table = {}
        for k, v in pairs(config.pulse_potential_pos) do
            pos_table[v.pos] = k
        end
        for _, v in ipairs(info.equips) do
            self.pulse_equips[pos_table[v.pos]]:SetItemInfo({ id = v.id })
            self.pulse_equips[pos_table[v.pos]]:AddClickEvent(function()
                game.HeroCtrl.instance:OpenEquipInfoView(self.cur_id, v.pos, v.id, false, false)
            end)
            local equip_cfg = config.pulse_equip[v.id]
            local add_attr = equip_cfg.base_attr
            local flag = false
            for _, val in pairs(equip_cfg.heros) do
                if val == info.hero then
                    add_attr = equip_cfg.pro_attr
                    self.hero_equips[pos_table[v.pos]]:ShowMask(false)
                    flag = true
                end
            end
            local add_value = 0
            for _, val in pairs(add_attr) do
                if val[1] == pulse_potential_info[pos_table[v.pos]] then
                    add_value = val[2]
                end
            end
            if flag then
                self._layout_objs["equip_add" .. pos_table[v.pos]]:SetText("+" .. add_value .. config.words[3130])
            else
                self._layout_objs["equip_add" .. pos_table[v.pos]]:SetText("+" .. add_value .. config.words[3130 + config.goods[v.id].color])
            end
        end
    else
        for i, v in ipairs(pulse_cfg.init) do
            self._layout_objs["attr" .. i]:SetText(config.pulse_potential[v[2]].name .. "+" .. v[3])
            self._layout_objs["equip_add" .. i]:SetText("")
            self.pulse_equips[i]:ResetItem()
        end
    end
end

function PulseAttrCom:GetPulseInfoByID(id)
    for _, v in pairs(self.pulse_info or {}) do
        if v.channel.id == id then
            return v.channel
        end
    end
end

function PulseAttrCom:InitModel()
    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.hero, game.BodyType.ModelSp)
    self.model:SetPosition(0, -10, 20)
    self.model:SetRotateEnable(false)
    self.model:SetModelChangeCallBack(function()
        self.model:SetScale(self.hero_scale)
    end)
end

return PulseAttrCom
