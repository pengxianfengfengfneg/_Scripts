local FriendGroupInfoView = Class(game.BaseView)

function FriendGroupInfoView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "friend_group_info_view"
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
    self.friend_data = self.ctrl:GetData()
end

function FriendGroupInfoView:OpenViewCallBack(group_info)

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[1735])

    self.group_info = group_info

    self:InitList()

    self:UpdateList()

    self:BindEvent(game.FriendEvent.RefreshGroupList, function()
        self:UpdateList()
    end)
end

function FriendGroupInfoView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function FriendGroupInfoView:InitList()

    self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/friend/friend_group_info_template").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:SetItemNum(0)
end

function FriendGroupInfoView:UpdateList()

    local group_data = self.friend_data:GetGroupData(self.group_info.id)
    self.group_data = group_data

    local owner = self.group_data.owner
    local sortfunction = function (a, b)
        local a1 = (a.roleId == owner) and 0 or 1
        local b1 = (b.roleId == owner) and 0 or 1

        return a1 < b1
    end
    table.sort( self.group_data.mem_list, sortfunction)

    local num = #self.group_data.mem_list
    self.ui_list:SetItemNum(num)
end

function FriendGroupInfoView:GetListData()
    return self.group_data.mem_list
end

function FriendGroupInfoView:GetGroupData()
    return self.group_data
end

return FriendGroupInfoView