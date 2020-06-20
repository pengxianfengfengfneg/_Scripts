
local RenderUnit = Class()

local _ui_manager = N3DClient.UIManager:GetInstance()

function RenderUnit:_init()
	if RenderUnit.instance ~= nil then
		error("RenderUnit Init Twice!")
	end
	RenderUnit.instance = self
end

function RenderUnit:_delete()
	RenderUnit.instance = nil
end

function RenderUnit:Start()
    UnityEngine.Shader.globalMaximumLOD = 600

    self.screen_width = UnityEngine.Screen.width
    self.screen_height = UnityEngine.Screen.height
    self.resolution_width = _ui_manager.ResolutionX
    self.resolution_height = _ui_manager.ResolutionY
    
    -- 主摄像机
    self.scene_culling_mask = game.LayerMask.Default
                                + game.LayerMask.Terrain 
                                + game.LayerMask.SceneObject
                                + game.LayerMask.MapElementMain
                                + game.LayerMask.MapElementSub
                                + game.LayerMask.MapElementMin
                                + game.LayerMask.MapEffect
                                + game.LayerMask.Water
                                + game.LayerMask.MainSceneObject
                                + game.LayerMask.Effect
                                + game.LayerMask.SkyBox
                                + game.LayerMask.HeadWidget

    local main_cam_obj, main_cam = self:CreateSceneCamera("_MainCamera", "MainCamera"
        , self.scene_culling_mask, 50, 50, 300)
    main_cam.allowMSAA = false
    self.scene_camera = main_cam
    self.scene_camera_obj = main_cam_obj.transform

    local ray_caster = main_cam_obj:AddComponent(UnityEngine.EventSystems.PhysicsRaycaster)
    ray_caster:SetMask(~game.LayerMask.UI)

    -- light
    local light = UnityEngine.GameObject.Find("_MainLight")
    if light then
        self.main_light = light:GetComponent(UnityEngine.Light)
        self.main_light.intensity = 1
    end

    -- layer
    local map_layer = UnityEngine.GameObject("_map_layer")
    UnityEngine.GameObject.DontDestroyOnLoad(map_layer)
    self.map_layer = map_layer.transform

    local obj_layer = UnityEngine.GameObject("_obj_layer")
    UnityEngine.GameObject.DontDestroyOnLoad(obj_layer)
    self.obj_layer = obj_layer.transform

	local unused_layer = UnityEngine.GameObject("_Unused_layer")
    UnityEngine.GameObject.DontDestroyOnLoad(unused_layer)
    unused_layer:SetActive(false)
    self.unused_layer = unused_layer.transform

    -- ui cam
    self.ui_camera = _ui_manager:GetCamera()
    self.ui_camera_obj = self.ui_camera.transform
    self.ui_camera.useOcclusionCulling = false
    self.ui_camera.depth = 100
    self.ui_camera.backgroundColor = UnityEngine.Color.black
    self.ui_camera.cullingMask = game.LayerMask.UI + game.LayerMask.UIDefault

    -- match
    local s1 = self.screen_width / self.resolution_width
    local s2 = self.screen_height / self.resolution_height
    local scale = math.min(s1, s2)
    local vw = self.resolution_width * scale
    local vh = self.resolution_height * scale
    local vx = (self.screen_width - vw) * 0.5
    local vy = (self.screen_height - vh) * 0.5
    self.scene_camera:SetViewport(vx / self.screen_width, vy / self.screen_height, vw / self.screen_width, vh / self.screen_height)
end

function RenderUnit:Stop()
    UnityEngine.GameObject.Destroy(self.scene_camera_obj)
    self.scene_camera = nil
    self.scene_camera_obj = nil
    self.ui_camera = nil
    self.main_light = nil

    UnityEngine.GameObject.Destroy(self.map_layer)
    self.map_layer = nil
    UnityEngine.GameObject.Destroy(self.obj_layer)
    self.obj_layer = nil
    UnityEngine.GameObject.Destroy(self.unused_layer)
    self.unused_layer = nil
end

function RenderUnit:CreateSceneCamera(name, tag, mask, depth, fov, farplane)
    local camObj = UnityEngine.GameObject(name)
    if tag then
        camObj.tag = tag
    end
    UnityEngine.GameObject.DontDestroyOnLoad(camObj)

    local cam = camObj:AddComponent(UnityEngine.Camera)
    cam.clearFlags = UnityEngine.CameraClearFlags.Color
    cam.backgroundColor = UnityEngine.Color.black
    cam.cullingMask = mask
    cam.fieldOfView = fov
    cam.nearClipPlane = 0.1
    cam.farClipPlane = farplane
    cam.orthographic = false
    cam.depth = depth
    cam.allowHDR = false
    cam.allowMSAA = false
    cam.useOcclusionCulling = false
    cam.layerCullDistances = {40,10,10,10,70,10,10,10,80,40,
                              50,80,55,10,10,10,10,10,0,10,
                              45,30,0,40,10,10,10,10,10,10,
                              10,10}

    return camObj, cam
end

function RenderUnit:AddToObjLayer(obj)
	obj:SetParent(self.obj_layer, false)
end

function RenderUnit:AddToUnUsedLayer(obj)
	obj:SetParent(self.unused_layer, false)
end

function RenderUnit:AddToMapLayer(obj)
    obj:SetParent(self.map_layer, false)
end

function RenderUnit:SetUICameraClearColor(val)
    if val then
        self.ui_camera.clearFlags = UnityEngine.CameraClearFlags.Color
    else
        self.ui_camera.clearFlags = UnityEngine.CameraClearFlags.Depth
    end
end

function RenderUnit:SetLayerVisible(layer, visible)
    if visible then
        self.scene_culling_mask = self.scene_culling_mask | layer
    else
        self.scene_culling_mask = self.scene_culling_mask & ~layer
    end
    self.scene_camera.cullingMask = self.scene_culling_mask
end

function RenderUnit:IsLayerVisible(layer)
    if layer then
        return self.scene_culling_mask & layer
    end
    return false
end

function RenderUnit:GetSceneCameraObj()
	return self.scene_camera_obj
end

function RenderUnit:GetSceneCamera()
    return self.scene_camera
end

function RenderUnit:SetSceneCameraEnable(val)
    self.scene_camera.enabled = val
end

function RenderUnit:GetUICameraObj()
	return self.ui_camera_obj
end

function RenderUnit:GetUICamera()
    return self.ui_camera
end

function RenderUnit:CameraToWorldDir2D(cam, x, y)
    return cam:CameraToWorldDir2D(x, y)
end

function RenderUnit:ScreenToWorldPos(cam, x, y)
    return cam:ScreenToWorldPos(x, y)
end

function RenderUnit:WorldToScreenPos(cam, x, y, z)
    return cam:WorldToScreenPos(x, y, z)
end

function RenderUnit:WorldToUIPos(cam, obj, x, y, z)
    return cam:WorldToUIPos(obj, x, y, z)
end

function RenderUnit:RaycastFromScreenPos(cam, x, y, dist, layer_mask)
    return cam:RaycastFromScreenPos(x, y, dist, layer_mask)
end

function RenderUnit:SwitchToFighting()
    self.scene_camera.cullingMask = self.scene_culling_mask
end

function RenderUnit:SwitchToMainCity()
    local culling_mask = 0
    self.scene_camera.cullingMask = culling_mask  
end

function RenderUnit:ShowScene()
    self.scene_camera.cullingMask = self.scene_culling_mask
end

function RenderUnit:HideScene()
    local culling_mask = 0
    self.scene_camera.cullingMask = culling_mask  
end

function RenderUnit:ShowUI()
    self.ui_camera.cullingMask = game.LayerMask.UI + game.LayerMask.UIDefault
end

function RenderUnit:HideUI(mask)
    local culling_mask = mask or 0
    self.ui_camera.cullingMask = culling_mask + game.LayerMask.UIDefault
end

game.RenderUnit = RenderUnit.New()
