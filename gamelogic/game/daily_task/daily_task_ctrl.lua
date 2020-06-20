local DailyTaskCtrl = Class(game.BaseCtrl)

local view_map = {
    daily_task_view = "game/daily_task/daily_task_view",
    jhexp_tips_view = "game/daily_task/daily_task_jhexp_tips_view",

    chess_chal_view = "game/daily_task/daily_task_chess_chal_view",
    chess_tips_view = "game/daily_task/daily_task_chess_tips_view",
    
    daily_task_tips_view = "game/daily_task/daily_task_tips_view",

    thief_exp_view = "game/daily_task/daily_thief_exp_view",
    thief_roraty_view = "game/daily_task/daily_thief_roraty_view",
    team_member_state_view = "game/daily_task/team_member_state_view",

    guild_task_question_view = "game/daily_task/guild_task_question_view",
    task_item_select_view = "game/daily_task/task_item_select_view",

    examine_rank_view = "game/daily_task/examine_rank_view",
    examine_assist_view = "game/daily_task/examine_assist_view",

    reward_show_view = "game/daily_task/reward_show_view",

    treasure_reward_view = "game/daily_task/treasure_reward_view",
    treasure_map_view = "game/daily_task/treasure_map_view",

    daily_task_item_view = "game/daily_task/daily_task_item_view",
    line_game_view = "game/daily_task/daily_task_line_game_view",
    puzzle_game_view = "game/daily_task/daily_task_puzzle_game_view",
}

function DailyTaskCtrl:_init()
    if DailyTaskCtrl.instance ~= nil then
        error("DailyTaskCtrl Init Twice!")
    end
    DailyTaskCtrl.instance = self

    for view_name, class in pairs(view_map) do
        self[view_name] = require(class).New(self)
        self:CreateViewFunc(view_name)
    end
    self.data = require("game/daily_task/daily_task_data").New(self)

    self:RegisterAllEvents()
    self:RegisterAllProtocal()
end

function DailyTaskCtrl:PrintTable(data)
    if self.log_enable then
        PrintTable(data)
    end
end

function DailyTaskCtrl:print(...)
    if self.log_enable then
        print(...)
    end
end

function DailyTaskCtrl:CreateViewFunc(view_name)
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
        else
            if self[view_name].Refresh then
                self[view_name]:Refresh(...)
            end
        end
    end
    self[close_func] = function(self, ...)
        if self[view_name] then
            self[view_name]:Close()
        end
    end
end

function DailyTaskCtrl:_delete()
    for view_name, class in pairs(view_map) do
        self[view_name]:DeleteMe()
        self[view_name] = nil
    end
    self.data:DeleteMe()
    DailyTaskCtrl.instance = nil
end

function DailyTaskCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginRoleRet, handler(self, self.OnLoginRoleRet)},
        {game.ChatEvent.UpdateNewChat, handler(self, self.OnUpdateNewChat)},
        {game.ChatEvent.AddHisChatData, handler(self, self.OnAddHisChatData)},
        {game.SceneEvent.CommonlyValueRespon, handler(self, self.OnCommonlyValue)},
        {game.GuildEvent.LeaveGuild, handler(self, self.OnLeaveGuild)},
        {game.SceneEvent.ChangeScene, handler(self, self.OnChangeScene)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function DailyTaskCtrl:RegisterAllProtocal()
    local proto = {
        [10702] = "OnKillMonRewardResp",
        [10704] = "OnFinishKillMonRewardReq",

        [25302] = "OnChessInfo",
        [25304] = "OnChessRefresh",
        [25306] = "OnChessOneKeyFinish",
        [25308] = "OnChessGetReward",

        [51002] = "OnDailyThiefInfo",
        [51004] = "OnDailyThiefGet",
        [51006] = "OnDailyThiefNear",
        [51007] = "OnDailyThiefKill",
        [51008] = "OnDailyThiefKillHorse",
        [51010] = "OnDailyThiefExpAdven",
        [51012] = "OnDailyThiefRoratyAdven",
        [51014] = "OnDailyThiefCancel",
        [51015] = "OnDailyThiefRefershAdven",
        [51018] = "OnDailyThiefTriggerRoraty",
        [51019] = "OnDailyThiefTaskBack",
        [51021] = "OnDailyThiefRoratyAdvenGet",
        [51023] = "OnDailyThiefExpAdvenGet",

        [51402] = "OnGuildTask",
        [51404] = "OnGuildTaskGet",
        [51406] = "OnGuildTaskFinish",
        [51407] = "OnGuildTaskInfo",
        [51409] = "OnGuildTaskCancel",
        [51410] = "OnGuildTaskTimesChange",

        [51502] = "OnExamineInfo",
        [51504] = "OnExamineBegin",
        [51506] = "OnExamineRank",
        [51508] = "OnExamineAnswer",
        [51510] = "OnExamineHelp",
        [51512] = "OnExamineReward",
        [51514] = "OnExamineHelpReward",
        [51516] = "OnExamineGuide",

        [51602] = "ScDailyRobberInfo",
        [51604] = "ScDailyRobberAcceptTask",
        [51606] = "ScDailyRobberAbandonTask",
        [51607] = "ScDailyRobberUpdateTask",

        [51902] = "OnTreasureMapInfo",
        [51904] = "OnTreasureMapPos",
        [51906] = "OnTreasureMapUse",
        [51907] = "OnTreasureMapRefresh",
        [51909] = "OnTreasureMapGet",
        [51910] = "OnTreasureMaoKill",
        [51912] = "OnTreasureMapReward",
        [51913] = "OnTreasureMapEvent",

        [53202] = "OnDailyTaskInfo",
        [53204] = "OnDailyTaskGet",
    }
    for id, func_name in pairs(proto) do
        self:RegisterProtocalCallback(id, func_name)
    end
end

function DailyTaskCtrl:OpenView(index, ...)
    if not self.daily_task_view:IsOpen() then
        self.daily_task_view:Open(index, ...)
    else
        self.daily_task_view:Refresh(index, ...)
    end
end

function DailyTaskCtrl:CloseView(view_name)
    if not view_name then
        self.daily_task_view:Close()
    else
        if self[view_name] then
            self[view_name]:Close()
        end
    end
end

function DailyTaskCtrl:IsOpen(view_name)
    return self[view_name]:IsOpen()
end

function DailyTaskCtrl:OpenTipsView(...)
    self.daily_task_tips_view:Open(...)
end

function DailyTaskCtrl:OnLoginRoleRet(val)
    if val then
        self:SendDailyThiefInfo()
        self:SendGuildTask()
        self:SendTreasureMapInfo()
        self:CsDailyRobberInfo()

        game.MainUICtrl.instance:SendGetCommonlyKeyValue(game.CommonlyKey.GuildTaskNpcId)
        game.MainUICtrl.instance:SendGetCommonlyKeyValue(game.CommonlyKey.ExamineNewTaskNum)
        game.MainUICtrl.instance:SendGetCommonlyKeyValue(game.CommonlyKey.ExamineNewTaskRight)
    end
end

function DailyTaskCtrl:OnCommonlyValue(data)
    if data.key == game.CommonlyKey.GuildTaskNpcId then
        self.data:SetGuildTaskNpcId(data.value)
    elseif data.key == game.CommonlyKey.ExamineNewTaskNum then
        self:SetExamineNewTaskNum(data.value)
    elseif data.key == game.CommonlyKey.ExamineNewTaskRight then
        self:SetExamineNewTaskRight(data.value)
    end
end

function DailyTaskCtrl:OnChangeScene(to_scene_id, from_scene_id)
    if from_scene_id == config.treasure_map_info.scene_id then
        local team_ctrl = game.MakeTeamCtrl.instance
        if team_ctrl:HasTeam() then
            local role_id = game.Scene.instance:GetMainRoleID()
            if team_ctrl:IsLeader(role_id) then
                if team_ctrl:GetTeamMemberNums() <= 1 then
                    return
                end

                if not team_ctrl:IsTeamFollow() then
                    team_ctrl:SendTeamFollow(1)
                end
            else
                local is_following = team_ctrl:IsMemberFollow(role_id)
                if not team_ctrl:IsMemberFollow(role_id) then
                    team_ctrl:SendTeamSyncState(game.TeamFollowState.CloseTo)
                    team_ctrl:DoFollowStart()
                end
            end
        end
    end
end

function DailyTaskCtrl:OnLeaveGuild()
    self:ResetExamineInfo()
end

function DailyTaskCtrl:JoinInChessAct()
    local act = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.Chess)
    local team_ctrl = game.MakeTeamCtrl.instance
    local need_num = config.sys_config["chess_team_need_num"].value
    if not act then
        game.GameMsgCtrl.instance:PushMsg(config.words[4453])
    elseif not team_ctrl:HasTeam() or team_ctrl:GetTeamMemberNums() < need_num then
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[1964], need_num))
    else
        local dun_id = 1200
        game.CarbonCtrl.instance:SendDungEnterTeam(dun_id)
    end
end

function DailyTaskCtrl:FindChessNpc()
    local npc_id = config.sys_config["chess_npc_id"].value
    game.Scene.instance:GetMainRole():GetOperateMgr():DoGoToNpc(npc_id, function()
        local npc = game.Scene.instance:GetNpc(npc_id)
        npc:ShowTalk()
    end)
end

function DailyTaskCtrl:OnDailyThiefInfo(data)
    self:PrintTable(data)
    self.data:SetThiefInfo(data)
