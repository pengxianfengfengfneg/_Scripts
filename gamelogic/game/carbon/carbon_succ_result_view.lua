local CarbonSuccResultView = Class(game.BaseView)

function CarbonSuccResultView:_init(ctrl)
    self._package_name = "ui_carbon"
    self._com_name = "carbon_succ_result_view"
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function CarbonSuccResultView:OpenViewCallBack(result_info)
    self.result_info = result_info

    local dun_cfg = config.dungeon_lv[result_info.dung_id]
    local dun_lv_cfg = dun_cfg[result_info.level]

    local controller = self:GetRoot():GetController("c1")

    local award_items = {}
    for _, v in pairs(result_info.rewards) do
        local id = v.gid
        if v.type ~= 5 then
            id = config.money_type[v.type].goods
        end
        table.insert(award_items, {id = id, num = v.gnum})
    end

    if result_info.is_first_chal == 1 and dun_lv_cfg.false_reward ~= 0 then
        local drop_cfg = config.drop[dun_lv_cfg.false_reward]
        if drop_cfg then
            for _, v in pairs(drop_cfg.client_goods_list) do
                table.insert(award_items, {id = v[1], num = v[2]})
            end
        end
    end

    local list = self:CreateList("list", "game/bag/item/goods_item")
    list:SetRefreshItemFunc(function(item, idx)
        local item_info = award_items[idx]
        item:SetItemInfo(item_info)
        item:SetShowTipsEnable(true)
    end)
    list:SetItemNum(#award_items)

    self._layout_objs.btn_leave:AddClickCallBack(function()
        self.ctrl:DungLeaveReq()
        self:Close()
    end)

    self._layout_objs.btn_next:AddClickCallBack(function()
        local next_dun_lv_cfg = dun_cfg[result_info.level + 1]
        local role_fight = game.RoleCtrl.instance:GetCombatPower()
        if next_dun_lv_cfg.fight > role_fight then
            local str = string.format(config.words[1422], next_dun_lv_cfg.fight)
            local msg_box = game.GameMsgCtrl.instance:CreateMsgTips(str)
            msg_box:SetBtn1(nil, function()
                self.ctrl:DungEnterReq(result_info.dung_id, result_info.level + 1)
                self:Close()
            end)
            msg_box:SetBtn2(config.words[101], function()
                self.ctrl:DungLeaveReq()
                self:Close()
            end)
            msg_box:Open()
        else
            self.ctrl:DungEnterReq(result_info.dung_id, result_info.level + 1)
            self:Close()
        end
    end)

    local cd = config.dungeon[result_info.dung_id].count_down
    self._layout_objs.desc:SetText(string.format(config.words[1436], dun_lv_cfg.chapter_name, dun_lv_cfg.name))
    if cd ~= 0 and result_info.level < #dun_cfg then
        controller:SetSelectedIndexEx(0)
        self:StartNextCountTime(cd)
    else
        controller:SetSelectedIndexEx(1)
        self:StartLeaveCountTime(10)
    end
end

function CarbonSuccResultView:CloseViewCallBack()
    self:StopCountTime()
end

function CarbonSuccResultView:StartNextCountTime(count_time)
    self:StopCountTime()
    self.tween = DOTween.Sequence()
    self.tween:AppendCallback(function()
        if count_time < 0 then
            self:StopCountTime()

            self.ctrl:DungEnterReq(self.result_info.dung_id, self.result_info.level + 1)
            self:Close()
        else
            self._layout_objs.text:SetText(string.format(config.words[1421], count_time))
        end
        count_time = count_time - 1
    end)
    self.tween:AppendInterval(1)
    self.tween:SetLoops(-1)
end

function CarbonSuccResultView:StopCountTime()
    self._layout_objs.text:SetText("")
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

function CarbonSuccResultView:StartLeaveCountTime(count_time)
    self:StopCountTime()
    self.tween = DOTween.Sequence()
    self.tween:AppendCallback(function()
        if count_time < 0 then
            self:DoClose()
        else
            self._layout_objs.text:SetText(string.format(config.words[1424], count_time))
        end
        count_time = count_time - 1
    end)
    self.tween:AppendInterval(1)
    self.tween:SetLoops(-1)
end

function CarbonSuccResultView:DoClose()
    game.CarbonCtrl.instance:DungLeaveReq()
    self:Close()
end

return CarbonSuccResultView