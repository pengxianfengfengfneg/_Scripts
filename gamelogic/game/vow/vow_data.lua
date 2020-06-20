local VowData = Class(game.BaseData)

function VowData:_init()

end

function VowData:_delete()

end

--契约信息
function VowData:SetDeedData(data)
	self.all_deed_data = data
end

--是否有契约
function VowData:InDeedState()
	local state = false

	if self.all_deed_data then
		local end_time = self.all_deed_data.end_time
		local cur_time = global.Time:GetServerTime()

		if cur_time < end_time then
			state = true
		end
	end

	return state
end

function VowData:GetDeedData()
	return self.all_deed_data
end

function VowData:GetMyCurDeed()
	if self.all_deed_data then
		return self.all_deed_data.deed
	else
		return 0
	end
end

function VowData:SetVowInfo(data)
	self.all_vow_data = data
end

function VowData:GetVowInfo()
	return self.all_vow_data
end

function VowData:SetMyLikeVowInfo(data)
	if self.all_vow_data then
		self.all_vow_data.vow_list = data.vow_list
	end
end

function VowData:GetVowList()
	local list = {}
	if self.all_vow_data then
		list = self.all_vow_data.vow_list
	end
	return list
end

function VowData:AddAgreeData(data)
	if self.all_vow_data then
		for k,v in pairs(self.all_vow_data.vow_list) do
			if v.role_id == data.target_id then
				v.like_num = v.like_num + 1
				break
			end
		end
	end
end

function VowData:SubAgreeData(data)
	if self.all_vow_data then
		for k,v in pairs(self.all_vow_data.vow_list) do
			if v.role_id == data.target_id then
				v.like_num = v.like_num - 1
				break
			end
		end
	end
end

function VowData:GetTaskIdList(wday)
	local list = {}

	for k,v in pairs(config.vow_task) do
		if v.day == wday then
			table.insert(list, v.id)
		end
	end

	table.sort(list, function(a, b)
		return a < b
	end)

	return list
end

function VowData:ChangeDeedList(data)
	if self.all_deed_data then
		self.all_deed_data.deed = data.deed
		self.all_deed_data.complete = data.complete
	end
end

function VowData:GetTaskFinishTimes(task_id)

	local complete_times = 0

	for k,v in pairs(self.all_deed_data.complete) do

		local exist = false

		for j,k in pairs(v.progress.list) do
			if k.id == task_id then
				complete_times = k.times
				exist = true
				break
			end
		end

		if exist then
			break
		end
	end

	return complete_times
end

function VowData:UpdateDeedData(data)
	if self.all_deed_data then
		self.all_deed_data.target_name = data.target_name
		self.all_deed_data.end_time = data.end_time
	end
end

function VowData:CheckRewardGet(index)

	local get = false

	if self.all_deed_data then
		for k,v in pairs(self.all_deed_data.get_list) do
			if v.id == index then
				get = true
				break
			end
		end
	end

	return get
end

function VowData:UpdateDeedReward(data)
	if self.all_deed_data then
		local t = {}
		t.id = data.id
		table.insert(self.all_deed_data.get_list, t)
	end
end

function VowData:GetActivityViewTabIndex()

	local index = 1

	if self.all_deed_data then
		local end_time = self.all_deed_data.end_time
		local cur_time = global.Time:GetServerTime()
		local off_time = end_time - cur_time
		if off_time > 0 then
			local left_day = math.floor(off_time/86400)
			index = 7 - left_day
		end
	end

	return index
end

return VowData