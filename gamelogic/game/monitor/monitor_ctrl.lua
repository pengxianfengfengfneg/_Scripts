
local MonitorCtrl = Class(game.BaseCtrl)

function MonitorCtrl:_init()
	if MonitorCtrl.instance ~= nil then
		error("MonitorCtrl Init Twice!")
	end
	MonitorCtrl.instance = self
	
	self.fps_info = {}
	self.view = require("game/monitor/monitor_view").New(self)
end

function MonitorCtrl:_delete()
	self.view:DeleteMe()
	self.view = nil

	MonitorCtrl.instance = nil
end

function MonitorCtrl:OpenView()
	self.view:Open()
end

function MonitorCtrl:CloseView()
	self.view:Close()
end

function MonitorCtrl:ToggleView()
	if self.view:IsOpen() then
		self.view:Close()
	else
		self.view:Open()
	end
end

function MonitorCtrl:StartFps()
	self.fps_info.last_time = global.Time.real_time
	self.fps_info.frames = 0
	self.fps_info.fps = 0
end

function MonitorCtrl:UpdateFps()
	self.fps_info.frames = self.fps_info.frames + 1
	local now_time = global.Time.real_time
	if now_time > self.fps_info.last_time + 0.5 then
		self.fps_info.fps = self.fps_info.frames / (now_time - self.fps_info.last_time)
		self.fps_info.frames = 0
		self.fps_info.last_time = global.Time.real_time
	end
end

function MonitorCtrl:GetFps()
	return self.fps_info.fps or 0
end

game.MonitorCtrl = MonitorCtrl

return MonitorCtrl
