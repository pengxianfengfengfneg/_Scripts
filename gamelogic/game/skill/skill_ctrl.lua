local SkillCtrl = Class(game.BaseCtrl)

local _configHelpSkill = config_help.ConfigHelpSkill

function SkillCtrl:_init()
    if SkillCtrl.instance ~= nil then
        error("SkillCtrl Init Twice!")
    end
    SkillCtrl.instance = self

    self.data = require("game/skill/skill_data").New(self)
    self.view = require("game/skill/skill_view").New(self)

    self.skill_setting_view = require("game/skill/skill_setting_view").New(self)
    self.change_guide_view = require("game/skill/change_guide_view").New(self)
    self.skill_blood_setting_view = require("game/skill/skill_blood_setting_view").New(self)

    self.hero_guide_view = require("game/skill/hero_guide_view").New(self)
    self.hero_set_guide_view = require("game/skill/hero_set_guide_view").New(self)
    self.hero_guide_edit_view = require("game/skill/hero_guide_edit_view").New(self)
    self.skill_info_view = require("game/skill/skill_info_view").New(self)

    self:RegisterAllProtocal()
    self:RegisterAllEvents()
end

function SkillCtrl:_delete()
    self.data:DeleteMe()
    self.view:DeleteMe()

    self.skill_setting_view:DeleteMe()
    self.change_guide_view:DeleteMe()
    self.hero_guide_view:DeleteMe()
    self.hero_set_guide_view:DeleteMe()
    self.hero_guide_edit_view:DeleteMe()
    self.skill_info_view:DeleteMe()
    self.skill_blood_setting_view:DeleteMe()

    if self.forge_view then
        self.forge_view:DeleteMe()
        self.forge_view = nil
    end

    if self.forge_select_star_view then
        self.forge_select_star_view:DeleteMe()
        self.forge_select_star_view = nil
    end

    self:ClearBigSkillCamera()

    SkillCtrl.instance = nil
end

function SkillCtrl:RegisterAllProtocal()
    --self:RegisterProtocalCallback(40802, "OnSkillGetInfo")
    self:RegisterProtocalCallback(40804, "OnSkillActive")
    self:RegisterProtocalCallback(40806, "OnSkillUpgrade")
    self:RegisterProtocalCallback(40808, "OnSkillOneKeyUp")
    self:RegisterProtocalCallback(40809, "OnSkillNew")
end

