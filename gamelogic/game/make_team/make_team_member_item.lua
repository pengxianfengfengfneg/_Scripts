local MakeTeamMemberItem = Class(game.UITemplate)

local TeamMatchRobotWait = config.sys_config["team_match_robot_wait"].value

function MakeTeamMemberItem:_init(ctrl)
    self.ctrl = ctrl
    
end

function MakeTeamMemberItem:OpenViewCallBack()
	self:Init()
end

function MakeTeamMemberItem:CloseViewCallBack()
	self:StopRobotTimer() 
end

function MakeTeamMemberItem:Init()
	self.img_add = self._layout_objs["img_add"]

	self.group_info = self._layout_objs["group_info"]
	self.group_match = self._layout_objs["group_match"]

	self.txt_hire_time = self._layout_objs["txt_hire_time"]
	self.btn_hire = self._layout_objs["btn_hire"]

	--佣兵入队
	self.btn_hire:AddClickCallBack(function()
		self.ctrl:SendAddRobot()
	end)

	self.img_hire = self._layout_objs["img_hire"]

	self.img_career = self._layout_objs["img_career"]
	self.txt_name = self._layout_objs["txt_name"]
	self.txt_lv = self._layout_objs["txt_lv"]

	self.img_leader = self._layout_objs["img_leader"]

	self.head_icon = self:GetIconTemplate("head_icon")

	--请离队伍
	self.btn_kick = self._layout_objs["btn_kick"]
	self.btn_kick:AddClickCallBack(function()
		if self.is_robot then
			self.ctrl:SendKickRobot(self.role_id)
		else
			self.ctrl:SendTeamKickOut(self.role_id)
		end
	end)

	self.shape_click = self._layout_objs["shape_click"]
	self.shape_click:AddClickCallBack(function()
		if not self:HasMember() then
			self.ctrl:OpenInviteView()
		end
	end)
end

function MakeTeamMemberItem:UpdateData(data)
	self.has_member = data~=nil
	self.img_add:SetVisible(not self.has_member)
	self.group_info:SetVisible(self.has_member)	

	local is_robot = false
	local is_match = self.ctrl:IsTeamMatching()
	local is_self_leader = self.ctrl:IsSelfLeader()
	local team_target = self.ctrl:GetTeamTarget()
	local target_cfg = config.team_target[team_target]
	if target_cfg then
		is_robot = target_cfg.robot==1
	end

	local auto_robot = (is_self_leader and is_robot and (not self.has_member))
	self:ShowAutoRobot(auto_robot)

	if not data then
		return
	end

	local data = data.member

	self.career = data.career
	self.role_id = data.id
	self.member_name = data.name
	self.member_lv = data.level
	self.icon = data.icon
	self.is_robot = data.is_robot==true

	self.txt_name:SetText(self.member_name)

	local str_lv = self.member_lv
	if data.is_robot then
		str_lv = config.words[5023]
	end
	self.txt_lv:SetText(str_lv)

	self.img_hire:SetVisible(self.is_robot)

	self.btn_kick:SetVisible(not self:IsLeader() and (self:IsSelfLeader()))
	self.img_leader:SetVisible(self:IsLeader())


	self:UpdateCareer(self.career)
	self:UpdateHeadIcon(data)
end

function MakeTeamMemberItem:IsLeader()
	return self.ctrl:IsLeader(self.role_id)
end

function MakeTeamMemberItem:IsSelf()
	return game.Scene.instance:IsSelf(self.role_id)
end

function MakeTeamMemberItem:HasMember()
	return self.has_member
end

function MakeTeamMemberItem:IsSelfLeader()
	local role_id = game.Scene.instance:GetMainRoleID()
	return self.ctrl:IsLeader(role_id)
end

function MakeTeamMemberItem:UpdateCareer(career)
	self.career = career
	local res = game.CareerRes[career]
	self.img_career:SetSprite("ui_main", res)
end

function MakeTeamMemberItem:UpdateHeadIcon(data)
    self.head_icon:UpdateData(data)
end

function MakeTeamMemberItem:ShowAutoRobot(val)
	self:StopRobotTimer()

	local match_begin_time = self.ctrl:GetMatchBeginTime()
	local match_hire_time = match_begin_time + TeamMatchRobotWait

	local is_hire = match_begin_time==1
	
	local left_time = match_hire_time - global.Time:GetServerTime()
	local is_time = (left_time>0)

	local is_robot_match = (val and is_time)
	if is_robot_match then
		self:StartRobotTimer(left_time)
	end

	self.group_match:SetVisible(is_robot_match and (not is_hire))

	local is_self_leader = self.ctrl:IsSelfLeader()
	self.btn_hire:SetVisible(val and is_hire and is_self_leader)
end

function MakeTeamMemberItem:StartRobotTimer(left_time)
	local left_time = left_time or 0
	local min = math.ceil(left_time/60)
	self.txt_hire_time:SetText(string.format(config.words[5024], min))

	self.robot_timer = global.TimerMgr:CreateTimer(10, function()
		left_time = left_time - 10
		if left_time <= 0 then
			--self:ShowAutoRobot(false)
			return true
		end

		local min = math.ceil(left_time/60)
		self.txt_hire_time:SetText(string.format(config.words[5024], min))
	end)
end

function MakeTeamMemberItem:StopRobotTimer()
	if self.robot_timer then
		global.TimerMgr:DelTimer(self.robot_timer)
		self.robot_timer = nil
	end
end

return MakeTeamMemberItem
