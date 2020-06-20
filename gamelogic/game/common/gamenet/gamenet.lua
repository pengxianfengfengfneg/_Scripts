
local GameNet = Class()

local _net_mgr = N3DClient.NetManager:GetInstance()
local _event_mgr = global.EventMgr
local _time = global.Time

local _table_insert = table.insert
local _table_remove = table.remove

local _update_msg_interval = 0.1
local _check_res_interval = 60 * 30
local _heart_beat_interval_time_sec = 10
local _heart_beat_duration_time_sec = 600
local _heart_beat_over_time = 30

local FirstLoadingRecv = table.clone(game.FirstLoadingRecv)

function GameNet:_init()
	if GameNet.instance ~= nil then
		error("GameNet Init Twice!")
	end
	GameNet.instance = self

	self.enable_reconnect = false
	self.msg_callback_map = {}
	self.msg_list = {}
	self.gamenet_info = {}

	self.next_heart_beat_over_time = 0
	self.next_heart_beat_time = 0
	self.next_update_time = 0
	self.msg_update_num = 0

	self:RegisterProtocalCallback(90010, function(data_list)
		self:OnHeartBeatRet(data_list)
	end)

	self._pause_ev = _event_mgr:Bind(game.GameEvent.Pause, function(is_pause)
		if self.gamenet_info.connected and not is_pause then
			self.next_heart_beat_over_time = _time.now_time + _heart_beat_over_time
		end
		_net_mgr:SetBackGroundHeartBeatEnable(self.gamenet_info.connected and is_pause and true or false, _heart_beat_interval_time_sec, _heart_beat_duration_time_sec)
	end)

	self.reuse_proto_map = {}
	local reuse_proto_list = {90302, 90301, 90201, 90235, 90248, 90010}
	for i,v in ipairs(reuse_proto_list) do
		self.reuse_proto_map[v] = true
	end

	global.Runner:AddUpdateObj(self, 1)
end

function GameNet:_delete()
	if self._pause_ev then
		_event_mgr:UnBind(self._pause_ev)
		self._pause_ev = nil
	end

	self:DisconnectGameNet()
	self.msg_list = nil
	self.msg_callback_map = nil
	self.gamenet_info = nil
	global.Runner:RemoveUpdateObj(self)
	GameNet.instance = nil
end

function GameNet:Start()
	self.enable_reconnect = true

	local connect_callback = function(net_id, ip, port)
		self:_OnConnect(net_id, ip, port)
	end

	local disconnect_callback = function(net_id)
		self:_OnDisConnect(net_id)
	end

	local recv_callback = function(net_id, proto_id, data_list)
		self:_OnRecv(net_id, proto_id, data_list)
	end

	_net_mgr:RegisterLuaHandler(connect_callback, disconnect_callback, recv_callback)
	self:RegisterAllProtocal()
end

function GameNet:Restart()
	self:DisconnectGameNet()

	FirstLoadingRecv = table.clone(game.FirstLoadingRecv)
end

function GameNet:Update(now_time, elapse_time)
	if now_time > self.next_heart_beat_time then
		self.next_heart_beat_time = now_time + _heart_beat_interval_time_sec
		self:SendHeartBeat()
	end

	if now_time > self.next_heart_beat_over_time and self.next_heart_beat_over_time ~= 0 then
		self.next_heart_beat_over_time = 0
		self:DisconnectGameNet(true)
	end

	if now_time > self.next_update_time then
		self.next_update_time = now_time + _update_msg_interval
		_net_mgr:Update()
		self.msg_update_num = #self.msg_list / _update_msg_interval
	end

	self:UpdateMsg(now_time, elapse_time)
end

function GameNet:UpdateMsg(now_time, elapse_time)
	if #self.msg_list == 0 then
		return
	end

	local proto
	local msg_num = self.msg_update_num * elapse_time + 1
	for i=1,msg_num do
		proto = self.msg_list[1]
		if proto then
			_table_remove(self.msg_list, 1)

			local callback = self.msg_callback_map[proto[1]]
			if callback then
				callback(proto[2])
			end

			if self.reuse_proto_map[proto[1]] then
				_net_mgr:ReuseProtocal(proto[1], proto[2])
			end

			if FirstLoadingRecv[proto[1]] then
                FirstLoadingRecv[proto[1]] = nil
            end
		else
			return
		end
	end
end

function GameNet:FirstLoadingReady()
	for _,v in pairs(FirstLoadingRecv) do
		return false
	end
	return true
end

function GameNet:RegisterProtocalCallback(proto_id, func)
	if self.msg_callback_map[proto_id] then
		error("Protocal Callback has already register")
	end
	self.msg_callback_map[proto_id] = func
end

function GameNet:RemoveProtocalCallback(proto_id, func)
	self.msg_callback_map[proto_id] = nil
end

local empty_table = {}
function GameNet:SendProtocal(proto_id, data_list)
	-- print(">>>>>send proto_id", proto_id)
	if not self.gamenet_info.connected then
		return
	end
	_net_mgr:SendLuaProtocal(self.gamenet_info.net_id, proto_id, data_list or empty_table)
end

function GameNet:ConnectGameNetAsyn(ip, port, time_out)
	if self.gamenet_info.connected then
		return
	end

	-- print("Connecting GameNet", ip, port)
	self.gamenet_info.ip = ip
	self.gamenet_info.port = port
	self.gamenet_info.net_id = _net_mgr:ConnectAsyn(ip, port, time_out)
	self.gamenet_info.connected = false
	self.gamenet_info.notice_disconnect = true
	self.msg_list = {}
end

function GameNet:IsGameNetConnect()
	return self.gamenet_info.connected
end

function GameNet:CanReconnect()
	return self.enable_reconnect
end

function GameNet:EnableReconnect(val)
	self.enable_reconnect = val
end

function GameNet:_OnConnect(net_id)
	print("_OnConnect", net_id)

	self.msg_list = {}
	if self.gamenet_info.net_id == net_id then
		_time:Reset()

		self.gamenet_info.connected = true
		_event_mgr:Fire(game.GameNetEvent.NetConnect)
	end
end

function GameNet:DisconnectGameNet(is_notice)
	if self.gamenet_info and self.gamenet_info.net_id then
		self.msg_list = {}
		self.gamenet_info.connected = false
		self.gamenet_info.notice_disconnect = is_notice
		_net_mgr:Disconnect(self.gamenet_info.net_id)
	end
end

function GameNet:_OnDisConnect(net_id)
	print("_OnDisConnect", net_id)

	if self.gamenet_info.net_id == net_id then
		self.msg_list = {}
		self.gamenet_info.connected = false
		if self.disconnect_callback then
			self.disconnect_callback()
		else
			if self.gamenet_info.notice_disconnect then
				self:OpenDisconnectView(function()
					local check_res_time = global.UserDefault:GetInt("LastCheckResTime", 0)
					if os.time() > check_res_time + _check_res_interval then
						app.AppLoop.instance:ChangeState(app.AppLoop.State.Restart)
					else
						game.GameLoop:ChangeState(game.GameLoop.State.Restart)
					end
				end)
			end
		end
		
		self.gamenet_info = {}
	end 

	_event_mgr:Fire(game.GameNetEvent.NetDisConnect)
end

function GameNet:SetDiconnectCallback(callback)
	self.disconnect_callback = callback
end

function GameNet:OpenDisconnectView(callback)
	if game.GameMsgCtrl.instance then
		local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[1000], config.words[1001])
		msg_box._ui_order = game.UIZOrder.UIZOrder_Top
		msg_box._layer_name = game.LayerName.UIDefault
		msg_box:SetOkBtn(function()
			msg_box:Close()
			msg_box:DeleteMe()
			if callback then
				callback()
			end
		end)
		msg_box:Open()
	end
end

function GameNet:_OnRecv(net_id, proto_id, data_list)
	-- if not self.record[proto_id] then
	-- 	self.record[proto_id] = 0
	-- end
	-- self.record[proto_id] = self.record[proto_id] + 1

	-- print("<<<<<Recv proto_id", proto_id)
	if not self.gamenet_info.connected then
		return
	end
	if not data_list then
		print("_OnRecv", net_id, proto_id, data_list)
		return
	end

	self:TranslateMsg(proto_id, data_list)
end

-- function GameNet:Record()
-- 	local ls = {}
-- 	for k,v in pairs(self.record) do
-- 		table.insert(ls, {id = k, num = v})
-- 	end

-- 	table.sort(ls, function(a, b)
-- 		return a.num > b.num
-- 	end)

-- 	PrintTable(ls)
-- end

function GameNet:TranslateMsg(proto_id, data_list)
	local proto = {proto_id, data_list}
	_table_insert(self.msg_list, proto)
end

-- heart beat
function GameNet:SendHeartBeat()
	if not self.gamenet_info.connected or _time:IsSyncNewCycle() then
		return
	end
	local time_ms = math.floor(_time.real_time * 1000)
	local proto = {
		client_time = time_ms
	}
	self:SendProtocal(90009, proto)
	_time:SetLastSyncTime(time_ms)
end

function GameNet:OnHeartBeatRet(data_list)
	self.next_heart_beat_over_time = _time.now_time + _heart_beat_over_time
	if data_list.client_time ~= 0 then
		local time_ms = math.floor(_time.real_time * 1000)
		_time:SetLastAckTime(time_ms)
		_time:SetServerTime(data_list.server_time)
	end
end

game.GameNet = GameNet.New()