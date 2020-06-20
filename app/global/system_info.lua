
local SystemInfo = Class()

local _sys_info = UnityEngine.SystemInfo

function SystemInfo:_init()
	self.device_id = _sys_info.deviceUniqueIdentifier
end

function SystemInfo:_delete()

end

function SystemInfo:GetDeviceID()
	return self.device_id
end

function SystemInfo:GetBatteryValue()
	local val = _sys_info.batteryLevel
	if val == -1 then
		return 1
	else
		return val
	end
end

global.SystemInfo = global.SystemInfo or SystemInfo.New()