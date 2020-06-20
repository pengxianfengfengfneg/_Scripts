local OperateCarry = Class(require("game/operate/operate_base"))

function OperateCarry:_init()
    self.oper_type = game.OperateType.Carry
end

function OperateCarry:Reset()
    self:ClearCurOperate()
    OperateCarry.super.Reset(self)
end

function OperateCarry:Start()
    self.change_scene = false
    self.next_time = 0
    return true
end

function OperateCarry:Update(now_time, elapse_time)
    self:UpdateCurOperate(now_time, elapse_time)

    if not self.cur_oper then
        if now_time < self.next_time then
            return
        end

        local info = game.GuildCtrl.instance:GetYunbiaoData()
        if info then
            if info.stat ~= 1 or info.carry_scene == 0 then
                return true
            end

            if info.carry_scene ~= game.Scene.instance:GetSceneID() then
                if not self.change_scene then
                    self.change_scene = true
                    game.GuildCtrl.instance:SendTransferToCarryReq()
                end
                return
            end

            local x, y = self:GetCarryPos()
            if not x then
                x, y = info.carry_x, info.carry_y
            end

            local dist = self.obj:GetLogicDistSq(x, y)
            if dist > 4 then
                local target_x, target_y = game.LogicToUnitPos(x, y)
                self.cur_oper = self:CreateOperate(game.OperateType.FindWay, self.obj, target_x, target_y, 2)
                if not self.cur_oper:Start() then
                    self:ClearCurOperate()
                end
            end
        end
    end
end

function OperateCarry:GetCarryPos()
    local carry = self.obj:GetCarry()
    if carry then
        return carry:GetLogicPosXY()
    end
end

function OperateCarry:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateCarry:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
    self.next_time = global.Time.now_time + 1
end

function OperateCarry:OnSaveOper()
    self.obj.scene:SetCrossOperate(self.oper_type)
end

return OperateCarry
