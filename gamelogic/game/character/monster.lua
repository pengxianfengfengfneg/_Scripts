
local Monster = Class(require("game/character/character"))
local _aoi_mgr = global.AoiMgr
local _global_time = global.Time
local _model_type = game.ModelType

local _config_monster = config.monster
local _monster_size = game.MonsterSizeCfg

local _event_mgr = global.EventMgr

function Monster:_init()
    self.obj_type = game.ObjType.Monster
    self.update_cd = 0.5 + math.random(10) * 0.03

    self.beattack_info = { next_time = 0 }
end

function Monster:_delete()

end

function Monster:Init(scene, vo)
    Monster.super.Init(self, scene, vo)

    self.vo = vo
    self.uniq_id = vo.id
    self:SetLogicPos(vo.x, vo.y)
    self:CreateDrawObj()

    self:ShowShadow(true)

    self:SetHudText(game.HudItem.Name, self:GetShowName())
    self:RefreshNameColor()
    
    self:InitBuffList()

    self:RegisterAoiObj(game.AoiMask.Monster)
end

function Monster:Reset()
    if self.scene then
        if self.owner_id ~= 0 and self.owner_id ~= self.scene:GetMainRoleID() then
            self.scene:FreeOtherMonShowNum()
        end
    end

    if self.draw_obj then
        self:StopBeattackEffect()
    end

    self.model_height = nil

    Monster.super.Reset(self)
end

function Monster:Update(now_time, elapse_time)
    self:UpdateBeattackEffect(now_time)
    Monster.super.Update(self, now_time, elapse_time)
end

