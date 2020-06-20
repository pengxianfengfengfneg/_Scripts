
local OperateAttack = Class(require("game/operate/operate_base"))

function OperateAttack:_init()
	self.oper_type = game.OperateType.Attack
end

function OperateAttack:Init(obj, skill_id, skill_lv, target_id, hero_id, legend)
	OperateAttack.super.Init(self, obj)
	self.skill_id = skill_id
	self.skill_lv = skill_lv
	self.target_id = target_id
	self.hero_id = hero_id
	self.legend = legend
end

function OperateAttack:Reset()
	-- if self.obj:IsMainRole() and self.cam_lerp then
 --        local cam = game.Scene.instance:GetCamera()
 --        if cam then
 --            cam:StopLerp()
 --        end
 --    end
    OperateAttack.super.Reset(self)
end

function OperateAttack:Start()
	if not self.obj:CanDoAttack(self.skill_id) then
		return false
	end

	local target = self.obj.scene:GetObj(self.target_id)

	-- if self.obj:IsMainRole() and target then
	-- 	if self.obj:GetLogicDistSq(target.logic_pos.x, target.logic_pos.y) > self.obj:GetCameraLerpDistSq() and self.obj:GetLogicAngleCos(target.logic_pos.x, target.logic_pos.y) < self.obj:GetCameraLerpCos() then
 --            local cam = game.Scene.instance:GetCamera()
 --            if cam then
 --                self.cam_lerp = cam:StartLerp(0.1, 1.5)
 --            end
 --        end
 --    end

	local assist_x, assist_y = self.obj:GetSkillAssistPos(self.skill_id, target)
	self.obj:DoAttack(self.skill_id, self.skill_lv, target, self.hero_id, self.legend, nil, assist_x, assist_y)
	return true
end

function OperateAttack:Update(now_time, elapse_time)
	if self.obj:GetCurStateID() ~= game.ObjState.Attack and self.obj:GetCurStateID() ~= game.ObjState.PreAttack then
		return true
	end
end

return OperateAttack
