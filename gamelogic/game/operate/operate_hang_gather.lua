local OperateHangGather = Class(require("game/operate/operate_base"))

local DefaultStopFunc = function()
    return 0
end

function OperateHangGather:_init()
    self.oper_type = game.OperateType.HangGather
end

function OperateHangGather:Init(obj, gather_id, x, y, scene_id, stop_func, callback, obj_id)
    OperateHangGather.super.Init(self, obj)
    self.gather_id = gather_id
    self.target_scene_id = scene_id

    self.target_x = x
    self.target_y = y

    self.gather_stop_func = stop_func or DefaultStopFunc

    self.gather_callback = callback

    self.gather_obj_id = obj_id

    self.next_gather_time = 0
end

function OperateHangGather:Reset()
    self:ClearCurOperate()
    OperateHangGather.super.Reset(self)
    self.is_stop_gather = false
end

function OperateHangGather:Start()  
    if self.target_scene_id then 
        local cur_scene_id = game.Scene.instance:GetSceneID()
        if cur_scene_id ~= self.target_scene_id then
            self.cur_oper = self:CreateOperate(game.OperateType.ChangeScene, self.obj, self.target_scene_id)
            if not self.cur_oper:Start() then
                self:ClearCurOperate()
            end

            return true
        end
    end

    self.gather_fliter_func = function(gather)
        return (gather:GetGatherId()==self.gather_id)
    end

    return true
end

function OperateHangGather:Update(now_time, elapse_time)
    if not self.cur_oper then
        if self.obj == nil then
            return
        end

        if not self.obj:CanDoGather() then
            return
        end
        
        local cur_scene = self.obj:GetScene()
        local gather_obj_list = cur_scene:GetObjByType(game.ObjType.Gather, self.gather_fliter_func)
        local gather_obj_num = #gather_obj_list
        if gather_obj_num > 0 then
            if now_time >= self.next_gather_time then
                local gather_obj = self.obj.scene:GetObj(self.gather_obj_id)
                if not gather_obj then
                    local len = 1000000
                    local logic_pos = self.obj:GetLogicPos()
                    for _,v in ipairs(gather_obj_list) do
                        local x,y = v:GetLogicPosXY()
                        local len_sq = (logic_pos.x-x)*(logic_pos.x-x) + (logic_pos.y-y)*(logic_pos.y-y)
                        if len_sq < len then
                            len = len_sq
                            gather_obj = v
                        end
                    end
                end
                self.cur_oper = self:CreateOperate(game.OperateType.GoToGather, self.obj, gather_obj.obj_id, 2)
                if not self.cur_oper:Start() then
                    self:ClearCurOperate()
                end
            end
        else
            self:RandomSearch()
        end
    else
        
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

function OperateHangGather:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local type = self.cur_oper:GetOperateType()
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            local num = 1
            if type == game.OperateType.GoToGather then
                num = self.gather_stop_func()
                self.next_gather_time = now_time + 0.15
            end
            self:ClearCurOperate()

            self.is_stop_gather = num <= 0
        end
    end
end

function OperateHangGather:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

function OperateHangGather:OnSaveOper()
    self.obj.scene:SetCrossOperate(self.oper_type, self.gather_id, self.target_x, self.target_y, self.target_scene_id, self.target_gather_num, self.gather_callback)
end

function OperateHangGather:RandomSearch()
    local target_x,target_y = self.target_x,self.target_y
    local unit_x,unit_y = self.obj:GetUnitPosXY()
    local len_sq = (unit_x-self.target_x)*(unit_x-self.target_x) + (unit_y-self.target_y)*(unit_y-self.target_y)
    if len_sq >= 6 then
        
    else
        target_x = target_x + math.random(10,20)
        target_y = target_y + math.random(10,20)
    end

    self.cur_oper = self:CreateOperate(game.OperateType.FindWay, self.obj, target_x, target_y)
    if not self.cur_oper:Start() then
        self:ClearCurOperate()
    end
end

return OperateHangGather
