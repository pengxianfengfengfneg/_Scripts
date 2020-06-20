local RoleBaseTemplate = Class(game.UITemplate)

function RoleBaseTemplate:_init(view)
    self.ctrl = game.RoleCtrl.instance
end

function RoleBaseTemplate:OpenViewCallBack()
	self:InitRoleModel()
	self:InitEquipList()
	self:RefreshEquipList()
	self:RefreshGodweapon()
    self:RefreshHideweapon()
    self:RefreshWeaponSoul()
    self:RefreshDragonDesign()

	self:InitInfo()
	self:RefreshPower()
    self:SetHonor()

	self._layout_objs["btn_up"]:AddClickCallBack(function()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_role/role_new_view/role_base_com/btn_up"})
        self.ctrl:OpenHonorView()
	end)
    self._layout_objs["honor"]:SetTouchDisabled(false)
    self._layout_objs["honor"]:AddClickCallBack(function()
        self.ctrl:OpenHonorView()
    end)
	self._layout_objs["btn_bs"]:AddClickCallBack(function()
		game.FoundryCtrl.instance:OpenStoneSuitAttrView()
	end)
	self._layout_objs["btn_zb"]:AddClickCallBack(function()
		game.FoundryCtrl.instance:OpenStrenSuitAttrView()
	end)

	self:RegisterAllEvents()
end

function RoleBaseTemplate:CloseViewCallBack()
	self:ClearEquipList()
	self:ClearRoleModel()
end

function RoleBaseTemplate:RegisterAllEvents()
    local events = {
        {game.RoleEvent.UpdateMainRoleInfo, handler(self,self.RefreshPower)},
        {game.FoundryEvent.EquipRefresh, handler(self,self.RefreshEquipList)},
        {game.RoleEvent.HonorUpgrade, handler(self,self.SetHonor)},
    }

    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function RoleBaseTemplate:InitInfo()
	local vo = game.Scene.instance:GetMainRoleVo()
	if vo then
		local cfg = config.career_init[vo.career]
		self._layout_objs["career_img"]:SetSprite("ui_common", "career" .. vo.career)
		self._layout_objs["role_info_txt"]:SetText(string.format(config.words[1267], vo.level, cfg.name, cfg.element, cfg.atk_type_name))
		self._layout_objs["name_txt"]:SetText(vo.name)
	end
end

function RoleBaseTemplate:RefreshPower()
	local power = self.ctrl:GetCombatPower()
	self._layout_objs["fight_txt"]:SetText(power)
end

--½ÇÉ«×°±¸
function RoleBaseTemplate:InitEquipList()
    self.equip_list = {}
    for i = 1, 12 do
        local equip_item = require("game/bag/item/goods_item").New()
        equip_item:SetVirtual(self._layout_objs["equip" .. i])
        equip_item:SetShowTipsEnable(true)
        equip_item:Open()
        equip_item:AddClickEvent(function()
        	local equip_info
        	if i == 9 then
        		equip_info = game.FoundryCtrl.instance:GetData():GetGodweaponData()
            elseif i == 10 then
                equip_info = game.FoundryCtrl.instance:GetData():GetHideWeaponData()
            elseif i == 11 then
                equip_info = game.WeaponSoulCtrl.instance:GetData():GetAllData()
            elseif i == 12 then
                equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(12)
        	else
        		equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(i)
        	end

        	if equip_info and equip_info.id ~= 0 then
        		if i == 9 then
                    game.BagCtrl.instance:OpenWearGodweaponInfoView(equip_info)
                elseif i == 10 then
                    game.BagCtrl.instance:OpenWearHideweaponInfoView(equip_info)
                elseif i == 11 then
                    game.BagCtrl.instance:OpenWearWeaponSoulInfoView(equip_info)
                elseif i == 12 then
                    game.BagCtrl.instance:OpenWearDragonDesignInfoView(equip_info)
				else
                    game.BagCtrl.instance:OpenWearEquipInfoView(equip_info)
				end
			end
        end)

        local info = {}
        info.name = self._layout_objs["equip_lv" .. i]
        info.lv_bg = self._layout_objs["lv_bg" .. i]
        info.lv = self._layout_objs["lv" .. i]
        info.item = equip_item
        table.insert(self.equip_list, info)
    end
end

function RoleBaseTemplate:ClearEquipList()
	for i,v in ipairs(self.equip_list) do
		v.item:DeleteMe()
	end
	self.equip_list = nil
end

function RoleBaseTemplate:RefreshEquipList()
    for i = 1, 8 do
        local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(i)
        if equip_info and equip_info.id ~= 0 then
            self.equip_list[i].item:SetItemInfo({ id = equip_info.id })
            self.equip_list[i].lv:SetText("+"..equip_info.stren)
            if i == 7 and game.MarryCtrl.instance:IsMarry() then
                local bless_cfg = config.marry_bless[game.MarryCtrl.instance:GetBless()]
                self.equip_list[i].item:SetRingImage(bless_cfg.frame)
            end
            self.equip_list[i].name:SetText(config.goods[equip_info.id].name)
        else
            self.equip_list[i].item:ResetItem()
            self.equip_list[i].lv_bg:SetVisible(false)
            self.equip_list[i].lv:SetVisible(false)
            self.equip_list[i].name:SetText(config.words[1222])
            self.equip_list[i].item:SetItemImage(tostring(i))
        end

        self.equip_list[i].name:SetVisible(false)
    end

    local data = game.FoundryCtrl.instance:GetData()
    self._layout_objs["btn_bs"]:SetText(tostring(data:GetStoneSuitNum()))
    self._layout_objs["btn_zb"]:SetText(tostring(data:GetStrenSuitLv()))
