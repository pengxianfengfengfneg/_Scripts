local FoundryStoneTemplate = Class(game.UITemplate)

local panel_pos = {
    [1] = {278,173},
    [2] = {447,396},
    [3] = {271,530},
    [4] = {103,402},
}

function FoundryStoneTemplate:_init()
	self._package_name = "ui_foundry"
    self._com_name = "foundry_stone_template"
    self.foundry_data = game.FoundryCtrl.instance:GetData()
end

--宝石提升、镶嵌
function FoundryStoneTemplate:OpenViewCallBack()

    self._layout_objs["n12"]:SetTouchDisabled(false)
    self._layout_objs["n12"]:AddClickCallBack(function()
        self._layout_objs["oper_panel"]:SetVisible(false)
    end)

    self:BindEvent(game.FoundryEvent.InlaySucc, function(data)
        self:RefreshView(data)
        self:SetStoneSuitNum()
        self:SetMidItemRedPoint()
    end)

    self._layout_objs["n11"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:OpenStoneSuitAttrView()
    end)

    self._layout_objs["inlay_btn"]:AddClickCallBack(function()
        if self.stone_index then
            local pos = self.select_equip_pos*10 + self.stone_index
            game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_view2/stone_template/inlay_btn"})
            game.FoundryCtrl.instance:OpenStoneInlayView(pos)
            self._layout_objs["oper_panel"]:SetVisible(false)
        end
    end)

    self._layout_objs["advance_btn"]:AddClickCallBack(function()
        if self.stone_index then
            local pos = self.select_equip_pos*10 + self.stone_index
            local stone_id = self.cur_stone_id_list[self.stone_index]
            game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_view2/stone_template/upgrade_btn"})
            game.FoundryCtrl.instance:OpenAdvanceView({stone_id,pos})
            self._layout_objs["oper_panel"]:SetVisible(false)
        end
    end)

    self:InitMidItems()

    self:InitBotEquips()

    self:SetStoneSuitNum()
end

function FoundryStoneTemplate:CloseViewCallBack()

    if self.bot_ui_list then
        self.bot_ui_list:DeleteMe()
        self.bot_ui_list = nil
    end

    for k, v in pairs(self.mid_item_list or {}) do
        v:DeleteMe()
    end
    self.mid_item_list = nil
end

