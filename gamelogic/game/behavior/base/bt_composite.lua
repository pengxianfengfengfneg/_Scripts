local BtComposite = Class(bt.BtNode)

function BtComposite:_init(children)
	self._name = "BtComposite"
	self._children = children
end

function BtComposite:Reset()
	for i,v in ipairs(self._children) do
		v:Reset()
	end
end

bt.BtComposite = BtComposite

-- BtSequence
local BtSequence = Class(BtComposite)

function BtSequence:_init(children)
	self._name = "BtSequence"
end

function BtSequence:Reset()
	self._cur_index = nil
	BtSequence.super.Reset(self)
end

function BtSequence:Tick(now_time, elapse_time, black_board)
	if not self._cur_index then
		self._cur_index = 1
	end

	local child, ret
	for i=self._cur_index,#self._children do
		child = self._children[i]
		ret = child:Tick(now_time, elapse_time, black_board)
		if ret == nil then
			self._cur_index = i
			return nil
		elseif ret == true then
			child:Clear()
		else
			child:Clear()
			self._cur_index = nil
			return false
		end
	end

	self._cur_index = nil
	return true
end

function BtSequence:Clear()
	BtSequence.super.Clear(self)
	if self._cur_index then
		self._children[self._cur_index]:Clear()
		self._cur_index = nil
	end
end

bt.BtSequence = BtSequence

-- BtPrioritySelector
local BtPrioritySelector = Class(BtComposite)

function BtPrioritySelector:_init(children)
	self._name = "BtPrioritySelector"
end

function BtPrioritySelector:Reset()
	self._cur_index = nil
	BtPrioritySelector.super.Reset(self)
end

function BtPrioritySelector:Tick(now_time, elapse_time, black_board)
	local ret
	for i,v in ipairs(self._children) do
		ret = v:Tick(now_time, elapse_time, black_board)
		if ret == nil then
			if self._cur_index and self._cur_index ~= i then
				self._children[self._cur_index]:Clear()
			end
			self._cur_index = i
			return nil
		elseif ret == true then
			if self._cur_index and self._cur_index ~= i then
				self._children[self._cur_index]:Clear()
			end
			v:Clear()
			self._cur_index = nil
		else
			v:Clear()
		end
	end

	self._cur_index = nil
	return false
end

function BtPrioritySelector:Clear()
	BtPrioritySelector.super.Clear(self)
	if self._cur_index then
		self._children[self._cur_index]:Clear()
		self._cur_index = nil
	end
end

bt.BtPrioritySelector = BtPrioritySelector

-- BtNoPrioritySelector
local BtNoPrioritySelector = Class(BtPrioritySelector)

function BtNoPrioritySelector:_init(children)
	self._name = "BtNoPrioritySelector"
end

function BtNoPrioritySelector:Tick(now_time, elapse_time, black_board)
	local ret
	if self._cur_index then
		local ret = self._children[self._cur_index]:Tick(now_time, elapse_time, black_board)
		if ret ~= nil then
			self._children[self._cur_index]:Clear()
			self._cur_index = nil
		else
			return nil
		end
	end

	return BtNoPrioritySelector.super.Tick(self, now_time, elapse_time, black_board)
end

bt.BtNoPrioritySelector = BtNoPrioritySelector

-- BtLoopUtil
local BtSequence = Class(BtComposite)

function BtSequence:_init(children)
	self._name = "BtSequence"
end

function BtSequence:Reset()
	BtSequence.super.Init(self)
	self._cur_index = nil
end

function BtSequence:Tick(now_time, elapse_time, black_board)
	if not self._cur_index then
		self._cur_index = 1
	end

	local child, ret
	for i=self._cur_index,#self._children do
		child = self._children[i]
		ret = child:Tick(now_time, elapse_time, black_board)
		if ret == nil then
			self._cur_index = i
			return nil
		elseif ret == true then
			child:Clear()
		else
			child:Clear()
			self._cur_index = nil
			return false
		end
	end

	self._cur_index = nil
	return true
end

function BtSequence:Clear()
	BtSequence.super.Clear(self)
	if self._cur_index then
		self._children[self._cur_index]:Clear()
		self._cur_index = nil
	end
end

bt.BtSequence = BtSequence