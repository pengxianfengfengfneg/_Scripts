local WearHideweaponInfoView = Class(game.BaseView)

function WearHideweaponInfoView:_init(ctrl)
    self._package_name = "ui_bag"
    self._com_name = "wear_hideweapon_info_view"
    self._view_level = game.UIViewLevel.Fouth

    self.ctrl = ctrl
end

function WearHideweaponInfoView:OnEmptyClick()
    self:Close()
end

local sort_attr = function(a, b)
    return a.id < b.id
end

function WearHideweaponInfoView:OpenViewCallBack(info)

    local cur_model_id = info.id
    local cur_cfg = config.anqi_model[cur_model_id]
    local item_id = cur_cfg.icon
    local goods_config = config.goods[item_id]
    local color = game.ItemColor[goods_config.color]

	self._layout_objs.name:SetText(string.format(config.words[1557], color, goods_config.name, info.stren))

    self.icon = require("game/bag/item/goods_item").New()
    self.icon:SetVirtual(self._layout_objs.icon)
    self.icon:Open()
    self.icon:SetItemInfo({ id = item_id})

    self._layout_objs.level:SetText(goods_config.lv)

    self._layout_objs.pos:SetText(config.equip_pos[10].name)

    local career = config.career_init[goods_config.career]
    if career then
        self._layout_objs.career:SetText(career.name)
    else
        self._layout_objs.career:SetText(config.words[1552])
    end

    self._layout_objs["n32"]:SetText(config.words[1555])

    for i = 1, 9 do
        if i <= cur_cfg.star then
            self._layout_objs["star"..i]:SetVisible(true)
        else
            self._layout_objs["star"..i]:SetVisible(false)
        end
    end

    --基础属性
    local base_attr_list = cur_cfg.attr
    local stren_attr = config.equip_stren[info.stren][10].attr
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


    local mid_attr_str = ""
    --原始属性
    local origin_attr = info.origin_attr
    table.sort(origin_attr, sort_attr)

    --暗器属性
    local add_attr = info.add_attr
    table.sort( add_attr, sort_attr)

    local count = 0
    for k, v in pairs(add_attr) do

        local attr_name = config_help.ConfigHelpAttr.GetAttrName(v.id)
        local orgin_attr_info = origin_attr[k]
        local s = string.format(config.words[1291], attr_name, v.value, attr_name, orgin_attr_info.value)
        if count == 0 then
            mid_attr_str = mid_attr_str..s
        else
            mid_attr_str = mid_attr_str.."<br/>"..s
        end
        count = count + 1
    end
    self._layout_objs["mid_attr"]:SetText("<font>"..mid_attr_str.."</font>")

    --暗器技能
    local cur_skill_info = game.FoundryCtrl.instance:GetData():GetHWCurSkill()
    if next(cur_skill_info) then
        local skill_desc = ""
        local count = 0
        for i = 1, 3 do
            if cur_skill_info["skill"..i] > 0 then

                local skill_id = cur_skill_info["skill"..i]
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
        end
        self._layout_objs["skill_attr"]:SetText("<font>"..skill_desc.."</font>")
    else
        self._layout_objs["skill_attr"]:SetText("")
    end

    --暗器品阶 修炼
    local str = ""
    local cur_practice_lv = info.practice_lv
    local max_practice_lv = #config.anqi_practice
    local cur_lv = info.q_level

    if cur_practice_lv == max_practice_lv then
        str = string.format(config.words[1292], cur_lv, cur_practice_lv)..config.words[1293]
    else
        str = string.format(config.words[1292], cur_lv, cur_practice_lv)
    end
    self._layout_objs["anqi_lv_info_txt"]:SetText("<font>"..str.."</font>")


    --评分
    local base_score = game.Utils.CalculateCombatPower2(base_attr_list)
    local add_score = game.Utils.CalculateCombatPower3(add_attr)
    local total_score = base_score + add_score
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

    --淬毒
    if cur_practice_lv >= 100 then

        local foundry_data = game.FoundryCtrl.instance:GetData()
        local poison_attr_list = foundry_data:GetAllPoisonAttrList()
        local count = 1
        for k, v in pairs(poison_attr_list) do
            local attr_name = config_help.ConfigHelpAttr.GetAttrName(k)
            local s = attr_name.."+"..tostring(v)
            self._layout_objs["attr"..count]:SetText(s)
            count = count + 1
        end

        self._layout_objs["poison_panel"]:SetVisible(true)

        local posx, posy = self._layout_objs["n85"]:GetPosition()
        self._layout_objs["n67"]:SetPosition(47, posy+399)
    else
        self._layout_objs["poison_panel"]:SetVisible(false)

        local posx, posy = self._layout_objs["n85"]:GetPosition()
        self._layout_objs["n67"]:SetPosition(47, posy+212)
    end

    self._layout_objs["btn_forge"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:OpenHideWeaponView(2)
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

function WearHideweaponInfoView:SetBtnVisible(val)
    self.btn_visible = val
end

return WearHideweaponInfoView
