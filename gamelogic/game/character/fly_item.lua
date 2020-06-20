local FlyItem = Class(require("game/character/character"))

local _effect_mgr = game.EffectMgr

function FlyItem:_init()
	self.obj_type = game.ObjType.FlyItem
	self.update_cd = 1
end

function FlyItem:Init(scene, vo)
	FlyItem.super.Init(self, scene, vo)

	self.vo = vo
	self.uniq_id = vo.id
	self:SetLogicPos(vo.x, vo.y)

	local cfg = config.flyitem[vo.cid]
	self.move_speed = cfg.speed / 24

	self:CreateDrawObj()
end

function FlyItem:Reset()
	if self.effect_id then
		_effect_mgr.instance:StopEffectByID(self.effect_id)
		self.effect_id = nil
	end
	FlyItem.super.Reset(self)
end

function FlyItem:CreateDrawObj()
	local cfg = config.flyitem[self.vo.cid]
	local eff_path = string.format("effect/skill/%s.ab", cfg.model_id)
    local effect = _effect_mgr.instance:CreateObjEffect(eff_path, self.obj_id, nil, 3)
    effect:SetParent(self:GetRoot())
	effect:SetLoop(true)
	self.effect_id = effect:GetID()
end

function FlyItem:GetSpeed()
	return self.move_speed
end

function FlyItem:CanBeAttack()
    return false
end

return FlyItem
