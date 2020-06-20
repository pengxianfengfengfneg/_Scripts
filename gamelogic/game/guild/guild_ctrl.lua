local GuildCtrl = Class(game.BaseCtrl)

local view_map = {
    guild_create_view = "game/guild/guild_create_view",
    guild_rename_view = "game/guild/guild_rename_view",
    guild_change_announce_view = "game/guild/guild_change_announce_view",

    guild_logs_view = "game/guild/guild_logs_view",
    guild_recruit_view = "game/guild/guild_recruit_view",
    guild_member_operate_view = "game/guild/guild_member_operate_view",
    guild_appoint_pos_view = "game/guild/guild_appoint_pos_view",
    guild_app_view = "game/guild/guild_app_view",

    guild_tips_view = "game/guild/guild_tips_view",
    guild_seat_view = "game/guild/guild_seat_view",
    guild_answer_view = "game/guild/guild_answer_view",

    guild_upgrade_view = "game/guild/guild_upgrade_view",
    guild_maintain_view = "game/guild/guild_maintain_view",
    guild_seven_live_view = "game/guild/guild_seven_live_view",
    guild_war_view = "game/guild/guild_war_view",
    guild_battleinfo_view = "game/guild/guild_battleinfo_view",
    guild_banquet_view = "game/guild/guild_banquet_view",
    guild_bonus_view = "game/guild/guild_bonus_view",
    guild_defend_side_info_view = "game/guild/guild_defend_side_info_view",
    guild_defend_reward_view = "game/guild/guild_defend_reward_view",
    guild_defend_chose_view = "game/guild/guild_defend_chose_view",

    guild_wine_side_info_view = "game/guild/guild_wine_side_info_view",
    guild_wine_comment_view = "game/guild/guild_wine_comment_view",
    guild_wine_cast_dice_view = "game/guild/guild_wine_cast_dice_view",
    guild_wine_answer_view = "game/guild/guild_wine_answer_view",

    field_battle_against_info_view = "game/guild/field_battle_against_info_view",
    field_battle_pk_view = "game/guild/field_battle_pk_view",

    guild_yunbiao_view = "game/guild/guild_yunbiao_view",
    guild_yunbiao_start_view = "game/guild/guild_yunbiao_start_view",
    guild_yunbiao_result_view = "game/guild/guild_yunbiao_result",
    guild_yunbiao_reward_view = "game/guild/guild_yunbiao_reward_view",

    guild_new_view = "game/guild/guild_new_view",
    guild_info_view = "game/guild/guild_info_view",
    guild_lobby_view = "game/guild/guild_lobby_view",
    guild_event_view = "game/guild/guild_event_view",
    guild_wage_view = "game/guild/guild_wage_view",
    guild_research_view = "game/guild/guild_research_view",
    guild_bless_view = "game/guild/guild_bless_view",
}

function GuildCtrl:PrintTable(tbl)
    if self.log_enable then
        PrintTable(tbl)
    end
end

function GuildCtrl:print(...)
    if self.log_enable then
        print(...)
    end
end

function GuildCtrl:_init()
    if GuildCtrl.instance ~= nil then
        error("GuildCtrl Init Twice!")
    end
    GuildCtrl.instance = self

    for view_name, class in pairs(view_map) do
        self[view_name] = require(class).New(self)
        self:CreateViewFunc(view_name)
    end
   
    self.data = require("game/guild/guild_data").New(self)

    self:RegisterAllProtocal()
    self:RegisterAllEvents()
end

function GuildCtrl:_delete()
    for view_name, class in pairs(view_map) do
        self[view_name]:DeleteMe()
        self[view_name] = nil
    end

    self:CloseInviteTipsView()

    self.data:DeleteMe()
    GuildCtrl.instance = nil
end

function GuildCtrl:CreateViewFunc(view_name)
    local func_view_name = ""
    local name_ary = string.split(view_name, '_')
    for i, v in ipairs(name_ary) do
        func_view_name = func_view_name .. string.upper(string.sub(v, 1, 1)) .. string.sub(v, 2)
    end

    local open_func = "Open" .. func_view_name
    local close_func = "Close" .. func_view_name
    self[open_func] = function(self, ...)
        if not self[view_name]:IsOpen() then
            self[view_name]:Open(...)
        end
        return self[view_name]
    end
    self[close_func] = function(self, ...)
        if self[view_name] then
            self[view_name]:Close()
        end
    end
end

function GuildCtrl:RegisterAllProtocal()
    local proto = {
        [41402] = "OnGuildInfo",
        [41404] = "OnGuildList",
        [41406] = "OnGuildGetDetail",
        [41408] = "OnGuildGetMembers",
        [41410] = "OnGuildGetJoinReq",
        [41412] = "OnGuildCreate",
        [41414] = "OnGuildJoinReq",
        [41416] = "OnGuildCancelReq",
        [41417] = "OnGuildNotifyJoinReq",
        [41418] = "OnGuildNotifyCancelReq",
        [41420] = "OnGuildHandleReq",
        [41422] = "OnInviteJoinGuild",
        [41423] = "OnGuildApproveResult",

        [41424] = "OnNewGuildInvite",
        [41426] = "OnGuildLeave",
        [41427] = "OnGuildNotifyJoin",
        [41428] = "OnGuildNotifyLeave",
        [41430] = "OnGuildKickMember",
        [41431] = "OnGuildNotifyKick",
        [41434] = "OnGuildRename",
        [41436] = "OnGuildAppointPos",
        [41437] = "OnGuildNotifyRename",
        [41438] = "OnGuildNotifyPos",

        [41440] = "OnGuildChangeAnnounce",
        [41442] = "OnGuildChangeAcceptType",
        [41443] = "OnGuildNotifyAnnounce",
        [41444] = "OnGuildNotifyLevelUp",
        [41445] = "OnGuildNotifyOnline",
        [41448] = "OnGuildRecruit",
        [41450] = "OnGuildLogs",
        [41452] = "OnGuildSkillList",
        [41454] = "OnGuildUpSkill",
        [41456] = "OnGuildLiveInfo",
        [41458] = "OnGuildGetLiveReward",
        [41460] = "OnGuildLiveUpgrade",
        [41461] = "OnGuildLiveNotify",

        [41464] = "OnGuildCookInfo",
        [41466] = "OnGuildCook",
        [41468] = "OnGuildGetCookReward",
        [41472] = "OnGuildEnterSeat",
        [41474] = "OnGuildLeaveSeat",
        [41476] = "OnGuildExInfo",
        [41478] = "OnGuildExchange",
        [41480] = "OnGuildExRefresh",
        [41482] = "OnGuildCostDenf",
        [41484] = "OnGuildPracticeInfo",
        [41486] = "OnGuildPracticeUp",
        [41488] = "OnGuildBanquet",
        [20506] = "OnLevelUpPracticeMaxLv",

        [41490] = "OnGuildMetallInfo",
        [41492] = "OnGuildMetallTask",
        [41494] = "OnGuildBuildUp",
        [41496] = "OnGuildStudyUp",

        [50102] = "OnQuestionInfo",
        [50104] = "OnQuestionAnswer",
        [50502] = "OnGuildDailyTaskInfo",
        [50503] = "OnGuildDailyTaskChange",

        [51102] = "OnGuildDefendEnter",
        [51104] = "OnGuildDefendLeave",
        [51111] = "OnGuildDefendPublish",
        [51112] = "OnGuildDefendRefresh",
        [51113] = "OnGuildDefendTripodHurt",
        [51115] = "OnGuildDefendPanel",
        [51117] = "OnGuildDefendScore",
        [51118] = "OnGuildDefendMonNum",
        [51119] = "OnGuildDefendCurNum",
        [51120] = "OnGuildDefendClose",

        [51802] = "OnGuildWineActInfo",
        [51803] = "OnGuildWineActUpdateExp",
        [51804] = "OnGuildWineActUpdateNumber",
        [51805] = "OnGuildWineActUpdateNextSubject",
        [51807] = "OnGuildWineActDice",
        [51809] = "OnGuildWineActCommentInfo",
        [51811] = "OnGuildWineActUpdateRole",

        [52002] = "OnGuildBeginPractice",

        [52102] = "OnCarryInfoResp",
        [52104] = "OnNotifyCarry",
        [52109] = "OnNotifyCarryPos",

        [53402] = "OnGuildWagesInfo",
        [53502] = "OnGuildDeclare",
        [53504] = "OnGuildHostile",
        [53506] = "OnGuildDeclareList",
        [53508] = "OnGuildHostileList",

        [53511] = "OnGuildBlessInfo",
        [53513] = "OnGuildBless",

        [53518] = "OnGuildTeamCarbonInfo",
        [53520] = "OnGuildHostileCancel",
    }
   for k, v in pairs(proto) do
        self:RegisterProtocalCallback(k, v)
   end
