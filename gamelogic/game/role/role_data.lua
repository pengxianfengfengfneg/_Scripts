local RoleData = Class(game.BaseData)

function RoleData:_init()
    self.role_info = {}
    self.title_show_setting = {}
end

function RoleData:_delete()

end

function RoleData:GetRoleLevel()
    return self.role_info.level or 1
end

function RoleData:GetRoleExp()
    return self.role_info.exp or 0
end

function RoleData:InitRoleInfo(data)
    self.role_info = data
    self.combat_power = data.combat_power

    self.chat_role_info = {
        id = data.role_id,
        name = data.name,
        platform = data.platform,
        svr_num = data.server_num,
        career = data.career,
        gender = data.gender,
        level = data.level,
        icon = data.icon,
        frame = data.frame,
        bubble = data.bubble,
    }
end

function RoleData:GetCombatPower()
    return self.combat_power or 0
end

function RoleData:SetCombatPower(val)
    self.combat_power = val
end

function RoleData:GetChatRoleInfo()
    return self.chat_role_info
end

function RoleData:GetRoleId()
    return self.role_info.role_id or 0
end

function RoleData:GetCareer()
    return self.role_info.career or 1
end

function RoleData:GetSex()
    return self.role_info.gender or 0
end

function RoleData:GetRoleInfo()
    return self.role_info
end

function RoleData:SetPersonalInfo(msg)
    self.personal_info = msg
    self:FireEvent(game.RoleEvent.PersonalInfoChange)
end

function RoleData:GetPersonalInfo()
    return self.personal_info or ""
end

function RoleData:SetRoleHonor(id)
    self.role_info.title_honor = id
end

function RoleData:GetRoleHonor()
    return self.role_info.title_honor or 0
end

function RoleData:SetTitleInfo(data)
    self.title_id = data.cur
    self.title_list = {}
    for i,v in ipairs(data.titles) do
        if v.title.valid == 1 then
            self.title_list[v.title.id] = v.title.expire
        end
    end
end

function RoleData:SetCurTitleID(id)
    self.title_id = id
    self:FireEvent(game.RoleEvent.RoleTitleChange, id)
end

function RoleData:GetCurTitleID()
    return self.title_id
end

function RoleData:AddTitle(data)
    if data.valid == 1 then
        self.title_list[data.id] = data.expire
    else
        self.title_list[data.id] = nil
    end
end

function RoleData:DelTitle(id)
    self.title_list[id] = nil
end

local _title_cfg = {
    [3000] = {
        check_func = function()
            return game.Scene.instance:GetMainRoleGuildID() ~= 0
        end,
    }
}
function RoleData:IsTitleValid(id)
    if id then
        if _title_cfg[id] then
            return _title_cfg[id].check_func()
        end
        return self.title_list[id] ~= nil
    end
    return false
end

function RoleData:SetTitleShow(idx, val)
    self.title_show_setting[idx] = val
    self:FireEvent(game.RoleEvent.TitleShowSettingChange, idx)
end

function RoleData:GetTitleShow(idx)
    return self.title_show_setting[idx] or 0xff
end

function RoleData:GetTitleExpire(id)
    return self.title_list[id] or 0
end

function RoleData:GetHonorTipState()
    local honor_sort_cfg = {}
    for _, v in pairs(config.title_honor) do
        table.insert(honor_sort_cfg, v)
    end
    table.sort(honor_sort_cfg, function(a, b)
        return a.level < b.level
    end)
    local max_lv = game.CarbonCtrl.instance:GetMaxLv(550)
    local top_honor_cfg = 0
    for _, v in ipairs(honor_sort_cfg) do
        if max_lv >= v.cond then
            top_honor_cfg = v
        else
            break
        end
    end

    if top_honor_cfg == 0 then
        return false
    end

    local honor_id = self:GetRoleHonor()
    local next_honor = honor_sort_cfg[1]
    if honor_id > 0 then
        for _, v in ipairs(honor_sort_cfg) do
            if v.level > config.title_honor[honor_id].level then
                next_honor = v
                break
            end
        end
    end
    if next_honor.level <= top_honor_cfg.level then
        if next_honor.cost == 0 or next_honor.num == 0 then
            return true
        end
        local own = game.BagCtrl.instance:GetNumById(next_honor.cost)
        return own >= next_honor.num
    end
    return false
end

function RoleData:OnExteriorBubbleInfo(data)
    self.bubble_info = data
end

function RoleData:OnExteriorBubbleChoose(data)
    self.bubble_info.id = data.id
end

function RoleData:OnExteriorFrameInfo(data)
    self.frame_info = data 
end

function RoleData:OnExteriorFrameChoose(data)
    self.frame_info.id = data.id
end

function RoleData:GetCurBubble()
    return self.bubble_info.id
end

function RoleData:GetCurFrame()
    return self.frame_info.id
end

function RoleData:GetBubbleInfo(bubble)
    for _,v in ipairs(self.bubble_info.active_list) do
        if v.id == bubble then
            return v
        end
    end
end

function RoleData:GetFrameInfo(frame)
    for _,v in ipairs(self.frame_info.active_list) do
        if v.id == frame then
            return v
        end
    end
end

return RoleData
