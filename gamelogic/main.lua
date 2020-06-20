require("extention/init")
require("game/init")

game.AccountInfo = {}
game.__DEBUG__ = N3DClient.GameConfig.GetClientConfig("GameMode") == "dev"
game.IsEditorMode = UnityEngine.Application.isEditor
if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.Android then
	game.Platform = "android"
elseif UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer then
	game.Platform = "ios"
else
	game.Platform = "win"
end

game.IsZhuanJia = false

__G__TRACKBACK__ = function(msg)
	local err = debug.traceback(msg, 3)

    if game.__DEBUG__ then
	    print(err)
        --game.GmCtrl.instance:OpenErrorView(err)
    end

	game.ServiceMgr:SendErrReport(msg, err)
	return err
end

local Game = {}

local preload_req_list = {}
local preload_finish_num = 0
local log_mode = N3DClient.GameConfig.GetClientConfigInt("LogMode", 0)

local common_res = {
	{"shader/default.ab", nil, false},
	{"shader/standard.ab", nil, false},
	{"model/other/shadow.ab", nil},
	{"model/other/light.ab", nil},
	{"ui/ui_common.ab", nil, true},
	{"ui/ui_common_bg.ab", nil, true},
	{"ui/ui_item.ab", nil, true},
	{"ui/ui_title.ab", nil, true},
	{"ui/ui_skill_icon.ab", nil, true},
	{"ui/ui_headicon.ab", nil, true},
	{"ui/ui_emoji.ab", nil, true},
	{"ui/ui_emoji_chat.ab", nil, true},
}

function Game.Init()
	DOTween.defaultEaseType = game.TweenEase.Linear
	math.randomseed(os.time())
	game.RenderUnit:Start()
	global.AssetLoader:InitDependency()
end

function Game.Preload()
	preload_req_list = {
		global.AssetLoader:LoadAllAsset("default.ab", false, function()
			preload_finish_num = preload_finish_num + 1
		end),
		global.AssetLoader:LoadAsset("controller.ab", "default", function()
			N3DClient.GameConfig.DefaultAnimatorController = global.AssetLoader:GetAsset("controller.ab", "default")
			preload_finish_num = preload_finish_num + 1
		end),
		global.AssetLoader:LoadAsset("material/default.ab", "mat_desc", function()
			local desc = global.AssetLoader:GetMaterialDesc("material/default.ab", "mat_desc")
			N3DClient.MaterialManager:GetInstance():RegisterMaterialDesc(desc)
			preload_finish_num = preload_finish_num + 1
		end),
	}
	for i,v in ipairs(common_res) do
		if v[2] then
			table.insert(preload_req_list, global.AssetLoader:LoadAsset(v[1], v[2], function()
				preload_finish_num = preload_finish_num + 1
			end))
		else
			table.insert(preload_req_list, global.AssetLoader:LoadAllAsset(v[1], v[3], function()
				preload_finish_num = preload_finish_num + 1
			end))
		end
	end

	if log_mode == 1 then
		table.insert(preload_req_list, global.AssetLoader:LoadAllAsset("console.ab", false, function()
			preload_finish_num = preload_finish_num + 1
		end))
	end
end

function Game.UpdatePreload()
	if preload_finish_num >= #preload_req_list then
		return true, 100
	end
	return false, preload_finish_num * 100 / #preload_req_list
end

function Game.UnloadPreload()
	for i,v in ipairs(preload_req_list) do
		global.AssetLoader:UnLoad(v)
	end
	preload_req_list = nil
end

local _debug_console = nil
function Game.Start()
	print("Game Start!!!!!")
	
	if game.IsEditorMode then
		setmetatable(_G, {
			__newindex  = function(t, k, v)
				error("Write Global Table!")
			end
		})
	end

	if log_mode == 1 then
		_debug_console = global.AssetLoader:CreateGameObject("console.ab", "IngameDebugConsole")
	end

	game.ModuleMgr:LoadAllModule()
	game.ModuleMgr:StartAllModule()
	game.GamePool:CreateGamePool()
	game.GameLoop:Start()
	game.GameNet:Start()
end

local _aoi_mgr = global.AoiMgr
local _sdk_mgr = game.SDKMgr
local _audio = global.AudioMgr
function Game.Update(now_time, delta_time)
	_sdk_mgr:Update()
	_aoi_mgr:Update(now_time, delta_time)
	_audio:Update(now_time, delta_time)
	collectgarbage("step", 8)
	Game.CheckCmd()
	_sdk_mgr:CheckShowExitBox()
end

function Game.Stop()
	game.ModuleMgr:StopAllModule()
	game.GameLoop:DeleteMe()
	game.CacheMgr:DeleteMe()
	game.GamePool:ClearGamePool()
	Game.UnloadPreload()
    game.RenderUnit:Stop()
	game.GameNet.instance:DeleteMe()	

	game.ViewMgr:DeleteMe()

	if _debug_console then
		UnityEngine.GameObject.Destroy(_debug_console)
		_debug_console = nil
	end
end

function Game.OnPause(is_pause)
	global.EventMgr:Fire(game.GameEvent.Pause, is_pause)
end

function Game.OnFocus(is_focus)

end

