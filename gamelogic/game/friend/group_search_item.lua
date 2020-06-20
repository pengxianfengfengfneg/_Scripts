local GroupSearchItem = Class(game.UITemplate)

function GroupSearchItem:_init(parent)
	self.parent = parent
end

function GroupSearchItem:OpenViewCallBack()
	self._layout_objs["n20"]:AddClickCallBack(function()
		game.FriendCtrl.instance:CsFriendSysApplyInGroup(self.group_item.group.id)
    end)

    self._layout_objs["n21"]:AddClickCallBack(function()

        local owner_info = self.group_item.group.owner_role
        local main_role_vo = game.Scene.instance:GetMainRoleVo()

        local chat_info = {
            id = owner_info.id,
            name = owner_info.name,
            career = owner_info.career,
            gender = owner_info.gender,
            channel = game.ChatChannel.Private,
            lv = owner_info.level,
            svr_num = main_role_vo.server_num,
            stat = 0,           --两人关系 参考 game.FriendRelationName
            offline = 0,     --0表示在线
            vip = 0,
        }

        game.ChatCtrl.instance:OpenFriendChatView(chat_info)
    end)
end

function GroupSearchItem:RefreshItem(idx)
    local list_data = self.parent:GetListData()
    local item_data = list_data[idx]
    self.group_item = item_data
    self._layout_objs["group_name"]:SetText(item_data.group.name)

	self._layout_objs["group_type"]:SetText(game.FriendGroupTypeName[item_data.group.type])

	self._layout_objs["mem_num"]:SetText(tostring(item_data.group.num).."/"..tostring(item_data.group.max_num))
end

return GroupSearchItem