end

function GuildCtrl:RegisterAllEvents()
    local events = {
        [game.LoginEvent.LoginSuccess] = function()
            self:SendGuildInfo()
            self:SendCarryInfoReq()
            self:SendGuildPracticeInfo()
            self:SendGuildMetallInfo()
        end,
        [game.MoneyEvent.Change] = function(change_list)
            if change_list[game.MoneyType.GuildCont] then
                self.data:ChangeGuildContribute(change_list[game.MoneyType.GuildCont])
            end
        end,
        [game.SceneEvent.MainRoleFightStateChange] = function(fight_state)
            self:OnHostileListChange(self:GetHostileIDList())
        end,
    }
    for k, v in pairs(events) do   
        self:BindEvent(k, v)
    end
end

function GuildCtrl:OpenView(index, ...)
    if self:IsGuildMember() then
        local args = table.pack(...)
        if not self:GetView("guild_new_view"):IsOpen() then
            self:OpenGuildNewView(index, args)
        else
            self:GetView("guild_new_view"):RefreshView(index, args)
        end
    else
        if index then
            game.GameMsgCtrl.instance:PushMsg(config.words[4772])
        else
            self:OpenGuildLobbyView()
        end
    end
end

function GuildCtrl:GetView(view_name)
    if self[view_name] then
        return self[view_name]
    end
end

function GuildCtrl:IsOpen(view_name)
    if self[view_name] then
        return self[view_name]:IsOpen()
    end
end

function GuildCtrl:CloseView(view_name)
    if view_name then
        return self[view_name]:Close()
    else
        local fliter = function(view)
            return view:GetViewLevel() > game.UIViewLevel.Standalone
        end
        self:CloseAllView(fliter)
    end
end

function GuildCtrl:CloseAllView(fliter)
    for view_name, class in pairs(view_map) do
        local view = self[view_name]
        if not fliter or fliter(view) then
            self:CloseView(view_name)
        end
    end
end

function GuildCtrl:OpenInviteTipsView(data)
    if not self.invite_tips_view then
        local title = config.words[4799]
        local content = string.format(config.words[4798], data.role_name, data.guild_name)
        self.invite_tips_view = game.GameMsgCtrl.instance:CreateMsgBox(title, content, 10)
        self.invite_tips_view:SetOkBtn(function()
            self:SendGuildJoinReq(data.guild_id)
            self:CloseInviteTipsView()
        end, config.words[5010])
        self.invite_tips_view:SetCancelBtn(function()
            self:CloseInviteTipsView()
        end, config.words[5011], true)
        self.invite_tips_view:Open()
    end
end

function GuildCtrl:CloseInviteTipsView()
    if self.invite_tips_view then
        self.invite_tips_view:DeleteMe()
        self.invite_tips_view = nil
    end
end

function GuildCtrl:OnGuildInfo(data)
    -- guild__U|CltGuild|
    self:PrintTable(data)
    self.data:SetGuildInfo(data.guild)
end

function GuildCtrl:OnGuildList(data)
    -- list__T__guild@U|CltGuildBrief|
    self:PrintTable(data)
    self.data:SetGuildList(data.list)
end

function GuildCtrl:OnGuildGetDetail(data)
    -- guild__U|CltGuild|
    self:PrintTable(data)
    self:FireEvent(game.GuildEvent.OnGuildGetDetail, data.guild)
end

function GuildCtrl:OnGuildGetMembers(data)
    -- members__T__mem@U|CltGuildMember|
    self:PrintTable(data)
    self.data:SetGuildMembers(data.members)
end

function GuildCtrl:OnGuildGetJoinReq(data)
    -- list__T__request@U|CltGuildRequest|
    self:PrintTable(data)
    self.data:SetGuildApplyInfo(data.list)
end

function GuildCtrl:OnGuildCreate(data)
    -- id__L                               // 帮会ID
    self:PrintTable(data)
    self:FireEvent(game.GuildEvent.CreateGuild)
end

function GuildCtrl:OnGuildJoinReq(data)
    -- id__L                               // 帮会ID
    self:PrintTable(data)
    if data.id == 0 then
        game.GameMsgCtrl.instance:PushMsg(config.words[2366])
    end
end

function GuildCtrl:OnGuildCancelReq(data)
    -- id__L                               // 帮会ID
    self:PrintTable(data)
end

function GuildCtrl:OnGuildNotifyJoinReq(data)
    -- id__L                               // 玩家ID
    -- name__s                             // 玩家名
    -- level__C                            // 玩家等级
    -- fight__I                            // 玩家战力
    self:PrintTable(data)
    self.data:AddMemberApply(data)
