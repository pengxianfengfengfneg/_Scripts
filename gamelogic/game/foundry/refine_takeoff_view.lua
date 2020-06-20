local RefineTakeoffView = Class(game.BaseView)

function RefineTakeoffView:_init(ctrl)
    self._package_name = "ui_equip_refine"
    self._com_name = "refine_takeoff_view"

    self._show_money = true

    self.ctrl = ctrl
end

function RefineTakeoffView:_delete()
end

function RefineTakeoffView:OpenViewCallBack()
    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[5213])

    self:InitItems()

    self:InitTopUnwearEquips()

    self:OnDefaultClickTop()

    self:InitEffect()

    --拆卸
    self._layout_objs["takeoff_btn"]:AddClickCallBack(function()
        
        if self.select_index then
            local pos = self.equip_pos_list[self.select_index]
            self.ctrl:CsEquipStripParis(pos)
        end
    end)

    self:BindEvent(game.FoundryEvent.UpdateStrip, function(data)
		self:PLayEffect()
        self:RefreshView()
    end)
end

function RefineTakeoffView:CloseViewCallBack()

    if self.top_ui_list then
        self.top_ui_list:DeleteMe()
        self.top_ui_list = nil
    end

    if self.sour_item then
        self.sour_item:DeleteMe()
        self.sour_item = nil
    end

    if self.target_item then
        self.target_item:DeleteMe()
        self.target_item = nil
    end
end

function RefineTakeoffView:InitItems()

    self.sour_item = require("game/bag/item/goods_item").New()
    self.sour_item:SetVirtual(self._layout_objs["sour_item"])
    self.sour_item:Open()
    self.sour_item:SetTouchEnable(true)
    self.sour_item:ResetItem()

    self.target_item = require("game/bag/item/goods_item").New()
    self.target_item:SetVirtual(self._layout_objs["need_item"])
    self.target_item:Open()
    self.target_item:SetTouchEnable(true)
    self.target_item:ResetItem()
end

function RefineTakeoffView:InitTopUnwearEquips()

    if self.top_ui_list then
        self.top_ui_list:DeleteMe()
        self.top_ui_list = nil
    end

    local equip_pos_list = {}
    local count = 0
    for pos, v in pairs(config.equip_paris) do

        local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(pos)
        if equip_info.paris > 0 then
            count = count + 1
            table.insert(equip_pos_list, pos)
        end
    end
    self.equip_pos_list = equip_pos_list

    self.top_list = self._layout_objs["list"]
    self.top_ui_list = game.UIList.New(self.top_list)
    self.top_ui_list:SetVirtual(true)

    self.top_ui_list:SetCreateItemFunc(function(obj)

        local equip_item = require("game/bag/item/goods_item").New()
        equip_item:SetVirtual(obj)
        equip_item:Open()
        return equip_item
    end)

    self.top_ui_list:SetRefreshItemFunc(function (equip_item, idx)
        equip_item.idx = idx

        local pos = equip_pos_list[idx]
        local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(pos)

        if equip_info and equip_info.id and equip_info.id ~= 0 then
            
            self.can_click_index = idx
            local cur_paris = equip_info.paris
            local cur_cfg = config.equip_paris[pos][cur_paris]
            equip_item:SetItemInfo({ id = equip_info.id, icon_name = cur_cfg.icon})
            equip_item:SetShowTipsEnable(true)
            equip_item:AddClickEvent(function ()
                self.top_ui_list:Foreach(function(v)
                    v:SetSelect(false)
                end)
                equip_item:SetSelect(true)
                self:OnSelectEquip(idx)
            end)
        else
            equip_item:ResetItem()
            local image = tostring(pos)
            equip_item:SetItemImage(image)
            equip_item:SetTouchEnable(false)
        end

        if self.select_index and idx == self.select_index then
            equip_item:SetSelect(true)
        else
            equip_item:SetSelect(false)
        end
    end)

    self.top_ui_list:SetItemNum(count)
end

function RefineTakeoffView:OnSelectEquip(index)
    self.select_index = index
    self:ShowInUnwear()
end

function RefineTakeoffView:ShowInUnwear()

    local pos = self.equip_pos_list[self.select_index]
    local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(pos)
    local cur_paris = equip_info.paris
    local cur_cfg = config.equip_paris[pos][cur_paris]

    self.sour_item:SetItemInfo({ id = equip_info.id, icon_name = cur_cfg.icon })
    self.sour_item:AddClickEvent(function()
        game.BagCtrl.instance:OpenWearEquipInfoView(equip_info, true)
    end)

    --拆卸后获得材料
    local return_num = 0
    for i = 1, cur_cfg.lv do
        local cost_num = config.equip_paris[pos][i].cost[2]
        return_num = return_num + cost_num
    end
    self.target_item:SetItemInfo({ id = cur_cfg.cost[1], num = return_num})
    self.target_item:SetShowTipsEnable(true)

    local skill_id1 = cur_cfg.skill[1]
    local skill_lv1 = cur_cfg.skill[2]
    local skill_desc1 = config.skill[skill_id1][skill_lv1].desc
    self._layout_objs["sour_txt1"]:SetText(skill_desc1)
    self._layout_objs["sour_txt2"]:SetText(string.format(config.words[5214], cur_cfg.pert).."%")
end

function RefineTakeoffView:RefreshView()

    --重置界面
    self.sour_item:ResetItem()
    self.target_item:ResetItem()

    self.can_click_index = nil
    self.select_index = nil
    self._layout_objs["sour_txt1"]:SetText("")
    self._layout_objs["sour_txt2"]:SetText("")

    self:InitTopUnwearEquips()

    self.top_ui_list:Foreach(function(v)
        v:SetSelect(false)
    end)
end

function RefineTakeoffView:OnDefaultClickTop()
    local equip_item
    self.top_ui_list:Foreach(function(v)
        v:SetSelect(false)
        if v.idx == self.can_click_index then
            equip_item = v
        end
    end)

    if equip_item then
        equip_item:SetSelect(true)
        self:OnSelectEquip(self.can_click_index)
    end
end

function RefineTakeoffView:InitEffect()
    self._layout_objs.effect:SetVisible(true)
    self:CreateUIEffect(self._layout_objs.effect, "effect/ui/zb_clcz.ab")
end

function RefineTakeoffView:PLayEffect()
    self._layout_objs.effect:SetVisible(true)
    self:CreateUIEffect(self._layout_objs["effect2"], "effect/ui/zb_clcj.ab")
end

return RefineTakeoffView
