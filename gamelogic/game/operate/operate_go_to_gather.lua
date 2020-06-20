
local OperateGoToGather = Class(require("game/operate/operate_sequence"))

function OperateGoToGather:_init()
	self.oper_type = game.OperateType.GoToGather
end

function OperateGoToGather:Init(obj, target_id, gather_dist)
	OperateGoToGather.super.Init(self, obj)
    self.target_id = target_id
    self.gather_dist = gather_dist or 2
end

function OperateGoToGather:Start()
    local target_obj = self.obj.scene:GetObj(self.target_id)
	if not target_obj then
        return false
    end

    local unit_pos = target_obj:GetUnitPos()
	self:InsertToOperateSequence(game.OperateType.FindWay, self.obj, unit_pos.x, unit_pos.y, self.gather_dist)
	self:InsertToOperateSequence(game.OperateType.Gather, self.obj, self.target_id)
	return true
end

return OperateGoToGather
