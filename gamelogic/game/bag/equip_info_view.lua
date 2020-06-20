local EquipInfoView = Class(game.BaseView)

local _master_type = { "stren", "refine", "temper", "quench" }

function EquipInfoView:_init(ctrl)
    self._package_name = "ui_bag"
    self._com_name = "equip_info_view"
    self._view_level = game.UIViewLevel.Fouth

    self.ctrl = ctrl
end

function EquipInfoView:OnEmptyClick()
    self:Close()
end

function EquipInfoView:OpenViewCallBack(info)
    local goods_config = config.goods[info.id]
    self.icon = require("game/bag/item/goods_item").New()
    self.icon:SetVirtual(self._layout_objs.icon)
    self.icon:Open()
    self.icon:SetItemInfo({ id = info.id})
    self._layout_objs.level:SetText(goods_config.lv)
    local career = config.career_init[goods_config.career]
    if career then
        self._layout_objs.career:SetText(career.name)
    else
        self._layout_objs.career:SetText(config.words[1552])
    end
    self._layout_objs.pos:SetText(config.equip_pos[goods_config.pos].name)
    self._layout_objs.name:SetText(goods_config.name)
    local color = cc.GoodsColor_light[goods_config.color]
    self._layout_objs.name:SetColor(color.x, color.y, color.z, color.w)

    self._layout_objs.score:SetText(game.Utils.CalculateCombatPower(goods_config.attr))
    local total_attr = {}
    for i, v in pairs(goods_config.attr) do
        table.insert(total_attr, v)
    end

    local str = "<font color='#fef4ad'>%s</font><br/>"
    local attr_str = string.format(str, config.words[1553])
    attr_str = attr_str .. self:FormatAttr(goods_config.attr)

    if goods_config.type == 10 then
        local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(goods_config.pos)
        if equip_info then
            for i, v in ipairs(_master_type) do
                local cur_lv = equip_info[_master_type[i]] or 1
                local attr = config["equip_" .. _master_type[i]][cur_lv][goods_config.pos].attr
                attr_str = attr_str .. "<img asset='ui_common:line_02' width='447' height='9'/><br/>"
                attr_str = attr_str .. string.format(str, config.words[1200 + i] .. config.words[1554])
                attr_str = attr_str .. self:FormatAttr(attr)
                for _, val in pairs(attr) do
                    table.insert(total_attr, val)
                end
            end
        end
    end
    self._layout_objs.base_attr:SetText(attr_str)
    self._layout_objs.power:SetText(config.words[1501] .. game.Utils.CalculateCombatPower(total_attr))
end

function EquipInfoView:CloseViewCallBack()
    self.icon:DeleteMe()
end

function EquipInfoView:FormatAttr(attr)
    local str = ""
    for i, v in ipairs(attr) do
        str = str .. config.combat_power[v[1]].name .. "：" .. v[2]
        if i < #attr then
            str = str .. "<br/>"
        end
    end
    return str
end

return EquipInfoView
