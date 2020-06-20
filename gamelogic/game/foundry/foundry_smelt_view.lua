local FoundrySmeltView = Class(game.BaseView)

function FoundrySmeltView:_init(ctrl)
    self._package_name = "ui_foundry"
    self._com_name = "foundry_smelt_view"

    self.ctrl = ctrl
end

function FoundrySmeltView:_delete()
end

function FoundrySmeltView:OpenViewCallBack()
    
    self.ctrl:CsSmeltInfo()
    game.MainUICtrl.instance:SendGetCommonlyKeyValue(game.CommonlyKey.SmeltColor)

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[1240])

    self._layout_objs["n32"]:AddClickCallBack(function()
        self.ctrl:OpenSmeltSelectView()
    end)

    self:BindEvent(game.FoundryEvent.UpdateSmeltInfo, function()
        self:UpdateInfo()
    end)
end

function FoundrySmeltView:CloseViewCallBack()
end

function FoundrySmeltView:UpdateInfo()
    local foundry_data = self.ctrl:GetData()
    local smelt_data = foundry_data:GetSmeltData()
    local cur_level = smelt_data.level
    local cur_exp = smelt_data.exp
    local cfg = config.equip_smelt[cur_level]
    local attr = cfg.attr
    local next_cfg = config.equip_smelt[cur_level+1]

    local s = game.Utils.GetNumStr(cur_level)
    self._layout_objs["level"]:SetText(s..config.words[1249])

    self._layout_objs["n30"]:SetProgressValue(cur_exp/cfg.cost*100)
    self._layout_objs["n30"]:GetChild("title"):SetText(cur_exp.."/"..cfg.cost)

    for index = 1, 5 do
        local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr[index][1])
        self._layout_objs["attr"..index]:SetText(attr_name.." "..tostring(attr[index][2]))

        if next_cfg then
            local attr_name2 = config_help.ConfigHelpAttr.GetAttrName(next_cfg.attr[index][1])
            self._layout_objs["next_attr"..index]:SetText(attr_name2.." "..tostring(next_cfg.attr[index][2]))
        end
    end

    --战力
    local combat = game.Utils.CalculateCombatPower2(attr)
    self._layout_objs["combat_txt"]:SetText(tostring(combat))

end

return FoundrySmeltView
