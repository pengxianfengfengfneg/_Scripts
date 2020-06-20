
local CollectPool = global.CollectPool or Class()
local _table_insert = table.insert

function CollectPool:_init(create_func, delete_func, free_func, reserve_num)
	self.create_func = create_func
	self.delete_func = delete_func
    self.free_func = free_func

	self.free_list = {}
	self.item_list = {}

	if reserve_num and reserve_num > 0 then
		self:Reserve(reserve_num)
	end
end

function CollectPool:_delete()
	self:Clear()
end

function CollectPool:Create()
	local free_count = #self.free_list
	if free_count > 0 then
		local item = self.free_list[free_count]
		self.free_list[free_count] = nil
		return item
	else
		local item = self.create_func()
		if item then
			_table_insert(self.item_list, item)
			return item
		end
	end
end

function CollectPool:Free(item)
    self.free_func(item)
	_table_insert(self.free_list, item)
end

function CollectPool:Clear()
	for i,v in ipairs(self.item_list) do
		self.delete_func(v)
	end
	self.item_list = {}
	self.free_list = {}
end

function CollectPool:ForeachItem(func)
	for k,v in ipairs(self.item_list) do
		func(v)
	end
end

function CollectPool:Reserve(num)
	local create_num = num - #self.item_list
	for i=1,create_num do
		local item = self.create_func()
		_table_insert(self.item_list, item)
		self:Free(item)
	end
end

function CollectPool:GetItemNum()
	return #self.item_list
end

function CollectPool:GetFreeNum()
	return #self.free_list
end

function CollectPool:GetUsedNum()
	return #self.item_list - #self.free_list
end

function CollectPool:HasFreeItem()
	return #self.free_list > 0
end

global.CollectPool = CollectPool



