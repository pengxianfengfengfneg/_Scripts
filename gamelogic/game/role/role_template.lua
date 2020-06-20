local RoleTemplate = Class(game.UITemplate)

local handler = handler
local config_skill = config.skill

local RoleFuncConfig = require("game/role/role_func_config")

function RoleTemplate:_init(view, ctrl)
    self.parent_view = view

    self.ctrl = ctrl
end

function RoleTemplate:OpenViewCallBack()
	self:Init()
	self:InitBtns()
	self:InitEquipList()
	
	self:SetRoleExp()
    self:RefreshCombatPower()
    self:InitRoleModel()

	self:RegisterAllEvents()
end

function RoleTemplate:CloseViewCallBack()
   	for i, v in pairs(self.equip_list or {}) do
        v:DeleteMe()
    end

    if self.role_model then
        self.role_model:DeleteMe()
        self.role_model = nil
    end
end

function RoleTemplate:RegisterAllEvents()

    local events = {
    	{game.RoleEvent.LevelChange, handler(self,self.SetRoleExp)},
        {game.RoleEvent.WearEquip, handler(self,self.RefreshEquip)},
        {game.RoleEvent.UpdateMainRoleInfo, handler(self,self.RefreshCombatPower)},
        {game.FashionEvent.SwitchHairId, handler(self,self.OnSwitchHairId)},
        {game.FashionEvent.ChangeHair, handler(self,self.OnChangeHair)},
        {game.FoundryEvent.EquipRefresh, handler(self,self.RefreshEquipList)},
    }

    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function RoleTemplate:Init()
	self.txt_exp = self._layout_objs["exp_com/txt_exp"]
    self.txt_fight = self._layout_objs["role_fight_com/txt_fight"]
    self.txt_lv = self._layout_objs["exp_com/txt_lv"]
    self.img_exp = self._layout_objs["exp_com/img_exp"]
    
end

function RoleTemplate:InitBtns()
	local btn_look = self._layout_objs["role_fight_com/btn_look"]
    btn_look:AddClickCallBack(function()
        self.ctrl:OpenRoleAttrView()
    end)

    local btn_lvup = self._layout_objs["exp_com/btn_lvup"]
    btn_lvup:AddClickCallBack(function()
        self.ctrl:SendLevelUp()
    end)
    self.btn_lvup = btn_lvup

    local btn_change = self._layout_objs["btn_change"]
    btn_change:AddClickCallBack(function()
        game.FoundryCtrl.instance:CsEquipOneKeyWear()
        -- self:FireEvent(game.GuideEndEvent.ClickButton, {click_btn_name = "ui_role/role_view/role_template/btn_change"})
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_role/role_view/role_template/btn_change"})
        game.ViewMgr:FireGuideEvent()
    end)

    
    local list_funcs = self._layout_objs["list_funcs"]
    list_funcs.foldInvisibleItems = true

    local item_num = list_funcs:GetItemNum()
    for i=1,item_num do
        local child = list_funcs:GetChildAt(i-1)
        local child_name = child.name

        local cfg = RoleFuncConfig[child_name]
        if cfg then
            cfg.node = child
            cfg.node_name = child_name
        else
            child:SetVisible(false)
        end
    end

    for k,v in pairs(RoleFuncConfig) do  
        if v.node then     
            v.node:AddClickCallBack(function()
                v.click_func()
            end)

            for _,cv in ipairs(v.check_events or {}) do
                self:BindEvent(cv,function()
                    self:DoCheckFunc(v)
                end)
            end
        end

        self:DoCheckFunc(v)
    end

    if game.IsZhuanJia then
        list_funcs:SetVisible(false)
    end
end

function RoleTemplate:DoCheckFunc(cfg)
    if cfg.node then
        local is_open = cfg.check_open_func()
        cfg.node:SetVisible(is_open)
        if is_open then
            self:SetFuncRedPoint(cfg.node, cfg.check_red_func())
        end
    end
end

function RoleTemplate:SetFuncRedPoint(node, is_red)
    game_help.SetRedPoint(node, is_red)
end

function RoleTemplate:InitEquipList()
    self.equip_list = {}
    for i = 1, 8 do
        local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(i)
        local equip_item = require("game/bag/item/goods_item").New()
        table.insert(self.equip_list, equip_item)
        local equip_item_obj = self._layout_objs["equip_left/equip" .. i]
        local equip_name_obj = self._layout_objs["equip_left/name" .. i]
        if not equip_item_obj then
        	equip_item_obj = self._layout_objs["equip_right/equip" .. i]
        	equip_name_obj = self._layout_objs["equip_right/name" .. i]
        end

        equip_item:SetVirtual(equip_item_obj)
        equip_item:Open()
        equip_item:SetShowTipsEnable(true)

        if equip_info and equip_info.id ~= 0 then

            equip_item:SetItemInfo({ id = equip_info.id })
            equip_item:SetShowTipsEnable(true)
            equip_name_obj:SetText(config.goods[equip_info.id].name)
            equip_item:AddClickEvent(function()
                game.BagCtrl.instance:OpenWearEquipInfoView(equip_info)
            end)
        else
            equip_item:ResetItem()
            equip_name_obj:SetText(config.words[1222])
            local image = tostring(i)
            equip_item:SetItemImage(image)
            equip_item:AddClickEvent(function()
            end)
        end
    end

    self:InitGodweapon()
