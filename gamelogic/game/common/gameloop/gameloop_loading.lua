
local GameLoopLoading = Class()

function GameLoopLoading:_init()
	self.is_first_enter = true
end

function GameLoopLoading:_delete()

end

function GameLoopLoading:Reset()
	self.is_first_enter = true
end

function GameLoopLoading:StateEnter(param)
	print("GameLoopLoading")
	game.LoginCtrl.instance:ClearLoginRes()

	self.scene = game.Scene.instance
    self.scene_id = param.scene_id
    self.scene_pos = param.unit_pos

    self.scene:PreLoadScene(self.scene_id)

	local map_id = self.scene:GetMapId()

	local line_id = self.scene:GetServerLine()
	self.view = game.GameLoop.instance:GetLoadingView()
	self.view:Open(self.scene_id, map_id, line_id)

	self.state = 0
	game.RenderUnit:SetUICameraClearColor(false)

    global.AssetLoader:SetUpdateInterval(0)
    game.CacheMgr:SetUpdateInterval(0)

	self.max_wait_net_time = global.Time.now_time + 10
	self.start_map_time = 0
	self.cur_value = 0
	UnityEngine.Application.backgroundLoadingPriority = 4
end

function GameLoopLoading:StateUpdate(now_time, elapse_time)
	if not self.view:IsOpen() then
		return
	end

	if self.state == 0 then
		self.scene:ChangeScene(self.scene_id, self.scene_pos)
		self.state = 1
	elseif self.state == 1 then
		self.scene:ResetSceneResInfo()
		self.scene:ClearScene(false, self.scene_id)
    	game.CacheMgr:UnloadUnuseCache()
        global.AssetLoader:UnLoadUnuseBundle()
		self.state = 2
    elseif self.state == 2 then
		collectgarbage("collect")
		N3DClient.GameTool.RunGC()		
		self.state = 3
	elseif self.state == 3 then
    	self.scene:LoadScene()

		game.MainUICtrl.instance:OpenRumorView()
		game.MainUICtrl.instance:OpenChatHornView()
		game.MainUICtrl.instance:OpenDropItemView()
    	game.MainUICtrl.instance:OpenView()

		self.state = 4
	elseif self.state == 4 then	
		local is_finish, percent = self.scene:GetSceneLoadState()
		self.cur_value = math.min(self.cur_value + 0.04, percent)
		game.GameLoop:SetLoadingPercent(self.cur_value)
		if is_finish then
			game.GameLoop:SetLoadingPercent(1)
			self.start_map_time = now_time + 0.5
			self.state = 5
		end
	elseif self.state == 5 then
		if now_time > self.start_map_time then
			if game.GameNet:FirstLoadingReady() or (now_time > self.max_wait_net_time) then
	    		self.state = 6
	    	end
	    end
    elseif self.state == 6 then
    	self.scene:PrepareScene()
		
    	self.state = 7
    elseif self.state == 7 then
    	if game.MainUICtrl.instance:IsViewOpen() then
    		if self.view:IsDone() then
		        game.GameLoop:ChangeState(game.GameLoop.State.Play)
		    end
    	end
    end
end

function GameLoopLoading:StateQuit()
    self.view:Close()
    self.view = nil

    global.AssetLoader:SetUpdateInterval(0.03)
    game.CacheMgr:SetUpdateInterval(0.2)
    -- game.RenderUnit:SetUICameraClearColor(false)

	UnityEngine.Application.backgroundLoadingPriority = 1
end

return GameLoopLoading
