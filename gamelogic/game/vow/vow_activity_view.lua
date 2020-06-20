local VowActivityView = Class(game.BaseView)

function VowActivityView:_init(ctrl)
    self._package_name = "ui_vow"
    self._com_name = "ui_vow_activity_view"
    self.ctrl = ctrl
    self.vow_data = self.ctrl:GetData()
end

function VowActivityView:_delete()
end

function VowActivityView:OpenViewCallBack()

	self.tab_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
		self.select_page = idx

        local index = self.select_page-1
        if index < 0 then
            index = 0
        end

        self._layout_objs["list_tab"]:ScrollToView(index, true, true)
    end)

	self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[6160])

	self._layout_objs["list_page"]:AddScrollEndCallback(function()

        local index = self.select_page-1
        if index < 0 then
            index = 0
        end

		self._layout_objs["list_tab"]:ScrollToView(index, true, true)
	end)

	self:InitTabs()
	self:InitPages()
    self:SetBotProgress()
    self:InitBotClick()

    local time = 1
    self.timer = global.TimerMgr:CreateTimer(0.5,
        function()
            time = time - 1
            if time <= 0 then
                local tab_index = self.vow_data:GetActivityViewTabIndex()
                self.tab_controller:SetSelectedIndex(tab_index-1, true)

                self:DelTimer()
            end
        end)

    
    self:BindEvent(game.VowEvent.UpdateGetReward, function(data)
        self:SetBotProgress()
    end)
end

function VowActivityView:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function VowActivityView:CloseViewCallBack()
    self:DelTimer()
end

function VowActivityView:InitTabs()

	local num = 7

	self.list = self._layout_objs["list_tab"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(false)

    self.ui_list:SetCreateItemFunc(function(obj, idx)
    	return obj
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
    end)

    self.ui_list:SetItemNum(num)
end

function VowActivityView:InitPages()

	local num = 7

	self.page_list = self._layout_objs["list_page"]
    self.ui_page_list = game.UIList.New(self.page_list)
    self.ui_page_list:SetVirtual(false)

    self.ui_page_list:SetCreateItemFunc(function(obj, idx)
    	local item = require("game/vow/vow_activity_template").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_page_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_page_list:SetItemNum(num)
end

function VowActivityView:SetBotProgress()
    local my_cur_deed = self.vow_data:GetMyCurDeed()
    local deed_reward = config.vow_base[1].deed_reward
    for i = 1, 5 do
        local need_deed = deed_reward[i][2]
        local drop_id = deed_reward[i][3]
        local item_id = config.drop[drop_id].client_goods_list[1][1]
        local item_num = config.drop[drop_id].client_goods_list[1][2]

        self._layout_objs["award_img"..i]:SetSprite("ui_item", tostring(config.goods[item_id].icon))
        self._layout_objs["award_value"..i]:SetText(need_deed)
        local bg_img = "ndk_0"..tostring(config.goods[item_id].color)
        self._layout_objs["award_bg"..i]:SetSprite("ui_common",bg_img)

        local got = self.vow_data:CheckRewardGet(i)
        self._layout_objs["get_img"..i]:SetVisible(got)

        if my_cur_deed >= need_deed and not got then
            self:SetEffect(i, true)
        else
            self:SetEffect(i, false)
        end
    end

    self._layout_objs["qihe_value"]:SetText(tostring(my_cur_deed))
end

function VowActivityView:InitBotClick()

    local deed_reward = config.vow_base[1].deed_reward
    local my_cur_deed = self.vow_data:GetMyCurDeed()
    for i = 1, 5 do
        self._layout_objs["award_img"..i]:SetTouchDisabled(false)
        self._layout_objs["award_img"..i]:AddClickCallBack(function()

            local need_deed = deed_reward[i][2]
            local drop_id = deed_reward[i][3]
            local item_id = config.drop[drop_id].client_goods_list[1][1]
            local item_num = config.drop[drop_id].client_goods_list[1][2]
            local got = self.vow_data:CheckRewardGet(i)
            if my_cur_deed >= need_deed and not got then
                self.ctrl:CsDeedReward(i)
            else
                game.BagCtrl.instance:OpenTipsView({id = item_id, num = item_num}, nil, false)
            end
        end)
    end
end

function VowActivityView:SetEffect(index, show)

    if show then
        self._layout_objs["effect"..index]:SetVisible(true)
        local effect = self:CreateUIEffect(self._layout_objs["effect"..index], "effect/ui/ui_huoyue.ab")
        effect:SetLoop(true)
    else
        self._layout_objs["effect"..index]:SetVisible(false)
    end
end

return VowActivityView