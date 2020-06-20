local TaskCtrl = Class(game.BaseCtrl)

local et = {}
local handler = handler
local global_time = global.Time
local event_mgr = global.EventMgr
local config_func = config.func
local config_task = config.task

local TaskClientActionConfig = require("game/task/task_client_action_config")
local TaskUpdateEventConfig = require("game/task/task_update_event_config")

function TaskCtrl:_init()
    if TaskCtrl.instance ~= nil then
        error("TaskCtrl Init Twice!")
    end
    TaskCtrl.instance = self

    self:InitConfig()
    
    self.data = require("game/task/task_data").New()
    self.view = require("game/task/task_view").New(self)

    self.task_detail_view = require("game/task/task_detail_view").New(self)
    self.task_dialog_view = require("game/task/task_dialog_view").New(self)
    self.npc_dialog_view = require("game/task/npc_dialog_view").New(self)
    self.chapter_story_view = require("game/task/chapter_story_view").New(self)

    self.circle_task_item_select_view = require("game/task/circle_task_item_select_view").New(self)
    self.circle_task_wilful_view = require("game/task/circle_task_wilful_view").New(self)
    self.circle_task_help_select_view = require("game/task/circle_task_help_select_view").New(self)

    self:RegisterAllEvents() 
    self:RegisterAllProtocals()

    self.dialog_frame_cache = {}
    self.npc_voice_timestamp = {}
end

function TaskCtrl:_delete()
    self.data:DeleteMe()
    self.view:DeleteMe()

    self.task_detail_view:DeleteMe()
    self.task_dialog_view:DeleteMe()
    self.npc_dialog_view:DeleteMe()
    self.chapter_story_view:DeleteMe()
    self.circle_task_item_select_view:DeleteMe()
    self.circle_task_wilful_view:DeleteMe()
    self.circle_task_help_select_view:DeleteMe()

    TaskCtrl.instance = nil
end


local gather_cond = {
    [12] = {3,2},
    --[40] = {3,3},
    [42] = {3,2},

    --[1007] = {5},
}
local item_cond = {
    [1006] = {4}
}
function TaskCtrl:InitConfig()
    require("game/common/function_config/config_npc_func")

    game.DailyTaskConfig = require("game/task/daily_task_config")

    self.task_gather_config = {}
    self.task_need_items = {}
    for k,v in pairs(config_task) do
        for _,cv in pairs(v) do
            if #cv.finish_cond > 0 then
                for _,ccv in ipairs(cv.finish_cond) do
                    local cond = gather_cond[ccv[1]]
                    if cond then
                        local gather_id = ccv[cond[1]][cond[2]]

                        if not self.task_gather_config[gather_id] then
                            self.task_gather_config[gather_id] = {}
                        end
                        self.task_gather_config[gather_id][k] = gather_id
                    end
                end
            end

            if #cv.client_action > 0 then
                for _,ccv in ipairs(cv.client_action) do
                    local cond = gather_cond[ccv[1]]
                    if cond then
                        local gather_id = ccv[cond[1]]
                        if not self.task_gather_config[gather_id] then
                            self.task_gather_config[gather_id] = {}
                        end
                        self.task_gather_config[gather_id][k] = gather_id
                    end

                    local cond = item_cond[ccv[1]]
                    if cond then
                        local item_id = ccv[cond[1]]
                        if not self.task_need_items[item_id] then
                            self.task_need_items[item_id] = {}
                        end
                        self.task_need_items[item_id][k] = item_id
                    end
                end
            end
        end
    end
end

function TaskCtrl:RegisterAllEvents()
    local events = {
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function TaskCtrl:RegisterAllProtocals()
    self:RegisterProtocalCallback(42302, "OnTaskInfo")
    self:RegisterProtocalCallback(42304, "OnTaskAccept")
    self:RegisterProtocalCallback(42306, "OnTaskFinish")
    self:RegisterProtocalCallback(42308, "OnTaskGetReward")
    self:RegisterProtocalCallback(42309, "OnTaskRefresh")

    -- 跑环
    self:RegisterProtocalCallback(42402, "OnCircleInfo")
    self:RegisterProtocalCallback(42404, "OnCircleAccept")
    self:RegisterProtocalCallback(42406, "OnCircleWilful")
    self:RegisterProtocalCallback(42408, "OnCircleAskForHelp")
    self:RegisterProtocalCallback(42410, "OnCircleHelp")
    self:RegisterProtocalCallback(42412, "OnCircleQuick")

end

function TaskCtrl:OpenView()
    self.view:Open()
end

function TaskCtrl:CloseView()
    self.view:Close()
end

function TaskCtrl:OpenTaskDetailView(task_id)
    self.task_detail_view:Open(task_id)
end

function TaskCtrl:CloseTaskDetailView()
    self.task_detail_view:Close()
end

function TaskCtrl:OpenTaskDialogView(task_id, dialog_id, npc_id)
    self.task_dialog_view:Open(task_id, dialog_id, npc_id)
end

function TaskCtrl:OpenNpcDialogView(npc_id)
    self.npc_dialog_view:Open(npc_id)
end

function TaskCtrl:IsOpenDialogView()
    return self.task_dialog_view:IsOpen()
end

function TaskCtrl:IsOpenNpcDialogView()
    return self.npc_dialog_view:IsOpen()
end

function TaskCtrl:SendTaskInfo()
    local proto = {

    }
    self:SendProtocal(42301, proto)
end

function TaskCtrl:OnTaskInfo(data)
    --[[
        "tasks__T__task@U|CltTask|",
    ]]
    --PrintTable(data)

    self.data:OnTaskInfo(data)

    self:FireEvent(game.TaskEvent.OnUpdateTaskInfo)
end

function TaskCtrl:SendTaskAccept(task_id)
    local proto = {
        id = task_id
    }
    self:SendProtocal(42303, proto)

    --PrintTable(proto)
end

function TaskCtrl:OnTaskAccept(data)
    --[[
        "task__U|CltTask|",
    ]]
    --PrintTable(data)

    self.data:OnTaskAccept(data)
    
    self:FireEvent(game.TaskEvent.OnAcceptTask, data.task.id)

    game.ViewMgr:FireGuideEvent()
end

function TaskCtrl:SendTaskFinish(task_id)
    local proto = {
        id = task_id
    }
    self:SendProtocal(42305, proto)

    --PrintTable(proto)
end

function TaskCtrl:OnTaskFinish(data)
    --[[
        "id__I",
    ]]
    --PrintTable(data)

    self.data:OnTaskFinish(data)
    
    --self:FireEvent(game.TaskEvent.OnFinishTask, data.id)
end

function TaskCtrl:SendTaskGetReward(task_id, grid_id)
    local proto = {
        id = task_id,
        grid = grid_id or 0,
    }
    self:SendProtocal(42307, proto)
    self.data:SendTaskGetReward(task_id)
end

function TaskCtrl:OnTaskGetReward(data)
    --[[
        "id__I",
        grid
    ]]
    --PrintTable(data)

    self.data:OnTaskGetReward(data)
    
    self:FireEvent(game.TaskEvent.OnGetTaskReward, data.id, self:IsMainTask(data.id))

    for i, v in ipairs(config.chapter_story) do
        if v.task_id == data.id then
            self:OpenChapterView(i)
            break
        end
    end
end

function TaskCtrl:OnTaskRefresh(data)
    --[[
        "tasks__T__task@U|CltTask|",
    ]]
    -- --PrintTable(data)
    
    self.data:OnTaskRefresh(data)    

    self:FireEvent(game.TaskEvent.OnUpdateTaskInfo)

    game.ViewMgr:FireGuideEvent()
end

function TaskCtrl:GetTaskInfo()
    return self.data:GetTaskInfo()
end

function TaskCtrl:GetTaskInfoById(task_id)
    return self.data:GetTaskInfoById(task_id)
end

function TaskCtrl:GetTaskInfoByType(task_type)
    return self.data:GetTaskInfoByType(task_type)
end

function TaskCtrl:IsTaskCompleted(task_id)
    return self.data:IsTaskCompleted(task_id)
end

function TaskCtrl:IsAcceptedTask(task_id)
    return self.data:IsAcceptedTask(task_id)
end

function TaskCtrl:IsAcceptableTask(task_id)
    return self.data:IsAcceptableTask(task_id)
end

function TaskCtrl:IsFinishedTask(task_id)
    return self.data:IsFinishedTask(task_id)
end

function TaskCtrl:GetTaskCfg(task_id)
    return self.data:GetTaskCfg(task_id)
end

function TaskCtrl:IsMainTask(task_id)
    return self.data:IsMainTask(task_id)
end

function TaskCtrl:IsBranchTask(task_id)
    return self.data:IsBranchTask(task_id)
end

function TaskCtrl:IsDailyTask(task_id)
    for k,v in pairs(game.DailyTaskId) do
        if v == task_id then
            return true
        end
    end
    return false
end

function TaskCtrl:CheckAutoTask(task_id)
    
end

function TaskCtrl:GetMainTaskInfo()
    return self.data:GetMainTaskInfo()
end

function TaskCtrl:GetTaskRewards(task_id)
    local task_cfg = self:GetTaskCfg(task_id)
    local rewards = {}
    if task_cfg.rewards > 0 then
        local drop_cfg = config.drop[task_cfg.rewards]
        rewards = drop_cfg.client_goods_list 
    else
        if task_cfg.type == game.TaskType.DailyTask then
            local role_lv = game.Scene.instance:GetMainRoleLevel()
            local lv_cfg = config.level[role_lv]
            local daily_task_reward = lv_cfg.daily_task_reward
            local daily_task_times = game.DailyTaskCtrl.instance:GetDailyTaskTimes()
            local times_cfg = daily_task_reward[daily_task_times]
            
            for _,v in ipairs(times_cfg[2]) do
                local money_cfg = config.money_type[v[1]]
                table.insert(rewards,{money_cfg.goods,v[2]})
            end
        end
    end

    return rewards
end

function TaskCtrl:GetTaskNpcFuncs(task_id)
    local task_cfg = self:GetTaskCfg(task_id)
    return task_cfg.npc_func
end

function TaskCtrl:RecordTaskTalk(task_id)
    local task_cfg = self:GetTaskCfg(task_id)
    local role_id = game.Scene.instance:GetMainRoleID()
    local key = string.format("%s_%s_%s", role_id, task_id, task_cfg.talk_id)
    global.UserDefault:SetBool(key, true)
end

function TaskCtrl:HasDoTaskTalk(task_id)
    local task_cfg = self:GetTaskCfg(task_id)
    local talk_id = task_cfg.talk_id
    if talk_id <= 0 then
        return true
    end

    local role_id = game.Scene.instance:GetMainRoleID()
    local key = string.format("%s_%s_%s", role_id, task_id, talk_id)
    return global.UserDefault:GetBool(key, false)
end

function TaskCtrl:IsDoingTask(task_id)
    local task_info = self:GetTaskInfoById(task_id)
    return (task_info~=nil)
end

function TaskCtrl:CheckTaskFinish(task_id)
    local task_info = self:GetTaskInfoById(task_id)
    if not task_info then
        return false
    end
    local task_state = task_info.stat

    if task_state == game.TaskState.Finished then
        local task_cfg = self:GetTaskCfg(task_id)
        
        if task_cfg.talk_id > 0 and (not self:HasDoTaskTalk(task_id)) then
            return false
        end

        if #task_cfg.client_action > 0 then
            local client_action = task_cfg.client_action[1]
            local action_id = client_action[1]
            local action_cfg = self:GetClientActionCfg(action_id)
            if action_cfg and not action_cfg.check_func(client_action) then
                return false
            end
        end

        return true
    end
    return false
end

function TaskCtrl:ShouldTaskFindNpc(task_id)
    local task_cfg = self:GetTaskCfg(task_id)

    if task_cfg == nil then
        return
    end

    if task_cfg.finish_talk > 0 then
        return true
    end

    if task_cfg.talk_id > 0 and (not self:HasDoTaskTalk(task_id)) then
        return true
    end

    if #task_cfg.client_action > 0 then
        return true
    end
    return false
end

function TaskCtrl:GetClientActionConfig()
    return TaskClientActionConfig
end

function TaskCtrl:GetClientActionCfg(action_id)
    return TaskClientActionConfig[action_id]
end

function TaskCtrl:GetTaskUpdateEvent(event_id)
    return TaskUpdateEventConfig[event_id]
end

function TaskCtrl:IsTaskGather(gather_id)
    return self.task_gather_config[gather_id]~=nil
end

function TaskCtrl:CanDoTaskGather(gather_id)
    --炼金小人只能采集金矿
    if game.GuildCtrl.instance:IsTransformAlchemist() then
        return gather_id == config.guild_metall.gather_id
    end

    local task_list = self.task_gather_config[gather_id]
    if not task_list then
        -- 不是任务采集物，返回true
        return true
    end

    for k,v in pairs(task_list) do
        local task_info = self:GetTaskInfoById(k)
        if task_info and task_info.stat==game.TaskState.Accepted then
            return true
        end
    end

    if game.DailyTaskCtrl.instance:IsGuildTaskGather(gather_id) then
        return true
    end
    return false
end

function TaskCtrl:OpenChapterView(id)
    self.chapter_story_view:Open(id)
end

function TaskCtrl:OpenCircleTaskSelectItemView()
    self.circle_task_item_select_view:Open()
end

function TaskCtrl:OpenCircleTaskWilfulView()
    self.circle_task_wilful_view:Open()
end

function TaskCtrl:OpenCircleTaskHelpSelectView(help_info)
    self.circle_task_help_select_view:Open(help_info)
end

function TaskCtrl:CheckDialogFrame(cfg)
    local task_info = self:GetTaskInfoById(cfg.task_id)
    if self.dialog_frame_cache[cfg.id] == nil and task_info ~= nil then
        if (cfg.type == 1 and task_info.stat == 2) or (cfg.type == 2 and task_info.stat == 3) then
            self.dialog_frame_cache[cfg.id] = 1
            return true
        end
    end
    return false
end

function TaskCtrl:IsTaskNeedItem(item_id)
    local task_list = self.task_need_items[item_id]
    if task_list then
        for k,v in pairs(task_list) do
            local task_info = self:GetTaskInfoById(k)
            if task_info and (not self:CheckTaskFinish(k)) then
                return true
            end
        end
    end
    return false
end

-- 跑环
function TaskCtrl:SendCircleInfo()
    local proto = {

    }
    self:SendProtocal(42401, proto)
end

function TaskCtrl:OnCircleInfo(data)
    --[[
        "times__H",
        "quick_item__I",
        "quick_num__C",
        "round_reward__C",
        "wilful_times__T__type@C##times@C",
    ]]
    --PrintTable(data)

    self.data:OnCircleInfo(data)
end

function TaskCtrl:SendCircleAccept()
    local proto = {

    }
    self:SendProtocal(42403, proto)
end

function TaskCtrl:OnCircleAccept(data)
    --[[
        "quick_item__C",
        "quick_num__C",
    ]]
    --PrintTable(data)

    self.data:OnCircleAccept(data)

    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        main_role:GetOperateMgr():DoHangTask(self:GetCircleTaskId())
    end
end

function TaskCtrl:SendCircleWilful(type)
    local proto = {
        type = type
    }
    self:SendProtocal(42405, proto)
end

function TaskCtrl:OnCircleWilful(data)
    --[[
        "wilful_times__T__type@C##times@C",
    ]]
    --PrintTable(data)

    self.data:OnCircleWilful(data)

    self:FireEvent(game.TaskEvent.OnCircleWilful)
end

function TaskCtrl:SendCircleAskForHelp()
    local proto = {

    }
    self:SendProtocal(42407, proto)
end

function TaskCtrl:OnCircleAskForHelp(data)
    --[[
       
    ]]
    --PrintTable(data)
end

function TaskCtrl:SendCircleHelp(role_id, task_id, ref, poses)
    --[[
        "role_id__L",
        "task_id__I",
        "ref__I",
        "poses__T__pos@H##num@H",
    ]]
    local proto = {
        role_id = role_id,
        task_id = task_id,
        ref = ref,
        poses = poses,
    }
    self:SendProtocal(42409, proto)
end

function TaskCtrl:OnCircleHelp(data)
    --[[
        
    ]]
    --PrintTable(data)

    self:FireEvent(game.TaskEvent.OnCircleHelp)
end

function TaskCtrl:SendCircleQuick(poses)
    --[[
        "poses__T__pos@H##num@H",
    ]]
    local proto = {
        poses = poses
    }
    self:SendProtocal(42411, proto)
end

function TaskCtrl:OnCircleQuick(data)
    --PrintTable(data)

    self:FireEvent(game.TaskEvent.OnCircleQuick)
end

function TaskCtrl:GetCircleTaskId()
    return self.data:GetCircleTaskId()
end

function TaskCtrl:GetCircleTaskInfo()
    return self.data:GetCircleTaskInfo()
end

function TaskCtrl:GetCircleTimes()
    return self.data:GetCircleTimes()
end

function TaskCtrl:GetCircleWilfulLeftTimes(type)
    return self.data:GetCircleWilfulLeftTimes(type)
end

local daily_task_max_times = config.sys_config["daily_task_max_times"].value
local TaskTypeName = game.TaskTypeName
local TaskTypeNameFunc = {
    [game.TaskType.DailyTask] = function(task_type, task_name)
        local type_name = TaskTypeName[task_type]

        local daily_task_times = game.DailyTaskCtrl.instance:GetDailyTaskTimes() or 0
        return string.format("%s%s(%s/%s)", type_name, task_name, daily_task_times+1, daily_task_max_times)
    end,
    [game.TaskType.GuildTask] = function(task_type, task_name)
        local type_name = TaskTypeName[task_type]

        local guild_task_info = game.DailyTaskCtrl.instance:GetGuildTaskInfo() or {daily_times=0}
        return string.format("%s%s(%s/%s)", type_name, task_name, guild_task_info.daily_times+1, config.guild_task_info.daily_max_times)
    end,
}

function TaskCtrl:GetTaskShowName(task_type, task_name)
    local name_func = TaskTypeNameFunc[task_type]
    if name_func then
        return name_func(task_type, task_name)
    end
    return TaskTypeName[task_type] .. task_name
end

function TaskCtrl:GetNpcTimestamp(id)
    return self.npc_voice_timestamp[id]
end

function TaskCtrl:SetNpcTimestamp(id)
    self.npc_voice_timestamp[id] = global.Time:GetServerTime()
end

function TaskCtrl:SetDialogNpcId(dialog_npc_id)
    self.dialog_npc_id = dialog_npc_id
end

function TaskCtrl:GetDialogNpcId()
    return self.dialog_npc_id
end

game.TaskCtrl = TaskCtrl

return TaskCtrl
