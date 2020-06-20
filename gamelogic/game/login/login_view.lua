
local LoginView = Class(game.BaseView)

local AudioMgr = global.AudioMgr

--登陆地址
local urlLogon = "http://120.78.87.199:99/login?"
--注册地址
local urlRegister = "http://120.78.87.199:99/register?"
--找回密码地址
local urlSeekPass = "http://120.78.87.199:99/repwd?"

function LoginView:_init(ctrl)
	self._package_name = "ui_login"
    self._com_name = "login_view"
	self._cache_time = 60

	self._view_level = game.UIViewLevel.Standalone

	self.ctrl = ctrl
	self.data = ctrl:GetData()
end

function LoginView:_delete()
	
end

--截取Json格式字符串
function LoginView:ExtractSubString(str)
	self.msg = string.sub(str,21,-3)
	print("msg",self.msg)
	self.code = string.sub(str,9,12)
	print("code",self.code)
end

function LoginView:OpenViewCallBack()
	self:PlayMusic()

	self._layout_objs["main"]:SetVisible(true)
	self._layout_objs["game"]:SetVisible(false)

	local login_name = global.UserDefault:GetString("Account")
	local login_password = global.UserDefault:GetString("Password")
	self.is_selected = global.UserDefault:GetBool("Selected")

	if self.is_selected ~= "" and self.is_selected ~= nil then
		if self.is_selected == true then
			self._layout_objs["btn_checkbox"].selected = self.is_selected
			self._layout_objs["n4"]:SetText(login_password)
		else
			self._layout_objs["btn_checkbox"].selected = self.is_selected
			self._layout_objs["n4"]:SetText("")
		end
	end

	self._layout_objs["n3"]:SetText(login_name)

	self._layout_objs["n5"]:SetTouchDisabled(false)
	self._layout_objs["n5"]:AddClickCallBack(function()
		self.ctrl:OpenSelectServerView()
	end)

	--打开注册界面
	self._layout_objs["btn_register"]:AddClickCallBack(function()
		self._layout_objs["touch_area"]:SetVisible(true)
		self._layout_objs["register"]:SetVisible(true)
		self._layout_objs["main"]:SetVisible(false)
		self:DelValue()
	end)
	--关闭注册界面
	self._layout_objs["btn_close"]:AddClickCallBack(function()
		self._layout_objs["touch_area"]:SetVisible(false)
		self._layout_objs["register"]:SetVisible(false)
		self._layout_objs["main"]:SetVisible(true)
	end)

	--注册
	self._layout_objs["btn_fixregister"]:AddClickCallBack(function()
		local reg_acc = self._layout_objs["reg_acc"]:GetText()
		local reg_pas = self._layout_objs["reg_pas"]:GetText()
		local reg_pasC = self._layout_objs["reg_pasC"]:GetText()
		local reg_email = self._layout_objs["reg_email"]:GetText()
		local reg_url = string.format("%susername=%s&password=%s&passwordC=%s&email=%s",
									   urlRegister,reg_acc,reg_pas,reg_pasC,reg_email)
		print("reg_url=",reg_url)
		global.HttpService:SendGetRequest(reg_url, function(success, data)
			self:ExtractSubString(data)

			if self.code ~= "1000" then
				return game.GameMsgCtrl.instance:PushMsg(self.msg)
			else
				self._layout_objs["register"]:SetVisible(false)
				self._layout_objs["touch_area"]:SetVisible(false)
				self._layout_objs["main"]:SetVisible(true)
				self._layout_objs["n3"]:SetText(reg_acc)
				self._layout_objs["n4"]:SetText(reg_pas)
				self._layout_objs["btn_checkbox"].selected = true
				game.GameMsgCtrl.instance:PushMsg("完成注册")
			end
		end)
	end)

	--确认登陆
	self._layout_objs["btn_login"]:AddClickCallBack(function()
		--if game.__DEBUG__ then
			local name = self._layout_objs["n3"]:GetText()
			local password = self._layout_objs["n4"]:GetText()
			local url	= string.format("%susername=%s&password=%s",urlLogon,name,password)
			global.HttpService:SendGetRequest(url,function(success, data)
				self:ExtractSubString(data)
				if name == "" then
					return game.GameMsgCtrl.instance:PushMsg("请输入账号")
					elseif password == "" then
						return game.GameMsgCtrl.instance:PushMsg("请输入密码")
				end

				if self.code ~= "1000" then
					return game.GameMsgCtrl.instance:PushMsg(self.msg)
				elseif self.code == "1000" then
					game.GameMsgCtrl.instance:PushMsg(self.msg)
					self._layout_objs["main"]:SetVisible(false)
					self._layout_objs["game"]:SetVisible(true)
					game.AccountInfo.account = name
					game.AccountInfo.password = password
					game.AccountInfo.isSelected = self._layout_objs["btn_checkbox"].selected

					global.UserDefault:SetString("Account", name)
					global.UserDefault:SetString("Password", password)
					global.UserDefault:SetBool("Selected", self._layout_objs["btn_checkbox"].selected)
					local accname = game.AccountInfo.account
					if accname then
						local server_info = self.data:GetLastServerInfo()
						if server_info == false then
							-- 未选服
							if game.__DEBUG__ then
								if not self.data:GetAllServerList() then
									game.GameLoop:ChangeState(game.GameLoop.State.SDKLogin)
								end
							end
						end
					end
				end
			end)
		--end

	end)

	--进入游戏
	self._layout_objs["n2"]:AddClickCallBack(function()
		--if game.__DEBUG__ then
			local accname = game.AccountInfo.account
			if accname then
				-- 已登录
				local server_info = self.data:GetLastServerInfo()
				if server_info then
					-- 已选服
					if self.data:IsWhiteList() then
						game.GameLoop:ChangeState(game.GameLoop.State.ConnectServer)
					elseif server_info.is_repairing then
						local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[1007], server_info.repair_notice)
						msg_box:SetOkBtn(function()
							msg_box:Close()
							msg_box:DeleteMe()
						end)
						msg_box:Open()
					elseif server_info.open_time > self.data:GetServerTime() then
						local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[1007], string.format(config.words[1010], game.Utils.ConvertToStyle1(server_info.open_time)))
						msg_box:SetOkBtn(function()
							msg_box:Close()
							msg_box:DeleteMe()
						end)
						msg_box:Open()
					else
						global.UserDefault:SetInt("LastLoginServer", server_info.server_id)
						game.GameLoop:ChangeState(game.GameLoop.State.ConnectServer)
					end
				else
					-- 未选服
					game.GameMsgCtrl.instance:PushMsg(config.words[1011])

					if game.__DEBUG__ then
						if not self.data:GetAllServerList() then
							game.GameLoop:ChangeState(game.GameLoop.State.SDKLogin)
						end
					end
				end
			else
				-- 未登录
				game.GameLoop:ChangeState(game.GameLoop.State.SDKLogin)
			end
		--end
	end)

	--打开找回密码界面
	self._layout_objs["btn_findpassword"]:AddClickCallBack(function()
		self._layout_objs["touch_area"]:SetVisible(true)
		self._layout_objs["seekpass"]:SetVisible(true)
		self._layout_objs["main"]:SetVisible(false)
		self:DelValue()
	end)

	--关闭找回密码界面
	self._layout_objs["btn_seekclose"]:AddClickCallBack(function()
		self._layout_objs["touch_area"]:SetVisible(false)
		self._layout_objs["seekpass"]:SetVisible(false)
		self._layout_objs["main"]:SetVisible(true)
	end)

	--找回密码
	self._layout_objs["btn_seekfix"]:AddClickCallBack(function()
		local seek_acc = self._layout_objs["seek_acc"]:GetText()
		local seek_pas = self._layout_objs["seek_pas"]:GetText()
		local seek_pasC = self._layout_objs["seek_pasC"]:GetText()
		local seek_email = self._layout_objs["seek_email"]:GetText()
		local urlseek	= string.format("%susername=%s&newpassword=%s&newpasswordC=%s&email=%s",
									urlSeekPass,seek_acc,seek_pas,seek_pasC,seek_email)
		global.HttpService:SendGetRequest(urlseek,function(success, data)
			self:ExtractSubString(data)
			if self.code ~= "1000" then
				return game.GameMsgCtrl.instance:PushMsg(self.msg)
			else
				self._layout_objs["seekpass"]:SetVisible(false)
				self._layout_objs["touch_area"]:SetVisible(false)
				self._layout_objs["main"]:SetVisible(true)
				game.GameMsgCtrl.instance:PushMsg("找回成功")
			end
		end)
	end)

	--if not game.__DEBUG__ then
	--	self._layout_objs["n3"]:SetVisible(false)
	--	self._layout_objs["n1"]:SetVisible(false)
	--end

	self:BindEvent(game.LoginEvent.LoginServerChange, function()
		self:RefreshServerInfo()
	end)
	self:RefreshServerInfo()
