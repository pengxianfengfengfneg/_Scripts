
local Scene = Class(game.BaseCtrl)

game.Scene = Scene
require("game/scene/scene_protocal")

local _obj_type = game.ObjType
local _table_insert = table.insert
local _math_floor = math.floor
local _math_abs = math.abs
local _global_time = global.Time
local game_tool = N3DClient.GameTool
local _asset_loader = global.AssetLoader
local _eff_mgr = game.EffectMgr

local config_show_fly = config.show_fly

function Scene:_init()
    if Scene.instance ~= nil then
        error("Scene Init Twice!")
    end
    Scene.instance = self

    self.map = require("game/scene/map").New()
    self.camera = require("game/scene/camera/camera").New()

    self:RegisterAllProtocal()
    self:RegisterErrorCode()
    self:RegisterAllEvent()

    self.obj_id = 0
    self.obj_list = {}
    self.obj_uniqid_map = {}
    self.delay_delete_list = {}
    self.is_started = false

    self.next_create_time = 0

    self.new_role_num = 0
    self.new_role_list = {}
    self.new_monster_num = 0
    self.new_monster_list = {}
    self.new_pet_num = 0
    self.new_pet_list = {}
    self.new_gather_num = 0
    self.new_gather_list = {}
    self.new_carry_num = 0
    self.new_carry_list = {}
    self.new_flyitem_num = 0
    self.new_flyitem_list = {}

    self.scene_res_list = {}
    self.scene_res_cur_num = 0
    self.scene_res_all_num = 0

    self.screen_role_num = 0
    self.scene_other_mon_num = 0

    self.scene_skill_list = {}

    self.flyer_mgr = require("game/character/flyer/flyer_mgr").New()
    self.scene_logic = require("game/scene/scene_logic/scene_logic_base").New(self)

    self.sys_setting_ctrl = game.SysSettingCtrl.instance

    self:RegisterAllEvents()
end

function Scene:_delete()
    self:StopScene()
    self:ClearScene(true)

    if self.map then
        self.map:DeleteMe()
        self.map = nil
    end

    if self.camera then
        self.camera:DeleteMe()
        self.camera = nil
    end

    if self.scene_logic then
        self.scene_logic:DeleteMe()
        self.scene_logic = nil
    end

    if self.flyer_mgr then
        self.flyer_mgr:DeleteMe()
        self.flyer_mgr = nil
    end

    Scene.instance = nil
    game.Obj.instance = nil
end

