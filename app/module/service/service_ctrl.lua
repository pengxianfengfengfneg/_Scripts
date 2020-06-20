
local ServiceCtrl = Class()

local secret_key = "2c41a3ddd23d1a1f711b7f37df4d515a"

function ServiceCtrl:_init()
	if ServiceCtrl.instance ~= nil then
		error("ServiceCtrl Init Twice!")
	end
	ServiceCtrl.instance = self

end

function ServiceCtrl:_delete()
	ServiceCtrl.instance = nil
end

-- Get ResVersion
function ServiceCtrl:StartGetVersion(retry_count, callback)
	self.get_version_cur_count = 0
	self.get_version_retry_count = retry_count
	self.get_version_callback = callback
	self:_StartGetVersion()
end

function ServiceCtrl:_StartGetVersion()
	self.get_version_cur_count = self.get_version_cur_count + 1

	local url = string.format("%s%s/version?n=%d", N3DClient.GameConfig.GetServerConfig("version_url"), app.Platform, math.random(100000))
	global.HttpService:SendGetRequest(url, function(res, data)
		self:_OnGetResVersion(res, data)
	end)
end

function ServiceCtrl:_OnGetResVersion(result, data)
	if result and data and data ~= "" then
		self.new_version = tonumber(data)
		self.get_version_callback(true)
		return
	end

	if self.get_version_cur_count >= self.get_version_retry_count then
		self.get_version_callback(false)
	else
		self:_StartGetVersion()
	end
end

function ServiceCtrl:GetNewVersion()
	return self.new_version
end

-- Get FileList
function ServiceCtrl:StartGetFileList(retry_count, callback)
	self.get_filelist_cur_count = 0
	self.get_filelist_retry_count = retry_count
	self.get_filelist_callback = callback
	self:_StartGetFileList()
end

function ServiceCtrl:_StartGetFileList()
	self.get_filelist_cur_count = self.get_filelist_cur_count + 1

	local url = string.format("%s%s/filelist_%d.db?n=%d", N3DClient.GameConfig.GetServerConfig("res_url"), app.Platform, self.new_version, math.random(100000))
	global.HttpService:SendGetRequest(url, function(res, msg, data)
		self:_OnGetFileList(res, msg, data)
	end)
end

function ServiceCtrl:_OnGetFileList(result, msg, data)
	if result and data and data ~= "" then
		local seed = N3DClient.GameTool.GetDecryptKey()
		N3DClient.GameTool.DecryptData(data, #data, seed)
		data = N3DClient.ZipUtility.UnzipFileList(data)
		if data then
			self.filelist_data = data
			self.get_filelist_callback(true)
			return
		end
	end

	if self.get_filelist_cur_count >= self.get_filelist_retry_count then
		self.get_filelist_callback(false)
	else
		self:_StartGetFileList()
	end
end

function ServiceCtrl:GetFileList()
	return self.filelist_data
end

function ServiceCtrl:SetFileList(data)
	self.filelist_data = data
end

-- compare filelist
function ServiceCtrl:StartCompareFileList(str)
	N3DClient.AssetManager:GetInstance():StartCompareFileList(str)
end

function ServiceCtrl:StopCompareFileList()
	N3DClient.AssetManager:GetInstance():StopCompareFileList()
end

function ServiceCtrl:IsCompareFileListFinish()
	return N3DClient.AssetManager:GetInstance():IsCompareFileListFinish()
end

function ServiceCtrl:GetPriorityDownloadList()
	return N3DClient.AssetManager:GetInstance():GetPriorityDownloadList()
end

-- http request
function ServiceCtrl:CalculateGetUrl(root_url, val_table)
	local keys = {}
	for k,v in pairs(val_table) do
		table.insert(keys, k)
	end

	local com_func = N3DClient.GameTool.CampareString
	table.sort(keys, function(a, b)
		return com_func(a, b) == -1
	end)

	local calc_str_tab = {}
	for i, v in ipairs(keys) do
		if i ~= 1 then
			table.insert(calc_str_tab, "&")
		end
		table.insert(calc_str_tab, v)
		table.insert(calc_str_tab, "=")
		table.insert(calc_str_tab, val_table[v])
	end
	local calc_str = table.concat(calc_str_tab)
	local ticket = calc_str .. secret_key
	ticket = N3DClient.GameTool.GetMD5(ticket)

	local res_url_tab = {}
	table.insert(res_url_tab, root_url)
	table.insert(res_url_tab, "?")
	table.insert(res_url_tab,  calc_str)
	table.insert(res_url_tab,  "&ticket=")
	table.insert(res_url_tab, ticket)
	local res_url = table.concat(res_url_tab)
	return res_url
end


app.ServiceCtrl = ServiceCtrl.New()

return ServiceCtrl