-- 外观形象相关
function Monster:CreateDrawObj()
    local cfg = _config_monster[self.vo.mid]
    self.monsetr_cfg = cfg

    self.is_boss = (self.monsetr_cfg.boss==1)

    if cfg.model_id < 100000 then
        self.draw_obj = game.GamePool.DrawObjPool:Create()
        self.draw_obj:Init(game.BodyType.Monster)
        self.draw_obj:SetParent(self.root_obj.tran)
        
        if cfg.zoom ~= 1.00 then
            self.draw_obj:SetScale(cfg.zoom)
        end

        self.draw_obj:SetModelID(_model_type.Body, cfg.model_id)
        self.draw_obj:SetModelChangeCallBack(function()
            self:RefreshShow()
        end)
    else
        self.draw_obj = game.GamePool.DrawObjPool:Create()
        self.draw_obj:Init(game.BodyType.Role)
        self.draw_obj:SetParent(self.root_obj.tran)
        self.draw_obj:SetModelID(_model_type.Body, cfg.model_id)

        local model_id, is_two = config_help.ConfigHelpModel.GetWeaponID(cfg.model_id // 100000)
        self.draw_obj:SetModelID(_model_type.Weapon, model_id)
        if is_two and model_id < 4008 then
            self.draw_obj:SetModelID(_model_type.Weapon2, model_id)
        end

        model_id = config_help.ConfigHelpModel.GetHairID(cfg.model_id // 100000)
        self.draw_obj:SetModelID(_model_type.Hair, model_id)

        self.draw_obj:SetModelChangeCallBack(function()
            self:RefreshShow()
        end)
    end

    self:SetClickCallBack(function()
        if self:IsDead() then
            return
        end
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then
            main_role:SelectTarget(self)
            main_role:GetOperateMgr():DoAttackTarget(self.obj_id, false)
        end
    end, 1)
end

function Monster:GetMonsterId()
    return self.vo.mid
end

function Monster:GetOwnerID()
    return self.vo.owner_id
end

function Monster:GetOwnerTeamID()
    return self.vo.owner_team
end

function Monster:GetIconID()
    return self.monsetr_cfg.icon_id
end

function Monster:GetShowName()
    local name = self.vo.name
    local owner_name = self.vo.owner_name
    local owner_team = self.vo.owner_team

    if owner_team ~= 0 then
        return string.format(config.words[105], owner_name .. config.words[1304], name)
    elseif owner_name ~= "" then
        return string.format(config.words[105], owner_name, name)
    else
        return name
    end
end

function Monster:IsMonster()
    return true
end

function Monster:IsBoss()
    return self.is_boss
end

function Monster:GetServerType()
    return 1
end

function Monster:SetOwnerType(owner_type)
    self.owner_type = owner_type
end

function Monster:GetOwnerType()
    return self.owner_type
end

function Monster:DoDie()
	self:ClearAllBuff()
    Monster.super.DoDie(self)

    _event_mgr:Fire(game.SceneEvent.MonsterDie, self:GetMonsterId())
end

function Monster:DoBeattack(attacker, skill_id, skill_lv, defer_info)
    self:StartBeattackEffect()
    Monster.super.DoBeattack(self, attacker, skill_id, skill_lv, defer_info)
end

function Monster:CanBeAttack()
    if self.vo.attackable == 0 then
        return false
    end
    return Monster.super.CanBeAttack(self)
end

-- effect
local _beattack_interval = 0.04
function Monster:StartBeattackEffect()
    if not self.beattack_info.enable then
        self.beattack_info.enable = true
        self.beattack_info.end_time = _global_time.now_time + _beattack_interval
        self.draw_obj:SetMatPropertyFloat(game.MaterialProperty.FlashIntensity, 0.6, _model_type.Body)
    end
end

function Monster:UpdateBeattackEffect(now_time)
    if self.beattack_info.enable then
        if now_time > self.beattack_info.end_time then
            self:StopBeattackEffect()
        end
    end
end

function Monster:StopBeattackEffect()
    self.beattack_info.enable = false
    self.draw_obj:SetMatPropertyFloat(game.MaterialProperty.FlashIntensity, 0.0, _model_type.Body)
end

function Monster:RefreshShow()
    self:SetModelVisible(self:IsSettingVisible())
end

function Monster:IsSettingVisible()
    return (not game.SysSettingCtrl.instance:IsSettingActived(game.SysSettingKey.MaskMonster))
end

function Monster:RefreshNameColor()
    if game.Scene.instance:GetSceneType() == game.SceneType.OutSideScene then
        -- 野外场景怪名称颜色读配置
        local cfg = _config_monster[self.vo.mid]
        self:SetHudTextColor(game.HudItem.Name, cfg.name_color)
    else
        local main_role = self.scene:GetMainRole()
        if main_role and main_role:IsEnemy(self) then
            self:SetHudTextColor(game.HudItem.Name, 2)
        else
            self:SetHudTextColor(game.HudItem.Name, 3)
        end
    end
end

function Monster:SetDir(x, y)
    if self:GetSpeed() <= 0 then
        return
    end

    Monster.super.SetDir(self, x, y)
end

function Monster:SetDirForce(x, y)
    if self:GetSpeed() <= 0 then
        return
    end

    Monster.super.SetDirForce(self, x, y)
end

function Monster:SetFirstAtt(first_att)
    if first_att ~= self.vo.first_att then
        self.vo.first_att = first_att
        game.Scene.instance:GetSceneLogic():SetFirstAtt(self, first_att)
        global.EventMgr:Fire(game.SceneEvent.TargetOwnerTypeChange, self)
    end
end

function Monster:GetModelHeight()
    if self.model_height == nil then
        local cfg = _config_monster[self.vo.mid]
        local model_id = cfg.model_id
        if cfg.model_height == 0 then
            if _monster_size[model_id] then
                self.model_height = _monster_size[model_id][2] * cfg.zoom + 0.3
            else
                self.model_height = 2
            end
        else
            self.model_height = cfg.model_height * cfg.zoom
        end
    end
    return self.model_height
end

function Monster:IsBoss()
    return self.is_boss
end

return Monster
