local Npc = Class(require("game/character/character"))

local _aoi_mgr = global.AoiMgr
local _global_time = global.Time
local _model_type = game.ModelType

local handler = handler
local _event_mgr = global.EventMgr

local config_npc = config.npc
local config_task = config.task
local config_task_dialog = config.task_dialog
local _monster_size = game.MonsterSizeCfg

local ClickNpcObjID = 0


function Npc:_init()
    self.obj_type = game.ObjType.Npc
    self.update_cd = 0.5 + math.random(10) * 0.03

    self.beattack_info = { next_time = 0 }

    self.aoi_mask = game.AoiMask.MainRole
    self.aoi_range = 30
end

function Npc:_delete()
    
end

function Npc:Reset()
    Npc.super.Reset(self)

    if ClickNpcObjID == self:GetObjID() then
        ClickNpcObjID = 0
    end
    
    self:RemoveTaskState()
    
    self.npc_click_callback = nil
    self.aoi_enter_listener = nil
    self.aoi_leave_listener = nil
    self.model_height = nil
end

require("game/common/function_config/config_npc")

function Npc:Init(scene, vo)
    Npc.super.Init(self, scene, vo)

    self.vo = vo
    self.npc_id = vo.npc_id
    self:SetUnitPos(vo.x, vo.y)

    self.npc_click_callback = nil

    self.npc_cfg = config_npc[self.npc_id]
    self.is_rotation = (self.npc_cfg.rotation==0)

    self:ShowShadow(self.npc_cfg.model_id>0)
    self:RefreshName()
    self:RefreshFuncName()
    self:ResetDir()

    self:RegisterAoiWatcher(self.aoi_range, self.aoi_range, game.AoiMask.MainRole)

    self:InitTaskState()
end

function Npc:ResetDir()
    self:SetDirForce(self.vo.dir_x, self.vo.dir_y)
end

function Npc:CheckUpdate(now_time, elapse_time)
    Npc.super.CheckUpdate(self, now_time, elapse_time)

    self:UpdateTalking(now_time, elapse_time)   
end

function Npc:UpdateTalking(now_time, elapse_time)
    if not self.is_rotation then
        return
    end

    if ClickNpcObjID ~= self:GetObjID() then
        return
    end

    local main_role = self.scene:GetMainRole()
    local tx,ty = main_role:GetUnitPosXY()

    local ux,uy = self:GetUnitPosXY()

    local dir_x = tx - ux
    local dir_y = ty - uy

    local lenSQ = (dir_x*dir_x) + (dir_y*dir_y)
    if lenSQ > 6 then        
        self:ResetDir()
        return
    end

    self:SetDirForce(dir_x, dir_y)
end

function Npc:SetDirForce(x, y)
    if x~=self.dir.x or y~=self.dir.y then
        self.dir.x = x
        self.dir.y = y
        self._rot_dirty = false
        self.root_obj.tran:SetLookDir(self.dir.x, 0, self.dir.y)
    end
end

-- aoi
function Npc:SetAoiEnterListener(listener)
    self.aoi_enter_listener = listener
end

function Npc:SetAoiLeaveListener(listener)
	self.aoi_leave_listener = listener
end

function Npc:OnAoiObjEnter(obj_id)
    self:CreateDrawObj()
    self:CheckTaskState()

	if self.aoi_enter_listener then
	    if obj_id ~= self.obj_id then
	        self.aoi_enter_listener(obj_id)
	    end
	end
end

function Npc:OnAoiObjLeave(obj_id)
    if ClickNpcObjID == self:GetObjID() then
        ClickNpcObjID = 0
    end

	if self.aoi_leave_listener then
		if obj_id ~= self.obj_id then
			self.aoi_leave_listener(obj_id)
		end
	end
end

function Npc:CalcDir(y)
    local y = math.rad(y)
    local dir_x = math.cos(y)
    local dir_y = math.sin(math.pi*0.25 -y)
    return dir_x, dir_y
end

-- 外观形象相关
function Npc:CreateDrawObj()
    if self.draw_obj then
        return 
    end

    self.draw_obj = game.GamePool.DrawObjPool:Create()
    self.draw_obj:Init(game.BodyType.Npc)
    self.draw_obj:SetParent(self.root_obj.tran)

    if self.npc_cfg.zoom ~= 1.00 then
        self.draw_obj:SetScale(self.npc_cfg.zoom)
    end

    self.draw_obj:SetModelID(_model_type.Body, self.npc_cfg.model_id)

    self.draw_obj:PlayLayerAnim(_model_type.Body, game.ObjAnimName.Idle)

    if self.npc_cfg.model_id > 0 then
        self:SetClickCallBack(function()
            self:DoClick()
        end, 1)
    else
        self:SetClickCallBack(nil, 0)
    end
end

function Npc:ShowTalk()
    local pre_npc = self.scene:GetObj(ClickNpcObjID)
    if pre_npc then
        pre_npc:ResetDir()
    end

    ClickNpcObjID = self:GetObjID()

    game.TaskCtrl.instance:OpenNpcDialogView(self.npc_cfg.id)
end

function Npc:DoShowTalk()
    local content = self.npc_cfg.talk_content
    if content ~= "" then
        self:DoTalk(content, self.npc_cfg.sound)
    end
end

function Npc:DoTalk(content, sound)
    
end

function Npc:CanBeAttack()
    return false
end

function Npc:ShowTaskTalk(task_id, dialog_id)
    local pre_npc = self.scene:GetObj(ClickNpcObjID)
    if pre_npc then
        pre_npc:ResetDir()
    end

    ClickNpcObjID = self:GetObjID()

    game.TaskCtrl.instance:OpenTaskDialogView(task_id or self.on_task_id, dialog_id or self.on_dialog_id, self:GetNpcId())
end

function Npc:InitTaskState()
    self._ev_list = {
        _event_mgr:Bind(game.TaskEvent.OnUpdateTaskInfo, handler(self, self.OnUpdateTaskInfo)),
        _event_mgr:Bind(game.TaskEvent.OnAcceptTask, handler(self, self.OnAcceptTask)),
        _event_mgr:Bind(game.TaskEvent.OnGetTaskReward, handler(self, self.OnGetTaskReward)),
        _event_mgr:Bind(game.TaskEvent.OnDoneTaskTalk, handler(self, self.OnDoneTaskTalk)),
        
    }

    self.acceptable_task_monitor_list = {}
    self.accepted_task_monitor_list = {}
    self.finish_task_monitor_list = {}

    for k,v in pairs(config_task) do
        for ck,cv in pairs(v) do
            local cfg = config_task_dialog[cv.accept_talk]
            if cfg then
                if cfg[1].npc_id == self.npc_id then
                    self.acceptable_task_monitor_list[k] = cv
                end
            end

            local is_talk_id = false
            local cfg = config_task_dialog[cv.talk_id]
            if cfg then
                if cfg[1].npc_id == self.npc_id then
                    is_talk_id = true
                    self.accepted_task_monitor_list[k] = cv
                end
            end

            local cfg = config_task_dialog[cv.finish_talk]
            if cfg then
                if cfg[1].npc_id == self.npc_id then
                    self.finish_task_monitor_list[k] = cv

                    if not is_talk_id then
                        self.accepted_task_monitor_list[k] = cv
                    end
                end                
            end

            if #cv.client_action > 0 then
                local client_action = cv.client_action[1]
                local npc_id = client_action[3]
                if npc_id == self:GetNpcId() then
                    self.finish_task_monitor_list[k] = cv
                end
            end
        end
    end

    local task_ctrl = game.TaskCtrl.instance
    for k,v in pairs(self.finish_task_monitor_list) do
        if #v.update_event > 0 then
            for _,cv in ipairs(v.update_event) do
                local event_name = task_ctrl:GetTaskUpdateEvent(cv)
                if event_name then
                    table.insert(self._ev_list, _event_mgr:Bind(event_name, handler(self, self.CheckTaskState)))
                end
            end
        end
    end
end

function Npc:CheckTaskState()
    self.on_task_id = nil
    self.on_dialog_id = nil

    local is_show_state = false
    local task_ctrl = game.TaskCtrl.instance
    for k,v in pairs(self.acceptable_task_monitor_list) do
        if task_ctrl:IsAcceptableTask(k) then
            self.on_task_id = k
            self.on_dialog_id = v.accept_talk
            is_show_state = true

            self:SetTaskStateFlag(game.TaskState.Acceptable)
            return
        end
    end   

    for k,v in pairs(self.accepted_task_monitor_list) do
        if task_ctrl:IsAcceptedTask(k) then
            -- self.on_task_id = k
            -- self.on_dialog_id = v.talk_id
            is_show_state = true

            self:SetTaskStateFlag(game.TaskState.Accepted)
            return
        end
    end

    for k,v in pairs(self.finish_task_monitor_list) do
        if task_ctrl:IsFinishedTask(k) then
            if task_ctrl:CheckTaskFinish(k) then
                self.on_task_id = k
                self.on_dialog_id = v.finish_talk
                is_show_state = true

                self:SetTaskStateFlag(game.TaskState.Finished)
            else
                self.on_task_id = k
                self.on_dialog_id = v.talk_id
                is_show_state = true

                self:SetTaskStateFlag(game.TaskState.Accepted)
            end
            return
        end
    end

    if not is_show_state then
        self:SetTaskStateFlag(0)
    end
end

function Npc:RemoveTaskState()
    for _,v in ipairs(self._ev_list or {}) do
        _event_mgr:UnBind(v)
    end
    self._ev_list = nil

    self.acceptable_task_monitor_list = nil
    self.accepted_task_monitor_list = nil
    self.finish_task_monitor_list = nil

    self.on_task_id = nil
    self.on_dialog_id = nil
end

function Npc:OnUpdateTaskInfo()
    self:CheckTaskState()
end

function Npc:OnAcceptTask(task_id)
    if not self.acceptable_task_monitor_list[task_id] then
        return
    end

    self:CheckTaskState()
end

function Npc:OnGetTaskReward(task_id)
    if not self.finish_task_monitor_list[task_id] then
        return
    end

    self:CheckTaskState()
end

function Npc:OnDoneTaskTalk(task_id)
    if (not self.accepted_task_monitor_list[task_id]) and (not self.finish_task_monitor_list[task_id]) then
        return
    end

    self:CheckTaskState()
end

function Npc:GetOnTaskInfo()
    return self.on_task_id,self.on_dialog_id
end

function Npc:GetNpcId()
    return self.npc_id
end

function Npc:SetNpcClickCallback(callback)
    self.npc_click_callback = callback
end

function Npc:DoClick()
    if self.npc_click_callback then
        self.npc_click_callback(self)
        return
    end
    global.EventMgr:Fire(game.SceneEvent.ClickNpc, self.npc_id, self:GetUnitPosXY())
end

function Npc:SetTaskStateFlag(state)
    if state == game.TaskState.Acceptable then
        self:SetHudImg(game.HudItem.Title, "rw4")
        return
    end
    
    if state == game.TaskState.Accepted then
        self:SetHudImg(game.HudItem.Title, "rw3")
        return
    end

    if state == game.TaskState.Finished then
        self:SetHudImg(game.HudItem.Title, "rw2")
        return
    end

    self:SetHudItemVisible(game.HudItem.Title, false)
end

function Npc:GetModelHeight()
    if self.model_height == nil then
        local cfg = config_npc[self.npc_id]
        local model_id = cfg.model_id
        if cfg.model_height == 0 then
            if _monster_size[model_id] then
                self.model_height = _monster_size[model_id][2] * cfg.zoom + 0.3
            else
                self.model_height = 2
            end
        else
            self.model_height = cfg.model_height * cfg.zoom
        end
    end
    return self.model_height
end

function Npc:RefreshName()
    if self.npc_cfg.name_func then
        self:SetHudText(game.HudItem.Name, self.npc_cfg.name_func(), 3)
    else
        self:SetHudText(game.HudItem.Name, self.npc_cfg.name, 3)
    end
end

function Npc:RefreshFuncName()
    local func_name = nil
    if self.npc_cfg.tips_func then
        func_name = self.npc_cfg.tips_func()
    else
        func_name = self.npc_cfg.func_name
    end
    self:SetHudText(game.HudItem.Tips, func_name, 7)
end

return Npc
