local JumpCtrl = Class(game.BaseCtrl)

function JumpCtrl:_init()
    if JumpCtrl.instance ~= nil then
        error("JumpCtrl Init Twice!")
    end
    JumpCtrl.instance = self

    self:RegisterAllEvents() 
    self:RegisterAllProtocals()

end

function JumpCtrl:_delete()
    
    self:FinishJumpAnim()
    
    JumpCtrl.instance = nil
end

function JumpCtrl:RegisterAllEvents()
    local events = {
        

    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function JumpCtrl:RegisterAllProtocals()
    
end

function JumpCtrl:HasJump(key)
    return global.UserDefault:GetBool(key, false)
end

function JumpCtrl:SaveJump(key)
    global.UserDefault:SetBool(key, true)
end

function JumpCtrl:DoJumpShow(scene_id, idx, params)
    local cfg = config.show_fly[scene_id]
    if not cfg then
        return false
    end

    local jump_cfg = cfg[idx]
    if not jump_cfg or (not jump_cfg.camera_anim) then
        return false
    end

    self.jump_sound = nil
    if jump_cfg.sound then
        --global.AudioMgr:StopMusic()

        self.jump_sound = jump_cfg.sound
    end

    self.is_jump_finish = false

    self.jump_cfg = jump_cfg
    self.jump_model_anim = jump_cfg.model_anim
    self.jump_camera_anim = jump_cfg.camera_anim
    self.jump_params = params

    self.role_draw_obj_ready = false
    self.camera_draw_obj_ready = false
    self.is_ying_ready = true

    self:CreateJumpCamera()
    self:CreateJumpRole()

    return true
end

local OrignRotate = {0,0,0}

function JumpCtrl:CreateJumpCamera()
    self:DelJumpCamera()

    self.camera_draw_obj_parent = UnityEngine.GameObject()
    self.camera_draw_obj_parent.transform:SetPosition(self.jump_cfg.x, self.jump_cfg.y, self.jump_cfg.z)
    self.camera_draw_obj_parent.transform:SetRotation(OrignRotate[1],OrignRotate[2],OrignRotate[3])

    game.RenderUnit:AddToObjLayer(self.camera_draw_obj_parent.transform)

    local model_id = 100
    self.camera_draw_obj = game.GamePool.CameraObjPool:Create()
    self.camera_draw_obj:Init() 
    self.camera_draw_obj:SetModelID(model_id)
    self.camera_draw_obj:SetParent(self.camera_draw_obj_parent.transform)
    self.camera_draw_obj:SetPosition(0,0,0)
    

    self.camera_draw_obj:SetModelChangeCallBack(function(model_type)
        local main_camera_obj = game.RenderUnit:GetSceneCameraObj()
        main_camera_obj:SetVisible(false)

        self.camera_draw_obj_ready = true

        self:PlayJumpAnim()
    end)
end

function JumpCtrl:DelJumpCamera()
    if self.camera_draw_obj_parent then
        UnityEngine.GameObject.Destroy(self.camera_draw_obj_parent)
        self.camera_draw_obj_parent = nil
    end    

    if self.camera_draw_obj then
        game.GamePool.CameraObjPool:Free(self.camera_draw_obj)
        self.camera_draw_obj = nil
    end
end

function JumpCtrl:CreateJumpRole()
    self:DelJumpRole()

    local main_role = game.Scene.instance:GetMainRole()
    local model_id = main_role:GetModelID(game.ModelType.Body)
    local weapon_id = main_role:GetModelID(game.ModelType.Weapon)
    local weapon_id_2 = main_role:GetModelID(game.ModelType.Weapon2)
    local hair_id = main_role:GetModelID(game.ModelType.Hair)


    self.role_draw_obj_parent = UnityEngine.GameObject()

    self.role_draw_obj_parent.transform:SetPosition(self.jump_cfg.x, self.jump_cfg.y, self.jump_cfg.z)
    self.role_draw_obj_parent.transform:SetRotation(OrignRotate[1],OrignRotate[2],OrignRotate[3])

    game.RenderUnit:AddToObjLayer(self.role_draw_obj_parent.transform)


    self.role_draw_obj = game.GamePool.DrawObjPool:Create()
    self.role_draw_obj:Init(game.BodyType.Role, 1)
    
    self.role_draw_obj:SetModelID(game.ModelType.Body, model_id)
    self.role_draw_obj:SetModelID(game.ModelType.Weapon, weapon_id)
    self.role_draw_obj:SetModelID(game.ModelType.Hair, hair_id)

    if weapon_id_2 > 0 then
        self.role_draw_obj:SetModelID(game.ModelType.Weapon2, weapon_id_2)
    end

    self.role_draw_obj:SetParent(self.role_draw_obj_parent.transform)
    self.role_draw_obj:SetPosition(0, 0, 0)
    --self.role_draw_obj:PlayLayerAnim(game.ObjAnimName.Idle, 1.0, 0.00)
    --self.role_draw_obj:SetLayer(game.LayerName.MapElementMain)

    local model_mask = (game.ModelType.Body+game.ModelType.Weapon+game.ModelType.Hair)
    if weapon_id_2 > 0 then
        model_mask = model_mask + game.ModelType.Weapon2
    end
    self.role_draw_obj:SetModelChangeCallBack(function(model_type)
        model_mask = model_mask - model_type
        self.role_draw_obj_ready = (model_mask<=0)

        self:PlayJumpAnim()
    end)
end

function JumpCtrl:DelJumpRole()
    if self.role_draw_obj_parent then
        UnityEngine.GameObject.Destroy(self.role_draw_obj_parent)
        self.role_draw_obj_parent = nil
    end

    if self.role_draw_obj then
        game.GamePool.DrawObjPool:Free(self.role_draw_obj)
        self.role_draw_obj = nil
    end
end

local anim_model_type = game.ModelType.Body + game.ModelType.Weapon + game.ModelType.Weapon2 + game.ModelType.Hair
function JumpCtrl:PlayJumpAnim()
    if not self.camera_draw_obj_ready or not self.role_draw_obj_ready or not self.is_ying_ready then
        return
    end

    if self.jump_sound then
        global.AudioMgr:PlaySound(self.jump_sound)
    end

    self:PrepareCamera()

    self.jump_camera_culling_time = global.Time.now_time + 0.1

    self.camera_draw_obj:AddToModel(game.ModelNodeName.Camera, self.jump_camera_obj.transform)

    self.camera_draw_obj:SetLayer(game.LayerName.MapElementMain)
    self.role_draw_obj:SetLayer(game.LayerName.MapElementMain)

    self.camera_draw_obj:SetAlwaysAnim(true)
    self.role_draw_obj:SetAlwaysAnim(true)

    local camera_anim_time = self.camera_draw_obj:GetAnimTime(self.jump_camera_anim)
    local role_anim_time = self.role_draw_obj:GetAnimTime(self.jump_model_anim)
    self.jump_anim_time = (camera_anim_time>role_anim_time and camera_anim_time or role_anim_time)
    self.jump_anim_time = global.Time.now_time + self.jump_anim_time + 0.1

    self.camera_draw_obj:PlayLayerAnim(self.jump_camera_anim)
    
    self.role_draw_obj:PlayLayerAnim(anim_model_type, self.jump_model_anim)

    if self.ying_draw_obj then
        self.ying_draw_obj:SetAlwaysAnim(true)
        self.ying_draw_obj:SetLayer(game.LayerName.MapElementMain)
        self.ying_draw_obj:PlayLayerAnim(game.ModelType.Body, game.ObjAnimName.ShowFly1)
    end
end

function JumpCtrl:Update(now_time, elapse_time)
    if self.jump_camera_culling_time then
        if now_time >= self.jump_camera_culling_time then
            self.jump_camera_culling_time = nil

            self.jump_camera_com.cullingMask = self.cene_culling_mask
        end
    end

    if self.jump_anim_time then
        if now_time >= self.jump_anim_time then
            self.jump_anim_time = nil

            self:FinishJumpAnim()
        end
    end

    return self.is_jump_finish
end

function JumpCtrl:FinishJumpAnim()
    self.is_jump_finish = true

    if self.camera_draw_obj then
        self.camera_draw_obj:PlayLayerAnim(game.ObjAnimName.Idle)
        self.role_draw_obj:PlayLayerAnim(anim_model_type, game.ObjAnimName.Idle)
    end

    self:DelJumpCamera()
    self:DelJumpRole()
    self:DelShowYing()

    self:ResumeCamera()

    --global.AudioMgr:ResumeMusic()
end

function JumpCtrl:PrepareCamera()
    if self.is_prepare_camera then
        return
    end

    self.is_prepare_camera = true

    local main_cam = game.RenderUnit:GetSceneCameraObj()
    local clone_camera = UnityEngine.GameObject.Instantiate(main_cam)
    clone_camera:SetVisible(true)
    self.jump_camera_obj = clone_camera

    local physics_raycaster = clone_camera:GetComponent(UnityEngine.EventSystems.PhysicsRaycaster)
    if physics_raycaster then
        UnityEngine.GameObject.Destroy(physics_raycaster)
    end

    local cam_com = clone_camera:GetComponent(UnityEngine.Camera)
    if cam_com then
        cam_com:SetLookAtTarget(nil, 0, 0, 0, 0)
        cam_com:StopImageEffect()
        -- 设置摄像机
        self.cene_culling_mask = game.LayerMask.Default
                                + game.LayerMask.Terrain 
                                --+ game.LayerMask.SceneObject
                                + game.LayerMask.MapElementMain
                                + game.LayerMask.MapElementSub
                                + game.LayerMask.MapElementMin
                                --+ game.LayerMask.MapEffect
                                + game.LayerMask.Water
                                + game.LayerMask.SkyBox
                                + game.LayerMask.ObjCollider
                                + game.LayerMask.Effect

        cam_com.depth = 0
        cam_com.fieldOfView = 50
        cam_com.nearClipPlane = 0.03
        cam_com.farClipPlane = 1000
        cam_com.clearFlags = 2
        cam_com.allowMSAA = true
        cam_com.cullingMask = 0
    end
    clone_camera.transform:ResetPRS()

    self.jump_camera_com = cam_com

    game.RenderUnit:HideScene()
    game.RenderUnit:HideUI()
    game.GuideCtrl.instance:SetGuideViewVisible(false)

    local main_role = game.Scene.instance:GetMainRole()
    main_role:SetPauseOperate(true)

    if self.jump_params.ux and self.jump_params.uy then
        main_role:SetUnitPos(self.jump_params.ux, self.jump_params.uy)
    else
        main_role:SetLogicPos(self.jump_params.x, self.jump_params.y)
    end

    if self.jump_params.fx then
        main_role:SendJumpReq(self.jump_params.x, self.jump_params.y, self.jump_params.fx, self.jump_params.fy)
    end
end

function JumpCtrl:ResumeCamera()
    if self.jump_camera_obj then
        UnityEngine.GameObject.Destroy(self.jump_camera_obj)
        self.jump_camera_obj = nil
    end

    if not self.is_prepare_camera then
        return
    end

    if not game.Scene.instance then
        return
    end

    global.Runner:RemoveUpdateObj(self)

    self.is_prepare_camera = false

    local main_camera_obj = game.RenderUnit:GetSceneCameraObj()
    main_camera_obj:SetVisible(true)
    game.RenderUnit:ShowScene()
    game.RenderUnit:ShowUI()
    game.GuideCtrl.instance:SetGuideViewVisible(true)

    local main_role = game.Scene.instance:GetMainRole()
    main_role:SetPauseOperate(false)

    if self.jump_params.key then
        self:SaveJump(self.jump_params.key)
    end
end

local FirstJumpCareerConfig = {
    [game.Career.GaiBang] = {213.366, 43.468},
    [game.Career.XiaoYao] = {213.366, 43.468},
    [game.Career.EMei] = {213.366, 43.468},
    [game.Career.TianShan] = {213.366, 43.468},
}

function JumpCtrl:DoFirstJump()
    local main_role_id = game.Scene.instance:GetMainRoleID()
    if main_role_id <= 0 then
        return false
    end

    local level = game.Scene.instance:GetMainRoleLevel()
    if level > 1 then
        return false
    end

    local scene_id = game.Scene.instance:GetSceneID()
    if scene_id ~= 10001 then
        return false
    end

    local key = string.format("%s_first_jump", main_role_id)
    if self:HasJump(key) then
        return false
    end

    local career = game.Scene.instance:GetMainRoleCareer()
    local cfg = FirstJumpCareerConfig[career] or FirstJumpCareerConfig[game.Career.GaiBang]

    local scene_cfg = config.scene[10001]
    self.jump_params = {
        key = key,
        x = scene_cfg.x,
        y = scene_cfg.y,
        ux = cfg[1],
        uy = cfg[2],
    }

    self:PrepareCamera()

    self.is_first_jump_ready = false

    local scene_id = 10001
    local idx = 0



    self:DoJumpShow(scene_id,idx, self.jump_params)
    self:DoShowYing()

    global.Runner:RemoveUpdateObj(self)
    global.Runner:AddUpdateObj(self, 2)

    return true
end

function JumpCtrl:DoShowYing()
    self:DelShowYing()

    self.ying_draw_obj_parent = UnityEngine.GameObject()

    self.ying_draw_obj_parent.transform:SetPosition(self.jump_cfg.x, self.jump_cfg.y, self.jump_cfg.z)
    self.ying_draw_obj_parent.transform:SetRotation(OrignRotate[1],OrignRotate[2],OrignRotate[3])

    game.RenderUnit:AddToObjLayer(self.ying_draw_obj_parent.transform)

    local model_id = 5033
    self.ying_draw_obj = game.GamePool.DrawObjPool:Create()
    self.ying_draw_obj:Init(game.BodyType.Monster)
    
    self.ying_draw_obj:SetModelID(game.ModelType.Body, model_id)

    self.ying_draw_obj:SetParent(self.ying_draw_obj_parent.transform)
    self.ying_draw_obj:SetPosition(0, 0, 0)

    self.is_ying_ready = false
    self.ying_draw_obj:SetModelChangeCallBack(function(model_type)
        self.is_ying_ready = true

        self:PlayJumpAnim()
    end)
end

function JumpCtrl:DelShowYing()
    if self.ying_draw_obj_parent then
        UnityEngine.GameObject.Destroy(self.ying_draw_obj_parent)
        self.ying_draw_obj_parent = nil

        if game.Scene.instance then
            local main_role = game.Scene.instance:GetMainRole()
            main_role:SetDir(0,1)
        end
    end

    if self.ying_draw_obj then
        game.GamePool.DrawObjPool:Free(self.ying_draw_obj)
        self.ying_draw_obj = nil

        self:FireEvent(game.SceneEvent.FinishFirstJump)
    end
end

game.JumpCtrl = JumpCtrl

return JumpCtrl