end

function GuildCtrl:OnGuildNotifyCancelReq(data)
    -- list__T__id@L                       // 玩家ID
    self:PrintTable(data)
    self.data:RemoveMemberApply(data.list)
end

function GuildCtrl:OnGuildHandleReq(data)
    -- approve__C
    -- list__T__id@L                       // 玩家ID
    self:PrintTable(data)
    self:FireEvent(game.GuildEvent.GuildHandleReq, data)
end

function GuildCtrl:OnInviteJoinGuild(data)
    -- role_id__L                          // 对方ID
    self:PrintTable(data)
end

function GuildCtrl:OnGuildApproveResult(data)
    -- id__L                               // 帮会ID
    -- name__s                             // 帮会名
    -- approve__C
    self:PrintTable(data)
    if data.approve == 0 then
        self.data:SetGuildApply(data.id, 0)
    elseif data.approve == 1 then
        self:SendGuildInfo()
    end
    self:FireEvent(game.GuildEvent.ApproveResult, data.id, data.approve)
end

function GuildCtrl:OnNewGuildInvite(data)
    -- role_id__L                          // 对方ID
    -- role_name__s                        // 对方名字
    -- guild_id__L                         // 帮会ID
    -- guild_name__s                       // 帮会名
    self:PrintTable(data)
    self:OpenInviteTipsView(data)
end

function GuildCtrl:OnGuildLeave(data)
    self:PrintTable(data)
    self.data:MemberLeave(game.Scene.instance:GetMainRoleID())
end

function GuildCtrl:OnGuildNotifyJoin(data)
    -- list__T__mem@U|CltGuildMember|
    self:PrintTable(data)
    self.data:MemberJoin(data.list)
end

function GuildCtrl:OnGuildNotifyLeave(data)
    -- id__L                               // 玩家ID
    self:PrintTable(data)
    self.data:MemberLeave(data.id)
end

function GuildCtrl:OnGuildKickMember(data)
    -- id__L                               // 玩家ID
    self:PrintTable(data)
    self:FireEvent(game.GuildEvent.KickMember, data.id)
end

function GuildCtrl:OnGuildNotifyKick(data)
    -- id__L                               // 帮会ID
    self:PrintTable(data)
    self.data:MemberLeave(game.Scene.instance:GetMainRoleID())
end

function GuildCtrl:OnGuildRename(data)
    -- name__s                             // 帮会名
    self:PrintTable(data)
    self:FireEvent(game.GuildEvent.RenameSuccess, data.name)
end

function GuildCtrl:OnGuildAppointPos(data)
    self:PrintTable(data)
    self:FireEvent(game.GuildEvent.AppointPos)
end

function GuildCtrl:OnGuildNotifyRename(data)
    -- guild_id__L                         // 帮会ID
    -- guild_name__s                       // 帮会名
    self:PrintTable(data)
    self.data:GuildRename(data.guild_id, data.guild_name)
end

-- 职位变化通知
function GuildCtrl:OnGuildNotifyPos(data)
    -- change__T__id@L##pos@C
    self:PrintTable(data)
    self.data:ChangePos(data.change)
end

function GuildCtrl:OnGuildChangeAnnounce(data)
    self:PrintTable(data)
    self:FireEvent(game.GuildEvent.ChangeAnnounce)
end

function GuildCtrl:OnGuildChangeAcceptType(data)
    -- type__C                             // 类型
    -- auto__C                             // 类型
    self:PrintTable(data)
    self.data:SetAcceptType(data.type, data.auto)
end

function GuildCtrl:OnGuildNotifyAnnounce(data)
    -- announce__s                         // 公告
    self:PrintTable(data)
    self.data:ChangeAnnounce(data.announce)
end

function GuildCtrl:OnGuildNotifyLevelUp(data)
    -- level__C
    -- funds__I
    self:PrintTable(data)
    self.data:SetGuildLevel(data.level)
    self.data:SetGuildFunds(data.funds)
end

-- 成员在线情况通知
function GuildCtrl:OnGuildNotifyOnline(data)
    -- role_id__L                          // 成员ID
    -- time__I                             // 大于0表示下线时间；0表示上线
    self:PrintTable(data)
    self.data:SetMemberOffline(data.role_id, data.time)
end

function GuildCtrl:OnGuildRecruit(data)
    self:PrintTable(data)
    self.data:OnGuildRecruit(data.recruit_time)
end

function GuildCtrl:OnGuildLogs(data)
    -- logs__T__log@s
    self:PrintTable(data)
    self.data:SetGuildLogs(data.logs)
end

function GuildCtrl:OnGuildSkillList(data)
    -- skills__T__id@I##lv@C
    self:PrintTable(data)
    self.data:SetGuildSkillList(data.skills)
end

function GuildCtrl:OnGuildUpSkill(data)
    -- skill__I
    -- level__C
    self:PrintTable(data)
    self.data:SetGuildSkill(data.skill, data.level)
end

function GuildCtrl:OnGuildLiveInfo(data)
    self:PrintTable(data)
    self.data:SetGuildLiveInfo(data)
end

function GuildCtrl:OnGuildGetLiveReward(data)
    -- id__C                               // ID
    self:PrintTable(data)
    self.data:SetGuildLiveReward(data.id)
end

function GuildCtrl:OnGuildLiveUpgrade(data)
    -- level__C                            // 活跃等级
    -- exp__H                              // 活跃进度
    self:PrintTable(data)
    self.data:SetGuildLiveInfo(data)
end

-- 活跃进度通知
function GuildCtrl:OnGuildLiveNotify(data)
    self:PrintTable(data)
    self.data:SetGuildLiveInfo(data)
end

function GuildCtrl:OnGuildCookInfo(data)
    self:PrintTable(data)
    self:FireEvent(game.GuildEvent.UpdateGuildCookInfo, data)
end

function GuildCtrl:OnGuildCook(data)
    -- type__C                             // 烹饪方式
    self:PrintTable(data)
    self:FireEvent(game.GuildEvent.GuildCook, data.type)
end

function GuildCtrl:OnGuildGetCookReward(data)
    -- id__C                               // ID
    self:PrintTable(data)
    self:FireEvent(game.GuildEvent.GetCookReward, data.id)
end

function GuildCtrl:OnGuildEnterSeat(data)
    self:PrintTable(data)
    self:CloseAllView()
end

function GuildCtrl:OnGuildLeaveSeat(data)
    self:PrintTable(data)
end

function GuildCtrl:OnGuildExInfo(data)
    self:PrintTable(data)
    self.data:SetGuildExchangeInfo(data)
