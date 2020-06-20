
local EffectObj = Class(require("game/common/cache_mgr/cache_obj"))

local _gameobject = UnityEngine.GameObject
local _time = global.Time
local _default_end_time = 5

function EffectObj:_init()
end

function EffectObj:_delete()

end

function EffectObj:Init(obj_id, path, is_preload)
	EffectObj.super.Init(self, obj_id, path)
	self.is_playing = true
	self.is_loop = false
	self.is_loop_play = false
	self.play_end_time = _time.now_time + _default_end_time

	if is_preload then
		self.is_playing = false
	end
end

function EffectObj:Reset()
	EffectObj.super.Reset(self)

	self._eff_ctrl = nil
	self.layer = nil
	self.life_time = nil
	self.play_end_time = nil
	self.over_time = nil
end

function EffectObj:ResetObj()
	EffectObj.super.ResetObj(self)
	
	if self._model_tran then
		if self.layer then
			self._model_tran:SetLayer(self.layer, true)
			self.layer = nil
		end

		if self._eff_ctrl then
			self._eff_ctrl:StopParitcle()
		end
	end
end

function EffectObj:OnLoadFinish(item, desc)
	EffectObj.super.OnLoadFinish(self, item, desc)

	if self._model_tran then
		if not item.eff_ctrl then
			item.eff_ctrl = self._model_tran:GetComponent(ParticleController)
		end
		self._eff_ctrl = item.eff_ctrl
	end

	if self._load_callback then
		self._load_callback()
	end

	if self.is_playing then
		self:Replay()
	else
		self:Pause()
	end
	
	self.play_end_time = global.Time.now_time + self:GetLifeTime()
end

function EffectObj:GetLifeTime()
	if not self.life_time then
		if self._model_desc then
			self.life_time = self._model_desc:GetLifeTime()
		else
			self.life_time = 0
		end
	end
	return self.life_time
end

function EffectObj:SetLifeTime(time)
	self.life_time = time
end

function EffectObj:SetLayer(layer)
	if self._model_tran then
		local old_layer = self._model_tran:SetLayer(layer, true)
		if not self.layer then
			self.layer = old_layer
		end
	end
end

function EffectObj:Play()
	self.is_playing = true
	if self._eff_ctrl then
		self._eff_ctrl:PlayParitcle()
	end
end

function EffectObj:Pause()
	self.is_playing = false
	if self._eff_ctrl then
		self._eff_ctrl:PauseParitcle()
	end
end

function EffectObj:Replay()
	self.is_playing = true
	if self._eff_ctrl then
		self._eff_ctrl:ReplayParitcle()
	end
end

function EffectObj:Stop()
	self.is_playing = false
	self.play_end_time = global.Time.now_time
	if self._eff_ctrl then
		self._eff_ctrl:StopParitcle()
	end
end

function EffectObj:SetLoop(is_loop)
	self.is_loop = is_loop
end

function EffectObj:IsPlayEnd(now_time)
	if self.is_loop then
		return false
	else
		if self.play_end_time then
			if now_time > self.play_end_time then
				if self.is_loop_play then
					self:Replay()
					self.play_end_time = global.Time.now_time + self:GetLifeTime()
					return false
				else
					return true
				end
			else
				return false
			end
		else
			return false
		end
	end
end

function EffectObj:SetOverTime(val)
	self.over_time = _time.now_time + val
end

function EffectObj:IsOverTime()
	return _time.now_time > self.over_time
end

function EffectObj:ResetTrialRender()
	if self._eff_ctrl then
		self._eff_ctrl:ResetTrialRender()
	end
end

function EffectObj:SetLoopPlay(val)
	self.is_loop_play = val
end

return EffectObj
