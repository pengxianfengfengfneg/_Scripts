
local TimerMgr = Class()

local _time = global.Time

function TimerMgr:_init()
	self.timer_id = 0
	self.timer_map = {}

	self.timer_list = {}
	self.timer_list.next = self.timer_list
	self.timer_list.prev = self.timer_list
	self.timer_list.is_head = true

	self.timer_num = 0
end

function TimerMgr:_delete()

end

function TimerMgr:GetTimerNum()
	return self.timer_num
end

-- 创建定时器，定时函数返回true即删除定时器
function TimerMgr:CreateTimer(interval, func)
	self.timer_id = self.timer_id + 1
	self.timer_num = self.timer_num + 1

	local timer = {}
	timer.id = self.timer_id
	timer.func = func
	timer.interval = interval

	self.timer_map[self.timer_id] = timer
	self:AddTimerNode(timer)
	return self.timer_id
end

function TimerMgr:DelTimer(timer_id)
	local timer = self.timer_map[timer_id]
	if timer and timer.func then
		self.timer_num = self.timer_num - 1
		timer.func = nil
		self.timer_map[timer_id] = nil
	end
end

function TimerMgr:AddTimerNode(timer)
	timer.expire_time = timer.interval + _time.now_time
	if timer.interval <= 3 then
		self:AddFromHead(timer)
	else
		self:AddFromTail(timer)
	end
end

function TimerMgr:AddFromHead(timer)
	local expire_time = timer.expire_time
	local tmp_node = self.timer_list.next
	while not tmp_node.is_head do
		if expire_time < tmp_node.expire_time then
			break
		end
		tmp_node = tmp_node.next
	end
	timer.prev = tmp_node.prev
	timer.next = tmp_node
	tmp_node.prev.next = timer
	tmp_node.prev = timer
end

function TimerMgr:AddFromTail(timer)
	local expire_time = timer.expire_time
	local tmp_node = self.timer_list.prev
	while not tmp_node.is_head do
		if expire_time >= tmp_node.expire_time then
			break
		end
		tmp_node = tmp_node.prev
	end
	timer.prev = tmp_node
	timer.next = tmp_node.next
	tmp_node.next.prev = timer
	tmp_node.next = timer
end

function TimerMgr:Poll()
	local now_time = _time.now_time
	local poll_num, poll_list = self:SplitPollList(now_time)

	if poll_num > 0 then
		local tmp_node = poll_list
		for i=1,poll_num do
			if not tmp_node.func or tmp_node.func() then
				self:DelTimer(tmp_node.id)
				tmp_node = tmp_node.next
			else
				local timer = tmp_node
				tmp_node = tmp_node.next
				self:AddTimerNode(timer)
			end
		end
	end
end

function TimerMgr:SplitPollList(now_time)
	local poll_list = self.timer_list.next
	local poll_num = 0

	local tmp_node = self.timer_list.next
	while not tmp_node.is_head do
		if tmp_node.expire_time > now_time then
			break
		end
		poll_num = poll_num + 1
		tmp_node = tmp_node.next
	end

	if poll_num > 0 then
		self.timer_list.next = tmp_node
		tmp_node.prev = self.timer_list
	end

	return poll_num, poll_list
end

function TimerMgr:DebugAll()
	print("TimerList")
	local n = 0
	local tmp_node = self.timer_list.next
	while not tmp_node.is_head do
		n = n + 1
		print(n, tmp_node.id, tmp_node.interval)
		tmp_node = tmp_node.next
	end

	print("TimerMap")
	n = 0
	for k,v in pairs(self.timer_map) do
		n = n + 1
		print(n, k, v)
	end
end

global.TimerMgr = global.TimerMgr or TimerMgr.New()