end

function GuildCtrl:OnGuildExchange(data)
    -- id__H
    self:PrintTable(data)
    self:FireEvent(game.GuildEvent.GuildExchange, data.id)
end

function GuildCtrl:OnGuildExRefresh(data)
    self:PrintTable(data)
    self:SendGuildExInfo()
end

function GuildCtrl:OnGuildDailyTaskInfo(data)
    -- task_data__T__id@C##round@C##state@C##reset_times@C##x@I##y@I -- id:1采集|2杀怪 round:轮数 state:1:开始 2:全部结束
    self:PrintTable(data)
    self.data:SetDailyTaskInfo(data)
end

function GuildCtrl:OnGuildDailyTaskChange(data)
    -- task_data__T__id@C##round@C##state@C##reset_times@C##x@I##y@I
    self:PrintTable(data)
    self.data:DailyTaskChange(data)
end

-- 扣除维护资金
function GuildCtrl:OnGuildCostDenf(data)
    -- funds__I
    self:PrintTable(data)
    self.data:SetGuildFunds(data.funds)
end

-- 获取玩家帮会信息
function GuildCtrl:SendGuildInfo()
    self:SendProtocal(41401)
end

-- 获取帮会列表
function GuildCtrl:SendGuildList()
    self:SendProtocal(41403)
end

-- 查看某个帮会
function GuildCtrl:SendGuildGetDetail(id)
    -- id__L                        // 帮会ID
    self:SendProtocal(41405, { id = id })
end

-- 获取帮会成员
function GuildCtrl:SendGuildGetMembers()
    self:SendProtocal(41407)
end

-- 获取申请列表
function GuildCtrl:SendGuildGetJoinReq()
    self:SendProtocal(41409)
end

-- 创建帮会
function GuildCtrl:SendGuildCreate(type, name, announce)
    -- type__C                             // 创建方式
    -- name__s                             // 帮会名
    self:SendProtocal(41411, { type = type, name = name, announce = announce })
end

-- 申请加入
function GuildCtrl:SendGuildJoinReq(id)
    -- id__L                               // 帮会ID
    self:SendProtocal(41413, { id = id })
end

-- 取消申请
function GuildCtrl:SendGuildCancelReq(id)
    -- id__L                               // 帮会ID
    self:SendProtocal(41415, { id = id })
end

-- 申请处理
function GuildCtrl:SendGuildHandleReq(approve, id)
    -- approve__C                          // 同意 or 拒绝
    -- id__L                               // 玩家ID
    self:SendProtocal(41419, { approve = approve, id = id })
end

-- 邀请加入帮会
function GuildCtrl:SendInviteJoinGuild(role_id)
    -- role_id__L                          // 对方ID
    self:SendProtocal(41421, { role_id = role_id })
end

-- 离开帮会
function GuildCtrl:SendGuildLeave()
    self:SendProtocal(41425)
end

-- 踢人
function GuildCtrl:SendGuildKickMember(id)
    -- id__L                               // 玩家ID
    self:SendProtocal(41429, { id = id })
end

-- 帮会改名
function GuildCtrl:SendGuildRename(name)
    -- name__s                             // 帮会名
    self:SendProtocal(41433, { name = name })
end

-- 任命职位
function GuildCtrl:SendGuildAppointPos(role_id, pos)
    -- role_id__L
    -- pos__C
    self:SendProtocal(41435, { role_id = role_id, pos = pos })
end

-- 更改公告
function GuildCtrl:SendGuildChangeAnnounce(announce)
    -- announce__s                         // 公告
    self:SendProtocal(41439, { announce = announce })
end

-- 修改招人条件
function GuildCtrl:SendGuildChangeAcceptType(type, auto)
    -- type__C                             // 类型
    -- auto__C                             // 类型
    self:SendProtocal(41441, { type = type, auto = auto })
end

-- 喊话招募
function GuildCtrl:SendGuildRecruit()
    self:SendProtocal(41447)
end

-- 获取帮会记录
function GuildCtrl:SendGuildLogs()
    self:SendProtocal(41449)
end

-- 获取技能列表
function GuildCtrl:SendGuildSkillList()
    self:SendProtocal(41451)
end

-- 升级技能
function GuildCtrl:SendGuildUpSkill()
    self:SendProtocal(41453)
end

-- 获取活跃信息
function GuildCtrl:SendGuildLiveInfo()
    self:SendProtocal(41455)
end

-- 领取日常活跃奖励
function GuildCtrl:SendGuildGetLiveReward(id)
    self:SendProtocal(41457, { id = id })
end

-- 升级活跃等级
function GuildCtrl:SendGuildLiveUpgrade()
    self:SendProtocal(41459)
end

-- 获取烹饪信息
function GuildCtrl:SendGuildCookInfo()
    self:SendProtocal(41463)
end

-- 烹饪
function GuildCtrl:SendGuildCook(type)
    -- type__C                             // 烹饪方式
    self:SendProtocal(41465, { type = type })
end

-- 领取烹饪奖励
function GuildCtrl:SendGuildGetCookReward(id)
    -- id__C                               // ID
    self:SendProtocal(41467, { id = id })
end

-- 进入帮会驻地
function GuildCtrl:SendGuildEnterSeat()
    self:SendProtocal(41471)
end

-- 离开帮会驻地
function GuildCtrl:SendGuildLeaveSeat()
    self:SendProtocal(41473)
end

-- 获取兑换信息
function GuildCtrl:SendGuildExInfo()
    self:SendProtocal(41475)
end

-- 兑换物品
function GuildCtrl:SendGuildExchange(id)
    -- id__H
    self:SendProtocal(41477, { id = id })
end

-- 手动刷新
function GuildCtrl:SendGuildExRefresh()
    self:SendProtocal(41479)
end

function GuildCtrl:SendQuestionInfo()
    self:SendProtocal(50101)
end

-- 答题
function GuildCtrl:SendQuestionAnswer(answer)
	-- answer__C // 1到4对应A到D
    self:SendProtocal(50103, { answer = answer })
end

-- 打开答题面板
function GuildCtrl:SendQuestionOpen()
    self:SendProtocal(50105)
end

-- 关闭答题面板
function GuildCtrl:SendQuestionClose()
    self:SendProtocal(50106)
end

function GuildCtrl:SendGuildDailyTaskInfo()
    self:SendProtocal(50501)
end

-- 重置(返回50503)
function GuildCtrl:SendGuildDailyTaskReset(id)
    -- id__C
    self:SendProtocal(50504, {id = id})
end

-- 一键完成(返回50503)
function GuildCtrl:SendGuildDailyTaskOneKey(id)
    -- id__C
    self:SendProtocal(50505, {id = id})
end

-- 帮会升级
function GuildCtrl:SendGuildUpgrade()
    self:SendProtocal(41481)
end

-- 获取帮会修炼技能信息
function GuildCtrl:SendGuildPracticeInfo()
    self:SendProtocal(41483)
end

-- 帮会修炼技能升级
function GuildCtrl:SendGuildPracticeUp(id)
    -- id__C
    self:SendProtocal(41485, {id = id})
end

function GuildCtrl:OnGuildPracticeInfo(data)
    -- practice_skill__T__id@C##lv@H
    self:PrintTable(data)
    self.data:SetPracticeInfo(data)
end

function GuildCtrl:OnGuildPracticeUp(data)
    -- id__C
    -- lv__H
    self:PrintTable(data)
    self.data:PracticeUp(data)
end

-- 帮会宴请
function GuildCtrl:SendGuildBanquet()
    self:SendProtocal(41487)
end

function GuildCtrl:OnGuildBanquet(data)
    self:PrintTable(data)
end

function GuildCtrl:OnGuildDefendEnter(data)
    self:PrintTable(data)
end

function GuildCtrl:OnGuildDefendLeave(data)
    self:PrintTable(data)
end

-- 进入
function GuildCtrl:SendGuildDefendEnter()
    self:SendProtocal(51101)
end

-- 离开
function GuildCtrl:SendGuildDefendLeave()
    self:SendProtocal(51103)
end

-- 面板信息
function GuildCtrl:SendGuildDefendPanel()
    self:SendProtocal(51114)
end

-- 积分变化通知
function GuildCtrl:SendGuildDefendScore()
    self:SendProtocal(51116)
end

-- 倒计时10秒刷怪
function GuildCtrl:OnGuildDefendPublish(data)
    -- refresh_time__I  // 下次刷怪时间戳
    self:PrintTable(data)
    self.data:DefendPublish(data)
end

-- 刷怪
function GuildCtrl:OnGuildDefendRefresh(data)
    -- wave__C -- 当前波数
    -- refresh_time__I  -- 下次刷怪时间戳
    self:PrintTable(data)
    self.data:DefendRefresh(data)
end

-- 鼎受到伤害
function GuildCtrl:OnGuildDefendTripodHurt(data)
    -- tripod_id__I   -- 鼎怪物ID
    -- hp_pert__C -- 血量百分比    
    self:PrintTable(data)
    self.data:DefendTripodHurt(data)
end

function GuildCtrl:OnGuildDefendPanel(data)
    -- wave__C -- 当前波数
    -- refresh_time__I  -- 下次刷怪时间戳
    -- tripod_info__T__tripod_id@I##hp_pert@C
    self:PrintTable(data)
    self.data:SetDefendPanelInfo(data)
end

-- 积分变化通知
function GuildCtrl:OnGuildDefendScore(data)
    self:PrintTable(data)
    self:FireEvent(game.GuildEvent.UpdateDefendScoreInfo, data)
end

-- 鼎周围怪物通知
function GuildCtrl:OnGuildDefendMonNum(data)
    -- tripod_mon_num__T__tripod_id@I##mon_num@I
    -- self:PrintTable(data)
    self:FireEvent(game.GuildEvent.UpdateDefendMonInfo, data.tripod_mon_num)
end

-- 当前波数怪物
function GuildCtrl:OnGuildDefendCurNum(data)
    -- total_num__H
	-- leave_num__H
    self:PrintTable(data)
    self.data:SetDefendCurNum(data)
    self:FireEvent(game.GuildEvent.UpdateDefendCurNum, data)
end

-- 活动提前结束
function GuildCtrl:OnGuildDefendClose(data)
    -- end_time__I
    self:PrintTable(data)
    self:FireEvent(game.GuildEvent.OnGuildDefendClose, data.end_time)
end

function GuildCtrl:GetDefendCurNum()
    return self.data:GetDefendCurNum()
end

function GuildCtrl:GetGuildId()
    return self.data:GetGuildId()
end

function GuildCtrl:GetGuildLevel()
    return self.data:GetGuildLevel()
end

function GuildCtrl:GetGuildName()
    return self.data:GetGuildName()
end

function GuildCtrl:GetGuildInfo()
    return self.data:GetGuildInfo()
end

function GuildCtrl:GetGuildList()
    return self.data:GetGuildList()
end

function GuildCtrl:GetGuildMembers()
    return self.data:GetGuildMembers()
end

function GuildCtrl:GetGuildMemberInfo(member_id, guild_id)
    return self.data:GetGuildMemberInfo(member_id, guild_id)
end

function GuildCtrl:IsGuildMember()
    return self.data:IsGuildMember()
end

function GuildCtrl:GetGuildMemberPos()
    return self.data:GetGuildMemberPos()
end

function GuildCtrl:GetMemberOnlineNums()
    local online_nums = 0
    for k, v in pairs(self:GetGuildMembers() or {}) do
        if v.mem.offline == 0 then
            online_nums = online_nums + 1
        end
    end
    return online_nums
end

function GuildCtrl:GetGuildPosMemberNums(pos)
    return self.data:GetGuildPosMemberNums(pos)
end

function GuildCtrl:GetGuildApplyInfo()
    return self.data:GetGuildApplyInfo()
end

function GuildCtrl:GetGuildLiveInfo()
    return self.data:GetGuildLiveInfo()
end

function GuildCtrl:GetCookTypeAttr(type)
    return self.data:GetCookTypeAttr(type)
end

function GuildCtrl:GetDailyTaskName(task_id)
    return self.data:GetDailyTaskName(task_id)
end

function GuildCtrl:IsDenfState()
    local guild_info = self:GetGuildInfo()
    if guild_info and guild_info.denf_state == 1 then
        return true
    end
    return false
end

function GuildCtrl:GetDefendPanelInfo()
    return self.data:GetDefendPanelInfo()
end

function GuildCtrl:GetDefendMonsterConfig(wave_num)
    local defend_info = self.data:GetDefendPanelInfo()
    if wave_num or defend_info then
        local wave = wave_num or defend_info.wave
        local world_lv = game.MainUICtrl.instance:GetWorldLv()
        if config.guild_defend_mon[world_lv] then
            return config.guild_defend_mon[world_lv][wave]
        else
            for lv, monster_cfg in ipairs(game.Utils.SortByKey(config.guild_defend_mon)) do
                if lv <= world_lv then
                    return monster_cfg[wave]
                end
            end
        end
    end
end

function GuildCtrl:GetDefendMonsterConfig2()
    local world_lv = game.MainUICtrl.instance:GetWorldLv()
    if config.guild_defend_mon[world_lv] then
        return config.guild_defend_mon[world_lv]
    else
        for lv, monster_cfg in ipairs(game.Utils.SortByKey(config.guild_defend_mon)) do
            if lv <= world_lv then
                return monster_cfg
            end
        end
    end
