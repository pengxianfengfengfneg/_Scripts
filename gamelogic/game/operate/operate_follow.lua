
local OperateFollow = Class(require("game/operate/operate_base"))

local NextFollowTime = 0
local FollowDelta = 0.25

function OperateFollow:_init()
	self.oper_type = game.OperateType.Follow
end

function OperateFollow:Init(obj, target_id, offset)
	OperateFollow.super.Init(self, obj)
    self.target_id = target_id
    self.offset = offset or 5
end

function OperateFollow:Reset()
    self:ClearCurOperate()
    OperateFollow.super.Reset(self)
end

function OperateFollow:Start()
    NextFollowTime = 0
	return true
end

local pDistanceSQ = cc.pDistanceSQ
function OperateFollow:Update(now_time, elapse_time)  
    local target = game.Scene.instance:GetObj(self.target_id)
    if not target then
        return false
    end

    self:UpdateCurOperate()

    if now_time >= NextFollowTime and not self.cur_oper then
        NextFollowTime = now_time + FollowDelta

        local leader_pos = target:GetLogicPos()
        local my_pos = self.obj:GetLogicPos()

        local is_leader_move = (target:GetCurStateID()==game.ObjState.Move)
        local lenSQ = pDistanceSQ(leader_pos, my_pos)

        if lenSQ > self.offset * self.offset then
            self:ClearCurOperate()

            local off_dist = is_leader_move and self.offset * 0.6 or self.offset
            local ux,uy = game.LogicToUnitPos(leader_pos.x, leader_pos.y)
            self.cur_oper = self:CreateOperate(game.OperateType.FindWay, self.obj, ux, uy, self.offset, nil, is_leader_move)

            if not self.cur_oper:Start() then
                self:ClearCurOperate()
            end
        end
    end
end

function OperateFollow:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateFollow:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateFollow
