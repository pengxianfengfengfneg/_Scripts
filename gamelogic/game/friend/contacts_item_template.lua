local ContactsItemTemplate = Class(game.UITemplate)

function ContactsItemTemplate:_init(parent)
	self.parent = parent
	self.ctrl = game.FriendCtrl.instance
	self.friend_data = game.FriendCtrl.instance:GetData()
end

function ContactsItemTemplate:OpenViewCallBack()

	if self._layout_objs["set_btn"] then
		self._layout_objs["set_btn"]:AddClickCallBack(function()

			self:FireEvent(game.FriendEvent.ShowFriendDetail, true, self.item_data)
	    end)
	end

	if self._layout_objs["bg1"] then
		self._layout_objs["bg1"]:SetTouchDisabled(false)
		self._layout_objs["bg1"]:AddClickCallBack(function()
			self.parent:OnClick(self)
	    end)
	end

	if self._layout_objs["bg2"] then
		self._layout_objs["bg2"]:SetTouchDisabled(false)
		self._layout_objs["bg2"]:AddClickCallBack(function()
			self.parent:OnClick(self)
	    end)
	end

	self:BindEvent(game.FriendEvent.ChangeNickName, function(data)
        if self.item_data.type == 2 and data.role_id == self.item_data.role_id then
            if game.FriendCtrl.instance.show_friend_nick_name then
                self._layout_objs["txt2"]:SetText(data.nickname)
            else
                self._layout_objs["txt2"]:SetText("")
            end
        end
    end)

    self:BindEvent(game.FriendEvent.RefreshNickName, function()
    	if self.item_data.type == 2 then
    		if self.ctrl.show_friend_nick_name then
			    local nick_name = self.friend_data:GetFriendNickName(self.item_data.role_id)
			    self._layout_objs["txt2"]:SetText(nick_name)
			else
				self._layout_objs["txt2"]:SetText("")
			end
    	end
    end)

    if self._layout_objs["head_icon"] then
	    self.head_icon = self:GetIconTemplate("head_icon")
	end
end

function ContactsItemTemplate:RefreshItem(idx)

	local list_data = self.parent:GetListData()
	local item_data = list_data[idx]
	self.item_data = item_data
	--分組標題
	if item_data.type == 1 then

		local total_num, online_num = self.friend_data:GetBlockOnlineNum(item_data.type_index, item_data.oper_type)
		local name = self.friend_data:GetBlockName(item_data.type_index, item_data.oper_type)
		self._layout_objs["type_name"]:SetText(name)
		self._layout_objs["num"]:SetText(tostring(online_num).."/"..tostring(total_num))
	--角色信息
	else
		local role_id = item_data.role_id
		local role_info = self.friend_data:GetRoleInfoById(role_id)
		if role_info then
			local career = role_info.unit.career
		    self._layout_objs["career_img"]:SetSprite("ui_common", "career" .. career)

		    self._layout_objs["n3"]:SetText(role_info.unit.level)

		    self._layout_objs["role_name"]:SetText(role_info.unit.name)

		    self._layout_objs["txt1"]:SetText("")

		    if self.ctrl.show_friend_nick_name then
			    local nick_name = self.friend_data:GetFriendNickName(role_id)
			    self._layout_objs["txt2"]:SetText(nick_name)
			else
				self._layout_objs["txt2"]:SetText("")
			end

	        if self.head_icon then
	        	self.head_icon:UpdateData(role_info.unit)
	        	self.head_icon:SetGray(role_info.unit.offline>0)
	        end
		end
	end
end

function ContactsItemTemplate:SetSelect(val)
	if self._layout_objs["arrow_img"] then

		self.select_flag = val
		if val then
			self._layout_objs["arrow_img"]:SetRotation(90)
			self._layout_objs["arrow_img"]:SetPosition(47,12)
		else
			self._layout_objs["arrow_img"]:SetRotation(0)
			self._layout_objs["arrow_img"]:SetPosition(25,10)
		end
	end
end

function ContactsItemTemplate:GetType()
	return self.item_data.type
end

function ContactsItemTemplate:GetTypeIndex()
	return self.item_data.type_index
end

function ContactsItemTemplate:GetOperType()
	return self.item_data.oper_type
end

function ContactsItemTemplate:GetSelect()
	return self.select_flag
end

function ContactsItemTemplate:GetItemData()
	return self.item_data
end

return ContactsItemTemplate