local ChangeSceneState = Class()

function ChangeSceneState:_init(obj)
	self.obj = obj
end

function ChangeSceneState:_delete()
	if self.change_effect then
		game.EffectMgr.instance:StopEffect(self.change_effect)
        self.change_effect = nil
	end
end

function ChangeSceneState:StateEnter(scene_id, change_func, line_id, is_follow)
	self.obj:SetMountState(0)

	self.scene_id = scene_id
	self.change_func = change_func
	self.line_id = line_id or self.obj:GetScene():GetServerLine()
	self.is_follow = is_follow or false

	self.obj:PlayStateAnim()

	self.is_change_done = false

	-- 播放特效
	self.change_effect = game.EffectMgr.instance:CreateEffect(string.format("effect/scene/%s.ab", "home"), 10)
    self.change_effect:SetLoop(true)
    self.change_effect:SetParent(self.obj:GetRoot())

	self.change_scene_time = 3
	global.EventMgr:Fire(game.SceneEvent.OperateChangeScene, true, self.scene_id, self.change_scene_time)
end

function ChangeSceneState:StateUpdate(now_time, elapse_time)
	if not self.is_change_done then
		self.change_scene_time = self.change_scene_time - elapse_time
		if self.change_scene_time <= 0 then
			self.is_change_done = true
			if self.change_func then
				self.change_func()
				self.obj:DoIdle()
			else
				self.obj:GetScene():SendChangeSceneReq(self.scene_id, self.line_id, self.is_follow)
			end
		end
	end
end

function ChangeSceneState:StateQuit()
	global.EventMgr:Fire(game.SceneEvent.OperateChangeScene, false)

	if self.change_effect then
		game.EffectMgr.instance:StopEffect(self.change_effect)
        self.change_effect = nil
	end
	self.change_func = nil
end

function ChangeSceneState:IsDone()
	return self.is_change_done
end

return ChangeSceneState