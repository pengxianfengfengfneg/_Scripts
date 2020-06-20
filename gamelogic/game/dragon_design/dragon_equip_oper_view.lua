local DragonEquipOperView = Class(game.BaseView)

function DragonEquipOperView:_init(ctrl)
    self._package_name = "ui_dragon_design"
    self._com_name = "dragon_equip_oper_view"
    self._view_level = game.UIViewLevel.Third
    self.ctrl = ctrl

    self.dragon_design_data = self.ctrl:GetData()
end

function DragonEquipOperView:_delete()
end

function DragonEquipOperView:OnEmptyClick()
    self:Close()
end

function DragonEquipOperView:OpenViewCallBack(item_info, hide_btn)
   
    local item_id = item_info.id
    local level = item_info.level
    local pos = item_info.pos
    local goods_cfg = config.goods[item_id]
    local equip_type_t = 0

    local item = self:GetTemplate("game/bag/item/goods_item", "item")
    item:SetItemInfo({id = item_id})
    item:SetShowTipsEnable(true)

    self._layout_objs["n2"]:SetText(goods_cfg.name)

    self._layout_objs["lv"]:SetText(tostring(level))

    --是主龙元
    if (pos%4) == 1 then
        equip_type_t = 0

        local desc = ""
        local skill_id = config.dragon_item[item_id].skill
        if skill_id > 0 then
            desc = config.skill[skill_id][1].desc
        end
        self._layout_objs["main_txt"]:SetText(string.format(config.words[6134], desc))

        local attr = config.dragon_attr[item_id][level].attr
        local attr_type = attr[1][1]
        local attr_val = attr[1][2]
        local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)
        local str = attr_name.."+"..attr_val
        self._layout_objs["sub_txt"]:SetText(string.format(config.words[6135], str))
    else
        equip_type_t = 1

        local desc = ""
        local skill_id = config.dragon_item[item_id].skill
        if skill_id > 0 then
            desc = config.skill[skill_id][1].desc
        end
        self._layout_objs["main_txt"]:SetText(string.format(config.words[6136], desc))

        local attr = config.dragon_attr[item_id][level].attr
        local attr_type = attr[1][1]
        local attr_val = attr[1][2]
        local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)
        local str = attr_name.."+"..attr_val
        self._layout_objs["sub_txt"]:SetText(string.format(config.words[6137], str))
    end

    self._layout_objs["replace_btn"]:SetVisible(not hide_btn)
    self._layout_objs["takeoff_btn"]:SetVisible(not hide_btn)
    self._layout_objs["upgrade_btn"]:SetVisible(not hide_btn)

    self._layout_objs["replace_btn"]:AddClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then     
            if main_role:IsFightState() then
                game.GameMsgCtrl.instance:PushMsg(config.words[535])
                return
            end
        end
        self.ctrl:OpenDragonEquipView({equip_type = equip_type_t, equip_pos = pos})
    end)

    self._layout_objs["takeoff_btn"]:AddClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then     
            if main_role:IsFightState() then
                game.GameMsgCtrl.instance:PushMsg(config.words[536])
                return
            end
        end
        self.ctrl:CsDragonEquip(pos, 0)
        self:Close()
    end)

    self._layout_objs["upgrade_btn"]:AddClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then     
            if main_role:IsFightState() then
                game.GameMsgCtrl.instance:PushMsg(config.words[537])
                return
            end
        end
        self.ctrl:OpenDragonEatView(item_info)
    end)
end

return DragonEquipOperView