
require "tool/init"
require "global/init"

_G.DOTween = DG.Tweening.DOTween

app = {}
app.__DEBUG__ = N3DClient.GameConfig.GetClientConfig("GameMode") == "dev"
app.IsEditorMode = UnityEngine.Application.isEditor
if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.Android then
	app.Platform = "android"
elseif UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer then
	app.Platform = "ios"
else
	app.Platform = "win"
end

release_print = print
if not app.__DEBUG__ then
	print = function()
	end
end

__G__TRACKBACK__ = function(err)
	print(err)
end

local _time = global.Time
local _timer_mgr = global.TimerMgr
local _runner = global.Runner

require("apploop/app_config")
require("apploop/apploop")
require("module/init")

local App = {}
function App.Start()
	print("App Start!!!!!")
	app.AppLoop:Start()
end

function App.Update()
	_time:Update()
	_timer_mgr:Poll()
	_runner:Update(_time.now_time, _time.delta_time)
	collectgarbage("step", 8)
end

function App.Stop()
	
end

function App.OnQuit()

end

function App.OnPause(is_pause)
	if app.Game then
		app.Game.OnPause(is_pause)
	end
end

function App.OnFocus(is_focus)
	if app.Game then
		app.Game.OnFocus(is_pause)
	end
end

function App.OnLowMemory()
	if app.Game then
		app.Game.OnLowMemory()
	end
end

function App.OnSDKEvent(ev, param)
	if app.Game then
		app.Game.OnSDKEvent(ev, param)
	end
end

function App.ErrorLog(str)
	if app.Game then
		app.Game.ErrorLog(str)
	end
end

function App.GetGameState()
	if app.AppLoop then
		return app.AppLoop:GetCurState()
	end
	return 1
end

return App


