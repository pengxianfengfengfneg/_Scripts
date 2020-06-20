local CreateRoleView = Class(game.BaseView)

local _anim_hash_map = game.ObjAnimHash

local init_hair = {
    [game.Career.GaiBang] = 11001,
    [game.Career.XiaoYao] = 21001,
    [game.Career.EMei] = 31001,
    [game.Career.TianShan] = 41001,
}

local career_model_id = {
    [game.Career.GaiBang] = 110101,
    [game.Career.XiaoYao] = 210101,
    [game.Career.EMei] = 310101,
    [game.Career.TianShan] = 410101,
}

function CreateRoleView:_init(ctrl)
    self._package_name = "ui_login"
    self._com_name = "create_role_view"
    self._cache_time = 60
    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone

    self.ctrl = ctrl
    self.data = ctrl:GetData()
end

function CreateRoleView:_delete()
end

function CreateRoleView:OpenViewCallBack()
    game.RenderUnit:SetUICameraClearColor(true)
    self._layout_objs["bg"]:SetVisible(false)
    self._layout_objs["group"]:SetVisible(false)
    self._layout_objs["image1"]:SetVisible(false)
    self._layout_objs["image2"]:SetVisible(false)

    self._layout_objs["btn_ret"]:AddClickCallBack(function()
        if self.mode ~= 0 then
            self.mode_ctrl:SetSelectedIndexEx(0)
        else
            if self.data:GetRoleListCount() > 0 then
                game.GameLoop:ChangeState(game.GameLoop.State.SelectRole)
            else
                game.GameLoop:ChangeState(game.GameLoop.State.SelectServer)
            end
        end
    end)

    --点击创建角色
    self._layout_objs["btn_create_role"]:AddClickCallBack(function()
        local name = self._layout_objs["txt_name"]:GetText()
        if name == "" then
            game.GameMsgCtrl.instance:PushMsg(config.words[1004])
            return
        end

        if game.Utils.CheckMaskWords(name) then
            game.GameMsgCtrl.instance:PushMsg(config.words[1005])
            return
        end

        self.ctrl:SendRoleCreate(name, self.gender, self.career, self.icon, self.hair << 24)
        self._layout_objs["btn_create_role"]:SetEnable(false)
        if self.voice_key then
            global.AudioMgr:StopSound(self.voice_key)
            self.voice_key = nil
        end
    end)

    self._layout_objs["btn_random"]:AddClickCallBack(function()
        self:RandomName()
    end)

    self.touch_pos_x = 0
    self._layout_objs["touch_area"]:SetTouchEnable(true)
    self._layout_objs["touch_area"]:SetTouchBeginCallBack(function(x)
        self.touch_pos_x = x
    end)
    self._layout_objs["touch_area"]:SetTouchMoveCallBack(function(x)
        local role_model = self.ctrl:GetRoleCreate(self.career)
        if role_model then
            local rx, ry, rz = role_model.transform:GetRotation()
            role_model.transform:SetRotation(rx, ry - (x - self.touch_pos_x) * 0.2, rz)
        end
        self.touch_pos_x = x
    end)

    for i = 1, 4 do
        local item = self._layout_objs["career_" .. i]
        local img = item:GetChild("career")
        img:SetSprite("ui_login", "career_" .. i)
    end

    self:CreateCamera()
    self:InitIcon()
    self:InitHair()
    self:InitObjs()

end

function CreateRoleView:CloseViewCallBack()
    if self.hair_list then
        for _, v in ipairs(self.hair_list) do
            v:DeleteMe()
        end
        self.hair_list = nil
    end
    if self.icon_list then
        for _, v in ipairs(self.icon_list) do
            v:DeleteMe()
        end
        self.icon_list = nil
    end
    if self.hair_template then
        self.hair_template:DeleteMe()
        self.hair_template = nil
    end
    if self.icon_template then
        self.icon_template:DeleteMe()
        self.icon_template = nil
    end
    self:Clear()

    if self.hair_model_list then
        for _, v in pairs(self.hair_model_list) do
            v:DeleteMe()
        end
        self.hair_model_list = nil
    end

    for _, v in pairs(config.career_init) do
        local scene_hair = self.ctrl:GetHairCreate(v.career)
        if scene_hair then
            scene_hair.transform:SetVisible(true)
        end

        local role_obj = self.ctrl:GetRoleCreate(v.career)
        if role_obj then
            role_obj.transform:SetVisible(false)
        end
    end
end

function CreateRoleView:InitObjs()

    local value = math.random()
    local init_career = 1
    for _, v in ipairs(config.career_init) do
        if v.random >= value then
            init_career = v.career
            break
        end
    end

    local career_ctrl = self:GetRoot():AddControllerCallback("career_ctrl", function(idx)
        self:RefreshCareer(idx + 1)
    end)

    self.mode_ctrl = self:GetRoot():AddControllerCallback("c4", function(idx)
        self.mode = idx
    end)
    self.mode_ctrl:SetSelectedIndexEx(0)

    self.hair_model_list = {}
    for _, v in pairs(config.career_init) do

        local role_obj = self.ctrl:GetRoleCreate(v.career)
        if role_obj then
            local draw_obj = game.GamePool.DrawObjPool:Create()
            draw_obj:Init(game.BodyType.HairCreate)
            draw_obj:SetAlwaysAnim(true)
            draw_obj:SetModelChangeCallBack(function()
                local scene_hair = self.ctrl:GetHairCreate(self.career)
                if scene_hair then
                    scene_hair.transform:SetVisible(false)
                end
            end)
            role_obj.transform:SetVisible(true)
            role_obj.transform:AddChild(draw_obj:GetRoot(), game.ModelNodeName.Head)
            self.hair_model_list[v.career] = draw_obj
        end
    end

    career_ctrl:SetSelectedIndexEx(init_career - 1)
end

function CreateRoleView:InitHair()
    self.hair_select = {}
    self.hair_template = require("game/login/round_template").New()
    self.hair_template:SetVirtual(self._layout_objs["hair_list"])
    self.hair_template:Open()
    self.hair_template:SetCallBack(function(idx)
        self:SelectHair(idx)
    end)
end

--根据性别设置刷新男女头发(1.男/2.女)
function CreateRoleView:RefreshHair()
    self.hair_data_list = {}
    local cfg = config.hair_style
    for k, v in pairs(cfg) do
        if v.sex == self.gender then
            local icon
            local model_id
            for _, j in ipairs(v.item_id) do
                if j[1] == self.career then
                    icon = tostring(j[2])
                end
            end
            for _, j in ipairs(v.model_id) do
                if j[1] == self.career then
                    model_id = j[2]
                end
            end
            if icon and model_id then
                table.insert(self.hair_data_list, { id = k, icon = icon, model_id = model_id })
            end
        end
    end
    table.sort(self.hair_data_list, function(a, b)
        return a.id < b.id
    end)

    self.hair_template:SetData(1, self.hair_data_list)

    if not self.hair_select[self.career] then
        self.hair_select[self.career] = 1
    end
    self.hair_template:SetSelect(self.hair_select[self.career])
end

function CreateRoleView:SelectHair(idx)
    self.hair_select[self.career] = idx

    local cfg = self.hair_data_list[idx]
    self.hair = cfg.id

    local hair_model = self.hair_model_list[self.career]
    if hair_model and self._layout_objs["group"]:IsVisible() then
        hair_model:SetVisible(true)
        hair_model:SetModelID(game.ModelType.HairCreate, cfg.model_id)
        hair_model:PlayLayerAnim(game.ModelType.HairCreate, game.ObjAnimName.ShowIdle)
        global.AudioMgr:PlaySound("ui004")
    end
end

function CreateRoleView:InitIcon()
    self.icon_select = {}
    self.icon_template = require("game/login/round_template").New()
    self.icon_template:SetVirtual(self._layout_objs["icon_list"])
    self.icon_template:Open()
    self.icon_template:SetCallBack(function(idx)
        self:SelectIcon(idx)
    end)
end

--根据性别设置刷新男女头像(1.男/2.女)
function CreateRoleView:RefreshIcon()
    self.icon_data_list = {}
    local cfg = config.role_icon
    for k, v in pairs(cfg) do
        if v.gender == self.gender then
            table.insert(self.icon_data_list, { id = k, icon = v.icon })
        end
    end
    table.sort(self.icon_data_list, function(a, b)
        return a.id < b.id
    end)

    self.icon_template:SetData(2, self.icon_data_list)

    if not self.icon_select[self.career] then
        self.icon_select[self.career] = math.random(#self.icon_data_list)
    end
    self.icon_template:SetSelect(self.icon_select[self.career])
end

function CreateRoleView:SelectIcon(idx)
    self.icon_select[self.career] = idx
    self.icon = self.icon_data_list[idx].id
    global.AudioMgr:PlaySound("ui004")
end

function CreateRoleView:Update()
    if self.anim_end_time then
        if self.anim_end_time > 0 and global.Time.now_time > self.anim_end_time then
            self.anim_end_time = 0
            self._layout_root:PlayTransition("t0")
            self._layout_objs["group"]:SetVisible(true)
            self._layout_objs["image1"]:SetVisible(false)
            self._layout_objs["image2"]:SetVisible(false)

            local career_obj = self.ctrl:GetCareerCreate(self.career)
            if career_obj then
                local controller_list = career_obj:GetComponentsInChildren(ModelController)
                for i = 1, controller_list.Length do
                    local controller = controller_list[i]
                    if _anim_hash_map[game.ObjAnimName.ShowIdle] then
                        controller:PlayAnim(game.ObjAnimName.ShowIdle, _anim_hash_map[game.ObjAnimName.ShowIdle], 1, 0)
                    end
                end
            end
        end
    end
    if self.play_music_time then
        if self.play_music_time > 0 and global.Time.now_time > self.play_music_time then
            self.play_music_time = 0
            local sound_name = config.career_init[self.career].music[2]
            self.voice_key = global.AudioMgr:PlaySound(sound_name)
        end
    end
    if self.play_voice_time then
        if self.play_voice_time > 0 and global.Time.now_time > self.play_voice_time then
            self.play_voice_time = 0
            local sound_name = config.career_init[self.career].voice[2]
            global.AudioMgr:PlaySound(sound_name)
        end
    end
end

function CreateRoleView:SetEnable(val)
    if self:IsOpen() then
        self._layout_objs["btn_create_role"]:SetEnable(val)
    end
end

--刷新选择创建人物
function CreateRoleView:RefreshCareer(career)
    self.career = career
    if self.career == 3 or self.career == 4 then
        self.gender = 2
    else
        self.gender = 1
    end

    local cfg = config.career_init[career]
    if cfg then
        self._layout_objs["desc"]:SetSprite("ui_login", string.format("a%d_%d", cfg.atk_type, cfg.atk_dist))
        self._layout_objs["image1"]:SetSprite("ui_login", cfg.poem_img[1])
        self._layout_objs["image2"]:SetSprite("ui_login", cfg.poem_img[2])
    end

    self:RandomName()
    self:PlayAnim(career)
    self:RefreshIcon()
    self:RefreshHair()
end

function CreateRoleView:CreateCamera()
    local main_cam = game.RenderUnit:GetSceneCameraObj()
    local clone_camera = UnityEngine.GameObject.Instantiate(main_cam)

    local physics_raycaster = clone_camera:GetComponent(UnityEngine.EventSystems.PhysicsRaycaster)
    if physics_raycaster then
        UnityEngine.GameObject.Destroy(physics_raycaster)
    end
    local cam_com = clone_camera:GetComponent(UnityEngine.Camera)
    if cam_com then
        cam_com.depth = 30
        cam_com.clearFlags = 2
        cam_com.allowMSAA = false
    end
    clone_camera.transform:ResetPRS()
    clone_camera:SetVisible(true)

    self.camera = clone_camera

    game.RenderUnit:SetSceneCameraEnable(false)
end

function CreateRoleView:PlayAnim(career)

    local role_obj = self.ctrl:GetRoleCreate(career)
    if role_obj then
        self._layout_objs["image1"]:SetVisible(true)
        self._layout_objs["image2"]:SetVisible(true)
        local hair_model = self.hair_model_list[career]
        if hair_model then
            hair_model:SetVisible(false)
        end
        local scene_hair = self.ctrl:GetHairCreate(career)
        if scene_hair then
            scene_hair.transform:SetVisible(true)
        end

        role_obj.transform:SetRotation(0, 0, 0)

        local camera = self.ctrl:GetCameraCreate(career)
        if camera then
            camera.transform:AddChild(self.camera, game.ModelNodeName.Camera)
        end

        local career_obj = self.ctrl:GetCareerCreate(self.career)
        if career_obj then
            local model_ctrl_list = career_obj:GetComponentsInChildren(ModelController)
            for i = 1, model_ctrl_list.Length do
                local controller = model_ctrl_list[i]
                if _anim_hash_map[game.ObjAnimName.Show1] then
                    controller:PlayAnim(game.ObjAnimName.Show1, _anim_hash_map[game.ObjAnimName.Show1], 1, 0)
                end
            end

            local effect_ctrl_list = career_obj:GetComponentsInChildren(ParticleController)
            for i = 1, effect_ctrl_list.Length do
                local controller = effect_ctrl_list[i]
                if controller then
                    controller:ReplayParitcle()
                end
            end
        end

        game.RenderUnit:SetUICameraClearColor(false)

        self.play_music_time = config.career_init[career].music[1] + global.Time.now_time
        self.play_voice_time = config.career_init[career].voice[1] + global.Time.now_time
        self._layout_objs["group"]:SetVisible(false)

        local anim_cfg = game.AnimMgr:GetAnimConfig(game.BodyType.RoleCreate, career_model_id[career])
        self.anim_end_time = anim_cfg[game.ObjAnimName.Show1] + global.Time.now_time
    else
        game.RenderUnit:SetUICameraClearColor(true)
    end
end

function CreateRoleView:Clear()
    if self.camera then
        UnityEngine.GameObject.Destroy(self.camera)
        self.camera = nil
    end

    game.RenderUnit:SetSceneCameraEnable(true)
end

function CreateRoleView:RandomName()
    local cfg = config.random_name
    local name = ""

    if self.gender % 2 == 0 then
        local n1 = math.random(1, #cfg[3])
        local n2 = math.random(1, #cfg[4])
        name = cfg[3][n1] .. cfg[4][n2]
    else
        local n1 = math.random(1, #cfg[1])
        local n2 = math.random(1, #cfg[2])
        name = cfg[1][n1] .. cfg[2][n2]
    end

    self._layout_objs["txt_name"]:SetText(name)
end

return CreateRoleView
