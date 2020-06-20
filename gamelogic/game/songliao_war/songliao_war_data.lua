local SongliaoWarData = Class(game.BaseData)
local sort_func = function(a, b)
	return a.rank < b.rank
end

function SongliaoWarData:_init()
	self.rank_list = {}
end

function SongliaoWarData:SetPrepareRoleNum(data)
	self.prepare_role_num = data.role_num
end

function SongliaoWarData:GetPrepareRoleNum()
	return self.prepare_role_num or 0
end

function SongliaoWarData:SetRankData(data)
	self.rank_data = data
	table.sort( self.rank_data.rank_list, sort_func)
end

function SongliaoWarData:GetRankData()
	return self.rank_data
end

function SongliaoWarData:SetResultData(data)
	self.result_data = data
	table.sort( self.result_data.rank_list, sort_func)
end

function SongliaoWarData:GetResultData()
	return self.result_data
end

function SongliaoWarData:SetTitleData(data)
	self.title_data = data.titles
	self.win_times = data.win_times
end

function SongliaoWarData:GetTitleData()
	return self.title_data
end

function SongliaoWarData:GetWinTimes()
	return self.win_times or 0
end

function SongliaoWarData:UpdateTitleData(add_id)
	if self.title_data then
		local t = {}
		t.id = add_id
		table.insert(self.title_data, t)
	end
end

function SongliaoWarData:CheckTitleGet(title_id)

	local is_get = false

	for k,v in pairs(self.title_data) do
		if v.id == title_id then
			is_get = true
			break
		end
	end

	return is_get
end

return SongliaoWarData