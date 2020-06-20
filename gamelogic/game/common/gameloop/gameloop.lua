
local GameLoop = Class()

GameLoop.State = {
	Start = 1,
	SDKLogin = 2,
	GetServerInfo = 3,
	SelectServer = 4,
	ConnectServer = 5,
	Login = 6,
	CreateRole = 7,
	SelectRole = 8,
	LoginSuccess = 9,
	Play = 10,
	Loading = 11,
	Restart = 12,
	Reconnect = 13,
}

function GameLoop:_init()
	if GameLoop.instance ~= nil then
		error("GameLoop Init Twice!")
	end
	GameLoop.instance = self

	self.stat_machine = global.StateMachine.New()

	local start_state = require("game/common/gameloop/gameloop_start").New()
	self.stat_machine:AddState(GameLoop.State.Start, start_state)

	local sdk_login_state = require("game/common/gameloop/gameloop_sdk_login").New()
	self.stat_machine:AddState(GameLoop.State.SDKLogin, sdk_login_state)

	local get_server_info_state = require("game/common/gameloop/gameloop_get_server_info").New()
	self.stat_machine:AddState(GameLoop.State.GetServerInfo, get_server_info_state)

	local select_server_state = require("game/common/gameloop/gameloop_select_server").New()
	self.stat_machine:AddState(GameLoop.State.SelectServer, select_server_state)

	local connect_server_state = require("game/common/gameloop/gameloop_connect_server").New()
	self.stat_machine:AddState(GameLoop.State.ConnectServer, connect_server_state)

	local login_state = require("game/common/gameloop/gameloop_login").New()
	self.stat_machine:AddState(GameLoop.State.Login, login_state)

	local create_role_state = require("game/common/gameloop/gameloop_create_role").New()
	self.stat_machine:AddState(GameLoop.State.CreateRole, create_role_state)

	local select_role_state = require("game/common/gameloop/gameloop_select_role").New()
	self.stat_machine:AddState(GameLoop.State.SelectRole, select_role_state)

	local login_success_state = require("game/common/gameloop/gameloop_login_success").New()
	self.stat_machine:AddState(GameLoop.State.LoginSuccess, login_success_state)

	local loading_state = require("game/common/gameloop/gameloop_loading").New()
	self.stat_machine:AddState(GameLoop.State.Loading, loading_state)

	local play_state = require("game/common/gameloop/gameloop_play").New()
	self.stat_machine:AddState(GameLoop.State.Play, play_state)

	local restart_state = require("game/common/gameloop/gameloop_restart").New()
	self.stat_machine:AddState(GameLoop.State.Restart, restart_state)

	local reconnect_state = require("game/common/gameloop/gameloop_reconnect").New()
	self.stat_machine:AddState(GameLoop.State.Reconnect, reconnect_state)

	self.loading_view = require("game/common/gameloop/gameloop_loading_view").New()

	global.Runner:AddUpdateObj(self, 2)
end

function GameLoop:_delete()
	if self.loading_view then
		self.loading_view:DeleteMe()
		self.loading_view = nil
	end
	if self.stat_machine then
		self.stat_machine:DeleteMe()
		self.stat_machine = nil
	end
	global.Runner:RemoveUpdateObj(self)
	GameLoop.instance = nil
end

function GameLoop:Reset()
	self.loading_view:Reset()

	local loading_state = self.stat_machine:GetState(GameLoop.State.Loading)
	if loading_state then
		loading_state:Reset()
	end
end

function GameLoop:Start()
	self:Reset()
	self:ChangeState(GameLoop.State.Start)
end

function GameLoop:Update(now_time, elapse_time)
	self.stat_machine:Update(now_time, elapse_time)
end

function GameLoop:ChangeState(id, param)
	self.stat_machine:ChangeState(id, param)
end

function GameLoop:GetCurState()
	return self.stat_machine:GetCurStateID()
end

function GameLoop:GetLoadingView()
	return self.loading_view
end

function GameLoop:SetLoadingPercent(percent)
	if self.loading_view:IsOpen() then
		self.loading_view:SetPercent(percent)
	end
end

game.GameLoop = GameLoop.New()

return GameLoop
