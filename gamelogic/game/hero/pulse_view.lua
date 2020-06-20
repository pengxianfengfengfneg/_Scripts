local PulseView = Class(game.BaseView)

local cfg_pulse = config.pulse

function PulseView:_init(ctrl)
    self._package_name = "ui_hero"
    self._com_name = "pulse_view"
    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
    self._show_money = true

    self.ctrl = ctrl
end

function PulseView:OpenViewCallBack(id)
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[3138])

    self:BindEvent(game.HeroEvent.HeroPulseActive, function()
        self:SelectPulse(self.cur_id)
    end)

    self:BindEvent(game.HeroEvent.HeroPulseTrain, function(data)
        if self.cur_id == data.id then
            self:SelectPulse(data.id)
        end
    end)

    self:BindEvent(game.HeroEvent.HeroChangePotential, function(data)
        if self.cur_id == data.id then
            self:SelectPulse(data.id)
        end
    end)

    self:BindEvent(game.HeroEvent.HeroPulseWearEquip, function(data)
        if self.cur_id == data.id then
            self:SelectPulse(data.id)
        end
    end)

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

    self:SelectPulse(id)
end

function PulseView:CloseViewCallBack()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function PulseView:InitBtns()
    self._layout_objs.btn_add:AddClickCallBack(function()
        local pulse_cfg = cfg_pulse[self.cur_id]
        local role_lv = game.RoleCtrl.instance:GetRoleLevel()
        if role_lv < pulse_cfg.level then
            game.GameMsgCtrl.instance:PushMsg(config.words[1549])
        else
            game.HeroCtrl.instance:OpenPulseHeroView(self.cur_id)
        end
    end)
    self._layout_objs.btn_change:AddClickCallBack(function()
        game.HeroCtrl.instance:OpenPulseHeroView(self.cur_id)
    end)
    self._layout_objs.btn_train:AddClickCallBack(function()
        game.HeroCtrl.instance:OpenPotentialTrainView(self.cur_id)
    end)
    self._layout_objs.btn_left:AddClickCallBack(function()
        self:SelectPulse(self.cur_id - 1)
    end)
    self._layout_objs.btn_right:AddClickCallBack(function()
        self:SelectPulse(self.cur_id + 1)
    end)
end

function PulseView:SelectPulse(id)
    self._layout_objs.btn_left:SetVisible(id > 1)
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    self._layout_objs.btn_right:SetVisible(id < #cfg_pulse and role_lv >= cfg_pulse[id + 1].level)
    self.cur_id = id

    local pulse_cfg = cfg_pulse[id]
    local info = game.HeroCtrl.instance:GetPulseInfoByID(id)
    self._layout_objs.group_add:SetVisible(info == nil)
    self._layout_objs.group_hero:SetVisible(info ~= nil)
    self._layout_objs.btn_train:SetVisible(info ~= nil and info.hero ~= 0)
    self._layout_objs.hero:SetVisible(false)
    if info then
        local hero_cfg = config.hero[info.hero]
        if hero_cfg then
            local hero_info = game.HeroCtrl.instance:GetHeroInfo(info.hero)
            self._layout_objs.name_bg:SetSprite("ui_common", "yx_bg" .. hero_cfg.color)
            self.hero_scale = hero_cfg.zoom
            --self.model:SetModel(game.ModelType.Body, hero_cfg.hero_bg)
            --self.model:PlayAnim(game.ObjAnimName.Show1)
            local bundle_name = "npc_" .. hero_cfg.hero_bg
            local bundle_path = self:GetPackageBundle("npc/" .. bundle_name)
            local asset_name = hero_cfg.hero_bg
            self._layout_objs.hero:SetVisible(true)
            self:SetSpriteAsync(self._layout_objs.hero, bundle_path, bundle_name, asset_name, true)
            self._layout_objs.hero_name:SetText(hero_cfg.name)
            local career = game.RoleCtrl.instance:GetCareer()
            local attr_pulse = config.hero_level[hero_cfg.id][hero_info.level].attr_pulse[career]
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
            self._layout_objs.group_add:SetVisible(true)
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
            self.pulse_equips[i]:ResetFunc()
            self.pulse_equips[i]:SetBtnAddVisible(info.hero ~= 0)
            self.pulse_equips[i]:SetAddCallBack(function()
                game.HeroCtrl.instance:OpenPulseEquipView(self.cur_id, config.pulse_potential_pos[i].pos)
            end)
            self._layout_objs["equip_add" .. i]:SetText("")
        end
        local pos_table = {}
        for k, v in pairs(config.pulse_potential_pos) do
            pos_table[v.pos] = k
        end
        for _, v in ipairs(info.equips) do
            self.pulse_equips[pos_table[v.pos]]:SetItemInfo({ id = v.id })
            self.pulse_equips[pos_table[v.pos]]:AddClickEvent(function()
                game.HeroCtrl.instance:OpenEquipInfoView(self.cur_id, v.pos, v.id, false, true)
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

function PulseView:InitModel()
    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.hero1, game.BodyType.ModelSp)
    self.model:SetPosition(0, -9.46, 20)
    self.model:SetRotateEnable(false)
    self.model:SetModelChangeCallBack(function()
        self.model:SetScale(self.hero_scale)
    end)
end

return PulseView