local _next_gc_time = 0
function Game.OnLowMemory()
	if global.Time.now_time > _next_gc_time then
		collectgarbage("collect")
		N3DClient.GameTool.RunGC()
		_next_gc_time = global.Time.now_time + 30
	end
end

function Game.OnSDKEvent(ev, param)
	print("OnSDKEvent", ev, param)
    if ev == game.SDKEventName.LoginSuccess then
		-- print("LoginSuccess", param.account)
		game.SDKMgr:SendUIDToSDK(param.account)
		game.SDKMgr:ShowSDKMenu(true)
		game.AccountInfo.is_login = true
		game.AccountInfo.account = param.account
		game.AccountInfo.password = param.password
        game.AccountInfo.isDelected = param.isDelected
	elseif ev == game.SDKEventName.AuthSuccess then
		-- print("AuthSuccess", param.code)
		game.SDKMgr:AuthAccount(param.code)
	elseif ev == game.SDKEventName.AuthFail then
		game.SDKMgr:ShowSDKMenu(false)
	  	game.AccountInfo.is_login = false
        game.AccountInfo.account = nil
    	game.GameLoop:ChangeState(game.GameLoop.State.Restart)
	elseif ev == game.SDKEventName.SwitchAccount then
		game.SDKMgr:ShowSDKMenu(false)
	  	game.AccountInfo.is_login = false
        game.AccountInfo.account = nil
    	game.GameLoop:ChangeState(game.GameLoop.State.Restart)	
	elseif ev == game.SDKEventName.LogoutSuccess then
		game.SDKMgr:ShowSDKMenu(false)
	  	game.AccountInfo.is_login = false
        game.AccountInfo.account = nil
    	game.GameLoop:ChangeState(game.GameLoop.State.Restart)	
    end

 	global.EventMgr:Fire(game.SDKEvent.SDKStatusChange, ev, param)
end

local key_x = 0
local key_y = 0

local counter = 0
function Game.CheckCmd()
	if game.__DEBUG__ and game.Platform == "win" then
        if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.F5) then
			app.AppLoop.instance:ChangeState(app.AppLoop.State.Restart)
            return
        end
        if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.F6) then
            game.GameLoop:ChangeState(game.GameLoop.State.Restart)
            return
        end
        if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.F1) then
            game.MonitorCtrl.instance:ToggleView()
            return
        end
        if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.F2) then
            game.GmCtrl.instance:OpenView()
            return
        end
        if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.F4) then
            --game.OverlordCtrl.instance:OpenView()
            	-- global.EventMgr:Fire(game.FoundryEvent.GodweaponCollect)
            game.WeaponSoulCtrl.instance:OpenView()
            return
        end
        if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.F8) then
            game.MakeTeamCtrl.instance:OpenView()
            return
        end
        if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.F12) then
            game.GameNet:DisconnectGameNet()
            return
        end
        if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.F11) then
            game.RankCtrl.instance:OpenRankView()
            return
        end

        if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.F3) then

        	game.ChatCtrl.instance:OpenFriendChatView()
        	
            return
        end


		if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.KeypadEnter) then
			game.GmCtrl.instance:OpenView()
			return
		end


        if UnityEngine.Input.GetKey(UnityEngine.KeyCode.C) then
        	local main_role = game.Scene.instance:GetMainRole()
        	if main_role then
        		main_role:GetOperateMgr():DoCarry()
        	end
        	return
        end
		-- if UnityEngine.Input.GetAxis("Mouse ScrollWheel") ~= 0 then
		-- 	local cam = game.Scene.instance:GetCamera()
		-- 	if cam then
		-- 		cam:ChangeFollowDist(-UnityEngine.Input.GetAxis("Mouse ScrollWheel") * 3)
		-- 	end
		-- 	return
		-- end
		if not game.Scene.instance then
			return
		end

        local tmp_key_x = 0
        local tmp_key_y = 0
        if UnityEngine.Input.GetKey(UnityEngine.KeyCode.A) then
            tmp_key_x = -1
        elseif UnityEngine.Input.GetKey(UnityEngine.KeyCode.D) then
            tmp_key_x = 1
        end
        if UnityEngine.Input.GetKey(UnityEngine.KeyCode.W) then
            tmp_key_y = 1
        elseif UnityEngine.Input.GetKey(UnityEngine.KeyCode.S) then
            tmp_key_y = -1
        end

        if game.Scene.instance and game.Scene.instance:IsSceneStart() then
	        if key_x ~= tmp_key_x or key_y ~= tmp_key_y then
	            key_x = tmp_key_x
	            key_y = tmp_key_y
	            local role = game.Scene.instance:GetMainRole()
	            local cam = game.Scene.instance:GetCamera()
	            if role and cam then
	                if key_x == 0 and key_y == 0 then
	                    role:GetOperateMgr():DoStop()
	                else
	                    local dir_x, dir_y = cam:CameraToWorldDir2D(key_x, key_y)
	                    local dist, nx, ny = game.Scene.instance:FindPathByUnit(role.unit_pos, cc.vec2(dir_x, dir_y), 50)
	                    if dist > 0 then
	                    	role:GetOperateMgr():DoMove(nx, ny)
						end
	                end
	            end
	        end
	    end
    end
end

function Game.ErrorLog(str)
	if game.__DEBUG__ then
		game.GameMsgCtrl.instance:AddErrorLog(str)
	end
end

return Game


