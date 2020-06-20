local FriendOperate = Class(game.UITemplate)

local get_list_index = function(item_data)
    if item_data.type_index == 1 then
        return 1
    elseif item_data.type_index == 2 then
        return 2
    elseif item_data.type_index == 3 then
        return 3
    elseif item_data.type_index == 4 then
        return 4
    end

    return 5
end

local show_btn_list = {
    --全部好友
    [1] = {2,3,4,5,6,7},
    --关注好友
    [2] = {2,3,4,5,6,7,12},
    --黑名单
    [3] = {5,9},
    --仇人
    [4] = {9},
    --私创分组
    [5] = {2,3,4,5,6,7,8,11},
}

local BotBtnFunc = {
    --添加好友
    [1] = {
        name = config.words[1751],
        func = function(select_info)
        	game.FriendCtrl.instance:CsFriendSysApplyAdd(select_info.role_id)
        end,
        check = function()
            return true
        end,
    },
    --邀请入帮
    [2] = {
        name = config.words[1752],
        func = function(select_info)
        	game.GuildCtrl.instance:SendInviteJoinGuild(select_info.role_id)
        end,
        check = function()
            return true
        end,
    },
    --邀请入队
    [3] = {
        name = config.words[1753],
        func = function(select_info)
        	game.MakeTeamCtrl.instance:DoTeamInviteJoin(select_info.role_id)
        end,
        check = function()
            return true
        end,
    },
    --清除记录
    [4] = {
        name = config.words[1754],
        func = function(select_info)
        	
        end,
        check = function()
            return true
        end,
    },
    --好友备注
    [5] = {
        name = config.words[1755],
        func = function(select_info, role_info)
            if role_info and role_info.unit.stat == 0 then
                game.GameMsgCtrl.instance:PushMsg(config.words[1770])
            else
                game.FriendCtrl.instance:OpenEditFriendDetailView(select_info.role_id)
            end
        end,
        check = function()
            return true
        end,
    },
    --删除好友
    [6] = {
        name = config.words[1756],
        func = function(select_info)
        	local role_id = select_info.role_id
        	local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[1660], config.words[1766])
		    msg_box:SetOkBtn(function()
		        local list = {}
		        local t = {
			     	role_id = role_id   
			    }
		        table.insert(list, t)
		        game.FriendCtrl.instance:CsFriendSysDelFriend(list)
		    end)
		    msg_box:SetCancelBtn(function()
		    end)
		    msg_box:Open()
        end,
        check = function()
            return true
        end,
    },
    --添加分组
    [7] = {
        name = config.words[1757],
        func = function(select_info)
        	local role_id_list = {}
		    local t = {}
		    t.id = select_info.role_id
		    t.op = 1
		    table.insert(role_id_list, t)

		    game.FriendCtrl.instance:OpenAddToBlockView(role_id_list)
        end,
        check = function()
            return true
        end,
    },
    --好友关注
    [8] = {
        name = config.words[1758],
        func = function(select_info)
        	game.FriendCtrl.instance:CsFriendSysFocus(select_info.role_id)
        end,
        check = function()
            return true
        end,
    },
    --移除 黑名单或仇人
    [9] = {
        name = config.words[1759],
        func = function(select_info)
        	if (not select_info.oper_type) and select_info.type_index == 3 then
		        game.FriendCtrl.instance:CsFriendSysBanRole(select_info.role_id)
		    elseif (not select_info.oper_type) and select_info.type_index == 4 then
		        game.FriendCtrl.instance:CsFriendSysAddEnemy(select_info.role_id)
		    end
        end,
        check = function()
            return true
        end,
    },
    --拉黑名单
    [10] = {
        name = config.words[1760],
        func = function(select_info)
        	game.FriendCtrl.instance:CsFriendSysBanRole(select_info.role_id)
        end,
        check = function()
            return true
        end,
    },
    --踢出分组
    [11] = {
        name = config.words[1764],
        func = function(select_info)
        	local role_id_list = {}
		    local t = {}
		    t.id = select_info.role_id
		    t.op = 2
		    table.insert(role_id_list, t)
		    game.FriendCtrl.instance:CsFriendSysAdd2Block(select_info.block_id, role_id_list)
        end,
        check = function()
            return true
        end,
    },
    --取消好友关注
    [12] = {
        name = config.words[1767],
        func = function(select_info)
        	game.FriendCtrl.instance:CsFriendSysFocus(select_info.role_id)
        end,
        check = function()
            return true
        end,
    },
}

