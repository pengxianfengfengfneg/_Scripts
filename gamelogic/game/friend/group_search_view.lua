local GroupSearchView = Class(game.BaseView)

function GroupSearchView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "group_search_view"
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function GroupSearchView:OpenViewCallBack()

    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1734])

    self:BindEvent(game.FriendEvent.RefreshGroupSearch, function(data)
        self:UpdateList(data)
    end)

    self._layout_objs["btn_fdj"]:AddClickCallBack(function()
        local str = self._layout_objs["text_input"]:GetText()
        self.ctrl:CsFriendSysFindGroup(str, 0)
    end)

    self._layout_objs["refresh_btn"]:AddClickCallBack(function()
        self.ctrl:CsFriendSysFindGroup("", 0)
    end)

    self._layout_objs["search_btn"]:AddClickCallBack(function()
        self.ctrl:OpenGroupTypeSearchView()
    end)

    self:InitList()

    self.ctrl:CsFriendSysFindGroup("", 0)
end

function GroupSearchView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function GroupSearchView:InitList()

    self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/friend/group_search_item").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:SetItemNum(0)
end

function GroupSearchView:UpdateList(data)

    self.group_list = data.group_list

    local list_num = #self.group_list

    self.ui_list:SetItemNum(list_num)
end

function GroupSearchView:GetListData()
    return self.group_list
end

return GroupSearchView