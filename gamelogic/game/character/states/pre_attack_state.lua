local PreAttackState = Class()

local _config_skill = config.skill
local _effect_mgr = game.EffectMgr

local _configHelpSkill = config_help.ConfigHelpSkill

function PreAttackState:_init(obj)
	self.obj = obj
end

function PreAttackState:_delete()
end

function PreAttackState:StateEnter(skill_id, skill_lv, target, hero_id, legend, assist_x, assist_y)
    if target then
        self.obj:SetDir(target.unit_pos.x - self.obj.unit_pos.x, target.unit_pos.y - self.obj.unit_pos.y)
    end
    
    local ConfigHelpSkill = config_help.ConfigHelpSkill
    local skill_cfg = _configHelpSkill.GetSkillInfo(skill_id, skill_lv, hero_id, legend)
    local pre_effect = skill_cfg.pre_effect
    local name = skill_cfg.name
    local pre_time = skill_cfg.pre_time
    local pre_act = skill_cfg.pre_act
    local sound_flag = true

    self.obj:SetMountState(0)
    
    if self.obj:CanPlaySkillEffect(skill_id) then
        if #pre_effect > 0 then
            for i,v in ipairs(pre_effect) do
                if v[1] == 1 then
                    local eff_path = string.format("effect/skill/%s.ab", v[2])
                    local effect = _effect_mgr.instance:CreateObjEffect(eff_path, self.obj.obj_id, 1)
                    effect:SetParent(self.obj:GetRoot())
                    if v[3] ~= 1 then
                        effect:SetScale(v[3], v[3], v[3])
                    end
                    effect:SetTag(self.obj.obj_id)
                elseif v[1] == 2 then
                    local eff_path = string.format("effect/skill/%s.ab", v[2])
                    local effect = _effect_mgr.instance:CreateObjEffect(eff_path, self.obj.obj_id, 1)
                    game.RenderUnit:AddToObjLayer(effect:GetRoot())
                    effect:SetDir(self.obj:GetDirXY())
                    effect:SetPosition(self.obj.unit_pos.x, self.obj:GetMapHeight(), self.obj.unit_pos.y)
                    if v[3] ~= 1 then
                        effect:SetScale(v[3], v[3], v[3])
                    end
                    effect:SetTag(self.obj.obj_id)
                end
            end
        end
    end

    if self.obj:IsClientObj() then
        if self.obj:IsMainRole() then
            if skill_cfg.pre_sound ~= "" then
                self.sound_key = global.AudioMgr:PlaySound(skill_cfg.pre_sound)
                sound_flag = false
            end
            global.EventMgr:Fire(game.SceneEvent.GatherChange, true, name, pre_time * 0.001)
        end

        self.skill_id = skill_id
        self.skill_lv = skill_lv
        self.hero_id = hero_id
        self.legend = legend
        self.assist_x = assist_x
        self.assist_y = assist_y

        if target then
            self.target_id = target.obj_id
        else
            self.target_id = nil
        end
        self.obj:SendPreSkillReq(skill_id, target, assist_x, assist_y, 1)
    end

    self.obj:PlayAnim(pre_act)
    self.end_time = global.Time.now_time + pre_time * 0.001

    if skill_cfg.speak_name ~= "" then
        global.EventMgr:Fire(game.SceneEvent.OnSkillSpeak, skill_cfg.speak_name, skill_cfg.speak_txt, skill_cfg.speak_icon)
        if skill_cfg.pre_sound ~= "" and sound_flag then
            self.sound_key = global.AudioMgr:PlaySound(skill_cfg.pre_sound)
            sound_flag = false
        end
    end

    if skill_cfg.bubble_time ~= 0 and skill_cfg.bubble_txt ~= "" then
        self.obj:SetSpeakBubble(skill_cfg.bubble_txt, skill_cfg.bubble_time)
        if skill_cfg.pre_sound ~= "" and sound_flag then
            self.sound_key = global.AudioMgr:PlaySound(skill_cfg.pre_sound)
            sound_flag = false
        end
    end
end

function PreAttackState:StateUpdate(now_time, elapse_time)
    if now_time > self.end_time then
        if self.obj:IsClientObj() then
            local target = self.obj.scene:GetObj(self.target_id)
            if target then
                self.obj:DoAttack(self.skill_id, self.skill_lv, target, self.hero_id, self.legend, true, self.assist_x, self.assist_y)
                return
            end
        end

        self.obj:DoIdle()
    end
end

function PreAttackState:StateQuit()
	_effect_mgr.instance:ClearEffectByTag(self.obj.obj_id)
    
    if self.obj:IsClientObj() then
        if self.obj:IsMainRole() then
            global.EventMgr:Fire(game.SceneEvent.GatherChange, false)
        end
        self.obj:SendPreSkillReq(self.skill_id, nil, nil, nil, 2)
    end

    if self.sound_key then
        global.AudioMgr:StopSound(self.sound_key)
        self.sound_key = nil
    end
end

return PreAttackState