end

function DailyTaskCtrl:OnDailyThiefGet(data)
    self:PrintTable(data)
    self.data:UpdateThiefInfo(data)
    self:HangThiefTask()
    if data.state ~= 3 then
        game.GameMsgCtrl.instance:PushMsg(config.words[1946])
    end
end

function DailyTaskCtrl:OnDailyThiefNear(data)
    self:PrintTable(data)
    self.data:UpdateThiefInfo(data)
    self:HangThiefTask()
    game.GameMsgCtrl.instance:PushMsg(config.words[1947])
end

-- 击杀马贼
function DailyTaskCtrl:OnDailyThiefKill(data)
    self:PrintTable(data)
    data.target_id = nil
    self.data:UpdateThiefInfo(data)
end

-- 击杀白马义从
function DailyTaskCtrl:OnDailyThiefKillHorse(data)
    self:PrintTable(data)
    data.horse_data = {}
    self.data:UpdateThiefInfo(data)
    if data.exp_time ~= 0 then
        self:OpenThiefExpView(data.exp_time)
    end
    self:HangThiefTask()
end

function DailyTaskCtrl:OnDailyThiefExpAdven(data)
    self:PrintTable(data)
    self:FireEvent(game.DailyTaskEvent.ThiefExpAdven, data.exp)
end

-- 经验奇遇领取
function DailyTaskCtrl:SendDailyThiefExpAdvenGet()
    self:SendProtocal(51022)
end

function DailyTaskCtrl:OnDailyThiefExpAdvenGet(data)
    self:PrintTable(data)
    self.data:UpdateThiefInfo(data)
end

function DailyTaskCtrl:OnDailyThiefRoratyAdven(data)
    self:PrintTable(data)
    self.data:UpdateThiefInfo(data)
    self:FireEvent(game.DailyTaskEvent.ThiefRoratyAdven, data.index)
end

function DailyTaskCtrl:SendDailyThiefRoratyAdvenGet()
    self:SendProtocal(51020)
end

function DailyTaskCtrl:OnDailyThiefRoratyAdvenGet(data)
    self:PrintTable(data)
    self.data:UpdateThiefInfo(data)
end

function DailyTaskCtrl:OnDailyThiefCancel(data)
    self:PrintTable(data)
    data.horse_data = nil
    data.npc_id = 0
    if data.type == 1 then
        game.GameMsgCtrl.instance:PushMsg(config.words[1967])
    elseif data.type == 2 then
        game.GameMsgCtrl.instance:PushMsg(config.words[1968])
    end
    self.data:UpdateThiefInfo(data)
end

-- 刷新出白马义从
function DailyTaskCtrl:OnDailyThiefRefershAdven(data)
    self:PrintTable(data)
    self.data:UpdateThiefInfo({horse_data = data})
    self:HangThiefTask()
    self:OpenTreasureRewardView(3)
end

-- 马贼任务
function DailyTaskCtrl:SendDailyThiefInfo()
    self:SendProtocal(51001)
end

-- 最开始接任务(一整轮马贼完成或自动接下一次马贼任务也返回此条)
function DailyTaskCtrl:SendDailyThiefGet()
    self:SendProtocal(51003)
end

-- 接近任务NPC
function DailyTaskCtrl:SendDailyThiefNear()
    self:SendProtocal(51005)
end

-- 经验奇遇
function DailyTaskCtrl:SendDailyThiefExpAdven()
    self:SendProtocal(51009)
end

-- 转盘奇遇
function DailyTaskCtrl:SendDailyThiefRoratyAdven()
    self:SendProtocal(51011)
end

-- 取消任务
function DailyTaskCtrl:SendDailyThiefCancel()
    self:SendProtocal(51013)
end

--  交任务(返回51014)
function DailyTaskCtrl:SendDailyThiefHandleTask()
    self:SendProtocal(51016)
end

-- 击杀马贼可能触发转盘奇遇
function DailyTaskCtrl:OnDailyThiefTriggerRoraty(data)
    self:PrintTable(data)
    self.data:UpdateThiefInfo(data)
    if data.roraty_time ~= 0 and data.roraty_time >= global.Time:GetServerTime() then
        self:OpenThiefRoratyView(data.roraty_time, data.roraty_list)
    end
end

-- 队长离开场景,任务回滚
function DailyTaskCtrl:OnDailyThiefTaskBack(data)
    self:PrintTable(data)
    self.data:UpdateThiefInfo(data)
end

function DailyTaskCtrl:GetThiefConfig()
    local role_lv = game.Scene.instance:GetMainRoleLevel()
    for _, thief_cfg in ipairs(config.daily_thief_by_lv) do
        if role_lv <= thief_cfg.lv then
            return thief_cfg
        end
    end
end

