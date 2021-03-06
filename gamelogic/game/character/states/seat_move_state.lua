local SeatMoveState = Class()

local _send_dist = 25
local _logic_tile_size = game.LogicTileSize

function SeatMoveState:_init(obj)
	self.obj = obj
	self.start_pos = cc.vec2(0, 0)
	self.target_pos = cc.vec2(0, 0)
	self.target_logic_pos = cc.vec2(0, 0)
	self.dir = cc.vec2(0, 0)
	self.last_send_pos = cc.vec2(0, 0)
end

function SeatMoveState:_delete()

end

function SeatMoveState:StateEnter(x, y, keep_move)
	self.keep_move = keep_move
	self.target_logic_pos.x, self.target_logic_pos.y = x, y

	if self.obj.logic_pos.x == x and self.obj.logic_pos.y == y then
		self.empty_run = true
	else
		self.empty_run = false
		
		self.start_pos.x, self.start_pos.y = self.obj.unit_pos.x, self.obj.unit_pos.y
		self.target_pos.x, self.target_pos.y = game.LogicToUnitPos(x, y)

		local delta = cc.pSub_static(self.target_pos, self.start_pos)
		self.dist = cc.pGetLength(delta)
		self.dir.x, self.dir.y = delta.x / self.dist, delta.y / self.dist
		self.cur_dist = 0

		self.obj:SetDir(self.dir.x, self.dir.y)

		if self.obj:IsClientObj() then
			self.last_send_dist = 0
		end
	end

	self.is_move_attack = self.obj:IsMoveAttack()
	if not self.is_move_attack then
		self.obj:PlayStateAnim()

		if self.obj:IsMainRole() then
			global.EventMgr:Fire(game.ObjStateEvent.SeatMoveState, true)
		end
	end
end

function SeatMoveState:StateUpdate(now_time, elapse_time)

	if self.empty_run then
		-- if not self.keep_move then
		-- 	self.obj:DoIdle()
		-- end
	else
		self.delta_dist = self.obj:GetSpeed() * elapse_time * _logic_tile_size
		self.cur_dist = self.cur_dist + self.delta_dist

		if self.cur_dist < self.dist then
			self.obj:SetUnitPos(self.start_pos.x + self.dir.x * self.cur_dist, self.start_pos.y + self.dir.y * self.cur_dist)

			if self.obj:IsClientObj() then
				self:CheckSendRoleWalk()
			end
		else
			self.obj:SetUnitPos(self.start_pos.x + self.dir.x * self.cur_dist, self.start_pos.y + self.dir.y * self.cur_dist)
			if self.obj.logic_pos.x ~= self.target_logic_pos.x or self.obj.logic_pos.y ~= self.target_logic_pos.y then
				self.obj:SetLogicPos(self.target_logic_pos.x, self.target_logic_pos.y)
			end
			self.empty_run = true
		end
	end
end

function SeatMoveState:StateQuit(next_state)
    if self.obj:IsClientObj() then
		if next_state ~= game.ObjState.Move then
			if self.obj.logic_pos.x ~= self.target_logic_pos.x or self.obj.logic_pos.y ~= self.target_logic_pos.y then
				local x, y = self.obj:GetLogicPosXY()
				self.obj:SendWalkReq(x, y, 7)
			end
		end
	end
end

function SeatMoveState:CheckSendRoleWalk()
	if self.cur_dist < self.last_send_dist then
		return
	end

	self.last_send_dist = self.last_send_dist + _send_dist
	if self.last_send_dist >= self.dist then
		self.last_send_dist = self.dist
	end
	self.last_send_pos.x = self.start_pos.x + self.dir.x * self.last_send_dist
	self.last_send_pos.y = self.start_pos.y + self.dir.y * self.last_send_dist

	local x, y = game.UnitToLogicPos(self.last_send_pos.x, self.last_send_pos.y)
	self.obj:SendWalkReq(x, y, 0)
end

return SeatMoveState
