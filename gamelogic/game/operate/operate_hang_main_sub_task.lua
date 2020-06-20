local OperateHangMainSubTask = Class(require("game/operate/operate_base"))

local HangTaskConfig = require("game/task/hang_task_config")
local SpecialTaskConfig = require("game/task/special_task_config")

local TalkCond = {0}

local NoTaskConfig = require("config/config_no_task")

function OperateHangMainSubTask:_init()
    self.oper_type = game.OperateType.HangMainSubTask
end

function OperateHangMainSubTask:Reset()
    --self:FireStopTask()

    self:ClearCurOperate()
    OperateHangMainSubTask.super.Reset(self)
end

function OperateHangMainSubTask:Init(obj, task_id)
	OperateHangMainSubTask.super.Init(self, obj)
	self.cur_task_id = task_id

	self.is_auto_task = true
    self.is_auto_reward = true
	self.task_ctrl = game.TaskCtrl.instance
end

function OperateHangMainSubTask:Start()
    local task_cfg = self.task_ctrl:GetTaskCfg(self.cur_task_id)
    if not task_cfg then
        return false
    end
    
    self.next_task_id = task_cfg.next

    return true
end


function OperateHangMainSubTask:Update(now_time, elapse_time)
    local is_main_task = self.task_ctrl:IsMainTask(self.cur_task_id)
    if is_main_task then
        if game.ViewMgr:HasViewMask() then
            return
        end
    end

    if self.cur_task_id <= 0 then
    	return false,true
    end

    if not self.cur_oper then        
    	if not self.is_auto_task then
    		-- 不自动继续任务
    		return false,true
    	end

        local task_info = self.task_ctrl:GetTaskInfoById(self.cur_task_id)

        if not is_main_task and NoTaskConfig[self.cur_task_id] then
            return
        end
    	
    	local task_cfg = self.task_ctrl:GetTaskCfg(self.cur_task_id)

    	if not task_info then
    		task_info = self.task_ctrl:GetTaskInfoById(self.next_task_id)
    		if task_info then
    			self.cur_task_id = self.next_task_id

                --self:FireStartTask()

    			task_cfg = self.task_ctrl:GetTaskCfg(self.cur_task_id)
    			self.next_task_id = task_cfg.next
    		else
    			return
    		end
    	end

    	if task_info.has_get_reward then
    		return
    	end

    	local task_state = task_info.stat
    	
    	self.is_auto_task = false	
        if self.task_ctrl:IsMainTask(self.cur_task_id) then
            self.is_auto_task = true
        end

        if task_state == game.TaskState.Finished then
            self.is_auto_task = false   
        	local next_task_cfg = self.task_ctrl:GetTaskCfg(self.next_task_id)
        	if next_task_cfg then
        		self.is_auto_task = next_task_cfg.auto_task==1
                self.is_auto_reward = next_task_cfg.auto_reward==1
        	end
        end

        local oper_list = {}
        local conds = nil

        local sp_cfg = SpecialTaskConfig[self.cur_task_id] or SpecialTaskConfig[0]
        if sp_cfg.check_func(task_info, task_cfg) then
            if self.task_ctrl:CheckTaskFinish(self.cur_task_id) and not self.task_ctrl:ShouldTaskFindNpc(self.cur_task_id) then
        		if self.is_auto_reward then
        			-- 任务完成，自动领取奖励
    				self.task_ctrl:SendTaskGetReward(self.cur_task_id)

    				self.cur_task_id = task_cfg.next

                    --self:FireStartTask()

    				local task_cfg = self.task_ctrl:GetTaskCfg(self.cur_task_id)
                    if task_cfg then
            			self.next_task_id = task_cfg.next
        				return
                    else
                        -- 停止任务
                        return false,true
                    end
        			
        			-- 不自动继续任务
        			return false,true
                end
    		end

            if task_state == game.TaskState.Acceptable then
                -- 可接任务
                conds = TalkCond
            else
                conds = self:GetTaskCondType(task_cfg, task_info)
            end
        else
            if task_state == game.TaskState.Acceptable then
                -- 可接任务
                conds = TalkCond
            else
                conds = sp_cfg.oper_func()
            end
        end
        
    	for k,v in ipairs(conds or {}) do
    		local cfg = HangTaskConfig[v]
    		if cfg then
    			local opers = {cfg.oper_func(self, task_cfg, task_info, k)}
                for _,cv in ipairs(opers) do
        			table.insert(oper_list, cv)
                end
    		end
    	end

    	self.cur_oper = self:CreateOperate(game.OperateType.HangSequence, self.obj, oper_list)
        local res,is_stop = self.cur_oper:Start()
        if not res then
            self:ClearCurOperate()
        end

        if is_stop then
            return false,true
        end
    else
    	
    end

    local is_stop = self:UpdateCurOperate(now_time, elapse_time)
    if is_stop then
        return false,true
    end
end

function OperateHangMainSubTask:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret,is_stop = self.cur_oper:Update(now_time, elapse_time)
        if is_stop then
            if self.cur_oper:GetOperateType() == 126 then

                for _,v in ipairs(self.cur_oper._operate_sequence or {}) do
                    print("v:GetOperateType() XXX", v:GetOperateType())
                end
            end
        end
        if ret ~= nil then
            self:ClearCurOperate()            
        end
        return is_stop
    end
end

function OperateHangMainSubTask:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

function OperateHangMainSubTask:OnSaveOper()
	self.obj.scene:SetCrossOperate(self.oper_type, self.cur_task_id)
end

function OperateHangMainSubTask:GetTaskCondType(task_cfg, task_info)
    if #task_cfg.client_action > 0 then
        local conds = {
            task_cfg.client_action[1][1],
        }
        return conds
    end

	if #task_cfg.finish_cond <= 0 then
		return TalkCond
	end

    if task_info.stat == game.TaskState.Finished then
        return TalkCond
    end

	local conds = {}
	for _,v in ipairs(task_cfg.finish_cond) do
		table.insert(conds, v[1])
	end
	return conds
end

function OperateHangMainSubTask:FireStartTask( )
    global.EventMgr:Fire(game.TaskEvent.HangTask, self.cur_task_id, true)
end

function OperateHangMainSubTask:FireStopTask()
    global.EventMgr:Fire(game.TaskEvent.HangTask, nil, false)
end

function OperateHangMainSubTask:GetCurTaskId()
    return self.cur_task_id
end

return OperateHangMainSubTask
