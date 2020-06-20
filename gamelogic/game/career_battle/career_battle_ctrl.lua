local CareerBattleCtrl = Class(game.BaseCtrl)

local view_map = {
    lounge_side_info_view = "game/career_battle/career_battle_lounge_side_info_view",
    fight_side_info_view = "game/career_battle/career_battle_fight_side_info_view",

    fight_rank_view = "game/career_battle/career_battle_fight_rank_view",
    fight_rank_reward_view = "game/career_battle/career_battle_fight_rank_reward_view",
    reward_rank_view = "game/career_battle/career_battle_reward_rank_view",
    battle_result_view = "game/career_battle/career_battle_result_view",
}

function CareerBattleCtrl:PrintTable(tbl)
    if self.log_enable then
        PrintTable(tbl)
    end
end

function CareerBattleCtrl:print(...)
    if self.log_enable then
        print(...)
    end
end

function CareerBattleCtrl:_init()
    if CareerBattleCtrl.instance ~= nil then
        error("CareerBattleCtrl Init Twice!")
    end
    CareerBattleCtrl.instance = self

    for view_name, class in pairs(view_map) do
        self[view_name] = require(class).New(self)
        self:CreateViewFunc(view_name)
    end
   
    self.data = require("game/career_battle/career_battle_data").New(self)

    self:RegisterAllProtocal()
    self:RegisterAllEvents()
end

function CareerBattleCtrl:_delete()
    for view_name, class in pairs(view_map) do
        self[view_name]:DeleteMe()
        self[view_name] = nil
    end

    self.data:DeleteMe()
    CareerBattleCtrl.instance = nil
end

function CareerBattleCtrl:CreateViewFunc(view_name)
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
    end
    self[close_func] = function(self, ...)
        if self[view_name] then
            self[view_name]:Close()
        end
    end
end

function CareerBattleCtrl:RegisterAllProtocal()
    local proto = {
        [51202] = "OnCareerBattleEnter",
        [51204] = "OnCareerBattleLeave",
        [51206] = "OnCareerBattleReward",
        [51208] = "OnCareerBattleTop",
        [51212] = "OnCareerBattleLoungeInfo",
        [51214] = "OnCareerBattleRank",
        [51215] = "OnCareerBattleEnterBat",
        [51216] = "OnCareerBattleUpdateHurt",
        [51217] = "OnCareerBattleBatEnd",
        [51219] = "OnCareerBattleLeaveBat",
    }
   for k, v in pairs(proto) do
        self:RegisterProtocalCallback(k, v)
   end
end

function CareerBattleCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginSuccess, handler(self, self.OnLoginSuccess)},   
    }
    for k, v in pairs(events) do   
        self:BindEvent(v[1], v[2])
    end
end

function CareerBattleCtrl:OpenView(...)
    if self:IsGuildMember() then
        self:OpenGuildView(...)
    else
        self:OpenGuildListView(...)
    end
end

function CareerBattleCtrl:GetView(view_name)
    if self[view_name] then
        return self[view_name]
    end
end

function CareerBattleCtrl:IsOpen(view_name)
    if self[view_name] then
        return self[view_name]:IsOpen()
    end
end

function CareerBattleCtrl:CloseView(view_name)
    if self[view_name] then
        return self[view_name]:Close()
    end
end

function CareerBattleCtrl:CloseAllView()
    for view_name, class in pairs(view_map) do
        self:CloseView(view_name)
    end
end

function CareerBattleCtrl:OnLoginSuccess()
    self:SendCareerBattleTop()
end

-- 进入门派竞技
function CareerBattleCtrl:SendCareerBattleEnter()
    self:SendProtocal(51201)
end

-- 离开休息室
function CareerBattleCtrl:SendCareerBattleLeave()
    self:SendProtocal(51203)
end

-- 休息室面板信息
function CareerBattleCtrl:SendCareerBattleLoungeInfo()
    self:SendProtocal(51211)
end

-- 查看排行
function CareerBattleCtrl:SendCareerBattleRank(career, grade)
    self:SendProtocal(51213, {career = career, grade = grade})
end

-- 离开战斗室
function CareerBattleCtrl:SendCareerBattleLeaveBat()
    self:SendProtocal(51218)
end

-- 领取场次奖励
function CareerBattleCtrl:SendCareerBattleReward(times)
    self:SendProtocal(51205, {times = times})
end

function CareerBattleCtrl:OnCareerBattleReward(data)
    self:PrintTable(data)
    self:FireEvent(game.CareerBattleEvent.CareerBattleReward, data.times)
end

function CareerBattleCtrl:OnCareerBattleEnter(data)
    self:PrintTable(data)
end

function CareerBattleCtrl:OnCareerBattleLeave(data)
    self:PrintTable(data)
end

function CareerBattleCtrl:OnCareerBattleLoungeInfo(data)
    self:PrintTable(data)
    self:FireEvent(game.CareerBattleEvent.UpdateLoungeInfo, data)
    self.data:UpdateBattleEndTime(0)
end

function CareerBattleCtrl:OnCareerBattleRank(data)
    self:PrintTable(data)
    self:FireEvent(game.CareerBattleEvent.UpdateBattleRankInfo, data)
end

-- 进入战斗场景
function CareerBattleCtrl:OnCareerBattleEnterBat(data)
    self:PrintTable(data)
    self.data:UpdateBattleEndTime(data.battle_end)
    self:StartBattleStartCounter()
end

-- 更新伤害变化
function CareerBattleCtrl:OnCareerBattleUpdateHurt(data)
    self:PrintTable(data)
    self:FireEvent(game.CareerBattleEvent.BattleUpdateHurt, data)