end

function RoleBaseTemplate:RefreshGodweapon()
    local equip_info = game.FoundryCtrl.instance:GetData():GetGodweaponData()
    if equip_info and equip_info.id > 0 then
        self.equip_list[9].item:SetVisible(true)
        self.equip_list[9].lv_bg:SetVisible(true)
        self.equip_list[9].lv:SetVisible(true)
        self.equip_list[9].name:SetVisible(false)

        local gw_id = equip_info.id
        local career = math.floor(gw_id/100)
        local gw_cfg = config.artifact_base[career][gw_id]
        local item_id = gw_cfg.item_id
        self.equip_list[9].item:SetItemInfo({ id = item_id})
        self.equip_list[9].lv:SetText("+"..equip_info.stren)
        self.equip_list[9].name:SetText(config.goods[item_id].name)
    else
    	self.equip_list[9].item:SetVisible(false)
    	self.equip_list[9].name:SetVisible(false)
        self.equip_list[9].lv_bg:SetVisible(false)
        self.equip_list[9].lv:SetVisible(false)
    end
end

function RoleBaseTemplate:RefreshHideweapon()
    local equip_info = game.FoundryCtrl.instance:GetData():GetHideWeaponData()
    if equip_info and equip_info.id > 0 then
        self.equip_list[10].item:SetVisible(true)
        self.equip_list[10].lv_bg:SetVisible(true)
        self.equip_list[10].lv:SetVisible(true)
        self.equip_list[10].name:SetVisible(false)

        local cur_cfg = config.anqi_model[equip_info.id]
        local item_id = cur_cfg.icon
        self.equip_list[10].item:SetItemInfo({ id = item_id})
        self.equip_list[10].lv:SetText("+"..equip_info.stren)
        self.equip_list[10].name:SetText(config.goods[item_id].name)
    else
        self.equip_list[10].item:SetVisible(false)
        self.equip_list[10].name:SetVisible(false)
        self.equip_list[10].lv_bg:SetVisible(false)
        self.equip_list[10].lv:SetVisible(false)
    end
end

function RoleBaseTemplate:RefreshWeaponSoul()
    local equip_info = game.WeaponSoulCtrl.instance:GetData():GetAllData()
    if equip_info and equip_info.id > 0 then
        self.equip_list[11].item:SetVisible(true)
        self.equip_list[11].lv_bg:SetVisible(true)
        self.equip_list[11].lv:SetVisible(true)
        self.equip_list[11].name:SetVisible(false)

        local star_lv = equip_info.star_lv
        local item_id = config.weapon_soul_star_up[star_lv].icon
        self.equip_list[11].item:SetItemInfo({ id = item_id})
        self.equip_list[11].lv:SetText("+"..equip_info.stren)
        self.equip_list[11].name:SetText(config.goods[item_id].name)
    else
        self.equip_list[11].item:SetVisible(false)
        self.equip_list[11].name:SetVisible(false)
        self.equip_list[11].lv_bg:SetVisible(false)
        self.equip_list[11].lv:SetVisible(false)
    end
end

function RoleBaseTemplate:RefreshDragonDesign()
    local equip_info =game.FoundryCtrl.instance:GetEquipInfoByType(12)
    if equip_info and equip_info.id > 0 then
        self.equip_list[12].item:SetVisible(true)
        self.equip_list[12].lv_bg:SetVisible(true)
        self.equip_list[12].lv:SetVisible(true)
        self.equip_list[12].name:SetVisible(false)

        local item_id = equip_info.id
        self.equip_list[12].item:SetItemInfo({ id = item_id})
        self.equip_list[12].lv:SetText("+"..equip_info.stren)
        self.equip_list[12].name:SetText(config.goods[item_id].name)
    else
        self.equip_list[12].item:SetVisible(false)
        self.equip_list[12].name:SetVisible(false)
        self.equip_list[12].lv_bg:SetVisible(false)
        self.equip_list[12].lv:SetVisible(false)
    end
end

local show_model_type_list = {
	game.ModelType.Body, game.ModelType.Hair, game.ModelType.Weapon, game.ModelType.Weapon2, game.ModelType.WeaponSoul
}

function RoleBaseTemplate:InitRoleModel()
    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end

    local model_list = {}
    for i,v in ipairs(show_model_type_list) do
    	local id, anim = main_role:_GetModelID(v)
    	if id ~= 0 then
    		model_list[v] = id
    	end
    end

    self.role_model = require("game/character/model_template").New()
    self.role_model:CreateModel(self._layout_objs["wrapper"], game.BodyType.Role, model_list)
    self.role_model:SetModelChangeCallBack(function(model_type)
        if model_type == game.ModelType.Hair then
            local color_hex = main_role:GetHair()
            self.role_model:UpdateHairColorHex(color_hex)
        end
    end)
    self.role_model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.Body + game.ModelType.Hair + game.ModelType.WeaponSoul)
    self.role_model:SetCameraRotation(9.5,0,0)
    self.role_model:SetPosition(0,-1.4,2.5)
    self.role_model:SetRotation(0,180,0)
end

function RoleBaseTemplate:ClearRoleModel()
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
end

function RoleBaseTemplate:SetHonor()
    local honor = self.ctrl:GetRoleHonor()
    self._layout_objs["title_txt"]:SetVisible(honor == 0)
    self._layout_objs["honor"]:SetVisible(honor > 0)
    if honor > 0 then
        self._layout_objs["honor"]:SetSprite("ui_title", config.title_honor[honor].icon, true)
    end

    game.Utils.SetTip(self._layout_objs.btn_up, self.ctrl:GetHonorTipState(), {x = 60, y = 25})
end

return RoleBaseTemplate
