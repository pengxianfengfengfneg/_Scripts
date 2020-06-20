--藏宝图任务
local OperateHangTaskTreasureMap = Class(require("game/operate/operate_base"))

local TaskState = {
    None = 1,
    GetTask = 2,
    DoTask = 3,
    OnGoing = 4,
}

function OperateHangTaskTreasureMap:_init()
    self.oper_type = game.OperateType.HangTaskTreasureMap
end

function OperateHangTaskTreasureMap:Reset()
    self:ClearCurOperate()
    OperateHangTaskTreasureMap.super.Reset(self)
end

function OperateHangTaskTreasureMap:Init(obj)
    OperateHangTaskTreasureMap.super.Init(self, obj)
    self.state = TaskState.None
    return true
end

function OperateHangTaskTreasureMap:Start()
    return true
end

function OperateHangTaskTreasureMap:Update(now_time, elapse_time)
    local treasure_info = game.DailyTaskCtrl.instance:GetTreasureMapInfo()

    if not self.cur_oper then
        if self.state == TaskState.None then
            if treasure_info.is_complete == 1 then
                game.DailyTaskCtrl.instance:SendTreasureMapReward()
                return true,true
            end

            if game.DailyTaskCtrl.instance:IsFinishTreasureMapTask() then
                return true,true
            end

            self.cur_task_id = nil
            if treasure_info.is_trigger == 0 then                
                game.DailyTaskCtrl.instance:SendTreasureMapGet()
                self.state = TaskState.GetTask
            else
                self.state = TaskState.DoTask
            end
        elseif self.state == TaskState.GetTask then
            self.cur_task_id = nil
            if treasure_info.is_trigger == 1 then
                self.state = TaskState.DoTask
            end
        elseif self.state == TaskState.DoTask then
            self.cur_task_id = game.DailyTaskId.TreasureTask
            local item_id = config.treasure_map_info.nor_map_id
            self.cur_oper = self:CreateOperate(game.OperateType.UseTreasureMap, self.obj, item_id)
            if not self.cur_oper:Start() then
                self:ClearCurOperate()
                return false,true
            end
            self.state = TaskState.OnGoing
        end
    end

    self:UpdateCurOperate(now_time, elapse_time)
end

function OperateHangTaskTreasureMap:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
            return ret
        end
    end
end

function OperateHangTaskTreasureMap:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
    self.state = TaskState.None
end

function OperateHangTaskTreasureMap:OnSaveOper()
	self.obj.scene:SetCrossOperate(self.oper_type)
end

function OperateHangTaskTreasureMap:GetCurTaskId()
    return self.cur_task_id
end

return OperateHangTaskTreasureMap
