local GodEquipResonanceView = Class(game.BaseView)

function GodEquipResonanceView:_init(ctrl)
    self._package_name = "ui_god_equip"
    self._com_name = "god_equip_resonance"
    self._view_level = game.UIViewLevel.Second
end

function GodEquipResonanceView:OpenViewCallBack()

    self:GetRoot():AddClickCallBack(function()
        self:Close()
    end)

    local equip_info = game.FoundryCtrl.instance:GetEquipInfo()

    local attr = {}
    local attr_str = ""

    if equip_info then
        self._layout_objs.level:SetText(equip_info.god_level .. config.words[1217])
        self._layout_objs.num:SetText(equip_info.god_chain .. config.words[1218])

        for i, v in ipairs(config.god_equip_level) do
            if equip_info.god_level >= v.level then
                attr = v.attr
            end
        end
        for i, v in ipairs(attr) do
            attr_str = attr_str .. config.combat_power[v[1]].name .. "：" .. v[2] .. "<br/>"
        end
        self._layout_objs.level_attr:SetText(attr_str)

        attr = {}
        attr_str = ""

        for i, v in ipairs(config.god_equip_chain) do
            if equip_info.god_chain >= v.num then
                attr = v.attr
            end
        end
        for i, v in ipairs(attr) do
            attr_str = attr_str .. config.combat_power[v[1]].name .. "：" .. v[2] .. "<br/>"
        end
        self._layout_objs.chain_attr:SetText(attr_str)
    end
end

return GodEquipResonanceView
