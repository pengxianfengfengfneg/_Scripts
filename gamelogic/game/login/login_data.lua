
local LoginData = Class(game.BaseData)

function LoginData:_init()

	LoginData.instance = self
end

function LoginData:_delete()
	LoginData.instance = nil
end

function LoginData:SetRoleList(data)
	self.role_list = {}
	for i,v in ipairs(data) do
		table.insert(self.role_list, v.info)
	end
end

function LoginData:AddRoleList(data)
	if not self.role_list then
		self.role_list = {}
	end
	local idx = #self.role_list + 1
	self.role_list[idx] = data
end

function LoginData:GetRoleListCount()
	if self.role_list then
		return #self.role_list
	else
		return 0
	end
end

function LoginData:GetRoleInfo(index)
	if self.role_list then
		return self.role_list[index]
	end
end

function LoginData:GetLastLoginRoleIndex()
	local last_login_time = 0
	local last_login_index = 0
	for i,v in ipairs(self.role_list or {}) do
		if v.last_login_time > last_login_time then
			last_login_index = i
			last_login_time = v.last_login_time
		end
	end
	return math.max(last_login_index, 1)
end

function LoginData:GetLastLoginRoleInfo()
	local index = self:GetLastLoginRoleIndex()
	return self:GetRoleInfo(index)
end

function LoginData:GetLoginAccount()
	return game.AccountInfo.account
end

function LoginData:SetIsWhiteList(val)
	self.is_white_list = (val == 1)
end

function LoginData:IsWhiteList()
	return self.is_white_list
end

function LoginData:SetServerTime(time)
	self.server_time = time
	self.server_local_time = os.time()
end

function LoginData:GetServerTime()
	if self.server_time then
		return self.server_time + os.time() - self.server_local_time
	else
		return os.time()
	end
end

function LoginData:SetZoneList(zone_list)
	self.zone_list = zone_list
	if not zone_list or #zone_list < 1 then
		self.zone_list = {
			[1] = {
				name = config.words[1050],
				list = {},
			}
		}
	end
end

function LoginData:GetZoneList()
	return self.zone_list
end

local function getAddrInfo(_domain)
    local ipv4, ipv6 = N3DClient.GameTool.GetIpAddress(_domain)
    if ipv6 then
    	return true, ipv6
    else
    	return false, ipv4
    end
end

function LoginData:SetServerList(data)
	self.all_server_list = {}
	self.recommend_server_list = {}
	for k,v in pairs(data) do
		local state = tonumber(v.default)
		-- 测试服/正式服/维护中/合服
		if state == 0 or state == 1 or state == 4 or state == 6 then
			local info = {}
			info.title = v.description
			info.game_ip = v.game_ip
			info.game_port = tonumber(v.game_port)
			info.server_id = tonumber(v.server_id)
			info.open_time = tonumber(v.otime)
			info.visible_time = tonumber(v.visible_time)
            info.is_recommend = v.recom_state == "1"
			info.shenhe = (v.shenhe == "1")
			if info.shenhe and game.Platform == "ios" then
				local isV6, addr = getAddrInfo(v.game_ip)
				info.game_ip = addr
			end
			
			if state == 0 then
				info.is_test = true
				info.state =  tonumber(v.hot_state)
			elseif state == 4 then
				info.state = 99
				info.is_repairing = true
				info.repair_notice = v.stop_service_describe
			else
				info.state =  tonumber(v.hot_state)
			end
			
			self.all_server_list[k] = info

            if info.is_recommend then
			    table.insert(self.recommend_server_list, info)
            end
		end
	end
end

function LoginData:GetZoneName(id)
	if self.zone_list[id] then
		return self.zone_list[id].name
	else
		return ""
	end
end

function LoginData:GetRecommendServerInfo()
    if self.recommend_server_list and #self.recommend_server_list >= 1 then
        return self.recommend_server_list[1]
    end
end

function LoginData:GetNewestServerInfo()
	local server_time = self:GetServerTime()
	for i,v in pairs(self.all_server_list) do
		if server_time >= v.open_time then
			return v
		end
	end
end

function LoginData:GetNextOpenServerInfo()
	local info = nil
	local server_time = self:GetServerTime()
	for i,v in pairs(self.all_server_list) do
		if server_time < v.open_time then
			info = v
		else
			break
		end
	end
	return info
end

function LoginData:GetAllServerList()
	return self.all_server_list
end

function LoginData:GetPerson(acc_name, role_id)
	local role_id_str = string.toU64String(role_id)
	for i,v in ipairs(self.person_list) do
		if v.accname == acc_name and v.role_id == role_id_str then
			return v
		end
	end
    return nil
end

function LoginData:SetPersonList(data)
	self.person_list = {}

	local login_time = 0
	local login_server = nil
	for k,v in pairs(data or {}) do
		local info = {}
		info.role_id = v.role_id
		info.role_name = v.nickname
		info.last_login_server = tonumber(v.last_login_server)
		info.last_login_time = tonumber(v.last_login_time)
		info.server_id = tonumber(v.server_id)
		info.reg_time = tonumber(v.reg_time)
		info.accname = v.accname
		table.insert(self.person_list, info)

		if info.last_login_time > login_time then
			login_time = info.last_login_time
			login_server = info.server_id
		end
	end
	table.sort(self.person_list, function(a, b)
		return a.last_login_time > b.last_login_time
	end)

	if login_server then
		self.last_server_info = self:GetServerInfo(login_server)
	end

	if not self.last_server_info then
		local log_server_id = global.UserDefault:GetInt("LastLoginServer")
		if log_server_id ~= 0 then
			self.last_server_info = self:GetServerInfo(log_server_id)
		end
	end

	self.server_info = self.last_server_info

	if not self.last_server_info then
		-- 自动选择推荐服务器 
        local recommend_server_info = self:GetRecommendServerInfo()
        local newest_server_info = self:GetNewestServerInfo()
        if recommend_server_info then
            self.last_server_info = recommend_server_info
        elseif newest_server_info then
            self.last_server_info = newest_server_info
        else
        	local server_time = self:GetServerTime()
            for k,v in pairs(self.all_server_list) do
                if not v.is_repairing and server_time >= v.visible_time then
                    if not self.last_server_info then
                        self.last_server_info = v
                    elseif self.last_server_info.open_time < v.open_time then
                        self.last_server_info = v
                    end
                end  
            end
        end
	end
	
	global.EventMgr:Fire(game.LoginEvent.LoginServerChange)
end

function LoginData:GetPersonList()
	return self.person_list
end

function LoginData:SetLastServerID(id)
	self.last_server_info = self:GetServerInfo(id)
	global.EventMgr:Fire(game.LoginEvent.LoginServerChange)
end

function LoginData:GetLastServerInfo()
	return self.last_server_info
end

function LoginData:GetServerInfo(id)
	for k,v in pairs(self.all_server_list) do
		if v.server_id == id then
			return v
		end
	end
end

--获取角色进入游戏的服务器信息
function LoginData:GetGameServerInfo()
	return self.server_info
end

function LoginData:SetLoginNoticeData(data)
    if not data then return end

    self.login_notice_data = data

    self.notice_title = data.data.title
    self.notice_content = data.data.content
	global.EventMgr:Fire(game.LoginEvent.LoginNoticeChange)
end

function LoginData:GetLoginNotice()
	return self.notice_title, self.notice_content
end

function LoginData:SetGameNotice(data)
    self.game_notice_data = data
end

function LoginData:GetGameNotice()
    return self.game_notice_data
end

game.LoginData = LoginData

return LoginData