function DailyTaskCtrl:GetThiefInfo()
    return self.data:GetThiefInfo()
end

function DailyTaskCtrl:HangThiefTask()
    local scene = game.Scene.instance
    local main_role = scene and scene:GetMainRole()
    if main_role then
        main_role:GetOperateMgr():DoHangTask(game.DailyTaskId.BanditTask)
    end
end

function DailyTaskCtrl:StartThiefTask()
    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end

    local team_members = game.MakeTeamCtrl.instance:GetTeamMembers()
    local dist = config.sys_config.team_near_by_distance.value

    for _,v in ipairs(team_members or game.EmptyTable) do
        local role_id = v.member.id
        local role = game.Scene.instance:GetObjByUniqID(role_id)
        if not role or (role_id ~= main_role.uniq_id and cc.pDistanceSQ(role:GetLogicPos(), main_role:GetLogicPos()) > dist*dist) then
            game.GameMsgCtrl.instance:PushMsg(config.words[5175])
            self:OpenTeamMemberStateView(dist)
            return
        end
    end
    self:SendDailyThiefGet()
end

-- (有帮会的玩家才会返回51490)
function DailyTaskCtrl:SendGuildTask()
    self:SendProtocal(51401)
end

-- 接任务
function DailyTaskCtrl:SendGuildTaskGet(type)
    -- type__C
    self:SendProtocal(51403, {type = type})
end

-- 完成任务
function DailyTaskCtrl:SendGuildTaskFinish(type, grid)
    self:SendProtocal(51405, {type = type, grid = grid})
end

-- 放弃任务
function DailyTaskCtrl:SendGuildTaskCancel()
    self:SendProtocal(51408)
end

function DailyTaskCtrl:OnGuildTask(data)
    self:PrintTable(data)
    self.data:SetGuildTaskInfo(data)
end

function DailyTaskCtrl:OnGuildTaskGet(data)
    self:PrintTable(data)
    data.flag = 1
    self.data:RandomGuildTaskNpcId(data.type)
    self.data:UpdateGuildTaskInfo(data)
    self:FireEvent(game.DailyTaskEvent.GuildTaskGet)
end

-- 完成任务返回51406和51407
function DailyTaskCtrl:OnGuildTaskFinish(data)
    self:PrintTable(data)
    self.data:UpdateGuildTaskInfo(data)
    self:FireEvent(game.DailyTaskEvent.GuildTaskFinish, data)

    game.GameMsgCtrl.instance:PushMsg(config.words[5139])
    self:TryOpenGuildTaskView()
end

function DailyTaskCtrl:TryOpenGuildTaskView(force)
    local task_info = self.data:GetGuildTaskInfo()
    if task_info and task_info.daily_times < config.guild_task_info.daily_max_times then
        if task_info.type ~= 3 or not self["guild_task_question_view"]:IsOpen() or force then
            game.GuildTaskCtrl.instance:OpenView()
        end
    end
end

-- 帮会任务总进度
function DailyTaskCtrl:OnGuildTaskInfo(data)
    self:PrintTable(data)
    self.data:UpdateGuildTaskInfo(data)
end

function DailyTaskCtrl:OnGuildTaskCancel(data)
    self:PrintTable(data)
    if data.flag == 0 then
        data.type = 0
        data.id = 0
    end
    self.data:UpdateGuildTaskInfo(data)
end

-- 完成次数改变通知
function DailyTaskCtrl:OnGuildTaskTimesChange(data)
    self:PrintTable(data)
    self.data:UpdateGuildTaskInfo(data)
end

function DailyTaskCtrl:TryCompleteNpcGuildTask(npc_cfg)
    local task_data = self:GetGuildTaskInfo()
    if not task_data or task_data.flag == 0 then
        game.GameMsgCtrl.instance:PushMsg(config.words[5140])
        return false
    else
        local type = task_data.type
        local id = task_data.id
        local task_cfg = config.guild_task[type][id]
        local npc_task_type = {4, 5}
        local npc_id = self:GetGuildTaskNpcId()

        if npc_id ~= npc_cfg.id or not table.indexof(npc_task_type, type) then
            game.GameMsgCtrl.instance:PushMsg(config.words[5140])
            return false
        else
            local main_role = game.Scene.instance:GetMainRole()
            main_role:GetOperateMgr():DoHangGuildTask()
            return true
        end
    end
end

function DailyTaskCtrl:GetGuildTaskNpcId()
    return self.data:GetGuildTaskNpcId()
end

function DailyTaskCtrl:GetGuildTaskInfo()
    return self.data:GetGuildTaskInfo()
end

function DailyTaskCtrl:CsDailyRobberInfo()
    self:SendProtocal(51601)
end

