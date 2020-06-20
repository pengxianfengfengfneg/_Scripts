
local AppLoop = Class()

AppLoop.State = {
	Start = 1,
	FirstEnter = 2, 
	GetServerInfo = 3,
	CheckResVersion = 4,
	GetFileList = 5,
	CompareFileList = 6,
	UpdateRes = 7,
	LoadingRes = 8,
	LoadingScript = 9,
	Run = 10,
	Restart = 11,
}

function AppLoop:_init()
	if AppLoop.instance ~= nil then
		error("AppLoop Init Twice!")
	end
	AppLoop.instance = self

	self.stat_machine = global.StateMachine.New()

	self:AddState(AppLoop.State.Start, "apploop/apploop_start")
	self:AddState(AppLoop.State.FirstEnter, "apploop/apploop_first_enter")
	self:AddState(AppLoop.State.GetServerInfo, "apploop/apploop_get_server_info")
	self:AddState(AppLoop.State.CheckResVersion, "apploop/apploop_check_res_version")
	self:AddState(AppLoop.State.GetFileList, "apploop/apploop_get_filelist")
	self:AddState(AppLoop.State.CompareFileList, "apploop/apploop_compare_filelist")
	self:AddState(AppLoop.State.UpdateRes, "apploop/apploop_update_res")
	self:AddState(AppLoop.State.LoadingScript, "apploop/apploop_loading_script")
	self:AddState(AppLoop.State.LoadingRes, "apploop/apploop_loading_res")
	self:AddState(AppLoop.State.Run, "apploop/apploop_run")
	self:AddState(AppLoop.State.Restart, "apploop/apploop_restart")

	global.Runner:AddUpdateObj(self, 1)
end

function AppLoop:_delete()
	global.Runner:RemoveUpdateObj(self)
	
	self.stat_machine:DeleteMe()
	AppLoop.instance = nil
end

function AppLoop:Start()
	self:ChangeState(AppLoop.State.Start)
end

function AppLoop:Update(now_time, elapse_time)
	self.stat_machine:Update(now_time, elapse_time)
end

function AppLoop:ChangeState(id, param)
	self.stat_machine:ChangeState(id, param)
end

function AppLoop:GetCurState()
	return self.stat_machine:GetCurStateID()
end

function AppLoop:GetLoadingView()
	return self.loading_view
end

function AppLoop:AddState(id, path)
	local state = require(path).New()
	self.stat_machine:AddState(id, state)
end

app.AppLoop = AppLoop.New()

return AppLoop
