local PassBossData = Class(game.BaseData)

local table_insert = table.insert

local config_scene = config.scene
local config_monster = config.mon
local config_task = config.task
local config_task_pass = config.task_pass
local config_task_pass_sort = {}

function PassBossData:_init()
    self:InitConfig()
end

function PassBossData:_delete()

end

function PassBossData:InitConfig()
	config_task_pass_sort = {}
	for _,v in pairs(config.task_pass or {}) do
		if not config_task_pass_sort[v.scene] then
			config_task_pass_sort[v.scene] = {pass = v.pass}
		end

		if not config_task_pass_sort[v.scene][v.chapter] then
			config_task_pass_sort[v.scene][v.chapter] = {}
		end

		if not config_task_pass_sort[v.scene][v.chapter][v.section] then
			config_task_pass_sort[v.scene][v.chapter][v.section] = {}
		end

		table_insert(config_task_pass_sort[v.scene][v.chapter][v.section], v)
	end

	local function sortSection(v1,v2)
		return v1.subsection<v2.subsection
	end

	for _,v in pairs(config_task_pass_sort) do
		for _,cv in ipairs(v) do
			for _,ccv in ipairs(cv) do
				table.sort(ccv, sortSection)
			end
		end
	end
end

function PassBossData:OnGetTaskBossInfoResp(data)
	self.task_pass_info = data

	self.cur_pass_id = data.pass
	self.cur_pass_state = data.stat
end

function PassBossData:OnGetPassRewardResp(data)
	--[[
        "ret__C",
        "pass__I",
        "rewards__T__pass@I",
    ]]

    self.task_pass_info.pass = data.pass
    self.task_pass_info.rewards = data.rewards
end

function PassBossData:OnNotifyPassProcChange(data)
	--[[
        "pass__I",
        "stat__C",
        "proc__T__mon_id@I##cur@H##require@H",
    ]]

    self.task_pass_info.pass = data.pass
    self.task_pass_info.stat = data.stat
    self.task_pass_info.proc = data.proc

    self.cur_pass_id = data.pass
	self.cur_pass_state = data.stat
end

function PassBossData:GetPassAcceptRequireInfo()
	return (self.task_pass_info or {}).proc or {}
end

function PassBossData:IsSectionCompleted(pass_id)
	local pass_cfg = config_task_pass[pass_id]
	if not pass_cfg then
		return false
	end

	local scene = pass_cfg.scene
	local chapter = pass_cfg.chapter
	local section = pass_cfg.section

	local section_cfg = config_task_pass_sort[scene][chapter][section]
	for _,v in ipairs(section_cfg) do
		if not self:IsPassFinished(v.pass) then
			return false
		end
	end
	return true
end

function PassBossData:IsChapterCompleted(pass_id)
	local pass_cfg = config_task_pass[pass_id]
	if not pass_cfg then
		return false
	end

	local chapter_cfg = config_task_pass_sort[pass_cfg.scene][pass_cfg.chapter]
	if not chapter_cfg then
		return false
	end

	for _,v in pairs(chapter_cfg or {}) do
		if not self:IsSectionCompleted(v.section) then
			return false
		end
	end
	return true
end

function PassBossData:CalcSectionProgress(pass_id)
	local pass_cfg = config_task_pass[pass_id]

	local scene = pass_cfg.scene
	local chapter = pass_cfg.chapter
	local section = pass_cfg.section

	local finish_num = 0
	local section_cfg = config_task_pass_sort[scene][chapter][section]
	local section_num = #section_cfg
	for _,v in ipairs(section_cfg) do
		if self:IsPassFinished(v.pass) then
			finish_num = finish_num + 1
		end
	end

	return (finish_num/section_num)*100
end

function PassBossData:IsPassFinished(pass_id)
	return (pass_id<self.cur_pass_id or (pass_id==self.cur_pass_id and self.cur_pass_state==4))
end

function PassBossData:GetChapterName(pass_id)
	local cfg = config_task_pass[pass_id]
	if not cfg then return "" end

	local scene_cfg = config_scene[cfg.scene] or {}
	return scene_cfg.name or ""
end

function PassBossData:GetSectionName(pass_id)
	local cfg = config_task_pass[pass_id]
	if not cfg then return "" end

	local scene_cfg = config_scene[cfg.scene] or {}
	return string.format("%s%s", scene_cfg.name or "", cfg.section)
end

function PassBossData:CanChallengePass()
	return (self.cur_pass_state==2)
end

function PassBossData:IsDoingChallenge()
	return (self.cur_pass_state==3)
end

function PassBossData:GetCurPassState()
	return self.cur_pass_state
end

function PassBossData:GetCurPassId()
	return self.cur_pass_id
end

function PassBossData:GetPassFuncId()
	-- body
end

function PassBossData:GetPassRewardList()
	return (self.task_pass_info or {}).rewards or {}
end

function PassBossData:GetPassSectionRewardId(pass_id)
	local pass_cfg = config_task_pass[pass_id]

	local scene = pass_cfg.scene
	local chapter = pass_cfg.chapter
	local section = pass_cfg.section

	local finish_num = 0
	local section_cfg = config_task_pass_sort[scene][chapter][section]
	local cfg = section_cfg[#section_cfg]

	return cfg.reward[1]
end

function PassBossData:GetCurPassScene()
	local pass_cfg = config_task_pass[self.cur_pass_id] or {}
	return pass_cfg.scene or 0
end

function PassBossData:GetCurChapter()
	local pass_cfg = config_task_pass[self.cur_pass_id] or {}
	return pass_cfg.chapter or 1
end

function PassBossData:GetCurChapterConfig()
	local pass_cfg = config_task_pass[self.cur_pass_id] or {}
	local chapter_cfg = config_task_pass_sort[pass_cfg.scene][pass_cfg.chapter] or {}

	local result = {}
	for k,v in pairs(config_task_pass_sort) do
		table.insert(result, {
				scene = k,
				pass = v.pass
			})
	end
	table.sort(result,function(v1,v2)
			return v1.pass<v2.pass
		end)
	return result
end

function PassBossData:GetPassSceneConfig(scene_id)
	return config_task_pass_sort[scene_id]
end

return PassBossData
