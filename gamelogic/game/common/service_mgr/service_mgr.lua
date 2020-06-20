
local ServiceMgr = Class()

local secret_key = "2c41a3ddd23d1a1f711b7f37df4d515a"

function ServiceMgr:_init()
	self.admin_url = N3DClient.GameConfig.GetServerConfig("admin_url")
	self.platform_id = N3DClient.GameConfig.GetClientConfig("DitchID")
	self.app_version = N3DClient.GameConfig.GetClientConfig("AppVersion")
	self.game_id = N3DClient.GameConfig.GetServerConfig("game_id")
	self.pos_url = N3DClient.GameConfig.GetServerConfig("pos_url")
	self.device_id = global.SystemInfo:GetDeviceID()
	self.os = UnityEngine.Application.platform

	self.enable_err_report = N3DClient.GameConfig.GetClientConfigBool("LuaErrReport", false)
	self.report_err_mark = false
	
	-- self.enable_bugly = N3DClient.GameConfig:GetClientConfig("BuglyEnable") == "true"
	-- if self.enable_bugly then
	-- 	if self.os == cc.PLATFORM_OS_ANDROID or self.os == cc.PLATFORM_OS_IPHONE or self.os == cc.PLATFORM_OS_IPAD then
	-- 		buglyAddUserValue("DitchID", self.platform_id)
	-- 		buglyAddUserValue("AppVersion", cc.GameConfig:getClientConfig("AppVersion"))
	-- 		buglyAddUserValue("ResVersion", cc.UserDefault:getInstance():getStringForKey("ResVersion"))
	-- 	end
	-- end

	self.sync_create_role = false
	self.sync_update_role = false
end

function ServiceMgr:_delete()

end

function ServiceMgr:Start()
	self.sync_create_role = false
	self.sync_update_role = false
end

function ServiceMgr:GetDitchID()
	return self.platform_id
end

function ServiceMgr:GetAdminUrl()
	return self.admin_url
end

function ServiceMgr:GetLoginNotice()
	return self.login_notice_data
end

function ServiceMgr:SendErrReport(err)
	if self.enable_err_report then
		if not self.report_err_mark then
			self.report_err_mark = true

			local server_id = -1
			local role_id = 0
			local name = "no_role"
			local level = -1
			if game.Scene and game.Scene.instance then
				local main_role_vo = game.Scene.instance:GetMainRoleVo()
				if main_role_vo then
					server_id = main_role_vo.server_num
					role_id = main_role_vo.role_id
					name = main_role_vo.name
					level = main_role_vo.level
		    	end
		    end

		    local api_interface = N3DClient.GameConfig.GetServerConfig("error_url")
			local url = string.format("%s%s", self.admin_url, api_interface)

			local data_map = {}
			data_map["channel"] = self.platform_id
			data_map["content"] = string.urlencode(err)
			data_map["server_id"] = server_id
			data_map["role_id"] = string.toU64String(role_id)
			data_map["nick_name"] = string.urlencode(name)
			data_map["level"] = level
			data_map["time"] = os.time()
			self:CalcTicket(data_map)

			-- release_print("SendErrReport")
			global.HttpService:SendPostRequest(url, data_map, function(success, data)
				-- release_print("SendErrReportRespond", success, data)
			end)
		end
	end
end

--请求服务器列表
function ServiceMgr:RequestServerList(accname, callback)
    local api_interface = N3DClient.GameConfig.GetServerConfig("server_url")
	local url = string.format("%s%s", self.admin_url, api_interface)

	local data_map = {}
	data_map["accname"] = accname
	data_map["channel"] = self.platform_id
	data_map["ios_version"] = self.app_version
	data_map["device_id"] = self.device_id
	data_map["time"] = os.time()
	self:CalcTicket(data_map)

	-- release_print("RequestServerList", url)
	-- PrintTable(data_map)
	global.HttpService:SendPostRequest(url, data_map, function(success, data)
		-- release_print("RequestServerList", data)
		callback(success, data)
	end)
end

--请求服务器通知
function ServiceMgr:RequestServerNotice(callback)
	if self.login_notice_data and os.time() <= self.login_notice_deadline then
		return
	end

	self.login_notice_data = nil
	self.login_notice_deadline = os.time()

    local api_interface = N3DClient.GameConfig.GetServerConfig("notice_url")
	local url = string.format("%s%s", self.admin_url, api_interface)

	local data_map = {}
	data_map["channel"] = self.platform_id
	data_map["time"] = os.time()
	self:CalcTicket(data_map)

	-- release_print("RequestServerNotice", url)
	global.HttpService:SendPostRequest(url, data_map, function(success, data)
		-- release_print("RequestServerNoticeResponse", success, data)
		if success and data then
			local json_data = N3DClient.JsonConverter.ParseJsonToLua(data)
			if json_data and json_data.info == 1 then
				self.login_notice_data = json_data
				callback(json_data)
			end
		end
	end)
end

function ServiceMgr:SendCreateRole(accname, server_id, role_id, nickname)
	if self.sync_create_role then
		return
	end
	self.sync_create_role = true

    local api_interface = N3DClient.GameConfig.GetServerConfig("reg_url")
	local url = string.format("%s%s", self.admin_url, api_interface)

	local data_map = {}
	data_map["channel"] = self.platform_id
	data_map["accname"] = accname
	data_map["sid"] = server_id
	data_map["device_id"] = self.device_id
	data_map["os"] = self.os
	data_map["nickname"] = string.urlencode(nickname)
	data_map["role_id"] = string.toU64String(role_id)
	data_map["time"] = os.time()
	self:CalcTicket(data_map)

    -- release_print("SendCreateRole", url)
	-- PrintTable(data_map)
    global.HttpService:SendPostRequest(url, data_map, function(success, data)
        -- print("SendCreateRoleResponse", success, data)
    end)
