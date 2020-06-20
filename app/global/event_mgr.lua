
local EventMgr = Class()

function EventMgr:_init()
	self.ev_num = 0
	self.event_id = 0
	self.event_map = {}
	self.event_id_map = {}
end

function EventMgr:_delete()
	
end

function EventMgr:GetEventNum()
	return self.ev_num
end

function EventMgr:Bind(ev_name, func)
	local ev = self.event_map[ev_name]
	if not ev then
		self.event_id = self.event_id + 1

		ev = {}
		ev.event_id = self.event_id
		ev.handle_id = 0 
		ev.function_list = {}
		self.event_map[ev_name] = ev
		self.event_id_map[self.event_id] = ev
	end

	self.ev_num = self.ev_num + 1
	ev.handle_id = ev.handle_id + 1
	ev.function_list[ev.handle_id] = func

	local ev_handle = ev.event_id + ev.handle_id * 10000
	return ev_handle
end

function EventMgr:UnBind(ev_handle)
	local ev_id = ev_handle % 10000
	local handle_id = ev_handle // 10000

	local ev = self.event_id_map[ev_id]
	if not ev then
		error("EventMgr:UnBind event not found!", ev_id)
		return
	end

	if not ev.function_list[handle_id] then
		error("EventMgr:UnBind event handle not found!", ev_id, handle_id)
		return
	end

	self.ev_num = self.ev_num - 1
	ev.function_list[handle_id] = nil
end

function EventMgr:Fire(event_id, ...)
	local ev = self.event_map[event_id]
	if not ev then
		return
	end

	for i,v in pairs(ev.function_list) do
		if v then
			v(...)
		end
	end
end

global.EventMgr = EventMgr.New()