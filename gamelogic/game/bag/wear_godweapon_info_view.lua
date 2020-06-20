local WearGodweaponInfoView = Class(game.BaseView)

function WearGodweaponInfoView:_init(ctrl)
    self._package_name = "ui_bag"
    self._com_name = "wear_godweapon_info_view"
    self._view_level = game.UIViewLevel.Fouth

    self.ctrl = ctrl
end

function WearGodweaponInfoView:OnEmptyClick()
    self:Close()
end

function WearGodweaponInfoView:OpenViewCallBack(info)

    local pos = info.pos
    local gw_id = info.id
    local career = math.floor(gw_id/100)
    local gw_cfg = config.artifact_base[career][gw_id]
    local item_id = gw_cfg.item_id
	local goods_config = config.goods[item_id]
	local color = game.ItemColor[goods_config.color]

	self._layout_objs.name:SetText(string.format(config.words[1557], color, goods_config.name, info.stren))
    
    self.icon = require("game/bag/item/goods_item").New()
    self.icon:SetVirtual(self._layout_objs.icon)
    self.icon:Open()
    self.icon:SetItemInfo({ id = item_id})

    self._layout_objs.level:SetText(goods_config.lv)

    self._layout_objs.pos:SetText(config.equip_pos[9].name)

    local career = config.career_init[goods_config.career]
    if career then
        self._layout_objs.career:SetText(career.name)
    else
        self._layout_objs.career:SetText(config.words[1552])
    end

    self._layout_objs["n32"]:SetText(config.words[1555])

    for i = 1, 9 do
        self._layout_objs["star"..i]:SetVisible(true)
    end

    --基础属性
    local all_attr_list = {}

    for k, v in pairs(gw_cfg.attr) do
        all_attr_list[v[1]] = v[2]
    end

    for k, v in pairs(info.extra_attr) do
        if not all_attr_list[v.id] then
            all_attr_list[v.id] = v.value
        else
            all_attr_list[v.id] = all_attr_list[v.id] + v.value
        end
    end
    --1内功和外功
    local base_attr_list = {}
    for attr_type, attr_value in pairs(all_attr_list) do
        if attr_type == 5 or attr_type == 6 then
            local t = {}
            t[1] = attr_type
            t[2] = attr_value
            table.insert(base_attr_list, 1, t)
        end
    end

    --2非内功和外功
    local extra_attr_list = {}
    for attr_type, attr_value in pairs(all_attr_list) do
        if attr_type ~= 5 and attr_type ~= 6 then
            local t = {}
            t[1] = attr_type
            t[2] = attr_value
            table.insert(extra_attr_list, 1, t)
        end
    end

    local stren_attr = config.equip_stren[info.stren][9].attr
	local base_attr_str = ""
    local count = 0
    for i, j in pairs(base_attr_list) do

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
    for k, v in pairs(extra_attr_list) do

        local attr_name
        if v[1] > 100 then
            attr_name = config.combat_power_base[v[1] - 100].attr_name
        else
            attr_name = config.combat_power_battle[v[1]].attr_name
        end

        local s = string.format(config.words[1253], attr_name, v[2], "")
        if count2 == 0 then
            random_attr_str = random_attr_str..s
        else
            random_attr_str = random_attr_str.."<br/>"..s
        end
        count2 = count2 + 1
    end
    self._layout_objs["random_attr"]:SetText("<font>"..random_attr_str.."</font>")

    --神器技能
    local skill_id = gw_cfg.skill
    local skill_desc = config.skill[skill_id].desc
    self._layout_objs["refine_attr"]:SetText(skill_desc)

    --评分
    local base_score = game.Utils.CalculateCombatPower2(base_attr_list)
    local extra_score = game.Utils.CalculateCombatPower2(extra_attr_list)
    local total_score = base_score + extra_score
    self._layout_objs.score:SetText(total_score)

    for i = 1, 4 do
    	local stone_info = info.stones[i]
    	if stone_info then

    		local stone_item_id = stone_info.id
    		local stone_pos = stone_info.pos
    		local stone_cfg = config.goods[stone_item_id]
    		local color = game.ItemColor2[stone_cfg.color]

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

    --神器打造
    self._layout_objs["btn_forge"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:OpenGodWeaponView()
        self:Close()
    end)
    --神器强化
    self._layout_objs["btn_stren"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:OpenView(1)
        self:Close()
    end)
    --神器镶嵌
    self._layout_objs["btn_inlay"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:OpenView(2)
        self:Close()
    end)

    self._layout_objs["btn_forge"]:SetVisible(self.btn_visible)
    self._layout_objs["btn_stren"]:SetVisible(self.btn_visible)
    self._layout_objs["btn_inlay"]:SetVisible(self.btn_visible)
    self._layout_objs.btn_bg:SetVisible(self.btn_visible)
end

function WearGodweaponInfoView:SetBtnVisible(val)
    self.btn_visible = val
end

return WearGodweaponInfoView
