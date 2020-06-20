
local GameLoopLoginSuccess = Class()

function GameLoopLoginSuccess:_init()

end

function GameLoopLoginSuccess:_delete()

end

function GameLoopLoginSuccess:StateEnter()
	print("GameLoopLoginSuccess")
	game.Scene.instance:SendRoleEnterSceneInfoReq()
	game.Scene.instance:SendRoleInitInfoReq()
    global.EventMgr:Fire(game.LoginEvent.LoginSuccess)
end

function GameLoopLoginSuccess:StateUpdate(now_time, elapse_time)
	-- local param = {}
 --    param.scene_id = 80001
 --    param.unit_pos = cc.vec2(15, 15)
 --    game.GameLoop:ChangeState(game.GameLoop.State.Loading, param)
end

function GameLoopLoginSuccess:StateQuit()
	game.LoginCtrl.instance:ClearLoginRes()
end

return GameLoopLoginSuccess
