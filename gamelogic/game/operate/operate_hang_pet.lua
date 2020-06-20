local OperateHangPet = Class(require("game/operate/operate_base"))

local _follow_offset = {x = 0, y = 1}
local _follow_dist = 3

function OperateHangPet:_init()
    self.next_time = 0
    self.oper_type = game.OperateType.HangPet
end

function OperateHangPet:Reset()
    self:ClearCurOperate()
    OperateHangPet.super.Reset(self)
end

function OperateHangPet:Start()
    self.status = 0
    return true
end

function OperateHangPet:Update(now_time, elapse_time)
    local owner = self.obj:GetOwner()
    if not owner then
    	return
    end

    self:UpdateCurOperate(now_time, elapse_time)

	if now_time < self.next_time then
		return
	end
	self.next_time = now_time + 0.3

    if self.status == 2 then
        if not owner:IsInAttackState() then
            self:ClearCurOperate()
            if self.obj:GetCurStateID() ~= game.ObjState.Idle then
                self.obj:DoIdle()
            end
            return
        end
    end

	local dist = owner:GetLogicDistSq(self.obj.logic_pos.x, self.obj.logic_pos.y)
    if dist > 500 then
        self:ClearCurOperate()
        if self.obj:GetCurStateID() ~= game.ObjState.Idle then
            self.obj:DoIdle()
        end
        
        local owner_state = owner:GetCurStateID()
        if owner_state ~= game.ObjState.Jump then
            self.obj:SetDir(owner.dir.x, owner.dir.y)
            local x, y = owner:GetOffsetPos(_follow_offset, _follow_dist)
            if self.obj.scene:IsWalkable(x, y) then
                self.obj:SendWalkReq(x, y, 5)
                self.obj:SetLogicPos(x, y)
            end
        end
    elseif dist > 20 then
        self.next_time = now_time + 0.6
        if not self.cur_oper then
            local owner_state = owner:GetCurStateID()
            if owner_state ~= game.ObjState.Jump then
                local x, y = owner:GetOffsetPos(_follow_offset, _follow_dist)
                if self.obj.scene:IsWalkable(x, y) then
                    x, y = game.LogicToUnitPos(x, y)
                    self.status = 1
                    self.cur_oper = self:CreateOperate(game.OperateType.FindWay, self.obj, x, y)
                    if not self.cur_oper:Start() then
                        self:ClearCurOperate()
                    end
                end
            end
        end
    else
        if self.status == 1 then
            self:ClearCurOperate()
            if self.obj:GetCurStateID() ~= game.ObjState.Idle then
                self.obj:DoIdle()
            end
        else
        	if owner:IsInAttackState() then
                if self.status == 0 then
                 --    local target_obj = self.obj:GetTarget()
                 --    if not self.obj:CanAttackObj(target_obj) then
                 --        self.obj:SelectTarget(nil)
                 --        target_obj = nil
                 --    end

        	        -- if target_obj then
                        
        	        -- end
                    self.status = 2
                    self.cur_oper = self:CreateOperate(game.OperateType.HangAttack, self.obj)
                    if not self.cur_oper:Start() then
                        self:ClearCurOperate()
                    end
                end
        	end
        end
    end
end

function OperateHangPet:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangPet:ClearCurOperate()
    self.next_time = 0
    self.status = 0
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateHangPet
