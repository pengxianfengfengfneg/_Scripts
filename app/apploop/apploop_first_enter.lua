
local AppLoopFirstEnter = Class()

function AppLoopFirstEnter:_init()

end

function AppLoopFirstEnter:_delete()

end

function AppLoopFirstEnter:StateEnter()
	print("AppLoopFirstEnter")
	local res_mode = N3DClient.GameConfig.GetClientConfigBool("ResRawMode")
	if res_mode then
		app.AppLoop.instance:ChangeState(app.AppLoop.State.GetServerInfo)
	else
		local cfg_app_date = N3DClient.GameConfig.GetClientConfig("AppDate", "0")
		local db_app_date = global.UserDefault:GetString("AppDate")
		if cfg_app_date ~= db_app_date then
			global.UserDefault:SetInt("ResVersion", 0)
			N3DClient.AssetPathCache:GetInstance():DropDB()
			global.UserDefault:SetString("AppDate", cfg_app_date)
		end
	end
end

function AppLoopFirstEnter:StateUpdate(now_time, elapse_time)
	app.AppLoop.instance:ChangeState(app.AppLoop.State.GetServerInfo)
end

function AppLoopFirstEnter:StateQuit()

end

return AppLoopFirstEnter
