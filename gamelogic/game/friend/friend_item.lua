local FriendItem = Class(game.UITemplate)

function FriendItem:_init(item_type)
	self.item_type = item_type	--1.我的关注  2.我的粉丝 3.黑明单 4.推荐
end

function FriendItem:OpenViewCallBack()

	self.tab_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
    end)

    self.tab_controller:SetSelectedIndexEx(self.item_type-1)

    ----------------我的关注----------------
    --赠送按钮
    self._layout_objs["n6"]:AddClickCallBack(function()

        if self.send_state == 0 then
            local role_id = self.item_data.role.id
            game.FriendCtrl.instance:FriendGiveCoinReq(role_id)
        end
    end)

    --取消关注按钮
    self._layout_objs["n7"]:AddClickCallBack(function()
        local role_id = self.item_data.role.id
        game.FriendCtrl.instance:FriendUnFollowReq(role_id)
    end)


    ----------------我的粉丝----------------
    --关注按钮
    self._layout_objs["n11"]:AddClickCallBack(function()
    	local role_id = self.item_data.role.id
    	game.FriendCtrl.instance:FriendFollowReq(1, role_id)
    end)

    --接收金币 按钮/赠送金币
    self._layout_objs["n10"]:AddClickCallBack(function()

        if self.recv_state == 1 then
            local role_id = self.item_data.role.id
            game.FriendCtrl.instance:FriendRecvCoinReq(role_id)
        end
    end)

    --------------黑名单-----------
    self._layout_objs["n13"]:AddClickCallBack(function()
        local role_id = self.item_data.role.id
        game.FriendCtrl.instance:FriendDelBlackReq(role_id)
    end)

    --------------推荐----------------
    --关注按钮
    self._layout_objs["n9"]:AddClickCallBack(function()
    	local role_id = self.item_data.role.id
    	game.FriendCtrl.instance:FriendFollowReq(2, role_id)
    end)

    self._layout_objs["head_icon"]:SetTouchDisabled(false)
    self._layout_objs["head_icon"]:AddClickCallBack(function ()
        self.item_data.role.career = 1  --temp
        game.RoleCtrl.instance:OpenRoleInfoView(self.item_data.role)
    end)
end

function FriendItem:RefreshItem(idx)

	self.index = idx

    if self.item_type == 1 then
        self:RefreshFollowItem(idx)
	elseif self.item_type == 2 then
		self:RefreshFansItem(idx)
    elseif self.item_type == 3 then
        self:RefreshBlackListItem(idx)
	elseif self.item_type == 4 then
		self:RefreshRecommendItem(idx)
	end
end

function FriendItem:RefreshFollowItem(idx)
    local friend_data = game.FriendCtrl.instance:GetData()
    local follow_list = friend_data:GetMyFollow()

    local item_data = follow_list[idx]
    self.item_data = item_data

    local online_str = (item_data.role.offline == 0) and config.words[1701] or config.words[1702]
    self._layout_objs["n3"]:SetText(string.format(config.words[1703], item_data.role.name, online_str))

    self._layout_objs["n4"]:SetText(string.format(config.words[1704], item_data.role.level))

    self._layout_objs["n5"]:SetText(string.format(config.words[1705], item_data.role.fight))

    local send_state = item_data.role.send
    self.send_state = send_state

    --赠送
    if send_state == 1 then
        self._layout_objs["n6"]:SetVisible(false)
    else
        self._layout_objs["n6"]:SetVisible(true)
    end
end

function FriendItem:RefreshFansItem(idx)
	local friend_data = game.FriendCtrl.instance:GetData()
    local fans_list = friend_data:GetMyFans()

    local item_data = fans_list[idx]
    self.item_data = item_data

    local online_str = (item_data.role.offline == 0) and config.words[1701] or config.words[1702]
    self._layout_objs["n3"]:SetText(string.format(config.words[1703], item_data.role.name, online_str))

    self._layout_objs["n4"]:SetText(string.format(config.words[1704], item_data.role.level))

    self._layout_objs["n5"]:SetText(string.format(config.words[1705], item_data.role.fight))

    local recv_state = item_data.role.recv
    self.recv_state = recv_state

    --接收
    if recv_state == 0 then
        self._layout_objs["n10"]:SetVisible(false)
        self._layout_objs["n16"]:SetVisible(false)
    elseif recv_state == 1 then
    	self._layout_objs["n10"]:SetVisible(true)
	else
        self._layout_objs["n10"]:SetVisible(false)
		self._layout_objs["n16"]:SetVisible(true)
	end
end

function FriendItem:RefreshBlackListItem(idx)

    local friend_data = game.FriendCtrl.instance:GetData()
    local black_list = friend_data:GetBlackList()

    local item_data = black_list[idx]
    self.item_data = item_data

    local online_str = (item_data.role.offline == 0) and config.words[1701] or config.words[1702]
    self._layout_objs["n3"]:SetText(string.format(config.words[1703], item_data.role.name, online_str))

    self._layout_objs["n4"]:SetText(string.format(config.words[1704], item_data.role.level))

    self._layout_objs["n5"]:SetText(string.format(config.words[1705], item_data.role.fight))
end

function FriendItem:RefreshRecommendItem(idx)

	local friend_data = game.FriendCtrl.instance:GetData()
    local recommend_list = friend_data:GetRecommendData()
    local item_data = recommend_list.list[idx]
    self.item_data = item_data

    local online_str = (item_data.role.offline == 0) and config.words[1701] or config.words[1702]
    self._layout_objs["n3"]:SetText(string.format(config.words[1703], item_data.role.name, online_str))

    self._layout_objs["n4"]:SetText(string.format(config.words[1704], item_data.role.level))

    self._layout_objs["n5"]:SetText(string.format(config.words[1705], item_data.role.fight))
end

function FriendItem:OnClickTab()

	
end

return FriendItem