end

function ServiceMgr:UpdateRoleInfo(accname, create_server_id, server_id, role_id, nickname, level)
	if self.sync_update_role then
		return
	end
	self.sync_update_role = true

    local api_interface = N3DClient.GameConfig.GetServerConfig("update_url")
	local url = string.format("%s%s", self.admin_url, api_interface)

	local data_map = {}
	data_map["channel"] = self.platform_id
	data_map["accname"] = accname
	data_map["server_id"] = create_server_id
	data_map["last_login_server"] = server_id
	data_map["nickname"] = string.urlencode(nickname)
	data_map["role_id"] = string.toU64String(role_id)
	data_map["level"] = level
	data_map["time"] = os.time()
	self:CalcTicket(data_map)

    -- release_print("UpdateRoleInfo", url)
	-- PrintTable(data_map)
    global.HttpService:SendPostRequest(url, data_map, function(success, data)
        -- print("UpdateRoleInfoResponse", success, data)
    end)
end

function ServiceMgr:RequestGetGift(gift_id_str, callback)
	local role_id
	local server_id
	if game.Scene and game.Scene.instance then
	    local main_role_vo = game.Scene.instance:GetMainRoleVo()
	    if main_role_vo then
	        role_id = main_role_vo.role_id
	        server_id = main_role_vo.server_num
	    end
	end

	if not role_id then
		return
	end

    local api_interface = N3DClient.GameConfig.GetServerConfig("card_url")
	local url = string.format("%s%s", self.admin_url, api_interface)

	local data_map = {}
	data_map["sid"] = game.LoginCtrl.instance:GetLoginServerID()
	data_map["role_id"] = string.toU64String(role_id)
	data_map["card_no"] = gift_id_str
	data_map["time"] = os.time()

	self:CalcTicket(data_map)

	global.HttpService:SendPostRequest(url, data_map, function(success, data)
		callback(success, data)
	end)
end

function ServiceMgr:SendDeviceCount(step)
	if not self.pos_url then
		return nil
	end
	local url = self.admin_url .. self.pos_url
	local data_map = {}
	data_map["channel"] = self.platform_id
	data_map["dev"] = self.device_id
	data_map["pos"] = step
	data_map["time"] = os.time()
	local res_url = self:CalculateGetUrl(url, data_map)

	global.HttpService:SendGetRequest(res_url, function(success, data)
		--release_print("发送设备统计结果", success, res_url, data)
	end)
end

function ServiceMgr:VerifyToken(code, callback)
    local api_interface = N3DClient.GameConfig.GetServerConfig("verify_url")
	local url = string.format("%s%s", self.admin_url, api_interface)

	local data_map = {}
	data_map["channel"] = self.platform_id
	data_map["token"] = code
	data_map["game_id"] = self.game_id
	data_map["time"] = os.time()
	self:CalcTicket(data_map)

	-- release_print("#### VerifyToken", url, string.format("channel=%s&token=%s&game_id%s&time=%s&ticket=%s", tostring(data_map["channel"]),tostring(data_map["token"]),tostring(data_map["game_id"]),tostring(data_map["time"]),tostring(data_map["ticket"])))
	global.HttpService:SendPostRequest(url, data_map, function(success, data)
		-- release_print("#### VerifyToken", data)
		callback(success, data)
	end)
end

-- sid	int	服务器ID
-- role_id	int	角色id
-- money	int	充值金额 单位分
-- product_id int 商品id
function ServiceMgr:RequestOrder(accname, sid, role_id, money, product_id, callback)
    local api_interface = N3DClient.GameConfig.GetServerConfig("order_url")
	local url = string.format("%s%s", self.admin_url, api_interface)

	local data_map = {}
	data_map["accname"] = accname
	data_map["channel"] = self.platform_id
	data_map["sid"] = sid
	data_map["money"] = money
	data_map["product_id"] = product_id
	data_map["role_id"] = string.toU64String(role_id)
	data_map["time"] = os.time()
	self:CalcTicket(data_map)

	-- release_print("RequestOrder", url, product_id)
	global.HttpService:SendPostRequest(url, data_map, function(success, data)
		-- release_print("RequestOrder", data)
		callback(success, data)
	end)
end

function ServiceMgr:CalcTicket(val_tb)
	local val_list = {}
	for k,v in pairs(val_tb) do
		table.insert(val_list, {k, v})
	end

	local com_func = N3DClient.GameTool.CampareString
	table.sort(val_list, function(a, b)
		return com_func(a[1], b[1]) == -1
	end)

	local secret_str = ""
	for i,v in ipairs(val_list) do
		if i > 1 then
			secret_str = secret_str .. "&"
		end
		secret_str = secret_str .. v[1] .. "=" .. v[2]
	end
	secret_str = secret_str .. secret_key

	val_tb["ticket"] = N3DClient.GameTool.GetMD5FromUtf8(secret_str)
end

function ServiceMgr:CalculateGetUrl(rootUrl, valTable)
	local keys = table.keys(valTable)
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
		table.insert(calc_str_tab, valTable[v])
	end
	local calc_str = table.concat(calc_str_tab, "")
	local ticket = calc_str .. secret_key
	ticket = N3DClient.GameTool.GetMD5FromUtf8(ticket)

	local res_url_tab = {}
	table.insert(res_url_tab, rootUrl)
	table.insert(res_url_tab, "?")
	table.insert(res_url_tab,  calc_str)
	table.insert(res_url_tab,  "&ticket=")
	table.insert(res_url_tab, ticket)
	local res_url = table.concat(res_url_tab, "")
	return res_url
end

game.ServiceMgr = ServiceMgr.New()