end

function LoginView:CloseViewCallBack()

end

--清空值
function LoginView:DelValue()
	--注册
	self._layout_objs["reg_acc"]:SetText("")
	self._layout_objs["reg_pas"]:SetText("")
	self._layout_objs["reg_pasC"]:SetText("")
	self._layout_objs["reg_email"]:SetText("")
	--找回密码
	self._layout_objs["seek_acc"]:SetText("")
	self._layout_objs["seek_pas"]:SetText("")
	self._layout_objs["seek_pasC"]:SetText("")
	self._layout_objs["seek_email"]:SetText("")
end


function LoginView:EnableLogin(val)
	if self:IsOpen() then
		self._layout_objs["n2"]:SetEnable(val)
		self._layout_objs["n5"]:SetEnable(val)
	end
end

function LoginView:RefreshServerInfo()
	local last_server_info = self.data:GetLastServerInfo()
	if last_server_info then
		self._layout_objs["n7"]:SetVisible(true)
		self._layout_objs["server_name"]:SetText(last_server_info.title)
		self._layout_objs["server_state"]:SetSprite("ui_login", "cj_" .. last_server_info.state)
	else
		self._layout_objs["n7"]:SetVisible(false)
	end
end

function LoginView:PlayMusic()
	AudioMgr:EnableMusic(true)
	AudioMgr:SetMusicVolume(30*0.01)
	AudioMgr:PlayMusic("bg_cj_nndj")
end

return LoginView
