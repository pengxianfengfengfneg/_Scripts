local HomeView = Class(game.BaseView)

local RedConfig = {
    [game.OpenFuncId.Friend] = {
        check_func = function()
            local data = game.FriendCtrl.instance:GetData()
			local flag = data:CheckRedPoint()
			return flag
        end,
        update_events = {
            game.FriendEvent.RefreshRoleIdList,
        },
    },
}

function HomeView:_init(ctrl)
    self._package_name = "ui_sworn"
    self._com_name = "home_view"
    self.ctrl = ctrl

    self._show_money = true

    self._view_level = game.UIViewLevel.First
    self._mask_type = game.UIMaskType.Full
end

function HomeView:OpenViewCallBack()
    self:Init()
    self:InitBg()
end

function HomeView:Init()
    self.home_friend = self._layout_objs.home_friend
    --ºÃÓÑ
    self.home_friend:AddClickCallBack(function()
        game.FriendCtrl.instance:OpenFriendView()
    end)

    --½á°Ý
    self.home_sworn = self._layout_objs.home_sworn
    self.home_sworn:AddClickCallBack(function()
        local mainrole_lv = game.Scene.instance:GetMainRoleLevel()
        local limit_lv = config.func[3302].show_lv[1]
        if mainrole_lv >= limit_lv then
            game.OpenFuncCtrl.instance:OpenFuncView(game.OpenFuncId.Sworn)
        else
            game.GameMsgCtrl.instance:PushMsg(tostring(limit_lv)..config.words[2101])
        end
    end)

    --Ê¦Í½
    self.home_mentor = self._layout_objs.home_mentor
    self.home_mentor:AddClickCallBack(function()
        local mainrole_lv = game.Scene.instance:GetMainRoleLevel()
        local limit_lv = config.func[3303].show_lv[1]
        if mainrole_lv >= limit_lv then
            game.OpenFuncCtrl.instance:OpenFuncView(game.OpenFuncId.Mentor)
        else
            game.GameMsgCtrl.instance:PushMsg(tostring(limit_lv)..config.words[2101])
        end
    end)
    self.home_mentor:SetVisible(false)

    --结婚
    self.home_marry = self._layout_objs.home_marry
    self.home_marry:AddClickCallBack(function()
        local mainrole_lv = game.Scene.instance:GetMainRoleLevel()
        local limit_lv = config.func[1009].show_lv[1]
        if mainrole_lv >= limit_lv then
            game.OpenFuncCtrl.instance:OpenFuncView(game.OpenFuncId.Marry)
            self:Close()
        else
            game.GameMsgCtrl.instance:PushMsg(tostring(limit_lv)..config.words[2101])
        end
    end)
    --self.home_marry:SetVisible(false)

    self.home_items = {
        [game.OpenFuncId.Friend] = self.home_friend,
    }
    
    self:BindRedEvent()
    for func_id, v in pairs(RedConfig) do
        self:UpdateRedPoint(func_id)
    end
end

function HomeView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[514])
end

function HomeView:BindRedEvent()
    for func_id, v in pairs(RedConfig) do
        for _, cv in pairs(v.update_events) do
            self:BindEvent(cv, function()
                self:UpdateRedPoint(func_id)
            end)
        end
    end
end

function HomeView:UpdateRedPoint(func_id)
    local item = self.home_items[func_id]
    local visible = RedConfig[func_id].check_func()
    game_help.SetRedPoint(item, visible)
end

return HomeView
