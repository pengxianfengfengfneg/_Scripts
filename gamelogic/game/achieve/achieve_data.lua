local AchieveData = Class(game.BaseData)

function AchieveData:_init()
end

function AchieveData:_delete()
end

function AchieveData:SetAchieveInfo(info)
    self.achieve_info = info
end

function AchieveData:GetAchieveInfo()
    return self.achieve_info
end

function AchieveData:GetAchieveTypeInfo(type)
    for _, val in pairs(self.achieve_info.types) do
        if val.type == type then
            return val
        end
    end
end

function AchieveData:GetAchieveTaskInfo(id)
    local type_list = {}
    for _, v in pairs(self.achieve_info.tasks) do
        if math.floor(v.id / 100) == id then
            table.insert(type_list, v)
        end
    end
    table.sort(type_list, function(a, b)
        return a.id < b.id
    end)
    local type_info = type_list[1]
    for _, v in ipairs(type_list) do
        if v.state <= 3 then
            type_info = v
            break
        end
        if v.state == 4 then
            type_info = v
        end
        if v.state < 3 and type_info.state == 4 then
            type_info = v
        end
    end
    return type_info
end

function AchieveData:SetNotifyInfo(info)
    if self.achieve_info == nil then
        return
    end
    for _, v in pairs(info.tasks) do
        for _, val in pairs(self.achieve_info.tasks) do
            if val.id == v.id then
                val.current = v.current
                val.state = v.state
                break
            end
        end
    end
    local flag
    for _, v in pairs(info.types) do
        flag = true
        for _, val in pairs(self.achieve_info.types) do
            if val.type == v.type then
                val.star = v.star
                val.state = v.state
                flag = false
                break
            end
        end
        if flag then
            table.insert(self.achieve_info.types, v)
        end
    end
end

function AchieveData:GetAchieveTypeTips(type)
    -- 同一分组成就，第一个未完成，第二个完成也不提示领取
    local state_list = {}
    if self.achieve_info then
        for _, v in pairs(self.achieve_info.tasks) do
            local id = math.floor(v.id / 100)
            local index = v.id % 100
            if config.achieve_task[id] and config.achieve_task[id][index].type == type then
                if state_list[id] == nil then
                    state_list[id] = {}
                end
                state_list[id][index] = v
            end
        end
    end
    for _, val in pairs(state_list) do
        local achieve = val[1]
        for _, v in ipairs(val) do
            if v.state == 3 and achieve.state >= 3 then
                return true
            elseif v.state < achieve.state then
                achieve = v
            end
        end
    end
    return false
end

function AchieveData:GetAchieveCateTips(cate)
    for k, v in pairs(config.achieve_type) do
        if v.cate == cate and self:GetAchieveTypeTips(k) then
            return true
        end
    end
    return false
end

function AchieveData:GetAchieveTips()
    for _, v in pairs(config.achieve_cate) do
        if self:GetAchieveCateTips(v.cate) then
            return true
        end
    end
    return false
end

return AchieveData
