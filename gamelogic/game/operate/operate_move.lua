
local OperateMove = Class(require("game/operate/operate_base"))

local _logic_tile_size = game.LogicTileSize

function OperateMove:_init()
	self.target_pos = {}
	self.oper_type = game.OperateType.Move
end

function OperateMove:Init(obj, x, y, keep_move, offset_dist, dir_x, dir_y)
    OperateMove.super.Init(self, obj)
    self.target_pos_unit_x, self.target_pos_unit_y = x, y
    self.dir_x, self.dir_y = dir_x, dir_y
	self.offset_dist = (offset_dist or 0) * _logic_tile_size
	self.keep_move = keep_move
end

function OperateMove:Start()
	if not self.obj:CanDoMove() then
		return false
	end

	if self.offset_dist > 0 then
		local dx, dy = self.target_pos_unit_x - self.obj.unit_pos.x, self.target_pos_unit_y - self.obj.unit_pos.y
		local len = cc.pGetLengthXY(dx, dy)
		dx = dx / len
		dy = dy / len

		self.target_pos_unit_x = self.target_pos_unit_x - dx * self.offset_dist
		self.target_pos_unit_y = self.target_pos_unit_y - dy * self.offset_dist
	end

    self.target_pos_logic_x, self.target_pos_logic_y = game.UnitToLogicPos(self.target_pos_unit_x, self.target_pos_unit_y)

	self.obj:DoMove(self.target_pos_unit_x, self.target_pos_unit_y, self.keep_move, self.dir_x, self.dir_y)

	return true
end

function OperateMove:Update(now_time, elapse_time)
	if not self.obj:CanDoMove() then
		return false
	end

    local cur_pos = self.obj:GetLogicPos()
	if cur_pos.x == self.target_pos_logic_x and cur_pos.y == self.target_pos_logic_y then
		return true
	else
		if self.obj:GetCurStateID() ~= game.ObjState.Move then
			return false
		end
	end
end

return OperateMove
