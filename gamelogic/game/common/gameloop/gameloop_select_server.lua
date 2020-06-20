
local GameLoopSelectServer = Class()

function GameLoopSelectServer:_init()

end

function GameLoopSelectServer:_delete()

end

function GameLoopSelectServer:StateEnter()
	print("GameLoopSelectServer")
	game.GameMsgCtrl.instance:CloseWaitingView()
	game.LoginCtrl.instance:OpenLoginView()
	game.LoginCtrl.instance:SetLoginEnable(true)
	game.GameNet:DisconnectGameNet()
	game.LoginCtrl.instance:OpenLoginNoticeView()
end

function GameLoopSelectServer:StateUpdate(now_time, elapse_time)

end

function GameLoopSelectServer:StateQuit()

end

return GameLoopSelectServer