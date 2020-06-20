local DragonBagOperView = Class(game.BaseView)

function DragonBagOperView:_init(ctrl)
    self._package_name = "ui_dragon_design"
    self._com_name = "dragon_equip_oper_view"
    self._view_level = game.UIViewLevel.Third
    self.ctrl = ctrl

    self.dragon_design_data = self.ctrl:GetData()
end

function DragonBagOperView:_delete()
end

function DragonBagOperView:OnEmptyClick()
    self:Close()
end

function DragonBagOperView:OpenViewCallBack(item_info)
   
    local item_id = item_info.id
    local level = item_info.level
    local pos = item_info.pos
    local goods_cfg = config.goods[item_id]
    local equip_type_t = 1

    local item = self:GetTemplate("game/bag/item/goods_item", "item")
    item:SetItemInfo({id = item_id})
    item:SetShowTipsEnable(true)

    self._layout_objs["n2"]:SetText(goods_cfg.name)

    self._layout_objs["lv"]:SetText(tostring(level))

    local desc = ""
    local skill_id = config.dragon_item[item_id].skill
    if skill_id > 0 then
        desc = config.skill[skill_id][1].desc
    end
    self._layout_objs["main_txt"]:SetText(string.format(config.words[6138], desc))

    local attr = config.dragon_attr[item_id][level].attr
    if attr[1] then
        local attr_type = attr[1][1]
        local attr_val = attr[1][2]
        local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)
        local str = attr_name.."+"..attr_val
        self._layout_objs["sub_txt"]:SetText(string.format(config.words[6139], str))
    else
        self._layout_objs["sub_txt"]:SetText(string.format(config.words[6139], config.words[6140]))
    end

    if item_info.id == 39000101 then
        self._layout_objs["main_txt"]:SetText("[color=#FEF4AD]"..goods_cfg.desc.."[/color]")
        self._layout_objs["sub_txt"]:SetText("")
    end

    self._layout_objs["replace_btn"]:SetVisible(false)
    self._layout_objs["takeoff_btn"]:SetVisible(false)

    self._layout_objs["upgrade_btn"]:AddClickCallBack(function()
         if item_info.id == 39000101 then
            game.GameMsgCtrl.instance:PushMsg(config.words[6141])
        else
            self.ctrl:OpenDragonEatView(item_info, true)
        end
    end)
end

return DragonBagOperView