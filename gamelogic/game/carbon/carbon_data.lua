local CarbonData = Class(game.BaseData)

function CarbonData:_init()
	self.dunge_data = {}
	self.auto_start = {}
end

function CarbonData:_delete()

end

function CarbonData:SetDungeData(data)
	self.dunge_data = data
end

--更新单个副本数据
function CarbonData:UpdateSingleDungeInfo(single_dunge_data)

	for key, var in pairs(self.dunge_data.dungs) do

		if var.dung.id == single_dunge_data.dung.id then
			var.dung = single_dunge_data.dung
		end
	end
end


--获取对应副本信息 #proto.CltDungeon
function CarbonData:GetDungeDataByID(dunge_id)

	for key, var in pairs(self.dunge_data.dungs or {}) do

		if var.dung.id == dunge_id then
			return var.dung
		end
	end
end

--获取材料副本列表
function CarbonData:GetMaterialCarbons()

	local dunge_id_list = {}

	for key, var in pairs(config.dungeon) do

		if var.dun_type == game.CarbonType.MatrialCarbon then

			table.insert(dunge_id_list, var.dungeon_id)
		end
	end

	table.sort(dunge_id_list,  function (a, b)
		return a < b
	end)

	return dunge_id_list
end

--获取材料副本剩余挑战次数
function CarbonData:GetMaterialCarbonsChanTimes(dunge_id)

	local dunge_data
	local daily_his
	local has_chan_times = 0
	local left_chan_times = 0

	for key, var in pairs(self.dunge_data.dungs or {}) do

		if var.dung.id == dunge_id then
			dunge_data = var.dung
		end
	end

	if dunge_data then

		daily_his = dunge_data.daily_his
		if daily_his[1] then
			has_chan_times = daily_his[1].times
		else
			has_chan_times = 0
		end

		local cfg_chan_times = config.dungeon[dunge_id].chal_times
		left_chan_times = cfg_chan_times - has_chan_times
	end

	return left_chan_times
end

function CarbonData:GetResetTimes(dunge_id)

	local reset_times = 0

	for key, var in pairs(self.dunge_data.dungs or {}) do

		if var.dung.id == dunge_id then
			reset_times = var.dung.reset_times
		end
	end

	return reset_times
end

function CarbonData:CanWipe(dunge_id)

	--副本可扫荡
	local cfg_wipe = config.dungeon[dunge_id].can_wipe == 1
	if not cfg_wipe then
		return false
	end

	--副本扫荡等级够
	local role_lv = game.Scene.instance:GetMainRoleLevel()
	local cfg_wipe_lv = config.dungeon[dunge_id].wipe_lv
	if role_lv < cfg_wipe_lv then
		return false
	end

	--历史上通关过
	local his_fishied = false
	for key, var in pairs(self.dunge_data.dungs or {}) do

		if var.dung.id == dunge_id then
			
			if var.dung.star_info[1] then
				his_fishied = true
			end
		end
	end
	if not his_fishied then
		return false
	end

	return true
end

--[[
	return 第一个参数表示 挑战类型 或者 扫荡类型
		   第二个参数表示当前类型是否能扫荡
]]
function CarbonData:GetDungeWipeState(dunge_id)

	local left_chan_times = self:GetMaterialCarbonsChanTimes(dunge_id)
	--有挑战次数1
	if left_chan_times > 0 then
		--能扫荡1.1
		if self:CanWipe(dunge_id) then
			return 1, 1

		--不能扫荡
		else
			return 1, 0
		end
	--没有挑战次数2
	else

		local reseted_times = self:GetResetTimes(dunge_id)
		local vip_lv = game.Scene.instance:GetMainRoleVipLv() or 0
		local wipe_times = config.dungeon[dunge_id].reset_times[vip_lv+1][2]
		local left_reset_times = wipe_times - reseted_times
		local cost = config.dungeon[dunge_id].reset_cost[reseted_times+1][2] or 0
		--vip有扫荡次数
		if left_reset_times > 0 then
			return 2, 1, left_reset_times, cost
		else
			return 2, 0, left_reset_times, 0
		end
	end
end

function CarbonData:UpdateDungeData(data)

	local target_dunge_id = data.dung.id

	for key, var in pairs(self.dunge_data.dungs or {}) do

		if var.dung.id == target_dunge_id then
			var.dung = data.dung
		end
	end
end

-- 挑战副本次数 {1, 副本类型, 次数}
function CarbonData:CheckChanTimesByType(dunge_type, need_times)

	local chan_times = 0

	for key, var in pairs(self.dunge_data.dungs or {}) do

		local dun_type = config.dungeon[var.dung.id].dun_type
		if dun_type == dunge_type then

			if var.dung.life_his[1] then
				chan_times = chan_times + var.dung.life_his[1].times
			end
		end
	end

	return chan_times >= need_times
end

--挑战副本波数 {2, 副本ID, 波数}
function CarbonData:CheckLvWave(dunge_id, need_lv, need_wave)

	local flag = false

	for key, var in pairs(self.dunge_data.dungs or {}) do
		if var.dung.id == dunge_id then

			if var.dung.max_lv > need_lv then
				return true
			elseif var.dung.max_lv == need_lv then
				if var.dung.max_wave > need_wave then
					return true
				end
			end
		end
	end

	return flag
end

function CarbonData:SetAutoStart(id, val)
	self.auto_start[id] = val
end

function CarbonData:GetAutoStart(id)
	return self.auto_start[id]
end

function CarbonData:SetChapterRwd(data)
	for i, v in pairs(self.dunge_data.dungs or {}) do
		if v.dung.id == data.dung_id then
			v.dung.chapter_reward = data.chapter_reward
			break
		end
	end
end

function CarbonData:SetFirstRwd(data)
	for i, v in pairs(self.dunge_data.dungs or {}) do
		if v.dung.id == data.dung_id then
			v.dung.first_reward = data.first_reward
			break
		end
	end
end

function CarbonData:OnDungData(data)
	self.dun_fight_data = data
end

function CarbonData:GetDunFightData()
	return self.dun_fight_data
end

function CarbonData:ResetDunFightData()
	self.dun_fight_data = nil
end

function CarbonData:GetDungeonData()
	return self.dunge_data
end

function CarbonData:GetMaxLv(carbon_id)
	local dun_data = self:GetDungeDataByID(carbon_id)
	if dun_data then
		local max_lv = dun_data.max_lv
		local dun_cfg = config.dungeon_lv[carbon_id]
		if max_lv > #dun_cfg then
			max_lv = #dun_cfg
		else
			if max_lv > 0 then
				max_lv = max_lv - 1
			end
		end
		return max_lv
	else
		return 0
	end
end

function CarbonData:OnDungTeamStatus(data)
	self.dun_team_state_data = data
end

function CarbonData:GetDunTeamStateData()
	return self.dun_team_state_data
end

function CarbonData:SetHeroDungeInfo(data)
	self.hero_dunge_id = data.dung_id
end

function CarbonData:GetHeroDungeId()
	return self.hero_dunge_id or 0
end

return CarbonData