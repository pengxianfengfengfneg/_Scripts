local BtDecorator = Class(bt.BtNode)

function BtDecorator:_init(node)
	self._name = "BtDecorator"
	self._node = node
end

function BtDecorator:Reset()
	self._node:Reset()
	BtDecorator.super.Reset(self)
end

bt.BtDecorator = BtDecorator

-- BtDecorateNot
local BtDecorateNot = Class(bt.BtDecorator)

function BtDecorateNot:_init(node)
	self._name = "BtDecorateNot"
end

function BtDecorateNot:Tick(now_time, elapse_time, black_board)
	local ret = self._node:Tick(now_time, elapse_time, black_board)
	if ret ~= nil then
		ret = not ret
	end
	return ret
end

bt.BtDecorateNot = BtDecorateNot

-- BtDecorateLoop
local BtDecorateLoop = Class(bt.BtDecorator)

function BtDecorateLoop:_init(node, num, end_on_fail)
	self._name = "BtDecorateLoop"
	self._cur_num = 0
	self._loop_num = num
	self._end_on_fail = end_on_fail
end

function BtDecorateLoop:Reset()
	self._cur_num = 0
	BtDecorateLoop.super.Reset(self)
end

function BtDecorateLoop:Tick(now_time, elapse_time, black_board)
	if self._loop_num < 0 or self._cur_num < self._loop_num then
		local ret = self._node:Tick(now_time, elapse_time, black_board)
		if ret == nil then
			return nil
		elseif ret == true then
			self._cur_num = self._cur_num + 1
		else
			self._cur_num = self._cur_num + 1
			if self._end_on_fail then
				return false
			end
		end

		if self._loop_num > 0 and self._cur_num >= self._loop_num then
			return true
		else
			return nil
		end
	end
end

function BtDecorateLoop:Clear()
	self._cur_num = 0
	BtDecorateLoop.super.Clear(self)
end

bt.BtDecorateLoop = BtDecorateLoop

-- BtDecorateUtil
local BtDecorateUtil = Class(bt.BtDecorator)

function BtDecorateUtil:_init(node, func)
	self._name = "BtDecorateUtil"
	self._loop_func = func
end

function BtDecorateUtil:Tick(now_time, elapse_time, black_board)
	local ret = self._node:Tick(now_time, elapse_time, black_board)
	if ret == nil then
		return nil
	elseif ret == false then
		return false
	else
		if self._loop_func(now_time, elapse_time, black_board) then
			return true
		else
			return nil
		end
	end
end

bt.BtDecorateUtil = BtDecorateUtil
