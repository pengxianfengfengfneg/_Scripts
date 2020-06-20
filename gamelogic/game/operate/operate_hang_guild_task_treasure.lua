local OperateHangGuildTaskTreasure = Class(require("game/operate/operate_base"))

function OperateHangGuildTaskTreasure:_init()
    self.oper_type = game.OperateType.HangGuildTaskTreasure
end

function OperateHangGuildTaskTreasure:Init(obj, task_type, task_id)
    OperateHangGuildTaskTreasure.super.Init(self, obj)

    self.task_type = task_type
    self.task_id = task_id
    self.task_cfg = config.guild_task[task_type][task_id]

    return true
end

function OperateHangGuildTaskTreasure:Reset()
    self:ClearCurOperate()
    
    OperateHangGuildTaskTreasure.super.Reset(self)
end

function OperateHangGuildTaskTreasure:Start()
    if game.BagCtrl.instance:GetNumById(self.task_cfg.obj_id) == 0 then
        game.MarketCtrl.instance:OpenBuyViewByItemId(self.task_cfg.obj_id)
    end
    return true
end

function OperateHangGuildTaskTreasure:Update(now_time, elapse_time)
    local ret = self:UpdateCurOperate(now_time, elapse_time)
    if ret ~= nil then
        return false
    end
    
    local task_info = game.DailyTaskCtrl.instance:GetGuildTaskInfo()
    if task_info.flag <= 0 then
        return false
    end

    if not self.cur_oper then
        if game.BagCtrl.instance:GetNumById(self.task_cfg.obj_id) > 0 and not game.MarketCtrl.instance:IsOpenView() then
            local npc_id = game.DailyTaskCtrl.instance:GetGuildTaskNpcId()
            self.cur_oper = self:CreateOperate(game.OperateType.GoToNpc, self.obj, npc_id, function()
                game.DailyTaskCtrl.instance:OpenTaskItemSelectView(self.task_cfg)
            end)
            if not self.cur_oper:Start() then
                self:ClearCurOperate()
            end
        end
    end
end

function OperateHangGuildTaskTreasure:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
            return ret
        end
    end
end

function OperateHangGuildTaskTreasure:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateHangGuildTaskTreasure
