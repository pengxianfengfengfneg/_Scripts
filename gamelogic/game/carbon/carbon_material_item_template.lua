local CarbonMaterialItemTemplate = Class(game.UITemplate)

function CarbonMaterialItemTemplate:_init()

end

function CarbonMaterialItemTemplate:OpenViewCallBack()

    self._layout_objs["n7"]:AddClickCallBack(function()
        --元宝重置扫荡
        if self.can_wipe == 2 then
            game.CarbonCtrl.instance:DungResetReq(self.dunge_id)
            game.CarbonCtrl.instance:DungWipeReq(self.dunge_id, 1)
        --免费扫荡不需要重置
        elseif self.can_wipe == 1 then
            game.CarbonCtrl.instance:DungWipeReq(self.dunge_id, 1)
        --挑战
        else
            game.CarbonCtrl.instance:DungEnterReq(self.dunge_id, 1)
        end
    end)
end

function CarbonMaterialItemTemplate:CloseViewCallBack()
    self:DelItems()
end

function CarbonMaterialItemTemplate:_delete()

end

function CarbonMaterialItemTemplate:RefreshItem(dunge_id)

    self._layout_objs["n1"]:SetText(config.dungeon[dunge_id].name)

    self.dunge_id = dunge_id

    self:SetAwards()

    -- self:SetChanTimes()

    -- self:SetBtnState()

    self:SetChanData()
end

function CarbonMaterialItemTemplate:SetAwards()

    self:DelItems()
    self.item_list = {}

    local first_drop_id = config.dungeon_lv[self.dunge_id][1].first_award
    local client_goods_list = config.drop[first_drop_id].client_goods_list

    for i = 1, 3 do
        local item_info = client_goods_list[i]
        local item_root = self._layout_objs["n"..(i+2)]

        local item = require("game/bag/item/goods_item").New()
        item:SetVirtual(item_root)
        item:Open()
        table.insert(self.item_list, item)

        if item_info then
            item:SetItemInfo({ id = item_info[1], num = item_info[2]})
            item_root:SetVisible(true)
            item:SetShowTipsEnable(true)
        else
            item:ResetItem()
            item_root:SetVisible(false)
            item:SetShowTipsEnable(false)
        end
    end
end

function CarbonMaterialItemTemplate:DelItems()
    
    for key, var in pairs(self.item_list or {}) do

        var:DeleteMe()
    end

    self.item_list = nil
end

function CarbonMaterialItemTemplate:SetChanTimes()

    local dunge_data = game.CarbonCtrl.instance:GetData()
    local left_chan_times = dunge_data:GetMaterialCarbonsChanTimes(self.dunge_id)

    self._layout_objs["n8"]:SetText(string.format(config.words[1403], left_chan_times))

    local btn = self._layout_objs["n7"]
    if left_chan_times < 1 then
        btn:SetEnable(false)
    else
        btn:SetEnable(true)
    end
end

function CarbonMaterialItemTemplate:SetBtnState()

    local dunge_data = game.CarbonCtrl.instance:GetData()
    self.can_wipe = dunge_data:CanWipe(self.dunge_id)

    local btn_title = self._layout_objs["n7"]:GetChild("title")
    if self.can_wipe then
        btn_title:SetText(config.words[1404])
    else
        btn_title:SetText(config.words[1405])
    end
end

function CarbonMaterialItemTemplate:SetChanData()

    local dunge_data = game.CarbonCtrl.instance:GetData()
    local left_chan_times = dunge_data:GetMaterialCarbonsChanTimes(self.dunge_id)

    local wipe_type, can_wipe, left_reset_times, reset_cost = dunge_data:GetDungeWipeState(self.dunge_id)
    --print("---------self.dunge_id-------",self.dunge_id, wipe_type, can_wipe, left_reset_times, reset_cost)
    self.can_wipe = 0

    if wipe_type == 1 then
        if can_wipe == 1 then
            self.can_wipe = 1
            self._layout_objs["n7/title"]:SetText(config.words[1404])
        else
            self._layout_objs["n7/title"]:SetText(config.words[1405])
        end
        self._layout_objs["n8"]:SetText(string.format(config.words[1403], left_chan_times))

        self._layout_objs["n11"]:SetVisible(false)
    else
        self._layout_objs["n7/title"]:SetText(config.words[1404])
        if can_wipe == 1 then
            self.can_wipe = 2
            self._layout_objs["n7"]:SetEnable(true)
            self._layout_objs["n10"]:SetText(string.format(config.words[1407], reset_cost))
            self._layout_objs["n11"]:SetVisible(true)

        else
            self._layout_objs["n7"]:SetEnable(false)
            self._layout_objs["n11"]:SetVisible(false)
        end
        self._layout_objs["n8"]:SetText(string.format(config.words[1406], left_reset_times))

        
    end
end


return CarbonMaterialItemTemplate