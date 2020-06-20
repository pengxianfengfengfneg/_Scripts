
local OperateMoveAttack = Class(require("game/operate/operate_base"))

local _pDistanceSQ = cc.pDistanceSQ
local _pSub = cc.pSub

local MoveAttackState = {
    FindWay = 1,
    Attack = 2,
}

function OperateMoveAttack:_init()
	self.oper_type = game.OperateType.MoveAttack
end

function OperateMoveAttack:Init(obj, skill_id, skill_lv, target_id, hero_id, legend)
    OperateMoveAttack.super.Init(self, obj)
    self.skill_id = skill_id
    self.skill_lv = skill_lv
    self.target_id = target_id
    self.hero_id = hero_id
    self.legend = legend
end

function OperateMoveAttack:Reset()
    -- if self.obj:IsMainRole() and self.cam_lerp then
    --     self.cam_lerp = nil
    --     local cam = game.Scene.instance:GetCamera()
    --     if cam then
    --         cam:StopLerp()
    --     end
    -- end
    self:ClearCurOperate()
    OperateMoveAttack.super.Reset(self)
end

function OperateMoveAttack:Start()
    local cfg = config.skill[self.skill_id]
    if not cfg or not cfg[self.skill_lv] then
        return false
    end
    
    local target_obj = self.obj.scene:GetObj(self.target_id)
    if not target_obj then
        return false
    end

    -- if self.obj:IsMainRole() and target_obj then
    --     if self.obj:GetLogicDistSq(target_obj.logic_pos.x, target_obj.logic_pos.y) > self.obj:GetCameraLerpDistSq() and self.obj:GetLogicAngleCos(target_obj.logic_pos.x, target_obj.logic_pos.y) < self.obj:GetCameraLerpCos() then
    --         local cam = game.Scene.instance:GetCamera()
    --         if cam then
    --             self.cam_lerp = cam:StartLerp(1, 5)
    --         end
    --     end
    -- end

    local dist = config_help.ConfigHelpSkill.GetSkillCfg(self.skill_id, self.skill_lv, self.hero_id, self.legend, "dist")
    self.skill_dist_sq = dist * dist
    self.state = nil
    return true
end

function OperateMoveAttack:Update(now_time, elapse_time)
    local target_obj = self.obj.scene:GetObj(self.target_id)
    if not target_obj then
        return false
    end

    if self.state == MoveAttackState.FindWay then
        local dist_sq = _pDistanceSQ(self.obj.logic_pos, target_obj.logic_pos)
        if dist_sq < self.skill_dist_sq then
            self:ClearCurOperate()
        end
    end

    if not self.cur_oper then
        local dist_sq = _pDistanceSQ(self.obj.logic_pos, target_obj.logic_pos)
        if dist_sq > self.skill_dist_sq then
            self.cur_oper = self:CreateOperate(game.OperateType.FindWay, self.obj, target_obj.unit_pos.x, target_obj.unit_pos.y)
            if not self.cur_oper:Start() then
                self:ClearCurOperate()
                return false
            else
                self.state = MoveAttackState.FindWay
            end
        else
            self.cur_oper = self:CreateOperate(game.OperateType.Attack, self.obj, self.skill_id, self.skill_lv, self.target_id, self.hero_id, self.legend)
            if not self.cur_oper:Start() then
                self:ClearCurOperate()
                return false
            else
                self.state = MoveAttackState.Attack
            end
        end
    else
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
            return ret
        end
    end
end

function OperateMoveAttack:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
            return ret
        end
    end
end

function OperateMoveAttack:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
        self.state = nil
    end
end

return OperateMoveAttack
