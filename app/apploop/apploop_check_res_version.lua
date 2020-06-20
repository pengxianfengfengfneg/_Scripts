
local AppLoopCheckResVersion = Class()

function AppLoopCheckResVersion:_init()

end

function AppLoopCheckResVersion:_delete()

end

function AppLoopCheckResVersion:StateEnter()
	print("AppLoopCheckResVersion")
	global.UserDefault:SetInt("LastCheckResTime", os.time())

	local update_res_enable = N3DClient.GameConfig.GetClientConfigBool("UpdateResEnable")
	if not update_res_enable then
		app.AppLoop.instance:ChangeState(app.AppLoop.State.LoadingScript)
	else
		app.InitCtrl.instance:SetLoadingTxt(app.words[3])
		app.InitCtrl.instance:SetLoadingValue(0)
		app.ServiceCtrl.instance:StartGetVersion(3, function(result)
			if result then
				local new_version = app.ServiceCtrl.instance:GetNewVersion()
				local cur_version = global.UserDefault:GetInt("ResVersion")
				print(string.format("AppLoopCheckResVersion Success: %d %d", new_version, cur_version))

				local app_version = N3DClient.GameConfig.GetClientConfig("AppVersion")
				app.InitCtrl.instance:SetVersion(app_version, tostring(new_version))
				if new_version == cur_version then
					app.AppLoop.instance:ChangeState(app.AppLoop.State.LoadingScript)
				else
					app.AppLoop.instance:ChangeState(app.AppLoop.State.GetFileList)
				end
			else
				print("AppLoopCheckResVersion Fail")
				app.AppLoop.instance:ChangeState(app.AppLoop.State.LoadingScript)
			end
		end)
	end
end

function AppLoopCheckResVersion:StateUpdate(now_time, elapse_time)

end

function AppLoopCheckResVersion:StateQuit()

end

return AppLoopCheckResVersion
