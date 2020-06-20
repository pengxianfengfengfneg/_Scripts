local GatherData = Class(game.BaseData)

local et = game.EmptyTable

function GatherData:_init()
    self.gather_info = {}
end

function GatherData:_delete()

end

function GatherData:OnGatherInfo(data)
    --[[
        "vitality__H",
        "skills__T__id@H##level@C##exp@H",
    ]]
    
    self.gather_info = data
end

function GatherData:OnGatherUpgrade(data)
    --[[
        "id__C",
        "level__C",
        "exp__H",
    ]]
    if not self.gather_info then return end
    
    for _,v in ipairs(self.gather_info.skills) do
    	if data.id == v.id then
    		v.level = data.level
    		v.exp = data.exp
    	end
    end
end

function GatherData:OnGatherColl(data)
    --[[
        "vitality__H",
    ]]
    if not self.gather_info then return end
    
    self.gather_info.vitality = data.vitality
end

function GatherData:GetGatherSkills()
	return self.gather_info.skills or et
end

function GatherData:GetGatherSkillInfo(id)
	local skills = self:GetGatherSkills()
	for _,v in ipairs(skills) do
		if v.id == id then
			return v
		end
	end
end

function GatherData:GetGatherVitality()
	return self.gather_info.vitality or 0
end

return GatherData
