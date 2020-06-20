
local EffectBase = Class()

local _cache_mgr = game.CacheMgr
local _cache_time = 90

function EffectBase:_init()
	self.load_res_func = function()
		self._effect_obj:SetParent(self._root_obj.tran)
		if self.callback then
			self.callback()
		end
	end

	self.on_obj_del_func = handler(self, self.OnObjDelete)
end

function EffectBase:_delete()
	self:Reset()
end

function EffectBase:Init(id, path, over_time)
    self._eff_id = id

	if not self._root_obj then
		self._root_obj = game.GamePool.GameObjectPool:Create()
	end

	self._effect_obj = _cache_mgr:CreateEffectObj(path, _cache_time, false, nil, over_time)
	self._effect_obj:SetLoadCallBack(self.load_res_func)
end

function EffectBase:Reset()
	self.layer = nil
	self.callback = nil
	self.obj_id = nil
    self.is_play_end = nil
    self.tag = 0
    self.type = nil

	if self.ev then
		global.EventMgr:UnBind(self.ev)
		self.ev = nil
	end

	if self._effect_obj then
		_cache_mgr:FreeObj(self._effect_obj)
		self._effect_obj = nil
	end

	if self._root_obj then
		game.GamePool.GameObjectPool:Free(self._root_obj)
		self._root_obj = nil
	end
end

function EffectBase:GetID()
	return self._eff_id
end

function EffectBase:SetTag(tag)
	self.tag = tag
end

-- 1:技能 2:受击特效 3:buff
function EffectBase:SetType(type)
	self.type = type
end

function EffectBase:SetPlayEnd()
	self.is_play_end = true
end

function EffectBase:GetRoot()
	return self._root_obj.tran
end

function EffectBase:SetVisible(val)
	self._root_obj.tran:SetVisible(val)
end

function EffectBase:SetName(name)
    self._root_obj.tran.name = name
end

function EffectBase:SetLoadCallBack(func)
	self.callback = func
end

function EffectBase:SetPosition(x, y, z)
	self._root_obj.tran:SetPosition(x, y, z)
end

function EffectBase:SetRotation(x, y, z)
    self._root_obj.tran:SetRotation(x, y, z)
end

function EffectBase:SetScale(x, y, z)
    self._root_obj.tran:SetScale(x, y, z)
end

function EffectBase:SetDir(x, y)
	self._root_obj.tran:SetLookDir(x, 0, y)
end

function EffectBase:SetLookDir(x, y, z)
    self._root_obj.tran:SetLookDir(x, y, z)
end

function EffectBase:SetParent(parent)
	self._root_obj.tran:SetParent(parent, false)
end

function EffectBase:Play()
	self._effect_obj:Play()
end

function EffectBase:Pause()
	self._effect_obj:Pause()
end

function EffectBase:Stop()
	self._effect_obj:Stop()
end

function EffectBase:Replay()
	self._effect_obj:Replay()
end

function EffectBase:SetLayer(layer)
	self._effect_obj:SetLayer(layer)
end

function EffectBase:SetLoop(is_loop)
	self._effect_obj:SetLoop(is_loop)
end

function EffectBase:IsPlayEnd(now_time)
	return self.is_play_end or (self._effect_obj and self._effect_obj:IsPlayEnd(now_time))
end

function EffectBase:BindObjID(obj_id)
	self.obj_id = obj_id
	if not self.ev then
		self.ev = global.EventMgr:Bind(game.SceneEvent.ObjDelete, self.on_obj_del_func)
	end
end

function EffectBase:OnObjDelete(del_id)
	if del_id == self.obj_id then
		game.EffectMgr.instance:StopEffect(self)
	end
end

function EffectBase:GetGameObject()
	return self._root_obj.obj
end

function EffectBase:SetLoopPlay(val)
	self._effect_obj:SetLoopPlay(val)
end

function EffectBase:SetLifeTime(time)
	self._effect_obj:SetLifeTime(time)
end

return EffectBase
