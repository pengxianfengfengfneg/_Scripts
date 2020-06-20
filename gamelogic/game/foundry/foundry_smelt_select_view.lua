local FoundrySmeltSelectView = Class(game.BaseView)

function FoundrySmeltSelectView:_init(ctrl)
    self._package_name = "ui_foundry"
    self._com_name = "foundry_smelt_select_view"
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function FoundrySmeltSelectView:_delete()
end

function FoundrySmeltSelectView:OpenViewCallBack(bag_pos)

    self:InitList()

    self:SetColorTips()

    self:SetSmeltValue()

    self:BindEvent(game.FoundryEvent.UpdateSmeltInfo, function()
        self:UpdateList()
        self:SetSmeltValue()
    end)

    self:BindEvent(game.FoundryEvent.UpdateSmeltColor, function()
        self:SetColorTips()
    end)

    self._layout_objs["btn_close"]:AddClickCallBack(function()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_smelt_select_view/btn_close"})
        self:Close()
    end)

    self._layout_objs["n13"]:AddClickCallBack(function()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_smelt_select_view/n13"})
        game.ViewMgr:FireGuideEvent()
        self:OnClickSmetl()
    end)

    self._layout_objs["n14"]:AddClickCallBack(function()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_smelt_select_view/n14"})
        game.ViewMgr:FireGuideEvent()
        self:OnClickOneKey()
    end)

    self._layout_objs["n6"]:AddClickCallBack(function()
        self.ctrl:OpenSmeltSetView()
    end)

    if bag_pos then
        self:OnDefaultSelect(bag_pos)
    end
end

function FoundrySmeltSelectView:CloseViewCallBack()
end

function FoundrySmeltSelectView:InitList()

    self.equip_list = game.BagCtrl.instance:GetSmeltEquipList()

    self.select_list = {}

    self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/bag/item/goods_item").New()
        item:SetParent(self)
        item:SetVirtual(obj)
        item:Open()
        item:SetShowTipsEnable(true)
        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)

        item.idx = idx

        local item_info = self.equip_list[idx]
        item:SetItemInfo({ id = item_info.goods.id, num = item_info.goods.num, bind = item_info.goods.bind})
        item:SetNum()
        item:AddClickEvent(function()
            self:OnSelect(idx)
        end)

        local offset_score = self.ctrl:CalEquipOffsetScore(item_info.goods)
        item:SetArrowVisibel(offset_score > 0)
 
        item:SetLongClickFunc(function()
            game.BagCtrl.instance:OpenBagEquipInfoView(item_info.goods, true)
        end)

        local f = self.select_list[idx]
        if f then
            item:SetSelect(true)
        else
            item:SetSelect(false)
        end
    end)

    self.ui_list:SetItemNum(#self.equip_list)
end

function FoundrySmeltSelectView:OnSelect(idx)

    local item
    self.ui_list:Foreach(function (item_t)
        if item_t.idx == idx then
            item = item_t
        end
    end)

    if item == nil then
        return
    end

    if item:GetSelect() then
        item:SetSelect(false)
        self.select_list[idx] = false
    else
        item:SetSelect(true)
        self.select_list[idx] = true
    end

    self:SetSmeltValue()
end

function FoundrySmeltSelectView:UpdateList()
    self.equip_list = game.BagCtrl.instance:GetSmeltEquipList()
    self.select_list = {}
    self.ui_list:SetItemNum(#self.equip_list)
end

function FoundrySmeltSelectView:OnClickOneKey()

    local smelt_data = self.ctrl:GetSmeltData()
    local select_color_index = smelt_data.value
    if select_color_index == 0 then
        select_color_index = 1
    end
    local select_color = select_color_index + 1

    self.select_list = {}

    for k, item_info in pairs(self.equip_list) do

        local cfg = config.goods[item_info.goods.id]
        local color = cfg.color
        if color <= select_color then
            self.select_list[k] = true
        end
    end

    self.ui_list:Foreach(function(item)
        if item.idx and self.select_list[item.idx] then
            item:SetSelect(true)
        else
            item:SetSelect(false)
        end
    end)

    self:SetSmeltValue()
end

function FoundrySmeltSelectView:OnClickSmetl()

    local need_warning = false
    local mycareer = game.RoleCtrl.instance:GetCareer()
    local wear_equip = {}
    for i = 1, 10 do
        local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(i)
        if equip_info and equip_info.id ~= 0 then
            wear_equip[i] = equip_info
        end
    end

    local pos_t = {}

    for k, v in pairs(self.select_list) do

        local item_info = self.equip_list[k]
        if item_info and v then

            local t = {}
            t.pos = item_info.goods.pos
            table.insert(pos_t, t)


            local cfg = config.goods[item_info.goods.id]

            if cfg.career == 0 or cfg.career == mycareer then

                --身上有同类型装备
                if wear_equip[cfg.pos] then

                    --身上装备评分
                    local wear_equip_info = wear_equip[cfg.pos]
                    local wear_base_attr  = config.goods[wear_equip_info.id].attr
                    local wear_random_attr = wear_equip_info.attr

                    local wear_base_score = game.Utils.CalculateCombatPower2(wear_base_attr)
                    local wear_random_score = game.Utils.CalculateCombatPower2(wear_random_attr)
                    local wear_total_score = wear_base_score + wear_random_score

                    --选择装备评分
                    local select_base_attr = config.goods[item_info.goods.id].attr
                    local select_random_attr = item_info.goods.attr

                    local select_base_score = game.Utils.CalculateCombatPower2(select_base_attr)
                    local select_random_score = game.Utils.CalculateCombatPower2(select_random_attr)
                    local select_total_score = select_base_score + select_random_score

                    if select_total_score > wear_total_score then
                        need_warning = true
                    end
                else
                    need_warning = true
                end
            end
        end
    end

    if need_warning then
        local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[1241])
        msg_box:SetOkBtn(function()
            self.ctrl:CsSmeltDo(pos_t)
            msg_box:Close()
            msg_box:DeleteMe()
        end)
        msg_box:SetCancelBtn(function()
            end)
        msg_box:Open()
    else
        self.ctrl:CsSmeltDo(pos_t)
    end
end

function FoundrySmeltSelectView:SetColorTips()

    local smelt_data = self.ctrl:GetSmeltData()

    local select_color_index = smelt_data.value
    if select_color_index == 0 then
        select_color_index = 1
    end
    local select_color = select_color_index + 1

    local color_name = game.Utils.GetColorName(select_color)
    self._layout_objs["color_txt"]:SetText(color_name)

    local color = cc.GoodsColor[select_color]
    self._layout_objs["color_txt"]:SetColor(color.x, color.y, color.z, color.w)
end

function FoundrySmeltSelectView:SetSmeltValue()

    local smelt_value = 0

    for k, v in pairs(self.select_list) do
        local item_info = self.equip_list[k]
        if item_info and v then

            local cfg = config.equip_attr[item_info.goods.id]
            smelt_value = cfg.smelt + smelt_value
        end
    end

    self._layout_objs["exp_txt"]:SetText(tostring(smelt_value))
end

function FoundrySmeltSelectView:OnDefaultSelect(bag_pos)

    local index = 1
    for k, v in ipairs(self.equip_list) do
        if v.goods.pos == bag_pos then
            index = k
        end
    end

    self:OnSelect(index)
end

return FoundrySmeltSelectView
