local MakeTeamItem = Class(game.UITemplate)

local AttrTypes = {
	Hp = 1,
	MaxHp = 2,
	Lv = 3,
	Career = 4,
	Offline = 5,
	Scene = 6,
	Line = 7,
}

local DefaultAttr = {
	{type = AttrTypes.Hp, value = 100},
	{type = AttrTypes.MaxHp, value = 1},
	{type = AttrTypes.Lv, value = 1},
	{type = AttrTypes.Career, value = 1},
	{type = AttrTypes.Offline, value = 0},
	{type = AttrTypes.Scene, value = 0},
	{type = AttrTypes.Line, value = 1},
}

function MakeTeamItem:_init(ctrl,idx)
    self.ctrl = ctrl
    self.mem_idx = idx

end

function MakeTeamItem:OpenViewCallBack()
	self:Init()
end

function MakeTeamItem:CloseViewCallBack()
    
end

function MakeTeamItem:Init()
	self.txt_name = self._layout_objs["txt_name"]
	self.txt_lv = self._layout_objs["txt_lv"]
	self.img_leader = self._layout_objs["img_leader"]

	self.img_hp = self._layout_objs["img_hp"]
	self.txt_hp = self._layout_objs["txt_hp"]

	self.img_hp:SetFillAmount(1)

	self.img_career = self._layout_objs["img_career"]
	self.img_in_follow = self._layout_objs["img_in_follow"]
	self.img_following = self._layout_objs["img_following"]
	self.img_offline = self._layout_objs["img_offline"]
	self.img_other_map = self._layout_objs["img_other_map"]

	self.img_hire = self._layout_objs["img_hire"]

	self.img_mask = self._layout_objs["img_mask"]

	self.img_assist = self._layout_objs["img_assist"]

	self.group_info = self._layout_objs["group_info"]
	
	self:GetRoot():AddClickCallBack(function()
		if self.click_callback then
			self.click_callback(self)
		end
	end)

	self.attr_list = {}

	self.attr_type_func = {
		[AttrTypes.Hp] = function(attr_type)
			local hp = self:GetAttr(attr_type)
			-- local max_hp = self:GetAttr(AttrTypes.MaxHp)
			-- local percent = math.floor((hp/max_hp))

			local percent = hp*0.01
			self.img_hp:SetFillAmount(percent)

			--self.txt_hp:SetText(string.format("%s/%s", hp, max_hp))
		end,
		[AttrTypes.MaxHp] = function(attr_type)
			local hp = self:GetAttr(AttrTypes.Hp)
			-- local max_hp = self:GetAttr(attr_type)
			-- local percent = math.floor((hp/max_hp))

			local percent = hp*0.01
			self.img_hp:SetFillAmount(percent)

			--self.txt_hp:SetText(string.format("%s/%s", hp, max_hp))
		end,
		[AttrTypes.Lv] = function(attr_type, is_aoi)
			local str_lv = self:GetAttr(attr_type)
			if self.is_robot and (not is_aoi) then
				str_lv = config.words[5023]
			end
			self.txt_lv:SetText(str_lv)
		end,
		[AttrTypes.Career] = function(attr_type)
			local career = self:GetAttr(attr_type)
			self:UpdateCareer(career)
		end,
		[AttrTypes.Offline] = function(attr_type)
			local offline = self:GetAttr(attr_type)
			local is_offline = (offline>0 and not self.is_robot)
			self.img_offline:SetVisible(is_offline)

			if is_offline then
				self.img_other_map:SetVisible(false)
			end

			self:EnableDark(is_offline)
		end,
		[AttrTypes.Scene] = function(attr_type)
			local offline = self:GetAttr(AttrTypes.Offline)
			local is_offline = offline>0

			local scene = self:GetAttr(attr_type)
			local cur_scene_id = game.Scene.instance:GetSceneID()
			local is_other_map = scene~=cur_scene_id
			self.img_other_map:SetVisible(is_other_map and (not is_offline) and (not self.is_robot))

			local is_dark = (is_offline or is_other_map) and (not self.is_robot)
			self:EnableDark(is_dark)
		end,
		[AttrTypes.Line] = function(attr_type)
			
		end,
	}
end

function MakeTeamItem:UpdateData(data)
	self.has_member = data~=nil
	--self.group_info:SetVisible(self.has_member)	

	if not data then
		return
	end

	local data = data.member

	self.career = data.career
	self.role_id = data.id
	self.member_name = data.name
	self.member_lv = data.level
	self.scene = data.scene
	self.follow_state = data.state
	self.offline_time = data.offline
	self.hp = data.hp
	self.hp_lim = data.hp_lim
	self.is_robot = data.is_robot==true

	self.txt_name:SetText(self.member_name)

	local str_lv = self.member_lv
	if self.is_robot then
		str_lv = config.words[5023]
	end
	self.txt_lv:SetText(str_lv)

	self.img_hire:SetVisible(self.is_robot)

	self.img_leader:SetVisible(self:IsLeader())

	local is_offline = self.offline_time>0
	self.img_offline:SetVisible(is_offline)

	local cur_scene_id = game.Scene.instance:GetSceneID()
	local is_other_map = (self.scene~=cur_scene_id)
	self.img_other_map:SetVisible(is_other_map and (not is_offline))

	self:EnableDark(is_offline or is_other_map)

	self:UpdateFollowState(self.follow_state)

	self:UpdateCareer(self.career)
	self:UpdateAssistFlag()
end

function MakeTeamItem:IsLeader()
	return self.ctrl:IsLeader(self.role_id)
end

function MakeTeamItem:IsSelf()
	return game.Scene.instance:IsSelf(self.role_id)
end

function MakeTeamItem:HasMember()
	return self.has_member
end

function MakeTeamItem:IsSelfLeader()
	local role_id = game.Scene.instance:GetMainRoleID()
	return self.ctrl:IsLeader(role_id)
end

function MakeTeamItem:SetClickCallback(callback)
	self.click_callback = callback
end

function MakeTeamItem:GetName()
	return self.member_name
end

function MakeTeamItem:GetRoleId()
	return self.role_id
end

function MakeTeamItem:GetLevel()
	return self.member_lv
end

function MakeTeamItem:GetCareer()
	return self.career
end

function MakeTeamItem:UpdateAttrInfo(attr_list, is_aoi)
	for k,v in pairs(attr_list) do
		self.attr_list[v.type] = v.value
	end

	for k,v in pairs(attr_list) do
		local func = self.attr_type_func[v.type]
		func(v.type, is_aoi)
	end

end

function MakeTeamItem:GetAttr(attr_type)
	return self.attr_list[attr_type] or 1
end

function MakeTeamItem:UpdateCareer(career)
	self.career = career
	local res = game.CareerRes[career]
	self.img_career:SetSprite("ui_main", res)
end

function MakeTeamItem:EnableDark(is_dark)
	self.img_mask:SetVisible(is_dark)
end

function MakeTeamItem:UpdateFollowState(state)
	self.follow_state = state

	self.img_following:SetVisible(self.follow_state==game.TeamFollowState.CloseTo)
	self.img_in_follow:SetVisible(self.follow_state==game.TeamFollowState.Follow)
end

function MakeTeamItem:GetMemIdx()
	return self.mem_idx
end

function MakeTeamItem:IsRobot()
	return self.is_robot
end

function MakeTeamItem:SetAssistFlag(val)
	self.img_assist:SetVisible(val)
end

function MakeTeamItem:UpdateAssistFlag()
	local is_assist = (self.ctrl:GetMemberAssist(self:GetRoleId())==1)
	self:SetAssistFlag(is_assist)
end

return MakeTeamItem
