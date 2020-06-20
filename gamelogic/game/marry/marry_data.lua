local MarryData = Class(game.BaseData)

function MarryData:_init()
end

function MarryData:_delete()
end

function MarryData:SetMarryInfo(info)
    self.marry_info = info
end

function MarryData:GetMarryInfo()
    return self.marry_info
end

function MarryData:SetMarryBless(bless)
    if self.marry_info then
        self.marry_info.bless = bless
    end
end

function MarryData:GetBless()
    if self.marry_info then
        return self.marry_info.bless
    end
    return 0
end

function MarryData:SetMarrySkill(skill)
    if self.marry_info then
        for _, v in pairs(self.marry_info.skills) do
            if v.id == skill.id then
                v.level = skill.level
            end
        end
    end
end

function MarryData:GetMarrySkill(id)
    if self.marry_info then
        for _, v in pairs(self.marry_info.skills) do
            if v.id == id then
                return v
            end
        end
        -- 默认1级
        return {id = id, level = 1}
    end
end

function MarryData:GetHisLove()
    if self.marry_info then
        return self.marry_info.love_value or 0
    end
    return 0
end

function MarryData:GetMateName()
    if self.marry_info then
        return self.marry_info.mate_name
    end
    return ""
end

function MarryData:SetSkillCDList(cd_list)
    self.skill_cd_list = cd_list
end

function MarryData:GetSkillCDList()
    return self.skill_cd_list
end

function MarryData:SetSkillCD(skill_id)
    if self.skill_cd_list then
        local flag = true
        for _, v in pairs(self.skill_cd_list) do
            if v.skill_id == skill_id then
                flag = false
                v.last_use = global.Time:GetServerTime()
            end
        end
        if flag then
            table.insert(self.skill_cd_list, {skill_id = skill_id, last_use = global.Time:GetServerTime()})
        end
    end
end

function MarryData:GetSkillCD(skill_id)
    if self.skill_cd_list then
        for _, v in pairs(self.skill_cd_list) do
            if v.skill_id == skill_id then
                return v.last_use
            end
        end
    end
    return 0
end

return MarryData