function DailyTaskCtrl:ScDailyRobberInfo(data)
    self.data:SetCxdxData(data)
    self:FireEvent(game.DailyTaskEvent.UpdateCxdtInfo, data)
end

function DailyTaskCtrl:CsDailyRobberAcceptTask()
    self:SendProtocal(51603)
end

function DailyTaskCtrl:ScDailyRobberAcceptTask(data)
    self.data:UpdateCxdtData(data)
    self:FireEvent(game.DailyTaskEvent.UpdateCxdtInfo, data)

    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        main_role:GetOperateMgr():DoHangTask(game.DailyTaskId.RobberTask)
    end
end

function DailyTaskCtrl:CsDailyRobberAbandonTask()
    self:SendProtocal(51605)
end

function DailyTaskCtrl:ScDailyRobberAbandonTask(data)
    self.data:UpdateCxdtData(data)
    self:FireEvent(game.DailyTaskEvent.UpdateCxdtInfo, data)
end

function DailyTaskCtrl:ScDailyRobberUpdateTask(data)
    self.data:UpdateCxdtData(data)

    local cxdt_data = self:GetCxdtData()
    if cxdt_data then
        local used_times = cxdt_data.times
        local max_times = cxdt_data.max_times

        if used_times == max_times and cxdt_data.state == 2 then
            local npc_id = config.activity_hall_ex[1007].npc_id
            game.Scene.instance:GetMainRole():GetOperateMgr():DoGoToNpc(npc_id, function()
                local npc = game.Scene.instance:GetNpc(npc_id)
                if npc then
                    npc:ShowTalk()
                end
            end)
        end
    end
    self:FireEvent(game.DailyTaskEvent.UpdateCxdtInfo, data)
end

function DailyTaskCtrl:CsDailyRobberSubmitTask()
    self:SendProtocal(51608)
end

function DailyTaskCtrl:GetCxdtData()
    return self.data:GetCxdtData()
end

-- 科举考试 515

function DailyTaskCtrl:SendExamineInfo()
    self:SendProtocal(51501)
end

-- 打开答题界面时发送
function DailyTaskCtrl:SendExamineBegin()
    self:SendProtocal(51503)
end

-- 打开排名界面时请求
function DailyTaskCtrl:SendExamineRank()
    self:SendProtocal(51505)
end

-- 答题
function DailyTaskCtrl:SendExamineAnswer(index)
    self:SendProtocal(51507, {index = index})
end

-- 求助
function DailyTaskCtrl:SendExamineHelp()
    self:SendProtocal(51509)
end

-- 获得奖励
function DailyTaskCtrl:SendExamineReward()
    self:SendProtocal(51511)
end

function DailyTaskCtrl:OnExamineInfo(data)
    self:PrintTable(data)
    self.data:SetExamineInfo(data)
end

function DailyTaskCtrl:OnExamineBegin(data)
    self:PrintTable(data)
    self.data:SetExamineAnswerState(1)
    self.data:UpdateExamineInfo(data)
end

function DailyTaskCtrl:OnExamineRank(data)
    self:PrintTable(data)
    self:FireEvent(game.DailyTaskEvent.UpdateExamineRankInfo, data.ranks)
end

function DailyTaskCtrl:OnExamineAnswer(data)
    self:PrintTable(data)
    self.data:OnExamineAnswer(data)
end

function DailyTaskCtrl:OnExamineHelp(data)
    self:PrintTable(data)
    self.data:UpdateExamineInfo(data)
end

function DailyTaskCtrl:OnExamineReward(data)
    -- is_get__C
    self:PrintTable(data)
    self.data:UpdateExamineInfo(data)
end

-- 帮助获奖
function DailyTaskCtrl:SendExamineHelpReward(target_id, id)
    self:SendProtocal(51513, {target_id = target_id, id = id})
end

function DailyTaskCtrl:OnExamineHelpReward(data)
    self:PrintTable(data)
end

function DailyTaskCtrl:GetExamineInfo()
    return self.data:GetExamineInfo()
end

function DailyTaskCtrl:OnAddHisChatData(his_chat_data)
    for k, v in pairs(his_chat_data or game.EmptyTable) do
        self:OnUpdateNewChat(v, true)
    end
end

