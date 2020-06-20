--惩凶打图
local OperateHangTaskCxdt = Class(require("game/operate/operate_base"))

local HangState = {
    None = 0,
    GoToNpc = 1,
    HangMonster = 2,
}

function OperateHangTaskCxdt:_init()
    self.oper_type = game.OperateType.HangTaskCxdt
end

function OperateHangTaskCxdt:Reset()
    
    self:ClearCurOperate()
    OperateHangTaskCxdt.super.Reset(self)
end

function OperateHangTaskCxdt:Init(obj)
    OperateHangTaskCxdt.super.Init(self, obj)

    return true
end

function OperateHangTaskCxdt:Start()
    self.target_npc_id = config.activity_hall_ex[1007].npc_id

    self.daily_ctrl = game.DailyTaskCtrl.instance

    self.cur_task_id = game.DailyTaskId.RobberTask

    local make_team_ctrl = game.MakeTeamCtrl.instance
    if make_team_ctrl:IsSelfLeader() then
        make_team_ctrl:SendTeamCommand(game.MakeTeamCommand.Cxdt)
    end

    return true
end

function OperateHangTaskCxdt:Update(now_time, elapse_time)
    self:UpdateCurOperate(now_time, elapse_time)

    local cxdt_data = self.daily_ctrl:GetCxdtData()
    if not cxdt_data then
        self:ClearCurOperate()
        return false,true
    end

    if cxdt_data.mon_id ~= self.mosnter_id or 
        (cxdt_data.scene_id ~= self.scene_id) or
        (cxdt_data.x ~= self.x) or
        (cxdt_data.y ~= self.y) then
        self.cur_task_id = game.DailyTaskId.RobberTask
        self:ClearCurOperate()
    end

    if not self.cur_oper then
        self.scene_id = cxdt_data.scene_id
        self.mosnter_id = cxdt_data.mon_id
        self.x = cxdt_data.x
        self.y = cxdt_data.y
        self.used_times = cxdt_data.times
        self.max_times = cxdt_data.max_times

        if cxdt_data.state <= 0 or cxdt_data.state == 2 then
            -- 寻找Npc
            if game.TaskCtrl.instance:IsOpenNpcDialogView() then
                return
            end
            
            self.cur_oper = self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, self.target_npc_id)
            if not self.cur_oper:Start() then
                self:ClearCurOperate()
                return false,true
            end
            return
        end

        --已经完成任务
        if self.used_times >= self.max_times then
            return false,true
        end

        self.cur_oper = self:CreateOperate(game.OperateType.HangMonster, self.obj, self.scene_id, nil, 1, self.x, self.y, self.mosnter_id)
        if not self.cur_oper:Start() then
            self:ClearCurOperate()
            return false,true
        end
    end
end

function OperateHangTaskCxdt:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangTaskCxdt:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

function OperateHangTaskCxdt:OnSaveOper()
    self.obj.scene:SetCrossOperate(self.oper_type)
end

function OperateHangTaskCxdt:GetCurTaskId()
    return self.cur_task_id
end

return OperateHangTaskCxdt
