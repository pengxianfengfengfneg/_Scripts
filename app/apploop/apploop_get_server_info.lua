
local AppLoopGetServerInfo = Class()

local secret_key = "2c41a3ddd23d1a1f711b7f37df4d515a"
local root_url_map = {
	["dev"] = "http://120.78.87.199:81/vt/api_active.php",
	["zj"] = "http://120.78.87.199:81/vt/api_active.php",
	["base"] = "http://120.78.87.199:81/vt/api_active.php",
	["base_win"] = "http://120.78.87.199:81/vt/api_active.php",
	--台湾
	--["dev"] = "http://120.78.87.199/vt/api_active.php",
	--["zj"] = "http://120.78.87.199/vt/api_active.php",
	--["base"] = "http://120.78.87.199/vt/api_active.php",
	--["base_win"] = "http://120.78.87.199/vt/api_active.php",
}
local _sdk_helper = N3DClient.SdkHelper:GetInstance()

function AppLoopGetServerInfo:_init()

end

function AppLoopGetServerInfo:_delete()

end

function AppLoopGetServerInfo:StateEnter()
	print("AppLoopGetServerInfo")
	app.InitCtrl.instance:SetLoadingTxt(app.words[2])
	app.InitCtrl.instance:SetLoadingValue(0)

	self.req_cur_count = 0
	self.req_max_count = 3
	self.req_state = -2
end

function AppLoopGetServerInfo:StateUpdate(now_time, elapse_time)
	if self.req_state == -2 then
		self:SyncDitchID()
	elseif self.req_state == -1 then
		self:StartGetServerInfo()
	elseif self.req_state == 1 then
		app.AppLoop.instance:ChangeState(app.AppLoop.State.CheckResVersion)
	end
end

function AppLoopGetServerInfo:StateQuit()

end

function AppLoopGetServerInfo:SyncDitchID()
	local ditch_id = _sdk_helper:GetDitchID()
	if ditch_id then
		N3DClient.GameConfig.SetClientConfig("DitchID", ditch_id)
		self.req_state = self.req_state + 1
	end
end

function AppLoopGetServerInfo:StartGetServerInfo()
	self.req_state = 0
	self.req_cur_count = self.req_cur_count + 1

	local ditch_id = N3DClient.GameConfig.GetClientConfig("DitchID")
	local root_url_mode = N3DClient.GameConfig.GetClientConfig("RootUrlMode")
	local root_url = root_url_map[root_url_mode] or N3DClient.GameConfig.GetRootUrl(root_url_mode)
	if not ditch_id or not root_url then
		error("GetServerInfo Error: DitchID Or RootUrl is Null!")
		return
	end

	local url
	if app.Platform == "ios" then
		local app_version = N3DClient.GameConfig.GetClientConfig("AppVersion")
		local params = {
			["channel"] = ditch_id,
			["time"] = os.time(),
			["ios_version"] = app_version,
		}
		url = app.ServiceCtrl.instance:CalculateGetUrl(root_url, params)
	else
		local params = {
			["channel"] = ditch_id,
			["time"] = os.time(),
		}
		url = app.ServiceCtrl.instance:CalculateGetUrl(root_url, params)
	end

	print("Root Url:", url)

	global.HttpService:SendGetRequest(url, function(res, data)
		self:OnGetServerInfo(res, data)
	end)
end

function AppLoopGetServerInfo:OnGetServerInfo(result, data)
	if result and data and data ~= "" then
		local json_data = N3DClient.JsonConverter.ParseJsonToLua(data)
		if json_data and json_data.info == 1 then
			N3DClient.GameConfig.ClearServerConfig()
			for k,v in pairs(json_data.data) do
				N3DClient.GameConfig.SetServerConfig(k, v)
			end
			self.req_state = 1
			return
		end
	end

	print("GetServerInfo Error: Http Request Fail")
	if self.req_cur_count >= self.req_max_count then
		app.InitCtrl.instance:ShowNotice(true, app.words[11], function()
			app.AppLoop.instance:ChangeState(app.AppLoop.State.GetServerInfo)
			app.InitCtrl.instance:ShowNotice(false)
		end, function()
			UnityEngine.Application.Quit()
		end)
	else
		self.req_state = -1
	end
end

return AppLoopGetServerInfo
