local GuildData = Class(game.BaseData)

local et = {}

function GuildData:_init(ctrl)
    self.ctrl = ctrl
end

function GuildData:_delete()
    self:ClearGuildInfo()
end

function GuildData:SetGuildInfo(guild)
    self:ResetGuildData()
    self.total_guild_contri = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.GuildCont)
    if guild.id ~= 0 then
        if guild.id ~= self.guild_id then
            self.ctrl:SendGuildDeclareList()
            self.ctrl:SendGuildHostileList()
        end

        self.guild_id = guild.id
        self.guild_info[guild.id] = guild
        for k, v in pairs(guild.members) do
            local member = v.mem
            if member.pos <= 0 or member.pos > #config.guild_pos[1] then
                member.pos = 1
            end
            self.pos_info[member.pos] = self.pos_info[member.pos] + 1
        end
        self:FireEvent(game.GuildEvent.UpdateGuildInfo, guild)
        self:FireEvent(game.GuildEvent.UpdateMemberList, self:GetGuildMembers())
    end
end

function GuildData:SetGuildList(guild_list)
    for k, v in pairs(guild_list or {}) do
        local guild = v.guild
        self.guild_info[guild.id] = self.guild_info[guild.id] or {}
        for i, j in pairs(guild) do
            self.guild_info[guild.id][i] = j
        end
    end
    self:FireEvent(game.GuildEvent.UpdateGuildList, self.guild_info)
end

function GuildData:GetGuildList()
    return self.guild_info
end

function GuildData:GetGuildId()
    return self.guild_id
end

function GuildData:GetGuildInfo(guild_id)
    return self.guild_info[guild_id or self.guild_id]
end

function GuildData:SetGuildMembers(members)
    if not self:IsGuildMember() then
        return
    end
    self:GetGuildInfo().members = members
    self:FireEvent(game.GuildEvent.UpdateMemberList, members)
end

function GuildData:GetGuildMembers(guild_id)
    local guild_info = self.guild_info[guild_id or self.guild_id] or et
    return guild_info.members or et
end

function GuildData:GetGuildMemberInfo(member_id, guild_id)
    if not self:IsGuildMember() then
        return
    end
    member_id = member_id or game.Scene.instance:GetMainRoleID()
    local guild = self:GetGuildInfo(guild_id)
    for k, v in pairs(guild.members) do
        if v.mem.id == member_id then
            return v.mem
        end
    end
end

function GuildData:MemberJoin(member_list)
    if not self:IsGuildMember() then
        return
    end
    for i, v in pairs(member_list or {}) do
        table.insert(self:GetGuildInfo().members, v)
    end
    local list_id = {}
    for i, v in pairs(member_list or {}) do
        table.insert(list_id, {id = v.mem.id})
    end
    self:RemoveMemberApply(list_id)
    self:FireEvent(game.GuildEvent.UpdateMemberList, self:GetGuildMembers())
    self:FireEvent(game.GuildEvent.UpdateGuildInfo, self:GetGuildInfo())
end

function GuildData:MemberLeave(id)
    if not self:IsGuildMember() then
        return
    end
    if id == game.Scene.instance:GetMainRoleID() then
        self:ClearGuildInfo()
        self.ctrl:OnDeclareWarListChange(self:GetDeclareWarIDList())
        self:FireEvent(game.GuildEvent.LeaveGuild)
    else
        local members = self:GetGuildMembers()
        for k, v in pairs(members or {}) do
            if v.mem.id == id then
                table.remove(members, k)
                break
            end
        end
        self:FireEvent(game.GuildEvent.UpdateMemberList, self:GetGuildMembers())
        self:FireEvent(game.GuildEvent.UpdateGuildInfo, self:GetGuildInfo())
    end
end

function GuildData:SetGuildLogs(logs)
    self.guild_logs = logs
    self:FireEvent(game.GuildEvent.UpdateLogsList, self.guild_logs)
end

function GuildData:SetGuildApplyInfo(app_list)
    self.guild_apply_info = app_list
    self:FireEvent(game.GuildEvent.UpdateAppList, self.guild_apply_info)
