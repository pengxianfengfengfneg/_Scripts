local WorldBossStageItem = Class(game.UITemplate)

local config_world_boss_level = config.world_boss_level

function WorldBossStageItem:_init(data, world_lv)
	self.stage_data = data or {}

	self.world_lv = world_lv
end

function WorldBossStageItem:OpenViewCallBack()
	self:Init()
end

function WorldBossStageItem:CloseViewCallBack()
    
end

function WorldBossStageItem:Init()
	self.img_stage = self._layout_objs["img_stage"]	
	self.img_select = self._layout_objs["img_select"]	

	self.list_stars = self._layout_objs["list_stars"]	
	self.rtx_time = self._layout_objs["rtx_time"]	

	self.img_stage:SetSprite("ui_world_boss", self.stage_data.res)
	self.list_stars:SetItemNum(self:GetStar())

	self:UpdateTimeTips()
end

function WorldBossStageItem:UpdateData(data)
	
end

function WorldBossStageItem:GetName()
	return self.stage_data.name
end

function WorldBossStageItem:GetStar()
	return self.stage_data.star
end

function WorldBossStageItem:GetBossId()
	if not self.boss_id then
		local boss_list = self.stage_data.boss_list or {}
		self.boss_id = boss_list[1]
		for _,v in ipairs(boss_list) do
			local cfg = config_world_boss_level[v]
			if cfg and cfg[1].reward_show[1] then
				self.boss_id = v
				break
			end
		end
	end
	return self.boss_id
end

function WorldBossStageItem:GetAwards()
	local boss_id = self:GetBossId()
	local cfg = config_world_boss_level[boss_id]
	local awrad_cfg = cfg[1]
	for _,v in ipairs(cfg or {}) do
		if self.world_lv <= v.world_lv then
			awrad_cfg = v
		end
	end

	return awrad_cfg.reward_show
end

function WorldBossStageItem:GetTime()
	
end

function WorldBossStageItem:GetId()
	return self.stage_data.id
end

function WorldBossStageItem:GetLayer()
	return self.stage_data.layer
end

function WorldBossStageItem:GetSceneId()
	return self.stage_data.scene_id
end

function WorldBossStageItem:GetWorldLv()
	return self.stage_data.world_lv
end

function WorldBossStageItem:OnUpdateActivity()
	self:UpdateTimeTips()
end

function WorldBossStageItem:OnStopActivity()
	self:UpdateTimeTips()
end

function WorldBossStageItem:UpdateTimeTips()
	local act_id = game.ActivityId.WorldBoss
	local act_info = game.ActivityMgrCtrl.instance:GetActivity(act_id)
    if act_info then
        self.rtx_time:SetText(config.words[4464])
    else
        local coming_info = game.ActivityMgrCtrl.instance:GetActComingTime(act_id)
        local str_time = string.format(config.words[4461], coming_info.hour, coming_info.min)
        self.rtx_time:SetText(string.format(config.words[4465], str_time))
    end
end

return WorldBossStageItem
