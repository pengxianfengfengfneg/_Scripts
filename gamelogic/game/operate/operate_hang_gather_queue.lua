local OperateHangGatherQueue = Class(require("game/operate/operate_base"))

local pDistanceSQ = cc.pDistanceSQ

local GatherState = {
    FindWay = 1,
    Gather = 2,
}

local DefaultStopFunc = function()
    return 0
end

function OperateHangGatherQueue:_init()
    self.oper_type = game.OperateType.HangGatherQueue
end

function OperateHangGatherQueue:Init(obj, gather_id, scene_id, stop_func)
    OperateHangGatherQueue.super.Init(self, obj)
    self.gather_id = gather_id
    self.scene_id = scene_id
    self.stop_func = stop_func or DefaultStopFunc
    self.next_gather_time = 0
end

function OperateHangGatherQueue:Reset()
    self:ClearCurOperate()
    OperateHangGatherQueue.super.Reset(self)
end

function OperateHangGatherQueue:Start()  
    if self.scene_id then 
        local cur_scene_id = game.Scene.instance:GetSceneID()
        if cur_scene_id ~= self.scene_id then
            self.cur_oper = self:CreateOperate(game.OperateType.ChangeScene, self.obj, self.scene_id)
            if not self.cur_oper:Start() then
                self:ClearCurOperate()
            end
            return true
        end
    end

    local scene_config_path = string.format("config/editor/scene/%d", self.scene_id)
    local scene_config = require(scene_config_path)
    package.loaded[scene_config_path] = nil

    self.gather_list = {}
    for _,v in pairs(scene_config.gather_list or {}) do
        if v.gather_id == self.gather_id then
            table.insert(self.gather_list, v)
        end
    end

    if #self.gather_list <= 0 then
        return false
    end

    self.gather_obj_fliter = function(obj)
        if obj:GetGatherId() == self.gather_id then         
            return true
        end
        return false
    end

    self.is_stop_gather = false
    self.state = nil
    self.target_gather = nil
    return true
end

function OperateHangGatherQueue:Update(now_time, elapse_time)
    if not self.obj then
        return
    end

    if not self.cur_oper then
        if not self.obj:CanDoGather() or self.scene_id ~= self.obj.scene:GetSceneID() then
            return
        end

        if now_time >= self.next_gather_time then
            if self.state ~= GatherState.FindWay then
                if #self.gather_list == 0 then
                    return false
                end

                local gather_idx = math.random(1, #self.gather_list)
                local gather = self.gather_list[gather_idx]

                self.cur_oper = self:CreateOperate(game.OperateType.FindWay, self.obj, gather.x, gather.y, 2)
                if not self.cur_oper:Start() then
                    self:ClearCurOperate()
                    return false
                end
                self.state = GatherState.FindWay
                self.target_gather = gather

                table.remove(self.gather_list, gather_idx)
            else
                local gather_list = self.obj.scene:GetObjByType(game.ObjType.Gather, self.gather_obj_fliter)
                if #gather_list > 0 and self.target_gather then
                    local gather = self:GetTargetGather(gather_list)

                    self.cur_oper = self:CreateOperate(game.OperateType.GoToGather, self.obj, gather.obj_id, 2)
                    if not self.cur_oper:Start() then
                        self:ClearCurOperate()
                        return false
                    end
                    self.state = GatherState.Gather
                else
                    return false
                end
            end
        end
    end

    self:UpdateCurOperate(now_time, elapse_time)

    if self.is_stop_gather then
        -- 采集足够，停止
        if self.gather_callback then
            self.gather_callback(self.gather_id)
        end
        return false
    end
end

function OperateHangGatherQueue:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            local num = self.stop_func()
            self.next_gather_time = now_time + 0.1
            self:ClearCurOperate()

            self.is_stop_gather = num <= 0
        end
    end
end

function OperateHangGatherQueue:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

function OperateHangGatherQueue:OnSaveOper()
    self.obj.scene:SetCrossOperate(self.oper_type, self.gather_id, self.scene_id, self.stop_func)
end

function OperateHangGatherQueue:GetTargetGather(gather_list)
    local tar_x, tar_y = game.UnitToLogicPos(self.target_gather.x, self.target_gather.y)
    local gather = gather_list[1]

    for k, v in ipairs(gather_list) do
        local logic_x, logic_y = v:GetLogicPosXY()
        if logic_x == tar_x and logic_y == tar_y then
            gather = v
            break
        end
    end

    return gather
end

return OperateHangGatherQueue
