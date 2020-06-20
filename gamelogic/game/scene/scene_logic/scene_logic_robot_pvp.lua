
local SceneLogicRobotPvP = Class(require("game/scene/scene_logic/scene_logic_base"))

local _obj_type = game.ObjType

function SceneLogicRobotPvP:_init(scene)
	self.scene = scene
end

function SceneLogicRobotPvP:_delete()

end

function SceneLogicRobotPvP:CreateRole(vo)
	local role = self.scene:_CreateRole(vo)
	role:GetOperateMgr():SetDefaultOper(self:GetHangOperate())
	role:SetSelected(true)

	self.arena_opp = role

	global.EventMgr:Fire(game.ArenaEvent.InitOppInfo)

	return role
end

function SceneLogicRobotPvP:CreatePet(vo)
	local pet = self.scene:_CreatePet(vo)
	return pet
end

function SceneLogicRobotPvP:IsEnemy(attacker, target)
	if attacker.obj_type == _obj_type.Pet then
		attacker = attacker:GetOwner()
		if not attacker then
			return false
		end
	end
	if target.obj_type == _obj_type.Pet then
		target = target:GetOwner()
		if not target then
			return false
		end
	end
	
	return attacker.uniq_id ~= target.uniq_id
end

function SceneLogicRobotPvP:GetHangOperate()
    return game.OperateType.Hang
end

function SceneLogicRobotPvP:CanChangeScene(scene_id)
	return false
end

function SceneLogicRobotPvP:OnMainRoleDie(killer_id, killer_name)
	
end

function SceneLogicRobotPvP:CanAutoHang()
	return true
end

function SceneLogicRobotPvP:GetArenaOpp()
	return self.arena_opp
end

return SceneLogicRobotPvP