function DailyTaskCtrl:OnUpdateNewChat(data, is_history)
    local help_chat_id = config.examine_info.help_chat_id
    local assist_chat_id = config.examine_info.assist_chat_id

    if data.channel ~= game.ChatChannel.Guild or data.extra == "" then
        return
    end

    local params = string.split(data.extra, "|")
    local chat_id = tonumber(params[1])

    if chat_id ~= help_chat_id and chat_id ~= assist_chat_id then
        return
    end

    local data = unserialize(params[2])
    local tag = (chat_id == help_chat_id) and 0 or 1
    self.data:SetExamineHelpTag(data, tag)

    if not is_history then
        local self_role_id = game.Scene.instance:GetMainRoleID()
        if tag == 0 then
            if data.role_id ~= self_role_id then
                return
            end
            local exam_info = self:GetExamineInfo()
            if not exam_info then
                return
            end      
            if exam_info.answer_num == data.answer_num and exam_info.id == data.quest_id then
                self:SendExamineHelp()
                self:SetExamineHelpState(data, 1)
                self:FireEvent(game.DailyTaskEvent.UpdateExamineHelpState)
                game.GameMsgCtrl.instance:PushMsg(config.words[5142])
            end
        elseif tag == 1 then
            if data.answer_role_id == self_role_id then
                self:SendExamineHelpReward(data.role_id, data.quest_id)
                game.GameMsgCtrl.instance:PushMsg(config.words[5156])
            elseif data.role_id == self_role_id then
                self:FireEvent(game.DailyTaskEvent.UpdateExamineTipsText)
            end
        end
    end
end

function DailyTaskCtrl:ResetExamineInfo()
    self.data:ResetExamineInfo()
end

-- 协助答题状态{0, 1}
function DailyTaskCtrl:GetExamineHelpTag(data)
    return self.data:GetExamineHelpTag(data)
end

function DailyTaskCtrl:SetExamineHelpTag(data, tag)
    self.data:SetExamineHelpTag(data, tag)
end

-- 求助按钮状态{0, 1}
function DailyTaskCtrl:GetExamineHelpState(data)
    return self.data:GetExamineHelpState(data)
end

function DailyTaskCtrl:SetExamineHelpState(data, state)
    self.data:SetExamineHelpState(data, state)
end

function DailyTaskCtrl:GetExamineAnswerState()
    return self.data:GetExamineAnswerState()
end

function DailyTaskCtrl:SetExamineAnswerState(state)
    self.data:SetExamineAnswerState(state)
end

function DailyTaskCtrl:GetExamineHelpData(data)
    return self.data:GetExamineHelpData(data)
end

function DailyTaskCtrl:TryAssistExamine(data)
    if data.role_id == game.Scene.instance:GetMainRoleID() then
        game.GameMsgCtrl.instance:PushMsg(config.words[5159])
        return
    elseif data.guild_id ~= game.GuildCtrl.instance:GetGuildId() then
        game.GameMsgCtrl.instance:PushMsg(config.words[5169])
        return
    end

    local tag = self.data:GetExamineHelpTag(data)
    if tag == 1 then
        game.GameMsgCtrl.instance:PushMsg(config.words[5143])
    else
        self:OpenExamineAssistView(data)
    end
end

function DailyTaskCtrl:TryResetExamineHelpState()
    self.data:TryResetExamineHelpState()
end

function DailyTaskCtrl:GetExamineRewardConfig()
    local level = game.RoleCtrl.instance:GetRoleLevel()
    if config.examine_reward[level] then
        return config.examine_reward[level]
    else
        for k, v in pairs(game.Utils.SortByKey(config.examine_reward)) do
            if level <= v.lv then
                return v
            end
        end
    end
end

function DailyTaskCtrl:GetExamineNewTaskNum()
    return self.examine_new_task_num or 0
end

function DailyTaskCtrl:SetExamineNewTaskNum(num)
    self.examine_new_task_num = num
    game.MainUICtrl.instance:SendSetCommonlyKeyValue(game.CommonlyKey.ExamineNewTaskNum, num)
end

function DailyTaskCtrl:GetExamineNewTaskRight()
    return self.examine_new_task_right or 0
end

function DailyTaskCtrl:SetExamineNewTaskRight(right)
    self.examine_new_task_right = right
    game.MainUICtrl.instance:SendSetCommonlyKeyValue(game.CommonlyKey.ExamineNewTaskRight, right)
end

-- 新手指引
function DailyTaskCtrl:SendExamineGuide()
    self:SendProtocal(51515)
end

function DailyTaskCtrl:OnExamineGuide(data)
    self:PrintTable(data)
    self:SetExamineNewTaskNum(data.num)
    self:FireEvent(game.DailyTaskEvent.OnExamineGuide, data.num)
end

function DailyTaskCtrl:OpenRewardShowView(id, level)
    self.reward_show_view:Open(id, level)
end

-- 分金定穴信息
function DailyTaskCtrl:SendTreasureMapInfo()
    self:SendProtocal(51901)
end

function DailyTaskCtrl:OnTreasureMapInfo(data)
    self:PrintTable(data)
    self.data:SetTreasureMapInfo(data)
end

-- 确定坐标点
function DailyTaskCtrl:SendTreasureMapPos()
    self:SendProtocal(51903)
end

function DailyTaskCtrl:OnTreasureMapPos(data)
    self:PrintTable(data)
    self.data:SetTreasureMapPosInfo(self.req_treas_item_id, data)
    self.req_treas_item_id = nil
