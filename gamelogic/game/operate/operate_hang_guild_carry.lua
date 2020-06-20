local OperateHangGuildCarry = Class(require("game/operate/operate_base"))

local carry_npc_id = config.carry_common.carry_npc
local max_carry_times = config.carry_common.carry_times

function OperateHangGuildCarry:_init()
    self.oper_type = game.OperateType.HangGuildCarry
end

function OperateHangGuildCarry:Reset()
    
    self:ClearCurOperate()
    OperateHangGuildCarry.super.Reset(self)
end

function OperateHangGuildCarry:Start()
    self.ctrl = game.GuildCtrl.instance

    self.is_done_carry = false

    local yunbiao_data = self.ctrl:GetYunbiaoData()
    if yunbiao_data.stat <= 0 then
        return false
    end

    return true
end

function OperateHangGuildCarry:Update(now_time, elapse_time)
    self:UpdateCurOperate(now_time, elapse_time)

    if not self.cur_oper then
        if self.is_done_carry then
            return false
        end

        local yunbiao_data = self.ctrl:GetYunbiaoData()
        local state = yunbiao_data.stat

        if state == 1 then
            -- 运镖中
            self.cur_oper = self:CreateOperate(game.OperateType.Carry, self.obj)
            
        elseif state == 2 then
            -- 运镖完成
            self.cur_oper = self:CreateOperate(game.OperateType.GoToNpc, self.obj, carry_npc_id, function()
                local npc = game.Scene.instance:GetNpc(carry_npc_id)
                if npc then
                    npc:DoClick()

                    self.is_done_carry = true
                end
            end)
        end

        if not self.cur_oper then
            return false
        end

        if not self.cur_oper:Start() then
            self:ClearCurOperate()
        end
    else
        
    end
end

function OperateHangGuildCarry:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangGuildCarry:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

function OperateHangGuildCarry:OnSaveOper()
    self.obj.scene:SetCrossOperate(self.oper_type)
end

function OperateHangGuildCarry:GetCurTaskId()
    return game.DailyTaskId.YunbiaoTask
end

return OperateHangGuildCarry
