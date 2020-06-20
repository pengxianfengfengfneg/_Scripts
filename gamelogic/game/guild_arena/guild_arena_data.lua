local GuildArenaData = Class(game.BaseData)

function GuildArenaData:_init()

end

function GuildArenaData:SetRestRoomData(data)
	self.rest_room_data = data
end

function GuildArenaData:GetRestRoomData()
	return self.rest_room_data
end

function GuildArenaData:SetFirstFightData(data)
	self.first_fight_data = data
end

function GuildArenaData:GetFirstFightData()
	return self.first_fight_data
end

function GuildArenaData:SetSecondFightData(data)
	self.second_fight_data = data
end

function GuildArenaData:GetSecondFightData()
	return self.second_fight_data
end


return GuildArenaData