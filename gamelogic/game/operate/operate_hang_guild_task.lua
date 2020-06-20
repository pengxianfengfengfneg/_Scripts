local OperateHangGuildTask = Class(require("game/operate/operate_base"))

local config_guild_task = config.guild_task

local GuildTaskTypeConfig = {
    [1] = {
        oper_func = function(self, task_cfg)
            -- 收集资源
            local task_scene_info = task_cfg.task_scene_info
            local scene_id = task_scene_info[1]
            local gather_id = task_cfg.obj_id

            local function stop_func()
                return 9999
            end
            local unit_x, unit_y = self:GetGatherPos(scene_id, gather_id)
            return self:CreateOperate(game.OperateType.HangGather, self.obj, gather_id, unit_x, unit_y, scene_id, stop_func)
        end,
    },
    [2] = {
        oper_func = function(self, task_cfg)
            -- 除暴安良
            local task_scene_info = task_cfg.task_scene_info
            local scene_id = task_scene_info[1]

            local monster_id = task_cfg.obj_id
            local kill_num = task_cfg.obj_num

            return self:CreateOperate(game.OperateType.HangMonster, self.obj, scene_id, monster_id, kill_num)
        end,
    },
    [3] = {
        oper_func = function(self, task_cfg)
            -- 拜访名士
            local npc_id = game.DailyTaskCtrl.instance:GetGuildTaskNpcId()
            return self:CreateOperate(game.OperateType.HangGuildTaskVisit, self.obj, npc_id, function()
                game.DailyTaskCtrl.instance:OpenGuildTaskQuestionView()
            end)
        end,
    },
    [4] = {
        oper_func = function(self, task_cfg)
            -- 奇珍异物
            return self:CreateOperate(game.OperateType.HangGuildTaskPet, self.obj, task_cfg.type, task_cfg.id)
        end,
        oper_times = 1,
    },
    [5] = {
        oper_func = function(self, task_cfg)
            -- 稀世之宝
            return self:CreateOperate(game.OperateType.HangGuildTaskTreasure, self.obj, task_cfg.type, task_cfg.id)
        end,
        oper_times = 1,
    },
}

function OperateHangGuildTask:_init()
    self.oper_type = game.OperateType.HangGuildTask
end

function OperateHangGuildTask:Reset()
    self:ClearCurOperate()
    OperateHangGuildTask.super.Reset(self)
end

function OperateHangGuildTask:Init(obj)
    OperateHangGuildTask.super.Init(self, obj)

    return true
end

function OperateHangGuildTask:Start()
    local task_info = game.DailyTaskCtrl.instance:GetGuildTaskInfo()
    self.start_flag = task_info.flag
    self.times = 0
    return true
end

function OperateHangGuildTask:Update(now_time, elapse_time)
    local task_info = game.DailyTaskCtrl.instance:GetGuildTaskInfo()
    if not task_info then
        return false
    end

    if not self.cur_oper and self:CanHangTask(task_info.type) then
        if task_info.flag <= 0 then
            -- 未领取任务
            return false, true
        end

        local task_type = task_info.type
        local task_id = task_info.id

        local cfg = GuildTaskTypeConfig[task_type]
        local task_cfg = config_guild_task[task_type][task_id]

        self.cur_oper = cfg.oper_func(self, task_cfg)
        if not self.cur_oper:Start() then
            self:ClearCurOperate()
            return false, true
        else
            self.times = self.times + 1
        end
    else
        if task_info.flag ~= self.start_flag and task_info.flag==0 then
            -- 任务完成，打开帮会任务界面

            return false, true
        end
    end

    local ret = self:UpdateCurOperate(now_time, elapse_time)
end

function OperateHangGuildTask:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
            return ret
        end
    end
end

function OperateHangGuildTask:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

function OperateHangGuildTask:OnSaveOper()
    self.obj.scene:SetCrossOperate(self.oper_type)
end

function OperateHangGuildTask:CanHangTask(type)
    local times = GuildTaskTypeConfig[type].oper_times
    return not times or self.times < times
end

function OperateHangGuildTask:GetCurTaskId()
    return game.DailyTaskId.GuildTask
end

function OperateHangGuildTask:GetGatherPos(scene_id, gather_id)
    local scene_config_path = string.format("config/editor/scene/%d", scene_id)
    local scene_config = require(scene_config_path)
    package.loaded[scene_config_path] = nil

    local target_x = 0
    local target_y = 0
    local gather_list = scene_config.gather_list
    for _,v in ipairs(gather_list) do
        if v.gather_id == gather_id then
            target_x = v.x
            target_y = v.y
            break
        end
    end
    return target_x, target_y
end

return OperateHangGuildTask
