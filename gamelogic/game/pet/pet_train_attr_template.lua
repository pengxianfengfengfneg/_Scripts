local PetTrainAttrTemplate = Class(game.UITemplate)

function PetTrainAttrTemplate:OpenViewCallBack()
    self:InitBtn()

    self.cost_item = self:GetTemplate("game/bag/item/goods_item", "cost_item")
    self.cost_item:SetShowTipsEnable(true)

    self:BindEvent(game.BagEvent.BagItemChange, function()
        self:UpdateCostItem()
    end)
    self:BindEvent(game.PetEvent.Wash, function()
        self:AutoWash()
    end)
    self:BindEvent(game.PetEvent.Savvy, function()
        self:AutoSavvy()
    end)
    self.last_growup_lv = nil
end

function PetTrainAttrTemplate:CloseViewCallBack()
    self:StopAuto()
end

function PetTrainAttrTemplate:InitBtn()
    self._layout_objs.btn_wash:AddClickCallBack(function()
        if self.info then
            game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_pet/pet_train_view/train_attr_template/btn_wash"})
            game.PetCtrl.instance:SendWash(self.info.grid)
        end
    end)

    self._layout_objs.btn_auto_wash:AddClickCallBack(function()
        if self.info then
            if self.is_auto_wash then
                self.is_auto_wash = false
                self._layout_objs.btn_auto_wash:SetText(config.words[1544])
            else
                self.is_auto_wash = true
                game.PetCtrl.instance:SendWash(self.info.grid)
                self._layout_objs.btn_auto_wash:SetText(config.words[1545])
            end
        end
    end)

    self._layout_objs.btn_quality:AddClickCallBack(function()
        if self.info then
            game.PetCtrl.instance:SendSavvy(self.info.grid)
        end
    end)

    self._layout_objs.btn_auto_quality:AddClickCallBack(function()
        if self.info then
            if self.is_auto_savvy then
                self.is_auto_savvy = false
                self._layout_objs.btn_auto_quality:SetText(config.words[1546])
            else
                self.is_auto_savvy = true
                game.PetCtrl.instance:SendSavvy(self.info.grid)
                self._layout_objs.btn_auto_quality:SetText(config.words[1547])
            end
        end
    end)
end

local function potential(init_val, star_add, savvy_add)
    return math.floor(init_val * (1 + star_add / 10000) * (1 + savvy_add / 10000)), math.floor(init_val * (1 + star_add / 10000) * savvy_add / 10000)
end

