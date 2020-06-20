
local AiBase = Class()

function AiBase:_init(mgr, obj, ai_type)
	self.ai_mgr = mgr
	self.ai_obj = obj
	self.ai_type = ai_type
	self.is_pause = false
end

function AiBase:_delete()

end

function AiBase:Init(obj)
	self.obj = obj
end

function AiBase:SetObj(obj)
	self.obj = obj
end

function AiBase:GetType()
	return self.ai_type
end

function AiBase:Pause()
	self.is_pause = true
end

function AiBase:Resume()
	self.is_pause = false
end

function AiBase:Update(now_time, elapse_time)
	if self.is_pause then
		return
	end
end

function AiBase:GetSpeed()
	return self.ai_speed
end

function AiBase:SetSpeed(val)
	self.ai_speed = val
end

return AiBase
