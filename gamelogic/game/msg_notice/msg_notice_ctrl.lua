local MsgNoticeCtrl = Class(game.BaseCtrl)

local _et = {}
local config_msg_notice = config.msg_notice
local UserDefault = global.UserDefault
local global_Time = global.Time
local MsgNoticeType = game.MsgNoticeType

function MsgNoticeCtrl:_init()
    if MsgNoticeCtrl.instance ~= nil then
        error("MsgNoticeCtrl Init Twice!")
    end
    MsgNoticeCtrl.instance = self

    self.msg_notice_view = require("game/msg_notice/msg_notice_view").New(self)

    self.msg_notice_list = {}

    self:RegisterAllEvents() 

    global.Runner:AddUpdateObj(self, 2)
end

function MsgNoticeCtrl:_delete()
    global.Runner:RemoveUpdateObj(self)

    self.msg_notice_list = nil
    self.msg_notice_view:DeleteMe()

    MsgNoticeCtrl.instance = nil
end

function MsgNoticeCtrl:RegisterAllEvents()
    local events = {
        {game.MsgNoticeEvent.AddMsgNotice, handler(self,self.OnAddMsgNotice)},
        {game.SceneEvent.UpdateEnterSceneInfo, handler(self,self.OnUpdateEnterSceneInfo)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MsgNoticeCtrl:RegisterAllProtocals()
    
end

function MsgNoticeCtrl:OpenView(msg_type)
    if not self:HasAnyMsgNotice() then
        game.GameMsgCtrl.instance:PushMsg(config.words[6354])
        return
    end

    local msg_open_type = msg_type or self:GetMsgOpenType()
    self.msg_notice_view:Open(msg_open_type)
end

local MsgTypeSort = {
    game.MsgNoticeType.System,
    game.MsgNoticeType.Activity,
    game.MsgNoticeType.Social
}

function MsgNoticeCtrl:GetMsgOpenType()
    local UnReadCounter = {}
    local ReadCounter = {}

    for k,v in pairs(self.msg_notice_list) do
        local cfg = config_msg_notice[k]
        if cfg then
            for _,cv in ipairs(v) do
                local read_flag = tonumber(cv[3])
                if read_flag == 0 then
                    UnReadCounter[cfg.type] = 1
                else
                    ReadCounter[cfg.type] = 1
                end
            end
        end
    end

    for k,v in pairs(MsgTypeSort) do
        if UnReadCounter[v] then
            return v
        end
    end

    for k,v in pairs(MsgTypeSort) do
        if ReadCounter[v] then
            return v
        end
    end

    return MsgTypeCounter[1]
end

function MsgNoticeCtrl:OnUpdateEnterSceneInfo(data)
    if not self.role_id then
        self.role_id = data.role_id

        self:ReadMsgNotice()
    end
end

function MsgNoticeCtrl:ReadMsgNotice()
    if self.is_read_msg then
        return
    end
    self.is_read_msg = true

    for k,v in pairs(config_msg_notice) do
        local key = string.format("%s_%s", self.role_id, k)
        local msg = UserDefault:GetString(key, "")
        if msg ~= "" then
            if v.type == MsgNoticeType.Activity then
                UserDefault:SetString(key, "")
            else
                local msg_list = string.split(msg, "#")

                local list = {}
                for _,cv in ipairs(msg_list) do
                    local tb = string.split(cv, "|")
                    table.insert(list, tb)
                end

                self.msg_notice_list[k] = list
            end
        end
    end

    self:FireEvent(game.MsgNoticeEvent.UpdateMsgNotice)
end

function MsgNoticeCtrl:OnAddMsgNotice(id, ...)
    local cfg = config_msg_notice[id]
    if not cfg or (not cfg.check_lv_func(cfg)) then
        return
    end
    
    local list = self.msg_notice_list[id]
    if not list then
        list = {}
        self.msg_notice_list[id] = list
    end

    local time = math.floor(global_Time:GetServerTimeMs()*100)
    for _,v in ipairs(list) do
        local time_stamp = tonumber(v[2])
        if time_stamp == time then
            return
        end
    end

    local params = {...}
    table.insert(params, 1, 0)
    table.insert(params, 1, time)
    table.insert(params, 1, id)

    table.insert(list, params)

    self:SaveMsgNotie(id)

    self:FireEvent(game.MsgNoticeEvent.UpdateMsgNotice)
end

function MsgNoticeCtrl:SaveMsgNotie(id)
    local list = self.msg_notice_list[id]
    if not list then
        return
    end

    local msg_list = {}
    for _,v in ipairs(list) do
        local msg = table.concat(v, "|")
        table.insert(msg_list, msg)
    end

    local key = string.format("%s_%s", self.role_id, id)
    local content = table.concat(msg_list, "#")
    UserDefault:SetString(key, content)
end

local NextUpdateTime = 0
function MsgNoticeCtrl:Update(now_time, elapse_time)
    if now_time < NextUpdateTime then
        return
    end

    NextUpdateTime = now_time + 5

    local act_ctrl = game.ActivityMgrCtrl.instance
    local now_server_time = global_Time:GetServerTime()
    for k,v in pairs(self.msg_notice_list) do
        local del_list = {}
        local is_delete = false
        for ck,cv in ipairs(v) do
            local id = tonumber(cv[1])
            local cfg = config_msg_notice[id]
            if cfg then
                local time = tonumber(cv[2])
                local expire_time = time*0.01 + cfg.keep_time
                if cfg.type == MsgNoticeType.Activity then
                    expire_time = tonumber(cv[5])
                end

                if now_server_time >= expire_time then
                    del_list[ck] = 1
                    is_delete = true
                end
            end
        end

        if is_delete then
            local new_list = {}
            for ck,cv in ipairs(v) do
                if not del_list[ck] then
                    table.insert(new_list, cv)
                end
            end

            self.msg_notice_list[k] = new_list

            self:SaveMsgNotie(k)

            self:FireEvent(game.MsgNoticeEvent.UpdateMsgNotice)
        end
    end
end

function MsgNoticeCtrl:GetMsgNoticeByType(type)
    local list = {}
    for k,v in pairs(self.msg_notice_list) do
        local cfg = config_msg_notice[k]
        if cfg and cfg.type==type then
            for _,cv in ipairs(v) do
                table.insert(list, cv)
            end
        end
    end

    table.sort(list, function(v1,v2)
        return (tonumber(v1[2])>tonumber(v2[2]))
    end)

    return list
end

function MsgNoticeCtrl:IsMsgNoticeTypeEmpty(type)
    for k,v in pairs(self.msg_notice_list) do
        local cfg = config_msg_notice[k]
        if cfg and cfg.type==type then
            for _,cv in ipairs(v) do
                return false
            end
        end
    end
    return true
end

function MsgNoticeCtrl:HasAnyMsgNotice()
    for k,v in pairs(self.msg_notice_list) do
        for _,cv in ipairs(v) do
            return true
        end
    end
    return false
end

function MsgNoticeCtrl:SetReadFlag(id, time, no_event)
    local list = self.msg_notice_list[id]
    for _,v in ipairs(list or _et) do
        local time_stamp = tonumber(v[2])
        if time_stamp == time then
            local read_flag = tonumber(v[3])
            if read_flag == 1 then
                break
            end

            v[3] = 1
            self:SaveMsgNotie(id)

            if not no_event then
                self:FireEvent(game.MsgNoticeEvent.UpdateMsgNotice)
            end
            break
        end
    end
end

function MsgNoticeCtrl:ClearMsgNoticeByIdTime(id, time)
    local list = self.msg_notice_list[id]
    for k,v in ipairs(list or _et) do
        local time_stamp = tonumber(v[2])
        if time_stamp == time then
            table.remove(list, k)
            break
        end
    end

    self:SaveMsgNotie(id)

    self:FireEvent(game.MsgNoticeEvent.UpdateMsgNotice)
end

function MsgNoticeCtrl:ClearMsgNoticeById(id, no_event)
    self.msg_notice_list[id] = {}

    self:SaveMsgNotie(id)

    if not no_event then
        self:FireEvent(game.MsgNoticeEvent.UpdateMsgNotice)
    end
end

function MsgNoticeCtrl:ClearMsgNoticeByType(type)
    local list = self:GetMsgNoticeByType(type)
    for _,v in ipairs(list or _et) do
        self:ClearMsgNoticeById(tonumber(v[1]), true)
    end

    self:FireEvent(game.MsgNoticeEvent.UpdateMsgNotice)
end

function MsgNoticeCtrl:ClearAllMsgNotice()
    for k,v in pairs(config_msg_notice) do
        self:ClearMsgNoticeById(k, true)
    end

    self:FireEvent(game.MsgNoticeEvent.UpdateMsgNotice)
end

function MsgNoticeCtrl:ReadAllMsgNotice()
    for k,v in pairs(self.msg_notice_list) do
        for _,cv in ipairs(v) do
            local id = tonumber(cv[1])
            local time = tonumber(cv[2])

            self:SetReadFlag(id, time, true)
        end
    end

    self:FireEvent(game.MsgNoticeEvent.UpdateMsgNotice)
end

function MsgNoticeCtrl:ReadAllTypeMsgNotice(type)
    for k,v in pairs(self.msg_notice_list) do
        local cfg = config_msg_notice[k]
        if cfg and cfg.type==type then
            for _,cv in ipairs(v) do
                local id = tonumber(cv[1])
                local time = tonumber(cv[2])

                self:SetReadFlag(id, time, true)
            end
        end
    end

    self:FireEvent(game.MsgNoticeEvent.UpdateMsgNotice)
end

function MsgNoticeCtrl:GetMsgNoticeNum()
    local count = 0
    for k,v in pairs(self.msg_notice_list) do
        count = count + #v
    end
    return count
end

function MsgNoticeCtrl:GetMsgNoticeNumByType(type)
    local count = 0
    for k,v in pairs(self.msg_notice_list) do
        local cfg = config_msg_notice[k]
        if cfg and cfg.type==type then
            count = count + #v
        end
    end
    return count
end

function MsgNoticeCtrl:GetMsgNoticeUnReadNum()
    local count = 0
    for k,v in pairs(self.msg_notice_list) do
        for _,cv in ipairs(v) do
            local read_flag = tonumber(cv[3])
            if read_flag == 0 then
                count = count + 1
            end
        end
    end
    return count
end

function MsgNoticeCtrl:GetMsgNoticeUnReadNumByType(type)
    local count = 0
    for k,v in pairs(self.msg_notice_list) do
        local cfg = config_msg_notice[k]
        if cfg and cfg.type==type then
            for _,cv in ipairs(v) do
                local read_flag = tonumber(cv[3])
                if read_flag == 0 then
                    count = count + 1
                end
            end
        end
    end
    return count
end

game.MsgNoticeCtrl = MsgNoticeCtrl

return MsgNoticeCtrl
