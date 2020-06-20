local OperateFindWay = Class(require("game/operate/operate_sequence"))

local pDistanceSQ = cc.pDistanceSQ
local pMidpoint3 = cc.pMidpoint3

function OperateFindWay:_init()
    self.oper_type = game.OperateType.FindWay
end

function OperateFindWay:Init(obj, x, y, offset_dist, cb, keep_move, not_effect)
    OperateFindWay.super.Init(self, obj)
    self.dst_x, self.dst_y = x, y

    self.offset_dist = offset_dist
    self.cb = cb
    self.keep_move = keep_move
    self.not_effect = not_effect
end

function OperateFindWay:Reset()
    if self.obj:IsMainRole() then
        global.EventMgr:Fire(game.SceneEvent.FindWay, false)

        if self.effect then
            game.EffectMgr.instance:StopEffect(self.effect)
            self.effect = nil
        end

        local cam = game.Scene.instance:GetCamera():StopLerp()
        if cam then
            cam:StopLerp()
        end
    end

    if self.cb then
        self.cb(false)
    end

    self.offset_dist = nil
    self.cb = nil
    self.find_succ = nil
    self.path_list = nil

    OperateFindWay.super.Reset(self)
end

function OperateFindWay:Start()
	local src_x, src_y = self.obj:GetUnitPosXY()
    local ret, path_list = game.Utils.FindWay(src_x, src_y, self.dst_x, self.dst_y)
    if not ret then
        return false
    elseif not path_list[2] then
        self.find_succ = true
        return true
    end

    self.path_list = path_list

    local scene = self.obj.scene
    if self.obj:IsMainRole() then
        if (not self.not_effect) and not self.effect then
            self.effect = game.EffectMgr.instance:CreateEffect("effect/scene/movesign.ab")
            game.RenderUnit:AddToObjLayer(self.effect:GetRoot())
            self.effect:SetPosition(self.dst_x, scene:GetHeightForUniqPos(self.dst_x, self.dst_y), self.dst_y)
        end

        local cam = game.Scene.instance:GetCamera()
        if cam then
            cam:StartLerp()
        end
    end

    self.scene_cfg = self.obj:GetScene():GetSceneConfig()

    local pos
    for index = 2, #path_list do 
        pos = path_list[index]
        local pre_pos = path_list[index-1]

        if pre_pos then
            pre_pos.y = pre_pos.z
        end

        pos.y = pos.z

        local is_now_jump,mid_list,is_now_reverse,now_idx = self:IsJumpPoint(pos)
        local is_pre_jump,mid_list,is_pre_reverse,pre_idx = self:IsJumpPoint(pre_pos)

        local is_jump = (is_now_jump and is_pre_jump) and (is_now_reverse~=is_pre_reverse) and (now_idx==pre_idx)
        if is_jump then
            local lx,ly = game.UnitToLogicPos(pos.x, pos.z)
            local fx,fy = game.UnitToLogicPos(pre_pos.x, pre_pos.z)

            if mid_list and is_pre_reverse then
                local new_mid_list = {}
                for i=#mid_list,1,-1 do
                    table.insert(new_mid_list, mid_list[i])
                end
                mid_list = new_mid_list
            end
            self:InsertToOperateSequence(game.OperateType.Jump, self.obj, lx, ly, fx, fy, mid_list)
        else
            self:InsertToOperateSequence(game.OperateType.Move, self.obj, pos.x, pos.z)
        end
    end

    if self.offset_dist then
        self.offset_dist = self.offset_dist*self.offset_dist

        self.final_pos = path_list[#path_list]
        self.final_pos.y = self.final_pos.z
    end

    self.mount_time = global.Time.now_time + 2

    if self.obj:IsMainRole() then
        global.EventMgr:Fire(game.SceneEvent.FindWay, true, self)
    end

    return OperateFindWay.super.Start(self)
end

local pFuzzyEqual = cc.pFuzzyEqual
local variance = 1
local ComparePosFrom = {x=0,y=0}
local ComparePosTo = {x=0,y=0}
function OperateFindWay:IsJumpPoint(pos)
    if not pos then return false end

    local jump_list = self.scene_cfg.jump_list or {}
    for k,v in ipairs(jump_list) do
        ComparePosFrom.x = v.from.x
        ComparePosFrom.y = v.from.z

        ComparePosTo.x = v.to.x
        ComparePosTo.y = v.to.z

        if pFuzzyEqual(pos, ComparePosFrom, variance) then
            return true,v.mid,false,k
        end

        if pFuzzyEqual(pos, ComparePosTo, variance) then
            return true,v.mid,true,k
        end
    end
    return false
end

function OperateFindWay:Update(now_time, elapse_time)
    if self.find_succ then
        if self.cb then
            self.cb(true)
            self.cb = nil
        end
        return true
    end

    if self.offset_dist then
        local cur_pos = self.obj:GetUnitPos()
        if pDistanceSQ(cur_pos, self.final_pos) <= self.offset_dist then
            self.obj:DoIdle(self.keep_move)
            if self.cb then
                self.cb(true)
                self.cb = nil
            end
            return true
        end
    end

    local cur_operate = self:GetCurOperate()
    if cur_operate then
        if cur_operate:GetOperateType() == game.OperateType.Jump then
            self.mount_time = now_time + 2
        end

        if self.mount_time and self.obj:IsMainRole() and now_time > self.mount_time then
            self.mount_time = nil
            if self.obj:CanRideMount(1) then
                self.obj:SetMountState(1)
            end
        end
    end

    local ret = OperateFindWay.super.Update(self, now_time, elapse_time)
    if ret ~= nil then
        if self.cb then
            self.cb(true)
            self.cb = nil
        end
    end
    return ret
end

function OperateFindWay:GetDstXY()
    return self.dst_x, self.dst_y
end

function OperateFindWay:GetPathList()
    return self.path_list
end

return OperateFindWay
