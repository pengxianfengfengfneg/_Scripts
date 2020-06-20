local FoundryGodweaponHuanhuaTemplate = Class(game.UITemplate)
local common_index = 0
function FoundryGodweaponHuanhuaTemplate:_init(parent)
	self._package_name = "ui_foundry"
    self._com_name = "godweapon_huanhua_template"
    self.parent = parent
    self.foundry_data = game.FoundryCtrl.instance:GetData()
end

function FoundryGodweaponHuanhuaTemplate:OpenViewCallBack()

    self._layout_objs["huanhua_btn"]:AddClickCallBack(function()
        if self.select_avatar_id then
            game.FoundryCtrl.instance:CsArtifactChangeAvatar(self.select_avatar_id)
        end
    end)

    self._layout_objs["n1"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:OpenGodWeaponHHAttr()
    end)

    self._layout_objs["shop_btn"]:AddClickCallBack(function()
        game.ShopCtrl.instance:OpenViewByCateId(135)
    end)

    self:BindEvent(game.FoundryEvent.UpdateGodweaponInfo, function(data)

        local num = self:GetListNum()
        self.ui_list:SetItemNum(num)

        self:SetCombatText()
    end)

    self:BindEvent(game.FoundryEvent.ChangeAvatar, function(data)

        self:SetHuanhuaBtn(false)

       local num = self:GetListNum()
        self.ui_list:SetItemNum(num)
    end)

	self:InitList()

    self:SetDefaultSelect()
end

function FoundryGodweaponHuanhuaTemplate:CloseViewCallBack()
	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end

	if self.role_model then
        self.role_model:DeleteMe()
        self.role_model = nil
    end
end

function FoundryGodweaponHuanhuaTemplate:InitList()

	local career = game.RoleCtrl.instance:GetCareer()
    local cfg = config.artifact_avatar[career]
	local cfg2 = config.artifact_avatar[common_index]
    local num = game.Utils.getTableLength(cfg)
	local num2 = game.Utils.getTableLength(cfg2)
    --local total_num = self:GetDataList()
    local total_num = num + num2


    local data_list = {}
	for k, v in pairs(cfg) do
        table.insert(data_list, v)
	end
    for k, v in pairs(cfg2) do
        table.insert(data_list, v)
    end

	local sort_func = function(a, b)
		return a.id < b.id
	end
	table.sort(data_list, sort_func)
	self.data_list = data_list

	self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/foundry/foundry_godweapon_huanhua_item").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:SetItemNum(total_num)
end

function FoundryGodweaponHuanhuaTemplate:GetDataList()
	return self.data_list
end

function FoundryGodweaponHuanhuaTemplate:SelectItem(index)

    self.select_index = index

	self.ui_list:Foreach(function(v)
		if v:GetIdx() ~= index then
	        v:SetSelect(false)
	    else
	        v:SetSelect(true)
	    end
    end)

    local data = self.foundry_data:GetGodweaponData()
    local id = data.id      --自身本门派神器的武器ID
    local cur_avatar_id = self.foundry_data:GetAvatarId()   --当前选择的武器ID
    local avatar_cfg = self.data_list[index]    --获取选择的武器ID
    local have_flag = self.foundry_data:CheckHaveAvatar(avatar_cfg.id)
    self._layout_objs["gain_way"]:SetVisible(false)
    self._layout_objs["shop_btn"]:SetVisible(true)
    if index == 1 then
        self._layout_objs["gain_way"]:SetVisible(true)
        self._layout_objs["shop_btn"]:SetVisible(false)
        have_flag = true
        if id == 101 then
            avatar_cfg.id = 1100
        elseif id == 201 then
            avatar_cfg.id = 1200
        elseif id == 301 then
            avatar_cfg.id = 1300
        elseif id == 401 then
            avatar_cfg.id = 1400
        else
            avatar_cfg.id = id
        end
    end

    if have_flag and avatar_cfg.id ~= cur_avatar_id then
        self:SetHuanhuaBtn(true)
        self:SetCurSelectAvartar(avatar_cfg.id)
    else
        self:SetHuanhuaBtn(false)
        self:SetCurSelectAvartar(nil)
    end

    self:SetHuanhuaAttr(avatar_cfg, index)

    local model_id = avatar_cfg.model
    if index == 1 then   -- cur_avatar_id < 1500 and index == 1 then
        model_id = model_id + (id%100) - 1
    end
    self:ShowModel(model_id)
end

