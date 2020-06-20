local SocietyCtrl = Class(game.BaseCtrl)

function SocietyCtrl:_init()
	if SocietyCtrl.instance ~= nil then
		error("SocietyCtrl Init Twice!")
	end
	SocietyCtrl.instance = self

	self.society_data = require("game/society/society_data").New()

	self:RegisterAllEvents()

	self:RegisterAllProtocal()
end

function SocietyCtrl:_delete()

	self.society_data:DeleteMe()
	self.society_data = nil

	if self.society_view then
		self.society_view:DeleteMe()
		self.society_view = nil
	end

	SocietyCtrl.instance = nil
end

function SocietyCtrl:RegisterAllEvents()
    local events = {
        -- {game.LoginEvent.LoginSuccess, handler(self, self.CsSocietyInfo)},
    }

    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SocietyCtrl:RegisterAllProtocal()
	self:RegisterProtocalCallback(31202, "ScSocietyInfo")
	self:RegisterProtocalCallback(31204, "ScSocietyGetReward")
	self:RegisterProtocalCallback(31206, "ScSocietyStarReward")
	self:RegisterProtocalCallback(31207, "ScSocietyNotifyTask")
end

--登录信息
function SocietyCtrl:CsSocietyInfo()
	self:SendProtocal(31201,{})
end

function SocietyCtrl:ScSocietyInfo(data)
	self.society_data:SetAllInfo(data)
	self:FireEvent(game.SocietyEvent.RefreshMainUI)
end

--领取任务奖励
function SocietyCtrl:CsSocietyGetReward(id_t)
	self:SendProtocal(31203,{id = id_t})
end

function SocietyCtrl:ScSocietyGetReward(data)
	self.society_data:UpdateStar(data)
	self:FireEvent(game.SocietyEvent.RefreshTaskState)
	self:FireEvent(game.SocietyEvent.RefreshStarAward)
	self:FireEvent(game.SocietyEvent.RefreshMainUI)
end

--领取星级奖励
function SocietyCtrl:CsSocietyStarReward(star_t)
	self:SendProtocal(31205,{star = star_t})
end

function SocietyCtrl:ScSocietyStarReward(data)
	self.society_data:UpdateStarStatus(data)
	self:FireEvent(game.SocietyEvent.RefreshStarAward)
	self:FireEvent(game.SocietyEvent.RefreshMainUI)
end

--任务有变化
function SocietyCtrl:ScSocietyNotifyTask(data)
	self.society_data:UpdateTaskStatus(data)
	self:FireEvent(game.SocietyEvent.RefreshTaskState)
	self:FireEvent(game.SocietyEvent.RefreshMainUI)
end

function SocietyCtrl:OpenView()
	if not self.society_view then
		self.society_view = require("game/society/society_view").New(self)
	end
	self.society_view:Open()
end

function SocietyCtrl:GetTasksByTag(tag_index)

	local list = {}

	local un_finish_list = {}
	local can_finish_list = {}
	local finished_list = {}

	for k, v in pairs(config.society_task) do
		if v.tag == tag_index then
			local state = self.society_data:GetTaskState(v.id)
			if state == 4 then
				table.insert(finished_list, v)
			elseif state == 3 then
				table.insert(can_finish_list, v)
			else
				table.insert(un_finish_list, v)
			end
		end
	end

	for k,v in ipairs(can_finish_list) do
		table.insert(list, v)
	end

	for k,v in ipairs(un_finish_list) do
		table.insert(list, v)
	end

	for k,v in ipairs(finished_list) do
		table.insert(list, v)
	end

	return list
end

function SocietyCtrl:GetData()
	return self.society_data
end

function SocietyCtrl:CheckActOpen()
	return self.society_data:CheckActOpen()
end

function SocietyCtrl:CheckAllHd()
	return self.society_data:CheckAllHd()
end

game.SocietyCtrl = SocietyCtrl

return SocietyCtrl