end

function GuildCtrl:GetDefendAuctionConfig(wave)
    local world_lv = game.MainUICtrl.instance:GetWorldLv()
    local guild_defend_auction_config = game.Utils.SortByKey(config.guild_defend_auction)
    local auction_cfg

    for _, v in ipairs(guild_defend_auction_config) do
        if table.nums(v) > 0 then
            local data = game.Utils.SortByKey(v)
            local lv = data[1].world_lv
            if world_lv <= lv then
                auction_cfg = data
                break
            end
        end
    end

    for i=#auction_cfg, 1, -1 do
        local cfg = auction_cfg[i]
        if wave >= cfg.wave then
            return cfg
        end
    end
end

function GuildCtrl:GetDefendTripodInfo()
    local guild_level = self:GetGuildLevel()
    local config = config.guild_defend_tripod
    if config[guild_level] then
        return config[guild_level]
    else
        for _, v in ipairs(game.Utils.SortByKey(config)) do
            if v[1] and guild_level <= v[1].guild_lv then
                return v
            end
        end
    end
end

function GuildCtrl:GetDefendWave()
    local defend_info = self.data:GetDefendPanelInfo()
    if defend_info then
        return defend_info.wave
    end
end

function GuildCtrl:TryJoinInGuildWine()
    local open_lv = config.guild_wine_act.open_lv
    if not self:IsGuildMember() then
        game.GameMsgCtrl.instance:PushMsgCode(3401)
    elseif game.RoleCtrl.instance:GetRoleLevel() < open_lv then
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[1953], open_lv))
    elseif not game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.GuildWine) then
        game.GameMsgCtrl.instance:PushMsg(config.words[4758])
    else
        local scene_id = config.sys_config.guild_seat_scene.value
        game.Scene.instance:GetMainRole():GetOperateMgr():DoChangeScene(scene_id)
    end
end

-- 获取行酒令侧边栏信息
function GuildCtrl:SendGuildWineActInfo()
    self:SendProtocal(51801)
end

-- 抛骰子
function GuildCtrl:SendGuildWineActDice()
    self:SendProtocal(51806)
end

-- 获取点评界面数据
function GuildCtrl:SendGuildWineActCommentInfo()
    self:SendProtocal(51808)
end

-- 对玩家给出点评
function GuildCtrl:SendGuildWineActGiveComment(role_id, comment_type)
    -- role_id__I                               -- 玩家ID
    -- comment_type__C                          -- 点评类型，1点赞，2点踩
    self:SendProtocal(51810, {role_id = role_id, comment_type = comment_type})
end

function GuildCtrl:OnGuildWineActInfo(data)
    self:PrintTable(data)
    self.data:SetWineInfo(data)
end

-- 下发累计获得经验更新
function GuildCtrl:OnGuildWineActUpdateExp(data)
    self.data:UpdateWineInfo(data, false)
    self:FireEvent(game.GuildEvent.UpdateWineExp, data.exp_get)
end

-- 下发参与人数更新
function GuildCtrl:OnGuildWineActUpdateNumber(data)
    self:PrintTable(data)
    self.data:UpdateWineInfo(data, false)
    self:FireEvent(game.GuildEvent.UpdateWineNumber, data)
end

-- 下发新环节信息
function GuildCtrl:OnGuildWineActUpdateNextSubject(data)
    self:PrintTable(data)
    self.data:UpdateWineInfo(data, false)
    self:FireEvent(game.GuildEvent.UpdateWineNextSubject, data)
end

function GuildCtrl:OnQuestionInfo(data)
    self:PrintTable(data)
    self.data:SetQuestionInfo(data)
end

function GuildCtrl:OnQuestionAnswer(data)
    self:PrintTable(data)
    self:SendQuestionInfo()
end

-- 返回抛骰子结果
function GuildCtrl:OnGuildWineActDice(data)
    self:PrintTable(data)
    self.data:UpdateWineInfo(data, false)
    self:FireEvent(game.GuildEvent.OnWineDice, data)
end

function GuildCtrl:GetGuildWineDiceData()
    return self.data:GetGuildWineDiceData()
end

function GuildCtrl:OnGuildWineActCommentInfo(data)
    self:PrintTable(data)
    self:FireEvent(game.GuildEvent.UpdateWineCommentInfo, data)
end

-- 下发点评界面信息更新
function GuildCtrl:OnGuildWineActUpdateRole(data)
    self:PrintTable(data)
    self:FireEvent(game.GuildEvent.UpdateWineCommentRoleInfo, data)
end

-- 请求开始练功
function GuildCtrl:SendGuildBeginPractice()
    self:SendProtocal(52001)
end

-- 成功进入练功返回
function GuildCtrl:OnGuildBeginPractice(data)
    --[[
        end_time__I                             -- 将要结束练功的时间戳，用于显示进度条
    ]]
    self:PrintTable(data)
    self:SetPracticeEndTime(data.end_time)
end

-- 参加帮会练功（直接拉到练功师跟前）
function GuildCtrl:SendGuildJoinInPractice()
    self:SendProtocal(52003)
end

function GuildCtrl:TryJoinInPractice()
    local open_lv = config.guild_wine_practice.open_lv
    if not self:IsGuildMember() then
        game.GameMsgCtrl.instance:PushMsgCode(3401)
    elseif game.RoleCtrl.instance:GetRoleLevel() < open_lv then
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[1948], open_lv))
    else
        local npc_id = 2003
        game.Scene.instance:GetMainRole():GetOperateMgr():DoGoToTalkNpc(npc_id)
    end
end

function GuildCtrl:TryPractice()
    local ctrl = game.MakeTeamCtrl.instance
    local act = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.GuildPractice)
    local open_lv = config.guild_wine_practice.open_lv
    local need_num = config.guild_wine_practice.team_num
    
    if not act then
        game.GameMsgCtrl.instance:PushMsgCode(3900)
    elseif game.RoleCtrl.instance:GetRoleLevel() < open_lv then
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[1948], open_lv))
    elseif not ctrl:HasTeam() or ctrl:GetTeamMemberNums() < need_num then
        self:OpenGuildTipsView(3)
    elseif ctrl:HasTeam() and ctrl:GetTeamMemberNums() > need_num then
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[4771], need_num))
    else
        self:SendGuildBeginPractice()
    end
end

function GuildCtrl:SetPracticeEndTime(end_time)
    self.practice_end_time = end_time
end

function GuildCtrl:GetPracticeEndTime()
    return self.practice_end_time
