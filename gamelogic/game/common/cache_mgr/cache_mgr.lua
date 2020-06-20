
local CacheMgr = Class()

local _gameobject = UnityEngine.GameObject
local _asset_loader = global.AssetLoader
local _render_unit = game.RenderUnit
local _table_insert = table.insert
local _table_remove = table.remove

local _default_cache_time = 30

local CacheType = {
	Model = 1,
	Particle = 2,
}

local CacheInfoMap = {
	[CacheType.Model] = {
		obj_cls = require("game/common/cache_mgr/model_obj"),
		load_func = function(item, path, finish_cb)
			item.asset_handler = _asset_loader:LoadAsset(path, "model_desc", finish_cb)
		end,
		create_func = function(path)
			return _asset_loader:GetModelPrefabDesc(path, "model_desc")
		end,
		unload_func = function(item)
			if item.asset_handler then
				_asset_loader:UnLoad(item.asset_handler)
				item.asset_handler = nil
			end
		end
	},
	[CacheType.Particle] = {
		obj_cls = require("game/common/cache_mgr/effect_obj"),
		load_func = function(item, path, finish_cb)
			item.asset_handler = _asset_loader:LoadAsset(path, "particle_desc", finish_cb)
		end,
		create_func = function(path)
			return _asset_loader:GetParticlePrefabDesc(path, "particle_desc")
		end,
		unload_func = function(item)
			if item.asset_handler then
				_asset_loader:UnLoad(item.asset_handler)
				item.asset_handler = nil
			end
		end
	},
}

function CacheMgr:_init()
	self.obj_id = 0
	self.obj_list = {}
	self.cache_map = {}

	self.next_free_time = 0
	self.free_cache_list = {}

	self.update_interval = 0
	self.next_finish_time = 0
	self.finish_obj_list = {}

	self.cache_obj_pool = {}
	for i=1,2 do
		self.cache_obj_pool[i] = global.CollectPool.New(function()
			return CacheInfoMap[i].obj_cls.New()
		end, function(item)
			item:DeleteMe()
		end, function(item)
			item:Reset()
		end, 0)
	end

	global.Runner:AddUpdateObj(self, 2)
end

function CacheMgr:_delete()
	local tmp_list = {}
	for i,v in pairs(self.cache_map) do
		table.insert(tmp_list, i)
	end
	
	for i,v in ipairs(tmp_list) do
		self:_UnloadCache(v)
	end
	self.cache_map = nil
	global.Runner:RemoveUpdateObj(self)
end

function CacheMgr:Update(now_time, elapse_time)
	if now_time > self.next_finish_time then
		if #self.finish_obj_list > 0 then
			local obj_id = self.finish_obj_list[1]
			_table_remove(self.finish_obj_list, 1)

			local obj = self.obj_list[obj_id]
			if obj then
				local cache_item = self.cache_map[obj._path] 
				if cache_item and not obj:IsOverTime() then
					if cache_item.model_pool:HasFreeItem() then
						self.next_finish_time = now_time + 0.05
					else
						self.next_finish_time = now_time + self.update_interval
					end
				
					local item = cache_item.model_pool:Create()
					obj:OnLoadFinish(item, cache_item.cache_desc)
				end
			end
		else
			self.next_finish_time = now_time + 0.02
		end
	end

	if now_time > self.next_free_time then
		self.next_free_time = now_time + 0.5
		for k,v in pairs(self.free_cache_list) do
			if now_time > v then
				self:_UnloadCache(k)
				break
			end
		end
	end
end

function CacheMgr:SetUpdateInterval(val)
	self.update_interval = val
end

function CacheMgr:CreateModelObj(path, cache_time, auto_release, cache_num)
	return self:_CreateCacheObj(CacheType.Model, path, cache_time, auto_release, cache_num)
end

function CacheMgr:CreateEffectObj(path, cache_time, auto_release, cache_num, over_time, is_preload)
	local obj = self:_CreateCacheObj(CacheType.Particle, path, cache_time, auto_release, cache_num, is_preload)
	obj:SetOverTime(over_time or 1)
	return obj
end

