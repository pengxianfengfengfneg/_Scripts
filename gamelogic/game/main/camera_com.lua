local CameraCom = Class(game.UITemplate)

local _x_factor = 0
local _y_factor = 0

function CameraCom:_init()
	self.cam_rot_enable = true
end

function CameraCom:_delete()
	
end

function CameraCom:OpenViewCallBack()
	self.touch_move = false
	self.touch_move_time = 0

	self.last_touch_pos = cc.vec2(0, 0)
	self.joystick_info = {
		com = self._layout_objs["n0"],
		node = self._layout_objs["n1"],
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

function CameraCom:CloseViewCallBack()

end

function CameraCom:Update(now_time, elapse_time)
	if self.touch_info.touch_mode == 1 then
		local cam = game.Scene.instance:GetCamera()
		if cam then
			cam:ChangeFollowRotation(self.touch_info.touch_dy * _x_factor, self.touch_info.touch_dx * _y_factor)
		end
	end
end

function CameraCom:OnJoystickTouchBegin(x, y, double, touch_id)
	if not self.cam_rot_enable then
		return
	end

	if not self.touch_info.touch_id then
		x, y = self._layout_root:ToLocalPos(x, y)

		self.touch_info.touching = true
		self.touch_info.touch_mode = 0
		self.touch_info.touch_time = global.Time.now_time
		self.touch_info.touch_x = x
		self.touch_info.touch_y = y
		self.touch_info.touch_id = touch_id
	end
end

function CameraCom:OnJoystickTouchMove(x, y, double, touch_id)
	if self.touch_info.touch_id ~= touch_id then
		return
	end

	x, y = self._layout_root:ToLocalPos(x, y)

	if self.touch_info.touch_mode == 0 then
		local dx = x - self.touch_info.touch_x
		local dy = y - self.touch_info.touch_y
		local len = math.sqrt(dx * dx + dy * dy)

		if len > 6 then
			self.touch_info.touch_mode = 1
			self.joystick_info.com:SetVisible(true)
	        self.joystick_info.node:SetVisible(true)
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
	end
end

function CameraCom:OnJoystickTouchEnd(x, y, double, touch_id)
	if self.touch_info.touch_id ~= touch_id then
		return
	end
	self.touch_info.touch_id = nil
	self.touch_info.touching = false
	if self.touch_info.touch_mode == 1 then
		self.touch_info.touch_mode = 0
		self.joystick_info.com:SetVisible(false)
	    self.joystick_info.node:SetVisible(false)
		self.joystick_info.com:Center()
		self.joystick_info.node:Center()
	end
end

function CameraCom:SetCameraRotEnable(val)
	self.cam_rot_enable = val
end

function CameraCom:SetCameraRotState(val)
	self:SetVisible(false)
	if val == 0 then
		_x_factor = 0
		_y_factor = 4
	elseif val == 1 then
		_x_factor = 0
		_y_factor = 4
	elseif val == 2 then
		_x_factor = 0.3
		_y_factor = 4
	elseif val == 3 then
		_x_factor = 0.3
		_y_factor = 4
	end
end

return CameraCom