end

-- 确认使用
function DailyTaskCtrl:SendTreasureMapUse(item_id)
    self:SendProtocal(51905, {item_id = item_id})
end

function DailyTaskCtrl:OnTreasureMapUse(data)
    self:PrintTable(data)
    self.data:SetTreasureMapPosInfo(data.item_id, nil)
    self.data:UpdateTreasureMapInfo(data)

    local event_id = data.event_id
    local event_cfg = self:GetTreasureMapEventConfig()

    local GetGoodsInfo = function(drop_id)
        local client_goods_list = config.drop[drop_id].client_goods_list
        return client_goods_list[1]
    end

    local GetGoodsConfig = function(drop_id)
        return config.goods[GetGoodsInfo(drop_id)[1]]
    end

    local update_tag = false
    
    if event_id == 1 then
        local goods_info = GetGoodsInfo(event_cfg[event_id].info)
        local goods_cfg = config.goods[goods_info[1]]
        local str = goods_cfg.name

        if game.MoneyGoodsId[goods_cfg.id] then
            str = goods_info[2] .. str
        end

        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[5162], str))
        update_tag = true
    elseif event_id == 2 then
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[5163], GetGoodsConfig(event_cfg[event_id].info).name))
        update_tag = true
    elseif event_id == 3 then
        game.GameMsgCtrl.instance:PushMsg(config.words[5164])
        update_tag = true
    elseif event_id == 4 then
        self:OpenTreasureRewardView(2)
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[5165], GetGoodsConfig(event_cfg[event_id].info).name))
        update_tag = true
    elseif event_id == 5 then
        game.GameMsgCtrl.instance:PushMsg(config.words[5166])
    elseif event_id == 6 then
        game.GameMsgCtrl.instance:PushMsg(config.words[5166])
    elseif event_id == 7 then
        self:OpenTreasureRewardView(1)
        game.GameMsgCtrl.instance:PushMsg(config.words[5167])
        update_tag = true
    end

    if update_tag then
        self:SetTreasureMapEventTag(1)
    end
end

function DailyTaskCtrl:GetTreasureMapEventTag()
    return self.data:GetTreasureMapEventTag()
end

function DailyTaskCtrl:SetTreasureMapEventTag(tag)
    self.data:SetTreasureMapEventTag(tag)
end

function DailyTaskCtrl:IsFinishTreasureMapTask()
    local treas_info = self:GetTreasureMapInfo()
    return treas_info.task_times >= config.treasure_map_info.nor_map_times
end

function DailyTaskCtrl:TryNextTreasureMap()
    if not self:IsFinishTreasureMapTask() then
        self:ToFinishTreasureMapTask()
    end
end

-- 接受任务
function DailyTaskCtrl:SendTreasureMapGet()
    self:SendProtocal(51908)
end

function DailyTaskCtrl:OnTreasureMapGet(data)
    self:PrintTable(data)
    self.data:UpdateTreasureMapInfo(data)
end

-- 刷出盗贼
function DailyTaskCtrl:OnTreasureMapRefresh(data)
    self:PrintTable(data)
    if data.is_rare == 0 then
        self.data:UpdateTreasureMapInfo(data, false)
    else
        game.MakeTeamCtrl.instance:DoFollowReset()
        local scene = game.Scene.instance
        local scene_id = scene and scene:GetSceneID()
        local main_role = scene and scene:GetMainRole()
        local x, y = main_role and main_role:GetLogicPosXY()
        if main_role then
            main_role:GetOperateMgr():DoHangMonster(scene_id, nil, 1, x, y, data.mon_id)
        end
    end
end

function DailyTaskCtrl:ClearTreasureMapMonInfo()
    self.data:ClearTreasureMapMonInfo()
end

-- 杀死普通藏宝图盗贼
function DailyTaskCtrl:OnTreasureMaoKill(data)
    if data.type == 1 then
        self.data:ClearTreasureMapMonInfo()
        self:SetTreasureMapEventTag(1)
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then
            main_role:GetOperateMgr():DoHangTaskTreasureMap()
        end
    else
        self.data:UpdateTreasureMapInfo({mon_id = nil})
        local team_ctrl = game.MakeTeamCtrl.instance
        local role_id = game.Scene.instance:GetMainRoleID()
        if team_ctrl:HasTeam() and team_ctrl:IsLeader(role_id) then
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:DoIdle()
            end
            if not team_ctrl:IsTeamFollow() then
                team_ctrl:SendTeamFollow(1)
            end
        end
    end
end

-- 领取藏宝图奖励
function DailyTaskCtrl:SendTreasureMapReward()
    self:SendProtocal(51911)
end

