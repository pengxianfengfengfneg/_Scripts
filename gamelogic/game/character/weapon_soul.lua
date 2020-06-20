
local WeaponSoul = Class(require("game/character/character"))
local _model_type = game.ModelType

function WeaponSoul:_init()
    self.obj_type = game.ObjType.WeaponSoul
    self.update_cd = 0.5 + math.random(10) * 0.03

	self.aoi_range = 30
end

function WeaponSoul:_delete()

end

function WeaponSoul:Init(scene, vo)
    WeaponSoul.super.Init(self, scene)

    self.model_id = vo.model_id
    self.owner = vo.owner
    self.vo = vo
    self.vo.move_speed = 140
    self:CreateDrawObj()

	self:GetOperateMgr():SetDefaultOper(game.OperateType.HangWeaponSoul)
end

function WeaponSoul:Reset()
	WeaponSoul.super.Reset(self)
end

-- 外观形象相关
function WeaponSoul:CreateDrawObj()
	local cur_x, cur_y = self.owner:GetLogicPosXY()
	self:SetLogicPos(cur_x, cur_y)
    self.draw_obj = game.GamePool.DrawObjPool:Create()
    self.draw_obj:Init(game.BodyType.WeaponSoul)
    self.draw_obj:SetParent(self.root_obj.tran)
    self.draw_obj:SetModelID(_model_type.WeaponSoul, self.model_id)
end

function WeaponSoul:SetModelID(id)
	if self.draw_obj then
    	self.draw_obj:SetModelID(_model_type.WeaponSoul, id)
	end
end

function WeaponSoul:GetOwner()
	return self.owner
end

function WeaponSoul:SetOwner(owner)
	self.owner = owner
end

function WeaponSoul:DoIdle()
	self.draw_obj:PlayLayerAnim(_model_type.WeaponSoul, game.ObjAnimName.Idle)
end

function WeaponSoul:SetSelected()

end

function WeaponSoul:CanDoMove()
	return true
end

function WeaponSoul:CanBeAttack()
    return false
end

return WeaponSoul