function FoundryStoneTemplate:InitBotEquips()

    local godweapon_data = game.FoundryCtrl.instance:GetData():GetGodweaponData()
    local hideweapon_data = game.FoundryCtrl.instance:GetData():GetHideWeaponData()
    local weaponsoul_data = game.WeaponSoulCtrl.instance:GetData():GetAllData()
    local dragon_data = game.FoundryCtrl.instance:GetEquipInfoByType(12)

    self.bot_list = self._layout_objs["list"]
    self.bot_ui_list = game.UIList.New(self.bot_list)
    self.bot_ui_list:SetVirtual(false)

    self.bot_ui_list:SetCreateItemFunc(function(obj)

        local equip_item = require("game/foundry/foundry_stone_bot_template").New(self)
        equip_item:SetVirtual(obj)
        equip_item:Open()
        return equip_item
    end)

    self.bot_ui_list:SetRefreshItemFunc(function (equip_item, idx)
        equip_item.idx = idx
        equip_item:RefreshItem(idx)
    end)

    self.bot_ui_list:AddClickItemCallback(function(item)
        
        self._layout_objs["oper_panel"]:SetVisible(false)

        self:OnSelectEquip(item.idx)

        if item.idx == 2 then
            game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_view2/stone_template/bot_btn2"})
            game.ViewMgr:FireGuideEvent()
        end
    end)

    local can_stone_pos = {}
    for i = 1, 8 do
        table.insert(can_stone_pos, i)
    end

    if godweapon_data and godweapon_data.id > 0 then
        table.insert(can_stone_pos, 9)   
    end

    if hideweapon_data and hideweapon_data.id > 0 then
        table.insert(can_stone_pos, 10)
    end

    if weaponsoul_data and weaponsoul_data.id > 0 then
        table.insert(can_stone_pos, 11)
    end

    if dragon_data and dragon_data.id > 0 then
        table.insert(can_stone_pos, 12)
    end

    self.can_stone_pos = can_stone_pos

    self.bot_ui_list:SetItemNum(#can_stone_pos)

    self.bot_ui_list:ScrollToView(0)

    self:OnSelectEquip(1)

    self:SetBotRedPoint(true)
end

function FoundryStoneTemplate:SetStoneSuitNum()

    local foundry_data = game.FoundryCtrl.instance:GetData()
    local num = foundry_data:GetStoneSuitNum()
    self._layout_objs["n11/title"]:SetText(string.format(config.words[1238], num))
end

function FoundryStoneTemplate:OnSelectEquip(select_index)

    self.select_index = select_index
    self.select_equip_pos = self.can_stone_pos[select_index]
    --默认选择第一个装备
    local equip_item
    self.bot_ui_list:Foreach(function(v)
        v:SetSelect(false)
        if v.idx == select_index then
            equip_item = v
        end
    end)
    equip_item:SetSelect(true)

    self:SetMidItems()

    self:SetMidItemRedPoint()
end

function FoundryStoneTemplate:InitMidItems()

    self.mid_item_list = {}

    for i = 1, 4 do
        local item = require("game/bag/item/goods_item").New()
        item:SetVirtual(self._layout_objs["inlay_item"..i])
        item:Open()
        item:SetTouchEnable(true)
        item:ResetItem()
        self.mid_item_list[i] = item

        item:AddClickEvent(function()
            self:ShowStoneOperPanel(i)

            if i == 1 then
                game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_view2/stone_template/mid_btn1"})
                game.ViewMgr:FireGuideEvent()
            end
        end)
    end
end

function FoundryStoneTemplate:SetMidItems()

    self.cur_stone_id_list = {}

    local stone_pos_cfg = config.equip_stone_pos[self.select_equip_pos]
    local stone_num = game.Utils.getTableLength(stone_pos_cfg)

    local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(self.select_equip_pos)
    if self.select_equip_pos == 9 then
        equip_info = game.FoundryCtrl.instance:GetData():GetGodweaponData()
    elseif self.select_equip_pos == 10 then
        equip_info = game.FoundryCtrl.instance:GetData():GetHideWeaponData()
    elseif self.select_equip_pos == 11 then
        equip_info = game.WeaponSoulCtrl.instance:GetData():GetAllData()
    end

    for i = 1, 4 do

        local stone_pos = self.select_equip_pos*10 + i    --宝石格子id
        local stone_item_id = 0

        if equip_info and equip_info.stones then

            for _, v in pairs(equip_info.stones) do
                if v.pos == stone_pos then
                    stone_item_id = v.id
                    break
                end
            end
        end

        --未镶嵌
        if stone_item_id == 0 then
            self.mid_item_list[i]:ResetItem()
            self._layout_objs["inlay_item"..i.."/stone_name"]:SetText("")
            self._layout_objs["inlay_item"..i.."/item_attr"]:SetText("")
            self._layout_objs["inlay_item"..i.."/jh_img"]:SetVisible(true)
        else
            local item_cfg = config.goods[stone_item_id]
            local cfg = self:GetStoneCfg(stone_item_id)
            local attr = cfg.attr
            local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr[1])

            self._layout_objs["inlay_item"..i.."/stone_name"]:SetText(item_cfg.name)

            self.mid_item_list[i]:SetItemInfo({id = stone_item_id})

            self._layout_objs["inlay_item"..i.."/item_attr"]:SetText(string.format(config.words[1226], attr_name, attr[2]))
            -- self._layout_objs["inlay_item"..i.."/sub_btn"]:SetVisible(true)
            self._layout_objs["inlay_item"..i.."/jh_img"]:SetVisible(false)
        end

        self.cur_stone_id_list[i] = stone_item_id
    end
