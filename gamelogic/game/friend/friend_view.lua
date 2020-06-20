local FriendView = Class(game.BaseView)

function FriendView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "friend_view"

    self._show_money = true

    self.ctrl = ctrl
end

function FriendView:OpenViewCallBack()
    self._layout_objs["list_page"]:SetHorizontalBarTop(true)

    self:SetLvLimit()
    self:InitBg()
    self:InitTabList()
    self:InitOperate()
    self:CheckContactPageRedPoint()

    self:RegisterAllEvents()
end

function FriendView:RegisterAllEvents()
    local events = {
        {game.FriendEvent.ShowFriendDetail, handler(self,self.OnShowFriendDetail)},
        {game.FriendEvent.ShowGroupDetail, handler(self,self.OnShowGroupDetail)},
        {game.FriendEvent.RefreshRoleIdList, handler(self,self.CheckContactPageRedPoint)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1],v[2])
    end
end

function FriendView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1700])
end

function FriendView:InitTabList()
    self:GetTemplateByObj("game/friend/history_message_template", self._layout_objs["list_page"]:GetChildAt(0))
    self:GetTemplateByObj("game/friend/contacts_template", self._layout_objs["list_page"]:GetChildAt(1))
    self:GetTemplateByObj("game/friend/group_template", self._layout_objs["list_page"]:GetChildAt(2))
end

function FriendView:InitOperate()
    self.group_operate = self._layout_objs["group_operate"]
    self.friend_operate = self._layout_objs["friend_operate"]

    self.group_operate_temp = self:GetTemplateByObj("game/friend/group_operate", self.group_operate)
    self.friend_operate_temp = self:GetTemplateByObj("game/friend/friend_operate", self.friend_operate)
end

function FriendView:OnShowFriendDetail(val, role_info)
    self.group_operate:SetVisible(false)
    self.friend_operate:SetVisible(val)

    if val then
        self.friend_operate_temp:UpdateData(role_info)
    end
end

function FriendView:OnShowGroupDetail(val, group_info)
    self.group_operate:SetVisible(val)
    self.friend_operate:SetVisible(false)

    if val then
        self.group_operate_temp:UpdateData(group_info)
    end
end

function FriendView:SetLvLimit()

    self.tab_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
        self:OnClickPage(idx)
    end)

    local mainrole_lv = game.Scene.instance:GetMainRoleLevel()
    if mainrole_lv < 30 then
        self._layout_objs["list_page"]:SetLastPageCallBack(2, function()
        end)
    else
        self._layout_objs["list_page"]:SetLastPageCallBack(3, function()
        end)
    end
end

function FriendView:OnClickPage(idx)

    local mainrole_lv = game.Scene.instance:GetMainRoleLevel()

    --群组30级开启提示
    if idx == 2 then
        if mainrole_lv < 30 then
            game.GameMsgCtrl.instance:PushMsg("30" .. config.words[2101])
        end
    end
end

function FriendView:CheckContactPageRedPoint()

    local friend_data = self.ctrl:GetData()
    if friend_data:CheckContactRedpoint() then
        self._layout_objs["hd2"]:SetVisible(true)
    else
        self._layout_objs["hd2"]:SetVisible(false)
    end
end

return FriendView