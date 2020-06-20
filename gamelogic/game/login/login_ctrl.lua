
local LoginCtrl = Class(game.BaseCtrl)

local _ticket = "geh#3.*(=dda9&62Tdkfa[}dpw/%"

function LoginCtrl:_init()
	if LoginCtrl.instance ~= nil then
		error("LoginCtrl Init Twice!")
	end
	LoginCtrl.instance = self
	
	self.data = require("game/login/login_data").New()
	self.login_view = require("game/login/login_view").New(self)
	self.select_server_view = require("game/login/select_server_view").New(self)
	self.create_role_view = require("game/login/create_role_view").New(self)
	self.select_role_view = require("game/login/select_role_view").New(self)
	self.loading_view_bg = require("game/login/loading_view_bg").New(self)
	self.login_notice_view = require("game/login/login_notice_view").New(self)

	self:RegisterAllProtocal()
	self:RegisterErrorCallBack()
end

function LoginCtrl:_delete()
	self.data:DeleteMe()
	self.data = nil
	self.login_view:DeleteMe()
	self.login_view = nil
	self.create_role_view:DeleteMe()
	self.create_role_view = nil
	self.select_server_view:DeleteMe()
	self.select_server_view = nil
	self.select_role_view:DeleteMe()
	self.select_role_view = nil
	self.loading_view_bg:DeleteMe()
	self.loading_view_bg = nil
	self.login_notice_view:DeleteMe()
	self.login_notice_view = nil

	self:ClearLoginScene()

	LoginCtrl.instance = nil
end

function LoginCtrl:RegisterAllProtocal()
	self:RegisterProtocalCallback(90001, "OnRoleLoginCheckResp")
	self:RegisterProtocalCallback(90003, "OnGetRoleListResp")
	self:RegisterProtocalCallback(90007, "OnRoleCreateResp")
	self:RegisterProtocalCallback(90011, "OnSelectRoleLoginResp")
	self:RegisterProtocalCallback(90014, "OnGetDelRoleResp")
	self:RegisterProtocalCallback(90015, "OnGetPurgeRoleResp")
end

function LoginCtrl:RegisterErrorCallBack()
	self:RegisterErrorCodeCallback(105, function()
		game.GameNet:EnableReconnect(false)
	end)
end

function LoginCtrl:OpenLoginView()
	self.login_view:Open()
end

function LoginCtrl:CloseLoginView()
	self.login_view:Close()
end

function LoginCtrl:IsLoginViewOpen()
	return self.login_view:IsOpen()
end

function LoginCtrl:SetLoginEnable(val)
	if self.login_view:IsOpen() then
		self.login_view:EnableLogin(val)
	end
end

function LoginCtrl:SetSelectRoleEnable(val)
	if self.select_role_view:IsOpen() then
		self.select_role_view:SetEnable(val)
	end
end

function LoginCtrl:OpenCreateRoleView()
	self.create_role_view:Open()
end

function LoginCtrl:CloseCreateRoleView()
	self.create_role_view:Close()
end

function LoginCtrl:IsCreateViewOpen()
	return self.create_role_view:IsOpen()
end

function LoginCtrl:UpdateCreateView(now_time, elapse_time)
	self.create_role_view:Update(now_time, elapse_time)
end

function LoginCtrl:OpenSelectServerView()
	self.select_server_view:Open()
end

function LoginCtrl:CloseSelectServerView()
	self.select_server_view:Close()
end

function LoginCtrl:OpenSelectRoleView()
	self.select_role_view:Open()
end

function LoginCtrl:CloseSelectRoleView()
	self.select_role_view:Close()
end

function LoginCtrl:OpenLoginNoticeView()
	if not self.open_notice then
		self.login_notice_view:Open()
		self.open_notice = true
	end
end

function LoginCtrl:CloseLoginNoticeView()
	self.login_notice_view:Close()
end

function LoginCtrl:IsSelectRoleViewOpen()
	return self.select_role_view:IsOpen()
end

function LoginCtrl:UpdateSelectRoleView(now_time, elapse_time)
	self.select_role_view:Update(now_time, elapse_time)
end

-- data
function LoginCtrl:GetData()
	return self.data
end

function LoginCtrl:SetServerTime(time)
	self.data:SetServerTime(time)
end

function LoginCtrl:SetIsWhiteList(val)
	self.data:SetIsWhiteList(val)
end

function LoginCtrl:SetServerList(data)
	self.data:SetServerList(data)
end

function LoginCtrl:SetPersonList(data)
	self.data:SetPersonList(data)
end

function LoginCtrl:SetZoneList(data)
	self.data:SetZoneList(data)
end

function LoginCtrl:GetLoginServerInfo()
	return self.data:GetLastServerInfo()
end

function LoginCtrl:GetLoginServerID()
	return self.data:GetLastServerInfo().server_id
