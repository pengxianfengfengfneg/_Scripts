-- BtAttack
-- in: attack_skill_id, attack_skill_lv, target_obj_id
local BtAttack = Class(bt.BtAction)

function BtAttack:_init()
	self._name = "BtAttack"
end

function BtAttack:OnEnter(now_time, elapse_time, black_board)
	local target = black_board.obj.scene:GetObj(black_board.target_obj_id)
	black_board.obj:DoAttack(black_board.attack_skill_id, black_board.attack_skill_lv, target)
end

function BtAttack:OnUpdate(now_time, elapse_time, black_board)
	if black_board.obj:GetCurStateID() ~= game.ObjState.Attack 
		and black_board.obj:GetCurStateID() ~= game.ObjState.PreAttack then
		return true
	end
end

bt.BtAttack = BtAttack

-- BtCanAttackTarget
local BtCanAttackTarget = Class(bt.BtCondition)

function BtCanAttackTarget:_init()
	self._name = "BtCanAttackTarget"
end

function BtCanAttackTarget:Check(now_time, elapse_time, black_board)
	local target = black_board.obj.scene:GetObj(black_board.target_obj_id)
	return black_board.obj:CanAttackObj(target)
end

bt.BtCanAttackTarget = BtCanAttackTarget


-- BtCanAttack
local BtCanAttack = Class(bt.BtCondition)

function BtCanAttack:_init()
	self._name = "BtCanAttack"
end

function BtCanAttack:Check(now_time, elapse_time, black_board)
	return black_board.obj:CanDoAttack()
end

bt.BtCanAttack = BtCanAttack

-- BtHasNextSkill
-- in: only_default_skill
-- out: attack_skill_id, attack_skill_lv, attack_skill_dist
local BtHasNextSkill = Class(bt.BtCondition)

function BtHasNextSkill:_init()
	self._name = "BtHasNextSkill"
end

function BtHasNextSkill:Check(now_time, elapse_time, black_board)
	black_board.attack_skill_id, black_board.attack_skill_lv = black_board.obj:GetNextSkill(not black_board.only_default_skill)
	if black_board.attack_skill_id then
		black_board.attack_skill_dist = config.skill[black_board.attack_skill_id][black_board.attack_skill_lv].dist
		return true
	else
		return false
	end
end

bt.BtHasNextSkill = BtHasNextSkill

-- BtInSkillRange
-- in: attack_skill_id, attack_skill_lv, attack_skill_dist, target_obj_id
local BtInSkillRange = Class(bt.BtCondition)

function BtInSkillRange:_init()
	self._name = "BtInSkillRange"
end

function BtInSkillRange:Check(now_time, elapse_time, black_board)
	local target = black_board.obj.scene:GetObj(black_board.target_obj_id)
	if target then
		if target:GetLogicDist(black_board.obj:GetLogicPosXY()) < black_board.attack_skill_dist then
			return true
		end
	end
	return false
end

bt.BtInSkillRange = BtInSkillRange

-- BtHasEnemy
local BtHasEnemy = Class(bt.BtCondition)

function BtHasEnemy:_init()
	self._name = "BtHasEnemy"
end

function BtHasEnemy:Check(now_time, elapse_time, black_board)
	if black_board.target_obj_id then
		local obj = black_board.obj.scene:GetObj(black_board.target_obj_id)
		if obj and black_board.obj:CanAttackObj(obj) then
			return true
		end
	end
	return false
end

bt.BtHasEnemy = BtHasEnemy

-- BtSearchEnemy
local BtSearchEnemy = Class(bt.BtCondition)

function BtSearchEnemy:_init()
	self._name = "BtSearchEnemy"
end

function BtSearchEnemy:Check(now_time, elapse_time, black_board)
	local target = black_board.obj:SearchEnemy()
	black_board.obj:SelectTarget(target)
	if target then
		black_board.target_obj_id = target.obj_id
		return true
	else
		black_board.target_obj_id = nil
		return false
	end
end

bt.BtSearchEnemy = BtSearchEnemy