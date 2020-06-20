local AttackState = Class()

local _config_skill = config.skill
local _effect_mgr = game.EffectMgr
local _logic_tile_size = game.LogicTileSize

local _configHelpSkill = config_help.ConfigHelpSkill
local _table_insert = table.insert

function AttackState:_init(obj)
	self.obj = obj
    self.effect_list = {}
end

function AttackState:_delete()
end

function AttackState:StateEnter(skill_id, skill_lv, target, hero_id, legend, assist_x, assist_y)

    local skill_cfg = _configHelpSkill.GetSkillInfo(skill_id, skill_lv, hero_id, legend)
    local action = skill_cfg.action
    local attack_time = skill_cfg.attack_time
    local skill_effect = skill_cfg.effect
    local skill_type = skill_cfg.type
    local shake_frequency = skill_cfg.shake_frequency
    local sound = skill_cfg.sound
    local sound_flag = true

    self.obj:SetMountState(0)
    self.obj:PlayAnim(action)

    local is_move_attack = attack_time > 0
    if is_move_attack then
        self.obj:SetMoveAttack(global.Time.now_time + attack_time)
        self.end_time = 0
    else
        if skill_cfg.progress_time > 0 then
            self.end_time = global.Time.now_time + skill_cfg.progress_time
        else
            self.end_time = global.Time.now_time + self.obj:GetAnimTime(action)
        end
        if target then
            self.obj:SetDirForce(target.unit_pos.x - self.obj.unit_pos.x, target.unit_pos.y - self.obj.unit_pos.y)
        end
    end

    self.rushing = false
    if skill_cfg.pos_dist > 0 and (skill_cfg.pos_type == 1 or skill_cfg.pos_type == 2) then
        if self.obj:IsClientObj() then
            if skill_cfg.pos_type == 2 then
                local dist
                dist, assist_x, assist_y = self.obj.scene:FindPath(self.obj.logic_pos, self.obj.dir, skill_cfg.pos_dist - 2)
            else
                if target then
                    if cc.pGetDistance(self.obj.logic_pos, target.logic_pos) < skill_cfg.pos_dist - 2  then
                        assist_x, assist_y = target.logic_pos.x, target.logic_pos.y
                    else
                        local dist
                        local dir = cc.pNormalize(cc.pSub_static(target.logic_pos, self.obj.logic_pos))
                        dist, assist_x, assist_y = self.obj.scene:FindPath(self.obj.logic_pos, dir, skill_cfg.pos_dist - 2)
                    end
                else
                    local dist
                    dist, assist_x, assist_y = self.obj.scene:FindPath(self.obj.logic_pos, self.obj.dir, skill_cfg.pos_dist - 2)
                end
            end
        end

        if skill_cfg.pos_time == 0 then
            self.rush_speed = 10000
        else
            self.rush_speed = skill_cfg.pos_dist / skill_cfg.pos_time * 1000
        end

        self.rushing = true
        self.rush_start_pos_x, self.rush_start_pos_y = self.obj.unit_pos.x, self.obj.unit_pos.y
        self.rush_target_pos_x, self.rush_target_pos_y = game.LogicToUnitPos(assist_x, assist_y)

        local delta_x, delta_y = self.rush_target_pos_x - self.rush_start_pos_x, self.rush_target_pos_y - self.rush_start_pos_y
        self.rush_dist = cc.pGetLengthXY(delta_x, delta_y)
        self.rush_dir_x, self.rush_dir_y = delta_x / self.rush_dist, delta_y / self.rush_dist
        self.rush_cur_dist = 0

        self.obj:SetDir(self.rush_dir_x, self.rush_dir_y)
    end

    if self.obj:CanPlaySkillEffect(skill_id) then
        if #skill_effect > 0 then
            for i,v in ipairs(skill_effect) do
                if v[1] == 1 then
                    local eff_path = string.format("effect/skill/%s.ab", v[2])
                    local effect = _effect_mgr.instance:CreateObjEffect(eff_path, self.obj.obj_id, 1)
                    effect:SetParent(self.obj:GetRoot())
                    if v[3] ~= 1 then
                        effect:SetScale(v[3], v[3], v[3])
                    end
                    if is_move_attack then
                        effect:SetTag(self.obj.obj_id)
                    elseif skill_cfg.progress_time > 0 then
                        _table_insert(self.effect_list, effect:GetID())
                    end
                elseif v[1] == 2 then
                    local eff_path = string.format("effect/skill/%s.ab", v[2])
                    local effect = _effect_mgr.instance:CreateObjEffect(eff_path, self.obj.obj_id, 1)
                    game.RenderUnit:AddToObjLayer(effect:GetRoot())
                    effect:SetDir(self.obj:GetDirXY())
                    effect:SetPosition(self.obj.unit_pos.x, self.obj:GetMapHeight(), self.obj.unit_pos.y)
                    if v[3] ~= 1 then
                        effect:SetScale(v[3], v[3], v[3])
                    end
                    if is_move_attack or skill_cfg.progress_time > 0 then
                        effect:SetTag(self.obj.obj_id)
                    elseif skill_cfg.progress_time > 0 then
                        _table_insert(self.effect_list, effect:GetID())
                    end
                elseif v[1] == 3 then
                    if target then
                        local item = self.obj.scene:CreateFlyer(v)
                        item:SetStartPos(self.obj:GetUnitPosXY())
                        item:SetTargetPos(target:GetUnitPosXY())
                        item:SetStartHeight(self.obj:GetMapHeight())
                        item:SetTargetHeight(self.obj:GetMapHeight())
                        item:SetHeightOffset(v[5])
                        item:Start()
                    end
                elseif v[1] == 4 then
                    if target then
                        local item = self.obj.scene:CreateFlyer(v)
                        item:SetStartPos(self.obj:GetUnitPosXY())
                        item:SetTargetPos(target:GetUnitPosXY())
                        item:SetStartHeight(self.obj:GetMapHeight())
                        item:SetTargetHeight(self.obj:GetMapHeight())
                        item:SetHeightOffset(v[5])
                        item:SetReturn(true, self.obj.obj_id)
                        item:Start()
                    end
                elseif v[1] == 5 then
                    if target then
                        local eff_path = string.format("effect/skill/%s.ab", v[2])
                        local effect = _effect_mgr.instance:CreateObjEffect(eff_path, self.obj.obj_id, 1)
                        effect:SetParent(target:GetRoot())
                        if v[3] ~= 1 then
                            effect:SetScale(v[3], v[3], v[3])
                        end
                    end
                end
            end
        end
    end

    if self.obj:IsClientObj() then
        if skill_type == 2 or skill_type == 4 then
            self.obj:PlaySkill(skill_id, skill_lv)
        end

        self.obj:SendAttackReq(skill_id, target, assist_x, assist_y)

        self.target_id = nil
        if skill_cfg.progress_time > 0 then
            if target then
                self.target_id = target.obj_id
                self.dist_sq = skill_cfg.dist * skill_cfg.dist
            end
        end

        if self.obj:IsMainRole() then
            self.shake_cfg = shake_frequency
            self.shake_idx = 1
            self.shake_time = 0

            local to_obj = skill_cfg.to_obj
            if to_obj ~= 1 and to_obj ~= 6 and to_obj ~= 7 then
                if not target or target:IsMonster() then
                    self.obj:EnterFightState(1)
                else
                    self.obj:EnterFightState(2)
                end
            end
            
            if skill_cfg.progress_time > 0 then
                global.EventMgr:Fire(game.SceneEvent.GatherChange, true, skill_cfg.name, skill_cfg.progress_time)
            end

            if sound and sound ~= "" then
                global.AudioMgr:PlaySound(sound)
                sound_flag = false
            end
        end
    end

    if skill_cfg.pre_time == 0 and skill_cfg.speak_name ~= "" then
        global.EventMgr:Fire(game.SceneEvent.OnSkillSpeak, skill_cfg.speak_name, skill_cfg.speak_txt, skill_cfg.speak_icon, skill_id)
        if sound and sound ~= "" and sound_flag then
            global.AudioMgr:PlaySound(sound)
            sound_flag = false
        end
    end

    if skill_cfg.bubble_time ~= 0 and skill_cfg.bubble_txt ~= "" then
        self.obj:SetSpeakBubble(skill_cfg.bubble_txt, skill_cfg.bubble_time)
        if sound and sound ~= "" and sound_flag then
            global.AudioMgr:PlaySound(sound)
            sound_flag = false
        end
    end

    if self.obj:IsMainRole() then
        self.is_big_skill = game.SkillCtrl.instance:PlayBigSkill(skill_id)

        if self.is_big_skill then
            global.EventMgr:Fire(game.SceneEvent.OnPlayBigSkill, skill_id)
        end
    end

    if #skill_cfg.random_voice > 0 then
        if skill_cfg.random_voice[1] >= math.random(1, 100) then
            local index = math.random(#skill_cfg.random_voice[2])
            global.AudioMgr:PlayVoice(skill_cfg.random_voice[2][index])
        end
    end
end

function AttackState:StateUpdate(now_time, elapse_time)
    if self.obj:IsClientObj() then
        if self.target_id then
            local target = self.obj.scene:GetObj(self.target_id)
            if not target or target:IsDead() or self.obj:GetLogicDistSq(target.logic_pos.x, target.logic_pos.y) > self.dist_sq then
                self.obj:DoIdle()
                return
            end
        end
    end

    if now_time > self.end_time then
        self.obj:DoIdle()
    else
        if self.rushing then
            local delta_dist = elapse_time * self.rush_speed * _logic_tile_size
            self.rush_cur_dist = self.rush_cur_dist + delta_dist

            if self.rush_cur_dist < self.rush_dist then
                self.obj:SetUnitPos(self.rush_start_pos_x + self.rush_dir_x * self.rush_cur_dist, self.rush_start_pos_y + self.rush_dir_y * self.rush_cur_dist)
            else
                self.obj:SetUnitPos(self.rush_target_pos_x, self.rush_target_pos_y)
                self.rushing = false
            end
        end

        if self.obj:IsMainRole() then
            self:CheckShake(now_time, elapse_time)
        end
    end
end

function AttackState:StateQuit()
    for i=1,#self.effect_list do
        _effect_mgr.instance:StopEffectByID(self.effect_list[i])
        self.effect_list[i] = nil
    end

    if self.rushing then
        self.obj:SetUnitPos(self.rush_target_pos_x, self.rush_target_pos_y)
    end

    if self.obj:IsMainRole() then
        global.EventMgr:Fire(game.SceneEvent.GatherChange, false)

        if self.is_big_skill then
            self.is_big_skill = false
            game.SkillCtrl.instance:ResumeBigSkill()
        end
    end
end

function AttackState:CheckShake(now_time, elapse_time)
    if self.shake_idx > #self.shake_cfg then
        return
    end
    self.shake_time = self.shake_time + elapse_time
    if self.shake_time > self.shake_cfg[self.shake_idx][6] then
        local cfg = self.shake_cfg[self.shake_idx]
        self.obj.scene:StartShake(cfg[1],cfg[2],cfg[3],cfg[4],cfg[5])
        self.shake_idx = self.shake_idx + 1
    end
end

return AttackState
