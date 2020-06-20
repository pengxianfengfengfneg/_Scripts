local OperateMgr = Class()

require("game/operate/operate_pool")
local _oper_type = game.OperateType
local _oper_pool = game.OperatePool

function OperateMgr:_init(obj)
    self.is_enable = true
    self.is_pause = false
    self.is_team_pause = false

    self.obj = obj
    self.update_cd = 0.01
    self.next_update_time = 0

    self.default_oper = nil
    self.default_oper_time = 0
end

function OperateMgr:_delete()
    if self.cur_oper and self.obj:IsMainRole() then
        self.cur_oper:OnSaveOper()
    end
    self:ClearOperate()
end

function OperateMgr:SetPause(val)
    self.is_pause = val
end

function OperateMgr:SetEnable(val)
    self.is_enable = val
end

function OperateMgr:SetTeamPause(val)
    self.is_team_pause = val
end

function OperateMgr:SetUpdateCD(val)
    self.update_cd = val
end

function OperateMgr:Update(now_time, elapse_time)
    if self.is_pause then
        return
    end

    if now_time > self.next_update_time then
        self.next_update_time = now_time + self.update_cd
        if self.cur_oper then
            local ret = self.cur_oper:Update(now_time, elapse_time)
            if ret ~= nil then
                self:ClearOperate()
            end
        else
            if self.default_oper and now_time > self.default_oper_time then
                self:DoOperate(self:CreateOperate(self.default_oper, self.obj))
            end
        end
    end
end

function OperateMgr:GetCurOperate()
    return self.cur_oper
end

function OperateMgr:DoOperate(oper, is_force)
    if (self.is_enable and (not self.is_team_pause)) or is_force then
        if oper:Start() then
            self:ClearOperate()
            self.cur_oper = oper
            self.cur_oper:OnStart()

            return self.cur_oper
        else
            oper:DeleteMe()
        end
    else
        oper:DeleteMe()
    end
end

function OperateMgr:DoOperateByType(oper_type, ...)
   self:DoOperate(self:CreateOperate(oper_type, self.obj, ...))
end

function OperateMgr:ClearOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
        self.default_oper_time = global.Time.now_time + 3
    end
end

function OperateMgr:DoStop(keep_stop)
   self:DoOperate(self:CreateOperate(_oper_type.Stop, self.obj, keep_stop))
end

function OperateMgr:DoMove(x, y, keep_move)
   self:DoOperate(self:CreateOperate(_oper_type.Move, self.obj, x, y, keep_move))
end

function OperateMgr:DoFindWay(x, y, offset_dist, callback, keep_move, is_force, not_effect)
   return self:DoOperate(self:CreateOperate(_oper_type.FindWay, self.obj, x, y, offset_dist, callback, keep_move, not_effect), is_force)
end

function OperateMgr:DoAttackTarget(target_id, active_skill)
    self:DoOperate(self:CreateOperate(_oper_type.AttackTarget, self.obj, target_id, active_skill))
end

function OperateMgr:DoHang()
    self:DoOperate(self:CreateOperate(_oper_type.Hang, self.obj))
end

function OperateMgr:DoHangStay()
   self:DoOperate(self:CreateOperate(_oper_type.HangStay, self.obj)) 
end

function OperateMgr:DoFollow(owner_id, dist)
    self:DoOperate(self:CreateOperate(_oper_type.Follow, self.obj, owner_id, dist))
end

function OperateMgr:DoTeamAssist()
    self:DoOperate(self:CreateOperate(_oper_type.TeamAssist, self.obj, owner_id))
end

function OperateMgr:DoTalkToNpc(task_id, dialog_id)
    self:DoOperate(self:CreateOperate(_oper_type.TalkToNpc, self.obj, task_id, dialog_id))
end

function OperateMgr:DoGoToNpc(npc_id, callback)
    self:DoOperate(self:CreateOperate(_oper_type.GoToNpc, self.obj, npc_id, callback))
end

function OperateMgr:DoGoToTalkNpc(npc_id, callback)
    self:DoOperate(self:CreateOperate(_oper_type.GoToTalkNpc, self.obj, npc_id, callback))
end

function OperateMgr:DoKillMonster(monster_id, kill_num)
    self:DoOperate(self:CreateOperate(_oper_type.KillMonster, self.obj, monster_id, kill_num))
end

function OperateMgr:DoHangMonster(scene_id, monster_id, kill_num, x, y, uniq_id)
    self:DoOperate(self:CreateOperate(_oper_type.HangMonster, self.obj, scene_id, monster_id, kill_num, x, y, uniq_id))
end

function OperateMgr:DoHangSequence(operate_list)
    self:DoOperate(self:CreateOperate(_oper_type.HangSequence, operate_list))
end

function OperateMgr:DoClickNpc(npc_id)
    self:DoOperate(self:CreateOperate(_oper_type.ClickNpc, self.obj, npc_id))
end

function OperateMgr:DoGather(obj_id)
    self:DoOperate(self:CreateOperate(_oper_type.Gather, self.obj, obj_id))
end

function OperateMgr:DoGoToGather(obj_id, gather_dist)
    self:DoOperate(self:CreateOperate(_oper_type.GoToGather, self.obj, obj_id, gather_dist))
end

function OperateMgr:DoHangGather(gather_id, x, y, scene_id, stop_func, callback, obj_id)
    self:DoOperate(self:CreateOperate(_oper_type.HangGather, self.obj, gather_id, x, y, scene_id, stop_func, callback, obj_id))
end

function OperateMgr:DoHangTask(task_id)
    self:DoOperate(self:CreateOperate(_oper_type.HangTask, self.obj, task_id))
end

function OperateMgr:DoHangGuildCarry()
    self:DoOperate(self:CreateOperate(_oper_type.HangGuildCarry, self.obj))
end

function OperateMgr:DoJoystick(x, y)
    self:DoOperate(self:CreateOperate(_oper_type.Joystick, self.obj, x, y))
end

function OperateMgr:DoJoystickAttack(skill_id)
    self:DoOperate(self:CreateOperate(_oper_type.JoystickAttack, self.obj, skill_id))
end

function OperateMgr:DoHangJoystick(x, y)
    self:DoOperate(self:CreateOperate(_oper_type.HangJoystick, self.obj, x, y))
end

function OperateMgr:DoHangPet()
    self:DoOperate(self:CreateOperate(_oper_type.HangPet, self.obj))
end

function OperateMgr:SetDefaultOper(oper_type)
    self.default_oper = oper_type
end

function OperateMgr:DoSceneHang()
    local oper_type = self.obj.scene.scene_logic:GetHangOperate()
    if oper_type then
        self:DoOperate(self:CreateOperate(oper_type, self.obj))
    end
end

function OperateMgr:DoMakeTeamFollow()
    self:DoOperate(self:CreateOperate(_oper_type.MakeTeamFollow, self.obj))
end

function OperateMgr:DoHangMakeTeamFollow()
    self:DoOperate(self:CreateOperate(_oper_type.HangMakeTeamFollow, self.obj))
end

function OperateMgr:DoGoToScenePos(scene_id, x, y, callback, offset)
    self:DoOperate(self:CreateOperate(_oper_type.GoToScenePos, self.obj, scene_id, x, y, callback, offset))
end

function OperateMgr:DoPractice()
    self:DoOperate(self:CreateOperate(_oper_type.Practice, self.obj))
end

function OperateMgr:DoCarry()
    self:DoOperate(self:CreateOperate(_oper_type.Carry, self.obj))
end

function OperateMgr:DoHangCatchPet(gather_id, monster_id, callback)
    self:DoOperate(self:CreateOperate(_oper_type.HangCatchPet, self.obj, gather_id, monster_id, callback))
end

function OperateMgr:DoChangeScene(scene_id, line_id, is_follow)
    self:DoOperate(self:CreateOperate(_oper_type.ChangeScene, self.obj, scene_id, line_id, is_follow))
end

function OperateMgr:DoHangGuildTask()
    self:DoOperate(self:CreateOperate(_oper_type.HangGuildTask, self.obj))
end

function OperateMgr:DoHangTaskTreasureMap()
    self:DoOperate(self:CreateOperate(_oper_type.HangTaskTreasureMap, self.obj))
end

function OperateMgr:DoUseTreasureMap(item_id)
    self:DoOperate(self:CreateOperate(_oper_type.UseTreasureMap, self.obj, item_id))
end

function OperateMgr:DoHangTaskCxdt()
    self:DoOperate(self:CreateOperate(_oper_type.HangTaskCxdt, self.obj))
end

function OperateMgr:DoGoToMonsterPos(scene_id, monster_id)
    self:DoOperate(self:CreateOperate(_oper_type.GotoMonsterPos, self.obj, scene_id, monster_id))
end

function OperateMgr:DoJump(x, y, fx, fy, mid_list)
    self:DoOperate(self:CreateOperate(_oper_type.Jump, self.obj, x, y, fx, fy, mid_list))
end

function OperateMgr:DoHangGatherQueue(gather_id, scene_id, stop_func)
    self:DoOperate(self:CreateOperate(_oper_type.HangGatherQueue, self.obj, gather_id, scene_id, stop_func))
end

function OperateMgr:DoHangTaskGatherQueue(task_id, gather_id, scene_id)
    self:DoOperate(self:CreateOperate(_oper_type.HangTaskGatherQueue, self.obj, task_id, gather_id, scene_id))
end

function OperateMgr:DoHangTaskThief()
    self:DoOperate(self:CreateOperate(_oper_type.HangTaskThief, self.obj))
end

function OperateMgr:DoHangDailyTask()
    self:DoOperate(self:CreateOperate(_oper_type.HangDailyTask, self.obj))
end

function OperateMgr:DoFollow(target_id, offset)
    self:DoOperate(self:CreateOperate(_oper_type.Follow, self.obj, target_id, offset))
end

-- pool
function OperateMgr:CreateOperate(oper_type, ...)
    return _oper_pool:CreateOperate(oper_type, ...)
end

function OperateMgr:FreeOperate(oper)
    _oper_pool:FreeOperate(oper)
end

function OperateMgr:GetOperPool()
    return _oper_pool
end

function OperateMgr:IsOnTeamFollow()
    if self.cur_oper and self.cur_oper:GetOperateType()==_oper_type.MakeTeamFollow then
        return true
    end
    return false
end

game.OperateMgr = OperateMgr

return OperateMgr
