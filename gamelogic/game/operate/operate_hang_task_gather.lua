local OperateHangTaskGather = Class(require("game/operate/operate_base"))

function OperateHangTaskGather:_init()
    self.oper_type = game.OperateType.HangTaskGather
end

function OperateHangTaskGather:Reset()
    
    self:ClearCurOperate()
    OperateHangTaskGather.super.Reset(self)
end

function OperateHangTaskGather:Init(obj, task_id, gather_id, scene_id)
    OperateHangTaskGather.super.Init(self, obj)

    self.task_id = task_id
    self.gather_id = gather_id
    self.scene_id = scene_id

    return true
end

function OperateHangTaskGather:Start()
    self.task_ctrl = game.TaskCtrl.instance

    local task_info = self.task_ctrl:GetTaskInfoById(self.task_id)
    if not task_info then
        return false
    end

    local info = task_info.masks[1]
    if info then
        if info.current>=info.total then
            return false
        end
    end

    local scene_config_path = string.format("config/editor/scene/%d", self.scene_id)
    local scene_config = require(scene_config_path)
    package.loaded[scene_config_path] = nil

    self.target_x = 0
    self.target_y = 0
    local gather_list = scene_config.gather_list
    for _,v in ipairs(gather_list) do
        if v.gather_id == self.gather_id then
            self.target_x = v.x
            self.target_y = v.y
        end
    end

    self.stop_func = function()
        return 9999
    end

    return true
end

function OperateHangTaskGather:Update(now_time, elapse_time)
    self:UpdateCurOperate(now_time, elapse_time)

    if not self.cur_oper then
        self.cur_oper = self:CreateOperate(game.OperateType.HangGather, self.obj, self.gather_id, self.target_x, self.target_y, self.scene_id, self.stop_func)
        if not self.cur_oper:Start() then
            self:ClearCurOperate()
            return false
        end
    else
        local task_info = self.task_ctrl:GetTaskInfoById(self.task_id)
        if task_info then
            local info = task_info.masks[1]
            if info then
                if info.current >= info.total then
                    return false
                end
            end
        else
            return false
        end
    end
end

function OperateHangTaskGather:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangTaskGather:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateHangTaskGather
