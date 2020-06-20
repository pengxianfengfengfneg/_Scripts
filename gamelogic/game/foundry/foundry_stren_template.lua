local FoundryStrenTemplate = Class(game.UITemplate)

function FoundryStrenTemplate:_init()
	self._package_name = "ui_foundry"
    self._com_name = "foundry_stren_template"
end

function FoundryStrenTemplate:OpenViewCallBack()

	--一键强化
    self._layout_objs["n60"]:AddClickCallBack(function()
        self:DoOnekeyStren()
    end)

    --强化
    self._layout_objs["n61"]:AddClickCallBack(function()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_view2/btn_stren"})
        self:DoStren()
    end)

    --套装
	self._layout_objs["n10"]:AddClickCallBack(function()
		game.FoundryCtrl.instance:OpenStrenSuitAttrView()
    end)

    self:BindEvent(game.FoundryEvent.StrenSucc, function(data)
        self:PLayEffect()
        self:RefreshView(data)
    end)

    self:BindEvent(game.FoundryEvent.OneKeyStrenSucc, function(data)
        self:PLayEffect()
        self:RefreshView(data)
    end)

    self.cost_item = require("game/bag/item/goods_item").New()
    self.cost_item:SetVirtual(self._layout_objs["sour_item"])
    self.cost_item:Open()
    self.cost_item:SetShowTipsEnable(true)
    self.cost_item:ResetItem()

    self.cur_item = require("game/bag/item/goods_item").New()
    self.cur_item:SetVirtual(self._layout_objs["cur_equip"])
    self.cur_item:Open()
    self.cur_item:SetShowTipsEnable(true)
    self.cur_item:ResetItem()

    self:InitEquips()

    self:SetStrenLv()

    -- self:OnSelectEquip(1)
end

function FoundryStrenTemplate:PLayEffect()
    local effect_root = self.select_equip_item:GetChild("effect")
    self._layout_objs["effect2"]:SetVisible(true)
    self:CreateUIEffect(effect_root, "effect/ui/intensify_tb.ab")
    self:CreateUIEffect(self._layout_objs["effect2"], "effect/ui/intensify_process.ab")
end

function FoundryStrenTemplate:CloseViewCallBack()

    if self.cost_item then
        self.cost_item:DeleteMe()
        self.cost_item = nil
    end

    if self.cur_item then
        self.cur_item:DeleteMe()
        self.cur_item = nil
    end

    if self.bot_ui_list then
        self.bot_ui_list:DeleteMe()
        self.bot_ui_list = nil
    end
end

