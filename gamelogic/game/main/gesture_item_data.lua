local GestureItem = Class(game.UITemplate)

local _z_factor = 3

function GestureItem:_init()
	self.cam_rot_enable = true
	self.can_touch_terrain = true

	self.screen_height = UnityEngine.Screen.height
end

function GestureItem:_delete()
	
end

function GestureItem:OpenViewCallBack()
	self.touch_move = false
	self.touch_move_time = 0
	
	self.last_touch_pos = cc.vec2(0, 0)
	self.joystick_info = {
		com = self._layout_objs["joystick_bg"],
		node = self._layout_objs["joystick_node"],
		center_pos = cc.vec2(65, 65),
		radius = 65,
		new_dir = cc.vec2(0, 0),
		pre_dir = cc.vec2(0, 0),
		next_move_time = 0,
	}
	
	self.joystick_info.com:SetVisible(false)
	self.joystick_info.node:SetVisible(false)

	self.touch_info = {}

	self._layout_root:SetTouchBeginCallBack(function(x, y, is_double, touch_id)
		self:OnJoystickTouchBegin(x, y, is_double, touch_id)
    end)

	self._layout_root:SetTouchMoveCallBack(function(x, y, is_double, touch_id)
		self:OnJoystickTouchMove(x, y, is_double, touch_id)
    end)

	self._layout_root:SetTouchEndCallBack(function(x, y, is_double, touch_id)
		self:OnJoystickTouchEnd(x, y, is_double, touch_id)
    end)
end

function GestureItem:CloseViewCallBack()

end

function GestureItem:Update(now_time, elapse_time)
	if game.__DEBUG__ and game.Platform == "win" then
		if UnityEngine.Input.GetAxis("Mouse ScrollWheel") ~= 0 then
			local cam = game.Scene.instance:GetCamera()
			if cam then
				cam:ChangeFollowDist(-UnityEngine.Input.GetAxis("Mouse ScrollWheel") * _z_factor)
			end
			return
		end
	end
end

function GestureItem:OnClick(x, y)
	if self.touch_move_time == global.Time.now_time then
		return
	end

	local main_role = game.Scene.instance:GetMainRole()
	local cam = game.Scene.instance:GetCamera()
	if not main_role or not cam then
		return
	end

	y = self.screen_height - y

	local eff = self:CreateUIEffect(self._layout_objs["graph"], "effect/ui/ui_click.ab")
	local nx, ny = self._layout_objs["graph"]:ToLocalPos(x, y)
	eff:SetPosition(nx, ny, 0)

	local id = cam:CheckRaycastObj(x, y, 1000, game.LayerMask.ObjCollider)
	if id ~= 0 then
		local obj = game.Scene.instance:GetObj(id)
		if obj then
			obj:OnClick()
			return
		end
	end

	local result, wx, wy, wz = cam:Raycast(x, y, 1000, game.LayerMask.Height)
	if result and self.can_touch_terrain then
		if not self.callback or self.callback() then
			if not main_role:CanDoMove(true) then
				game.MarryProcessCtrl.instance:CheckCanDonwn()
				return
			end
			main_role:GetOperateMgr():DoFindWay(wx, wz)
		end
	end
end

function GestureItem:OnJoystickTouchBegin(x, y, double, touch_id)
	if not self.touch_info.touch_id then
		x, y = self._layout_root:ToLocalPos(x, y)

		self.touch_info.touching = true
		self.touch_info.touch_id = touch_id
		self.touch_info.touch_mode = 0
		self.touch_info.touch_time = global.Time.now_time
		self.touch_info.touch_x = x
		self.touch_info.touch_y = y
	end
end

