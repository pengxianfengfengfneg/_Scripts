local ChatCtrl = Class(game.BaseCtrl)

local handler = handler
local global_time = global.Time
local event_mgr = global.EventMgr
local config_func = config.func

local string_gmatch = string.gmatch
local string_gsub = string.gsub
local string_format = string.format
local string_sub = string.sub
local string_find = string.find
local table_concat = table.concat
local tonumber = tonumber

function ChatCtrl:_init()
    if ChatCtrl.instance ~= nil then
        error("ChatCtrl Init Twice!")
    end
    ChatCtrl.instance = self

    self.data = require("game/chat/chat_data").New()

    self.chat_view = require("game/chat/chat_view").New(self)
    self.chat_at_view = require("game/chat/chat_at_view").New(self)
    self.friend_chat_view = require("game/chat/friend_chat_view").New(self)

    self.chat_setting_view = require("game/chat/chat_setting_view").New(self)

    self:Init()

    self:RegisterAllEvents() 
    self:RegisterAllProtocals()
end

function ChatCtrl:_delete()
    self.data:DeleteMe()

    self.chat_view:DeleteMe()
    self.chat_at_view:DeleteMe()
    self.friend_chat_view:DeleteMe()
    self.chat_setting_view:DeleteMe()
    
    ChatCtrl.instance = nil
end

function ChatCtrl:Init()
    require("game/chat/rumor_func_config")

end

