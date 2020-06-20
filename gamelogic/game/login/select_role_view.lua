
local SelectRoleView = Class(game.BaseView)
local bit = Class(require("game/main/Bit"))

local create_role_cfg = {
	[game.Career.GaiBang] = {
		pos = {116.459, 59.183, 47.633},
		rot = {0, 0, 0},
	},
	[game.Career.TianShan] = {
		pos = {217.832, 72.675, 67.55},
		rot = {0, 0, 0},
	},
	[game.Career.XiaoYao] = {
		pos = {372.286, 59.247, 94.793},
		rot = {0, 0, 0},
	},
	[game.Career.EMei] = {
		pos = {652.21, 55.562, 264.024},
		rot = {0, 0, 0},
	},
}

function SelectRoleView:_init(ctrl)
	SelectRoleView.instance = self

	self._package_name = "ui_login"
    self._com_name = "select_role_view"
	self._cache_time = 60
    self._mask_type = game.UIMaskType.None
	self._view_level = game.UIViewLevel.Standalone
	self.ctrl = ctrl
	self.data = ctrl:GetData()

	bit:init()
end

function SelectRoleView:_delete()
	SelectRoleView.instance = nil
end

function SelectRoleView:OpenViewCallBack()
	game.RenderUnit:SetUICameraClearColor(true)
	self._layout_objs["bg"]:SetVisible(false)
	self._layout_objs["group"]:SetVisible(false)

	self._layout_objs["btn_ret"]:AddClickCallBack(function()
		game.GameLoop:ChangeState(game.GameLoop.State.SelectServer)
	end)
	
	self._layout_objs["btn_start"]:AddClickCallBack(function()
		local role_info = game.LoginCtrl.instance:GetRoleInfo(self.role_index)
		if role_info then
			self._layout_objs["btn_start"]:SetEnable(false)
			self.ctrl:SendSelectRoleLogin(role_info.role_id)
			self.role_info = role_info
		end
	end)

	--self._layout_objs["btn_delete"]:SetVisible(false)
	--删除角色
	self._layout_objs["btn_delete"]:AddClickCallBack(function()
		game.LoginCtrl.instance:OnDelRoleResp(self.role_index,1)
	end)

	--撤销删除角色
	self._layout_objs["btn_cancel_del"]:AddClickCallBack(function()
		game.LoginCtrl.instance:OnDelRoleResp(self.role_index,0)
	end)

	self.touch_pos_x = 0
	self._layout_objs["touch_area"]:SetTouchEnable(true)
	self._layout_objs["touch_area"]:SetTouchBeginCallBack(function(x, y)
		self.touch_pos_x = x
	end)
	self._layout_objs["touch_area"]:SetTouchMoveCallBack(function(x, y)
		local obj = self.obj_list[self.role_index]
		if obj then
			local model_obj = obj:GetModel(game.ModelType.Body)
			if model_obj then
				local rx, ry, rz = model_obj:GetRoot():GetRotation()
				model_obj:GetRoot():SetRotation(rx, ry - (x - self.touch_pos_x) * 0.2, rz)
			end
		end
		self.touch_pos_x = x
	end)
	self._layout_objs["touch_area"]:SetTouchEndCallBack(function(x, y)
		
	end)

	local last_index = 1
	local last_login_time = 0
	for i=1,4 do
		local item = self._layout_objs["role_" .. i]
		local role_info = self.data:GetRoleInfo(i)
		if role_info then
			if role_info.last_login_time > last_login_time then
				last_login_time = role_info.last_login_time
				last_index = i
			end
			item:GetController("c1"):SetSelectedIndexEx(1)
			item:GetChild("name"):SetText(role_info.name)
			item:GetChild("lv"):SetText(string.format(config.words[1006], role_info.level))
			item:GetChild("career_img"):SetSprite("ui_common", "career" .. role_info.career)

			local cfg = config.role_icon[role_info.icon]
            if cfg then
				item:GetChild("head_img"):SetSprite("ui_headicon", cfg.icon, true)
            end
		else
			item:GetController("c1"):SetSelectedIndexEx(0)
		end
	end

	self.scene_loaded = false
	self.show_group_time = 0
	self.obj_list = {}
	self.obj_load_list = {}
	self.obj_load_dirty = false
	self:CreateCamera()

    local control = self:GetRoot():AddControllerCallback("c1", function(idx)
        self:RefreshRole(idx + 1)
    end)
    control:SetSelectedIndexEx(last_index - 1)
end

function SelectRoleView:DelRole()
	self._layout_objs["btn_start"]:SetEnable(false)
	self._layout_objs["btn_delete"]:SetVisible(false)
	self._layout_objs["btn_cancel_del"]:SetVisible(true)

	local msg_box = game.GameMsgCtrl.instance:CreateMsgBoxSec(config.words[102], "角色三天后删除")
	msg_box:SetOkBtn(function()
		msg_box:DeleteMe()
	end)
	msg_box:Open()
end

function SelectRoleView:CancelDelRole()
	self._layout_objs["btn_cancel_del"]:SetVisible(false)
	self._layout_objs["btn_delete"]:SetVisible(true)
	self._layout_objs["btn_start"]:SetEnable(true)
end

function SelectRoleView:CloseViewCallBack()
	self:Clear()
end

function SelectRoleView:Update(now_time, elapse_time)
	if not self.scene_loaded then
		if self.ctrl:IsLoginSceneLoaded() then
			self.scene_loaded = true
			self.show_group_time = now_time
			local map = self.ctrl:GetLoginMap()
			if map then
			    map:EnableRealTimeShadow(false)
			    local obj = self.obj_list[self.role_index]
			    if obj then
			    	map:SetRealTimeShadowTarget(obj:GetRoot())
				end
			end
		end
	end

	if self.show_group_time > 0 then
		if now_time > self.show_group_time then
			self.show_group_time = 0
			self._layout_objs["group"]:SetVisible(true)
			game.RenderUnit:SetUICameraClearColor(false)
		end
	end

	if self.obj_load_dirty and self.obj_load_list[self.role_index] then
		self.obj_load_dirty = false

		for k,v in pairs(self.obj_list) do
			if k ~= self.role_index then
				v:SetVisible(false)
			end
		end
	end
end

function SelectRoleView:SetEnable(val)
	if self:IsOpen() then
		self._layout_objs["btn_start"]:SetEnable(val)
	end
end

function SelectRoleView:RefreshRole(index)
    self.role_index = index

	local role_info = self.data:GetRoleInfo(index)
	if role_info ~= nil then
		local role_del_state = bit:_rshift(role_info.state,5)
		local is_role_del = bit:_and(role_del_state,1)
		print("is_role_del",is_role_del)
		if is_role_del == 1 then
			self._layout_objs["btn_delete"]:SetVisible(false)
			self._layout_objs["btn_cancel_del"]:SetVisible(true)
			self._layout_objs["btn_start"]:SetEnable(false)
		else
			self._layout_objs["btn_delete"]:SetVisible(true)
			self._layout_objs["btn_cancel_del"]:SetVisible(false)
			self._layout_objs["btn_start"]:SetEnable(true)
		end
	end

	if role_info then
		local career = role_info.career

		local camera = self.ctrl:GetCameraCreate(career)
		if camera then
			camera.transform:AddChild(self.camera, game.ModelNodeName.Camera)
			local model_ctrl = camera:GetComponent(ModelController)
			if model_ctrl then
				model_ctrl:PlayAnim(game.ObjAnimName.ShowIdle, game.ObjAnimHash[game.ObjAnimName.ShowIdle], 1, 0)
			end
		end

		local cfg = config.career_init[career]
		if cfg then
			self._layout_objs["desc"]:SetSprite("ui_login", string.format("a%d_%d", cfg.atk_type, cfg.atk_dist))
		end

		local obj = self.obj_list[index]
		if not obj then
			obj = self:CreateObj()
			self.obj_list[index] = obj
			
			local weapon_model_id, is_two = config_help.ConfigHelpModel.GetWeaponID(role_info.career, role_info.artifact)
			obj:SetModelID(game.ModelType.Body, config_help.ConfigHelpModel.GetBodyID(role_info.career, role_info.fashion))
			obj:SetModelID(game.ModelType.Weapon, weapon_model_id, career)
			if is_two and weapon_model_id < 4008 then
				obj:SetModelID(game.ModelType.Weapon2, weapon_model_id)
			end
			obj:SetModelID(game.ModelType.Hair, config_help.ConfigHelpModel.GetHairID(role_info.career, role_info.hair))
			obj:SetModelChangeCallBack(function(model_type)
				if model_type == game.ModelType.Body then
					-- 相机是创角相机，角色模型是场景模型，不匹配，需要调整
					local body_model = obj:GetModel(model_type)
					if body_model then
						body_model:SetRotation(0, 180, 0)
					end
				end
			end)

			local r,g,b = config_help.ConfigHelpModel.GetHairColor(role_info.hair)
			obj:SetMatPropertyColor(game.MaterialProperty.Color, r/255, g/255, b/255, 1, game.ModelType.Hair)

			obj:PlayLayerAnim(game.ModelType.Body + game.ModelType.Hair, game.ObjAnimName.Idle, 1, 0, true)
		end

		for k, v in pairs(self.obj_list) do
			v:SetVisible(k == index)
		end
		
		if create_role_cfg[career] then
			local pos = create_role_cfg[career].pos
			local rot = create_role_cfg[career].rot
			obj:SetPosition(pos[1], pos[2], pos[3])
			obj:SetRotation(rot[1], rot[2], rot[3])
		end

		local map = self.ctrl:GetLoginMap()
		if map then
			map:SetRealTimeShadowTarget(obj:GetRoot())
		end

		self.obj_load_dirty = true
	else
		game.GameLoop:ChangeState(game.GameLoop.State.CreateRole)
	end
end

function SelectRoleView:CreateObj()
	local draw_obj = game.GamePool.DrawObjPool:Create()
	draw_obj:Init(game.BodyType.Role)
	draw_obj:SetAlwaysAnim(true)
	draw_obj:SetLayer(game.LayerName.MainSceneObject)
	game.RenderUnit:AddToObjLayer(draw_obj)
	return draw_obj
end

function SelectRoleView:CreateCamera()
	local main_cam = game.RenderUnit:GetSceneCameraObj()
	local clone_camera = UnityEngine.GameObject.Instantiate(main_cam)

    local physics_raycaster = clone_camera:GetComponent(UnityEngine.EventSystems.PhysicsRaycaster)
    if physics_raycaster then
        UnityEngine.GameObject.Destroy(physics_raycaster)
    end
    local cam_com = clone_camera:GetComponent(UnityEngine.Camera)
    if cam_com then
        cam_com.depth = 30
        cam_com.clearFlags = 2
        cam_com.allowMSAA = false
    end
    clone_camera.transform:ResetPRS()
    clone_camera:SetVisible(true)

    self.camera = clone_camera

	game.RenderUnit:SetSceneCameraEnable(false)
end

function SelectRoleView:Clear()
	if self.obj_list then
		for k,v in pairs(self.obj_list) do
			v:DeleteMe()
		end
		self.obj_list = nil
	end

	if self.camera then
		UnityEngine.GameObject.Destroy(self.camera)
		self.camera = nil
	end

	game.RenderUnit:SetSceneCameraEnable(true)
end

--获取进入游戏的玩家信息
function SelectRoleView:GetRoleInfo()
	return self.role_info
end

game.SelectRoleView = SelectRoleView

return SelectRoleView
