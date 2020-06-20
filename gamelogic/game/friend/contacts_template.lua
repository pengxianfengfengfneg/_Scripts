local BotBtnFunc = {
    --添加好友
    [1] = {
        name = config.words[1751],
        func = "AddFriend",
        check = function()
            return true
        end,
    },
    --邀请入帮
    [2] = {
        name = config.words[1752],
        func = "InviteGuild",
        check = function()
            return true
        end,
    },
    --邀请入队
    [3] = {
        name = config.words[1753],
        func = "InviteTeam",
        check = function()
            return true
        end,
    },
    --清除记录
    [4] = {
        name = config.words[1754],
        func = "ClearLogs",
        check = function()
            return true
        end,
    },
    --好友备注
    [5] = {
        name = config.words[1755],
        func = "EditDetails",
        check = function()
            return true
        end,
    },
    --删除好友
    [6] = {
        name = config.words[1756],
        func = "DelFriend",
        check = function()
            return true
        end,
    },
    --添加分组
    [7] = {
        name = config.words[1757],
        func = "AddBlock",
        check = function()
            return true
        end,
    },
    --好友关注
    [8] = {
        name = config.words[1758],
        func = "FocusFriend",
        check = function()
            return true
        end,
    },
    --移除 黑名单或仇人
    [9] = {
        name = config.words[1759],
        func = "RemoveFromList",
        check = function()
            return true
        end,
    },
    --拉黑名单
    [10] = {
        name = config.words[1760],
        func = "AddBanList",
        check = function()
            return true
        end,
    },
    --踢出分组
    [11] = {
        name = config.words[1764],
        func = "RemoveFromSelfList",
        check = function()
            return true
        end,
    },
    --取消好友关注
    [12] = {
        name = config.words[1767],
        func = "RemoveFromFocusList",
        check = function()
            return true
        end,
    },
}

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

local ContactsTemplate = Class(game.UITemplate)

function ContactsTemplate:_init()
	self.friend_data = game.FriendCtrl.instance:GetData()
end

function ContactsTemplate:OpenViewCallBack()

    self.select_info = nil
    -- self._layout_objs["black_bg"]:SetTouchDisabled(false)
    -- self._layout_objs["black_bg"]:AddClickCallBack(function()
    --     self._layout_objs["bot_pannel"]:SetVisible(false)
    --     self.select_info = nil
    -- end)

    -- self._layout_objs["detail_bg"]:SetTouchDisabled(false)
    -- self._layout_objs["detail_bg"]:AddClickCallBack(function()
    -- end)

	self._layout_objs["add_friend_btn"]:AddClickCallBack(function()
		game.FriendCtrl.instance:OpenFriendSearchView()
    end)

    self._layout_objs["invite_btn"]:AddClickCallBack(function()
		game.FriendCtrl.instance:OpenFriendInviteView()
    end)

    self._layout_objs["play_btn"]:AddClickCallBack(function()
		game.FriendCtrl.instance:OpenFriendEditView()
    end)

    self:BindEvent(game.FriendEvent.RefreshRoleIdList, function()
        self:UpdateListData()
        self:UpdateList()
        self:ResetSelect()
        self:SetApplyRedPoint()

        self:FireEvent(game.FriendEvent.ShowFriendDetail, false)
    end)

    self:BindEvent(game.FriendEvent.RefreshBlockList, function()
        self:UpdateListData()
        self:UpdateList()
        self:ResetSelect()

        self:FireEvent(game.FriendEvent.ShowFriendDetail, false)
    end)

    self:BindEvent(game.FriendEvent.ChangeNickName, function(data)
        if self.select_info then
            if game.FriendCtrl.instance.show_friend_nick_name then
                self._layout_objs["nick_name"]:SetText(data.nickname)
            else
                self._layout_objs["nick_name"]:SetText("")
            end
        end
    end)

    self:InitList()

	self:UpdateListData()

	self:UpdateList()

    self:ResetSelect()

    self:SetApplyRedPoint()
end

function ContactsTemplate:CloseViewCallBack()
	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end
end

function ContactsTemplate:InitList()

    self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/friend/contacts_item_template").New(self)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        item:RefreshItem(idx)
    end)

    -- self.ui_list:AddClickItemCallback(function(item)
    --     self:OnClick(item)
    -- end)

    self.ui_list:AddItemProviderCallback(function(idx)

        local data = self.list_data[idx]
        if data.type == 1 then
            return "ui_friend:friend_type_template"
        else
            return "ui_friend:friend_info_template"
        end
    end)

    self.ui_list:SetItemNum(0)
end

function ContactsTemplate:UpdateList()

    local num = #self.list_data

    self.ui_list:SetItemNum(num)
end

function ContactsTemplate:UpdateListData(index, oper_type)
	self.list_data = self.friend_data:GetContactsData(index, oper_type)
end

function ContactsTemplate:GetListData()
    return self.list_data
end

function ContactsTemplate:OnClick(item)

    --分组类型栏
    if item:GetType() == 1 then

        self.ui_list:Foreach(function(v)
            if v ~= item then
                v:SetSelect(false)
            end
        end)

        if item:GetSelect() then
            self:UpdateListData()
            item:SetSelect(false)
        else
            self:UpdateListData(item:GetTypeIndex(), item:GetOperType())
            item:SetSelect(true)
        end
        self:UpdateList()

    --角色栏
    else

        local item_data = item:GetItemData()
        local role_id = item_data.role_id
        local role_info = self.friend_data:GetRoleInfoById(role_id)
        local main_role_vo = game.Scene.instance:GetMainRoleVo()

        local chat_info = {
            id = role_info.unit.id,
            name = role_info.unit.name,
            career = role_info.unit.career,
            gender = role_info.unit.gender,
            channel = game.ChatChannel.Private,
            lv = role_info.unit.level,
            svr_num = main_role_vo.server_num,
            stat = role_info.unit.stat,           --两人关系 参考 game.FriendRelationName
            offline = role_info.unit.offline,     --0表示在线
            vip = role_info.unit.vip,   
        }

        game.ChatCtrl.instance:OpenFriendChatView(chat_info)
    end
end


local get_list_index = function(item_data)
    if not item_data.type_index then
        return 5
    elseif item_data.type_index == 1 then
        return 1
    elseif item_data.type_index == 2 then
        return 2
    elseif item_data.type_index == 3 then
        return 3
    elseif item_data.type_index == 4 then
        return 4
    end
end

function ContactsTemplate:ShowDetailInfo(item_data)

    self.select_info = item_data

    local role_info = self.friend_data:GetRoleInfoById(item_data.role_id)

    self._layout_objs["role_name"]:SetText(role_info.unit.name)

    self._layout_objs["guild_name"]:SetText(role_info.unit.guild_name)

    self._layout_objs["team_num"]:SetText(tostring(role_info.unit.team_num).."/5")

    self._layout_objs["relation_name"]:SetText(game.FriendRelationName[role_info.unit.stat])

    local scene_id = role_info.unit.scene
    if scene_id > 0 then
        local scene_name = config.scene[scene_id].name
        self._layout_objs["pos_name"]:SetText(scene_name)
    else
        self._layout_objs["pos_name"]:SetText(config.words[1702])
    end

    local nick_name = self.friend_data:GetFriendNickName(item_data.role_id)
    self._layout_objs["nick_name"]:SetText(nick_name)

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
                ContactsTemplate[cfg.func](self)
            end)

            self._layout_objs["bot_btn"..i]:SetVisible(true)
        else
            self._layout_objs["bot_btn"..i]:SetVisible(false)
        end
    end

    self._layout_objs["bot_pannel"]:SetVisible(true)
end

function ContactsTemplate:AddFriend()
    game.FriendCtrl.instance:CsFriendSysApplyAdd(self.select_info.role_id)
end

function ContactsTemplate:InviteGuild()
    game.GuildCtrl.instance:SendInviteJoinGuild(self.select_info.role_id)
end

function ContactsTemplate:InviteTeam()
    game.MakeTeamCtrl.instance:DoTeamInviteJoin(self.select_info.role_id)
end

function ContactsTemplate:ClearLogs()

end

function ContactsTemplate:EditDetails()
    game.FriendCtrl.instance:OpenEditFriendDetailView(self.select_info.role_id)
end

function ContactsTemplate:DelFriend()

    local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[1660], config.words[1766])
    msg_box:SetOkBtn(function()
        local list = {}
        local t = {}
        t.role_id = self.select_info.role_id
        table.insert(list, t)
        game.FriendCtrl.instance:CsFriendSysDelFriend(list)
    end)
    msg_box:SetCancelBtn(function()
    end)
    msg_box:Open()
end

function ContactsTemplate:AddBlock()
    local role_id_list = {}
    local t = {}
    t.id = self.select_info.role_id
    t.op = 1
    table.insert(role_id_list, t)

    game.FriendCtrl.instance:OpenAddToBlockView(role_id_list)
end

function ContactsTemplate:FocusFriend()
    game.FriendCtrl.instance:CsFriendSysFocus(self.select_info.role_id)
end

function ContactsTemplate:RemoveFromList()
    if (not self.select_info.oper_type) and self.select_info.type_index == 3 then
        game.FriendCtrl.instance:CsFriendSysBanRole(self.select_info.role_id)
    elseif (not self.select_info.oper_type) and self.select_info.type_index == 4 then
        game.FriendCtrl.instance:CsFriendSysAddEnemy(self.select_info.role_id)
    end
end

function ContactsTemplate:AddBanList()
    game.FriendCtrl.instance:CsFriendSysBanRole(self.select_info.role_id)
end

function ContactsTemplate:RemoveFromSelfList()
    local role_id_list = {}
    local t = {}
    t.id = self.select_info.role_id
    t.op = 2
    table.insert(role_id_list, t)
    game.FriendCtrl.instance:CsFriendSysAdd2Block(self.select_info.block_id, role_id_list)
end

function ContactsTemplate:RemoveFromFocusList()
    game.FriendCtrl.instance:CsFriendSysFocus(self.select_info.role_id)
end

function ContactsTemplate:SetApplyRedPoint()

    local apply_list = self.friend_data:GetApplyList()
    if apply_list and #apply_list > 0 then
        self._layout_objs["apply_hd"]:SetVisible(true)
    else
        self._layout_objs["apply_hd"]:SetVisible(false)
    end
end

function ContactsTemplate:ResetSelect()
     self.ui_list:Foreach(function(v)
        v:SetSelect(false)
    end)
end

return ContactsTemplate