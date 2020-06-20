local Blackboard = Class()

function Blackboard:_init()
	self._name = "Blackboard"
end

function Blackboard:_delete()
	
end

function Blackboard:Reset()
	self.obj = nil
end

function Blackboard:SetObj(obj)
	self.obj = obj
end

function Blackboard:SetValue(name, val)
	self[name] = val
end

function Blackboard:SetPos(name, x, y)
	local pos = self[name]
	if not pos then
		pos = {}
		self[name] = pos
	end
	pos.x = x
	pos.y = y
end

function Blackboard:SetFindWayPos(x, y)
	self.findway_id = (self.findway_id or 0) + 1
	self:SetPos("findway_pos", x, y)
end

bt.Blackboard = Blackboard