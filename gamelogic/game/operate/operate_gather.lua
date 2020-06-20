
local OperateGather = Class(require("game/operate/operate_base"))

function OperateGather:_init()
	self.oper_type = game.OperateType.Gather
end

function OperateGather:Init(obj, target_id)
	OperateGather.super.Init(self, obj)
	self.target_id = target_id
end

function OperateGather:Start()
	if not self.obj:CanDoGather() then
		return false
	end

	local scene = self.obj:GetScene()
	local gather_obj = scene:GetObj(self.target_id)
	if not gather_obj then
		return false
	end

	local scene_logic = scene:GetSceneLogic()
    if not scene_logic:CanDoGather(gather_obj) then
    	self.obj:GetOperateMgr():ClearOperate()
        return false
    end

	self.obj:DoGather(self.target_id)
	return true
end

function OperateGather:Update(now_time, elapse_time)
	if self.obj:GetCurStateID() ~= game.ObjState.Gather then
		return true
	end
end

return OperateGather