end

function GuildData:GetGuildApplyInfo()
    return self.guild_apply_info
end

function GuildData:AddMemberApply(data)
    if not self.guild_apply_info then
        return
    end
    for k, v in pairs(self.guild_apply_info) do
        if v.request.id == data.id then
            return
        end
    end
    table.insert(self.guild_apply_info, {request = data})
    self:FireEvent(game.GuildEvent.UpdateAppList, self.guild_apply_info)
end

function GuildData:RemoveMemberApply(list)
    if not self.guild_apply_info then
        return
    end
    for k, v in pairs(list) do
        for i, j in pairs(self.guild_apply_info) do
            if j.request.id == v.id then
                table.removebyvalue(self.guild_apply_info, j)
                break
            end
        end
    end
    self:FireEvent(game.GuildEvent.UpdateAppList, self.guild_apply_info)
end

function GuildData:GuildRename(guild_id, guild_name)
    if not self:IsGuildMember() then
        return
    end
    self:GetGuildInfo(guild_id).name = guild_name
    self:FireEvent(game.GuildEvent.UpdateGuildName, guild_id, guild_name)
    self:FireEvent(game.GuildEvent.UpdateGuildList, self:GetGuildList())
end

function GuildData:ChangeAnnounce(announce)
    if not self:IsGuildMember() then
        return
    end
    self:GetGuildInfo().announce = announce
    self:FireEvent(game.GuildEvent.UpdateAnnounce, announce)
end

function GuildData:ChangePos(change_list)
    for k, v in pairs(change_list or {}) do
        self:SetPos(v.id, v.pos)
    end
    self:FireEvent(game.GuildEvent.UpdateGuildInfo, self:GetGuildInfo())
    self:FireEvent(game.GuildEvent.UpdateMemberList, self:GetGuildMembers())
end

function GuildData:SetPos(role_id, pos)
    if not self:IsGuildMember() then
        return
    end
    local member_info = self:GetGuildMemberInfo(role_id)
    self.pos_info[member_info.pos] = self.pos_info[member_info.pos] - 1
    member_info.pos = pos
    self.pos_info[pos] = self.pos_info[pos] + 1
    self:FireEvent(game.GuildEvent.UpdateMemberPos, role_id, pos)
end

function GuildData:SetMemberOffline(role_id, time)
    if self:IsGuildMember() then

        local member_info = self:GetGuildMemberInfo(role_id)
        if member_info then
            member_info.offline = time
            self:FireEvent(game.GuildEvent.UpdateMemberOffline, role_id, time)
        end
    end
end

function GuildData:SetGuildLevel(level)
    if not self:IsGuildMember() then
        return
    end
    self:GetGuildInfo().level = level
    self:FireEvent(game.GuildEvent.UpdateGuildLevel, level)
    self:FireEvent(game.GuildEvent.UpdateGuildInfo, self:GetGuildInfo())
    self:FireEvent(game.GuildEvent.UpdateGuildList, self:GetGuildList())
end

function GuildData:GetGuildLevel()
    return self:IsGuildMember() and self:GetGuildInfo().level or 0
end

function GuildData:GetGuildName()
    return self:IsGuildMember() and self:GetGuildInfo().name or ""
end

function GuildData:IsGuildMember()
    return self.guild_id and self.guild_id ~= 0 or false
end

function GuildData:GetGuildPosMemberNums(pos)
    return self.pos_info[pos] or 0
end

function GuildData:GetGuildMemberPos()
    local member_info = self:GetGuildMemberInfo()
    if member_info then
        return member_info.pos
    else
        return 0
    end
end

function GuildData:SetGuildApply(guild_id, apply)
    if not self:IsGuildMember() then
        return
    end
    self:GetGuildInfo(guild_id).apply = apply
    if apply == 1 then
        self.ctrl:SendGuildInfo()
    end
    self:FireEvent(game.GuildEvent.ChangeApply, guild_id, apply)
end

