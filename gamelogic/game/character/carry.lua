local Carry = Class(require("game/character/character"))

local _model_type = game.ModelType

function Carry:_init()
    self.obj_type = game.ObjType.Carry
    self.update_cd = 60
end

function Carry:_delete()

end

function Carry:Init(scene, vo)
    Carry.super.Init(self, scene, vo)

    self.vo = vo
    self.uniq_id = vo.id
    self.carry_id = vo.cid
    self:SetLogicPos(vo.x, vo.y)

    self:CreateDrawObj()

    self:ShowShadow(true)

    local cfg = config.carry[self.carry_id]
    self.move_speed = cfg.speed

    self:SetHudText(game.HudItem.Name, vo.owner_name,  cfg.color)
    self:SetHudText(game.HudItem.GuildName, vo.guild_name, 7)

    self.is_main_role_carry = self:GetOwnerID() == self.scene:GetMainRoleID()
end

function Carry:Reset()
    if self.is_main_role_carry then
        global.EventMgr:Fire(game.SceneEvent.MainRoleCarryChange, nil)
    end
    Carry.super.Reset(self)
end

-- 外观形象相关
function Carry:CreateDrawObj()
    local cfg = config.carry[self.carry_id]
    self.draw_obj = game.GamePool.DrawObjPool:Create()
    self.draw_obj:Init(game.BodyType.Carry)
    self.draw_obj:SetParent(self.root_obj.tran)
    self.draw_obj:SetModelID(_model_type.Body, cfg.model_id)
    self.draw_obj:PlayLayerAnim(_model_type.Body, game.ObjAnimName.Idle)
end

function Carry:GetSpeed()
    return self.move_speed / 24
end

function Carry:IsMainRoleCarry()
    return self.is_main_role_carry
end

function Carry:GetOwnerID()
    return self.vo.owner_id
end

function Carry:GetOwner()
    return self.scene:GetObjByUniqID(self.vo.owner_id)
end

function Carry:DoMove(x, y, keep_move)
    if self:GetUnitDistSq(x, y) > 1 then
        self.state_machine:ChangeState(game.ObjState.Move, x, y, keep_move)
    else
        local cur_x, cur_y = self:GetLogicPosXY()
        self:DoIdle()
        self:SetLogicPos(cur_x, cur_y)
    end
end

function Carry:CanBeAttack()
    return false
end

return Carry