end

function GuildCtrl:GetPracticeTargetPosXY(logic_x, logic_y)
    local config = config.guild_wine_practice.area
    local x, y = logic_x, logic_y
    if not logic_x or not logic_y then
        x, y = game.Scene.instance:GetMainRole():GetLogicPosXY()
    end
    for k, v in pairs(config) do
        if math.abs(v[1] - x) == 1 then
            return v[1], y
        end
    end
end

-- 向帮会频道发送练功组队邀请信息
function GuildCtrl:SendGuildSendTeamInvite()
    self:SendProtocal(52004)
end

-- 运镖
function GuildCtrl:SendCarryInfoReq()
    -- print("SendCarryInfoReq")
    self:SendProtocal(52101)
end

function GuildCtrl:SendBookCarryReq()
    -- print("SendBookCarryReq")
    self:SendProtocal(52103)
end

function GuildCtrl:SendRefreshCarryReq(val)
    self:SendProtocal(52105, {type = val})
end

function GuildCtrl:SendStartCarryReq()
    self:SendProtocal(52106)
end

function GuildCtrl:SendSubmitCarryReq()
    self:SendProtocal(52107)
end

function GuildCtrl:OnCarryInfoResp(data_list)
    -- print("OnCarryInfoResp")
    --  PrintTable(data_list)
    self.data:SetYunBiaoData(data_list)
end

function GuildCtrl:OnNotifyCarry(data_list)
    -- print("OnNotifyCarry")
    -- PrintTable(data_list)
    self.data:SetYunBiaoQuality(data_list.quality, data_list.refresh_times)
end

function GuildCtrl:GetYunbiaoData()
    return self.data:GetYunBiaoData()
end

function GuildCtrl:SendTransferToCarryReq()
    self:SendProtocal(52108)
end

function GuildCtrl:OnNotifyCarryPos(data_list)
    -- print("OnNotifyCarryPos")
    -- PrintTable(data_list)
    self.data:SetYunBiaoPos(data_list.scene_id, data_list.x, data_list.y)
end

function GuildCtrl:GetCarryLeftRobTimes()
    return self.data:GetCarryLeftRobTimes()
end

function GuildCtrl:OnLevelUpPracticeMaxLv(data_list)
    self.data:SetPracticeMaxLv(data_list.prac_max_lv)
    game.GameMsgCtrl.instance:PushMsg(config.words[5598])
end

function GuildCtrl:SendLevelUpPracticeMaxLv()
    self:SendProtocal(20502)
end

function GuildCtrl:IsPracticeSkillAllMax()
    return self.data:IsPracticeSkillAllMax()
end

function GuildCtrl:GetPracticeLevelConfig()
    return self.data:GetPracticeLevelConfig()
end

function GuildCtrl:GetRealPracticeMaxLv()
    return self.data:GetRealPracticeMaxLv()
end

function GuildCtrl:CanRecruit()
    return self.data:CanRecruit()
end

function GuildCtrl:GetGuildLevelConfig(lv)
    return self.data:GetGuildLevelConfig(lv)
end

-- 帮会炼金
function GuildCtrl:SendGuildMetallInfo()
    self:SendProtocal(41489)
end

function GuildCtrl:OnGuildMetallInfo(data)
    self:PrintTable(data)
    self.data:UpdateMetallTaskInfo(data)
end

function GuildCtrl:SendGuildMetallTask(type)
    self:SendProtocal(41491, {type = type})
end

function GuildCtrl:OnGuildMetallTask(data)
    self:PrintTable(data)
    self.data:UpdateMetallTaskInfo(data)
    if data.task_id ~= 0 then
        game.Scene.instance:GetMainRole():GetOperateMgr():DoHangTask(data.task_id)
    end
end

function GuildCtrl:GetMetallTaskId()
    return self.data:GetMetallTaskId()
end

function GuildCtrl:GetMetallLively()
    return self.data:GetMetallLively()
end

-- 帮会建筑
function GuildCtrl:SendGuildBuildUp(id)
    --[[
        "id__H",                  
    ]]
    self:SendProtocal(41493, {id = id})
end

function GuildCtrl:OnGuildBuildUp(data)
    --[[
        "build__T__id@H##lv@C",   
    ]]
    self:PrintTable(data)
    self.data:UpdateBuildInfo(data.build)
end

function GuildCtrl:GetBuildInfo()
    return self.data:GetBuildInfo()
end

-- 帮会研究
function GuildCtrl:SendGuildStudyUp(id)
    --[[
        "id__H",                  
    ]]
    self:SendProtocal(41495, {id = id})
end

function GuildCtrl:OnGuildStudyUp(data)
    --[[
        "study__T__id@H##lv@C",   
    ]]
    self:PrintTable(data)
    self.data:UpdateResearchInfo(data.study)
end

function GuildCtrl:GetResearchBuildLevel(build)
    return self.data:GetResearchBuildLevel(build)
end

function GuildCtrl:GetWingBuildLevel(build)
    return self.data:GetWingBuildLevel(build)
end

function GuildCtrl:GetPavilionBuildLevel(build)
    return self.data:GetPavilionBuildLevel(build)
end

function GuildCtrl:IsAllBuildMaxLevel()
    return self.data:IsAllBuildMaxLevel()
end

function GuildCtrl:GetResearchInfo()
    return self.data:GetResearchInfo()
end

function GuildCtrl:GetResearchInfoByType(type)
    return self.data:GetResearchInfoByType(type)
end

function GuildCtrl:GetResearchLevel(id)
    return self.data:GetResearchLevel(id)
end

-- 帮会工资
function GuildCtrl:SendGuildWagesInfo()
    self:SendProtocal(53401)
end

function GuildCtrl:OnGuildWagesInfo(data)
    --[[
        stages__T__id@H##times@C",   
    ]]
    self:PrintTable(data)
    self.data:FireEvent(game.GuildEvent.OnGuildWagesInfo, data.stages)
end

-- 宣战
function GuildCtrl:SendGuildDeclare(guild_id)
    --[[
        "guild_id__L",                                 -- 被宣战帮会ID
    ]]
    self:SendProtocal(53501, {guild_id = guild_id})
end

function GuildCtrl:OnGuildDeclare(data)
    self:PrintTable(data)
    self.data:AddDeclareGuild(data)
    if data.type == 1 then
        game.GameMsgCtrl.instance:PushMsg(config.words[6011])
    end
end

-- 敌对设置
function GuildCtrl:SendGuildHostile(guild_id)
    --[[
        "guild_id__L",                                 -- 被设置帮会ID
    ]]
    self:SendProtocal(53503, {guild_id = guild_id})
end

