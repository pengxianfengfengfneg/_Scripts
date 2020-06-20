
local Runner = Class()

local MaxPriorityNum = 3

function Runner:_init()
	self.all_update_objs = {}
	self.priority_update_list = {}

	self.is_updating = false
	self.delay_delete_list = {}
	for i=1,MaxPriorityNum do
		table.insert(self.priority_update_list, {})
	end
end

function Runner:_delete()

end

function Runner:Update( now_time, elapse_time )
	self.is_updating = true
	for i=1,MaxPriorityNum do
		local priority_tbl = self.priority_update_list[i]
		for i, v in ipairs(priority_tbl) do
			if v[2] then
				v[3]:Update(now_time, elapse_time)
			end
		end
	end
	self.is_updating = false

	if #self.delay_delete_list > 0 then
		for i,v in ipairs(self.delay_delete_list) do
			self:_DeleteUpdateObj(v)
		end
		self.delay_delete_list = {}
	end
end

-- priority high to low: 1 ~ 3 
function Runner:AddUpdateObj(obj, priority)
	if self.all_update_objs[obj] then
		error("Runner:AddUpdateObj Add Update Obj Twice!")
	else
		priority = priority or 2

		local info = {priority, true, obj}
		self.all_update_objs[obj] = info
		table.insert(self.priority_update_list[priority], info)
	end
end

function Runner:RemoveUpdateObj(obj)
	local info = self.all_update_objs[obj]
	if info then
		if self.is_updating then
			info[2] = false
			table.insert(self.delay_delete_list, obj)
		else
			self:_DeleteUpdateObj(obj)
		end
	end
end

function Runner:_DeleteUpdateObj(obj)
	local info = self.all_update_objs[obj]
	if info then
		self.all_update_objs[obj] = nil
		for i,v in ipairs(self.priority_update_list[info[1]]) do
			if v[3] == obj then
				table.remove(self.priority_update_list[info[1]], i)
				return
			end
		end
	else
		error("Runner:RemoveUpdateObj No Obj Found!")
	end
end

function Runner:GetRunnerNum()
	local num = 0
	for i=1,MaxPriorityNum do
		local priority_tbl = self.priority_update_list[i]
		for i, v in ipairs(priority_tbl) do
			num = num + 1
		end
	end
	return num
end

global.Runner = Runner.New()
