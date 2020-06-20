local OperateHangTaskDungeon = Class(require("game/operate/operate_base"))

local config_dungeon = config.dungeon
local config_dungeon_lv = config.dungeon_lv

function OperateHangTaskDungeon:_init()
    self.oper_type = game.OperateType.HangTaskDungeon
end

function OperateHangTaskDungeon:Reset()
    
    self:ClearCurOperate()
    OperateHangTaskDungeon.super.Reset(self)
end

function OperateHangTaskDungeon:Init(obj, task_id, dun_id, dun_lv)
    OperateHangTaskDungeon.super.Init(self, obj)

    self.task_id = task_id
    self.dun_id = dun_id
    self.dun_lv = dun_lv

    self.dun_cfg = config_dungeon[self.dun_id]
    self.dun_lv_cfg = config_dungeon_lv[self.dun_id][self.dun_lv]

    self.dun_scene_id = self.dun_lv_cfg.scene_id

    return true
end

function OperateHangTaskDungeon:Start()
    local task_info = game.TaskCtrl.instance:GetTaskInfoById(self.task_id)
    if not task_info then
        return false
    end

    local cur_scene_id = self.obj:GetScene():GetSceneID()
    if cur_scene_id ~= self.dun_scene_id then
        -- 寻找npc
        if self.dun_cfg.npc > 0 and self.dun_lv_cfg.chapter_name ~= "武林悬赏令" then
            self.cur_oper = self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, self.dun_cfg.npc)
            if not self.cur_oper:Start() then
                self:ClearCurOperate()
                return false
            end
        else
            -- 没有Npc直接进入副本
            game.CarbonCtrl.instance:DungEnterReq(self.dun_id, 1)
        end
        return true
    end

    return true
end

function OperateHangTaskDungeon:Update(now_time, elapse_time)
    self:UpdateCurOperate(now_time, elapse_time)    

    if not self.cur_oper then
        self.cur_oper = self:CreateOperate(game.OperateType.HangDungeon, self.obj)
        if not self.cur_oper:Start() then
            self:ClearCurOperate()
            return false
        end
    else
        
    end
end

function OperateHangTaskDungeon:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangTaskDungeon:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateHangTaskDungeon
