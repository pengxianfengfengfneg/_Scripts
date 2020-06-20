
local OperateBase = Class()

function OperateBase:_init()
end

function OperateBase:_delete()
	self:Reset()
end

function OperateBase:Init(obj)
	self.obj = obj
end

function OperateBase:Reset()
	self.obj = nil
end

function OperateBase:OnStart()

end

function OperateBase:OnSaveOper()
	
end

function OperateBase:SetObj(obj)
	self.obj = obj
end

function OperateBase:GetOperateType()
	return self.oper_type
end

function OperateBase:CreateOperate(oper_type, ...)
	local oper = game.OperatePool:CreateOperate(oper_type, ...)	
	return oper
end

function OperateBase:FreeOperate(oper)
	game.OperatePool:FreeOperate(oper)
end

return OperateBase
