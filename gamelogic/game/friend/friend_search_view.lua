local FriendSearchView = Class(game.BaseView)

function FriendSearchView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "friend_search_view"
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function FriendSearchView:OpenViewCallBack()
    
    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[1713])

	self._layout_objs["btn_fdj"]:AddClickCallBack(function()
        local str = self._layout_objs["text_input"]:GetText()
        self.ctrl:CsFriendSysFindNew(str)
    end)

    self._layout_objs["search_btn"]:AddClickCallBack(function()
        self.ctrl:CsFriendSysFindNew("")
    end)

    self:BindEvent(game.FriendEvent.RefreshSearch, function(data)
        self:UpdateList(data)
    end)

    self:InitList()

    --默认查询好友列表
    self.ctrl:CsFriendSysFindNew("")
end

function FriendSearchView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function FriendSearchView:InitList()

	self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(false)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/friend/friend_search_item").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddItemProviderCallback(function(idx)
        return "ui_friend:friend_search_item"
    end)

    self.ui_list:SetItemNum(0)
end

function FriendSearchView:UpdateList(data)

    self.role_info_list = data.role_info_list

	local list_num = #self.role_info_list

	self.ui_list:SetItemNum(list_num)
end

function FriendSearchView:GetListData()
    return self.role_info_list
end

return FriendSearchView