local MentorData = Class(game.BaseData)

local _config_mentor_lv = config.mentor_lv

function MentorData:_init(ctrl)
    self.ctrl = ctrl
end

function MentorData:SetMentorInfo(data)
    self.mentor_info = data
    self:FireEvent(game.MentorEvent.UpdateMentorInfo, data)
end

function MentorData:GetMentorInfo()
    return self.mentor_info
end

function MentorData:HasMentorInfo()
    return self.mentor_info and self.mentor_info.mentor_id ~= 0
end

function MentorData:GetMentorID()
    if not self:HasMentorInfo() then
        return 0
    end
    return self.mentor_info.mentor_id
end

function MentorData:UpdateMentorInfo(data)
    if not self.mentor_info then
        return
    end
    for k, v in pairs(data) do
        self.mentor_info[k] = v
    end
    if data.mentor_id == 0 then
        self.ctrl:CloseView()
    else
        self:FireEvent(game.MentorEvent.UpdateMentorInfo, self.mentor_info)
    end
end

function MentorData:IsMentor()
    if not self:HasMentorInfo() then
        return false
    end
    return self.mentor_info.mentor_id == game.RoleCtrl.instance:GetRoleId()
end

function MentorData:GetMemberList(fliter)
    if not self:HasMentorInfo() then
        return
    end
    local member_list = {}
    for k, v in pairs(self.mentor_info.info_list) do
        if not fliter or fliter(v) then
            table.insert(member_list, v)
        end
    end
    table.sort(member_list, function(m, n)
        return m.info.senior < n.info.senior
    end)
    return member_list
end

function MentorData:OnMentorRegister(registered)
    if not self.mentor_info then
        return
    end
    self.mentor_info.registered = registered
    self:FireEvent(game.MentorEvent.OnMentorRegister, registered)
end

function MentorData:IsMentorRegistered()
    if not self.mentor_info then
        return false
    end
    return self.mentor_info.registered == 1
end

function MentorData:UpdateMentorAnswerQuiz(type, quiz_list)
    if not self.mentor_info then
        return
    end
    if type == 1 then
        self.mentor_info.mentor_quiz_list = quiz_list
    else
        self.mentor_info.tudi_quiz_list = quiz_list
    end
end

function MentorData:GetBaseInfo(role_id)
    if not self:HasMentorInfo() then
        return
    end
    if role_id == game.RoleCtrl.instance:GetRoleId() then
        return game.RoleCtrl.instance:GetRoleInfo()
    end
    for k, v in ipairs(self.mentor_info.info_list) do
        if v.info.role_id == role_id then
            return v.info
        end
    end
end

function MentorData:GetPrenticeInfo(role_id)
    if not self:HasMentorInfo() then
        return
    end
    for k, v in ipairs(self.mentor_info.tudi_list) do
        if v.tudi.role_id == role_id then
            return v.tudi
        end
    end
end

function MentorData:GetMemberType(role_id)
    if not self:HasMentorInfo() then
        return 0
    end
    if role_id == self.mentor_info.mentor_id then
        return 3
    else
        local info = self:GetPrenticeInfo(role_id)
        if not info then
            return 0
        elseif info.type == 0 then
            return 1
        elseif info.type == 1 then
            return 2
        end
    end    
end

function MentorData:GetSeniorName(senior_id, gender)
    if senior_id == 0 then
        return config.words[6425]
    else
        local senior_cfg = config.mentor_senior[senior_id]
        if gender then
            local my_senior = self:GetMySeniorID()
            if gender == game.Gender.Male then
                return my_senior < senior_id and senior_cfg.male_young or senior_cfg.male_old
            else
                return my_senior < senior_id and senior_cfg.female_young or senior_cfg.female_old
            end
        else
            return senior_cfg.name
        end
    end
end

function MentorData:GetMySeniorID()
    if not self:HasMentorInfo() then
        return
    end
    local role_id = game.RoleCtrl.instance:GetRoleId()
    if self.mentor_info.mentor_id == role_id then
        return 0
    else
        local info = self:GetPrenticeInfo(role_id)
        if info then
            return info.senior
        end
    end
    return config.mentor_base.tudi_num
end

function MentorData:UpdateMentorComment(data)
    if not self:HasMentorInfo() then
        return
    end
    local info = self:GetPrenticeInfo(data.role_id)
    if info then
        info.comment = data.comment
        self:FireEvent(game.MentorEvent.UpdatePrentice, data.role_id)
    end
end

function MentorData:GetRegisterBankInfo()
    if not self.reg_bank_data then
        self.reg_bank_data = {}
        for id, v in ipairs(config.mentor_register_bank) do
            self.reg_bank_data[id] = {}

            local mentor_cfg = string.split(v.mentor_quiz, "|")
            local mentor_info = {}

            mentor_info.quest = mentor_cfg[1]
            mentor_info.option_list = string.split(mentor_cfg[2], "/")
            mentor_info.show_info = mentor_cfg[3]
            self.reg_bank_data[id].mentor_info = mentor_info

            local prent_cfg = string.split(v.tudi_quiz, "|")
            local prent_info = {}

            prent_info.quest = prent_cfg[1]
            prent_info.option_list = string.split(prent_cfg[2], "/")
            prent_info.show_info = prent_cfg[3]
            self.reg_bank_data[id].prent_info = prent_info
        end
    end
    return self.reg_bank_data
end

function MentorData:GetMentorLevelConfig(value)
    if not value and not self:HasMentorInfo() then
        return
    end
    if not value then
        return _config_mentor_lv[self.mentor_info.mentor_lv]
    else
        for i=#_config_mentor_lv, 1, -1 do
            if value >= _config_mentor_lv[i].morality_value then
                return _config_mentor_lv[i]
            end
        end
    end
end

--师门任务奖励
function MentorData:GetMentorTaskReward(lv)
    if not self:HasMentorInfo() then
        return
    end
    local reward_list = {}
    for _, v in pairs(config.mentor_task_award) do
        table.insert(reward_list, v)
    end
    table.sort(reward_list, function(m, n)
        return m.lv > n.lv
    end)
    for k, v in ipairs(reward_list) do
        if lv >= v.lv then
            return v
        end
    end
end

--太学册任务奖励
function MentorData:GetTaixueTaskReward()
    if not self:HasMentorInfo() then
        return game.EmptyTable
    end
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    local reward_list = {}
    for k, v in pairs(config.mentor_taixue_task_award) do
        for _, cv in ipairs(game.Utils.SortByKey(v, function(m, n) return m > n end)) do
            if role_lv >= cv.lv then
                table.insert(reward_list, cv)
                break
            end
        end
    end
    table.sort(reward_list, function(m, n)
        return m.num < n.num
    end)
    return reward_list
end

function MentorData:UpdateBaseInfo(info_list)
    if not self:HasMentorInfo() then
        return
    end
    for _, v in ipairs(info_list) do
        local update = false
        for k, cv in pairs(self.mentor_info.info_list) do
            if cv.info.role_id == v.info.role_id then
                self.mentor_info.info_list[k] = v
                update = true
                break
            end
        end
        if not update then
            table.insert(self.mentor_info.info_list, v)
        end
    end
    self:FireEvent(game.MentorEvent.UpdateMemberList)
end

function MentorData:DelBaseInfo(del_id_list)
    if not self:HasMentorInfo() then
        return
    end
    for _, v in ipairs(del_id_list) do
        for k, cv in pairs(self.mentor_info.info_list) do
            if cv.info.role_id == v.id then
                table.remove(self.mentor_info.info_list, k)
                break
            end
        end
    end
    self:FireEvent(game.MentorEvent.UpdateMemberList)
end

function MentorData:UpdatePrenticeInfo(info_list)
    if not self:HasMentorInfo() then
        return
    end
    for _, v in ipairs(info_list) do
        local update = false
        for k, cv in pairs(self.mentor_info.tudi_list) do
            if cv.tudi.role_id == v.tudi.role_id then
                self.mentor_info.tudi_list[k] = v
                update = true
                break
            end
        end
        if not update then
            table.insert(self.mentor_info.tudi_list, v)
        end
    end
    self:FireEvent(game.MentorEvent.UpdateMemberList)
end

function MentorData:DelPrenticeInfo(del_id_list)
    if not self:HasMentorInfo() then
        return
    end
    for _, v in ipairs(del_id_list) do
        for k, cv in pairs(self.mentor_info.tudi_list) do
            if cv.tudi.role_id == v.id then
                table.remove(self.mentor_info.tudi_list, k)
                break
            end
        end
    end
    self:FireEvent(game.MentorEvent.UpdateMemberList)
end

function MentorData:GetPrenticeMark(role_id)
    local info = self.ctrl:GetPrenticeInfo(role_id)
    if info then
        return info.mark
    end
    return 0
end

function MentorData:GetMentorName()
    local base_info = self:GetBaseInfo(self:GetMentorID())
    if base_info then
        return base_info.name
    end
    return ""
end

function MentorData:MentorBeginPractice(role_id, practice_num)
    local info = self:GetPrenticeInfo(role_id)
    if info then
        info.practice_num = practice_num
    end
    self:FireEvent(game.MentorEvent.UpdatePrentice, role_id)
end

function MentorData:GetAdvanceTaskFinishNum(advance_tasks)
    local finish_num = 0
    local advance_cfg = config.mentor_task[game.TaskType.MentorAdvance]
    for k, v in pairs(advance_tasks) do
        local task_cfg = advance_cfg[v.id]
        if v.progress >= task_cfg.cond[2] then
            finish_num = finish_num + 1
        end
    end
    return finish_num
end

function MentorData:GetMaxStudyMark()
    local mark = 0
    for k, v in pairs(config.mentor_task[game.TaskType.MentorStudy]) do
        mark = mark + v.mark
    end
    return mark
end

function MentorData:UpdateMenterTask(role_id, mentor_tasks, replace)
    local info = self:GetPrenticeInfo(role_id)
    if info then
        if replace == 0 then
            for k, v in pairs(mentor_tasks) do
                local update = true
                for _, cv in pairs(info.mentor_tasks) do
                    if cv.id == v.id then
                        cv = v
                        update = false
                        break
                    end
                end
                if update then
                    table.insert(info.mentor_tasks, v)
                end
            end
        else
            info.mentor_tasks = mentor_tasks
        end
    end
    self:FireEvent(game.MentorEvent.UpdatePrentice, role_id)
end

function MentorData:UpdateStudyTask(role_id, learn_tasks, replace)
    local info = self:GetPrenticeInfo(role_id)
    if info then
        if info.replace == 0 then
            for k, v in pairs(learn_tasks) do
                local update = true
                for _, cv in pairs(info.learn_tasks) do
                    if cv.id == v.id then
                        cv = v
                        update = false
                        break
                    end
                end
                if update then
                    table.insert(info.learn_tasks, v)
                end
            end
        else
            info.learn_tasks = learn_tasks
        end
    end
    self:FireEvent(game.MentorEvent.UpdatePrentice, role_id)
end

function MentorData:UpdateAdvanceTask(role_id, taixue_tasks, replace)
    local info = self:GetPrenticeInfo(role_id)
    if info then
        if replace == 0 then
            for k, v in pairs(taixue_tasks) do
                local update = true
                for _, cv in pairs(info.taixue_tasks) do
                    if cv.id == v.id then
                        cv = v
                        update = false
                        break
                    end
                end
                if update then
                    table.insert(info.taixue_tasks, v)
                end
            end
        else
            info.taixue_tasks = taixue_tasks
        end
    end
    self:FireEvent(game.MentorEvent.UpdatePrentice, role_id)
end

function MentorData:IsFinishMentorTask(role_id)
    local info = self:GetPrenticeInfo(role_id)
    local mentor_task_cfg = config.mentor_task[game.TaskType.MentorTask]
    if info then
        for k, v in pairs(info.mentor_tasks) do
            local cfg = mentor_task_cfg[v.id]
            if v.progress < cfg.cond[2] then
                return false
            end
        end
        return true
    end
    return false
end

function MentorData:TakeMentorTaskAward(role_id, award_taken)
    local info = self:GetPrenticeInfo(role_id)
    if info then
        info.award_taken = award_taken
    end
    self:FireEvent(game.MentorEvent.UpdatePrentice, role_id)
end

function MentorData:GetMentorLevel()
    if self:HasMentorInfo() then
        return self.mentor_info.mentor_lv
    end
    return 0
end

return MentorData