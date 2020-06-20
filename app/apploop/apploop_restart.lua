
local AppLoopRestart = Class()

function AppLoopRestart:_init()

end

function AppLoopRestart:_delete()

end

function AppLoopRestart:StateEnter()
	if app.InitCtrl.instance:IsViewOpen() then
		app.InitCtrl.instance:SetLoadingTxt(app.words[8])
		app.InitCtrl.instance:SetLoadingValue(0)
		self.state = 1
		self.state_end_time = global.Time.now_time + 1
	else
		self.state = 2
		self.state_end_time = global.Time.now_time + 1
		N3DClient.UIManager:GetInstance():GetCamera().clearFlags = UnityEngine.CameraClearFlags.Color
	end
end

function AppLoopRestart:StateUpdate(now_time, elapse_time)
	if self.state == 1 then
		if now_time > self.state_end_time then
			app.InitCtrl.instance:CloseView()
			app.InitCtrl.instance:UnloadInitRes()
			app.InitCtrl.instance:DeleteMe()
			self.state = 2
		else
			app.InitCtrl.instance:SetLoadingValue((1 - self.state_end_time + now_time) * 100)
		end
	elseif self.state == 2 then
		if global.AssetLoader:GetWaitTaskNum() ~= 0 and global.AssetLoader:GetRunTaskNum() ~= 0 then
			self.free_time = now_time + 1
		else
			if now_time > self.free_time then
				global.AudioMgr:DeleteMe()
				global.AoiMgr:DeleteMe()
				app.AppLoop:DeleteMe()
				N3DClient.UIManager:GetInstance():RemoveAllUIPackage()
				global.AssetLoader:DeleteMe()

				collectgarbage("collect")

				N3DClient.AppDelegate:GetInstance():Restart()
			end
		end
	end
end

function AppLoopRestart:StateQuit()

end

return AppLoopRestart