function FriendOperate:_init()
	self.ctrl = game.FriendCtrl.instance
	self.friend_data = self.ctrl:GetData()
end

function FriendOperate:OpenViewCallBack()
	self.txt_role_name = self._layout_objs["role_name"]
	self.txt_guild_name = self._layout_objs["guild_name"]
	self.txt_team_num = self._layout_objs["team_num"]
	self.txt_relation_name = self._layout_objs["relation_name"]
	self.txt_pos_name = self._layout_objs["pos_name"]
	self.txt_nick_name = self._layout_objs["nick_name"]
	
    self._layout_objs["touch_com"]:AddClickCallBack(function()
    	self:GetRoot():SetVisible(false)

        self.select_info = nil
    end)

    self:BindEvent(game.SceneEvent.OnRoleCommonInfo, function(common_info)
        if self.select_info and common_info.role_id == self.select_info.role_id then
            local role_info = self.select_info.role_info
            if role_info then
                for k, v in pairs(common_info) do
                    role_info.unit[k] = v
                end
                self:DoUpdateData(self.select_info, role_info)
            end
        end
    end)

    self.head_icon = self:GetIconTemplate("head_icon")
end

function FriendOperate:UpdateData(item_data)
	self.select_info = item_data

	local role_id = item_data.role_id

    local role_info = self.friend_data:GetRoleInfoById(role_id)
    if not role_info then
        if item_data.role_info then
            game.ViewOthersCtrl.instance:SendViewGetRoleCommonInfo(role_id)
        end
    	return
    end
    self:DoUpdateData(item_data, role_info)
end

function FriendOperate:DoUpdateData(item_data, role_info)
    self.head_icon:UpdateData(role_info.unit)

    self.txt_role_name:SetText(role_info.unit.name)
    self.txt_guild_name:SetText(role_info.unit.guild_name)
    self.txt_team_num:SetText(tostring(role_info.unit.team_num).."/5")
    self.txt_relation_name:SetText(game.FriendRelationName[role_info.unit.stat])

    local scene_id = role_info.unit.scene
    if scene_id > 0 then
        local scene_name = config.scene[scene_id].name
        self.txt_pos_name:SetText(scene_name)
    else
        self.txt_pos_name:SetText(config.words[1702])
    end

    local nick_name = self.friend_data:GetFriendNickName(item_data.role_id)
    self.txt_nick_name:SetText(nick_name)

    --属于哪个列表
    local index = get_list_index(item_data)
    local btns = {}
    for k, v in pairs(show_btn_list[index]) do
        table.insert(btns, v)
    end

    --全部好友裏面 區分是否关注
    if index == 1 then
        local is_focused = self.friend_data:IsMyFocus(item_data.role_id)
        if is_focused then
            table.insert(btns, 12)
        else
            table.insert(btns, 8)
        end
    end

    for i = 1, 10 do
        if btns[i] then
            local cfg = BotBtnFunc[btns[i]]
            self._layout_objs["bot_btn"..i]:SetText(cfg.name)
            self._layout_objs["bot_btn"..i]:AddClickCallBack(function()
                cfg.func(item_data, role_info)
            end)

            self._layout_objs["bot_btn"..i]:SetVisible(true)
        else
            self._layout_objs["bot_btn"..i]:SetVisible(false)
        end
    end
end

return FriendOperate