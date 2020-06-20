local FriendEditView = Class(game.BaseView)

function FriendEditView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "friend_edit_view"
    self._view_level = game.UIViewLevel.Second
    self._show_money = true

    self.ctrl = ctrl
    self.friend_data = self.ctrl:GetData()
end

function FriendEditView:OpenViewCallBack()

	self._layout_objs["common_bg/txt_title"]:SetText(config.words[1715])

	self._layout_objs["common_bg/btn_close"]:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs["create_btn"]:AddClickCallBack(function()
        self.ctrl:OpenFriendCreateBlockView()
    end)

    self._layout_objs["del_btn"]:AddClickCallBack(function()
        self:OnDel()
    end)

    self._layout_objs["add_btn"]:AddClickCallBack(function()
        self:OnAddToBlock()

    end)

    self:BindEvent(game.FriendEvent.RefreshBlockList, function(data)
        self:UpdateBlockList()
        self:UpdateFriendList()
    end)

    self:BindEvent(game.FriendEvent.RefreshRoleIdList, function(data)
        self:UpdateFriendList()
    end)

    self:InitLists()

    self:UpdateBlockList()

    self:UpdateFriendList()
end

function FriendEditView:CloseViewCallBack()
    if self.ui_block_list then
        self.ui_block_list:DeleteMe()
        self.ui_block_list = nil
    end

    if self.ui_friend_list then
        self.ui_friend_list:DeleteMe()
        self.ui_friend_list = nil
    end
end

function FriendEditView:InitLists()

    self.list = self._layout_objs["block_list"]
    self.ui_block_list = game.UIList.New(self.list)
    self.ui_block_list:SetVirtual(true)

    self.ui_block_list:SetCreateItemFunc(function(obj)

        local item = require("game/friend/friend_edit_block_template").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_block_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_block_list:SetItemNum(0)

    self.list2 = self._layout_objs["friend_list"]
    self.ui_friend_list = game.UIList.New(self.list2)
    self.ui_friend_list:SetVirtual(true)

    self.ui_friend_list:SetCreateItemFunc(function(obj)

        local item = require("game/friend/friend_edit_friend_template").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_friend_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_friend_list:AddClickItemCallback(function(item)
        item:SetSelect()
    end)

    self.ui_friend_list:SetItemNum(0)
end

function FriendEditView:UpdateBlockList()
    
    self.block_list = self.friend_data:GetBlockList()
    local num = #self.block_list
    self.ui_block_list:SetItemNum(num)
end

function FriendEditView:UpdateFriendList()
    
    self.friend_list = self.friend_data:GetFriendList()
    local num = #self.friend_list
    self.ui_friend_list:SetItemNum(num)

    self.ui_friend_list:Foreach(function(item)
        item:Reset()
    end)
end

function FriendEditView:GetBlockListData()
    return self.block_list
end

function FriendEditView:GetFriendListData()
    return self.friend_list
end

function FriendEditView:OnDel()

    local role_id_list = {}
    self.ui_friend_list:Foreach(function(item)

        if item:GetVisible() then
            local t = {}
            t.role_id = item:GetRoleId()
            table.insert(role_id_list, t)
        end
    end)

    local str = string.format(config.words[1761], #role_id_list)
    local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[1660], str)
    msg_box:SetOkBtn(function()
        self.ctrl:CsFriendSysDelFriend(role_id_list)
    end)
    msg_box:SetCancelBtn(function()
    end)
    msg_box:Open()
    
end

function FriendEditView:OnAddToBlock()

    local role_id_list = {}
    self.ui_friend_list:Foreach(function(item)
        if item:GetVisible() then
            local t = {}
            t.id = item:GetRoleId()
            t.op = 1
            table.insert(role_id_list, t)
        end
    end)

    self.ctrl:OpenAddToBlockView(role_id_list)
end

return FriendEditView