local BagEquipInfoView = Class(game.BaseView)

function BagEquipInfoView:_init(ctrl)
    self._package_name = "ui_bag"
    self._com_name = "bag_equip_info_view"
    self._view_level = game.UIViewLevel.Fouth

    self.ctrl = ctrl
end

function BagEquipInfoView:OnEmptyClick()
    self:Close()
end

function BagEquipInfoView:OpenViewCallBack(info)

    self.info = info

    if info.val == true then
        self._layout_objs["n65"]:SetVisible(false)
    else
        self._layout_objs["n65"]:SetVisible(true)
    end

    local goods_config = config.goods[info.id]
    local paris = info.paris
    local pos = goods_config.pos
    local refine_pert = 0
    local refine_add_str = ""
    if paris > 0 then
        if config.equip_paris[pos] then
            refine_pert = config.equip_paris[pos][paris].pert
        end
    end
    

    self._layout_objs.name:SetText(goods_config.name)
    local color = game.ItemColor2[goods_config.color]
    self._layout_objs.name:SetColor(color[1], color[2], color[3], color[4])

    self.icon = require("game/bag/item/goods_item").New()
    self.icon:SetVirtual(self._layout_objs.icon)
    self.icon:Open()
    if refine_pert > 0 then
        self.icon:SetItemInfo({ id = info.id, icon_name= config.equip_paris[pos][paris].icon})
    else
        self.icon:SetItemInfo({ id = info.id})
    end

    self._layout_objs.level:SetText(goods_config.lv)

    self._layout_objs.pos:SetText(config.equip_pos[pos].name)

    -- self._layout_objs.score:SetText(game.Utils.CalculateCombatPower2(goods_config.attr))

    local career = config.career_init[goods_config.career]
    if career then
        self._layout_objs.career:SetText(career.name)
    else
        self._layout_objs.career:SetText(config.words[1552])
    end

    if info.bind == 1 then
        self._layout_objs["n32"]:SetText(config.words[1555])
    else
        self._layout_objs["n32"]:SetText(config.words[1556])
    end

    local star = config.equip_attr[info.id].star

    --熔炼(smelt==0不能熔炼)
    local smelt = config.equip_attr[info.id].smelt

    for i = 1, 9 do
        if i <= star then
            self._layout_objs["star"..i]:SetVisible(true)
        else
            self._layout_objs["star"..i]:SetVisible(false)
        end
    end

    local base_attr_str = ""
    local count = 0
    for i, j in pairs(goods_config.attr) do
        local attr_name = config_help.ConfigHelpAttr.GetAttrName(j[1])
        local s = string.format(config.words[1226], attr_name, j[2])
        if count == 0 then
            base_attr_str = base_attr_str..s
        else
            base_attr_str = base_attr_str.."<br/>"..s
        end
        count = count + 1
    end
    self._layout_objs["base_attr"]:SetText(base_attr_str)


    local random_attr_str = ""

    for k, v in pairs(info.attr) do

        local attr_name
        if v.key > 100 then
            attr_name = config.combat_power_base[v.key - 100].attr_name
        else
            attr_name = config.combat_power_battle[v.key].attr_name
        end

        if refine_pert > 0 then
            refine_add_str = "+"..tostring(math.floor(v.value*refine_pert/100))
        end

        local s = string.format(config.words[1253], attr_name, v.value, refine_add_str)
        random_attr_str = random_attr_str..s.."<br/>"
    end
    self._layout_objs["random_attr"]:SetText("<font>"..random_attr_str.."</font>")

    --重楼技能/扩展
    if paris > 0 and (pos == 1 or pos == 5)then

        self._layout_objs.name:SetText(string.format(config.words[1558], color, config.equip_paris[pos][paris].name))

        local next_pert_str = ""
        if config.equip_paris[pos][paris+1] then
            next_pert_str = string.format(config.words[1251], config.equip_paris[pos][paris+1].pert).."%"
        else
            next_pert_str = config.words[2201]
        end

        self._layout_objs["refine_attr"]:SetText(string.format(config.words[1250], config.equip_paris[pos][paris].skill_desc, tostring(refine_pert).."%", next_pert_str))
    --重楼肩
    elseif paris > 0 and (pos == 3)then

        local cfg = config.paris_shoulder[info.id]
        if cfg then
            local skill_name = config.skill[cfg.skill[1]][cfg.skill[2]].name
            self._layout_objs["refine_attr"]:SetText(skill_name..":"..cfg.skill_desc)
        else
            self._layout_objs["refine_attr"]:SetText("")
        end
    else
        self._layout_objs["refine_attr"]:SetText("")
    end

    local base_score = game.Utils.CalculateCombatPower2(goods_config.attr)
    local random_score = game.Utils.CalculateCombatPower2(info.attr)
    self.total_score = base_score + random_score
    self._layout_objs.score:SetText(self.total_score)

    self._layout_objs["btn_wear"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:CsEquipWear(info.pos)
        self:Close()
    end)

    --熔炼
    self._layout_objs["btn_smelt"]:AddClickCallBack(function()
        if smelt == 0 then
            game.GameMsgCtrl.instance:PushMsg("此装备不能熔炼")
            return
        end
        game.FoundryCtrl.instance:OpenSmeltSelectView(info.pos)
        self:Close()
    end)

    if not game.IsZhuanJia then
        self._layout_objs["btn_sale"]:SetVisible(false)
        self._layout_objs["bg_btn"]:SetSize(158, 136)
    end
    self._layout_objs["btn_sale"]:AddClickCallBack(function()
        self.ctrl:SendBagSellItem(1, {{pos = info.pos}})
        self:Close()
    end)

    if info.not_show_wear then
        self._layout_objs["n65"]:SetVisible(false)
    end

    if self.wear_btn_hide then
        self._layout_objs["n65"]:SetVisible(false)
    end

    self:CompareScoreWithWear()

end

function BagEquipInfoView:CompareScoreWithWear()

    local wear_sccore = 0
    local item_id = self.info.id
    local equip_pos = config.equip_attr[item_id].pos
    local wear_equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(equip_pos)

    if wear_equip_info and wear_equip_info.id > 0 then
        local wear_item_id = wear_equip_info.id
        local wear_item_cfg = config.goods[wear_item_id]

        local base_score = game.Utils.CalculateCombatPower2(wear_item_cfg.attr)
        local random_score = game.Utils.CalculateCombatPower2(wear_equip_info.attr) 
        wear_sccore = base_score + random_score
    end

    if wear_sccore > self.total_score then
        self._layout_objs["score_arrow_down"]:SetVisible(true)
        self._layout_objs["score_arrow_up"]:SetVisible(false)
    elseif wear_sccore < self.total_score then
        self._layout_objs["score_arrow_down"]:SetVisible(false)
        self._layout_objs["score_arrow_up"]:SetVisible(true)
    else
        self._layout_objs["score_arrow_down"]:SetVisible(false)
        self._layout_objs["score_arrow_up"]:SetVisible(false)
    end
end

function BagEquipInfoView:SetWearBtnHide(val)
    self.wear_btn_hide = val
end

function BagEquipInfoView:CloseViewCallBack()
    self.wear_btn_hide = false
end

function BagEquipInfoView:SetRefineDesc()

end

return BagEquipInfoView