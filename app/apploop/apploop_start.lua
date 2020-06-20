
local AppLoopStart = Class()

local _ui_manager = N3DClient.UIManager:GetInstance()

function AppLoopStart:_init()

end

function AppLoopStart:_delete()

end

function AppLoopStart:StateEnter()
	print("AppLoopStart")

    UnityEngine.QualitySettings.blendWeights = 2
    UnityEngine.QualitySettings.vSyncCount = 0
    UnityEngine.Application.targetFrameRate = 30

    local screen_width = UnityEngine.Screen.width
    local screen_height = UnityEngine.Screen.height
    local resolution_width = _ui_manager.ResolutionX
    local resolution_height = _ui_manager.ResolutionY

    local s1 = screen_width / resolution_width
    local s2 = screen_height / resolution_height
    local scale = math.min(s1, s2)
    local vw = resolution_width * scale
    local vh = screen_height  --resolution_height * scale
    local vx = (screen_width - vw) * 0.5
    local vy = (screen_height - vh) * 0.5

    local ui_camera = _ui_manager:GetCamera()
    ui_camera:SetViewport(vx / screen_width, vy / screen_height, vw / screen_width, vh / screen_height)
    ui_camera.orthographicSize = 5 * vh / screen_height
    ui_camera.clearFlags = UnityEngine.CameraClearFlags.SolidColor
    ui_camera.backgroundColor = UnityEngine.Color.black

    local priority = N3DClient.GameConfig.GetClientConfigInt("DownloadPriority", 0)
    N3DClient.AssetManager:GetInstance():SetDownloadPriority(priority)

    global.AssetLoader:SetUpdateInterval(0)
	app.InitCtrl.instance:LoadInitRes()
end

function AppLoopStart:StateUpdate(now_time, elapse_time)
	if app.InitCtrl.instance:IsInitResLoaded() then
		app.InitCtrl.instance:OpenView()
		app.AppLoop.instance:ChangeState(app.AppLoop.State.FirstEnter)
	end
end

function AppLoopStart:StateQuit()

end

return AppLoopStart
