local OperateHangWeaponSoul = Class(require("game/operate/operate_base"))

local _follow_offset = {x = 0, y = 1}
local _follow_dist = 1

function OperateHangWeaponSoul:_init()
    self.next_time = 0
    self.oper_type = game.OperateType.HangWeaponSoul
end

function OperateHangWeaponSoul:Reset()
    self:ClearCurOperate()
    OperateHangWeaponSoul.super.Reset(self)
end

function OperateHangWeaponSoul:Start()
    self.status = 0
    return true
end

function OperateHangWeaponSoul:Update(now_time, elapse_time)
    local owner = self.obj:GetOwner()
    if not owner then
    	return
    end

    self:UpdateCurOperate(now_time, elapse_time)

	if now_time < self.next_time then
		return
	end
	self.next_time = now_time + 0.3

	local dist = owner:GetLogicDistSq(self.obj.logic_pos.x, self.obj.logic_pos.y)

    if dist > 900 then
        self:ClearCurOperate()

        local x, y = owner:GetOffsetPos(_follow_offset, _follow_dist)
        if self.obj.scene:IsWalkable(x, y) then
            self.obj:SetLogicPos(x, y)
        end
    elseif dist > 6 then
        self.next_time = now_time + 1
        if not self.cur_oper then
            self.obj.vo.move_speed = owner:GetSpeed()*24
            local x, y = owner:GetOffsetPos(_follow_offset, _follow_dist)
            if self.obj.scene:IsWalkable(x, y) then
                x, y = game.LogicToUnitPos(x, y)
                self.cur_oper = self:CreateOperate(game.OperateType.FindWay, self.obj, x, y)
                if not self.cur_oper:Start() then
                    self:ClearCurOperate()
                end
            end
        end
    else
        self:ClearCurOperate()
        if self.obj:GetCurStateID() ~= game.ObjState.Idle then
            self.obj:DoIdle()
        end
    end
end

function OperateHangWeaponSoul:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangWeaponSoul:ClearCurOperate()
    self.next_time = 0
    self.status = 0
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateHangWeaponSoul
