local SwornData = Class(game.BaseData)

local empty_str = ""

function SwornData:_init()
    self.greet_info = {}
    self.platform_info = {}
end

function SwornData:HaveSwornGroup()
    return self.sworn_info ~= nil and self.sworn_info.group_id ~= 0
end

function SwornData:SetSwornInfo(data)
    self.sworn_info = data
    table.sort(self.sworn_info.mem_list, function(m, n)
        return m.mem.senior < n.mem.senior
    end)
    self:UpdateGroupName()
    self:FireEvent(game.SwornEvent.UpdateSwornInfo, self.sworn_info)
end

function SwornData:GetSwornInfo()
    return self.sworn_info
end

function SwornData:GetNotice()
    if not self:HaveSwornGroup() then
        return ""
    end
    return self.sworn_info.enounce
end

function SwornData:GetExpAddValue(sworn_value)
    if not sworn_value and not self:HaveSwornGroup() then
        return 0
    end
    sworn_value = sworn_value or self.sworn_info.sworn_value
    for k, v in ipairs(config.sworn_exp_add) do
        if sworn_value >= v.sworn_value then
            return v.exp_add
        end
    end
    return 0
end

function SwornData:UpdateSwornValue(sworn_value)
    if not self:HaveSwornGroup() then
        return
    end
    self.sworn_info.sworn_value = sworn_value
    self:FireEvent(game.SwornEvent.UpdateSwornValue, sworn_value)
end

function SwornData:ModifyGroupName(group_name)
    if not self:HaveSwornGroup() then
        return
    end
    self.sworn_info.group_name = group_name

    self:FireEvent(game.SwornEvent.UpdateSwornInfo, self.sworn_info)
    self:FireEvent(game.SwornEvent.ModifyGroupName, group_name)
end

function SwornData:UpdateGroupName()
    if not self:HaveSwornGroup() then
        return
    end
    local mem_num = table.nums(self.sworn_info.mem_list)
    if mem_num > 1 then
        local group_name = self.sworn_info.group_name
        local lens = string.utf8lens(group_name)
        local words = {}
        for i=1, #lens do
            local start_idx = i > 1 and lens[i-1]+1 or 1
            words[i] = string.sub(group_name, start_idx, lens[i])
        end
        local str_list = {empty_str, config.words[6245], config.words[6246], config.words[6247], config.words[6248]}
        words[3] = str_list[mem_num]
        self:ModifyGroupName(table.concat(words))
    end
end

function SwornData:UpdateQuality(quality)
    if not self:HaveSwornGroup() then
        return
    end
    self.sworn_info.quality = quality
    self:FireEvent(game.SwornEvent.UpdateQuality, quality)
end

function SwornData:GetSeniorName(senior_id)
    return config.sworn_senior_name[senior_id].name
end

function SwornData:GetSeniorName2(senior_id, gender)
    local my_senior = self:GetMemberInfo().senior
    local cfg = config.sworn_senior_name[senior_id]
    if my_senior > senior_id then
        return gender==1 and cfg.male_old or cfg.female_old
    else
        return gender==1 and cfg.male_young or cfg.female_young
    end
end

function SwornData:GetMemberInfo(role_id)
    if not self:HaveSwornGroup() then
        return
    end
    role_id = role_id or game.RoleCtrl.instance:GetRoleId()
    for k, v in ipairs(self.sworn_info.mem_list) do
        local mem_info = v.mem
        if mem_info.role_id == role_id then
            return mem_info
        end
    end
end

function SwornData:GetMemberList()
    if not self:HaveSwornGroup() then
        return game.EmptyTable
    end
    table.sort(self.sworn_info.mem_list, function(m, n)
        return m.mem.senior < n.mem.senior
    end)
    return self.sworn_info.mem_list
end

function SwornData:UpdateMemberList(mem_list)
    if not self:HaveSwornGroup() then
        return
    end

    local update = false
    for k, v in pairs(mem_list) do
        local role_id = v.mem.role_id
        if not self:GetMemberInfo(role_id) then
            update = true
            table.insert(self.sworn_info.mem_list, v)
            game.GameMsgCtrl.instance:PushMsg(string.format(config.words[6295], v.mem.name))
        end
    end
    table.sort(self.sworn_info.mem_list, function(m, n)
        return m.mem.senior < n.mem.senior
    end)

    if update then
        self:UpdateGroupName()
    end

    self:FireEvent(game.SwornEvent.UpdateMemberList, self.sworn_info.mem_list)
end

function SwornData:DeleteMember(data)
    if not self:HaveSwornGroup() then
        return
    end

    local mem_list = self.sworn_info.mem_list
    for k, v in ipairs(mem_list) do
        if v.mem.role_id == data.role_id then
            table.remove(mem_list, k)
            if data.role_id ~= game.RoleCtrl.instance:GetRoleId() then
                game.GameMsgCtrl.instance:PushMsg(string.format(config.words[6296], v.mem.name))
            end
            break
        end
    end 
    table.sort(self.sworn_info.mem_list, function(m, n)
        return m.mem.senior < n.mem.senior
    end)

    self:UpdateSwornValue(data.sworn_value)
    self:UpdateGroupName()

    self:FireEvent(game.SwornEvent.DeleteMember, data.role_id)
    self:FireEvent(game.SwornEvent.UpdateMemberList, self.sworn_info.mem_list)
end

function SwornData:GetQuality()
    if not self:HaveSwornGroup() then
        return 0
    end
    return self.sworn_info.quality
end

function SwornData:HaveTitle()
    if not self:HaveSwornGroup() then
        return false
    end
    return self:GetTitleGroupName() ~= ""
end

function SwornData:GetTitle(role_id)
    if not self:HaveSwornGroup() then
        return empty_str
    end
    local group_name = self:GetTitleGroupName()
    local style_name = self:GetTitleStyleName(role_id)
    if group_name ~= "" then
        return group_name .. config.sworn_base.fix_word .. style_name
    else
        return ""
    end
end

function SwornData:GetTitleColor()
    if not self:HaveSwornGroup() then
        return empty_str
    end
    local quality = self.sworn_info.quality
    return game.TitleUIColor[quality]
end

function SwornData:GetColoredTitle(role_id, is_ubb)
    if not self:HaveSwornGroup() then
        return empty_str
    end
    local title = self:GetTitle(role_id)
    local color = self:GetTitleColor()
    is_ubb = is_ubb or true
    if is_ubb then
        return string.format("[color=#%s]%s[/color]", color, title)
    else
        return string.format("<font color='#%s'>%s</font>", color, title)
    end
end

function SwornData:GetTitleGroupName()
    if not self:HaveSwornGroup() then
        return empty_str
    end
    return self.sworn_info.group_name
end

function SwornData:GetTitleStyleName(role_id)
    if not self:HaveSwornGroup() then
        return empty_str
    end
    local info = self:GetMemberInfo(role_id)
    return info.word
end

function SwornData:OnSwornModifyEnounce(enounce)
    if not self:HaveSwornGroup() then
        return
    end
    self.sworn_info.enounce = enounce
    self:FireEvent(game.SwornEvent.OnSwornModifyEnounce, enounce)
end

function SwornData:OnSwornModifyWord(word)
    if not self:HaveSwornGroup() then
        return
    end
    local mem_info = self:GetMemberInfo()
    if mem_info then
        mem_info.word = word
    end
    self:FireEvent(game.SwornEvent.OnSwornModifyWord, word)
    self:FireEvent(game.SwornEvent.UpdateMemberList, self.sworn_info.mem_list)
end

function SwornData:SetPlatformInfo(data)
    self.platform_info.registered = data.registered
    self.platform_info.greet_num = data.greet_num

    if not self.platform_info.person_list or #data.person_list ~= 0 then
        self.platform_info.person_list = data.person_list
    end
    if not self.platform_info.group_list or #data.group_list ~= 0 then
        self.platform_info.group_list = data.group_list
    end
    
    self:FireEvent(game.SwornEvent.UpdatePlatformInfo, self.platform_info)
end

function SwornData:GetPlatformInfo()
    return self.platform_info
end

function SwornData:UpdatePlatformInfo(data)
    for k, v in pairs(data) do
        self.platform_info[k] = v
    end
    self:FireEvent(game.SwornEvent.UpdatePlatformInfo, self.platform_info)
end

function SwornData:OnSwornGreet(data)
    self.platform_info.greet_num = data.greet_num
    self:SetGreet(data.type, data.id)
    self:FireEvent(game.SwornEvent.OnSwornGreet, data.greet_num)
end

function SwornData:UpdateSeniorSortInfo(data)
    self.senior_sort_info = data
    self:FireEvent(game.SwornEvent.UpdateSeniorSortInfo, data)
end

function SwornData:GetSeniorSortInfo()
    return self.senior_sort_info
end

function SwornData:LeaveGroup()
    self.sworn_info = nil
    self:FireEvent(game.SwornEvent.LeaveGroup)
end

function SwornData:SetGreet(type, id)
    self.greet_info[type] = self.greet_info[type] or {}
    self.greet_info[type][id] = 1
end

function SwornData:ClearGreetInfo()
    self.greet_info = {}
end

function SwornData:IsGreet(type, id)
    local greet_list = self.greet_info[type]
    if greet_list then
        return greet_list[id] == 1
    else
        return false
    end
end

return SwornData