
local AppLoopLoadingScript = Class()

function AppLoopLoadingScript:_init()

end

function AppLoopLoadingScript:_delete()

end

function AppLoopLoadingScript:StateEnter()
	print("AppLoopLoadingScript")
	app.InitCtrl.instance:SetLoadingTxt(app.words[4])
	app.InitCtrl.instance:SetLoadingValue(0)

	self.req_list = {}

	self.script_raw_mode = N3DClient.GameConfig.GetClientConfigBool("ScriptRawMode")
	self.res_raw_mode = N3DClient.GameConfig.GetClientConfigBool("ResRawMode")
	if self.script_raw_mode then
		local path = N3DClient.GameConfig.GetClientConfig("ScriptConfigPath")
		if path ~= "" then
			N3DClient.ScriptManager:GetInstance():AddSearchPath(path)
		end
		
		path = N3DClient.GameConfig.GetClientConfig("ScriptGamePath")
		if path ~= "" then
			N3DClient.ScriptManager:GetInstance():AddSearchPath(path)
		end
	end

	self:LoadAsset()
end

function AppLoopLoadingScript:StateUpdate(now_time, elapse_time)
end

function AppLoopLoadingScript:StateQuit()
	for i,v in ipairs(self.req_list) do
		global.AssetLoader:UnLoad(v)
	end
	self.req_list = nil
end

function AppLoopLoadingScript:LoadAsset()
	if self.res_raw_mode then
		self:LoadScript()
	else
		local num = 0
		local callback = function()
			num = num + 1
			if num == #self.req_list then
				self:LoadScript()
			end
		end
		table.insert(self.req_list, global.AssetLoader:LoadAsset("data2.ab", "data", callback))
		table.insert(self.req_list, global.AssetLoader:LoadAsset("data3.ab", "data", callback))
	end
end

function AppLoopLoadingScript:LoadScript()
	if not self.res_raw_mode then
		local seed = global.UserDefault:GetInt("Seed")
		if seed == 0 then
			seed = N3DClient.AssetPathCache:GetInstance():GetDefaultDecryteSeed()
		end
		N3DClient.ScriptManager:GetInstance():AddSearchBundle("data2.ab", "data", seed)
		N3DClient.ScriptManager:GetInstance():AddSearchBundle("data3.ab", "data", seed)
	end
	require("init")
	app.Game = require("main")
	app.AppLoop.instance:ChangeState(app.AppLoop.State.LoadingRes)
end

return AppLoopLoadingScript
