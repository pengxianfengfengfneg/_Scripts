
local GameLoopConnectServer = Class()

function GameLoopConnectServer:_init()

end

function GameLoopConnectServer:_delete()

end

function GameLoopConnectServer:StateEnter()
	game.LoginCtrl.instance:SetLoginEnable(false)

	local server_info = game.LoginCtrl.instance:GetLoginServerInfo()
	game.GameNet:ConnectGameNetAsyn(server_info.game_ip, server_info.game_port, 8000)

	game.GameNet:SetDiconnectCallback(function()
		game.GameNet:OpenDisconnectView(function()
			game.GameLoop:ChangeState(game.GameLoop.State.SelectServer)
		end)
	end)
end

function GameLoopConnectServer:StateUpdate(now_time, elapse_time)
	if game.GameNet:IsGameNetConnect() then
		collectgarbage("collect")
		game.GameLoop:ChangeState(game.GameLoop.State.Login)
	end
end

function GameLoopConnectServer:StateQuit()
	game.GameNet:SetDiconnectCallback()
end

return GameLoopConnectServer