function CacheMgr:_CreateCacheObj(cache_type, path, cache_time, auto_release, cache_num, is_preload)
	self.obj_id = self.obj_id + 1

	local cache_item = self.cache_map[path]
	if not cache_item then
		cache_item = {}
		self.cache_map[path] = cache_item

		local finish_cb = function(is_success)
			cache_item.load_success = is_success
			if is_success and not cache_item.cache_desc then
				cache_item.cache_desc = CacheInfoMap[cache_type].create_func(path)
				if cache_num and cache_num > 0 then
					cache_item.model_pool:Reserve(cache_num)
				end
			end
			self:_OnResLoaded(path)
		end

		local new_func = function()
			local obj
			if cache_item.template then
				obj = _gameobject.Instantiate(cache_item.template)
			elseif cache_item.cache_desc then
				obj = cache_item.cache_desc:CreateObj()
			end
			if obj then
				return {obj = obj}
			end
		end

		local free_func = function(item)
			_gameobject.Destroy(item.obj)
			item.obj = nil
		end

		local collect_func = function(item)
			_render_unit:AddToUnUsedLayer(item.obj)
		end

		if auto_release == nil then
			auto_release = true
		end

		cache_item.path = path
		cache_item.cache_type = cache_type
		cache_item.cache_time = cache_time or _default_cache_time
		cache_item.model_pool = global.CollectPool.New(new_func, free_func, collect_func)
		cache_item.req_obj_list = {}
		cache_item.ref_count = 0
		cache_item.auto_release = auto_release
		CacheInfoMap[cache_type].load_func(cache_item, path, finish_cb)
	end

	if cache_item.ref_count == 0 then
		self.free_cache_list[cache_item.path] = nil
	end

	cache_item.ref_count = cache_item.ref_count + 1

	local obj = self.cache_obj_pool[cache_type]:Create()
	obj:Init(self.obj_id, path, is_preload)
	self.obj_list[self.obj_id] = obj
	
	if cache_item.is_loaded then
		_table_insert(self.finish_obj_list, self.obj_id)
	else
		_table_insert(cache_item.req_obj_list, self.obj_id)
	end

	return obj
end

function CacheMgr:SetTemplate(path, tran)
	local cache_item = self.cache_map[path]
	if cache_item then
		cache_item.template = tran
	end
end

function CacheMgr:_OnResLoaded(path)
	local cache_item = self.cache_map[path]
	if not cache_item then
		error("CacheMgr _OnResLoaded: No Cache Found " .. path)
		return
	end

	cache_item.is_loaded = true

	if cache_item.req_obj_list then
		for i,v in ipairs(cache_item.req_obj_list) do
			_table_insert(self.finish_obj_list, v)
		end
		cache_item.req_obj_list = nil
	end
end

function CacheMgr:FreeObj(obj)
	local cache_item = self.cache_map[obj._path]
	if not cache_item then
		error("CacheMgr:FreeObj No Cache Found" .. obj._path)
		return
	end
	
	obj:ResetObj()

	if obj._cahce_item then
		cache_item.model_pool:Free(obj._cahce_item)
	end
	
	self.obj_list[obj._obj_id] = nil

	self.cache_obj_pool[cache_item.cache_type]:Free(obj)

	cache_item.ref_count = cache_item.ref_count - 1
	if cache_item.ref_count <= 0 and cache_item.cache_time > 0 then 
		self.free_cache_list[cache_item.path] = global.Time.now_time + cache_item.cache_time
	end
end

function CacheMgr:_UnloadCache(path)
	local cache_item = self.cache_map[path]
	if not cache_item then
		error("CacheMgr:_UnloadCache No Cache Found! " .. path)
		return
	end

	if cache_item.ref_count > 0 then
		self.free_cache_list[path] = nil
		error("CacheMgr:_UnloadCache Cache Ref Count More than 1! " .. path)
		return
	end

	self.free_cache_list[path] = nil

	cache_item.model_pool:DeleteMe()
	cache_item.model_pool = nil
	cache_item.cache_desc = nil
	CacheInfoMap[cache_item.cache_type].unload_func(cache_item)

	self.cache_map[cache_item.path] = nil	
end

function CacheMgr:UnloadUnuseCache()
	local tmp_list = {}
	for i,v in pairs(self.cache_map) do
		if v.auto_release and v.ref_count <= 0 then
			table.insert(tmp_list, i)
		end
	end
	
	for i,v in ipairs(tmp_list) do
		self:_UnloadCache(v)
	end
	tmp_list = nil
end

function CacheMgr:GetCacheCount()
	local num = 0
	for k,v in pairs(self.cache_map) do
		num = num + 1
	end
	return num
end

function CacheMgr:GetObjCount()
	local num = 0
	for k,v in pairs(self.obj_list) do
		num = num + 1
	end
	return num
end

game.CacheMgr = CacheMgr.New()