function PetTrainAttrTemplate:SetAttr(info)
    if self.info and self.info.grid ~= info.grid then
        self.last_growup_lv = nil
        self:StopAuto()
    end
    self.info = info
    if self.last_growup_lv and info.growup_lv > self.last_growup_lv then
        self:CreateUIEffect(self._layout_objs.effect,  "effect/ui/ui_cw_cz.ab")
        self._layout_objs.effect:SetPositionY(317 + 45 * info.growup_lv)
    end
    self.last_growup_lv = info.growup_lv
    self._layout_objs.wash:SetVisible(info.star == 0)
    self._layout_objs.quality:SetVisible(info.star > 0)
    self._layout_objs.group_txt1:SetVisible(info.growup_lv < 5)
    self._layout_objs.group_txt2:SetVisible(info.growup_lv == 5)
    self._layout_objs.group_item:SetVisible(info.star > 0 or info.growup_lv < 5)

    local pet_cfg = config.pet[info.cid]
    local growup_cfg = config.pet_growup[pet_cfg.growup_id]
    local star_add = config.pet_star[info.star] or 0
    local savvy_cfg = config.pet_savvy[info.savvy_lv]
    local cur_potential = {}
    local savvy_add = {}
    cur_potential[1], savvy_add[1] = potential(info.potential.power, star_add, savvy_cfg.potential_addon)
    cur_potential[2], savvy_add[2] = potential(info.potential.anima, star_add, savvy_cfg.potential_addon)
    cur_potential[3], savvy_add[3] = potential(info.potential.energy, star_add, savvy_cfg.potential_addon)
    cur_potential[4], savvy_add[4] = potential(info.potential.concent, star_add, savvy_cfg.potential_addon)
    cur_potential[5], savvy_add[5] = potential(info.potential.method, star_add, savvy_cfg.potential_addon)

    local upgrade_cost = growup_cfg[info.growup_lv].upgrade_cost
    if info.star > 0 then
        upgrade_cost = savvy_cfg.upgrade_cost
    end
    self.cur_upgrade_cost = upgrade_cost
    self.cost_item:SetItemInfo({ id = upgrade_cost[1] })
    self:UpdateCostItem()

    local grow_text = config.words[1521]
    for i = 1, 5 do
        if savvy_add[i] > 0 then
            self._layout_objs["quality" .. i]:SetText(string.format("%d[color=#367a21](+%d)[/color]", cur_potential[i], savvy_add[i]))
        else
            self._layout_objs["quality" .. i]:SetText(cur_potential[i])
        end
        self._layout_objs["ratio" .. i]:SetText(growup_cfg[i].growup)
        if info.growup_rate >= growup_cfg[i].growup then
            grow_text = config.words[1520 + i]
        end
    end
    self._layout_objs.grow:SetText(grow_text .. info.growup_rate)
    local color = cc.GoodsColor[info.growup_lv]
    self._layout_objs.grow:SetColor(color.x, color.y, color.z, color.w)
    self._layout_objs.cur_lv:SetText(info.savvy_lv .. config.words[1217])
    local fail_down = config.pet_savvy[info.savvy_lv].fail_down
    if fail_down == info.savvy_lv then
        self._layout_objs.tips:SetText(config.words[1492])
    else
        self._layout_objs.tips:SetText(string.format(config.words[1493], fail_down))
    end

    self.savvy_max_lv_stat = false
    local max_savvy_lv = pet_cfg.max_savvy_lv
    if pet_cfg.quality == 2 and info.awaken > 0 then
        max_savvy_lv = config.pet_god_awake[info.cid][info.awaken].max_savvy_lv
    end
    if info.savvy_lv >= max_savvy_lv then
        self.savvy_max_lv_stat = true
        self._layout_objs.next_lv:SetText(config.words[1219])
        self._layout_objs.ratio_text:SetText("")
        for i = 1, 5 do
            self._layout_objs["next_quality" .. i]:SetText(config.words[1219])
        end
        if pet_cfg.quality == 2 then
            if info.awaken >= #config.pet_god_awake[info.cid] then
                self._layout_objs.tips:SetText(config.words[1491])
            else
                self._layout_objs.next_lv:SetText(info.savvy_lv + 1 .. config.words[1217])
                self._layout_objs.ratio_text:SetText(string.format(config.words[1510], math.floor(savvy_cfg.upgrade_ratio / 100)))
                savvy_cfg = config.pet_savvy[info.savvy_lv + 1]
                local next_potential = {}
                next_potential[1] = potential(info.potential.power, star_add, savvy_cfg.potential_addon)
                next_potential[2] = potential(info.potential.anima, star_add, savvy_cfg.potential_addon)
                next_potential[3] = potential(info.potential.energy, star_add, savvy_cfg.potential_addon)
                next_potential[4] = potential(info.potential.concent, star_add, savvy_cfg.potential_addon)
                next_potential[5] = potential(info.potential.method, star_add, savvy_cfg.potential_addon)
                for i = 1, 5 do
                    self._layout_objs["next_quality" .. i]:SetText(next_potential[i])
                end
                self._layout_objs.tips:SetText(config.words[1490])
            end
        else
            self._layout_objs.tips:SetText(config.words[1491] .. "\n" .. config.words[1490])
        end
    else
        self._layout_objs.next_lv:SetText(info.savvy_lv + 1 .. config.words[1217])
        self._layout_objs.ratio_text:SetText(string.format(config.words[1510], math.floor(savvy_cfg.upgrade_ratio / 100)))
        savvy_cfg = config.pet_savvy[info.savvy_lv + 1]
        local next_potential = {}
        next_potential[1] = potential(info.potential.power, star_add, savvy_cfg.potential_addon)
        next_potential[2] = potential(info.potential.anima, star_add, savvy_cfg.potential_addon)
        next_potential[3] = potential(info.potential.energy, star_add, savvy_cfg.potential_addon)
        next_potential[4] = potential(info.potential.concent, star_add, savvy_cfg.potential_addon)
        next_potential[5] = potential(info.potential.method, star_add, savvy_cfg.potential_addon)
        for i = 1, 5 do
            self._layout_objs["next_quality" .. i]:SetText(next_potential[i])
        end
    end
end

function PetTrainAttrTemplate:UpdateCostItem()
    if self.cur_upgrade_cost then
        local own = game.BagCtrl.instance:GetNumById(self.cur_upgrade_cost[1])
        self.cost_item:SetNumText(own .. "/" .. self.cur_upgrade_cost[2])
        self.can_upgrade = own >= self.cur_upgrade_cost[2]
    end
end

function PetTrainAttrTemplate:AutoWash()
    if self.is_auto_wash and self:GetRoot():GetActive() then
        if self.can_upgrade and self.info.growup_lv < 5 and self.info.stat == 0 then
            game.PetCtrl.instance:SendWash(self.info.grid)
        else
            self.is_auto_wash = false
            self._layout_objs.btn_auto_wash:SetText(config.words[1544])
        end
    else
        self.is_auto_wash = false
        self._layout_objs.btn_auto_wash:SetText(config.words[1544])
    end
end

function PetTrainAttrTemplate:AutoSavvy()
    if self.is_auto_savvy and self:GetRoot():GetActive() then
        if self.can_upgrade and self.savvy_max_lv_stat ~= true and self.info.stat == 0 then
            game.PetCtrl.instance:SendSavvy(self.info.grid)
        else
            self.is_auto_savvy = false
            self._layout_objs.btn_auto_quality:SetText(config.words[1546])
        end
    else
        self.is_auto_savvy = false
        self._layout_objs.btn_auto_quality:SetText(config.words[1546])
    end
end

function PetTrainAttrTemplate:StopAuto()
    self.is_auto_wash = false
    self._layout_objs.btn_auto_wash:SetText(config.words[1544])
    self.is_auto_savvy = false
    self._layout_objs.btn_auto_quality:SetText(config.words[1546])
end

return PetTrainAttrTemplate