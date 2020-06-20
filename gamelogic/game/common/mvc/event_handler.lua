
local EventHandler = Class()

local _event_mgr = global.EventMgr

function EventHandler:_init()

end

function EventHandler:_delete()
	self:UnBindAllEvents()
end

function EventHandler:BindEvent(event_id, func)
	if not self._bind_event_map then
		self._bind_event_map = {}
	end
	local ev_handle = _event_mgr:Bind(event_id, func)
	self._bind_event_map[ev_handle] = true
	return ev_handle
end

function EventHandler:UnBindEvent(ev_handle)
	if self._bind_event_map then
		self._bind_event_map[ev_handle] = nil
		_event_mgr:UnBind(ev_handle)
	end
end

function EventHandler:UnBindAllEvents()
	if self._bind_event_map then
		for k,v in pairs(self._bind_event_map) do
			_event_mgr:UnBind(k)
		end
		self._bind_event_map = nil
	end
end

function EventHandler:FireEvent(ev, ...)
	_event_mgr:Fire(ev, ...)
end

return EventHandler
