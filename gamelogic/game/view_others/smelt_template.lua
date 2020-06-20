local FoundrySmeltTemplate = Class(game.UITemplate)

function FoundrySmeltTemplate:_init(parent, info)
    self.parent_view = parent
    self.info = info.info
    self.smelt_info = info.forge
end

function FoundrySmeltTemplate:OpenViewCallBack()
    self:UpdateInfo()
end

function FoundrySmeltTemplate:UpdateInfo()
    local cur_level = self.smelt_info.level
    local cur_exp = self.smelt_info.exp
    local cfg = config.equip_smelt[cur_level]
    local attr = cfg.attr
    local next_cfg = config.equip_smelt[cur_level + 1]

    local s = game.Utils.GetNumStr(cur_level)
    self._layout_objs["level"]:SetText(s .. config.words[1249])

    self._layout_objs["n29"]:SetProgressValue(cur_exp / cfg.cost * 100)
    self._layout_objs["n29"]:GetChild("title"):SetText(cur_exp .. "/" .. cfg.cost)

    for index = 1, 5 do
        local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr[index][1])
        self._layout_objs["attr" .. index]:SetText(attr_name .. ": " .. tostring(attr[index][2]))

        if next_cfg then
            self._layout_objs["next_attr" .. index]:SetText(config.words[1269] .. " " .. tostring(next_cfg.attr[index][2]))
        end
    end

    --战力
    local combat = game.Utils.CalculateCombatPower2(attr)
    self._layout_objs["combat_txt"]:SetText(tostring(combat))

    --器魂属性
    local career = self.info.career
    local soul = self.smelt_info.soul
    for i = 1, 4 do

        local soul_data = soul[i]
        local soul_lv = 0
        if soul_data then
            soul_lv = soul_data.lv
        end

        local attr = config.smelt_soul_lv[i][soul_lv]["attr_" .. career][1]
        local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr[1])
        self._layout_objs["attrx" .. i]:SetText(attr_name .. ": " .. tostring(attr[2]))

        local attr2 = config.smelt_soul_lv[i][soul_lv + 1]["attr_" .. career][1]
        self._layout_objs["next_attrx" .. i]:SetText(config.words[1270] .. " " .. tostring(attr2[2]))

        self._layout_objs["txt" .. i]:SetText(tostring(soul_lv) .. config.words[1217])
    end
end

return FoundrySmeltTemplate