function GuildCtrl:OnGuildHostile(data)
    self:PrintTable(data)
    self.data:AddHostile(data)
    game.GameMsgCtrl.instance:PushMsg(config.words[6010])
end

-- 宣战列表
function GuildCtrl:SendGuildDeclareList()
    self:SendProtocal(53505)
end

function GuildCtrl:OnGuildDeclareList(data)
    self:PrintTable(data)
    self.data:SetDeclareWarList(data)
end

function GuildCtrl:OnGuildDeclareExpire(data)
    --[[
        "list__T__guild_id@L",
    ]]
    self:PrintTable(data)
    self.data:DeclareExpire(data.list)
end

function GuildCtrl:IsDeclareWar(num)
    return self.data:IsDeclareWar(num)
end

function GuildCtrl:IsBackWar(num)
    return self.data:IsBackWar(num)
end

-- 敌对列表
function GuildCtrl:SendGuildHostileList()
    self:SendProtocal(53507)
end

function GuildCtrl:OnGuildHostileList(data)
    --[[
        "hostile__T__num@L##rob@I",               -- 敌对列表 帮会ID 街标配收益
    ]]
    self:PrintTable(data)
    self.data:SetHostileList(data.hostile)
end

-- 解除敌对关系
function GuildCtrl:SendGuildHostileCancel(guild_id)
        --[[
        "guild_id__L",
    ]]
    self:SendProtocal(53519, {guild_id = guild_id})
end

function GuildCtrl:OnGuildHostileCancel(data)
    --[[
        "guild_id__L",
    ]]
    self:PrintTable(data)
    self.data:OnGuildHostileCancel(data.guild_id)
end

function GuildCtrl:GetHostileList()
    return self.data:GetHostileList()
end

function GuildCtrl:IsHostileGuild(guild_id)
    return self.data:IsHostileGuild(guild_id)
end

-- 帮会祝福
function GuildCtrl:SendGuildBlessInfo()
    self:SendProtocal(53510)
end

function GuildCtrl:OnGuildBlessInfo(data)
    --[[
        "bless__T__id@H##expire@I",   -- expire 过期时间戳
    ]]
    self:PrintTable(data)
    self.data:SetBlessInfo(data.bless)
end

-- expire 过期时间戳
function GuildCtrl:SendGuildBless(id)
    --[[
        "id__C",                      
    ]]
    self:SendProtocal(53512, {id = id})
end

function GuildCtrl:OnGuildBless(data)
    --[[
        "id__C",                      
        "expire__I",                  
    ]]
    self:PrintTable(data)
    self.data:UpdateBlessInfo(data)
end

function GuildCtrl:GetBlessExpireTime(id)
    return self.data:GetBlessExpireTime(id)
end

function GuildCtrl:GetGuildMaxMemberNum(build)
    return self.data:GetGuildMaxMemberNum(build)
end

function GuildCtrl:GetChiefName()
    return self.data:GetChiefName()
end

function GuildCtrl:CanChangeAnnounce()
    return (self.data:GetGuildMemberPos()>=game.GuildPos.ViceChief)
end

function GuildCtrl:OnGuildMoneyChange(data)
    self.data:OnGuildMoneyChange(data)
end

function GuildCtrl:OnGuildMoneyRemove(data)
    self.data:OnGuildMoneyRemove(data)
end

function GuildCtrl:GetLuckyMoney()
    return self.data:GetLuckyMoney()
end

function GuildCtrl:IsReceiveLuckyMoney(info)
    local role_id = game.RoleCtrl.instance:GetRoleId()
    for k, v in ipairs(info.list) do
        if v.role_id == role_id then
            return true
        end
    end
    return false
end

function GuildCtrl:GetReceiveState(info)
    return self.data:GetReceiveState(info)
end

function GuildCtrl:GetStandardDenfFunds()
    return self.data:GetStandardDenfFunds()
end

function GuildCtrl:GetDenfFunds()
    return math.floor(self.data:GetStandardDenfFunds() / 72)
end

function GuildCtrl:GetLowDenfFunds()
    return math.floor(self:GetDenfFunds() * 0.54)
end

function GuildCtrl:CanJoinGuild()
    local act_list = config.sys_config.guild_forbid_join_activity_ids.value
    for k, v in ipairs(act_list or game.EmptyTable) do
        local act = game.ActivityMgrCtrl.instance:GetActivity(v)
        if act and (act.state == game.ActivityState.ACT_STATE_PREPARE or act.state == game.ActivityState.ACT_STATE_ONGOING) then
            game.GameMsgCtrl.instance:PushMsgCode(3458)
            return false
        end
    end
    return true
end

function GuildCtrl:GetResearchEffect(id)
    return self.data:GetResearchEffect(id)
end

function GuildCtrl:GetPracticeInfo()
    return self.data:GetPracticeInfo()
end

function GuildCtrl:CanSkillUpPracticeSkill(id, lv)
    return self.data:CanSkillUpPracticeSkill(id, lv)
end

function GuildCtrl:GetPracticeTotalLv()
    return self.data:GetPracticeTotalLv()
end

function GuildCtrl:OnGuildTeamCarbonInfo(data)
    self.data:OnGuildTeamCarbonInfo(data)
end

function GuildCtrl:IsRivalGuild(guild_id)
    return self.data:IsRivalGuild(guild_id)
end

function GuildCtrl:GetDeclareWarIDList()
    return self.data:GetDeclareWarIDList()
end

function GuildCtrl:OnDeclareWarListChange(change_list)
    if change_list and table.nums(change_list) > 0 then
        local role_list = game.Scene.instance:GetObjByType(game.ObjType.Role, function(obj)
            return change_list[obj:GetGuildID()] ~= nil
        end)
        for k, v in ipairs(role_list) do
            v:RefreshNameColor()
        end
    end
end

function GuildCtrl:GetHostileIDList()
    return self.data:GetHostileIDList()
end

function GuildCtrl:OnHostileListChange(change_list)
    local act = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.GuildCarry)
    if act and change_list and table.nums(change_list) > 0 then
        local role_list = game.Scene.instance:GetObjByType(game.ObjType.Role, function(obj)
            return change_list[obj:GetGuildID()] ~= nil
        end)
        for k, v in ipairs(role_list) do
            v:RefreshNameColor()
        end
    end
end

function GuildCtrl:IsTransformAlchemist()
    local role = game.Scene.instance:GetMainRole()
    local id = role:GetTranStat()
    return id == 1 or id == 2
end

function GuildCtrl:GetQuestionInfo()
    return self.data:GetQuestionInfo()
end

function GuildCtrl:GetRecruitTime()
    return self.data:GetRecruitTime()
end

game.GuildCtrl = GuildCtrl

return GuildCtrl