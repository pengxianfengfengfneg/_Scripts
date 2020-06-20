local GuideData = Class(game.BaseData)

local global_time = global.Time
local event_mgr = global.EventMgr
local string_gsub = string.gsub
local string_format = string.format

function GuideData:_init(ctrl)
    self.ctrl = ctrl

    self.newbie_guide = {}
end

function GuideData:_delete()

end

function GuideData:OnGetGuideInfo(data)
	self.newbie_guide = data.newbie_guide
end

function GuideData:GetGuideFinishTimes(guide_id)
	for key, var in pairs(self.newbie_guide or{}) do

		if var.id == guide_id then
			return var.num
		end
	end

	return 0
end

function GuideData:IsGuideDone(guide_id)

	for _,v in ipairs(self.newbie_guide or {}) do
	    if v.id == guide_id then
	        local guide_info = config.new_step[guide_id]
	        if not guide_info then
	            return false
	        end
	        return v.num >= guide_info[1].do_times
	    end
	end

	return false
end

--[[
function GuideData:UpdateGuideNum(guide_step_info)
print("--------------------------UpdateGuideNum----") PrintTable(guide_step_info)
	local guide_id = guide_step_info.id
	local step = guide_step_info.step
	local max_step = #config.new_step[guide_id]

	local f = false
	local do_num
	if step == max_step then

		for _,v in ipairs(self.newbie_guide or {}) do
			if v.id == guide_id then
				v.num = v.num + 1
				do_num = v.num
				f = true
				break
			end
		end

		if not f then
			local t = {id = guide_id, num = 1}
			do_num = 1
			table.insert(self.newbie_guide, t)
		end

		--通知后端
		self.ctrl:UpdateGuideNumReq(guide_id, do_num)
	end
end
]]

function GuideData:UpdateGuideNum(guide_step_info)

	local guide_id = guide_step_info.id
	local step = guide_step_info.step

	local f = false
	local do_num

	for _,v in ipairs(self.newbie_guide or {}) do
		if v.id == guide_id then
			v.num = v.num + 1
			do_num = v.num
			f = true
			break
		end
	end

	if not f then
		local t = {id = guide_id, num = 1}
		do_num = 1
		table.insert(self.newbie_guide, t)
	end

	--通知后端
	self.ctrl:UpdateGuideNumReq(guide_id, do_num)
end

return GuideData