function GuildData:SetAcceptType(type, auto)
    if not self:IsGuildMember() then
        return
    end
    local guild = self:GetGuildInfo()
    guild.accept_type = type
    guild.auto_accept = auto
    self:FireEvent(game.GuildEvent.ChangeAcceptType, type, auto)
end

function GuildData:SetGuildLiveInfo(data)
    self.guild_live_info = self.guild_live_info or {}
    for k, v in pairs(data) do
        self.guild_live_info[k] = v
    end
    self:FireEvent(game.GuildEvent.UpdateGuildLiveInfo, self.guild_live_info)
end

function GuildData:GetGuildLiveInfo(data)
    return self.guild_live_info
end

function GuildData:SetGuildLiveReward(reward_id)
    local live_info = self:GetGuildLiveInfo()
    if live_info then
        table.insert(live_info.reward, {id = reward_id})
    end
    self:FireEvent(game.GuildEvent.UpdateGuildLiveInfo, self.guild_live_info)
end

function GuildData:GetCookTypeAttr(type)
    local cook_type_attr = {
        [1] = {
            sprite = "bh_07",
            name = config.words[2385],
        },
        [2] = {
            sprite = "bh_08",
            name = config.words[2386],
        },
        [3] = {
            sprite = "bh_09",
            name = config.words[2387],
        },
    }
    return cook_type_attr[type]
end

function GuildData:SetContribute(contri)
    if not self:IsGuildMember() then
        return
    end
    self:GetGuildMemberInfo().contri = contri
    self:FireEvent(game.GuildEvent.UpdateContribute, contri)
    self:FireEvent(game.GuildEvent.UpdateMemberList, self:GetGuildMembers())
end

function GuildData:ChangeGuildContribute(contri)
    if self:IsGuildMember() then
        self:SetContribute(self:GetGuildMemberInfo().contri + contri - self.total_guild_contri)
    end
    self.total_guild_contri = contri
end

function GuildData:SetGuildFunds(funds)
    if not self:IsGuildMember() then
        return
    end
    self:GetGuildInfo().funds = funds
    self:FireEvent(game.GuildEvent.UpdateGuildInfo, self:GetGuildInfo())
end

function GuildData:SetGuildSkillList(skill_list)
    self.skill_info = skill_list
    self:FireEvent(game.GuildEvent.UpdateGuildSkillList, self.skill_info)
end

function GuildData:SetGuildSkill(skill, level)
    if self.skill_info then
        for k, v in pairs(self.skill_info) do
            if v.id == skill then
                v.lv = level
                self:FireEvent(game.GuildEvent.UpdateGuildSkillList, self.skill_info)
                break
            end
        end
    end
end

function GuildData:CanRecruit()
    return self:GetGuildMemberPos() >= game.GuildPos.Elder
end

function GuildData:SetGuildExchangeInfo(exchange_info)
    self.exchange_info = exchange_info
    self:FireEvent(game.GuildEvent.UpdateGuildExchangeInfo, self.exchange_info)
end

function GuildData:SetDailyTaskInfo(daily_task_info)
    self.daily_task_info = daily_task_info
    self:FireEvent(game.GuildEvent.UpdateDailyTaskInfo, self.daily_task_info)
end

function GuildData:DailyTaskChange(daily_task_info)
    if self.daily_task_info then
        return
    end
    for k, v in pairs(self.daily_task_info) do
        for i, j in pairs(daily_task_info) do
            if v.id == j.id then
                self.daily_task_info[k] = j
                break
            end
        end
    end
    self:FireEvent(game.GuildEvent.UpdateDailyTaskInfo, self.daily_task_info)
end

function GuildData:GetDailyTaskName(task_id)
    local task_cfg = {
        [1] = config.words[2743],
        [2] = config.words[2742],
    }
    return task_cfg[task_id]
end

function GuildData:SetPracticeInfo(data)
    self.practice_info = data
    self.prac_max_lv = data.prac_max_lv
    self:FireEvent(game.GuildEvent.UpdatePracticeInfo, data)
end

function GuildData:GetPracticeInfo()
    return self.practice_info
end

function GuildData:GetPracticeMaxLv()
    return self.prac_max_lv or 0
end

function GuildData:SetPracticeMaxLv(lv)
    self.prac_max_lv = lv
    self:FireEvent(game.GuildEvent.UpdatePracticeInfo)
end

function GuildData:GetRealPracticeMaxLv()
    local prac_max_lv = self:GetPracticeMaxLv()
    if prac_max_lv == 0 then
        local level_config = self:GetPracticeLevelConfig()
        prac_max_lv = level_config.max_practice
    end
    return prac_max_lv
end

function GuildData:GetPracticeTotalLv()
    local level = 0
    if self.practice_info then
        for k, v in pairs(self.practice_info.practice_skill or game.EmptyTable) do
            level = level + v.lv
        end
    end
    return level
end

function GuildData:PracticeUp(data)
    if not self.practice_info then return end
    for k, v in pairs(self.practice_info.practice_skill or game.EmptyTable) do
        if v.id == data.id then
            self.practice_info.practice_skill[k].lv = data.lv
            break
        end
    end
    self:FireEvent(game.GuildEvent.UpdatePracticeInfo, self.practice_info)
end

function GuildData:IsPracticeSkillAllMax()
    if not self.practice_info then
        return false
    end

    local prac_max_lv = self:GetRealPracticeMaxLv()

    for k, v in pairs(self.practice_info.practice_skill or {}) do
        if v.lv < prac_max_lv then
            return false
        end
    end

    return true
end

function GuildData:CanSkillUpPracticeSkill(id, lv)
    local max_level = self:GetRealPracticeMaxLv()
    local guild_cont = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.GuildCont)
    local role_exp = game.RoleCtrl.instance:GetRoleExp()

    local skill_cfg = config.guild_practice[id][lv]
    local skill_effect = self.ctrl:GetResearchEffect(1001)
    local cost_cont = math.max(0, skill_cfg.cost_cont - skill_effect)

    return lv < max_level and guild_cont >= cost_cont and role_exp >= skill_cfg.cost_exp
end

function GuildData:GetPracticeLevelConfig()
    local role_level = game.RoleCtrl.instance:GetRoleLevel()
    if not config.level[role_level] then
        while role_level > 0 do
            role_level = role_level - 1
            if config.level[role_level] then
                return config.level[role_level]
            end
        end
    else
        return config.level[role_level]
    end
end

function GuildData:SetDefendPanelInfo(data)
    self.defend_panel_info = data
    self:FireEvent(game.GuildEvent.UpdateDefendPanelInfo, data)
end

function GuildData:UpdateDefendPanelInfo(data)
    if self.defend_panel_info then
        for k, v in pairs(data) do
            self.defend_panel_info[k] = v
        end
        self:FireEvent(game.GuildEvent.UpdateDefendPanelInfo, data)
    end
end

function GuildData:DefendRefresh(data)
    if self.defend_panel_info then
        for k, v in pairs(data) do
            self.defend_panel_info[k] = v
        end
        self:FireEvent(game.GuildEvent.DefendRefresh, self.defend_panel_info)
    end
end

function GuildData:DefendPublish(data)
    if self.defend_panel_info then
        for k, v in pairs(data) do
            self.defend_panel_info[k] = v
        end
        self:FireEvent(game.GuildEvent.DefendPublish, self.defend_panel_info)
    end
end

function GuildData:DefendTripodHurt(data)
    if self.defend_panel_info then
        local tripod_info = self.defend_panel_info.tripod_info
        for k, v in pairs(tripod_info or {}) do
            if v.tripod_id == data.tripod_id then
                tripod_info[k] = data
                break
            end
        end
        self:FireEvent(game.GuildEvent.DefendTripodHurt, data)
    end
end

function GuildData:GetDefendPanelInfo()
    return self.defend_panel_info
end

function GuildData:SetDefendCurNum(data)
    if self.defend_panel_info then
        for k, v in pairs(data) do
            self.defend_panel_info[k] = v
        end
        self:FireEvent(game.GuildEvent.UpdateDefendCurNum, data)
    end
end

function GuildData:GetDefendCurNum()
    local defend_panel_info = self.defend_panel_info
    local data = {}
    if defend_panel_info then
        data.total_num = defend_panel_info.total_num
        data.leave_num = defend_panel_info.leave_num
    end
    return data
end

function GuildData:SetWineInfo(data)
    self.wine_info = data
    self:FireEvent(game.GuildEvent.UpdateWineInfo, data)
end

function GuildData:UpdateWineInfo(data, fire)
    fire = fire or true
    if self.wine_info then
        for k, v in pairs(data) do
            self.wine_info[k] = v
        end
        if fire then
            self:FireEvent(game.GuildEvent.UpdateWineInfo, self.wine_info)
        end
    end
end

function GuildData:GetGuildWineDiceData()
    if self.wine_info then
        return self.wine_info.dice_num
    end
end

function GuildData:SetQuestionInfo(quest_info)
    self.quest_info = quest_info
    self:FireEvent(game.GuildEvent.UpdateQuestionInfo, self.quest_info)
end

function GuildData:GetQuestionInfo()
    return self.quest_info
end

function GuildData:ResetGuildData()
    self.guild_id = 0
    self.guild_info = {}
    self.pos_info = {}

    for i=1, 5 do
        self.pos_info[i] = 0
    end
end

function GuildData:ClearGuildInfo()
    self.skill_info = nil
    self.guild_live_info = nil
    self.guild_logs = nil
    self.guild_apply_info = nil
    self.exchange_info = nil
    self.quest_info = nil
    self.daily_task_info = nil
    self.defend_panel_info = nil
    self.wine_info = nil

    self:ResetGuildData()
end

function GuildData:SetYunBiaoData(data)
    local pre_state = 0
    if self.carry_info then
        pre_state = self.carry_info.stat
    end

    self.carry_info = data
    self:FireEvent(game.GuildEvent.YunbiaoInfoChange)

    if pre_state ~= self.carry_info.stat then
        self:FireEvent(game.GuildEvent.YunbiaoStateChange, pre_state, self.carry_info.stat)
    end
end

function GuildData:SetYunBiaoQuality(quality, refresh_times)
    if self.carry_info then
        self.carry_info.quality = quality
        self.carry_info.refresh_times = refresh_times
        self:FireEvent(game.GuildEvent.YunbiaoInfoChange)
    end
end

function GuildData:SetYunBiaoPos(scene_id, x, y)
    if self.carry_info then
        self.carry_info.carry_x = x
        self.carry_info.carry_y = y
        self.carry_info.carry_scene = scene_id
        self:FireEvent(game.GuildEvent.YunbiaoInfoChange)
    end
end

function GuildData:GetYunBiaoData()
    return self.carry_info
end

function GuildData:GetCarryLeftRobTimes()
    return config.carry_common.rob_times - self.carry_info.rob_times
end

function GuildData:GetGuildLevelConfig(lv)
    local lv = lv or self:GetGuildLevel()
    if config.guild_level[lv] then
        return config.guild_level[lv]
    else
        return config.guild_level[#config.guild_level]
    end
end

function GuildData:GetBuildInfo()
    if not self:IsGuildMember() then
        return
    end
    return self:GetGuildInfo().build
end

function GuildData:UpdateBuildInfo(build)
    if not self:IsGuildMember() then
        return
    end
    self:GetGuildInfo().build = build
    self:FireEvent(game.GuildEvent.UdpateBuildInfo, build)
end

function GuildData:GetResearchInfo()
    if not self:IsGuildMember() then
        return
    end
    return self:GetGuildInfo().study
end

function GuildData:GetResearchInfoByType(type)
    local bound = 2000
    local fliter = function(v)
        if type == 1 then
            return v.id < bound
        else
            return v.id > bound
        end
    end
    local item_list = {}
    for k, v in pairs(self:GetResearchInfo() or {}) do
        if fliter(v) then
            table.insert(item_list, v)
        end
    end
    return item_list
end

function GuildData:GetResearchLevel(id)
    for k, v in pairs(self:GetResearchInfo() or {}) do
        if v.id == id then
            return v.lv
        end
    end
end

function GuildData:UpdateResearchInfo(study)
    if not self:IsGuildMember() then
        return
    end
    self:GetGuildInfo().study = study
    self:FireEvent(game.GuildEvent.UdpateResearchInfo, study)
end

function GuildData:GetResearchBuildLevel(build)
    if not self:IsGuildMember() and build == nil then
        return 0
    end
    local build_id = 1005
    for k, v in ipairs(build or self:GetGuildInfo().build) do
        if v.id == build_id then
            return v.lv
        end
    end
end

function GuildData:GetWingBuildLevel(build)
    if not self:IsGuildMember() and build == nil then
        return 0
    end
    local build_id = 1002
    for k, v in ipairs(build or self:GetGuildInfo().build) do
        if v.id == build_id then
            return v.lv
        end
    end
end

function GuildData:GetPavilionBuildLevel(build)
    if not self:IsGuildMember() and build == nil then
        return 0
    end
    local build_id = 1004
    for k, v in ipairs(build or self:GetGuildInfo().build) do
        if v.id == build_id then
            return v.lv
        end
    end
end

function GuildData:IsAllBuildMaxLevel()
    local cfg = config.guild_research
    for k, v in ipairs(self:GetGuildInfo().build) do
        if v.lv ~= cfg[v.id][#cfg[v.id]].lv then
            return false
        end
    end
    return true
end

function GuildData:SetDeclareWarList(data)
    self.declare_war_list = data
    self.ctrl:OnDeclareWarListChange(self:GetDeclareWarIDList())
    self:FireEvent(game.GuildEvent.OnGuildDeclareList, data)
end

function GuildData:GetDeclareWarIDList()
    local id_list = {}
    for k, v in ipairs(self.declare_war_list.declare) do
        id_list[v.guild_id] = true
    end
    for k, v in ipairs(self.declare_war_list.back) do
        id_list[v.guild_id] = true
    end
    return id_list
end

function GuildData:AddDeclareGuild(data)
    if self.declare_war_list then
        local info = {
            num = data.num,
            time = data.expire_time,
            exploit = data.exploit,
            guild_id = data.guild_id,
            guild_name = data.guild_name,
        }
        if data.type == 1 then
            for k,v in ipairs(self.declare_war_list.declare) do
                if v.guild_id == info.guild_id then
                    return
                end
            end
            table.insert(self.declare_war_list.declare, info)
        else
            for k,v in ipairs(self.declare_war_list.back) do
                if v.guild_id == info.guild_id then
                    return
                end
            end
            table.insert(self.declare_war_list.back, info)
        end
        self.ctrl:OnDeclareWarListChange({[data.guild_id]=1})
        self:FireEvent(game.GuildEvent.OnGuildDeclareList, self.declare_war_list)
    end
end

function GuildData:DeclareExpire(list)
    local change_list = {}
    for k, v in pairs(list) do
        self:DeleteDeclareWar(v.guild_id)
        change_list[v.guild_id] = 1
    end
    self.ctrl:OnDeclareWarListChange(change_list)
    self:FireEvent(game.GuildEvent.OnGuildDeclareList, self.declare_war_list)
end

function GuildData:IsDeclareWar(num)
    local declare_list = self.declare_war_list.declare
    for k, v in ipairs(declare_list) do
        if v.num == num then
            return true
        end
    end
    return false
end

function GuildData:IsBackWar(num)
    local back_list = self.declare_war_list.back
    for k, v in ipairs(back_list) do
        if v.num == num then
            return true
        end
    end
    return false
end

function GuildData:DeleteDeclareWar(guild_id)
    if not self.declare_war_list then
        return
    end

    local declare_list = self.declare_war_list.declare
    for k, v in ipairs(declare_list) do
        if v.guild_id == guild_id then
            table.remove(declare_list, k)
            break
        end
    end

    local back_list = self.declare_war_list.back_list
    for k, v in ipairs(back_list) do
        if v.guild_id == guild_id then
            table.remove(back_list, k)
            break
        end
    end
end

function GuildData:SetHostileList(hostile_list)
    self.hostile_list = hostile_list
    self:FireEvent(game.GuildEvent.OnGuildHostileList, hostile_list)
    self.ctrl:OnHostileListChange(self:GetHostileIDList())
end

function GuildData:GetHostileList()
    return self.hostile_list
end

function GuildData:GetHostileIDList()
    local id_list = {}
    for k, v in pairs(self.hostile_list or game.EmptyTable) do
        id_list[v.guild_id] = 1
    end
    return id_list
end

function GuildData:OnGuildHostileCancel(guild_id)
    if self.hostile_list then
        for k, v in ipairs(self.hostile_list) do
            if v.guild_id == guild_id then
                table.remove(self.hostile_list, k)
                self:FireEvent(game.GuildEvent.OnGuildHostileList, self.hostile_list)
                self.ctrl:OnHostileListChange({[guild_id]=1})
                break
            end
        end
    end
end

function GuildData:AddHostile(data)
    if self.hostile_list then
        local update = true
        for k, v in ipairs(self.hostile_list) do
            if v.guild_id == data.guild_id then
                update = false
                break
            end
        end
        if update then
            table.insert(self.hostile_list, data)
            self.ctrl:OnHostileListChange({[data.guild_id]=1})
            self:FireEvent(game.GuildEvent.OnGuildHostileList, self.hostile_list)
        end
    end
end

function GuildData:UpdateMetallTaskInfo(data)
    self.metall_task_info = self.metall_task_info or {}
    for k, v in pairs(data) do
        self.metall_task_info[k] = v
    end
    self:FireEvent(game.GuildEvent.UpdateMetallTaskInfo, self.metall_task_info)
end

function GuildData:GetMetallTaskInfo()
    return self.metall_task_info
end

function GuildData:GetMetallTaskId()
    local task_info = game.TaskCtrl.instance:GetTaskInfoByType(game.TaskType.Metall) or game.TaskCtrl.instance:GetTaskInfoByType(39)
    return task_info and task_info.id or 0
end

function GuildData:GetMetallLively()
    return self.metall_task_info.metall_lively
end

function GuildData:SetBlessInfo(data)
    self.bless_info = data
    self:FireEvent(game.GuildEvent.UpdateBlessInfo, data)
end

function GuildData:UpdateBlessInfo(data)
    if not self.bless_info then
        return
    end

    for k, v in ipairs(self.bless_info) do
        if v.id == data.id then
            v.expire = data.expire
            self:FireEvent(game.GuildEvent.UpdateBlessInfo, self.bless_info)
            return
        end
    end

    table.insert(self.bless_info, data)
    self:FireEvent(game.GuildEvent.UpdateBlessInfo, self.bless_info)
end

function GuildData:GetBlessExpireTime(id)
    for k, v in pairs(self.bless_info or {}) do
        if v.id == id then
            return v.expire
        end
    end
    return 0
end

function GuildData:GetGuildMaxMemberNum(build)
    local build_id = 1002
    local build_lv = self:GetWingBuildLevel(build)
    return config.guild_build[build_id][build_lv].effect
end

function GuildData:GetChiefName()
    if self:IsGuildMember() then
        return self:GetGuildInfo().chief_name
    else
        return ""
    end
end

function GuildData:OnGuildMoneyChange(data)
    if not self:IsGuildMember() then
        return
    end

    local lucky_money = self:GetGuildInfo().lucky_money
    for k, v in ipairs(data.lucky_money or game.EmptyTable) do
        local info = v.info
        local update = false

        for _, money in ipairs(lucky_money) do
            if money.info.id == info.id then
                lucky_money[_].info = info
                update = true
                break
            end
        end

        if not update then
            table.insert(lucky_money, v)
        end

        self:FireEvent(game.GuildEvent.OnGuildMoneyChange, info)
    end

    self:FireEvent(game.GuildEvent.UpdateGuildLuckyMoneyList, lucky_money)
    self:FireEvent(game.GuildEvent.UpdateGuildLuckyMoneyReceiveNum, self:GetReceiveNum())
end

function GuildData:OnGuildMoneyRemove(data)
    --[[
        "remove_list__T__id@I",                    -- 红包唯一ID
    ]]
    if not self:IsGuildMember() then
        return
    end

    local remove_list = {}
    local lucky_money = self:GetGuildInfo().lucky_money

    for k, v in ipairs(data.remove_list) do
        for _, money in ipairs(lucky_money) do
            if money.info.id == v.id then
                table.remove(lucky_money, _)
                break
            end
        end
        remove_list[v.id] = true
    end

    self:FireEvent(game.GuildEvent.RemoveGuildLuckyMoney, remove_list)
    self:FireEvent(game.GuildEvent.UpdateGuildLuckyMoneyList, lucky_money)
    self:FireEvent(game.GuildEvent.UpdateGuildLuckyMoneyReceiveNum, self:GetReceiveNum())
end

function GuildData:GetLuckyMoney()
    if not self:IsGuildMember() then
        return game.EmptyTable
    end
    return self:GetGuildInfo().lucky_money
end

function GuildData:GetReceiveNum()
    local count = 0
    local times = game.LuckyMoneyCtrl.instance:GetDailyLuckyMoneyTimes()

    if not self:IsGuildMember() or times <= 0 then
        return count
    end

    local lucky_money = self:GetGuildInfo().lucky_money
    for k, v in ipairs(lucky_money) do
        if self:GetReceiveState(v.info) == 1 then
            count = count + 1
        end
    end
    
    return count
end

function GuildData:GetReceiveState(info)
    local cfg = config.guild_lucky_money[info.cid]
    local is_receive = game.GuildCtrl.instance:IsReceiveLuckyMoney(info)
    local can_receive = #info.list < cfg.times

    local receive_state = 1
    if not can_receive then
        receive_state = 3
    elseif is_receive then
        receive_state = 2
    end

    return receive_state
end

function GuildData:GetStandardDenfFunds()
    if not self:IsGuildMember() then
        return 0
    end
    local funds = 0
    local build_cfg = config.guild_build
    for k, v in pairs(self:GetBuildInfo()) do
        funds = funds + build_cfg[v.id][v.lv].denf_funds
    end
    return funds
end

function GuildData:GetResearchEffect(id)
    if not self:IsGuildMember() then
        return 0
    end
    local lv = self:GetResearchLevel(id)
    if lv and lv > 0 then
        return config.guild_research[id][lv].effect
    else
        return 0
    end
end

function GuildData:OnGuildTeamCarbonInfo(data)
    self.guild_info[self.guild_id].sh_dung = data.sh_dung
    self.guild_info[self.guild_id].sh_cur_page = data.sh_cur_page
end

function GuildData:IsRivalGuild(guild_id)
    if not guild_id or guild_id == 0 or guild_id == self.guild_id or not self:IsGuildMember() then
        return false
    elseif self.declare_war_list then
        local declare_list = self.declare_war_list.declare
        for k, v in pairs(declare_list) do
            if v.guild_id == guild_id then
                return true
            end
        end
        local back_list = self.declare_war_list.back
        for k, v in pairs(back_list) do
            if v.guild_id == guild_id then
                return true
            end
        end
    end
    return false
end

function GuildData:IsHostileGuild(guild_id)
    if not guild_id or guild_id == 0 or guild_id == self.guild_id or not self:IsGuildMember()  then
        return false
    elseif self.hostile_list then
        for k, v in pairs(self.hostile_list) do
            if v.guild_id == guild_id then
                return true
            end
        end
    end
    return false
end

function GuildData:OnGuildRecruit(recruit_time)
    if not self:IsGuildMember() then
        return
    end
    self:GetGuildInfo().recruit_time = recruit_time
    self:FireEvent(game.GuildEvent.GuildRecruit, recruit_time)
end

function GuildData:GetRecruitTime()
    if not self:IsGuildMember() then
        return 0
    end
    return self:GetGuildInfo().recruit_time
end

return GuildData