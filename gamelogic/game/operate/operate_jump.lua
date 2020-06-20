
local OperateJump = Class(require("game/operate/operate_base"))

function OperateJump:_init()
	self.from_pos = {}
	self.target_pos = {}
	self.oper_type = game.OperateType.Jump
end

function OperateJump:Init(obj, x, y, fx, fy, mid_list)
    OperateJump.super.Init(self, obj)

    self.from_pos.x, self.from_pos.y = fx, fy
	self.target_pos.x, self.target_pos.y = x, y

	self.mid_list = mid_list
end

function OperateJump:Start()
	self.jump_state = nil

	if not self.obj:CanDoJump() then
		return false
	end
	
	self.start_jump_time = global.Time.now_time + 0.2
	
	return true
end

function OperateJump:Update(now_time, elapse_time)
	if self.start_jump_time then
		if now_time >= self.start_jump_time then
			self.start_jump_time = nil
			self.jump_state = self.obj:DoJump(self.target_pos.x, self.target_pos.y, self.from_pos.x, self.from_pos.y, self.mid_list)
		end
		return
	end

	if self.jump_state then
		if self.jump_state:IsDone() then
			return true
		end

		if self.obj:GetCurStateID() ~= game.ObjState.Jump then
			return false
		end
	end
end

return OperateJump