end

function LoginCtrl:GetLoginServerTitle()
	return self.data:GetLastServerInfo().title
end

function LoginCtrl:GetPerson(acc_name, role_id)
	return self.data:GetPerson(acc_name, role_id)
end

function LoginCtrl:GetLoginNotice()
    local title,content = self.data:GetLoginNotice()
    if not title then
        local notice_data = game.ServiceMgr:GetLoginNotice()
        self.data:SetLoginNoticeData(notice_data)
    end
    return self.data:GetLoginNotice()
end

function LoginCtrl:GetLoginAccount()
    return self.data:GetLoginAccount()
end

function LoginCtrl:GetRoleInfo(index)
	return self.data:GetRoleInfo(index)
end

function LoginCtrl:GetLastLoginRoleIndex()
	return self.data:GetLastLoginRoleIndex()
end

function LoginCtrl:GetLastLoginRoleInfo()
	return self.data:GetLastLoginRoleInfo()
end

-- proto 发送角色登陆检查
function LoginCtrl:SendRoleLoginCheck()
	-- print("SendRoleLoginCheck")
	local time_stamp = os.time()
	local acc_name = self.data:GetLoginAccount()
	local str = acc_name .. tostring(time_stamp) .. _ticket
	local md5 = N3DClient.GameTool.GetMD5(str)

	local proto = {}
	proto.timestamp = time_stamp
	proto.ticket = md5
	proto.accname = acc_name
	proto.server_id = self:GetLoginServerID()
	proto.device = global.SystemInfo:GetDeviceID()
	self:SendProtocal(90000, proto)
end

--角色登陆检查
function LoginCtrl:OnRoleLoginCheckResp(data_list)
	-- print("OnRoleLoginCheckResp")
	-- PrintTable(data_list)
	self:FireEvent(game.LoginEvent.LoginCheckResult, data_list.res, data_list.cur_login)

	if game.GameLoop.instance:GetCurState() == game.GameLoop.State.Reconnect then
		return
	end

	if data_list.res == 0 then
		-- 验证成功，获取角色列表
		if data_list.cur_login ~= 0 then
			-- 顶号判断
			local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[1002], config.words[1012])
			msg_box:SetOkBtn(function()
				msg_box:Close()
				msg_box:DeleteMe()
				game.GameLoop:ChangeState(game.GameLoop.State.Reconnect)
			end)
			msg_box:SetCancelBtn(function()
				msg_box:Close()
				msg_box:DeleteMe()
				self:SendRoleReloginReq(0)
				game.GameLoop:ChangeState(game.GameLoop.State.Start)
			end)
			msg_box:Open()
		else
			self:SendGetRoleListReq()
		end
	else
		-- 验证失败
		local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[1002], config.words[1003])
		msg_box:SetOkBtn(function()
			msg_box:Close()
			msg_box:DeleteMe()
			game.GameLoop:ChangeState(game.GameLoop.State.Start)
		end)
		msg_box:Open()
	end
end

--发送获取角色列表请求
function LoginCtrl:SendGetRoleListReq()
	self:SendProtocal(90002)
end

--获取角色列表
function LoginCtrl:OnGetRoleListResp(data_list)
	-- print("OnGetRoleListResp")
	-- PrintTable(data_list)
	self.data:SetRoleList(data_list.role_list)
	self:FireEvent(game.LoginEvent.LoginRoleListRet, data_list.role_list)
end

--刪除角色請求
function LoginCtrl:OnDelRoleResp(role_index,type)
	self.type = type
	local role_info = game.LoginData.instance:GetRoleInfo(role_index)
	local role_id = role_info.role_id

	local time_stamp = os.time()
	local str = string.toU64String(role_id) .. tostring(time_stamp).. _ticket
	local md5 = N3DClient.GameTool.GetMD5(str)

	local proto = {}
	proto.role_id = role_id
	proto.timestamp = time_stamp
	proto.ticket = md5
	proto.device = global.SystemInfo:GetDeviceID()
	proto.type = type
	self:SendProtocal(90013, proto)
end

--获取刪除角色請求 成功后更新状态
function LoginCtrl:OnGetDelRoleResp(data_list)
	if data_list.result == 0 then
		game.LoginCtrl.instance:SendGetRoleListReq()
		if self.type == 1 then
			game.SelectRoleView.instance:DelRole()
		else
			game.SelectRoleView.instance:CancelDelRole()
		end
	end
end

--获取角色是否删掉清除
function LoginCtrl:OnGetPurgeRoleResp(data_list)
	print(data_list)
end


function LoginCtrl:SendRoleCreate(name, gender, career, icon, hair)
	local proto = {}
	proto.name = name
	proto.gender = gender
	proto.career = career
	proto.icon = icon
	proto.hair = hair
	proto.source = N3DClient.GameConfig.GetClientConfig("DitchID")
	proto.server_id = self:GetLoginServerID()
	proto.device = global.SystemInfo:GetDeviceID()
	self:SendProtocal(90006, proto)