end

function FoundryStoneTemplate:GetStoneCfg(stone_item_id)

    local cfg

    for k, v in pairs(config.equip_stone) do

        for item_id, v2 in pairs(v) do

            if item_id == stone_item_id then
                cfg = v2
                break
            end
        end

        if cfg then
            break
        end
    end

    return cfg
end

function FoundryStoneTemplate:GetSelectIndex()
    return self.select_index or 1
end

function FoundryStoneTemplate:RefreshView(data)

    --底部列表
    local godweapon_data = game.FoundryCtrl.instance:GetData():GetGodweaponData()
    local hideweapon_data = game.FoundryCtrl.instance:GetData():GetHideWeaponData()
    local weaponsoul_data = game.WeaponSoulCtrl.instance:GetData():GetAllData()
    local dragon_data = game.FoundryCtrl.instance:GetEquipInfoByType(12)


    local can_stone_pos = {}
    for i = 1, 8 do
        table.insert(can_stone_pos, i)
    end

    if godweapon_data and godweapon_data.id > 0 then
        table.insert(can_stone_pos, 9)   
    end

    if hideweapon_data and hideweapon_data.id > 0 then
        table.insert(can_stone_pos, 10)
    end

    if weaponsoul_data and weaponsoul_data.id > 0 then
        table.insert(can_stone_pos, 11)
    end

    if dragon_data and dragon_data.id > 0 then
        table.insert(can_stone_pos, 12)
    end

    self.can_stone_pos = can_stone_pos
    self.bot_ui_list:SetItemNum(#can_stone_pos)

    self:SetBotRedPoint()

    --中部列表
    local pos = math.floor(data.pos / 10)
    if self.select_equip_pos == pos then
        self:SetMidItems()
    end
end

function FoundryStoneTemplate:ShowStoneOperPanel(index)

    self.stone_index = index
    local pos_t = panel_pos[index]
    self._layout_objs["oper_panel"]:SetPosition(pos_t[1], pos_t[2])
    self._layout_objs["oper_panel"]:SetVisible(true)

    if self._layout_objs["inlay_item"..index.."/hd"]:IsVisible() then
        self._layout_objs["btn_hd"]:SetVisible(true)
    else
        self._layout_objs["btn_hd"]:SetVisible(false)
    end

    local stone_id = self.cur_stone_id_list[index]
    if stone_id == 0 then
        self._layout_objs["advance_btn"]:SetVisible(false)
        self._layout_objs["oper_panel_bg"]:SetSize(173, 94)
    else
        self._layout_objs["advance_btn"]:SetVisible(true)
        self._layout_objs["oper_panel_bg"]:SetSize(173, 149)
    end
end

function FoundryStoneTemplate:SetBotRedPoint(first_open)

    local rp_idx
    self.bot_ui_list:Foreach(function(v)
        local equip_pos = v.idx
        local can_inlay = self.foundry_data:CheckEquipCanStone(equip_pos)

        if can_inlay then
            if not rp_idx then
                rp_idx = equip_pos
            else
                if equip_pos < rp_idx then
                    rp_idx = equip_pos
                end
            end
        end
        v:SetRP(can_inlay)
    end)

    if first_open then
        if rp_idx then
            self.bot_ui_list:ScrollToView(rp_idx-1)
            self:OnSelectEquip(rp_idx)
        end
    end
end

function FoundryStoneTemplate:SetMidItemRedPoint()

    for k, v in pairs(self.mid_item_list) do
        local stone_pos = k + self.select_equip_pos * 10
        local can_inlay = self.foundry_data:CheckCanInlay(stone_pos)
        self._layout_objs["inlay_item"..k.."/hd"]:SetVisible(can_inlay)
    end
end

return FoundryStoneTemplate