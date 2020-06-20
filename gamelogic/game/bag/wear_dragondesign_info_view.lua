local WearDragonDesignInfoView = Class(game.BaseView)

function WearDragonDesignInfoView:_init(ctrl)
    self._package_name = "ui_bag"
    self._com_name = "wear_dragondesign_info_view"
    self._view_level = game.UIViewLevel.Fouth

    self.ctrl = ctrl
end

function WearDragonDesignInfoView:OnEmptyClick()
    self:Close()
end

function WearDragonDesignInfoView:OpenViewCallBack(info)
    local item_id = info.id
    local goods_config = config.goods[item_id]
    local color = game.ItemColor[goods_config.color]
    local dragon_data = info.dragon_data
    if dragon_data == nil then
        dragon_data = game.DragonDesignCtrl.instance:GetData():GetAllData()
    end
    local growth_lv = dragon_data.growth_lv            --等级
    local growth_hole = dragon_data.growth_hole        --属性孔
    local growth_cfg = config.dragon_growth[growth_lv][growth_hole]

	self._layout_objs.name:SetText(string.format(config.words[1557], color, goods_config.name, info.stren))

    self.icon = require("game/bag/item/goods_item").New()
    self.icon:SetVirtual(self._layout_objs.icon)
    self.icon:Open()
    self.icon:SetItemInfo({ id = item_id})

    self._layout_objs.level:SetText(growth_lv)

    self._layout_objs.pos:SetText(config.equip_pos[12].name)

    local career = config.career_init[goods_config.career]
    if career then
        self._layout_objs.career:SetText(career.name)
    else
        self._layout_objs.career:SetText(config.words[1552])
    end

    self._layout_objs["n32"]:SetText(config.words[1555])

    for i = 1, 9 do
        if i <= dragon_data.refine_star then
            self._layout_objs["star"..i]:SetVisible(true)
        else
            self._layout_objs["star"..i]:SetVisible(false)
        end
    end

    --基础属性
    local base_attr_list = growth_cfg.attr
    local stren_attr = config.equip_stren[info.stren][11].attr
	local base_attr_str = ""
    local count = 0
    for i = 9, 10 do

        local j = base_attr_list[i]
        local attr_name = config_help.ConfigHelpAttr.GetAttrName(j[1])
        local s = string.format(config.words[1226], attr_name, j[2], "")
        local stren_value = stren_attr[count+1][2]
        s = s.."<font color='#13f4f3'>(+"..stren_value..")</font>"

        if count == 0 then
            base_attr_str = base_attr_str..s
        else
            base_attr_str = base_attr_str.."<br/>"..s
        end
        count = count + 1
    end
    self._layout_objs["base_attr"]:SetText(base_attr_str)

    --攻击间隔
    local t = 6000/base_attr_list[8][2]
    self._layout_objs["mid_attr"]:SetText(string.format(config.words[6144], t))

    --所有镶嵌龙元属性
    local count = 0
    local mid_attr_str = ""
    local attr_list = {}
    local dragon_design_data = game.DragonDesignCtrl.instance:GetData()
    for i = 1, 7 do
        local attr_info = growth_cfg.attr[i]
        local attr_type = attr_info[1]
        local attr_val = attr_info[2]
        local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)

        local t = {}
        t.id = attr_type
        t.value = attr_val

        local s
        if i > 3 then
            local percent = dragon_design_data:GetQualityPercent(i-3)
            local add_val = math.floor(attr_val*percent)
            local str1 = attr_name.."+"..attr_val
            t.value = attr_val + add_val
            s = string.format(config.words[6146], str1, add_val)
        else
            local str1 = attr_name.."+"..attr_val
            s = string.format(config.words[6145], str1)
        end

        if count == 0 then
            mid_attr_str = mid_attr_str..s
        else
            mid_attr_str = mid_attr_str.."<br/>"..s
        end
        count = count + 1

        table.insert(attr_list, t)
    end

    self._layout_objs["dragon_attr"]:SetText("<font>"..mid_attr_str.."</font>")

    --评分
    local combat_power = game.Utils.CalculateCombatPower3(attr_list)
    self._layout_objs.score:SetText(combat_power)

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

    --龙元镶嵌
    for i = 1, 4 do
        local start_index = (i-1)*4+1
        local unlock_lv = config.dragon_pos[start_index].unlock

        --已解锁
        if growth_lv >= unlock_lv then

            local str = ""
            local count = 0
            for j = 1, 4 do
                local pos = (i-1)*4+j
                local inlay_info = dragon_design_data:GetInlayInfoByPos(pos)
                if inlay_info and inlay_info.id > 0 then

                    local goods_cfg = config.goods[inlay_info.id]
                    local str_t = ""
                    --主龙元
                    if j == 1 then
                        local desc = ""
                        local skill_id = config.dragon_item[inlay_info.id].skill
                        if skill_id > 0 then
                            desc = config.skill[skill_id][1].desc
                        end
                        str_t = string.format(config.words[6151], goods_cfg.name, inlay_info.level, desc)
                    --辅龙元
                    else
                        local attr = config.dragon_attr[inlay_info.id][inlay_info.level].attr
                        local attr_type = attr[1][1]
                        local attr_val = attr[1][2]
                        local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)
                        str_t = attr_name.."+"..attr_val
                        str_t = string.format(config.words[6152],str_t) 
                    end

                    if count == 0 then
                        str = str..str_t
                    else
                        str = str.."<br/>"..str_t
                    end
                    count = count + 1
                end
            end

            if str ~= "" then
                self._layout_objs["lw_txt"..i]:SetText("<font>"..str.."</font>")
            else
                self._layout_objs["lw_txt"..i]:SetText(config.words[6153])
            end

        --未解锁
        else
            local index = 6146+i
            self._layout_objs["lw_txt"..i]:SetText(string.format(config.words[index], unlock_lv))
        end
    end

    self._layout_objs["nh_panel"]:SetVisible(true)

    self._layout_objs["btn_forge"]:AddClickCallBack(function()
        game.DragonDesignCtrl.instance:OpenView(2)
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

function WearDragonDesignInfoView:SetBtnVisible(val)
    self.btn_visible = val
end

return WearDragonDesignInfoView
