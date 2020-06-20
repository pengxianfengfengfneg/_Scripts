local RoleOtherTemplate = Class(game.UITemplate)

local other_cfg = {
	{
		name = config.words[5570],
		get_func = function()
			local id = game.Scene.instance:GetMainRoleID()
			return tostring(id)
		end,
	},
	{
		name = config.words[5571],
		get_func = function()
			local mate_name = game.MarryCtrl.instance:GetMateName()
			if mate_name and mate_name ~= "" then
				return mate_name
			else
				return config.words[5590]
			end
		end,
	},
	{
		name = config.words[5572],
		get_func = function()
			return config.words[5591]
		end,
	},
	{
		name = config.words[5573],
		get_func = function()
			local exp = game.ActivityMgrCtrl.instance:GetDailyLivelyExp()
			return string.format("%d/%d", exp, config.daily_lively_reward[1].max_exp)
		end,
		notice_func = function()
			game.GameMsgCtrl.instance:OpenInfoDescView(3)
		end,
	},
	{
		name = config.words[5574],
		get_func = function()
			return game.LakeExpCtrl.instance:GetKillMonNum()
		end,
		notice_func = function()
			game.GameMsgCtrl.instance:OpenInfoDescView(4)
		end,
	},
	{
		name = config.words[5575],
		get_func = function()
			local vo = game.Scene.instance:GetMainRoleVo()
			if vo then
				return vo.murderous
			else
				return 0
			end
		end,
		notice_func = function()
			game.GameMsgCtrl.instance:OpenInfoDescView(5)
		end,
	},
	{
		name = config.words[5576],
		get_func = function()
			return ""
		end,
	},
	{
		name = config.words[5577],
		get_func = function()
			return ""
		end,
	},
	{
		name = config.words[5578],
		get_func = function()
			return game.BagCtrl.instance:GetMoneyByType(game.MoneyType.Prestige)
		end,
	},
}

function RoleOtherTemplate:_init(view)
    self.ctrl = game.RoleCtrl.instance
end

function RoleOtherTemplate:OpenViewCallBack()
	local events = {
        {game.LakeExpEvent.UpdateKillMonNum, handler(self,self.RefreshData)},
        {game.RoleEvent.PersonalInfoChange, handler(self,self.RefreshNotice)},
    }

    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end

	self._layout_objs["btn_fix"]:AddClickCallBack(function()
		self.ctrl:OpenRoleNoticeView()
	end)

	self.ctrl:SendGetCommonlyKeyValue()

	self:RefreshData()
	self:RefreshNotice()
end

function RoleOtherTemplate:CloseViewCallBack()
end

function RoleOtherTemplate:RefreshData()
	local idx = 1
	for i,v in ipairs(other_cfg) do
		idx = i + 1
		self._layout_objs["n" .. i]:SetText(v.name)
		self._layout_objs["v" .. i]:SetText(v.get_func())
		if v.notice_func then
			self._layout_objs["btn_notice" .. i]:AddClickCallBack(v.notice_func)
		end
	end

	for i=idx,9 do
		self._layout_objs["cn" .. i]:SetVisible(false)
		self._layout_objs["cv" .. i]:SetVisible(false)
		self._layout_objs["cbtn" .. i]:SetVisible(false)
	end
end

function RoleOtherTemplate:RefreshNotice()	
	local msg = game.RoleCtrl.instance:GetPersonalInfo()
	if msg == "" then
		msg = config.words[5592]
	end
	self._layout_objs["notice_txt"]:SetText(msg)
end

return RoleOtherTemplate
