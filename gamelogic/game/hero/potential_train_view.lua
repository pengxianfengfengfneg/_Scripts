local PotentialTrainView = Class(game.BaseView)

function PotentialTrainView:_init(ctrl)
    self._package_name = "ui_hero"
    self._com_name = "potential_train_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function PotentialTrainView:OpenViewCallBack(id)
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[3122])
    self._layout_objs["common_bg/btn_back"]:SetVisible(false)
    self.goods_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")
    self.goods_item:SetShowTipsEnable(true)

    self:BindEvent(game.HeroEvent.HeroPotentialSelect, function(data)
        self:SetSelectPotential(data)
    end)

    self._layout_objs.btn_train:AddClickCallBack(function()
        self.ctrl:SendTrainPulse(self.cur_id, self.potential_info.type)
    end)

    self._layout_objs.btn_add:AddClickCallBack(function()
        local pulse_cfg = config.pulse[self.cur_id]
        local role_lv = game.RoleCtrl.instance:GetRoleLevel()
        if role_lv < pulse_cfg.level then
            game.GameMsgCtrl.instance:PushMsg(config.words[1549])
        else
            self.ctrl:OpenPulseHeroView(self.cur_id)
            self:Close()
        end
    end)

    self._layout_objs.btn_left:AddClickCallBack(function()
        if self.cur_id == 1 then
            self:SetPulseInfo(8)
        else
            self:SetPulseInfo(self.cur_id - 1)
        end
    end)

    self._layout_objs.btn_right:AddClickCallBack(function()
        if self.cur_id == 8 then
            self:SetPulseInfo(1)
        else
            self:SetPulseInfo(self.cur_id + 1)
        end
    end)

    self.potentials = {}
    for i = 1, 4 do
        self.potentials[i] = self:GetTemplate("game/hero/item/potential_item", "potential" .. i)
    end

    self:SetPulseInfo(id)
end

function PotentialTrainView:OnEmptyClick()
    self:Close()
end

function PotentialTrainView:SetPulseInfo(id)
    self._layout_objs.btn_left:SetVisible(id > 1)
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    self._layout_objs.btn_right:SetVisible(id < #config.pulse and role_lv >= config.pulse[id + 1].level )
    self.cur_id = id

    local pulse_cfg = config.pulse[id]
    self._layout_objs.pulse:SetText(pulse_cfg.name)
    local info = self.ctrl:GetPulseInfoByID(id)
    self._layout_objs.group_add:SetVisible(info == nil)
    self._layout_objs.group_hero:SetVisible(info ~= nil)
    self._layout_objs.btn_train:SetVisible(info ~= nil)
    if info then
        local hero_cfg = config.hero[info.hero]
        if hero_cfg then
            local hero_info = self.ctrl:GetHeroInfo(info.hero)
            self._layout_objs.level:SetText(string.format(config.words[2209], hero_info.level))
            self._layout_objs.head:SetSprite("ui_headicon", hero_cfg.icon)
            self._layout_objs.hero_bg:SetSprite("ui_common", "yx_t" .. hero_cfg.color)
            self._layout_objs.name:SetText(hero_cfg.name)
            local career = game.RoleCtrl.instance:GetCareer()
            local attr_pulse = config.hero_level[hero_cfg.id][hero_info.level].attr_pulse[career]
            local text
            if attr_pulse[1] < 100 then
                text = config.combat_power_battle[attr_pulse[1]].name .. "+" .. attr_pulse[2]
            else
                text = config.combat_power_base[attr_pulse[1] - 100].name .. "+" .. attr_pulse[2]
            end
            self._layout_objs.attr:SetText(text)
        else
            self._layout_objs.group_add:SetVisible(true)
            self._layout_objs.group_hero:SetVisible(false)
        end

        for _, v in ipairs(info.potentials) do
            self.potentials[v.type]:SetPotentialInfo(v, self.cur_id)
            self.potentials[v.type]:SetBtnTouchEnable(true)
        end
        self:SetSelectPotential(info.potentials[1])
    else
        for _, v in ipairs(pulse_cfg.init) do
            self.potentials[v[1]]:SetPotentialInfo({ type = v[1], id = v[2], val = v[3] }, self.cur_id)
            self.potentials[v[1]]:SetBtnTouchEnable(false)
        end
        self:SetSelectPotential({ type = pulse_cfg.init[1][1], id = pulse_cfg.init[1][2], val = pulse_cfg.init[1][3] })
    end
end

function PotentialTrainView:SetCostItem(cost)
    self.goods_item:SetItemInfo({ id = cost[1] })
    local own = game.BagCtrl.instance:GetNumById(cost[1])
    self.goods_item:SetNumText(own .. "/" .. cost[2])
end

function PotentialTrainView:SetSelectPotential(info)
    self.potential_info = info
    for i, v in ipairs(self.potentials) do
        v:SetSelect(i == info.type)
    end

    local cost
    for _, val in ipairs(config.pulse_train) do
        if val.low <= info.val and info.val <= val.high then
            cost = val.cost
            break
        end
    end
    self:SetCostItem(cost)

    local limit = self.potentials[info.type]:GetLimit()
    self._layout_objs.text:SetText(string.format(config.words[3128], math.floor(limit * 0.01), math.floor(limit * 0.05)))
end

return PotentialTrainView
