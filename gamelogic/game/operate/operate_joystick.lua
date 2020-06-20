
local OperateJoystick = Class(require("game/operate/operate_base"))

function OperateJoystick:_init()
	self.oper_type = game.OperateType.Joystick
	self.dir = {}
end

function OperateJoystick:Init(obj, dir_x, dir_y)
    OperateJoystick.super.Init(self, obj)
	self.dir.x = dir_x
	self.dir.y = dir_y
end

function OperateJoystick:Reset()
	self:ClearCurOperate()
    OperateJoystick.super.Reset(self)
end

function OperateJoystick:Start()
	if not self.obj:CanDoMove() then
		return false
	end

	return self:CheckPath()
end

function OperateJoystick:Update(now_time, elapse_time)
	if self.cur_oper then
		local ret = self.cur_oper:Update(now_time, elapse_time)
		if ret ~= nil then
			if not self:CheckPath() then
				return false
			else
				return
			end
		else
			return ret
		end
	end
end

function OperateJoystick:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

function OperateJoystick:CheckPath()
	local is_valid, nx, ny = game.Scene.instance:FindPathByUnit(self.obj.unit_pos, self.dir, 50)
	if is_valid > 1 then
		self.cur_oper = self:CreateOperate(game.OperateType.Move, self.obj, nx, ny, true)
		return self.cur_oper:Start()
	end

	is_valid, nx, ny = game.Scene.instance:FindPathWithDirOffset(self.obj.unit_pos, self.dir)
	if is_valid then
		self:ClearCurOperate()
		self.cur_oper = self:CreateOperate(game.OperateType.Move, self.obj, nx, ny, true, 0, self.dir.x, self.dir.y)
		return self.cur_oper:Start()
	end

	self.obj:DoMove(self.obj.unit_pos.x, self.obj.unit_pos.y, true, self.dir.x, self.dir.y)
	return true
end

return OperateJoystick
