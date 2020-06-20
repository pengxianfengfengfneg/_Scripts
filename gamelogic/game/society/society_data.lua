local SocietyData = Class(game.BaseData)

function SocietyData:_init()

end

function SocietyData:SetAllInfo(data)
	self.all_info = data
end

function SocietyData:GetAllInfo()
	return self.all_info
end

--领取修改状态为 已领取
function SocietyData:UpdateStar(data)
	self.all_info.star = data.star

	for k,v in pairs(self.all_info.tasks) do
		if v.id == data.id then
			v.state = 4
			break
		end
	end
end

function SocietyData:GetStar()
	return self.all_info.star
end

function SocietyData:GetCurGotList()
	return self.all_info.status
end

function SocietyData:UpdateStarStatus(data)
	if self.all_info then
		self.all_info.star = data.star

		for k, v in pairs(data.status) do
			local t = {}
			t.star = v.star
			table.insert(self.all_info.status, t)
		end
	end
end

function SocietyData:UpdateTaskStatus(data)

	if self.all_info then
		for k, v in pairs(data.tasks) do

			for i, j in pairs(self.all_info.tasks) do

				if j.id == v.id then
					j.current = v.current
					j.state = v.state
					break
				end
			end
		end
	end
end

function SocietyData:GetTaskState(taks_id)
	local state = 0

	if self.all_info then
		for k, v in pairs(self.all_info.tasks) do
			if v.id == taks_id then
				state = v.state
				break
			end
		end
	end

	return state
end

function SocietyData:GetOpenTime()
	return self.all_info.open_time
end

function SocietyData:CheckActOpen()
	if self.all_info then
		local start_day = game.Utils.NowDaytimeStart(self.all_info.open_time)
		local now_day = global.Time:GetServerTime()

		if (now_day - start_day) <= 604800 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function SocietyData:CheckHdByTab(tab_index)

	local can_get = false
	local data_list = game.SocietyCtrl.instance:GetTasksByTag(tab_index)

	for k,v in pairs(data_list) do
		local state = self:GetTaskState(v.id)
		if state == 3 then
			can_get = true
			break
		end
	end

	return can_get
end

function SocietyData:CheckAllHd()

    local open_time = self:GetOpenTime()
    local cur_time = global.Time:GetServerTime()
    local open_day = math.floor(open_time/86400)
    local cur_day = math.floor(cur_time/86400)
    local off_day = cur_day - open_day + 1      --现在是开启的第几天

    local max_index = 0
    for k, v in ipairs(config.society_tag) do
        if off_day >= v.open_day then
            max_index = k
        end
    end

    local can_get = false

    --任务奖励
    for i = 1, 5 do
        if i <= max_index then
            if self:CheckHdByTab(i) then
            	can_get = true
            	break
            end
        end
    end

    --星级奖励
    local cur_star = self:GetStar()
    local cur_got_list = self:GetCurGotList()
    for index, v in ipairs(config.society_star) do
    	if cur_star >= v.star then

    		local got_flag = false
            for i, j in pairs(cur_got_list) do
                if j.star == v.star then
                    got_flag = true
                    break
                end
            end

            if not got_flag then
            	can_get = true
            	break
            end
    	end
    end

    return can_get
end

return SocietyData