function FoundryStrenTemplate:InitEquips()

    local godweapon_data = game.FoundryCtrl.instance:GetData():GetGodweaponData()
    local hideweapon_data = game.FoundryCtrl.instance:GetData():GetHideWeaponData()
    local weaponsoul_data = game.WeaponSoulCtrl.instance:GetData():GetAllData()
    local dragon_data = game.FoundryCtrl.instance:GetEquipInfoByType(12)

    self.bot_list = self._layout_objs["list"]
    self.bot_ui_list = game.UIList.New(self.bot_list)
    self.bot_ui_list:SetVirtual(false)

    self.bot_ui_list:SetCreateItemFunc(function(obj)

        local equip_item = require("game/bag/item/goods_item").New()
        equip_item:SetVirtual(obj)
        equip_item:Open()
        return equip_item
    end)

    self.bot_ui_list:SetRefreshItemFunc(function (equip_item, idx)
        local equip_pos = self.can_stren_pos[idx]
        equip_item.equip_pos = equip_pos

        local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(equip_pos)
        if equip_pos == 9 then
            equip_info = game.FoundryCtrl.instance:GetData():GetGodweaponData()
        elseif equip_pos == 10 then
            equip_info = game.FoundryCtrl.instance:GetData():GetHideWeaponData()
        elseif equip_pos == 11 then
            equip_info = game.WeaponSoulCtrl.instance:GetData():GetAllData()
        end
        if equip_info and equip_info.id and equip_info.id ~= 0 then
            if equip_pos == 9 then
                local gw_id = equip_info.id
                local career = math.floor(gw_id/100)
                local gw_cfg = config.artifact_base[career][gw_id]
                local item_id = gw_cfg.item_id
                equip_item:SetItemInfo({ id = item_id})
            elseif equip_pos == 10 then
                local model_id = equip_info.id
                local item_id = config.anqi_model[model_id].icon
                equip_item:SetItemInfo({ id = item_id})
            elseif equip_pos == 11 then
                local star_lv = equip_info.star_lv
                local item_id = config.weapon_soul_star_up[star_lv].icon
                equip_item:SetItemInfo({ id = item_id})
            else
                equip_item:SetItemInfo({ id = equip_info.id })
            end
            equip_item:SetShowTipsEnable(true)

        else
            equip_item:ResetItem()
            local image = tostring(equip_pos)
            equip_item:SetItemImage(image)
        end
        equip_item:AddClickEvent(function ()
            self.bot_ui_list:Foreach(function(v)
                v:SetSelect(false)
            end)
            equip_item:SetSelect(true)
            
            self.select_equip_item = equip_item

            self:OnSelectEquip(equip_pos)
        end)
    end)

    local can_stren_pos = {}
    for i = 1, 8 do
        table.insert(can_stren_pos, i)
    end

    if godweapon_data and godweapon_data.id > 0 then
        table.insert(can_stren_pos, 9)   
    end

    if hideweapon_data and hideweapon_data.id > 0 then
        table.insert(can_stren_pos, 10)
    end

    if weaponsoul_data and weaponsoul_data.id > 0 then
        table.insert(can_stren_pos, 11)
    end

    if dragon_data and dragon_data.id > 0 then
        table.insert(can_stren_pos, 12)
    end

    self.can_stren_pos = can_stren_pos

    self.bot_ui_list:SetItemNum(#can_stren_pos)

    self.bot_ui_list:ScrollToView(0)

     --默认选择第一个装备
    local equip_item
    self.bot_ui_list:Foreach(function(v)
        v:SetSelect(false)
        if v.equip_pos == 1 then
            equip_item = v
        end
    end)
    equip_item:SetSelect(true)
    self.select_equip_item = equip_item
    self:OnSelectEquip(1)
end

function FoundryStrenTemplate:SetStrenLv()

    local main_role_lv = game.Scene.instance:GetMainRoleLevel()

    self.bot_ui_list:Foreach(function(equip_item)
        if equip_item.equip_pos == 9 then
            local godweapon_data = game.FoundryCtrl.instance:GetData():GetGodweaponData()
            if godweapon_data and godweapon_data.id > 0 then
                equip_item:SetItemLevel("+"..godweapon_data.stren)

                local equip_stren_cfg = config.equip_stren[godweapon_data.stren][9]
                local cost_item_id = equip_stren_cfg.cost[1]
                local cost_item_num = equip_stren_cfg.cost[2]
                local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)
                equip_item:SetHdVisible(false)
                if cur_num >= cost_item_num then
                    if main_role_lv > godweapon_data.stren then
                        equip_item:SetHdVisible(true)
                    end
                end

            end
        elseif equip_item.equip_pos == 10 then
            local hideweapon_data = game.FoundryCtrl.instance:GetData():GetHideWeaponData()
            if hideweapon_data and hideweapon_data.id > 0 then
                equip_item:SetItemLevel("+"..hideweapon_data.stren)

                local equip_stren_cfg = config.equip_stren[hideweapon_data.stren][10]
                local cost_item_id = equip_stren_cfg.cost[1]
                local cost_item_num = equip_stren_cfg.cost[2]
                local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)
                equip_item:SetHdVisible(false)
                if cur_num >= cost_item_num then
                    if main_role_lv > hideweapon_data.stren then
                        equip_item:SetHdVisible(true)
                    end
                end
            end
        elseif equip_item.equip_pos == 11 then
            local weaponsoul_data = game.WeaponSoulCtrl.instance:GetData():GetAllData()
            if weaponsoul_data and weaponsoul_data.id > 0 then
                equip_item:SetItemLevel("+"..weaponsoul_data.stren)

                local equip_stren_cfg = config.equip_stren[weaponsoul_data.stren][11]
                local cost_item_id = equip_stren_cfg.cost[1]
                local cost_item_num = equip_stren_cfg.cost[2]
                local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)
                equip_item:SetHdVisible(false)
                if cur_num >= cost_item_num then
                    if main_role_lv > weaponsoul_data.stren then
                        equip_item:SetHdVisible(true)
                    end
                end
            end
        else
            local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(equip_item.equip_pos)
            if equip_info then
                equip_item:SetItemLevel("+"..equip_info.stren)
                local equip_stren_cfg = config.equip_stren[equip_info.stren][equip_item.equip_pos]
                local cost_item_id = equip_stren_cfg.cost[1]
                local cost_item_num = equip_stren_cfg.cost[2]
                local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)
                equip_item:SetHdVisible(false)
                if cur_num >= cost_item_num then
                    if main_role_lv > equip_info.stren then
                        equip_item:SetHdVisible(true)
                    end
                end
            else
                equip_item:SetItemLevel("+"..0)
            end
        end
    end)

    self:SetSuitLv()