function SkillCtrl:RegisterAllEvents()
    local events = {
        {game.SceneEvent.UpdateEnterSceneInfo, function(data_list)
            self:InitSkillList(data_list)

            self:CreateBigSkillCamera()
        end},

        {game.HeroEvent.GuideChange, handler(self, self.OnGuideChange)},
        {game.HeroEvent.HeroUseGuide, handler(self, self.OnHeroUseGuide)},
        {game.SceneEvent.ChangeScene, handler(self, self.OnChangeScene)},

        {game.SysSettingEvent.OnGetSettingInfo, handler(self, self.OnGetSettingInfo)},
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SkillCtrl:InitSkillList(data_list)
    self.data:InitSkillList(data_list)
end

-- function SkillCtrl:SendSkillGetInfo()
--     local proto = {

--     }
--     self:SendProtocal(40801, proto)
-- end

-- function SkillCtrl:OnSkillGetInfo(data)
--     --[[
--         skills__id@I##lv@H
--     ]]
--     --PrintTable(data)

--     self.data:OnSkillGetInfo(data)
-- end

function SkillCtrl:SendSkillActive(id)
    local proto = {
        id = id
    }
    self:SendProtocal(40803, proto)
end

function SkillCtrl:OnSkillActive(data)
    --[[
        id__I                      // 技能ID
        lv__H                      // 技能等级
    ]]
    --PrintTable(data)

    self.data:OnSkillActive(data)
end

function SkillCtrl:SendSkillUpgrade(id)
    local proto = {
        id = id
    }
    self:SendProtocal(40805, proto)
end

function SkillCtrl:OnSkillUpgrade(data)
    --[[
        id__I                      // 技能ID
        lv__H                      // 技能等级
    ]]
    --PrintTable(data)

    self.data:OnSkillUpgrade(data)

    self:FireEvent(game.SkillEvent.SkillUpgrade, data.id, data.lv)
end

function SkillCtrl:SendSkillOneKeyUp()
    local proto = {
        
    }
    self:SendProtocal(40807, proto)
end

function SkillCtrl:OnSkillOneKeyUp(data)
    --[[
        gold__I                    // 消耗的元宝
        skills__id@I##lv@H         // 升级的技能列表 ID,等级
    ]]
    --PrintTable(data)

    self.data:OnSkillOneKeyUp(data)

    self:FireEvent(game.SkillEvent.SkillOneKeyUp, data.skills)
end

function SkillCtrl:OnSkillNew(data)
    --[[
        skills__id@I##lv@H         // 技能列表 ID,等级
    ]]
    --PrintTable(data)

    self.data:OnSkillNew(data)

    self:FireEvent(game.SkillEvent.SkillNew, data.skills)
end

function SkillCtrl:IsSkillActived(skill_id)
    return self.data:IsSkillActived(skill_id)
end

function SkillCtrl:GetSkillLv(skill_id)
    return self.data:GetSkillLv(skill_id)
end

function SkillCtrl:GetSkillLvUpCost(skill_id, skill_lv)
    return self.data:GetSkillLvUpCost(skill_id, skill_lv)
end

function SkillCtrl:CanSkillUpgrade(skill_id, skill_lv)
    return self.data:CanSkillUpgrade(skill_id, skill_lv)
end

function SkillCtrl:CanSkillUpgradeAny()
    return self.data:CanSkillUpgradeAny()
end

function SkillCtrl:GetAllActiveSkillCost()
    return self.data:GetAllActiveSkillCost()
end

function SkillCtrl:OpenView(idx)
    self.view:Open(idx)
end

function SkillCtrl:CloseView()
    self.view:Close()
end

function SkillCtrl:OpenSkillBloodSettingView()
    self.skill_blood_setting_view:Open()
end

function SkillCtrl:OpenSkillSettingView()
    self.skill_setting_view:Open()
end

function SkillCtrl:OpenHeroGuideView()
    self.hero_guide_view:Open()
end

function SkillCtrl:OpenHeroSetGuideView(skill_id)
    self.hero_set_guide_view:Open(skill_id)
end

function SkillCtrl:OpenHeroGuideEditView(name, desc)
    self.hero_guide_edit_view:Open(name, desc)
end

function SkillCtrl:OnGetSettingInfo()
    self.data:OnGetSettingInfo()
end

function SkillCtrl:SetSkillSettingValue(idx, is_selected)
    return self.data:SetSkillSettingValue(idx, is_selected)
end

function SkillCtrl:IsSkillSettingActived(idx)
    return self.data:IsSkillSettingActived(idx)
end

function SkillCtrl:IsSkillSettingActivedForId(skill_id)
    return self.data:IsSkillSettingActivedForId(skill_id)
end

function SkillCtrl:GetSkillHeroId(skill_id)
    return self.data:GetSkillHeroId(skill_id)
end

function SkillCtrl:GetSkillLegend(skill_id)
    return self.data:GetSkillLegend(skill_id)
end

function SkillCtrl:GetSkillHeroLegend(skill_id)
    return self.data:GetSkillHeroLegend(skill_id)
end

function SkillCtrl:OnUpdateHeroGuide(data)
    self.data:OnUpdateHeroGuide(data)
end

function SkillCtrl:OpenChangeGuideView(id)
    self.change_guide_view:Open(id)
end

function SkillCtrl:SetSkillGuide(data)
    self.data:SetSkillGuide(data.skill, data.id, data.legend)
end

function SkillCtrl:OnGuideChange(data)
    self.data:OnGuideChange(data)
end

function SkillCtrl:OnHeroUseGuide(data)
    self.data:OnHeroUseGuide(data)
end

function SkillCtrl:IsSkillUsedHero(skill_id)
    return self.data:IsSkillUsedHero(skill_id)
end

function SkillCtrl:IsHeroUsed(hero_id)
    return self.data:IsHeroUsed(hero_id)
end

function SkillCtrl:OpenSkillInfoView(info)
    self.skill_info_view:Open(info)
end

function SkillCtrl:OpenForgeView(forge_id)
    if not self.forge_view then
        self.forge_view = require("game/skill/forge_view").New(self)
    end
    self.forge_view:Open(forge_id)
end

function SkillCtrl:OpenForgeSelectStarView(cur_index)
    if not self.forge_select_star_view then
        self.forge_select_star_view = require("game/skill/forge_select_star_view").New(self)
    end
    self.forge_select_star_view:Open(cur_index)
end

function SkillCtrl:CheckRedPoint()
    if self:CheckSkillRedPoint() then
        return true
    end

    if self:CheckPracticeRedPoint() then
        return true
    end

    if self:CheckGatherRedPoint() then
        return true
    end

    if self:CheckForeRedPoint() then
        return true
    end

    return false
end

function SkillCtrl:CheckSkillRedPoint()
    if self:CheckSkillUpgradeRedPoint() then
        return true
    end

    if self:CheckSkillGuideRedPoint() then
        return true
    end

    return false
end

function SkillCtrl:CheckSkillUpgradeRedPoint()
    local skill_list = self:GetSkillList()
    for _,v in ipairs(skill_list) do
        local is_can = self:CanSkillUpgrade(v.id, v.lv)
        if is_can then
            return true
        end
    end

    return false
end

function SkillCtrl:CheckSkillGuideRedPoint()
    if not game.OpenFuncCtrl.instance:IsFuncOpened(game.OpenFuncId.HeroGuide) then
        return false
    end

    local skill_list = self:GetSkillList()
    for _,v in ipairs(skill_list) do
        local is_use = self:IsSkillUsedHero(v.id)
        if not is_use then
            local has_hero = game.HeroCtrl.instance:IsSkillHasHero(v.id)
            if has_hero then
                return true
            end
        end
    end

    return false
end

--修炼红点提示
function SkillCtrl:CheckPracticeRedPoint()
    local info = game.GuildCtrl.instance:GetPracticeInfo()
    --获取自身等级
    local mainrole_lv = game.Scene.instance:GetMainRoleLevel()
    --获取修炼开放等级
    local practice_open_lv = config.sys_config.guild_practice_open_lv.value

    if info and mainrole_lv >= practice_open_lv then
        for k, v in pairs(info.practice_skill) do
            if game.GuildCtrl.instance:CanSkillUpPracticeSkill(v.id, v.lv) then
                return true
            end
        end
    end
    return false
end

function SkillCtrl:CheckGatherRedPoint()
    
    return false
end

function SkillCtrl:CheckForeRedPoint()
    

    return false
end

function SkillCtrl:GetSkillList()
    return self.data:GetSkillList()
end

function SkillCtrl:PlayBigSkill(skill_id)
    if not self.has_big_skill then
        return false
    end

    if not self.career_big_skill_id then
        local career = game.Scene.instance:GetMainRoleCareer()
        self.career_big_skill_id = game.CareerBigSkill[career]
    end
    
    if skill_id ~= self.career_big_skill_id then
        return false
    end

    self.is_play_big_skill = true

    local main_cam = game.RenderUnit:GetSceneCameraObj()
    main_cam:SetVisible(false)

    game.RenderUnit:HideUI()

    local main_role = game.Scene.instance:GetMainRole()
    main_role:ShowShadow(false)    

    self.jump_camera_obj:SetVisible(true)
    self.camera_draw_obj:SetParent(main_role:GetRoot())
    self.camera_draw_obj:PlayLayerAnim(game.ObjAnimName.Skill12)

    local role_anim_time = main_role:GetAnimTime(game.ObjAnimName.Skill12)
    local camera_anim_time = self.camera_draw_obj:GetAnimTime(game.ObjAnimName.Skill12)
    self.skill_end_time = global.Time.now_time + math.max(role_anim_time, camera_anim_time) + 0.1

    return true
end

function SkillCtrl:CreateBigSkillCamera()
    if self.is_create_camera then
        return
    end
    self.is_create_camera = true

    self.has_big_skill = true
    local model_id = game.Scene.instance:GetMainRoleCareer()
    -- if model_id ~= 1 then
    --     self.has_big_skill = false
    --     return
    -- end

    self.camera_draw_obj = game.GamePool.CameraObjPool:Create()
    self.camera_draw_obj:Init() 
    self.camera_draw_obj:SetModelID(model_id)
    
    self.camera_draw_obj:SetModelChangeCallBack(function(model_type)
        self.camera_draw_obj:SetLayer(game.LayerName.SceneObject)
        self.camera_draw_obj:SetAlwaysAnim(true)

        self:CloneMainCamera()
    end)
end

function SkillCtrl:ClearBigSkillCamera()
    if self.camera_draw_obj then
        game.GamePool.CameraObjPool:Free(self.camera_draw_obj)
        self.camera_draw_obj = nil
    end
end

function SkillCtrl:CloneMainCamera()
    local main_cam = game.RenderUnit:GetSceneCameraObj()
    local clone_camera = UnityEngine.GameObject.Instantiate(main_cam)
    clone_camera:SetVisible(false)
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
        local culling_mask = game.LayerMask.Default
                                + game.LayerMask.SceneObject
                                + game.LayerMask.MainSceneObject
                                + game.LayerMask.Effect

        cam_com.clearFlags = UnityEngine.CameraClearFlags.Color
        cam_com.cullingMask = culling_mask
    end
    clone_camera.transform:ResetPRS()

    self.camera_draw_obj:AddToModel(game.ModelNodeName.Camera, self.jump_camera_obj.transform)
end

function SkillCtrl:ResumeBigSkill()
    if not self.is_play_big_skill then
        return
    end

    self.is_play_big_skill = false

    local main_cam = game.RenderUnit:GetSceneCameraObj()
    main_cam:SetVisible(true)

    game.RenderUnit:ShowUI()

    self.camera_draw_obj:PlayAnim(game.ObjAnimName.ShowIdle)
    self.jump_camera_obj:SetVisible(false)

    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        main_role:ShowShadow(true)    
    end
end

function SkillCtrl:CheckSkillGuideOpen()
    return game.OpenFuncCtrl.instance:IsFuncOpened(game.OpenFuncId.HeroGuide)
end

function SkillCtrl:OnChangeScene()
    self:ResumeBigSkill()
end

function SkillCtrl:HasSkillHeroGuide(skill_id)
    for _,v in pairs(config.hero) do
        for _,cv in ipairs(v.skill) do
            if cv[2] == skill_id then
                return true
            end
        end
    end
    return false
end


function SkillCtrl:CalcSkillDamage(skill_id, skill_lv, hero_id, legend)
    local is_no_skill = (skill_lv<=0)
    if is_no_skill then
        skill_lv = 1
    end

    skill_lv = math.min(skill_lv, #config.level)

    local skill_cfg = _configHelpSkill.GetSkillInfo(skill_id, skill_lv, hero_id, legend)
    -- 1-伤害 2-治疗 3-持续时间 4-冷却时间
    local show_type = skill_cfg.damage_type
    if is_no_skill then
        return show_type,0
    end

    local config_battle_career_fact = config.battle_career_fact
    local config_career_init = config.career_init

    --[[
        技能显示伤害值=（内功攻击*职业内功伤害系数+外功攻击*职业外功伤害系数）*技能普通伤害万分比+（冰攻击*职业冰攻击系数+火攻击*职业火攻击系数+玄攻击*职业玄攻击系数+毒攻击*职业毒攻击系数）*技能属性伤害万分比+技能固定伤害
        技能显示治疗值=（内功攻击*职业内功伤害系数+外功攻击*职业外功伤害系数）*技能普通治疗万分比+（冰攻击*职业冰攻击系数+火攻击*职业火攻击系数+玄攻击*职业玄攻击系数+毒攻击*职业毒攻击系数）*技能属性治疗万分比+技能固定治疗
    ]]
    local vo = game.Scene.instance:GetMainRoleVo()
    local attr = vo.attr
    local career_fact_cfg = config.battle_career_fact[vo.career]

    local damage = 0
    if show_type == 1 or show_type == 2 then
        damage = ( (attr.inner_att*career_fact_cfg.inner_fact + attr.outer_att*career_fact_cfg.outer_fact)*skill_cfg.skill_ratio*0.0001 + 
            (attr.aatt_ice*career_fact_cfg.ice_factor + attr.aatt_fire*career_fact_cfg.fire_factor + attr.aatt_dark*career_fact_cfg.dark_factor + attr.aatt_poison*career_fact_cfg.poison_factor)*skill_cfg.attr_ratio*0.0001 +
            skill_cfg.skill_const )
    end

    if show_type == 3 then
        damage = ( (attr.inner_att*career_fact_cfg.inner_fact + attr.outer_att*career_fact_cfg.outer_fact)*skill_cfg.cure_ratio*0.0001 + 
            (attr.aatt_ice*career_fact_cfg.ice_factor + attr.aatt_fire*career_fact_cfg.fire_factor + attr.aatt_dark*career_fact_cfg.dark_factor + attr.aatt_poison*career_fact_cfg.poison_factor)*skill_cfg.attr_cure_ratio*0.0001 +
            skill_cfg.cure_const )
    end

    if show_type == 4 then
        damage = skill_cfg.cd*0.001
    end

    if show_type >= 10 then
        damage = (show_type-10)

        show_type = 10
    end

    return show_type,damage
end

game.SkillCtrl = SkillCtrl

return SkillCtrl