end

-- 战斗结束
function CareerBattleCtrl:OnCareerBattleBatEnd(data)
    self:PrintTable(data)
    self:FireEvent(game.CareerBattleEvent.BattleEnd, data)
    if game.Scene.instance:IsCareerBattleScene() then
        self:OpenBattleResultView(data)
        self:StartBattleEndCounter(data.leave_time)
    end
end

function CareerBattleCtrl:StartBattleEndCounter(leave_time)
    self:StopBattleEndCounter()

    self.tween_bat_end = DOTween:Sequence()
    self.tween_bat_end:AppendCallback(function()
        local time = math.max(0, leave_time - global.Time:GetServerTime())
        if time == 0 then
            self:StopBattleEndCounter()
        else
            game.GameMsgCtrl.instance:PushMsg(string.format(config.words[4832], time))
        end
    end)
    self.tween_bat_end:AppendInterval(1)
    self.tween_bat_end:SetLoops(-1)
    self.tween_bat_end:Play()
end

function CareerBattleCtrl:StopBattleEndCounter()
    if self.tween_bat_end then
        self.tween_bat_end:Kill(false)
        self.tween_bat_end = nil
    end
end

function CareerBattleCtrl:GetBattleStartTime()
    local prepare_time = config.sys_config.career_battle_forbid_time.value
    return self:GetBattleEndTime() - config.career_battle_info.battle_time + prepare_time
end

function CareerBattleCtrl:StartBattleStartCounter()
    self:StopBattleStartCounter()

    if game.Scene.instance:GetSceneID() ~= config.career_battle_info.battle_scene then
        return
    end

    local start_time = self:GetBattleStartTime()

    self.tween_bat_start = DOTween:Sequence()
    self.tween_bat_start:AppendCallback(function()
        local time = math.max(0, start_time - global.Time:GetServerTime())
        if time == 0 then
            self:StopBattleStartCounter()
        else
            game.GameMsgCtrl.instance:PushMsg(string.format(config.words[4838], time))
        end
    end)
    self.tween_bat_start:AppendInterval(1)
    self.tween_bat_start:SetLoops(-1)
    self.tween_bat_start:Play()
end

function CareerBattleCtrl:StopBattleStartCounter()
    if self.tween_bat_start then
        self.tween_bat_start:Kill(false)
        self.tween_bat_start = nil
    end
end

function CareerBattleCtrl:OnCareerBattleLeaveBat(data)
    self:PrintTable(data)
end

function CareerBattleCtrl:GetGrade()
    local role_level = game.RoleCtrl.instance:GetRoleLevel()
    local config = config.career_battle_info.stage
    for _, v in pairs(config) do
        if role_level >= v[1] and role_level <= v[2] then
            return v[3]
        end
    end
end

function CareerBattleCtrl:GetRankDropId(grade, rank)
    local cfg = config.career_battle_rank[grade]
    for k, v in pairs(cfg) do
        if rank >= v.begin_rank and rank <= v.end_rank then
            return v.drop_id
        end
    end
end

function CareerBattleCtrl:GetBattleEndTime()
    return self.data:GetBattleEndTime()
end

-- 门派大师兄信息
function CareerBattleCtrl:SendCareerBattleTop()
    self:SendProtocal(51207)
end

function CareerBattleCtrl:OnCareerBattleTop(data)
    -- info__T__career@C##grade@H##id@L##name@s
    self:PrintTable(data)
    self.data:SetTopInfo(data.info)
end

function CareerBattleCtrl:GetTopInfo(career, grade)
    return self.data:GetTopInfo(career, grade)
end

function CareerBattleCtrl:GetStatueCareer(npc_id)
    return self.data:GetStatueCareer(npc_id)
end

function CareerBattleCtrl:GetStatueFuncName(npc_id, grade)
    return self.data:GetStatueFuncName(npc_id, grade)
end

function CareerBattleCtrl:ShowStatueInfo(npc_id, grade)
    local career = self:GetStatueCareer(npc_id)
    local top_info = self:GetTopInfo(career, grade)
    if top_info then
        game.ViewOthersCtrl.instance:SendViewOthersInfo(game.GetViewRoleType.ViewOthers, top_info.id)
    else
        game.GameMsgCtrl.instance:PushMsg(config.words[4842])
    end
end

function CareerBattleCtrl:IsStatue(npc_id)
    for k, v in pairs(config.career_battle_info.statue_list or game.EmptyTable) do
        if v == npc_id then
            return true
        end
    end
    return false
end

function CareerBattleCtrl:GetStatueHudInfo(npc_id)
    local count = #config.career_battle_grade
    local career = self:GetStatueCareer(npc_id)
    local top_info = nil
    
    for i=count, 1, -1 do
        top_info = self:GetTopInfo(career, i)
        if top_info then
            break
        end
    end
    if top_info then
        local career_name = config.career_init[career].name
        local txt_format = (top_info.gender==game.Gender.Male) and config.words[4839] or config.words[4840]
        return top_info.name, string.format(txt_format, career_name)
    end
end

function CareerBattleCtrl:GetStatueHeaderName(npc_id)
    local name, tips = self:GetStatueHudInfo(npc_id)
    if name then
        return name
    end
    return ""
end

function CareerBattleCtrl:GetStatueHeaderFuncName(npc_id)
    local name, tips = self:GetStatueHudInfo(npc_id)
    if tips then
        return tips
    end
    return ""
end

game.CareerBattleCtrl = CareerBattleCtrl

return CareerBattleCtrl