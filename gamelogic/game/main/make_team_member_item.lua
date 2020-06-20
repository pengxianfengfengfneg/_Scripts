local MakeTeamMemberItem = Class(game.UITemplate)

local AttrTypes = {
	Hp = 1,
	MaxHp = 2,
	Lv = 3,
	Career = 4,
	Offline = 5,
	Scene = 6,
}

function MakeTeamMemberItem:_init(ctrl)
    self.ctrl = ctrl
    
end

function MakeTeamMemberItem:OpenViewCallBack()
	self:Init()
end

function MakeTeamMemberItem:CloseViewCallBack()
    
end

function MakeTeamMemberItem:Init()
	self.txt_name = self._layout_objs["txt_name"]
	self.txt_lv = self._layout_objs["txt_lv"]
	self.img_leader = self._layout_objs["img_leader"]

	self.bar_hp = self._layout_objs["bar_hp"]
	self.txt_hp = self._layout_objs["txt_hp"]

	self.img_career = self._layout_objs["img_career"]
	self.img_in_follow = self._layout_objs["img_in_follow"]
	self.img_following = self._layout_objs["img_following"]
	self.img_offline = self._layout_objs["img_offline"]
	self.img_other_map = self._layout_objs["img_other_map"]

	self.img_mask = self._layout_objs["img_mask"]

	self.group_info = self._layout_objs["group_info"]

	self.head_icon = self:GetIconTemplate("head_icon")
	
	self:GetRoot():AddClickCallBack(function()
		if self.click_callback then
			self.click_callback(self)
		end
	end)

	self.attr_type_func = {
		[AttrTypes.Hp] = function(attr_type)
			local hp = self:GetAttr(attr_type)
			local max_hp = self:GetAttr(AttrTypes.MaxHp)
			local percent = math.floor((hp/max_hp)*100)
			self.bar_hp:SetValue(percent)

			self.txt_hp:SetText(string.format("%s/%s", hp, max_hp))
		end,
		[AttrTypes.MaxHp] = function(attr_type)
			local hp = self:GetAttr(AttrTypes.Hp)
			local max_hp = self:GetAttr(attr_type)
			local percent = math.floor((hp/max_hp)*100)
			self.bar_hp:SetValue(percent)

			self.txt_hp:SetText(string.format("%s/%s", hp, max_hp))
		end,
		[AttrTypes.Lv] = function(attr_type)
			local lv = self:GetAttr(attr_type)
			self.txt_lv:SetText(lv)
		end,
		[AttrTypes.Career] = function(attr_type)
			local career = self:GetAttr(attr_type)
			self:UpdateCareer(career)
		end,
		[AttrTypes.Offline] = function(attr_type)
			local offline = self:GetAttr(attr_type)
			local is_offline = offline>0
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
			self.img_other_map:SetVisible(is_other_map and (not is_offline))

			self:EnableDark(is_offline or is_other_map)
		end,
	}
end

function MakeTeamMemberItem:UpdateData(data)
	self.has_member = data~=nil
	self.group_info:SetVisible(self.has_member)	

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
	self.icon = data.icon

	self.txt_name:SetText(self.member_name)

	local str_lv = self.member_lv
	if data.is_robot then
		str_lv = config.words[5023]
	end
	self.txt_lv:SetText(str_lv)

	self.img_leader:SetVisible(self:IsLeader())

	local is_offline = self.offline_time>0
	self.img_offline:SetVisible(is_offline)

	local cur_scene_id = game.Scene.instance:GetSceneID()
	local is_other_map = (self.scene~=cur_scene_id)
	self.img_other_map:SetVisible(is_other_map and (not is_offline))

	self:EnableDark(is_offline or is_other_map)

	self.img_following:SetVisible(self.follow_state==1)
	self.img_in_follow:SetVisible(self.follow_state==2)

	if self.hp_lim > 0 then
		self.txt_hp:SetText(string.format("%s/%s", self.hp, self.hp_lim))
		self.bar_hp:SetValue(math.floor(self.hp/self.hp_lim*100))
	else
		self.txt_hp:SetText(config.words[5009])
		self.bar_hp:SetValue(100)
	end

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

function MakeTeamMemberItem:SetClickCallback(callback)
	self.click_callback = callback
end

function MakeTeamMemberItem:GetName()
	return self.member_name
end

function MakeTeamMemberItem:GetRoleId()
	return self.role_id
end

local attr = {}
function MakeTeamMemberItem:UpdateAttrInfo(attr_list)
	for k,v in ipairs(attr_list) do
		attr[v.type] = v.value
	end

	for k,v in ipairs(attr_list) do
		local func = self.attr_type_func[v.type]
		func(v.type)
	end

end

function MakeTeamMemberItem:GetAttr(attr_type)
	return attr[attr_type] or 0
end

function MakeTeamMemberItem:UpdateCareer(career)
	self.career = career
	local res = game.CareerRes[career]
	self.img_career:SetSprite("ui_main", res)
end

function MakeTeamMemberItem:EnableDark(is_dark)
	self.img_mask:SetVisible(is_dark)
end

function MakeTeamMemberItem:UpdateFollowState(state)
	self.follow_state = state

	self.img_following:SetVisible(self.follow_state==1)
	self.img_in_follow:SetVisible(self.follow_state==2)
end

function MakeTeamMemberItem:UpdateHeadIcon(data)
    self.head_icon:UpdateData(data)
end

return MakeTeamMemberItem
