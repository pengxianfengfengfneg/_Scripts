
local AoiMgr = Class()

local _aoi = N3DClient.AoiManager:GetInstance()
local _math_floor = math.floor

function AoiMgr:_init()
	self.aoi_enter_list = {}
	self.aoi_leave_list = {}
	self:Start()

	self.next_update_time = 0
end

function AoiMgr:_delete()
	self:Clear()
end

function AoiMgr:Start()
	local enter_func = function(id, obj_list)
		local func = self.aoi_enter_list[id]
		if func then
			func(obj_list)
		end
	end

	local leave_func = function(id, obj_list)
		local func = self.aoi_leave_list[id]
		if func then
			func(obj_list)
		end
	end
	_aoi:RegisterLuaHandler(enter_func, leave_func)
end

function AoiMgr:Update(now_time, elapse_time)
	if now_time > self.next_update_time then
		self.next_update_time = self.next_update_time + 0.15
		_aoi:Update()
	end
end

function AoiMgr:SetSize(width, height)
	_aoi:InitAoiInfo(width, height, 2, 2)
end

function AoiMgr:Clear()
	_aoi:Clear()
end

function AoiMgr:AddObj(x, y, type, user_data)
	return _aoi:AddObj(_math_floor(x), _math_floor(y), type, user_data)
end

function AoiMgr:UpdateObj(id, x, y)
	_aoi:UpdateObj(id, _math_floor(x), _math_floor(y))
end

function AoiMgr:DelObj(id)
	_aoi:DelObj(id)
end

function AoiMgr:AddWatcher(x, y, range_x, range_y, mask, enter_func, leave_func)
	local id = _aoi:AddWatcher(_math_floor(x), _math_floor(y), range_x, range_y, mask, enter_func, leave_func)
	self.aoi_enter_list[id] = enter_func
	self.aoi_leave_list[id] = leave_func
	return id
end

function AoiMgr:UpdateWatcher(id, x, y)
	_aoi:UpdateWatcher(id, _math_floor(x), _math_floor(y))
end

function AoiMgr:DelWatcher(id)
	self.aoi_enter_list[id] = nil
	self.aoi_leave_list[id] = nil
	_aoi:DelWatcher(id)
end

function AoiMgr:ForeachAoiObj(id, func)
	local callback = function(watch_id, data_list)
		for i,v in ipairs(data_list) do
			func(v)
		end
	end
	_aoi:GetAoiZoneObjs(id, callback)
end

global.AoiMgr = AoiMgr.New()