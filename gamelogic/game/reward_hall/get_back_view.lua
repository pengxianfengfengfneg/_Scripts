local GetBackView = Class(game.BaseView)

function GetBackView:_init(ctrl)
    self._package_name = "ui_reward_hall"
    self._com_name = "get_back_view"
    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
end

function GetBackView:OnEmptyClick()
    self:Close()
end

function GetBackView:OpenViewCallBack(type)
    self.type = type
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[3054])
    self:InitBtn()

    local act_info
    for _, v in pairs(config.activity_hall) do
        if v.id == self.info.act_id then
            act_info = v
            break
        end
    end
    self._layout_objs.name:SetText(act_info.name)

    local drop_cfg = self.info.coin_reward
    local own_num = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.Copper)
    self.price = self.info.coin_cost
    if type == 2 then
        self.price = self.info.item_cost
        drop_cfg = self.info.item_reward
        own_num = game.BagCtrl.instance:GetNumById(self.info.item_id)
        self._layout_objs.need_icon:SetSprite("ui_item", config.goods[self.info.item_id].icon)
        self._layout_objs.own_icon:SetSprite("ui_item", config.goods[self.info.item_id].icon)
    else
        self._layout_objs.need_icon:SetSprite("ui_common", config.money_type[4].icon)
        self._layout_objs.own_icon:SetSprite("ui_common", config.money_type[4].icon)
    end
    self._layout_objs.own_num:SetText(own_num)
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    local drop_id
    for _, v in ipairs(drop_cfg) do
        if (role_lv >= v[1] and role_lv <= v[2]) or v[2] == -1 then
            drop_id = v[3]
            break
        end
    end

    local drop_info = {}
    for _, v in ipairs(config.drop[drop_id].client_goods_list) do
        table.insert(drop_info, v)
    end

    local level_cfg = config.level[role_lv].coin_back_reward
    if type == 2 then
        level_cfg = config.level[role_lv].item_back_reward
    end
    local level_reward = {}
    for _, v in pairs(level_cfg) do
        if v[1] == self.info.act_id then
            level_reward = v[2]
            break
        end
    end
    for _, v in ipairs(level_reward) do
        table.insert(drop_info, v)
    end

    local list = self:CreateList("list", "game/bag/item/goods_item")
    list:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo({ id = drop_info[idx][1], num = drop_info[idx][2] })
        item:SetShowTipsEnable(true)
    end)
    list:SetItemNum(#drop_info)

    self:SetNum(1)
end

function GetBackView:SetMaxTimes(times)
    self.max_times = times
end

function GetBackView:SetInfo(info)
    self.info = info
end

function GetBackView:SetNum(num)
    self._layout_objs.txt_amount:SetText(num)
    self._layout_objs.need_num:SetText(num * self.price)
    if self.type == 2 then
        local own_num = game.BagCtrl.instance:GetNumById(self.info.item_id)
        local need_num = num * self.price - own_num
        if need_num > 0 then
            local need_money = need_num * config.sys_config.retrieve_item_value_gold.value
            local bind_gold = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.BindGold)
            local backup_gold = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.BackupGold)
            local cfg = config.money_type
            if bind_gold >= need_money then
                self._layout_objs.tips:SetText(string.format(config.words[3070], need_money, cfg[game.MoneyType.BindGold].icon, need_num, config.goods[self.info.item_id].icon))
            else
                local need_backup = backup_gold >= need_money - bind_gold and need_money - bind_gold or backup_gold
                self._layout_objs.tips:SetText(string.format(config.words[3071], bind_gold, cfg[game.MoneyType.BindGold].icon, need_money - bind_gold, need_backup, cfg[game.MoneyType.Gold].icon, need_num, config.goods[self.info.item_id].icon))
            end
        else
            self._layout_objs.tips:SetText("")
        end
    else
        self._layout_objs.tips:SetText("")
    end
end

function GetBackView:InitBtn()
    self._layout_objs.btn_minus:AddClickCallBack(function()
        local num = tonumber(self._layout_objs.txt_amount:GetText())
        if num > 1 then
            self:SetNum(num - 1)
        end
    end)
    self._layout_objs.btn_plus:AddClickCallBack(function()
        local num = tonumber(self._layout_objs.txt_amount:GetText())
        if num < self.max_times then
            self:SetNum(num + 1)
        end
    end)
    self._layout_objs.btn_max:AddClickCallBack(function()
        self:SetNum(self.max_times)
    end)
    self._layout_objs.btn_cancel:AddClickCallBack(function()
        self:Close()
    end)
    self._layout_objs.btn_getback:AddClickCallBack(function()
        local num = tonumber(self._layout_objs.txt_amount:GetText())
        if self.type == 1 then
            game.MainUICtrl.instance:OpenAutoMoneyExchangeView(game.MoneyType.Copper, num * self.price, function()
                game.RewardHallCtrl.instance:SendGetBackReward(self.type, self.info.act_id, num)
            end)
        else
            game.RewardHallCtrl.instance:SendGetBackReward(self.type, self.info.act_id, num)
        end
    end)
end

return GetBackView