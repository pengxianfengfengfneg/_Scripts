local WearEquipInfoView = Class(game.BaseView)

function WearEquipInfoView:_init(ctrl)
    self._package_name = "ui_bag"
    self._com_name = "wear_equip_info_view"
    self._view_level = game.UIViewLevel.Fouth

    self.ctrl = ctrl
end

function WearEquipInfoView:OnEmptyClick()
    self:Close()
end

function WearEquipInfoView:OpenViewCallBack(info)

    local paris = info.paris
    local goods_config = config.goods[info.id]
    local pos = goods_config.pos
    local refine_pert = 0
    local refine_add_str = ""
    if paris > 0 then
        if config.equip_paris[pos] then
            refine_pert = config.equip_paris[pos][paris].pert
        end
    end
	
	local color = game.ItemColor[goods_config.color]

	self._layout_objs.name:SetText(string.format(config.words[1557], color, goods_config.name, info.stren))
    
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

    local career = config.career_init[goods_config.career]
    if career then
        self._layout_objs.career:SetText(career.name)
    else
        self._layout_objs.career:SetText(config.words[1552])
    end

    self._layout_objs["n32"]:SetText(config.words[1555])

    local star = config.equip_attr[info.id].star
    for i = 1, 9 do
        if i <= star then
            self._layout_objs["star"..i]:SetVisible(true)
        else
            self._layout_objs["star"..i]:SetVisible(false)
        end
    end

    local stren_attr = config.equip_stren[info.stren][info.pos].attr
	local base_attr_str = ""
    local count = 0
    for i, j in pairs(goods_config.attr) do

        local attr_name = config_help.ConfigHelpAttr.GetAttrName(j[1])
        local s = string.format(config.words[1226], attr_name, j[2], "")
        local stren_value = stren_attr[i][2]
        s = s.."<font color='#13f4f3'>(+"..stren_value..")</font>"

        if count == 0 then
            base_attr_str = base_attr_str..s
        else
            base_attr_str = base_attr_str.."<br/>"..s
        end
        count = count + 1
    end
    self._layout_objs["base_attr"]:SetText(base_attr_str)


    local random_attr_str = ""
    local count2 = 0
    for _, v in pairs(info.attr) do

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
        if count2 == 0 then
            random_attr_str = random_attr_str..s
        else
            random_attr_str = random_attr_str.."<br/>"..s
        end
        count2 = count2 + 1
    end
    self._layout_objs["random_attr"]:SetText("<font>"..random_attr_str.."</font>")

    --重楼技能/扩展
    if paris > 0 and (pos == 1 or pos == 5)then
        
        self._layout_objs.name:SetText(string.format(config.words[1557], color, config.equip_paris[pos][paris].name, info.stren))

        local next_pert_str = ""
        if config.equip_paris[pos][paris+1] then
            next_pert_str = string.format(config.words[1251], config.equip_paris[pos][paris+1].pert).."%"
        else
            next_pert_str = config.words[2201]
        end
        self._layout_objs["refine_attr"]:SetText(string.format(config.words[1250], config.equip_paris[pos][paris].skill_desc, tostring(refine_pert).."%", next_pert_str))
    --重楼肩
    elseif (pos == 3)then
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

    --评分
    local base_score = game.Utils.CalculateCombatPower2(goods_config.attr)
    local random_score = game.Utils.CalculateCombatPower2(info.attr)
    local total_score = base_score + random_score
    self._layout_objs.score:SetText(total_score)

    for i = 1, 4 do
    	local stone_info = info.stones[i]
    	if stone_info then

    		local stone_item_id = stone_info.id
    		local stone_cfg = config.goods[stone_item_id]
    		color = game.ItemColor2[stone_cfg.color]

    		self._layout_objs["stone_img"..i]:SetSprite("ui_item", tostring(stone_cfg.icon))
            self._layout_objs["stone_img"..i]:SetVisible(true)
    		self._layout_objs["stone_name"..i]:SetText(stone_cfg.name)
    		self._layout_objs["stone_name"..i]:SetColor(color[1], color[2], color[3], color[4])

    		local stone_attr = config.equip_stone2[stone_item_id].attr
    		local attr_name
	        if stone_attr[1] > 100 then
	            attr_name = config.combat_power_base[stone_attr[1] - 100].attr_name
	        else
	            attr_name = config.combat_power_battle[stone_attr[1]].attr_name
	        end
	        self._layout_objs["stone_attr"..i]:SetText(attr_name.."+"..stone_attr[2])
	        self._layout_objs["stone_attr"..i]:SetColor(color[1], color[2], color[3], color[4])

    		self._layout_objs["stone_group"..i]:SetVisible(true)
    	else
    		self._layout_objs["stone_group"..i]:SetVisible(true)
            self._layout_objs["stone_img"..i]:SetVisible(false)
            self._layout_objs["stone_name"..i]:SetText(config.words[1239])
            self._layout_objs["stone_name"..i]:SetColor(255, 255, 255, 255)
            self._layout_objs["stone_attr"..i]:SetText("")

    	end
    end

    self._layout_objs["btn_down"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:CsEquipTakeOff(info.pos)
        self:Close()
    end)

    self._layout_objs["btn_stren"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:OpenView(1)
        self:Close()
    end)

    self._layout_objs["btn_inlay"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:OpenView(2)
        self:Close()
    end)

    if self.wear_btn_hide then
        self._layout_objs["n67"]:SetVisible(false)
    else
        self._layout_objs["n67"]:SetVisible(true)
    end

    if info.pos == 7 and info.marry_bless and info.marry_bless > 0 then
        self._layout_objs.ring_line:SetVisible(true)
        self._layout_objs.ring_attr:SetFontSize(24)
        local str = ""
        local bless_cfg = config.marry_bless[info.marry_bless]
        for i, v in ipairs(bless_cfg.attr) do
            str = str .. config.combat_power_battle[v[1]].name .. "：+" .. v[2]
            if i < #bless_cfg.attr then
                str = str .. "\n"
            end
        end
        color = game.ItemColor[1]
        if info.mate_name and info.mate_name ~= "" then
            local main_role = game.Scene.instance:GetMainRole()
            str = string.format(config.words[2620], color, info.marry_bless, str, main_role:GetName(), info.mate_name)
            self.icon:SetRingImage(bless_cfg.frame)
        else
            color = game.ItemColor[6]
            str = string.format(config.words[2621], color, info.marry_bless, str)
            self.icon:SetRingImage("")
        end
        self._layout_objs.ring_attr:SetText(str)
    else
        self._layout_objs.ring_line:SetVisible(false)
        self._layout_objs.ring_attr:SetFontSize(0)
        self._layout_objs.ring_attr:SetText("")
        self.icon:SetRingImage("")
    end
end

function WearEquipInfoView:SetWearBtnHide(val)
    self.wear_btn_hide = val
end

function WearEquipInfoView:CloseViewCallBack()
    self.wear_btn_hide = false
    self.icon:DeleteMe()
end

return WearEquipInfoView
