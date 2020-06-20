local BlindState = Class()

local _send_dist = 25
local _logic_tile_size = game.LogicTileSize

function BlindState:_init(obj)
    self.start_pos = cc.vec2(0, 0)
    self.target_pos = cc.vec2(0, 0)
    self.target_logic_pos = cc.vec2(0, 0)
    self.dir = cc.vec2(0, 0)
    self.last_send_pos = cc.vec2(0, 0)
	self.obj = obj
end

function BlindState:_delete()
end

function BlindState:StateEnter()
    self.finish_move = true
    self.next_move_time = 0
end

function BlindState:StateUpdate(now_time, elapse_time)
    if self.finish_move then
        if now_time > self.next_move_time then
            self:StartBlindMove()
        end
    else
        local delta_dist = self.obj:GetSpeed() * elapse_time * _logic_tile_size
        self.cur_dist = self.cur_dist + delta_dist

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
            if self.obj:IsClientObj() then
                self.obj:SendWalkReq(self.target_logic_pos.x, self.target_logic_pos.y, 7)
            end
            self.finish_move = true
            self.next_move_time = now_time + 1.5
            self.obj:PlayAnim(game.ObjAnimName.Idle)
        end
    end
end

function BlindState:StateQuit()
    if self.obj:IsClientObj() then
        if self.obj.logic_pos.x ~= self.target_logic_pos.x or self.obj.logic_pos.y ~= self.target_logic_pos.y then
            local x, y = self.obj:GetLogicPosXY()
            self.obj:SendWalkReq(x, y, 7)
        end
    end
end

function BlindState:CheckSendRoleWalk()
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

function BlindState:StartBlindMove()
    self.dir.x, self.dir.y = cc.pNormalizeV(math.random(-100, 100) * 0.01, math.random(-100, 100) * 0.01)
    self.dist, self.target_logic_pos.x, self.target_logic_pos.y = self.obj.scene:FindPath(self.obj.logic_pos, self.dir, math.random(5, 10))
    self.start_pos.x, self.start_pos.y = self.obj.unit_pos.x, self.obj.unit_pos.y
    self.target_pos.x, self.target_pos.y = game.LogicToUnitPos(self.target_logic_pos.x, self.target_logic_pos.y)
    self.dist = cc.pGetDistance(self.start_pos, self.target_pos)

    if self.dist > 1 then
        self.finish_move = false
        self.cur_dist = 0
        self.last_send_dist = 0
        self.obj:SetDir(self.dir.x, self.dir.y)
        self.obj:PlayAnim(game.ObjAnimName.Run)
    end
end

return BlindState
