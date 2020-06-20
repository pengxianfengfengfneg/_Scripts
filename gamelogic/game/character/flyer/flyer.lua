local Flyer = Class()

local _effect_mgr = game.EffectMgr

function Flyer:_init(id)
	self.id = id
	self.start_pos = {x = 0, y = 0}
	self.target_pos = {x = 0, y = 0}

	self.dir_speed = {x = 0, y = 0}
	self.speed = 10
end

function Flyer:_delete()
	self:Reset()
end

function Flyer:Init(scene, vo)
	self.scene = scene
	self:SetEffect(vo[2], vo[3])
	self.delay_time = vo[4]
	self.speed = vo[6]
	self.is_start = false
end

function Flyer:Reset()
	self.is_start = false
	self.is_return = false
	self:ClearEffect()
end

function Flyer:Start()
	self:CalcPath()
	self.is_start = true
	self.start_time = global.Time.now_time + self.delay_time
end

function Flyer:CalcPath()
	local delta = cc.pSub_static(self.target_pos, self.start_pos)
	local dist = cc.pGetLength(delta)
	self.delta_time = (dist / self.speed) + 0.1
	self.dir_speed.x, self.dir_speed.y = delta.x / self.delta_time, delta.y / self.delta_time

	local delta_height = self.target_height - self.start_height
	self.height_speed = delta_height / self.delta_time

	self.cur_time = 0
	self:SetDir(self.dir_speed.x, self.dir_speed.y)
end

function Flyer:Update(now_time, elapse_time)
	if not self.is_start or now_time < self.start_time then
		return
	end

	local is_end = false
	self.cur_time = self.cur_time + elapse_time
	if self.cur_time > self.delta_time then
		self.cur_time = self.delta_time
		is_end = true
	end


	self:SetUnitPos(self.start_pos.x + self.dir_speed.x * self.cur_time, self.start_height + self.height_speed * self.cur_time + self.height_offset, self.start_pos.y + self.dir_speed.y * self.cur_time)

	if is_end then
		if self.is_return then
			local obj = self.scene:GetObj(self.return_obj_id)
			if obj then
				self.is_return = false
				self.start_pos.x, self.start_pos.y = self.target_pos.x, self.target_pos.y
				self.target_pos.x, self.target_pos.y = obj:GetUnitPosXY()
				self.start_height = self.target_height
				self.target_height = obj:GetMapHeight()
				self:CalcPath()
				return
			end
		end
		self.is_start = false
		self.scene:FreeFlyer(self.id)
	end
end

function Flyer:SetStartPos(x, y)
	self.start_pos.x = x
	self.start_pos.y = y
end

function Flyer:SetTargetPos(x, y)
	self.target_pos.x = x
	self.target_pos.y = y
end

function Flyer:SetStartHeight(val)
	self.start_height = val
end

function Flyer:SetTargetHeight(val)
	self.target_height = val
end

function Flyer:SetHeightOffset(val)
	self.height_offset = val
end

function Flyer:SetReturn(val, obj_id)
	self.is_return = val
	self.return_obj_id = obj_id
end

function Flyer:SetUnitPos(x, y, z)
	local eff = self:GetEffect()
	if eff then
		eff:SetPosition(x, y, z)
	end
end

function Flyer:SetDir(x, y)
	local eff = self:GetEffect()
	if eff then
		eff:SetDir(x, y)
	end
end

function Flyer:SetEffect(name, scale)
	if not self.effect_id then
		local eff_path = string.format("effect/skill/%s.ab", name)
	    local effect = _effect_mgr.instance:CreateEffect(eff_path)
	    self.effect_id = effect:GetID()
	    effect:SetLoop(true)
	    if scale ~= 1 then
		    effect:SetScale(scale, scale, scale)
		end
	    game.RenderUnit:AddToObjLayer(effect:GetRoot())
	end
end

function Flyer:ClearEffect()
	if self.effect_id then
		_effect_mgr.instance:StopEffectByID(self.effect_id)
		self.effect_id = nil
	end
end

function Flyer:GetEffect()
	if not self.effect_id then
		return
	else
		local eff = _effect_mgr.instance:GetEffectByID(self.effect_id)
		return eff
	end
end

return Flyer
