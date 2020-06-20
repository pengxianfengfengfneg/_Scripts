--马贼任务
local OperateHangTaskThief = Class(require("game/operate/operate_base"))

local TaskState = {
    None = 0,
    WaitTeamMember = 1,
    Follow = 2,
}

local NpcPos = {
    x = 0,
    y = 0,
}

local near_time_delta = 2.5
local error_time_delta = 2.5

function OperateHangTaskThief:_init()
    self.oper_type = game.OperateType.HangTaskThief
end

function OperateHangTaskThief:Reset()
    self:ClearCurOperate()
    OperateHangTaskThief.super.Reset(self)
    game.MakeTeamCtrl.instance:SetFollowPause(false)
end

function OperateHangTaskThief:Init(obj)
    OperateHangTaskThief.super.Init(self, obj)
    return true
end

function OperateHangTaskThief:Start()
    self.task_state = TaskState.None
    self.next_near_time = 0
    self.next_error_time = 0

    local thief_info = game.DailyTaskCtrl.instance:GetThiefInfo()
    if thief_info.state == 0 then
        return false
    end
    
    local make_team_ctrl = game.MakeTeamCtrl.instance
    if make_team_ctrl:IsSelfLeader() then
        game.MakeTeamCtrl.instance:SendTeamFollow(1)
        make_team_ctrl:SendTeamCommand(game.MakeTeamCommand.Dbmz)
    end
    
    return true
end

function OperateHangTaskThief:Update(now_time, elapse_time)
    self:UpdateCurOperate(now_time, elapse_time)

    local thief_info = game.DailyTaskCtrl.instance:GetThiefInfo()
    if thief_info.state == 0 then
        return false
    end

    local is_leader = game.MakeTeamCtrl.instance:IsLeader(game.RoleCtrl.instance:GetRoleId())
    local main_role = game.Scene.instance:GetMainRole()

    if not main_role then
        return false
    end

    if self.task_state == TaskState.WaitTeamMember then
        if thief_info.state ~= 1 then
            return false
        end

        if self:CheckTeamMemberPos() then
            self:SendDailyThiefNear(now_time)
        else
            if not self.next_error_time or now_time >= self.next_error_time then
                game.GameMsgCtrl.instance:PushMsg(config.words[1970])
                self.next_error_time = now_time + error_time_delta
            end
        end
    elseif not self.cur_oper then
        local horse_data = thief_info.horse_data
        if horse_data and horse_data.target_id then
            game.MakeTeamCtrl.instance:SetFollowPause(true)
            self.cur_oper = self:CreateOperate(game.OperateType.HangMonster, self.obj, horse_data.scene_id, nil, 1, horse_data.x, horse_data.y, horse_data.target_id)

            if not self.cur_oper:Start() then
                self:ClearCurOperate()
            end
            self.task_state = TaskState.None
        elseif thief_info.state == 1 then
            if is_leader then
                local npc_id = thief_info.npc_id

                self.cur_oper = self:CreateOperate(game.OperateType.GoToNpc, self.obj, npc_id, function()
                    local npc = game.Scene.instance:GetNpc(npc_id)
                    NpcPos = npc:GetLogicPos()
                    self.task_state = TaskState.WaitTeamMember
                end,1)           
                if not self.cur_oper:Start() then
                    self:ClearCurOperate()
                end
            else
                if self.task_state ~= TaskState.Follow then
                    game.MakeTeamCtrl.instance:SetFollowPause(false)
                    self.task_state = TaskState.Follow
                end
            end
        elseif thief_info.state == 2 then
            local npc_id = thief_info.npc_id
            local npc_pos = self:GetNpcLogicPos(npc_id)
            local scene_id = config.npc[npc_id].scene

            game.MakeTeamCtrl.instance:SetFollowPause(true)
            self.cur_oper = self:CreateOperate(game.OperateType.HangMonster, self.obj, scene_id, nil, 1, npc_pos.x, npc_pos.y, thief_info.target_id)
            if not self.cur_oper:Start() then
                self:ClearCurOperate()
            end
            self.task_state = TaskState.None
        elseif thief_info.state == 3 then
            if is_leader then
                local task_npc = config.daily_thief.task_npc
                local scene_id = task_npc[1]
                local ux, uy = game.LogicToUnitPos(task_npc[2], task_npc[3])

                self.cur_oper = self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, task_npc[4], function()
                    game.DailyTaskCtrl.instance:SendDailyThiefHandleTask()
                end,2)
                if not self.cur_oper:Start() then
                    self:ClearCurOperate()
                end
            else
                if self.task_state ~= TaskState.Follow then
                    game.MakeTeamCtrl.instance:SetFollowPause(false)
                    self.task_state = TaskState.Follow
                end
            end
        end
    end
end

function OperateHangTaskThief:CheckTeamMemberPos()
    local team_members = game.MakeTeamCtrl.instance:GetTeamMembers()
    local dist = config.sys_config.team_near_by_distance.value * 0.9

    for k, v in pairs(team_members) do
        local member = v.member
        local role = game.Scene.instance:GetObjByUniqID(member.id)
        if not role or cc.pDistanceSQ(role:GetLogicPos(), NpcPos) > dist * dist then
            return false
        end
    end

    return true
end

function OperateHangTaskThief:SendDailyThiefNear(now_time)
    if not self.next_near_time or now_time >= self.next_near_time then
        game.DailyTaskCtrl.instance:SendDailyThiefNear()
        self.next_near_time = now_time + near_time_delta
    end
end

function OperateHangTaskThief:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangTaskThief:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

function OperateHangTaskThief:OnSaveOper()
	self.obj.scene:SetCrossOperate(self.oper_type)
end

function OperateHangTaskThief:GetNpcLogicPos(npc_id)
    local pos = {x=0, y=0}
    local npc_cfg = config.npc[npc_id]

    local cur_scene = game.Scene.instance
    local npc = cur_scene:GetNpc(self.npc_id)
    if npc then
        pos.x, pos.y = npc:GetLogicPosXY()
    else
        local scene_id = npc_cfg.scene
        local scene_config_path = string.format("config/editor/scene/%d", scene_id)
        local scene_config = require(scene_config_path)
        package.loaded[scene_config_path] = nil

        local npc_list = scene_config.npc_list or game.EmptyTable
        for _,v in ipairs(npc_list) do
            if v.npc_id == npc_id then
                pos.x = v.x
                pos.y = v.y
                break
            end
        end
        pos.x, pos.y = game.UnitToLogicPos(pos.x, pos.y)
    end

    return pos
end

function OperateHangTaskThief:GetCurTaskId()
	return game.DailyTaskId.BanditTask
end

return OperateHangTaskThief