end

function FoundryStrenTemplate:OnSelectEquip(pos)

    self.select_pos = pos

    self:UpdateMidInfo()
end

function FoundryStrenTemplate:UpdateMidInfo()

    self:ResetAttrInfo()

    local pos = self.select_pos

    local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(pos)
    if pos == 9 then
        equip_info = game.FoundryCtrl.instance:GetData():GetGodweaponData()
    elseif pos == 10 then
        equip_info = game.FoundryCtrl.instance:GetData():GetHideWeaponData()
    elseif pos == 11 then
        equip_info = game.WeaponSoulCtrl.instance:GetData():GetAllData()
    end
    local stren_lv = 0
    if equip_info then
        stren_lv = equip_info.stren
    end
    local equip_stren_cfg = config.equip_stren[stren_lv][pos]
    local next_equip_stren_cfg = config.equip_stren[stren_lv+1] and config.equip_stren[stren_lv+1][pos] or config.equip_stren[stren_lv][pos]

    local equip_name = config.equip_pos[pos].name
    self._layout_objs["n13"]:SetText(equip_name)
    self._layout_objs["n14"]:SetText("+"..stren_lv)

    self._layout_objs["row1txt1"]:SetText(tostring(stren_lv)..config.words[1217])
    self._layout_objs["row1txt2"]:SetText(tostring(stren_lv+1)..config.words[1217])

    --属性
    for k, v in ipairs(equip_stren_cfg.attr) do
        local attr_type = v[1]
        local attr_v = v[2]
        local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)
        self._layout_objs["row"..(k+1).."txt1"]:SetText(string.format(config.words[1224], attr_name, attr_v))
    end

    for k, v in ipairs(next_equip_stren_cfg.attr) do
        local attr_type = v[1]
        local attr_v = v[2]
        local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)
        self._layout_objs["row"..(k+1).."txt2"]:SetText(string.format(config.words[1224], attr_name, attr_v))
    end

    --消耗材料
    local cost_item_id = equip_stren_cfg.cost[1]
    local cost_item_num = equip_stren_cfg.cost[2]
    local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)
    local str = tostring(cur_num).."/"..tostring(cost_item_num)
    self.cost_item:SetItemInfo({ id = cost_item_id, num = cost_item_num})
    self.cost_item:SetNumText(str)

    self._layout_objs["n61/hd"]:SetVisible(false)
    self._layout_objs["n60/hd"]:SetVisible(false)
    if cur_num>= cost_item_num then
        self.cost_item:SetColor(95,201,52)

        local main_role_lv = game.Scene.instance:GetMainRoleLevel()
        if stren_lv < main_role_lv then
            self._layout_objs["n61/hd"]:SetVisible(true)
            self._layout_objs["n60/hd"]:SetVisible(true)
        end
    else
        self.cost_item:SetColor(255, 0, 0)
    end

    if equip_info and equip_info.id and equip_info.id ~= 0 then
        if pos == 9 then
            local gw_id = equip_info.id
            local career = math.floor(gw_id/100)
            local gw_cfg = config.artifact_base[career][gw_id]
            local item_id = gw_cfg.item_id
            self.cur_item:SetItemInfo({ id = item_id})
            self.cur_item:AddClickEvent(function()
                game.BagCtrl.instance:OpenWearGodweaponInfoView(equip_info, false)
            end)
        elseif pos == 10 then
            local model_id = equip_info.id
            local item_id = config.anqi_model[model_id].icon
            self.cur_item:SetItemInfo({ id = item_id})
            self.cur_item:AddClickEvent(function()
                game.BagCtrl.instance:OpenWearHideweaponInfoView(equip_info, false)
            end)
        elseif pos == 11 then
            local star_lv = equip_info.star_lv
            local item_id = config.weapon_soul_star_up[star_lv].icon
            self.cur_item:SetItemInfo({ id = item_id})
            self.cur_item:AddClickEvent(function()
                game.BagCtrl.instance:OpenWearHideweaponInfoView(equip_info, false)
            end)
        elseif pos == 12 then
            self.cur_item:SetItemInfo({ id = equip_info.id })
            self.cur_item:AddClickEvent(function()
                game.BagCtrl.instance:OpenWearDragonDesignInfoView(equip_info, false)
            end)
        else
            self.cur_item:SetItemInfo({ id = equip_info.id })
            self.cur_item:AddClickEvent(function()
                game.BagCtrl.instance:OpenWearEquipInfoView(equip_info, true)
            end)
        end
 
        self.cur_item:SetShowTipsEnable(true)
    else
        self.cur_item:ResetItem()
        local image = tostring(pos)
        self.cur_item:SetItemImage(image)
        self.cur_item:AddClickEvent(function()
        end)
    end

    self.cur_item:SetItemLevel("+"..stren_lv)
