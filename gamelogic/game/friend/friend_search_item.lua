local FriendSearchItem = Class(game.UITemplate)

function FriendSearchItem:_init(parent)
	self.parent = parent
end

function FriendSearchItem:OpenViewCallBack()

    self.head_icon = self:GetIconTemplate("head_icon")
	self._layout_objs["n3"]:SetPosition(210, 52)
	self._layout_objs["career_img"]:SetPosition(166, 47)
	self._layout_objs["role_name"]:SetPosition(258, 51)
    self._layout_objs["add_btn"]:SetGray(false)
    --添加好友
    self._layout_objs["add_btn"]:AddClickCallBack(function()
        self._layout_objs["add_btn"]:SetGray(true)
        game.FriendCtrl.instance:CsFriendSysApplyAdd(self.item_data.unit.id)
    end)
    self.icon_data = {
        icon = self.icon_id,
        frame = 0,
        lock = false,   
    }
end

function FriendSearchItem:RefreshItem(idx)
    local list_data = self.parent:GetListData()
    local item_data = list_data[idx]
    
    self.item_data = item_data

    local career = item_data.unit.career
    self._layout_objs["career_img"]:SetSprite("ui_common", "career" .. career)

    self._layout_objs["n3"]:SetText(item_data.unit.level)

    self._layout_objs["role_name"]:SetText(item_data.unit.name)

    self._layout_objs["txt1"]:SetText("")

    self.icon_data.icon = item_data.unit.icon
    self.head_icon:UpdateData(self.icon_data)
end

return FriendSearchItem