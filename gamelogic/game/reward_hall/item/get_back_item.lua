local GetBackItem = Class(game.UITemplate)

function GetBackItem:OpenViewCallBack()
    self._layout_objs.btn_normal:AddClickCallBack(function()
        game.RewardHallCtrl.instance:OpenGetBackView(self.cfg, self.info.times, 1)
    end)

    self._layout_objs.btn_perfect:AddClickCallBack(function()
        game.RewardHallCtrl.instance:OpenGetBackView(self.cfg, self.info.times, 2)
    end)

    self.controller = self:GetRoot():GetController("c1")
end

function GetBackItem:SetItemInfo(info)
    self.info = info
    if info.times > 0 then
        self.controller:SetSelectedIndexEx(0)
    else
        self.controller:SetSelectedIndexEx(1)
    end
    self._layout_objs.times:SetText(info.times)
    local act_info
    for _, v in pairs(config.activity_hall) do
        if v.id == info.id then
            act_info = v
            break
        end
    end
    self._layout_objs.name:SetText(act_info.name)
    self.cfg = config.get_back[info.id]

    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    local drop_id
    for _, v in ipairs(self.cfg.item_reward) do
        if (role_lv >= v[1] and role_lv <= v[2]) or v[2] == -1 then
            drop_id = v[3]
            break
        end
    end

    local drop_info = {}
    for _, v in ipairs(config.drop[drop_id].client_goods_list) do
        table.insert(drop_info, v)
    end

    local level_cfg = config.level[role_lv].item_back_reward
    local level_reward = {}
    for _, v in pairs(level_cfg) do
        if v[1] == info.id then
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

    self._layout_objs.money:SetText(game.Utils.FormatLargeNum(self.cfg.coin_cost))
    self._layout_objs.num:SetText(game.Utils.FormatLargeNum(self.cfg.item_cost))
    self._layout_objs.item_img:SetSprite("ui_item", config.goods[self.cfg.item_id].icon)
end

function GetBackItem:SetBG(val)
    if val then
        self._layout_objs.bg:SetSprite("ui_common", "009_1")
    else
        self._layout_objs.bg:SetSprite("ui_common", "009_2")
    end
end

return GetBackItem