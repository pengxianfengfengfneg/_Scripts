local GatherState = Class()

function GatherState:_init(obj)
	self.obj = obj
end

function GatherState:_delete()
	if self.gather_effect then
		game.EffectMgr.instance:StopEffect(self.gather_effect)
		self.gather_effect = nil
	end

	if self.target_effect then
		game.EffectMgr.instance:StopEffect(self.target_effect)
		self.target_effect = nil
	end
end

function GatherState:StateEnter(target_id)	
	self.target_id = target_id

	local target = self.obj.scene:GetObj(target_id)
	local duration = 1
	self.is_gather_fail = false

	if target then
		duration = target:GetDuration()
		self.obj:SetDir(target.unit_pos.x - self.obj.unit_pos.x, target.unit_pos.y - self.obj.unit_pos.y)

		if self.obj:IsMainRole() then			
			local coll_id = target:GetGatherId()

			local coll_cfg = config.gather[coll_id]
			-- 播放特效
			if coll_cfg and coll_cfg.role_effect ~= "" then
				self.gather_effect = game.EffectMgr.instance:CreateEffect(string.format("effect/scene/%s.ab", coll_cfg.role_effect), 10)
				self.gather_effect:SetLoop(true)
				self.gather_effect:SetParent(self.obj:GetRoot())

			end

			-- 珍兽特效
			if coll_cfg and coll_cfg.effect ~= "" and coll_cfg.classify == 1 and self.target_effect == nil then
				self.target_effect = game.EffectMgr.instance:CreateEffect(string.format("effect/scene/%s.ab", coll_cfg.effect), 10)
				self.target_effect:SetLoop(true)
				self.target_effect:SetParent(target:GetRoot())
			end

			local gather_ctrl = game.GatherCtrl.instance

			local vitality_str = nil
			local gather_state = gather_ctrl:CheckGatherState(coll_id, true)
			if gather_state == 0 then
				-- 不属于采集技能物品，使用通用采集
				self.obj:SendCollectReq(target.uniq_id, coll_id)
			elseif gather_state == 1 then
				-- 属于采集技能物品
				vitality_str = gather_ctrl:GetVitalityStr()

				local is_quick = gather_ctrl:IsQuickGather()
				local offset_time = (is_quick and 0.1 or 0.3)
				duration = target:GetDuration(is_quick, offset_time)
				gather_ctrl:SendGatherColl(target.uniq_id, coll_id)
			elseif gather_state == 2 then
				-- 属于采集技能物品，技能等级不足
				self.is_gather_fail = true
			elseif gather_state == 3 then
				-- 属于采集技能物品，活力不足
				self.is_gather_fail = true
			end			

			if not self.is_gather_fail then
				global.EventMgr:Fire(game.SceneEvent.GatherChange, true, target:GetName(), duration, vitality_str)
			end
		end
	end
	
	if not self.is_gather_fail then
		self.obj:SetMountState(0)
		self.obj:PlayStateAnim()
		self.end_time = global.Time.now_time + duration
	end
end

function GatherState:StateUpdate(now_time, elapse_time)
	if self.is_gather_fail then
		self.obj:DoIdle()
		return
	end

	local target = self.obj.scene:GetObj(self.target_id)
	if not target or now_time > self.end_time then
		self.obj:DoIdle()
	end
end

function GatherState:StateQuit()
	if self.obj:IsMainRole() and not self.is_gather_fail then
		global.EventMgr:Fire(game.SceneEvent.GatherChange, false)
	end

	if self.gather_effect then
		game.EffectMgr.instance:StopEffect(self.gather_effect)
		self.gather_effect = nil
	end

	if self.target_effect then
		game.EffectMgr.instance:StopEffect(self.target_effect)
		self.target_effect = nil
	end
end

return GatherState