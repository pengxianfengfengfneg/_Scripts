
-- BtTree
local BtTree = Class()

function BtTree:_init()
	self._name = "BtTree"
	self._next_time = 0
	self._interval = 0.1
	self._is_loop = false
end

function BtTree:_delete()
	self:Reset()
end

function BtTree:Reset()
	self:ClearNode()
end

function BtTree:SetInterval(interval)
	self._interval = interval
end

function BtTree:SetBehaviour(name, loop)
	self:ClearNode()
	if name then
		self._is_loop = loop
		self._node = game.BtFactory.instance:Create(name)
	end
end

function BtTree:GetBehaviour()
	if self._node then
		return self._node:GetName()
	end
end

function BtTree:Update(now_time, elapse_time, black_board)
	if now_time > self._next_time then
		self._next_time = now_time + self._interval
		if self._node then
			if self._node:Tick(now_time, elapse_time, black_board) ~= nil then
				self._node:Clear()
				if not self._is_loop then
					self:ClearNode()
				end
			end
		end
	end
end

function BtTree:ClearNode()
	if self._node then
		game.BtFactory.instance:Free(self._node)
		self._node = nil
	end
end

bt.BtTree = BtTree