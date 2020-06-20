
local AssetLoader = Class()

local _asset_mgr = N3DClient.AssetManager:GetInstance()
local _time = global.Time
local _ui_mgr = N3DClient.UIManager:GetInstance()
local _table_insert = table.insert
local _table_remove = table.remove
local _all_asset_key = "__all_asset_key"
local _scene_key = "__scene_key"
local _download_key = "__download_key"
local _bundle_key = "__bundle_key"

local _load_func_map = {
	[_all_asset_key] = function(bundle_path, asset_name, need_download)
		return _asset_mgr:LoadAllAssetAsync(bundle_path, need_download)
	end,
	[_scene_key] = function(bundle_path, asset_name, need_download)
		return _asset_mgr:LoadSceneAsync(bundle_path, asset_name, need_download)
	end,
	[_download_key] = function(bundle_path, asset_name, need_download)
		return _asset_mgr:DownloadBundleAsync(bundle_path)
	end,
	[_bundle_key] = function(bundle_path, asset_name, need_download)
		return _asset_mgr:LoadBundleAsync(bundle_path, need_download)
	end
}

function AssetLoader:_init()
	self.req_id = 0
	self.req_map = {}

	self.asset_map = {}
	self.bundle_map = {}
	self.finish_req_list = {}

	self.next_update_time = 0
	self.update_interval = 0

	self.asset_num = 0
	self.need_download = true
	global.Runner:AddUpdateObj(self, 2)
end

function AssetLoader:SetNeedDownload(val)
	self.need_download = val
end

function AssetLoader:SetPersistentRes(name)
	_asset_mgr:SetPersistentRes(name)
end

function AssetLoader:SetUpdateInterval(val)
	self.update_interval = val
end

function AssetLoader:_delete()
	self:UnLoadUnuseBundle()
	global.Runner:RemoveUpdateObj(self)
end

function AssetLoader:InitDependency()
	if not N3DClient.GameConfig.GetClientConfigBool("ResRawMode", false) then
		local dep_map = require("dependences")
		for k,v in pairs(dep_map) do
			_asset_mgr:InitDependency(k, v)
		end
	end
end

function AssetLoader:Update(now_time, elapse_time)
	local id, success = _asset_mgr:GetFinishRequest()
	if id ~= 0 then
		self:_OnLoadAssetFinish(id, success)
	end

	if now_time > self.next_update_time then
		self.next_update_time = now_time + self.update_interval
		
		if #self.finish_req_list > 0 then
			local req_id = self.finish_req_list[1]
			_table_remove(self.finish_req_list, 1)

			local req = self.req_map[req_id]
			if req and req.finish_func then
				req.finish_func(req.asset_info.is_success)
			end
		end
	end
end

-- 异步加载asset
function AssetLoader:LoadAsset(bundle_path, asset_name, finish_func)
	return self:_LoadAsset(bundle_path, asset_name, asset_name, false, finish_func)
end

function AssetLoader:LoadAllAsset(bundle_path, is_ui, finish_func)
	return self:_LoadAsset(bundle_path, _all_asset_key, _all_asset_key, is_ui, finish_func)
end

function AssetLoader:LoadScene(bundle_path, asset_name, finish_func)
	return self:_LoadAsset(bundle_path, asset_name, _scene_key, false, finish_func)
end

function AssetLoader:DownloadAsset(bundle_path, finish_func)
	return self:_LoadAsset(bundle_path, _download_key, _download_key, false, finish_func)
end

function AssetLoader:LoadBundle(bundle_path, finish_func)
	return self:_LoadAsset(bundle_path, _bundle_key, _bundle_key, false, finish_func)
end

function AssetLoader:_LoadAsset(bundle_path, asset_name, key, is_ui, finish_func)
	local bundle_info = self.bundle_map[bundle_path]
	if not bundle_info then
		bundle_info = {}
		bundle_info.name = bundle_path
		bundle_info.asset_map = {}
		self.bundle_map[bundle_path] = bundle_info
	end

	local asset_info = bundle_info.asset_map[key]
	if not asset_info then
		asset_info = {}
		asset_info.path = bundle_path
		asset_info.name = key
		asset_info.ref_count = 0
		asset_info.load_finish = false
		asset_info.is_ui = is_ui
		bundle_info.asset_map[key] = asset_info
	end
	asset_info.ref_count = asset_info.ref_count + 1

	if not asset_info.id then
		self.asset_num = self.asset_num + 1
		if _load_func_map[key] then
			asset_info.id = _load_func_map[key](bundle_info.name, asset_name, self.need_download)
		else
			asset_info.id = _asset_mgr:LoadAssetAsync(bundle_info.name, asset_name, self.need_download)
		end
		self.asset_map[asset_info.id] = asset_info
		asset_info.req_list = {}
	end

	self.req_id = self.req_id + 1

	local req = {}
	req.asset_info = asset_info
	req.finish_func = finish_func
	self.req_map[self.req_id] = req

	if asset_info.load_finish then
		_table_insert(self.finish_req_list, self.req_id)
	else
		_table_insert(asset_info.req_list, self.req_id)
	end

	return self.req_id
end

function AssetLoader:UnLoad(req_id)
	local req = self.req_map[req_id]
	if not req then
		error("AssetLoader:Unload request not exist", req_id)
		return
	end

	local asset_info = req.asset_info
	asset_info.ref_count = asset_info.ref_count - 1

	if asset_info.ref_count <= 0 then
		if asset_info.id then
			self.asset_num = self.asset_num - 1
			self.asset_map[asset_info.id] = nil

			if asset_info.is_ui and asset_info.is_success then
				_ui_mgr:RemoveUIPackage(asset_info.path)
			end
			_asset_mgr:UnLoad(asset_info.id)
			asset_info.load_finish = false
			asset_info.is_success = false
			asset_info.id = nil
		end
		asset_info.req_list = nil
	end
	
	self.req_map[req_id] = nil
end

function AssetLoader:_OnLoadAssetFinish(asset_id, is_success)
	local asset_info = self.asset_map[asset_id]
	if not asset_info then
		error("AssetLoader:_OnLoadFinish unref asset loaded", asset_info.name)
		return
	end
	 
	asset_info.is_success = is_success
	asset_info.load_finish = true
	if asset_info.is_ui and is_success then
		_ui_mgr:AddUIPackage(asset_info.path)
	end

	-- local req
	for i,v in ipairs(asset_info.req_list) do
		_table_insert(self.finish_req_list, v)
	end
	asset_info.req_list = nil
end

function AssetLoader:UnLoadUnuseBundle()
	_asset_mgr:UnLoadUnuseAsset()
end

function AssetLoader:UnLoadAllBundle()
	for k,v in pairs(self.req_map) do
		self:UnLoad(k)
	end
	self.req_map = nil
end

function AssetLoader:GetAssetNum()
	return self.asset_num
end

function AssetLoader:GetBundleNum()
	return _asset_mgr:GetBundleNum()
end

function AssetLoader:GetProgress(req_id)
	return _asset_mgr:GetRequestProgress(req_id)
end

function AssetLoader:DebugAll()
	print("AssetLoader:DebugAll")
	local n = 0
	for k,v in pairs(self.asset_map) do
		n = n + 1
		print(n, v.path, v.name, v.ref_count)
	end
end

function AssetLoader:SetMaxTaskNum(num)
	_asset_mgr:SetMaxTaskNum(num)
end

function AssetLoader:GetWaitTaskNum()
	return _asset_mgr:GetWaitTaskNum()
end

function AssetLoader:GetRunTaskNum()
	return _asset_mgr:GetRunTaskNum()
end

-- Get Assets
function AssetLoader:GetAsset(bundle_path, asset_name)
	return _asset_mgr:GetAssetObj(bundle_path, asset_name)
end

function AssetLoader:GetTexture2D(bundle_path, asset_name)
	return _asset_mgr:GetTexture2D(bundle_path, asset_name)
end

function AssetLoader:GetMaterial(bundle_path, asset_name)
	return _asset_mgr:GetMaterial(bundle_path, asset_name)
end

function AssetLoader:GetModelPrefabDesc(bundle_path, asset_name)
	return _asset_mgr:GetModelPrefabDesc(bundle_path, asset_name)
end

function AssetLoader:GetParticlePrefabDesc(bundle_path, asset_name)
	return _asset_mgr:GetParticlePrefabDesc(bundle_path, asset_name)
end

function AssetLoader:GetShaderDesc(bundle_path, asset_name)
	return _asset_mgr:GetShaderDesc(bundle_path, asset_name)
end

function AssetLoader:GetGameObject(bundle_path, asset_name)
	return _asset_mgr:GetGameObject(bundle_path, asset_name)
end

function AssetLoader:GetFont(bundle_path, asset_name)
	return _asset_mgr:GetFont(bundle_path, asset_name)
end

function AssetLoader:GetMapInfo(bundle_path, asset_name)
	return _asset_mgr:GetMapInfo(bundle_path, asset_name)
end

function AssetLoader:GetMesh(bundle_path, asset_name)
	return _asset_mgr:GetMesh(bundle_path, asset_name)
end

function AssetLoader:GetNavMeshData(bundle_path, asset_name)
	return _asset_mgr:GetNavMeshData(bundle_path, asset_name)
end

function AssetLoader:GetMaterialDesc(bundle_path, asset_name)
	return _asset_mgr:GetMaterialDesc(bundle_path, asset_name)
end

function AssetLoader:CreateGameObject(bundle_path, asset_name)
	return _asset_mgr:CreateGameObject(bundle_path, asset_name)
end

global.AssetLoader = AssetLoader.New()
