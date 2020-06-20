local Time = Class()

local math_floor = math.floor
local unity_time = UnityEngine.Time

function Time:_init()
	self.now_time = 0
	self.delta_time = 0

	self.local_server_time = 0
	self.local_server_ret_time = 0

	self.sync_new_cycle = false
	self.last_sync_ms = 0
	self.last_delay_ms = 0
end

function Time:_delete()

end

function Time:Update()
	self.delta_time = unity_time.deltaTime
	self.now_time = unity_time.time
	self.real_time = unity_time.realtimeSinceStartup
end

function Time:SetScale(val)
	unity_time.timeScale = val
end

function Time:SetServerTime(time)
	self.local_server_time = time*0.001 + self.last_delay_ms*0.001*0.5
	self.local_server_ret_time = unity_time.realtimeSinceStartup
end

function Time:GetServerTime()
	return math_floor(self:GetServerTimeMs())
end

function Time:GetServerTimeMs()
	return self.local_server_time + unity_time.realtimeSinceStartup - self.local_server_ret_time
end

function Time:SetLastSyncTime(time_ms)
	self.last_sync_ms = time_ms
	self.sync_new_cycle = true
end

function Time:SetLastAckTime(time_ms)
	self.last_delay_ms = time_ms - self.last_sync_ms
	if self.last_delay_ms < 0 then
		self.last_delay_ms = 0
	end
	self.sync_new_cycle = false
end

function Time:IsSyncNewCycle()
	return self.sync_new_cycle
end

function Time:Reset()
	self.sync_new_cycle = false
end

function Time:GetDelayTime()
	if self.sync_new_cycle then
		local cur_delay_ms = self.real_time - self.last_sync_ms
		if cur_delay_ms > self.last_delay_ms then
			return cur_delay_ms
		else
			return self.last_delay_ms
		end
	else
		return self.last_delay_ms
	end
end

function Time:GetCurDay()

	local server_time = self:GetServerTime()
	local tab = os.date("*t", server_time)
	return tab.day
end

--星期几
function Time:GetCurWeekDay()

	local server_time = self:GetServerTime()
	local tab = os.date("*t", server_time)
	local wday = tab.wday - 1
	wday = wday == 0 and 7 or wday
	return wday
end

global.Time = Time.New()