function Scene:RegisterAllEvents()
    local events = { 
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function Scene:GetSceneID()
    return self.scene_id
end

function Scene:GetSceneType()
    return self.scene_type
end

function Scene:GetSceneName()
    return self.scene_name
end

function Scene:GetCamera()
    return self.camera
end

function Scene:GetMap()
    return self.map
end

function Scene:GetLastSceneID()
    return self.last_scene_id
end

function Scene:PrepareScene()
    global.AoiMgr:SetSize(1000, 1000)
    self:PrepareMainRole()
end

function Scene:PrepareMainRole()
    self.main_role = self:CreateMainRole(self.main_role_vo)    

    self.camera:SetFollowObj(self.main_role, 20, cc.vec3(35, 0, 0))
    self.camera:SetLookAtOffset(0, 0.5, 0)
    self.camera:EnableColliderCheck(true)
end

function Scene:ResetMainRole()
    if self.main_role then
        self:DeleteObj(self.main_role.obj_id, false)
        self.main_role = nil
    end
    self:PrepareMainRole()
end

function Scene:BuildNavMesh()
    local ret = game_tool.BuildNavMesh()
    if not ret then
        error("BuildNavMesh Fail")
    end
end

function Scene:StartScene()
    self:BuildNavMesh()

    self:CreateDoorList()
    self:CreateNpcList()
    self:CreateJumpList()

    self.scene_logic:StartScene()
    self:SendSceneInfoReq()
    self.scene_logic:PlayMusic()

    game.JumpCtrl.instance:DoFirstJump()
    

    

    -- self:EnableRealTimeShadow(true)

    self:InitCameraRotation()

    self:DoCrossOperate()
    
    self.is_started = true
end

function Scene:StopScene()
    self:EnableRealTimeShadow(false)

    self.scene_logic:StopScene()
    self.camera:Stop()

    self.main_role = nil

    local tmp_list = {}
    for k, v in pairs(self.obj_list) do
        table.insert(tmp_list, k)
    end

    for i, v in ipairs(tmp_list) do
        self:ReleaseObj(self.obj_list[v])
        self.obj_list[v] = nil
    end

    self.flyer_mgr:ClearAll()

    
    self.obj_id = 0
    self.obj_list = {}
    self.obj_uniqid_map = {}
    self.delay_delete_list = {}
    self.npc_list = {}
    self.jump_list = {}

    self.new_role_num = 0
    self.new_role_list = {}
    self.new_monster_num = 0
    self.new_monster_list = {}
    self.new_pet_num = 0
    self.new_pet_list = {}
    self.new_gather_num = 0
    self.new_gather_list = {}
    self.new_carry_num = 0
    self.new_carry_list = {}
    self.new_flyitem_num = 0
    self.new_flyitem_list = {}

    self.screen_role_num = 0
    self.scene_other_mon_num = 0
    self.scene_skill_list = {}

    global.AoiMgr:Clear()
    self.is_started = false
    self.next_mon_pos_enable = false
end

function Scene:IsSceneStart()
    return self.is_started
end

local ReconnectKeepObj ={
    [game.ObjType.MainRole] = 1,
    [game.ObjType.Npc] = 1,
    [game.ObjType.Door] = 1,
    [game.ObjType.JumpPoint] = 1,
}

function Scene:OnReconnect()
    local obj_id_list = {}
    local func = function(obj)
        if not ReconnectKeepObj[obj.obj_type] then
            if obj.obj_id then
                table.insert(obj_id_list, obj.obj_id)
            end
        end
    end

    self:ForeachObjs(func)

    for i, v in ipairs(obj_id_list) do
        self:DeleteObj(v)
    end
    
    self.new_role_num = 0
    self.new_role_list = {}
    self.new_monster_num = 0
    self.new_monster_list = {}
    self.new_pet_num = 0
    self.new_pet_list = {}
    self.new_gather_num = 0
    self.new_gather_list = {}
    self.new_carry_num = 0
    self.new_carry_list = {}
    self.new_flyitem_num = 0
    self.new_flyitem_list = {}
end

function Scene:Update(now_time, elapse_time)
    self.scene_logic:Update(now_time, elapse_time)

    self.in_update = true
    for k, v in pairs(self.obj_list) do
        v:CheckUpdate(now_time, elapse_time)
    end
    self.in_update = false

    if #self.delay_delete_list > 0 then
        for i, v in ipairs(self.delay_delete_list) do
            self:_DeleteObj(v)
        end
        self.delay_delete_list = {}
    end

    self.flyer_mgr:Update(now_time, elapse_time)
    self.map:Update(now_time, elapse_time)

    self.next_create_time = self.next_create_time - 1
    if self.next_create_time <= 0 then
        self.next_create_time = 1

        local has_create = false
        if not has_create and self.new_role_num > 0 then
            for k, v in pairs(self.new_role_list) do
                self.new_role_list[k] = nil
                self.new_role_num = self.new_role_num - 1
                has_create = true
                self:CreateRole(v)
                break
            end
        end

        if not has_create and self.new_pet_num > 0 then
            for k, v in pairs(self.new_pet_list) do
                self.new_pet_list[k] = nil
                self.new_pet_num = self.new_pet_num - 1
                has_create = true
                self:CreatePet(v)
                break
            end
        end

        if not has_create and self.new_monster_num > 0 then
            for k, v in pairs(self.new_monster_list) do
                self.new_monster_list[k] = nil
                self.new_monster_num = self.new_monster_num - 1
                has_create = true
                self:CreateMonster(v)
                break
            end
        end

        if not has_create and self.new_flyitem_num > 0 then
            for k, v in pairs(self.new_flyitem_list) do
                self.new_flyitem_list[k] = nil
                self.new_flyitem_num = self.new_flyitem_num - 1
                has_create = true
                self:CreateFlyItem(v)
                break
            end
        end

        if not has_create and self.new_carry_num > 0 then
            for k, v in pairs(self.new_carry_list) do
                self.new_carry_list[k] = nil
                self.new_carry_num = self.new_carry_num - 1
                has_create = true
                self:CreateCarry(v)
                break
            end
        end

        if not has_create and self.new_gather_num > 0 then
            for k, v in pairs(self.new_gather_list) do
                self.new_gather_list[k] = nil
                self.new_gather_num = self.new_gather_num - 1
                has_create = true
                self:CreateGather(v)
                break
            end
        end
    end
end

function Scene:RandomPos(x, y, range)
    return self.map:RandomPos(x, y, range)
end

-- load scene
function Scene:PreLoadScene(id)
    local old_id = self.scene_id
    self.last_scene_id = old_id
    self.scene_id = id

    local cfg = config.scene[id]
    self.scene_name = cfg.name
    self.scene_type = cfg.type
    self.scene_orientation = cfg.orientation

    self.camera_lock = cfg.camera_lock

    local scene_config_path = string.format("config/editor/scene/%d", self.scene_id)
    self.scene_config = require(scene_config_path)
    package.loaded[scene_config_path] = nil

    self.map_id = self.scene_config.map_id
end

function Scene:ChangeScene(id, pos)
    print("Scene:LoadScene", id, pos.x, pos.y, self.camera_lock)

    self:ChangeSceneLogic()
    self.camera:Start()
    self.camera:SetCameraLock(self.camera_lock == 1)
    game.MainUICtrl.instance:SetCameraRotState(self.camera_lock)

    global.EventMgr:Fire(game.SceneEvent.ChangeScene, self.scene_id, self.last_scene_id)
end

function Scene:CanChangePkMode()
    local cfg = config.scene[self.scene_id]
    if cfg then
        return cfg.switch_mode_lmt == 0
    end
end

function Scene:LoadScene()
    self.map:LoadMap(self.map_id)
    self:LoadSceneRes()
end

function Scene:GetSceneLoadState()
    return self.map:GetLoadState()
    -- local map_finish, map_percent = self.map:GetLoadState()
    -- local res_finish = self.scene_res_cur_num >= self.scene_res_all_num
    -- local res_percent = 1
    -- if self.scene_res_all_num > 0 then
    --     res_percent = self.scene_res_cur_num / self.scene_res_all_num
    -- end

    -- return map_finish and res_finish, (map_percent + res_percent) * 0.5
end

function Scene:ClearScene(clear_all, to_scene_id)
    self:ClearSceneRes(clear_all)

    local map_id = nil
    if to_scene_id then
        local path = string.format("config/editor/scene/%d", to_scene_id)
        local scene_cfg = require(path)
        package.loaded[path] = nil

        map_id = scene_cfg.map_id
    end

    self.map:ClearMap(map_id)
end

local _cfg_monster = config.monster
local _cfg_skill = config.skill
function Scene:ResetSceneResInfo()
    local cfg = config.scene[self.scene_id]

    local path
    local preload_res_map = {}
    if self.main_role_vo then
        if self.main_role_vo.level <= 1 then
            -- 第一跳资源
            local model_id = 5033
            path = string.format("model/monster/%d.ab", model_id)
            table.insert(preload_res_map, path)
        end
    end

    -- local mon_cfg
    -- for k, v in ipairs(cfg.monsters) do
    --     mon_cfg = _cfg_monster[v]
    --     if mon_cfg then
    --         path = string.format("model/monster/%d.ab", mon_cfg.model_id)
    --         preload_res_map[path] = 1
    --     end
    -- end

    local eff_cfg
    if self.main_role_vo then
        for k, v in ipairs(config.skill_career[self.main_role_vo.career]) do
            eff_cfg = _cfg_skill[v.skill_id]
            if eff_cfg and eff_cfg[1] then
                for k1, v1 in ipairs(eff_cfg[1].effect) do
                    path = string.format("effect/skill/%s.ab", v1[2])
                    table.insert(preload_res_map, path)
                end
            end
        end
    end

    for k,v in pairs(self.scene_res_list) do
        v.ref_count = v.ref_count - 1
    end

    local info
    for k, v in pairs(preload_res_map) do
        info = self.scene_res_list[v]
        if not info then
            info = {}
            info.ref_count = 0
            self.scene_res_list[v] = info
        end
        info.ref_count = info.ref_count + 1
    end
end

function Scene:LoadSceneRes()
    self.scene_res_cur_num = 0
    self.scene_res_all_num = 0
    local callback = function()
        self.scene_res_cur_num = self.scene_res_cur_num + 1
    end
    for k, v in pairs(self.scene_res_list) do
        if not v.id and v.ref_count > 0 then
            v.id = _asset_loader:LoadBundle(k, callback)
            self.scene_res_all_num = self.scene_res_all_num + 1
        end
    end
end

function Scene:ClearSceneRes(clear_all)
    for k, v in pairs(self.scene_res_list) do
        if clear_all or v.ref_count <= 0 then
            if v.id then
                _asset_loader:UnLoad(v.id)
                v.id = nil
            end
        end
    end
end

-- scene logic
function Scene:ChangeSceneLogic()
    if self.scene_logic then
        self.scene_logic:DeleteMe()
        self.scene_logic = nil
    end

    if self:IsGuildArenaWarFirst() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_guild_arena_first").New(self)
    elseif self:IsGuildArenaWarSecond() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_guild_arena_second").New(self)
    elseif self:IsGuildArenaRestScene() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_guild_arena_rest").New(self)
    elseif self:IsAngerSkillScene() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_anger_skill").New(self)    
    elseif self:IsDungeonScene() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_dungeon").New(self)
    elseif self:IsRobotPvpScene() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_robot_pvp").New(self)
    elseif self:IsGuildSeatScene() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_guild_seat").New(self)
    elseif self:IsGuildDefendScene() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_guild_defend").New(self)
    elseif self:IsWorldBossScene() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_world_boss").New(self)
    elseif self:IsCareerBattleScene() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_career_battle").New(self)
    elseif self:IsLakeBanditsScene() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_lake_bandits").New(self)
    elseif self:IsTerritoryPrepareScene() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_territory_prepare").New(self)
    elseif self:IsTerritoryBattleScene() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_territory_battle").New(self)
    elseif self:IsCatchPetScene() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_catch_pet").New(self)
    elseif self:IsSongliaoScene() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_songliao").New(self)
    elseif self:IsSongliaoPrepareScene() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_songliao_prepare").New(self)
    elseif self:IsMarryHallScene() then
        self.scene_logic = require("game/scene/scene_logic/scene_logic_marry_hall").New(self)
    else
        self.scene_logic = require("game/scene/scene_logic/scene_logic_common").New(self)
    end
end

function Scene:GetSceneLogic()
    return self.scene_logic
end

-- obj相关
function Scene:GetObj(id)
    return self.obj_list[id]
end

function Scene:GetObjByUniqID(uniq_id)
    local obj_id = self:GetObjID(uniq_id)
    if obj_id then
        return self:GetObj(obj_id)
    end
end

function Scene:GetObjID(uniq_id)
    return self.obj_uniqid_map[uniq_id]
end

local fliter_func = function()
    return true
end

function Scene:GetObjByType(obj_type, fliter)
    local objects = {}
    fliter = fliter or fliter_func
    for k,v in pairs(self.obj_list) do
        if v:GetObjType() == obj_type then
            if fliter(v) then
                _table_insert(objects, v)
            end
        end
    end
    return objects
end

function Scene:AddObj(obj)
    if self.obj_list[obj.obj_id] then
        error("Object Id Already Exist!")
    end
    if obj.uniq_id then
        self.obj_uniqid_map[obj.uniq_id] = obj.obj_id
    end
    self.obj_list[obj.obj_id] = obj
end

function Scene:DeleteObj(id, is_delay)
    if self.in_update or is_delay then
        _table_insert(self.delay_delete_list, id)
    else
        self:_DeleteObj(id)
    end
end

function Scene:_DeleteObj(id)
    local obj = self.obj_list[id]
    if obj then
        local uniq_id = obj.uniq_id
        if uniq_id then
            self.obj_uniqid_map[uniq_id] = nil
        end

        if obj.obj_type == _obj_type.Monster and obj.is_dead and not obj.real_dead then
            -- 怪物在死亡状态等待动画结束删除
        else
            self.obj_list[id] = nil
            self:ReleaseObj(obj)
        end
    else
        error("Scene:DeleteObj Obj Not Found!")
    end
end

local _release_func = {
    [_obj_type.Monster] = function(obj)
        game.GamePool.MonsterPool:Free(obj)
    end,
    [_obj_type.Role] = function(obj)
        game.GamePool.RolePool:Free(obj)
    end,
    [_obj_type.Pet] = function(obj)
        game.GamePool.PetPool:Free(obj)
    end,
    [_obj_type.Gather] = function(obj)
        game.GamePool.GatherPool:Free(obj)
    end,
    [_obj_type.Carry] = function(obj)
        game.GamePool.CarryPool:Free(obj)
    end,
    [_obj_type.FlyItem] = function(obj)
        game.GamePool.FlyItemPool:Free(obj)
    end,
    [_obj_type.WeaponSoul] = function(obj)
        game.GamePool.WeaponSoulPool:Free(obj)
    end,
    [_obj_type.FollowObj] = function(obj)
        game.GamePool.FollowObjPool:Free(obj)
    end,
}

function Scene:ReleaseObj(obj)
    self.scene_logic:ReleaseObj(obj)
    
    if _release_func[obj.obj_type] then
        _release_func[obj.obj_type](obj)
    else
        obj:DeleteMe()
    end
end

function Scene:ForeachObjs(func, ...)
    for k, v in pairs(self.obj_list) do
        func(v, ...)
    end
end

function Scene:FindObjs(func, ...)
    for k, v in pairs(self.obj_list) do
        if func(v, ...) then
            return true
        end
    end
end

-- MainRole
function Scene:GetMainRole()
    return self.main_role
end

function Scene:GetMainRoleVo()
    return self.main_role_vo
end

function Scene:GetMainRoleName()
    if self.main_role_vo then
        return self.main_role_vo.name
    end
    return ""
end

function Scene:GetMainRoleLevel()
    if self.main_role_vo then
        return self.main_role_vo.level
    end
    return 0
end

function Scene:GetMainRoleCareer()
    if self.main_role_vo then
        return self.main_role_vo.career
    end
    return 0
end

function Scene:GetMainRoleGender()
    if self.main_role_vo then
        return self.main_role_vo.gender
    end
    return 0
end

function Scene:GetMainRoleID()
    if self.main_role_vo then
        return self.main_role_vo.role_id
    end
    return 0
end

function Scene:GetMainRoleVipLv()
    if self.main_role_vo then
        return self.main_role_vo.vip_lv
    end
    return 0
end

function Scene:GetMainRoleExp()
    if self.main_role_vo then
        return self.main_role_vo.exp
    end
    return 0
end

function Scene:GetMainRolePower()
    if self.main_role_vo then
        return self.main_role_vo.combat_power
    end
    return 0
end

function Scene:GetServerNum()
    if self.main_role_vo then
        return self.main_role_vo.server_num
    end
    return 0
end

function Scene:GetServerLine()
    if self.main_role_vo then
        return self.main_role_vo.line_id
    end
    return 0
end

function Scene:GetMainRoleAnger()
    if self.main_role_vo then
        return self.main_role_vo.anger
    end
    return 0
end

function Scene:GetMainRoleIcon()
    if self.main_role_vo then
        return self.main_role_vo.icon
    end
    return 0
end

function Scene:GetMainRoleFrame()
    if self.main_role_vo then
        return self.main_role_vo.frame
    end
    return 0
end

function Scene:GetMainRoleBubble()
    if self.main_role_vo then
        return self.main_role_vo.bubble
    end
    return 0
end

function Scene:GetMainRoleGuildID()
    if self.main_role_vo then
        return self.main_role_vo.guild
    end
    return 0
end

-- Creat Obj
function Scene:CreateMainRole(vo)
    return self.scene_logic:CreateMainRole(vo)
end

function Scene:_CreateMainRole(vo)
    self.obj_id = self.obj_id + 1

    local role = require("game/character/main_role").New()
    role.obj_id = self.obj_id
    role:Init(self, vo)
    self:AddObj(role)

    if vo.hp <= 0 then
        role:DoDie()
    elseif vo.state & 1 ~= 0 then
        role:DoPractice()
    else
        role:DoIdle()
    end

    return role
end

function Scene:CreateMonster(vo)
    if not self:CheckOtherMonShowNum(vo) then
        return
    end
    return self.scene_logic:CreateMonster(vo)
end

function Scene:_CreateMonster(vo)
    self.obj_id = self.obj_id + 1

    local monster = game.GamePool.MonsterPool:Create()
    monster.obj_id = self.obj_id
    monster:Init(self, vo)
    self:AddObj(monster)

    if vo.to_x ~= vo.x and vo.to_y ~= vo.y and vo.to_x ~= 0 and vo.to_y ~= 0 then
        local ux, uy = game.LogicToUnitPos(vo.to_x, vo.to_y)
        monster:DoMove(ux, uy)
    else
        monster:DoIdle()
    end

    self:ResetMonsterShow(monster)

    return monster
end

function Scene:CreateFlyItem(vo)
    return self.scene_logic:CreateFlyItem(vo)
end

function Scene:_CreateFlyItem(vo)
    self.obj_id = self.obj_id + 1

    local flyitem = game.GamePool.FlyItemPool:Create()
    flyitem.obj_id = self.obj_id
    flyitem:Init(self, vo)
    self:AddObj(flyitem)

    if vo.to_x ~= vo.x and vo.to_y ~= vo.y and vo.to_x ~= 0 and vo.to_y ~= 0 then
        local ux, uy = game.LogicToUnitPos(vo.to_x, vo.to_y)
        flyitem:DoMove(ux, uy)
    else
        flyitem:DoIdle()
    end

    return flyitem
end

function Scene:CreateCarry(vo)
    return self.scene_logic:CreateCarry(vo)
end

function Scene:_CreateCarry(vo)
    self.obj_id = self.obj_id + 1

    local carry = game.GamePool.CarryPool:Create()
    carry.obj_id = self.obj_id
    carry:Init(self, vo)
    self:AddObj(carry)

    if vo.to_x ~= vo.x and vo.to_y ~= vo.y and vo.to_x ~= 0 and vo.to_y ~= 0 then
        local ux, uy = game.LogicToUnitPos(vo.to_x, vo.to_y)
        carry:DoMove(ux, uy)
    else
        carry:DoIdle()
    end

    if carry:IsMainRoleCarry() then
        global.EventMgr:Fire(game.SceneEvent.MainRoleCarryChange, carry.obj_id)
    end
    return carry
end

function Scene:CreatePet(vo)
    return self.scene_logic:CreatePet(vo)
end

function Scene:_CreatePet(vo)
    self.obj_id = self.obj_id + 1
    
    local pet = game.GamePool.PetPool:Create()
    pet.obj_id = self.obj_id
    pet:Init(self, vo)
    self:AddObj(pet)

    if vo.to_x ~= vo.x and vo.to_y ~= vo.y and vo.to_x ~= 0 and vo.to_y ~= 0 then
        local ux, uy = game.LogicToUnitPos(vo.to_x, vo.to_y)
        pet:DoMove(ux, uy)
    else
        pet:DoIdle()
    end

    if pet:IsMainRolePet() then
        local main_role = self:GetMainRole()
        if main_role then
            main_role:SetPetObjID(pet.obj_id)
        end
        global.EventMgr:Fire(game.SceneEvent.MainRolePetChange, pet.obj_id)
    end
    return pet
end

function Scene:CreateRole(vo)
    return self.scene_logic:CreateRole(vo)
end

function Scene:_CreateRole(vo)
    if game.GamePool.RolePool:GetUsedNum() > config.custom.max_role_num then
        return
    end
    self.obj_id = self.obj_id + 1

    local role = game.GamePool.RolePool:Create()
    role.obj_id = self.obj_id
    role:Init(self, vo)
    self:AddObj(role)

    if vo.hp <= 0 then
        role:DoDie()
    elseif vo.state & 1 ~= 0 then
        role:DoPractice()
    else
        if vo.to_x ~= vo.x and vo.to_y ~= vo.y and vo.to_x ~= 0 and vo.to_y ~= 0 then
            local ux, uy = game.LogicToUnitPos(vo.to_x, vo.to_y)
            role:DoMove(ux, uy)
        else
            role:DoIdle()
        end
    end

    return role
end

function Scene:CreateGather(vo)
    return self.scene_logic:CreateGather(vo)
end

function Scene:_CreateGather(vo)
    self.obj_id = self.obj_id + 1

    local gather = game.GamePool.GatherPool:Create()
    gather.obj_id = self.obj_id
    gather:Init(self, vo)
    self:AddObj(gather)

    return gather
end

function Scene:CreateFlyer(vo)
    return self.flyer_mgr:Create(self, vo)
end

function Scene:FreeFlyer(id)
    self.flyer_mgr:Free(id)
end

function Scene:CreateNpc(vo)
    return self.scene_logic:CreateNpc(vo)
end

function Scene:_CreateNpc(vo)
    self.obj_id = self.obj_id + 1

    local npc = require("game/character/npc").New()
    npc.obj_id = self.obj_id
    npc:Init(self, vo)
    self:AddObj(npc)

    return npc
end

function Scene:CreateNpcList()
    if not self.scene_config or not self.scene_config.npc_list or #self.scene_config.npc_list <= 0 then
        return
    end
    
    local config_npc = config.npc

    self.npc_list = {}
    for _, item in pairs(self.scene_config.npc_list) do 
        local npc_vo = {
            npc_id = item.npc_id,
            x = item.x,
            y = item.y,
            dir_x = item.dir_x or 0,
            dir_y = item.dir_y or 0,
        }

        local npc_cfg = config_npc[item.npc_id]
        if npc_cfg then
            npc_cfg.x = item.x
            npc_cfg.y = item.y
            npc_cfg.scene = self:GetSceneID()
        end

        local npc = self:CreateNpc(npc_vo)
        self.npc_list[item.npc_id] = npc
    end
end

function Scene:GetNpc(npc_id)
    if self.npc_list then
        return self.npc_list[npc_id]
    end
end

function Scene:GetNpcList()
    return self.npc_list
end

function Scene:CreateJumpList()
    if not self.scene_config or not self.scene_config.jump_list or #self.scene_config.jump_list <= 0 then
        return
    end
    
    local jump_cfg = config_show_fly[self:GetSceneID()]

    self.jump_list = {}
    for k, v in ipairs(self.scene_config.jump_list) do 
        local from = v.from
        local to = v.to

        local lx,ly = game.UnitToLogicPos(from.x, from.z)
        local jump_vo = {
            x = lx,
            y = ly,
            is_effect = true,
            from_pos = from,
            to_pos = to,
            mid_list = v.mid,
            scene_id = self:GetSceneID()
        }

        local is_effect = true
        if jump_cfg then
            local cfg = jump_cfg[k]
            if cfg then
                is_effect = cfg.effect
            end
        end
        jump_vo.is_effect = is_effect

        local jump_point = self:CreateJumpPoint(jump_vo)
        table.insert(self.jump_list, jump_point)

        local reverse_mid_list = {}
        local mid_list = v.mid or {}
        for i=#mid_list,1,-1 do
            table.insert(reverse_mid_list, mid_list[i])
        end

        local from = v.to
        local to = v.from
        local lx,ly = game.UnitToLogicPos(from.x, from.z)
        local jump_vo = {
            x = lx,
            y = ly,
            is_effect = true,
            from_pos = from,
            to_pos = to,
            mid_list = reverse_mid_list,
            scene_id = self:GetSceneID()
        }
        jump_vo.is_effect = is_effect
        
        local jump_point = self:CreateJumpPoint(jump_vo)
        table.insert(self.jump_list, jump_point)
    end
end

function Scene:CreateJumpPoint(vo)
    return self.scene_logic:CreateJumpPoint(vo)
end

function Scene:_CreateJumpPoint(vo)
    self.obj_id = self.obj_id + 1

    local jump_point = require("game/character/jump_point").New()
    jump_point.obj_id = self.obj_id
    jump_point:Init(self, vo)
    self:AddObj(jump_point)

    return jump_point
end

function Scene:CreateDoorList()
    if not self.scene_config or not self.scene_config.door_list or #self.scene_config.door_list <= 0 then
        return
    end
    
    for _, item in ipairs(self.scene_config.door_list) do 
        local x, y = game.UnitToLogicPos(item.pos_x, item.pos_y)
        local vo = {
            door_id = tonumber(item.name),
            x = x,
            y = y,
            res = item.res,
            scene_id = item.scene_id,
        }

        self:CreateDoor(vo)
    end
end

function Scene:CreateDoor(vo)
    return self.scene_logic:CreateDoor(vo)
end

function Scene:_CreateDoor(door_vo)
    self.obj_id = self.obj_id + 1
    local door = require("game/character/door").New()
    door.obj_id = self.obj_id
    door:Init(self, door_vo)
    self:AddObj(door)
    return door
end

function Scene:GetSkillList(id)
    return self.scene_skill_list[id]
end

-- 区域判断
local height_mask = 0x000fffff
local walkable_mask = 1 << 20

function Scene:IsWalkable(x, y)
    if x >= 0 and y >= 0 and x < self.scene_config.map_width and y < self.scene_config.map_height then
        return ((self.scene_config.tile_states[x+1][y+1] or 0) & walkable_mask) > 0
    end
    return false
end

function Scene:GetHeightForLogicPos(x, y)
    local value = self.scene_config.tile_states[x+1][y+1] or 0
    return (value & height_mask) * 0.01
end

function Scene:GetHeightForUniqPos(x, y)
    return self:GetHeightForLogicPos(game.UnitToLogicPos(x, y))
end

function Scene:GetMapId()
    return self.scene_config.map_id
end

function Scene:GetMapWidth()
    return self.scene_config.map_width*game.LogicTileSize
end

function Scene:GetMapHeight()
    return self.scene_config.map_width*game.LogicTileSize
end

function Scene:GetSceneConfig()
    return self.scene_config
end

local _logic_tile_factor = game.LogicTileFactor
function Scene:GetHeightLerp(lx, ly, ux, uy, height)
    local x, y = ux * _logic_tile_factor, uy * _logic_tile_factor
    x = x - lx
    y = y - ly
    local val1, val2, val3 = self:GetHeightForLogicPos(lx, ly), self:GetHeightForLogicPos(lx + 1, ly), self:GetHeightForLogicPos(lx, ly + 1)
    if val2 == 0 then
        val2 = val1
    end
    if val3 == 0 then
        val3 = val1
    end

    local value = val1 + ((val2 - val1) * x + (val3 - val1) * y) * 0.5
    if not height or height == 0 then
        return value
    end

    local delta = _math_abs(height - value)
    if delta >= 0.7 or delta <= 0.08 then
        return value
    else
        if height > value then
            return height - 0.08
        else
            return height + 0.08
        end
    end
end

function Scene:GetHeightByRaycast(tran, x, y)
    return tran:GetHeightByRaycast(x, y, game.LayerMask.Height)
end

-- 直线寻路，dir为单位向量
function Scene:FindPath(start_pos, dir, max_dist)
    local last_pos_x, last_pos_y = start_pos.x, start_pos.y
    local cur_pos_x, cur_pos_y = last_pos_x, last_pos_y
    local float_pos_x, float_pos_y = last_pos_x, last_pos_y
    local dir_x, dir_y = cc.pNormalizeV(dir.x, dir.y)
    local grid_num = 0

    local cur_dist = 0
    while cur_dist <= max_dist do
        cur_dist = cur_dist + 0.3
        float_pos_x = float_pos_x + dir_x * 0.3
        float_pos_y = float_pos_y + dir_y * 0.3
        cur_pos_x = _math_floor(float_pos_x)
        cur_pos_y = _math_floor(float_pos_y)
        if cur_pos_x ~= last_pos_x or cur_pos_y ~= last_pos_y then
            if self:IsWalkable(cur_pos_x, cur_pos_y) then
                last_pos_x = cur_pos_x
                last_pos_y = cur_pos_y
                grid_num = grid_num + 1
            else
                break
            end
        end
    end

    return grid_num, last_pos_x, last_pos_y
end

function Scene:FindPathByUnit(start_pos, dir, max_dist)
    local cur_pos_x, cur_pos_y = 0, 0
    local tmp_pos_x, tmp_pos_y = 0, 0
    local cur_logic_pos_x, cur_logic_pos_y = game.UnitToLogicPos(start_pos.x, start_pos.y)
    local tmp_logic_pos_x, tmp_logic_pos_y = 0, 0
    local dir_x, dir_y = cc.pNormalizeV(dir.x, dir.y)
    local cur_dist = 0
    local grid_num = 0

    while cur_dist <= max_dist do
        cur_dist = cur_dist + 0.2
        tmp_pos_x = start_pos.x + dir_x * cur_dist
        tmp_pos_y = start_pos.y + dir_y * cur_dist
        tmp_logic_pos_x, tmp_logic_pos_y = game.UnitToLogicPos(tmp_pos_x, tmp_pos_y)
        if tmp_logic_pos_x ~= cur_logic_pos_x or tmp_logic_pos_y ~= cur_logic_pos_y then
            if self:IsWalkable(tmp_logic_pos_x, tmp_logic_pos_y) then
                cur_pos_x = tmp_pos_x
                cur_pos_y = tmp_pos_y
                cur_logic_pos_x = tmp_logic_pos_x
                cur_logic_pos_y = tmp_logic_pos_y
                grid_num = grid_num + 1
            else
                break
            end
        end
    end

    return grid_num, cur_pos_x, cur_pos_y
end

function Scene:FindPathBack(start_pos, dir, max_dist)
    local last_pos_x, last_pos_y = start_pos.x, start_pos.y
    local cur_pos_x, cur_pos_y = last_pos_x, last_pos_y
    local float_pos_x, float_pos_y = last_pos_x, last_pos_y
    local dir_x, dir_y = cc.pNormalizeV(dir.x, dir.y)
    local grid_num = 0

    local cur_dist = 0
    while cur_dist <= max_dist do
        cur_dist = cur_dist + 0.5
        float_pos_x = float_pos_x - dir_x * 0.5
        float_pos_y = float_pos_y - dir_y * 0.5
        cur_pos_x = _math_floor(float_pos_x)
        cur_pos_y = _math_floor(float_pos_y)
        if cur_pos_x ~= last_pos_x or cur_pos_y ~= last_pos_y then
            if self:IsWalkable(cur_pos_x, cur_pos_y) then
                last_pos_x = cur_pos_x
                last_pos_y = cur_pos_y
                grid_num = grid_num + 1
            else
                break
            end
        end
    end

    return grid_num, last_pos_x, last_pos_y
end

local _tmp_dir = {x = 0, y = 0}
function Scene:FindPathRotateAngle(start_pos, dir, min_angle, max_angle, is_minus)
    local max_dist = 1
    local mid_angle, angle_prefix
    local dest_x, dest_y, ret, rotate_dir, best_dir, best_dest_x, best_dest_y
    if is_minus then
        angle_prefix = -1
    else
        angle_prefix = 1
    end
    while min_angle <= max_angle do
        mid_angle = math.floor((min_angle + max_angle) / 2)
        rotate_dir = angle_prefix * mid_angle / 180 * math.pi
        _tmp_dir.x = dir.x * math.cos(rotate_dir) - dir.y * math.sin(rotate_dir)
        _tmp_dir.y = dir.y * math.cos(rotate_dir) + dir.x * math.sin(rotate_dir)
        ret, dest_x, dest_y = self:FindPathByUnit(start_pos, _tmp_dir, 3)
        if ret >= 2 then
            best_dir = rotate_dir
            best_dest_x, best_dest_y = dest_x, dest_y
            max_angle = mid_angle - 2
        else
            min_angle = mid_angle + 2
        end
    end
    if best_dir then
        return best_dir, best_dest_x, best_dest_y
    else
        return nil, 0, 0
    end
end

function Scene:FindPathWithDirOffset(start_pos, dir)
    local left_best_dir, left_best_dest_x, left_best_dest_y = self:FindPathRotateAngle(start_pos, dir, 1, 75, true)
    local right_best_dir, right_best_dest_x, right_best_dest_y = self:FindPathRotateAngle(start_pos, dir, 1, 75, false)
    if left_best_dir and right_best_dir then
        if math.abs(left_best_dir) < math.abs(right_best_dir) then
            return true, left_best_dest_x, left_best_dest_y
        else
            return true, right_best_dest_x, right_best_dest_y
        end
    elseif left_best_dir then
        return true, left_best_dest_x, left_best_dest_y
    elseif right_best_dir then
        return true, right_best_dest_x, right_best_dest_y
    else
        return false, 0, 0
    end

end

-- New Obj Vo Cache
function Scene:AddNewRoleVo(vo)
    if not self.new_role_list[vo.role_id] then
        self.new_role_num = self.new_role_num + 1
        self.new_role_list[vo.role_id] = vo
    else
        self.new_role_list[vo.role_id] = vo
    end

    local marry_info = game.MarryCtrl.instance:GetMarryInfo()
    if marry_info and marry_info.mate_id == vo.role_id then
        self:FireEvent(game.MarryEvent.MateNear, true, self:GetObjID(vo.role_id))
    end
end

function Scene:DelNewRoleVo(role_id)
    if self.new_role_list[role_id] then
        self.new_role_num = self.new_role_num - 1
        self.new_role_list[role_id] = nil
    end

    local marry_info = game.MarryCtrl.instance:GetMarryInfo()
    if marry_info and marry_info.mate_id == role_id then
        self:FireEvent(game.MarryEvent.MateNear, false)
    end
end

function Scene:GetNewRoleVo(role_id)
    return self.new_role_list[role_id]
end

function Scene:AddNewMonsterVo(vo)
    if not self.new_monster_list[vo.id] then
        self.new_monster_num = self.new_monster_num + 1
        self.new_monster_list[vo.id] = vo
    else
        self.new_monster_list[vo.id] = vo
    end
end

function Scene:DelNewMonsterVo(mon_id)
    if self.new_monster_list[mon_id] then
        self.new_monster_num = self.new_monster_num - 1
        self.new_monster_list[mon_id] = nil
    end
end

function Scene:GetNewMonsterVo(mon_id)
    return self.new_monster_list[mon_id]
end

function Scene:AddNewGatherVo(vo)
    if not self.new_gather_list[vo.id] then
        self.new_gather_num = self.new_gather_num + 1
        self.new_gather_list[vo.id] = vo
    else
        self.new_gather_list[vo.id] = vo
    end
end

function Scene:DelNewGatherVo(id)
    if self.new_gather_list[id] then
        self.new_gather_num = self.new_gather_num - 1
        self.new_gather_list[id] = nil
    end
end

function Scene:GetNewGatherVo(id)
    return self.new_gather_list[id]
end

function Scene:AddNewCarryVo(vo)
    if not self.new_carry_list[vo.id] then
        self.new_carry_num = self.new_carry_num + 1
        self.new_carry_list[vo.id] = vo
    else
        self.new_carry_list[vo.id] = vo
    end
end

function Scene:DelNewCarryVo(id)
    if self.new_carry_list[id] then
        self.new_carry_num = self.new_carry_num - 1
        self.new_carry_list[id] = nil
    end
end

function Scene:GetNewCarryVo(id)
    return self.new_carry_list[id]
end

function Scene:AddNewPetVo(vo)
    if not self.new_pet_list[vo.id] then
        self.new_pet_num = self.new_pet_num + 1
        self.new_pet_list[vo.id] = vo
    else
        self.new_pet_list[vo.id] = vo
    end
end

function Scene:DelNewPetVo(id)
    if self.new_pet_list[id] then
        self.new_pet_num = self.new_pet_num - 1
        self.new_pet_list[id] = nil
    end
end

function Scene:GetNewPetVo(id)
    return self.new_pet_list[id]
end

function Scene:AddNewFlyItemVo(vo)
    if not self.new_flyitem_list[vo.id] then
        self.new_flyitem_num = self.new_flyitem_num + 1
        self.new_flyitem_list[vo.id] = vo
    else
        self.new_flyitem_list[vo.id] = vo
    end
end

function Scene:DelNewFlyItemVo(id)
    if self.new_flyitem_list[id] then
        self.new_flyitem_num = self.new_flyitem_num - 1
        self.new_flyitem_list[id] = nil
    end
end

function Scene:GetNewFlyItemVo(id)
    return self.new_flyitem_list[id]
end

function Scene:AddNewDropItemVo(vo)
    vo.is_new_born = _global_time:GetServerTimeMs() - vo.born_time < 3
    if not self.new_drop_item_list[vo.id] then
        self.new_drop_item_num = self.new_drop_item_num + 1
        self.new_drop_item_list[vo.id] = vo
    else
        self.new_drop_item_list[vo.id] = vo
    end
end

function Scene:DelNewDropItemVo(id)
    if self.new_drop_item_list[id] then
        self.new_drop_item_num = self.new_drop_item_num - 1
        self.new_drop_item_list[id] = nil
    end
end

function Scene:GetNewDropItemVo(id)
    return self.new_drop_item_list[id]
end

function Scene:GetObjCount(type)
    local cnt = 0
    self:ForeachObjs(function(obj)
        if obj.obj_type == type then
            cnt = cnt + 1
        end
    end)
    return cnt
end

function Scene:ResetObjVisible()
    local main_role = self.main_role
    if not main_role then
        return
    end

    self.screen_role_num = 0

    for k, v in pairs(self.obj_list) do
        if v.obj_type == game.ObjType.Role or v.obj_type == game.ObjType.MainRole then
            self:ResetRoleShow(v)
        elseif v.obj_type == game.ObjType.Monster then
            self:ResetMonsterShow(v)
        end
    end
end

function Scene:ResetMonsterShow(obj)
    obj:SetModelVisible(true)
end

function Scene:ResetRoleShow(obj)
    obj:ResetRoleShow(true)
end

function Scene:AddRoleShowNum()
    self.screen_role_num = self.screen_role_num + 1
    return self.screen_role_num <= game.SettingCtrl.Setting.RoleNum.Value + 1
end

function Scene:FreeRoleShowNum()
    self.screen_role_num = self.screen_role_num - 1
end

function Scene:CheckOtherMonShowNum(vo)
    if vo.owner_id ~= 0 and vo.owner_id ~= self:GetMainRoleID() then
        if self.scene_other_mon_num < 10 then
            self.scene_other_mon_num = self.scene_other_mon_num + 1
            return true
        end
    else
        return true
    end
end

function Scene:FreeOtherMonShowNum()
    self.scene_other_mon_num = self.scene_other_mon_num - 1
end

function Scene:ShowBlockBox()
    local pos_x, pos_y = self.main_role.logic_pos.x, self.main_role.logic_pos.y
    for x = pos_x - 20, pos_x + 20 do
        for y = pos_y - 20, pos_y + 20 do
            if self:IsWalkable(x, y) then
                local obj = UnityEngine.GameObject.CreatePrimitive(UnityEngine.PrimitiveType.Cube).transform
                obj:SetScale(0.5, 5, 0.5);
                obj:SetPosition(x * 0.5, self.main_role:GetMapHeight(), y * 0.5);
            end
        end
    end
end

function Scene:IsDungeonScene()
    return (self.scene_type == game.SceneType.DungeonScene)
end

local AngerSceneCfg = {
    [31003] = 1,
    -- [10002] = 1,
}
function Scene:IsAngerSkillScene()
    return AngerSceneCfg[self.scene_id]
end

function Scene:IsTaskScene()
    return (self.scene_type==game.SceneType.Special)
end

function Scene:IsRobotPvpScene()
    return (self.scene_type==game.SceneType.RobotPvPScene)
end

local GuildSceneCfg = {
    Seat = config.sys_config.guild_seat_scene.value,
    Defend = config.guild_defend.scene_id,
}
function Scene:IsGuildSeatScene()
    return (self.scene_id==GuildSceneCfg.Seat)
end

function Scene:IsGuildDefendScene()
    return (self.scene_id==GuildSceneCfg.Defend)
end

function Scene:IsWorldBossScene()
    return config.world_boss_scene[self.scene_id]
end

local CareerBattleScene = {
    [config.career_battle_info.lounge_scene] = 1,
    [config.career_battle_info.battle_scene] = 1,
}
function Scene:IsCareerBattleScene()
    return CareerBattleScene[self.scene_id] == 1
end

function Scene:IsLakeBanditsScene()
    return self.scene_id==config.lake_bandits_info.scene
end

function Scene:IsGuildArenaRestScene()
    return self.scene_id == 20005
end

function Scene:IsTerritoryPrepareScene()
    return (self.scene_id==config.sys_config["territory_prepare_scene"].value)
end

function Scene:IsTerritoryBattleScene()
    return (config.territory_scene[self.scene_id]~=nil)
end

function Scene:IsGuildArenaWarFirst()
    local war = 0
    for k, v in pairs(config.jousts_hall_war) do
        if v.scene_id == self.scene_id then
            war = v.war
            break
        end
    end
    return (1 <= war and war <= 3)
end

function Scene:IsGuildArenaWarSecond()
    local war = 0
    for k, v in pairs(config.jousts_hall_war) do
        if v.scene_id == self.scene_id then
            war = v.war
            break
        end
    end
    return (war == 4)
end

function Scene:SetCrossOperate(oper_type, ...)
    self.cross_oper_info = {
        oper_type = oper_type,
        oper_param = {...},
    }
end

function Scene:GetCrossOperInfo()
    return self.cross_oper_info
end

function Scene:DoCrossOperate()
    if not self.scene_logic:CanDoCrossOperate() then
        self.cross_oper_info = nil
        return
    end

    if self.cross_oper_info then
        if self.main_role then
            self.main_role:GetOperateMgr():DoOperateByType(self.cross_oper_info.oper_type, table.unpack(self.cross_oper_info.oper_param))
        end
        self.cross_oper_info = nil
    end
end

function Scene:_PlayMusic()
    local cfg = config.scene[self.scene_id]
    global.AudioMgr:PlayMusic(cfg.music)
end

function Scene:RefreshShow()    
    for _,v in pairs(self.obj_list or {}) do
        v:RefreshShow()
    end
end

function Scene:IsSelfEnemy(target)
    return self.scene_logic:IsSelfEnemy(target)
end

function Scene:IsSelf(role_id)
    return (self:GetMainRoleID()==role_id)
end

function Scene:StartShake(x, y, z, cycle_num, cycle_time)
    if self.sys_setting_ctrl:IsSettingActived(game.SysSettingKey.MaskShake) then
        return
    end
    
    self.camera:StartShake(x, y, z, cycle_num, cycle_time)
end

function Scene:EnableRealTimeShadow(val)
    if val then
        if self.main_role then
            self.map:EnableRealTimeShadow(true)
            self.main_role:ShowShadow(false)
            self.map:SetRealTimeShadowTarget(self.main_role:GetRoot())
        end
    else
        self.map:EnableRealTimeShadow(false)
        if self.main_role then
            self.main_role:ShowShadow(true)
        end
    end
end

function Scene:CanDoGather(gather_obj)
    return self.scene_logic:CanDoGather(gather_obj)
end

function Scene:IsCatchPetScene()
    return self.scene_id == config.sys_config.scene_pet_catch_show.value
end

function Scene:IsSongliaoScene()
    return self.scene_id == config.sys_config["dynasty_war_battle_scene"].value
end

function Scene:IsSongliaoPrepareScene()

    local is = false

    for k, v in pairs(config.sys_config["dynasty_war_prepare_scene"].value) do
        if v == self.scene_id then
            is = true
            break
        end
    end

    return  is
end

function Scene:IsMarryHallScene()
    return self.scene_id == 40013
end

function Scene:CreateWeaponSoul(vo)
    return self.scene_logic:CreateWeaponSoul(vo)
end

function Scene:_CreateWeaponSoul(vo)
    self.obj_id = self.obj_id + 1
    
    local weapon_soul = game.GamePool.WeaponSoulPool:Create()
    weapon_soul.obj_id = self.obj_id
    weapon_soul:Init(self, vo)
    
    self:AddObj(weapon_soul)

    weapon_soul:DoIdle()

    return weapon_soul
end

function Scene:CreateFollowObj(vo)
    self.obj_id = self.obj_id + 1
    
    local follow_obj = game.GamePool.FollowObjPool:Create()
    follow_obj.obj_id = self.obj_id
    follow_obj:Init(self, vo)
    
    self:AddObj(follow_obj)

    follow_obj:DoIdle()

    return follow_obj
end

function Scene:InitCameraRotation()
    local x,y = self.scene_orientation[1],self.scene_orientation[2]
    self.camera:ChangeFollowRotation(x, y)
end

-- 特效限制  1:技能 2:受击特效 3:buff
function Scene:CanPlayBuffEffect()
    return _eff_mgr.instance:GetEffectNumByType(3) < 8
end

local _skill_effect_map = {[10020013] = true, [10030016] = true}
function Scene:CanPlaySkillEffect(skill_id)
    return _skill_effect_map[skill_id] or _eff_mgr.instance:GetEffectNumByType(1) < 10
end

function Scene:CanPlayBeattackEffect()
    return _eff_mgr.instance:GetEffectNumByType(2) <= 5
end

return Scene