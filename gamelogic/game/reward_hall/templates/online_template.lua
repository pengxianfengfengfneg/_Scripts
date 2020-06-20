local OnlineTemplate = Class(game.UITemplate)

function OnlineTemplate:_init()
    self._package_name = "ui_reward_hall"
    self._com_name = "online_template"
end

function OnlineTemplate:OpenViewCallBack()
    self.pray_times = 0
    self:InitReward()
    self:InitBtn()
    self:UpdateView()
    self:BindEvent(game.RewardHallEvent.UpdateOnlinePray, function(data)
        self:Pray(data)
    end)
    self:BindEvent(game.RewardHallEvent.UpdateOnlineInfo, function(data)
        self:UpdateView(data)
    end)
    game.MainUICtrl.instance:SendGetOnlineTime()
    self:BindEvent(game.ActivityEvent.TodayOnlineTime, function(data)
        self:SetPrayTimes(data)
    end)

    self.is_seleanim = global.UserDefault:GetBool("SeleAnim")

    if self.is_seleanim ~= "" then
        self._layout_objs.btn_checkbox.selected = self.is_seleanim
    end
end

function OnlineTemplate:CloseViewCallBack()
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

function OnlineTemplate:InitReward()
    self.goods_items = {}
    for i, v in ipairs(config.online_reward.reward) do
        local item = self:GetTemplate("game/bag/item/goods_item", "goods_item" .. i)
        local drop_info = config.drop[v[2]].client_goods_list[1]
        item:SetItemInfo({ id = drop_info[1], num = drop_info[2] })
        item:SetShowTipsEnable(true)
        table.insert(self.goods_items, item)
    end
end

function OnlineTemplate:InitBtn()
    self._layout_objs.btn_pray:AddClickCallBack(function()
        game.RewardHallCtrl.instance:SendOnlinePray()
    end)

    self._layout_objs.btn_get:AddClickCallBack(function()
        if self.get_id then
            game.RewardHallCtrl.instance:SendOnlineRewardGet(self.get_id)
            self.get_id = nil
        end
    end)

    self._layout_objs.btn_shop:AddClickCallBack(function()
        game.ShopCtrl.instance:OpenViewByShopId(21)
    end)

    self._layout_objs.btn_checkbox:AddClickCallBack(function()
        global.UserDefault:SetBool("SeleAnim", self._layout_objs.btn_checkbox.selected)
        self.is_seleanim = self._layout_objs.btn_checkbox.selected
    end)

end

function OnlineTemplate:UpdateView()
    local info = game.RewardHallCtrl.instance:GetOnlineInfo()
    if info == nil then
        return
    end
    if info.times >= config.online_reward.max_times then
        self._layout_objs.times:SetText(config.words[3042])
    else
        self._layout_objs.times:SetText(string.format(config.words[3041], self.pray_times - info.times))
    end

    self.get_id = nil
    for _, v in pairs(info.list) do
        self.goods_items[v.id]:SetSelect(v.state == 1)
        self.goods_items[v.id]:ShowMask(v.state == 2)
        if v.state == 1 then
            self.get_id = v.id
        end
    end
    self._layout_objs.btn_pray:SetVisible(self.get_id == nil)
    self._layout_objs.btn_get:SetVisible(self.get_id ~= nil)
end

function OnlineTemplate:Pray(data)
    if data.times >= config.online_reward.max_times then
        self._layout_objs.times:SetText(config.words[3042])
    else
        self._layout_objs.times:SetText(string.format(config.words[3041], self.pray_times - data.times))
    end

    self.get_id = data.id
    self._layout_objs.btn_pray:SetVisible(false)
    self._layout_objs.btn_get:SetVisible(false)


    if self.is_seleanim then
        self._layout_objs.btn_pray:SetVisible(self.get_id == nil)
        self._layout_objs.btn_get:SetVisible(self.get_id ~= nil)
    else
        self:PrayEffect(data.id)
    end
end

function OnlineTemplate:PrayEffect(id)
    self.tween = DOTween.Sequence()
    for i = 1, 3 do
        for j = 1, 8 do
            self.tween:AppendInterval(0.1 + 0.01 * i)
            self.tween:AppendCallback(function()
                for k, v in ipairs(self.goods_items) do
                    v:SetSelect(j == k)
                end
            end)
        end
    end
    for j = 1, 8 do
        self.tween:AppendInterval(0.2)
        self.tween:AppendCallback(function()
            for k, v in ipairs(self.goods_items) do
                v:SetSelect(j == k)
            end
        end)
    end
    for j = 1, id do
        self.tween:AppendInterval(0.3)
        self.tween:AppendCallback(function()
            for k, v in ipairs(self.goods_items) do
                v:SetSelect(j == k)
            end
        end)
    end
    self.tween:AppendCallback(function()
        self._layout_objs.btn_pray:SetVisible(self.get_id == nil)
        self._layout_objs.btn_get:SetVisible(self.get_id ~= nil)
    end)
end

function OnlineTemplate:SetPrayTimes(time)
    self.pray_times = 0
    for _, v in ipairs(config.online_reward.online_time) do
        if time >= v[2] then
            self.pray_times = v[1]
        end
    end
    local info = game.RewardHallCtrl.instance:GetOnlineInfo()
    if info == nil then
        return
    end
    if info.times >= config.online_reward.max_times then
        self._layout_objs.times:SetText(config.words[3042])
    else
        self._layout_objs.times:SetText(string.format(config.words[3041], self.pray_times - info.times))
    end
end

return OnlineTemplate