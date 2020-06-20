local RefineUpgradeView = Class(game.BaseView)

function RefineUpgradeView:_init(ctrl)
    self._package_name = "ui_equip_refine"
    self._com_name = "refine_upgrade_view"

    self._show_money = true

    self.ctrl = ctrl
end

function RefineUpgradeView:_delete()
end

function RefineUpgradeView:OpenViewCallBack()

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[5213])

    self:InitItems()

    self:InitUpgradeEquips()

    self:OnDefaultClickTop()

    self:BindEvent(game.FoundryEvent.UpdateInlayStren, function(data)
        local old_select = self.select_index

        self:RefreshView()

        if old_select then

            local equip_item
            self.top_ui_list:Foreach(function(v)
                v:SetSelect(false)
                if v.idx == old_select then
                    equip_item = v
                end
            end)

            if equip_item then
                equip_item:SetSelect(true)

                self:OnSelectEquip(old_select)
            end
        else
            self:OnDefaultClickTop()
        end
    end)

    --强化
    self._layout_objs["upgrade_btn"]:AddClickCallBack(function()
        if self.select_index then
            local pos = self.equip_pos_list[self.select_index]
            self.ctrl:CsEquipInlayParis(pos)
        end
    end)
end

function RefineUpgradeView:CloseViewCallBack()
	self:DeleteItems()

    if self.top_ui_list then
        self.top_ui_list:DeleteMe()
        self.top_ui_list = nil
    end
end

function RefineUpgradeView:InitItems()

    self.sour_item = require("game/bag/item/goods_item").New()
    self.sour_item:SetVirtual(self._layout_objs["sour_item"])
    self.sour_item:Open()
    self.sour_item:SetTouchEnable(true)
    self.sour_item:ResetItem()

    self.target_item = require("game/bag/item/goods_item").New()
    self.target_item:SetVirtual(self._layout_objs["target_item"])
    self.target_item:Open()
    self.target_item:SetTouchEnable(true)
    self.target_item:ResetItem()

    self.need_item = require("game/bag/item/goods_item").New()
    self.need_item:SetVirtual(self._layout_objs["need_item"])
    self.need_item:Open()
    self.need_item:SetTouchEnable(true)
    self.need_item:ResetItem()
end

function RefineUpgradeView:DeleteItems()
    if self.sour_item then
        self.sour_item:DeleteMe()
        self.sour_item = nil
    end

    if self.target_item then
        self.target_item:DeleteMe()
        self.target_item = nil
    end

    if self.need_item then
        self.need_item:DeleteMe()
        self.need_item = nil
    end
end

function RefineUpgradeView:InitUpgradeEquips()

    if self.top_ui_list then
        self.top_ui_list:DeleteMe()
        self.top_ui_list = nil
    end

    local equip_pos_list = {}
    local count = 0
    local pos = 3

    local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(pos)

    if equip_info and  equip_info.id > 0 then

    	local item_id = equip_info.id
    	local goods_cfg = config.goods[item_id]

    	--是重楼肩部位
    	if goods_cfg.type == 10 and goods_cfg.subtype == 4 then
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

            equip_item:SetItemInfo({ id = equip_info.id })
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

function RefineUpgradeView:OnDefaultClickTop()
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

function RefineUpgradeView:OnSelectEquip(index)

	self.select_index = index

	self:ShowUpgrade()
end

function RefineUpgradeView:ShowUpgrade()

    local pos = self.equip_pos_list[self.select_index]
    local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(pos)

    self.sour_item:SetItemInfo({ id = equip_info.id })
    self.sour_item:AddClickEvent(function()
        game.BagCtrl.instance:OpenWearEquipInfoView(equip_info, true)
    end)

    local cur_id = equip_info.id
    local next_id = cur_id+1
    local cur_cfg = config.paris_shoulder[cur_id]
    local next_cfg = config.paris_shoulder[next_id]

    local skill_id1 = cur_cfg.skill[1]
    local skill_lv1 = cur_cfg.skill[2]
    local skill_desc1 = config.skill[skill_id1][skill_lv1].desc
    self._layout_objs["sour_txt1"]:SetText(skill_desc1)

    --有下一等级
    if next_cfg then

        self.need_item:SetItemInfo({ id = next_cfg.cost[1], num = next_cfg.cost[2] })

        local cur_num = game.BagCtrl.instance:GetNumById(next_cfg.cost[1])
        self.need_item:SetNumText(cur_num.."/"..next_cfg.cost[2])
        self.need_item:SetShowTipsEnable(true)
        if cur_num >= next_cfg.cost[2] then
            self.need_item:SetColor(224, 214, 189)
        else
            self.need_item:SetColor(255, 0, 0)
        end

        self.target_item:SetItemInfo({ id = next_id})
        self.target_item:SetShowTipsEnable(true)
        self.target_item:AddClickEvent(function()
            --paris加1 物品id也会变
            game.BagCtrl.instance:OpenWearEquipInfoCompareView(equip_info, true, {paris = equip_info.paris + 1, item_id = next_id})
        end)

        local skill_id = next_cfg.skill[1]
        local skill_lv = next_cfg.skill[2]
        local skill_desc = config.skill[skill_id][skill_lv].desc
        self._layout_objs["target_txt1"]:SetText(skill_desc)
    else
    	self.target_item:ResetItem()
    	self._layout_objs["target_txt1"]:SetText("")
    end
end


function RefineUpgradeView:RefreshView()

    --重置界面
    self.sour_item:ResetItem()
    self.target_item:ResetItem()
    self.need_item:ResetItem()

    self.can_click_index = nil
    self.select_index = nil
    self._layout_objs["sour_txt1"]:SetText("")
    self._layout_objs["sour_txt2"]:SetText("")
    self._layout_objs["target_txt1"]:SetText("")
    self._layout_objs["target_txt2"]:SetText("")

    self:InitUpgradeEquips()

    self.top_ui_list:Foreach(function(v)
        v:SetSelect(false)
    end)
end
return RefineUpgradeView