function ChatCtrl:RegisterAllEvents()
    local events = {
        --{game.LoginEvent.LoginSuccess, handler(self, self.OnLoginSuccess)},
        {game.SceneEvent.UpdateEnterSceneInfo, handler(self, self.OnUpdateEnterSceneInfo)},
        {game.MsgEvent.AddChatMsg, handler(self, self.OnAddChatMsg)},
        {game.VoiceEvent.OnStartPlay, handler(self, self.OnStartPlay)},
        {game.VoiceEvent.OnStopPlay, handler(self, self.OnStopPlay)},
        {game.VoiceEvent.OnStartRecord, handler(self, self.OnStartRecord)},
        {game.VoiceEvent.OnStopRecord, handler(self, self.OnStopRecord)},
        {game.VoiceEvent.OnSpeechText, handler(self, self.OnSpeechText)},

    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function ChatCtrl:RegisterAllProtocals()
    self:RegisterProtocalCallback(40202, "OnChatInfo")
    self:RegisterProtocalCallback(40204, "OnChatPublic")
    self:RegisterProtocalCallback(40206, "OnChatPrivate")
    self:RegisterProtocalCallback(40207, "OnChatPublicNotify")
    self:RegisterProtocalCallback(40208, "OnChatPrivateNotify")
    self:RegisterProtocalCallback(40210, "OnChatHorn")
    self:RegisterProtocalCallback(40211, "OnChatHornNotify")
    self:RegisterProtocalCallback(40214, "OnChatCache")
    self:RegisterProtocalCallback(40216, "OnChatClearCache")    

    -- 传闻
    self:RegisterProtocalCallback(40101, "OnRumorNew")    
end

function ChatCtrl:OnLoginSuccess()
    --self:SendGetChatInfo()
    self:SendGetChatCache()
end

function ChatCtrl:OnUpdateEnterSceneInfo(data)
    self:SendGetChatCache()
end

function ChatCtrl:TranslateMaskWords(str)
    return game.Utils.TranslateMaskWords(str)
end

function ChatCtrl:SendGetChatInfo()
    local proto = {

    }
    self:SendProtocal(40201, proto)
end

function ChatCtrl:OnChatInfo(data)
    -- 聊天次数记录
    --[[
        "channels__T__id@C##times@I",
    ]]
    -- PrintTable(data)
end

function ChatCtrl:SendChatPublic(params)
    local proto = {
        channel = params.channel,
        target = params.target or 0,
        content = self:TranslateMaskWords(params.content),
        voice = params.voice or "",
        voice_time = params.voice_time or 0,
        extra = params.extra or "",
    }
    self:SendProtocal(40203, proto)
end

function ChatCtrl:OnChatPublic(data)
    --[[
        "channel__C",
        "target__L",
        "content__s",
        "voice__s",
        "voice_time__H",
        "extra__s",
    ]]
    --PrintTable(data)

    self.data:OnChatPublic(data)

    self:FireEvent(game.ChatEvent.OnChatPublic)

    self:FireBubbleChat(data)
end

function ChatCtrl:SendChatPrivate(params)
    local proto = {
        id = params.id,
        platform = params.platform or "",
        svr_num = params.svr_num,
        content = self:TranslateMaskWords(params.content),
        voice = params.voice or "",
        voice_time = params.voice_time or 0,
        extra = params.extra or "",
    }
    self:SendProtocal(40205, proto)
end

function ChatCtrl:OnChatPrivate(data)
    --[[
        "id__L",
        "content__s",
        "voice__s",
        "voice_time__H",
        "extra__s",
    ]]
    --PrintTable(data)

    self.data:OnChatPrivate(data)

    self:FireEvent(game.ChatEvent.UpdatePrivateChat, data)
end

function ChatCtrl:OnChatPublicNotify(data)
    --[[
        "channel__C",
        "target__L",
        "sender__U|CltChatRole|",
        "time__I",
        "content__s",
        "voice__s",
        "voice_time__H",
        "extra__s",
    ]]
    --PrintTable(data)

    self.data:OnChatPublicNotify(data)

    self:FireBubbleChat(data)
end

function ChatCtrl:OnChatPrivateNotify(data)
    --[[
        "sender__U|CltChatRole|",
        "time__I",
        "content__s",
        "voice__s",
        "voice_time__H",
        "extra__s",
    ]]
    --PrintTable(data)

    self.data:OnChatPrivateNotify(data)

    self:FireEvent(game.ChatEvent.UpdatePrivateChat, data)
end

function ChatCtrl:SendChatHorn(content, extra, type)
    local proto = {
        content = content,
        extra = extra,
        type = type,
    }
    self:SendProtocal(40209, proto)
end

function ChatCtrl:OnChatHorn(data)
    --[[
        "content__s",
        "extra__s",
        "type__C",
    ]]
    --PrintTable(data)

    local vo = game.Scene.instance:GetMainRoleVo()
    data.sender = vo

    self.data:OnChatHorn(data)

    self:FireEvent(game.ChatEvent.NoticeHorn, data)
end

function ChatCtrl:OnChatHornNotify(data)
    --[[
        "sender__U|CltChatRole|",
        "time__I",
        "content__s",
        "extra__s",
    ]]
    --PrintTable(data)

    self.data:OnChatHornNotify(data)

    self:FireEvent(game.ChatEvent.NoticeHorn, data)
end

-- 群聊
function ChatCtrl:SendChatGroup(params)
    -- local proto = {
    --     id = params.id,
    --     platform = params.platform or "",
    --     svr_num = params.svr_num,
    --     content = self:TranslateMaskWords(params.content),
    --     voice = params.voice or "",
    --     voice_time = params.voice_time or 0,
    --     extra = params.extra or "",
    -- }
    -- PrintTable(proto)
    -- self:SendProtocal(40205, proto)

    self:SendChatPublic(params)
end

function ChatCtrl:SendGetChatCache()
    if self.is_send_get_cache then
        return
    end
    self.is_send_get_cache = true

    local proto = {
       
    }
    self:SendProtocal(40213, proto)
end

function ChatCtrl:OnChatCache(data)
    --[[
        "offline_time__I",
        "pub__T__cache@U|CltChatPublicCache|",
        "pri__T__cache@U|CltChatPrivateCache|",
    ]]
    --PrintTable(data)
    self.data:OnChatCache(data)
end

function ChatCtrl:SendChatClearCache(id)
    local proto = {
        id = id,
    }
    self:SendProtocal(40215, proto)
end

function ChatCtrl:OnChatClearCache(data)
    --[[
        "id__L",
    ]]
    --PrintTable(data)

    self:OnChatClearCache(data)
end

local RumorArgs = {}
function ChatCtrl:OnRumorNew(data)
    --[[
        "temp__I",
        "args__T__arg@s",
    ]]
    --PrintTable(data)

    local rumor_cfg = config.rumor[data.temp]
    if not rumor_cfg then
        return
    end

    local args = RumorArgs
    for k,v in ipairs(data.args) do
        args[k] = v.arg
        args[k+1] = nil
    end

    local count = 0
    for word in string_gmatch(rumor_cfg.rumor, "%%s") do
        count = count + 1
    end

    if #args < count then
        return
    end

    data.rolling = rumor_cfg.rolling
    data.show_tips = rumor_cfg.show_tips
    data.priority = rumor_cfg.priority
    data.channel = rumor_cfg.channel
    data.main_panel = rumor_cfg.main_panel
    data.content = self:ParseRumor(rumor_cfg.rumor, args)

    if rumor_cfg.show_tips == 1 then
        game.GameMsgCtrl.instance:PushMsg(data.content)
    end

    self.data:OnRumorNew(data)

    self:FireEvent(game.ChatEvent.UpdateRumor, data)
end

local DoneCircleHelpFuncId = 1015
local HasDoneCircleHelp = {}
function ChatCtrl:IsDoneCircleHelp(flag)
    return HasDoneCircleHelp[flag]
end

function ChatCtrl:ParseRumor(rumor, args)
    local args = args or {}
    local content = string_gsub(rumor, "%[%d+%]", function(arg)
        local func_id = tonumber(string_sub(arg, string_find(arg,"%d+")))

        if func_id == DoneCircleHelpFuncId then
            HasDoneCircleHelp[args[#args]] = true
        end

        local func_cfg = config.rumor_func[func_id] or {}
        if func_cfg.click_word == "" then
            return func_cfg.click_word
        end

        if args == nil then
            return
        end
        local herf_params = string_format("%s|%s", func_id, table_concat(args,"|"))
        local str = string_format("<font color='#%s'><a href='%s'>%s</a></font>", func_cfg.color, herf_params, func_cfg.click_word)
        return str
    end)

    return string_format(content, table.unpack(args))
end

function ChatCtrl:OpenView(open_channel)
    self.chat_view:Open(open_channel)
end

function ChatCtrl:CloseView()
    self.chat_view:Close()
end

function ChatCtrl:OpenChatAtView(channel, group_id)
    self.chat_at_view:Open(channel, group_id)
end

function ChatCtrl:CloseChatAtView()
    self.chat_at_view:Close()
end

function ChatCtrl:OpenFriendChatView(chat_info)
    self.friend_chat_view:Open(chat_info)
end

function ChatCtrl:CloseFriendChatView()
    self.friend_chat_view:Close()
end

function ChatCtrl:OpenChatSettingView(idx)
    self.chat_setting_view:Open(idx)
end

function ChatCtrl:GetChatData(chat_channel, fliter_func)
    return self.data:GetChatData(chat_channel, fliter_func)
end

function ChatCtrl:OnAddChatMsg(msg_list)
    for _,v in ipairs(msg_list or {}) do
        if v.is_chat then
            local data = {
                channel = game.ChatChannel.Sys,
                content = v.desc or "",
                chat_body_type = game.ChatBodyType.Sys,
                sender = {
                    gender = game.Gender.Male,
                    name = "",
                },
            }
            self:OnChatPublicNotify(data)
        end
    end
end

function ChatCtrl:OnStartPlay()
    global.AudioMgr:SetSoundVolume(0)
    global.AudioMgr:SetMusicVolume(0)
end

function ChatCtrl:OnStopPlay()
    global.AudioMgr:SetSoundVolume(1)
    global.AudioMgr:SetMusicVolume(1)
end

function ChatCtrl:OnStartRecord()
    global.AudioMgr:SetSoundVolume(0)
    global.AudioMgr:SetMusicVolume(0)
end

function ChatCtrl:OnStopRecord()
    global.AudioMgr:SetSoundVolume(1)
    global.AudioMgr:SetMusicVolume(1)
end

function ChatCtrl:OnSpeechText(share_id, voice_time, result, chat_channel, chat_role_id, group_id)  
    if result == "" then
        game.GameMsgCtrl.instance:PushMsg(config.words[1322])
        return
    end

    local send_data = {
        channel = chat_channel,
        content = result or "",
        voice = share_id,
        voice_time = math.floor(voice_time * 1000),
        extra = ""
    }

    if chat_role_id and chat_channel==game.ChatChannel.Private then
        -- 私聊语音
        send_data.id = chat_role_id
        self:SendChatPrivate(send_data)
        return
    end

    if group_id and chat_channel==game.ChatChannel.Group then
        -- 群聊语音
        send_data.group = group_id
        self:SendChatGroup(send_data)
        return
    end

    self:SendChatPublic(send_data)
end

function ChatCtrl:ShareItem(info, channel)
    local str = serialize(info)
    local extra =  string_format("extra_item|%s|%s", info.id, str)
    local params = {
        channel = channel or game.ChatChannel.World,
        content = "#i#",
        extra = extra,
    }
    self:SendChatPublic(params)
end

function ChatCtrl:GetChatPrivateData(role_id)
    return self.data:GetChatPrivateData(role_id)
end

function ChatCtrl:GetChatGroupData(group_id)
    return self.data:GetChatGroupData(group_id)
end

local BubbleTime = 5
local BubbleChatConfig = {
    [game.ChatChannel.Team] = 1,
    [game.ChatChannel.Nearby] = 1,
}
function ChatCtrl:FireBubbleChat(data)
    local channel = data.channel
    if not BubbleChatConfig[channel] then
        return
    end

    local obj = game.Scene.instance:GetObjByUniqID(data.sender.id)
    if not obj then
        return
    end

    obj:SetSpeakBubble(data.content, BubbleTime, data.sender.bubble)
end

function ChatCtrl:GetChatCacheData()
    return self.data:GetChatCacheData()
end

function ChatCtrl:GetChatAtData()
    return self.data:GetChatAtData()
end

game.ChatCtrl = ChatCtrl

return ChatCtrl
