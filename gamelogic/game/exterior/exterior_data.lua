local ExteriorData = Class(game.BaseData)

local _table_insert = table.insert

local MountSettingKey = {
    Forever = 1,
    NotActive = 2,
    Expire = 4,
    Default = 1024,
}

function ExteriorData:_init(ctrl)
    self.ctrl = ctrl

    self.MountSettingKey = MountSettingKey
    self.FashionSettingKey = MountSettingKey

    self.load_server_setting = false
end

function ExteriorData:_delete()

end

function ExteriorData:SetMountInfo(active_list)
    -- "active_list__T__id@C##expire_time@I",
    self.active_mount_map = {}
    for _, v in pairs(active_list) do
        self.active_mount_map[v.id] = v
    end
    self:FireEvent(game.ExteriorEvent.OnExteriorMountInfo, self.active_mount_map)
end

function ExteriorData:GetMountSortList()
    if not self.active_mount_map then
        return game.EmptyTable
    end

    local active_list = {}
    local not_active_list = {}
    local mount_id = game.Scene.instance:GetMainRole():GetExteriorID(game.ExteriorType.Mount)

    local fliter = function(data)
        if not data then
            return false
        end
        
        local setting_val = self:GetMountSettingValue()
        local expire = data.expire_time
        local server_time = global.Time:GetServerTime()
        if (setting_val & MountSettingKey.Forever > 0) and (expire == 0) then
            return true
        elseif (setting_val & MountSettingKey.NotActive > 0) and (expire == nil or server_time > expire) then
            return true
        elseif (setting_val & MountSettingKey.Expire > 0) and (expire and expire > 0) then
            return true
        end
        return false
    end

    for k, v in pairs(self.active_mount_map) do
        local server_time = global.Time:GetServerTime()
        if v.expire_time ~= 0 and server_time > v.expire_time then
            self.active_mount_map[k] = nil
        else
            if v.id ~= mount_id then
                if fliter(v) then
                    _table_insert(active_list, v)
                end
            end
        end
    end

    for _, v in pairs(config.exterior_mount) do
        if not self.active_mount_map[v.id] then
            if fliter(v) then
                _table_insert(not_active_list, v)
            end
        end
    end

    active_list = game.Utils.SortByField(active_list, 'id')
    not_active_list = game.Utils.SortByField(not_active_list, 'id')
    
    local sort_list = {}
    if mount_id and fliter(self.active_mount_map[mount_id]) then
        _table_insert(sort_list, self.active_mount_map[mount_id])
    end
    for _, v in ipairs(active_list) do
        _table_insert(sort_list, v)
    end
    for _, v in ipairs(not_active_list) do
        _table_insert(sort_list, v)
    end

    return sort_list
end

function ExteriorData:SetMountSettingValue(val, server)
    if not server or self.load_server_setting then
        self.mount_setting_value = val
        self:FireEvent(game.ExteriorEvent.OnMountSettingChange, self.mount_setting_value)
    end
end

function ExteriorData:GetMountSettingValue()
    if self.load_server_setting then
        if (self.mount_setting_value & MountSettingKey.Default) == 0 then
            self.mount_setting_value = MountSettingKey.Default - 1
        end
    else
        if not self.mount_setting_value then
            self.mount_setting_value = MountSettingKey.Default - 1
        end
    end
    return self.mount_setting_value
end

function ExteriorData:IsExpireMount(id)
    if not self.active_mount_map then
        return
    end
    local mount_info = id and self.active_mount_map[id]
    if mount_info then
        local time = global.Time:GetServerTime()
        local expire_time = mount_info.expire_time
        if expire_time ~= 0 and time >= expire_time then
            return true
        end
    end
    return false
end

function ExteriorData:SetFashionSettingValue(val)
    self.fashion_setting_value = val
    self:FireEvent(game.ExteriorEvent.OnFashionSettingChange, self.fashion_setting_value)
end

function ExteriorData:GetFashionSettingValue()
    if not self.fashion_setting_value then
        self.fashion_setting_value = MountSettingKey.Forever + MountSettingKey.NotActive + MountSettingKey.Expire
    end
    return self.fashion_setting_value
end

function ExteriorData:SetActionSettingValue(val)
    self.action_setting_value = val
    self:FireEvent(game.ExteriorEvent.OnActionSettingChange, val)
end

function ExteriorData:GetActionSettingValue()
    if not self.action_setting_value then
        self.action_setting_value = MountSettingKey.Forever + MountSettingKey.NotActive + MountSettingKey.Expire
    end
    return self.action_setting_value
end

function ExteriorData:SetFrameSettingValue(val)
    self.frame_setting_value = val
    self:FireEvent(game.ExteriorEvent.OnFrameSettingChange, val)
end

function ExteriorData:GetFrameSettingValue()
    if not self.frame_setting_value then
        self.frame_setting_value = MountSettingKey.Forever + MountSettingKey.NotActive + MountSettingKey.Expire
    end
    return self.frame_setting_value
end

function ExteriorData:SetBubbleSettingValue(val)
    self.bubble_setting_value = val
    self:FireEvent(game.ExteriorEvent.OnBubbleSettingChange, val)
end

function ExteriorData:GetBubbleSettingValue()
    if not self.bubble_setting_value then
        self.bubble_setting_value = MountSettingKey.Forever + MountSettingKey.NotActive + MountSettingKey.Expire
    end
    return self.bubble_setting_value
end

function ExteriorData:GetExteriorSettingKey()
    return MountSettingKey
end

function ExteriorData:SetActionInfo(info)
    if self.action_info then
        self:SetActionTips(true)
    end
    self.action_info = info
end

function ExteriorData:GetActionState(id)
    for _, v in pairs(self.action_info) do
        if v.id == id then
            return true
        end
    end
    return false
end

function ExteriorData:SetActionSingleTime(time)
    self.action_single_time = time
end

function ExteriorData:SetActionCoupleTime(time)
    self.action_couple_time = time
end

function ExteriorData:GetActionSingleTime()
    return self.action_single_time or 0
end

function ExteriorData:GetActionCoupleTime()
    return self.action_couple_time or 0
end

function ExteriorData:GetActionTips()
    return self.action_tips
end

function ExteriorData:SetActionTips(val)
    self.action_tips = val
    self:FireEvent(game.RedPointEvent.UpdateRedPoint, game.OpenFuncId.Exterior, game.ExteriorCtrl.instance:GetTipState())
end

return ExteriorData