end

function LoginCtrl:OnRoleCreateResp(data_list)
	-- print("OnRoleCreateResp")
	-- PrintTable(data_list)
	if data_list.result == 0 then
		local reg_time = data_list.reg_time
		local role_info = {
			lv = 1,
			reg_time = reg_time,
			last_login_time = reg_time,
			nickname = data_list.role_name,
			state = 0,
			role_id = data_list.role_id,
			career = data_list.career,
			gender = data_list.gender,
			icon = data_list.icon,
			hair = data_list.hair,
			is_new = true,
		}
		self.data:AddRoleList(role_info)

		self:SendSelectRoleLogin(data_list.role_id)
	else
		self.create_role_view:SetEnable(true)
	end
end

function LoginCtrl:SendSelectRoleLogin(role_id)
	local time_stamp = os.time()
	local str = string.toU64String(role_id) .. tostring(time_stamp).. _ticket
	local md5 = N3DClient.GameTool.GetMD5(str)

	local proto = {}
	proto.role_id = role_id
	proto.timestamp = time_stamp
	proto.ticket = md5
	proto.device = global.SystemInfo:GetDeviceID()
	self:SendProtocal(90008, proto)
end

function LoginCtrl:OnSelectRoleLoginResp(data_list)
	global.EventMgr:Fire(game.LoginEvent.LoginRoleRet, data_list.result == 0)
end

function LoginCtrl:SendRoleReloginReq(val)
	self:SendProtocal(90012, {relogin = val})
end

-- 
function LoginCtrl:InitLoginScene()
	if not self.map then
	    self.map = require("game/scene/map").New()
	    self.map:LoadMap(30001)
	end
end

function LoginCtrl:ClearLoginScene()
	if self.map then
		self.map:DeleteMe()
		self.map = nil
	end

	self.login_scene_init = nil
	self.career_obj_list = nil
	self.role_model_list = nil
	self.camera_model_list = nil
end

function LoginCtrl:ClearLoginRes()
	self:ClearLoginScene()
	self:CloseLoginView()
	self:CloseSelectRoleView()
	self:CloseSelectServerView()
	self:CloseCreateRoleView()
end

function LoginCtrl:IsLoginSceneLoaded()
	if self.map:GetLoadState() and not self.login_scene_init then
		self:InitCreateRoleObjs()
	end
	return self.map:GetLoadState()
end

function LoginCtrl:GetLoginMap()
	return self.map
end

function LoginCtrl:InitCreateRoleObjs()
	local scene_info = UnityEngine.SceneManagement.SceneManager.GetSceneByName("30001")

	local scene_obj_list = scene_info:GetRootGameObjects()
	self.career_obj_list = {}
	self.role_model_list = {}
	self.camera_model_list = {}
	self.hair_model_list = {}

	for i = 1, scene_obj_list.Length do
		for _, v in pairs(config.career_init) do
			if scene_obj_list[i].name == "career" .. v.career then
				self.career_obj_list[v.career] = scene_obj_list[i]
				scene_obj_list[i].transform:SetAlwaysAnimate(true)

				local camera = UnityEngine.GameObject.Find("career" .. v.career .. "/camera")
				self.camera_model_list[v.career] = camera
				self.hair_model_list[v.career] = UnityEngine.GameObject.Find("career" .. v.career .. "/model/head/model")
				self.role_model_list[v.career] = UnityEngine.GameObject.Find("career" .. v.career .. "/model")
				self.role_model_list[v.career].transform:SetVisible(false)
			end
		end
	end

	self.login_scene_init = true
end

function LoginCtrl:GetCareerCreate(career)
	if self.career_obj_list then
		return self.career_obj_list[career]
	end
end

function LoginCtrl:GetRoleCreate(career)
	self.career = career
	if self.role_model_list then
		return self.role_model_list[career]
	end
end

function LoginCtrl:SetGender(vil)
	if vil == true then
		self.role_model_list[self.career]:SetPosition(1.4,0,1.8)
	else
		self.role_model_list[self.career]:SetPosition(0,0,0)
	end
end

function LoginCtrl:GetCameraCreate(career)
	if self.camera_model_list then
		return self.camera_model_list[career]
	end
end

function LoginCtrl:GetHairCreate(career)
	if self.hair_model_list then
		return self.hair_model_list[career]
	end
end

function LoginCtrl:OpenLoadingViewBG()
	self.loading_view_bg:Open()
end

function LoginCtrl:CloseLoadingViewBG()
	self.loading_view_bg:Close()
end

game.LoginCtrl = LoginCtrl

return LoginCtrl
