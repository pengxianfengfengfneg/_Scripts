local WearWeaponSoulInfoView = Class(game.BaseView)

function WearWeaponSoulInfoView:_init(ctrl)
    self._package_name = "ui_bag"
    self._com_name = "wear_weaponsoul_info_view"
    self._view_level = game.UIViewLevel.Fouth

    self.ctrl = ctrl
end

function WearWeaponSoulInfoView:OnEmptyClick()
    self:Close()
end

local sort_attr = function(a, b)
    return a.id < b.id
end

local attr_prefix = {
    [1] = "tb_attr",
    [2] = "ty_attr",
    [3] = "ts_attr",
    [4] = "tr_attr",
}

function WearWeaponSoulInfoView:OpenViewCallBack(info)

    local star_lv = info.star_lv
    local item_id = config.weapon_soul_star_up[star_lv].icon
    local goods_config = config.goods[item_id]
    local color = game.ItemColor[goods_config.color]

	self._layout_objs.name:SetText(string.format(config.words[1557], color, goods_config.name, info.stren))

    self.icon = require("game/bag/item/goods_item").New()
    self.icon:SetVirtual(self._layout_objs.icon)
    self.icon:Open()
    self.icon:SetItemInfo({ id = item_id})

    self._layout_objs.level:SetText(info.id)

    self._layout_objs.pos:SetText(config.equip_pos[11].name)

    local career = config.career_init[goods_config.career]
    if career then
        self._layout_objs.career:SetText(career.name)
    else
        self._layout_objs.career:SetText(config.words[1552])
    end

    self._layout_objs["n32"]:SetText(config.words[1555])

    for i = 1, 9 do
        if i <= star_lv then
            self._layout_objs["star"..i]:SetVisible(true)
        else
            self._layout_objs["star"..i]:SetVisible(false)
        end
    end

    --基础属性
    local base_attr_list = config.weapon_soul_base[1].basic_attr
    local stren_attr = config.equip_stren[info.stren][11].attr
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


    --精铸属性
    local mid_attr_str = ""
    local lv = info.id
    local refine_cfg = config.weapon_soul_refine[lv]

    local count = 0
    for k, v in pairs(refine_cfg.attr) do

        local attr_name = config_help.ConfigHelpAttr.GetAttrName(v[1])
        local s = attr_name.."+"..v[2]
        if count == 0 then
            mid_attr_str = mid_attr_str..s
        else
            mid_attr_str = mid_attr_str.."<br/>"..s
        end
        count = count + 1
    end
    self._layout_objs["mid_attr"]:SetText("<font>"..mid_attr_str.."</font>")

    --武魂技能
    if next(info.skills) then
        local skill_desc = ""
        local count = 0
        for k,v in pairs(info.skills) do

            local skill_id = v.id
            local skill_cfg = config.skill[skill_id][1]
            local color = game.ItemColor[skill_cfg.color]

            local s = "<font color = #"..color..">"..skill_cfg.name.."</font>:"..skill_cfg.desc
            if count == 0 then
                skill_desc = skill_desc..s
            else
                skill_desc = skill_desc.."<br/>"..s
            end
            count = count + 1

        end
        self._layout_objs["skill_attr"]:SetText("<font>"..skill_desc.."</font>")
    else
        self._layout_objs["skill_attr"]:SetText("")
    end

    --评分
    self._layout_objs.score:SetText(info.combat_power)

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

    --幻化外观
    local cur_avatar_id = info.cur_avatar
    if cur_avatar_id > 0 then
        local jp_cfg = config.weapon_soul_avatar[cur_avatar_id]
        self._layout_objs["wg_txt"]:SetText(config.words[6121]..jp_cfg.name)
    else
        self._layout_objs["wg_txt"]:SetText(config.words[6122])
    end

    --四岁星属性
    for i = 1, 4 do

        local attr_pre = attr_prefix[i]
        local soul_part_info
        for _, v in pairs(info.soul_parts) do
            if v.part.type == i then
                soul_part_info = v.part
                break
            end
        end

        if soul_part_info then
            for k, v in ipairs(soul_part_info.attr) do

                local attr_type = v.id
                local attr_value = v.value
                local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)

                self._layout_objs[attr_pre..k]:SetText(attr_name.."+"..attr_value)
            end
        end
    end

    self._layout_objs["nh_panel"]:SetVisible(true)

    self._layout_objs["btn_forge"]:AddClickCallBack(function()
        game.WeaponSoulCtrl.instance:OpenView()
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

    self._layout_objs["btn_forge"]:SetVisible(self.btn_visible)
    self._layout_objs["btn_stren"]:SetVisible(self.btn_visible)
    self._layout_objs["btn_inlay"]:SetVisible(self.btn_visible)
    self._layout_objs.btn_bg:SetVisible(self.btn_visible)


end

function WearWeaponSoulInfoView:SetBtnVisible(val)
    self.btn_visible = val
end

return WearWeaponSoulInfoView
