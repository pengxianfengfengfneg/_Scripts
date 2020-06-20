local OpenFuncData = Class(game.BaseData)

local _config_func = config.func
local UserDefault = global.UserDefault

function OpenFuncData:_init()
    self.func_info = {}
    self.effect_info = {}
end

function OpenFuncData:_delete()

end

function OpenFuncData:OnFuncInfo(data)
    local data = data or {}
    self.func_info = {}
    for _,v in ipairs(data.funcs or {}) do
        self.func_info[v.id] = true
    end
    global.EventMgr:Fire(game.OpenFuncEvent.OpenFuncInfo, self.func_info)
end

function OpenFuncData:OnFuncNew(data)
    local data = data or {}
    local new_funcs = {}

    for _,v in ipairs(data.funcs or {}) do
        self.func_info[v.id] = true
        new_funcs[v.id] = true
    end
    self:SetFuncEffectInfo(new_funcs)

    global.EventMgr:Fire(game.OpenFuncEvent.OpenFuncNew, new_funcs)
end

function OpenFuncData:SetFuncEffectInfo(func_list)
    for id, v in pairs(func_list or game.EmptyTable) do
        if _config_func[id] then
            local effect = _config_func[id].effect
            if effect < 0 then
                self.effect_info[id] = 0
            elseif effect > 0 then
                self.effect_info[id] = global.Time.now_time + _config_func[id].effect
            end
        end
    end
end

function OpenFuncData:GetFuncInfo()
    return self.func_info
end

function OpenFuncData:IsFuncOpened(func_id)
    return (self.func_info[func_id]==true)
end

function OpenFuncData:IsFuncPlayEffect(func_id)
    local time = global.Time.now_time
    local end_time = self.effect_info[func_id]
    if end_time then
        return end_time == 0 or global.Time.now_time < end_time
    end
    return false
end

function OpenFuncData:GetFuncEffectEndTime(func_id)
    return self.effect_info[func_id]
end

function OpenFuncData:ResetFuncEffect(func_id)
    if self.effect_info[func_id] then
        self.effect_info[func_id] = nil
        self:SaveOpenFuncRecord(func_id)
    end
end

function OpenFuncData:CheckLoginOpenFunc()
    if not self.func_info then
        return
    end

    local func_list = {}
    for id, v in pairs(self.func_info) do
        if not self:IsFuncRecord(id) then
            func_list[id] = true
        end
    end

    if table.nums(func_list) > 0 then
        self:SetFuncEffectInfo(func_list)
        if game.MainUICtrl.instance:IsViewOpen() then
            self:FireEvent(game.OpenFuncEvent.ShowFuncsEffect, func_list)
        end
    end
end

function OpenFuncData:SaveOpenFuncRecord(func_id)
    local open_func_record = self:GetOpenFuncRecord()
    if not open_func_record[func_id] then
        local func_list = game.SysSettingCtrl.instance:GetString(game.CommonlyKey.OpenFuncRecord)
        local record_str = tostring(func_id)
        if func_list ~= "" then
            record_str = string.format("%s|%s", func_list, func_id)
        end
        game.SysSettingCtrl.instance:SetString(game.CommonlyKey.OpenFuncRecord, record_str)
        open_func_record[func_id] = 1
    end
end

function OpenFuncData:GetOpenFuncRecord()
    if not self.open_func_record then
        local func_list = game.SysSettingCtrl.instance:GetString(game.CommonlyKey.OpenFuncRecord)
        self.open_func_record = {}
        if func_list then
            local list = string.split(func_list, "|")
            for k, v in pairs(list) do
                local id = tonumber(v)
                if id then
                    self.open_func_record[id] = 1
                end
            end
        end
    end
    return self.open_func_record
end

function OpenFuncData:IsFuncRecord(func_id)
    local open_func_record = self:GetOpenFuncRecord()
    if open_func_record then
        return open_func_record[func_id] == 1
    end
    return false
end

return OpenFuncData
