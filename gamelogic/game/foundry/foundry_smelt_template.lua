local FoundrySmeltTemplate = Class(game.UITemplate)

function FoundrySmeltTemplate:_init(parent)
	self._package_name = "ui_foundry"
    self._com_name = "foundry_smelt_template"
    self.parent = parent
    self.ctrl = game.FoundryCtrl.instance
end

function FoundrySmeltTemplate:OpenViewCallBack()

	self.ctrl:CsSmeltInfo()

    game.MainUICtrl.instance:SendGetCommonlyKeyValue(game.CommonlyKey.SmeltColor)

    self._layout_objs["n31"]:AddClickCallBack(function()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_view2/smelt_template/btn_smelt"})
        self.ctrl:OpenSmeltSelectView()
    end)

    self:BindEvent(game.FoundryEvent.UpdateSmeltInfo, function()
        self:UpdateInfo()
    end)

    local time = 3
    self.timer = global.TimerMgr:CreateTimer(0.5,
        function()
            time = time - 1
            if time <= 0 then
                self._layout_objs["effect"]:SetVisible(true)
                local ui_effect = self:CreateUIEffect(self._layout_objs["effect"], "effect/ui/ui_fusion.ab")
                ui_effect:SetLoop(true)

                 self._layout_objs["effect2"]:SetVisible(true)
                local ui_effect2 = self:CreateUIEffect(self._layout_objs["effect2"], "effect/ui/ui_bagua.ab")
                ui_effect2:SetLoop(true)
                self:DelTimer()
            end
        end)
end

function FoundrySmeltTemplate:CloseViewCallBack()
    self:DelTimer()
end

function FoundrySmeltTemplate:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function FoundrySmeltTemplate:UpdateInfo()
    local foundry_data = self.ctrl:GetData()
    local smelt_data = foundry_data:GetSmeltData()
    local cur_level = smelt_data.level
    local cur_exp = smelt_data.exp
    local cfg = config.equip_smelt[cur_level]
    local attr = cfg.attr
    local next_cfg = config.equip_smelt[cur_level+1]

    local s = game.Utils.GetNumStr(cur_level)
    self._layout_objs["level"]:SetText(s..config.words[1249])

    self._layout_objs["n29"]:SetProgressValue(cur_exp/cfg.cost*100)
    self._layout_objs["n29"]:GetChild("title"):SetText(cur_exp.."/"..cfg.cost)

    for index = 1, 5 do
        local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr[index][1])
        self._layout_objs["attr"..index]:SetText(attr_name..": "..tostring(attr[index][2]))

        if next_cfg then
            self._layout_objs["next_attr"..index]:SetText(config.words[1269].." "..tostring(next_cfg.attr[index][2]))
        end
    end

    --战力
    local combat = game.Utils.CalculateCombatPower2(attr)
    self._layout_objs["combat_txt"]:SetText(tostring(combat))

    --器魂属性
    local career = game.RoleCtrl.instance:GetCareer()
    local soul = smelt_data.soul
    for i = 1, 4 do

    	local soul_data = soul[i]
    	local soul_lv = 0
    	if soul_data then
    		soul_lv = soul_data.lv
    	end

    	local attr = config.smelt_soul_lv[i][soul_lv]["attr_"..career][1]
    	local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr[1])
    	self._layout_objs["attrx"..i]:SetText(attr_name..": "..tostring(attr[2]))

    	local attr2 = config.smelt_soul_lv[i][soul_lv+1]["attr_"..career][1]
    	local attr_name2 = config_help.ConfigHelpAttr.GetAttrName(attr2[1])
    	self._layout_objs["next_attrx"..i]:SetText(config.words[1270].." "..tostring(attr2[2]))

    	self._layout_objs["txt"..i]:SetText(tostring(soul_lv)..config.words[1217])
    end
end

return FoundrySmeltTemplate