local FireworkData = Class(game.BaseData)

local global_time = global.Time

function FireworkData:_init()
    
end

function FireworkData:_delete()

end

function FireworkData:OnFireworkInfo(data)
	self.firework_info = data
end

return FireworkData