function GestureItem:OnJoystickTouchMove(x, y, double, touch_id)
	if self.touch_info.touch_id ~= touch_id then
		return
	end

	x, y = self._layout_root:ToLocalPos(x, y)

	if self.touch_info.touch_mode == 0 then
		local dx = x - self.touch_info.touch_x
		local dy = y - self.touch_info.touch_y
		local len = math.sqrt(dx * dx + dy * dy)

		if len > 30 then
			self.touch_info.touch_mode = 1
			self.joystick_info.center_pos.x = self.touch_info.touch_x
			self.joystick_info.center_pos.y = self.touch_info.touch_y
			self.joystick_info.com:SetVisible(true)
			self.joystick_info.node:SetVisible(true)
			--self.joystick_info.com:SetPosition(x, y)
			--self.joystick_info.node:Center()
			--self.joystick_info.com:SetAlpha(1.0)
			local main_role = game.Scene.instance:GetMainRole()
		    if main_role then
		    	main_role:CanDoMove(true)
			end
		end
	end

	if self.touch_info.touch_mode == 1 then
		local dx = x - self.joystick_info.center_pos.x
		local dy = y - self.joystick_info.center_pos.y
		local len = math.sqrt(dx * dx + dy * dy)

		if len > self.joystick_info.radius then
			self.joystick_info.center_pos.x = x - self.joystick_info.radius * dx / len
			self.joystick_info.center_pos.y = y - self.joystick_info.radius * dy / len
			self.joystick_info.com:SetPosition(self.joystick_info.center_pos.x, self.joystick_info.center_pos.y)
			self.joystick_info.node:SetPosition(self.joystick_info.center_pos.x + self.joystick_info.radius * dx / len, self.joystick_info.center_pos.y + self.joystick_info.radius * dy / len)

			--self.joystick_info.node:SetPosition(self.joystick_info.radius + self.joystick_info.radius * dx / len, self.joystick_info.radius + self.joystick_info.radius * dy / len)
		else
			self.joystick_info.node:SetPosition(dx + self.joystick_info.center_pos.x, dy + self.joystick_info.center_pos.y)
		end

		if dx > 45 then
			dx = 1
		elseif dx < -45 then
			dx = -1
		else
			dx = 0
		end

		if dy > 20 then
			dy = 1
		elseif dy < -20 then
			dy = -1
		else
			dy = 0
		end

		self.touch_info.touch_dx = dx
		self.touch_info.touch_dy = dy

		self.joystick_info.new_dir.x, self.joystick_info.new_dir.y = cc.pNormalizeV(dx / len, dy / len)
	    if self.joystick_info.next_move_time < global.Time.now_time and
	        not cc.pFuzzyEqual(self.joystick_info.new_dir, self.joystick_info.pre_dir, 0.0001) then
	        self.joystick_info.pre_dir.x = self.joystick_info.new_dir.x
	        self.joystick_info.pre_dir.y = self.joystick_info.new_dir.y
	        self.joystick_info.next_move_time = global.Time.now_time + 0.01
		    local main_role = game.Scene.instance:GetMainRole()
	        if main_role then
	        	if not self.callback or self.callback() then
	        		local nx, ny = game.Scene.instance:GetCamera():CameraToWorldDir2D(self.joystick_info.new_dir.x, -self.joystick_info.new_dir.y)
		            nx, ny = cc.pNormalizeV(nx, ny)
		            main_role:GetOperateMgr():DoJoystick(nx, ny)
	        	end
	        end
	    end
	end
end

function GestureItem:OnJoystickTouchEnd(x, y, double, touch_id)
	if self.touch_info.touch_id ~= touch_id then
		return
	end

	self.touch_info.touch_id = nil
	self.touch_info.touching = false
	if self.touch_info.touch_mode == 1 then
		local main_role = game.Scene.instance:GetMainRole()
	    if main_role then
	    	if main_role:GetCurStateID() == game.ObjState.Move then
		        main_role:GetOperateMgr():DoStop()
	    	end
	    end
		self.joystick_info.new_dir.x, self.joystick_info.new_dir.y = 0, 0
		self.joystick_info.pre_dir.x, self.joystick_info.pre_dir.y = 0, 0
		--self.joystick_info.com:SetAlpha(0.5)
		--self.joystick_info.com:SetPosition(180, 900)
		self.joystick_info.com:SetVisible(false)
		self.joystick_info.node:SetVisible(false)
		self.joystick_info.com:Center()
		self.joystick_info.node:Center()
		return true
	else
		return false
	end
end

function GestureItem:SetClickTerrainEnable(val)
	self.can_touch_terrain = val
end

function GestureItem:SetCameraRotEnable(val)
	self.cam_rot_enable = val
end

function GestureItem:SetCameraRotState(val)
	if val == 0 then
		_z_factor = 0
	elseif val == 1 then
		_z_factor = 0
	elseif val == 2 then
		_z_factor = 0
	elseif val == 3 then
		_z_factor = 3
	end
end

function GestureItem:SetGestureCallBack(callback)
	self.callback = callback
end

return GestureItem
