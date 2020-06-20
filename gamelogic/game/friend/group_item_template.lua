local GroupItemTemplate = Class(game.UITemplate)

function GroupItemTemplate:_init(parent)
	self.parent = parent
    self.friend_data = game.FriendCtrl.instance:GetData()
end

function GroupItemTemplate:OpenViewCallBack()

	self._layout_objs["set_btn"]:AddClickCallBack(function()
		self:FireEvent(game.FriendEvent.ShowGroupDetail, true, self.group_data)
    end)

    if self._layout_objs["bg"] then
		self._layout_objs["bg"]:SetTouchDisabled(false)
		self._layout_objs["bg"]:AddClickCallBack(function()
			self.parent:OnClick(self)
	    end)
	end
end

function GroupItemTemplate:RefreshItem(idx)
	local list_data = self.parent:GetListData()
	local item_data = list_data[idx]
	self.group_data = item_data

	local total_num, online_num = self.friend_data:GetGroupOnlineNum(item_data.group.id)
	self._layout_objs["group_name"]:SetText(item_data.group.name.."("..tostring(online_num).."/"..tostring(total_num)..")")

	self._layout_objs["group_type"]:SetText(config.words[1733]..game.FriendGroupTypeName[item_data.group.type])

	self.group_info = self.friend_data:GetGroupData(group_id)

    local num = #self.group_data.group.apply_list
    if num > 0 then
        self._layout_objs["apply_rp"]:SetVisible(true)
    else
        self._layout_objs["apply_rp"]:SetVisible(false)
    end

    local my_role_id = game.Scene.instance:GetMainRoleID()

    --是群主
    if my_role_id ~= item_data.group.owner then
    	self._layout_objs["apply_rp"]:SetVisible(false)
    end
end

function GroupItemTemplate:GetData()
	return self.group_data
end

return GroupItemTemplate