end

function FoundryStrenTemplate:ResetAttrInfo()

    for k = 1, 3 do
        self._layout_objs["row"..(k).."txt1"]:SetText("")
        self._layout_objs["row"..(k).."txt2"]:SetText("")
    end
end

function FoundryStrenTemplate:DoOnekeyStren()
    game.FoundryCtrl.instance:CsEquipOneKeyStren()
end

function FoundryStrenTemplate:DoStren()
    game.FoundryCtrl.instance:CsEquipStren(self.select_pos)
end

function FoundryStrenTemplate:RefreshView()
    self:SetStrenLv()
    self:UpdateMidInfo()
end

function FoundryStrenTemplate:SetSuitLv()

    local career = game.RoleCtrl.instance:GetCareer()
    local suit_cfg = config.equip_stren_suit[career]
    local stren_lv_list = {}
    for pos = 1, 8 do

        local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(pos)
        if equip_info then
            table.insert(stren_lv_list, equip_info.stren)
        else
            table.insert(stren_lv_list, 0)
        end
    end

    local godweapon_data = game.FoundryCtrl.instance:GetData():GetGodweaponData()
    if godweapon_data and godweapon_data.id > 0 then
        table.insert(stren_lv_list, godweapon_data.stren)
    end

    local hideweapon_data = game.FoundryCtrl.instance:GetData():GetHideWeaponData()
    if hideweapon_data and hideweapon_data.id > 0 then
        table.insert(stren_lv_list, hideweapon_data.stren)
    end

    local weaponsoul_data = game.WeaponSoulCtrl.instance:GetData():GetAllData()
    if weaponsoul_data and weaponsoul_data.id > 0 then
        table.insert(stren_lv_list, weaponsoul_data.stren)
    end

    local finish_item_num = 0

    for k, v in pairs(suit_cfg) do

        local need_lv = v.lv
        local need_num = v.num

        local count = 0
        for _, stren_lv in pairs(stren_lv_list) do

            if stren_lv >= need_lv then
                count = count + 1
            end
        end

        if count >= need_num then
            finish_item_num = finish_item_num + 1
        end
    end

    self._layout_objs["n10"]:SetText(finish_item_num)
end

function FoundryStrenTemplate:PlayEffect()
    self._layout_objs.effect:SetVisible(true)
    self:CreateUIEffect(self._layout_objs.effect, "effect/ui/zb_dadzao.ab")
end

return FoundryStrenTemplate