function DailyTaskCtrl:OnTreasureMapReward(data)
    self:PrintTable(data)
    self.data:UpdateTreasureMapInfo(data)
end

function DailyTaskCtrl:UpdateTreasureMapInfo(data)
    self.data:UpdateTreasureMapInfo(data)
end

-- 通知队员
function DailyTaskCtrl:OnTreasureMapEvent(data)
    local event_id = data.event_id

    if event_id == 6 then
        game.GameMsgCtrl.instance:PushMsg(config.words[5166])
    elseif event_id == 7 then
        self:OpenTreasureRewardView(1)
        game.GameMsgCtrl.instance:PushMsg(config.words[5167])
    end
end

function DailyTaskCtrl:CanUseTreasureMap(item_id)
    local cfg_info = config.treasure_map_info
    if game.BagCtrl.instance:GetNumById(item_id) == 0 then
        local goods_name = config.goods[item_id].name
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[1960], goods_name))
        game.ShopCtrl.instance:OpenViewByShopId(3, cfg_info.box_item_id)
        return false, 1
    elseif game.RoleCtrl.instance:GetRoleLevel() < cfg_info.open_lv then
        game.GameMsgCtrl.instance:PushMsg(config.words[1962])
        return false     
    elseif item_id == cfg_info.rare_map_id or item_id == cfg_info.top_map_id then      
        local team_ctrl = game.MakeTeamCtrl.instance
        local rare_need_num = cfg_info.rare_need_num
        local name = config.goods[item_id].name

        if not team_ctrl:HasTeam() or team_ctrl:GetTeamMemberNums() < rare_need_num then
            game.GameMsgCtrl.instance:PushMsg(string.format(config.words[1963], name, rare_need_num))
            return false
        elseif not team_ctrl:IsLeader(game.RoleCtrl.instance:GetRoleId()) then
            game.GameMsgCtrl.instance:PushMsg(string.format(config.words[1966], name))
            return false
        end
    end
    return true
end

function DailyTaskCtrl:DoUseTreasureMap(item_id)
    self:SendTreasureMapUse(item_id)
end

function DailyTaskCtrl:GetTreasureMapPosInfo(item_id)
    return self.data:GetTreasureMapPosInfo(item_id)
end

function DailyTaskCtrl:GetTreasureMapInfo()
    return self.data:GetTreasureMapInfo()
end

function DailyTaskCtrl:RequestTreasureMapPos(item_id)
    if not self.req_treas_item_id then
        self.req_treas_item_id = item_id
        self:SendTreasureMapPos()
    end
end

function DailyTaskCtrl:GetTreasureMapEventConfig()
    local role_level = game.RoleCtrl.instance:GetRoleLevel()
    if config.treasure_map_by_lv[role_level] then
        return config.treasure_map_by_lv[role_level]
    else
        local sort_list = game.Utils.SortByKey(config.treasure_map_by_lv)
        for k, v in ipairs(sort_list) do
            if role_level <= v[1].level then
                return v
            end
        end
    end
end

function DailyTaskCtrl:SendDailyTaskInfo()
    self:SendProtocal(53201)
end

-- 完成一次任务也返回此协议
function DailyTaskCtrl:OnDailyTaskInfo(data)
    self:PrintTable(data)
    self.data:SetDailyTaskInfo(data)

    if not self.daily_task_info_flag then
        self.daily_task_info_flag = true
    else
        self:HangDailyTask()
    end
end

-- 接任务
function DailyTaskCtrl:SendDailyTaskGet()
    self:SendProtocal(53203)
end

function DailyTaskCtrl:OnDailyTaskGet(data)
    self:PrintTable(data)
    self.data:UpdateDailyTaskInfo(data)
    self:HangDailyTask()
end

function DailyTaskCtrl:HangDailyTask()
    local task_id = self:GetDailyTaskInfo().task_id
    if task_id ~= 0 then
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then
            main_role:GetOperateMgr():DoHangTask(task_id)
        end
    end
end

function DailyTaskCtrl:GetDailyTaskTimes()
    return self.data:GetDailyTaskTimes()
end

function DailyTaskCtrl:GetDailyTaskInfo()
    return self.data:GetDailyTaskInfo()
end

function DailyTaskCtrl:IsGuildTaskGather(gather_id)
    local task_info = self:GetGuildTaskInfo()
    if task_info and task_info.flag == 1 then
        local task_type = task_info.type
        if task_type == 1 then
            local task_id = task_info.id
            local task_cfg = config.guild_task[task_type][task_id]
            return gather_id == task_cfg.obj_id
        end
    end
    return false
end

function DailyTaskCtrl:IsPuzzleGamePlayEnd()
    return self.puzzle_game_view:IsPlayEnd()
end

game.DailyTaskCtrl = DailyTaskCtrl

return DailyTaskCtrl