function FoundryGodweaponHuanhuaTemplate:ShowModel(weapon_id_t)

    if self.role_model then
        self.role_model:DeleteMe()
        self.role_model = nil
    end

    local main_role = game.Scene.instance:GetMainRole()
    local career = game.RoleCtrl.instance:GetCareer()
    local model_id = 100000*career + 10101
    local wing_id = 100000*career + 101
    local hair_id = 10000*career + 1001
    local weapon_id = weapon_id_t --1000*career + 1

    local model_list = {
        [game.ModelType.Body]    = model_id,
        [game.ModelType.Wing]    = wing_id,
        [game.ModelType.Hair]    = hair_id,
        [game.ModelType.Weapon]    = weapon_id,
    }

    for k,v in pairs(model_list) do
        if main_role:GetModelID(k) == nil then 
            return
        end
        local id = main_role:GetModelID(k)
        model_list[k] = (id>0 and id or v)
    end
    model_list[game.ModelType.Weapon] = weapon_id

    local anim = game.ObjAnimName.Idle
    local wing_model_id, wing_anim = main_role:_GetModelID(game.ModelType.Wing)
    if wing_model_id ~= 0 then
        anim = config_help.ConfigHelpModel.GetMountIdleAnimName(wing_anim)
    end

    if self.role_model then
        self.role_model:DeleteMe()
        self.role_model = nil
    end

    self.role_model = require("game/character/model_template").New()
    self.role_model:CreateModel(self._layout_objs["wrapper"], game.BodyType.Role, model_list)
    self.role_model:SetModelChangeCallBack(function(model_type)
        if model_type == game.ModelType.Hair then
            local color_hex = main_role:GetHair()
            self.role_model:UpdateHairColorHex(color_hex)
        end
    end)
    self.role_model:PlayAnim(anim, game.ModelType.Body + game.ModelType.Wing + game.ModelType.Hair +game.ModelType.WeaponSoul)
    self.role_model:SetCameraRotation(9.5,0,0)
    self.role_model:SetPosition(0,-1.8,3.5)
    self.role_model:SetRotation(0,180,0)
end

function FoundryGodweaponHuanhuaTemplate:SetHuanhuaBtn(val)
    self._layout_objs["huanhua_btn"]:SetVisible(val)
end

function FoundryGodweaponHuanhuaTemplate:SetCurSelectAvartar(val)
    self.select_avatar_id = val
end

function FoundryGodweaponHuanhuaTemplate:SetDefaultSelect()

    local default_index = 1
    local cur_avatar_id = self.foundry_data:GetAvatarId()

    for k, v in pairs(self.data_list) do
        if v.id == cur_avatar_id then
            default_index = k
            break
        end
    end

    self:SelectItem(default_index)
end

function FoundryGodweaponHuanhuaTemplate:SetHuanhuaAttr(avatar_cfg, index)

    for k = 1, 3 do

        local attr_info = avatar_cfg.attr[k]
        if attr_info then
            local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_info[1])
            self._layout_objs["attr"..k]:SetText(attr_name..": "..tostring(attr_info[2]))
        else
            self._layout_objs["attr"..k]:SetText("")
        end
    end

    self._layout_objs["equip_name"]:SetText(avatar_cfg.name)
    self._layout_objs["equip_desc"]:SetText(avatar_cfg.desc)

    --特殊加入（默认神器铸造装备）
    if index == 1 then
        local data = self.foundry_data:GetGodweaponData()
        local gw_id = data.id
        local career = math.floor(gw_id/100)
        local gw_cfg = config.artifact_base[career][gw_id]
        self._layout_objs["equip_name"]:SetText(gw_cfg.name)
        self._layout_objs["equip_desc"]:SetText(gw_cfg.desc)
    end
end

function FoundryGodweaponHuanhuaTemplate:SetCombatText()

    local godweapon_data = self.foundry_data:GetGodweaponData()

    if godweapon_data then
        self._layout_objs["combat_txt"]:SetText(godweapon_data.a_combat_power)
    else
        self._layout_objs["combat_txt"]:SetText(0)
    end
end

function FoundryGodweaponHuanhuaTemplate:GetListNum()

    local career = game.RoleCtrl.instance:GetCareer()
    local cfg = config.artifact_avatar[career]
    local num = 0
    for k,v in pairs(cfg) do
        if v.visible == 1 then
            num = num + 1
        end
    end

    local cfg2 = config.artifact_avatar[common_index]
    local num2 = 0
    for k,v in pairs(cfg2) do
        if v.visible == 1 then
            num2 = num2 + 1
        end
    end

    return num+num2
end

return FoundryGodweaponHuanhuaTemplate