end

function RoleTemplate:InitGodweapon()

    local equip_info = game.FoundryCtrl.instance:GetData():GetGodweaponData()

    if equip_info and equip_info.id > 0 then
        local equip_item_obj = self._layout_objs["equip_left/equip9"]
        local equip_name_obj = self._layout_objs["equip_left/name9"]
        equip_item_obj:SetVisible(true)
        equip_name_obj:SetVisible(true)
        local equip_item = require("game/bag/item/goods_item").New()
        table.insert(self.equip_list, equip_item)
        equip_item:SetVirtual(equip_item_obj)
        equip_item:Open()
        equip_item:SetShowTipsEnable(true)

        local gw_id = equip_info.id
        local career = math.floor(gw_id/100)
        local gw_cfg = config.artifact_base[career][gw_id]
        local item_id = gw_cfg.item_id
        equip_item:SetItemInfo({ id = item_id})
        equip_name_obj:SetText(config.goods[item_id].name)
        equip_item:AddClickEvent(function()
            game.BagCtrl.instance:OpenWearGodweaponInfoView(equip_info)
        end)
    end
end


function RoleTemplate:SetRoleExp()
    local level = self.ctrl:GetRoleLevel()
    
    local lv_cfg = config.level[level] or {exp=0}

    local exp = self.ctrl:GetRoleExp()
    local upgrade_exp = lv_cfg.exp

    self.txt_lv:SetText(level)
    self.txt_exp:SetText(exp .. "/" .. upgrade_exp)
    self.btn_lvup:SetVisible(exp >= upgrade_exp)
    self.img_exp:SetFillAmount(exp / upgrade_exp)

    if upgrade_exp <= 0 then
        self.txt_exp:SetText(config.words[2853])
    end
end

function RoleTemplate:RefreshEquip(changes)
    for i, v in pairs(changes) do
        self.equip_list[v.equip.pos]:SetItemInfo({ id = v.equip.id })
        local equip_name = self._layout_objs["equip_left/name" .. v.equip.pos]
        if not equip_name then
            equip_name = self._layout_objs["equip_right/name" .. v.equip.pos]
        end
        equip_name:SetText(config.goods[v.equip.id].name)
    end
end

function RoleTemplate:RefreshCombatPower()
    local power = self.ctrl:GetCombatPower()
    self.txt_fight:SetText(power)
end

function RoleTemplate:InitRoleModel()
    if self.role_model then return end

    local main_role = game.Scene.instance:GetMainRole()

    local model_list = {
        [game.ModelType.Body]    = 110101,
        [game.ModelType.Wing]    = 100101,
        [game.ModelType.Hair]    = 11001,
        [game.ModelType.Weapon]    = 1001,
        [game.ModelType.WeaponSoul]    = 1,
    }

    for k,v in pairs(model_list) do
        local id = main_role:GetModelID(k)
        model_list[k] = (id>0 and id or v)
    end

    self.role_model = require("game/character/model_template").New()
    self.role_model:CreateModel(self._layout_objs["wrapper"], game.BodyType.Role, model_list)
    self.role_model:SetModelChangeCallBack(function(model_type)
        if model_type == game.ModelType.Hair then
            local color_hex = main_role:GetHair()
            self.role_model:UpdateHairColorHex(color_hex)
        end
    end)
    self.role_model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.Body + game.ModelType.Wing + game.ModelType.Hair)
    self.role_model:SetCameraRotation(9.5,0,0)
    self.role_model:SetPosition(0,-1.8,3.5)
    self.role_model:SetRotation(0,180,0)
end

function RoleTemplate:PlayTransition()
    self:GetRoot():PlayTransition("t0")
end

function RoleTemplate:OnActived(val)
	if val then
		self:PlayTransition()
	end
end

function RoleTemplate:OnClickFunc(name)
    
end

function RoleTemplate:OnSwitchHairId(hair_id)
    local hair_cfg = config.hair_style[hair_id]
    local model_id = hair_cfg.model_id
    self.role_model:SetModel(game.ModelType.Hair, model_id)
    self.role_model:UpdateHairColorHex(hair_id)
end

function RoleTemplate:OnChangeHair(role_id, hair_id)
    self.role_model:UpdateHairColorHex(hair_id)
end

function RoleTemplate:RefreshEquipList()

    for i = 1, 8 do
        local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(i)
        local equip_item = self.equip_list[i]

        local equip_name_obj = self._layout_objs["equip_left/name" .. i]
        if not equip_name_obj then
            equip_name_obj = self._layout_objs["equip_right/name" .. i]
        end

        if equip_info and equip_info.id ~= 0 then

            equip_item:SetItemInfo({ id = equip_info.id })
            equip_item:SetShowTipsEnable(true)
            equip_name_obj:SetText(config.goods[equip_info.id].name)
            equip_item:AddClickEvent(function()
                game.BagCtrl.instance:OpenWearEquipInfoView(equip_info)
            end)
        else
            equip_item:ResetItem()
            equip_name_obj:SetText(config.words[1222])
            local image = tostring(i)
            equip_item:SetItemImage(image)
            equip_item:AddClickEvent(function()
            end)
        end
    end
end

return RoleTemplate
