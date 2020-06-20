local RefineInlayView = Class(game.BaseView)

function RefineInlayView:_init(ctrl)
    self._package_name = "ui_equip_refine"
    self._com_name = "refine_inlay_view"

    self._show_money = true

    self.ctrl = ctrl
end

function RefineInlayView:_delete()
end

function RefineInlayView:OpenViewCallBack()

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[5213])

    self:InitItems()

    self:InitTopInlayEquips()

    self:OnDefaultClickTop()

    --镶嵌
    self._layout_objs["inlay_btn"]:AddClickCallBack(function()

        if self.select_index then
            local pos = self.equip_pos_list[self.select_index]
            self.ctrl:CsEquipInlayParis(pos)
        end
    end)


    self:BindEvent(game.FoundryEvent.UpdateInlayStren, function(data)
            local old_select = self.select_index

            self:OnClickTab()

            if old_select and data.equip.paris > 1 then

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
end

function RefineInlayView:OnClickTab()

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

    self:InitTopInlayEquips()

    self.top_ui_list:Foreach(function(v)
        v:SetSelect(false)
    end)
end

function RefineInlayView:OnDefaultClickTop()
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

function RefineInlayView:CloseViewCallBack()
    self:DeleteItems()

    if self.top_ui_list then
        self.top_ui_list:DeleteMe()
        self.top_ui_list = nil
    end
end

function RefineInlayView:InitItems()

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

function RefineInlayView:DeleteItems()
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

function RefineInlayView:InitTopInlayEquips()

    if self.top_ui_list then
        self.top_ui_list:DeleteMe()
        self.top_ui_list = nil
    end

    local equip_pos_list = {}
    local count = 0
    for pos, v in pairs(config.equip_paris) do
        local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(pos)
        if (equip_info and equip_info.id > 0 and equip_info.paris == 0) then

            local item_id = equip_info.id
            local goods_cfg = config.goods[item_id]

            --是重楼打造装备
            if goods_cfg.type == 10 and goods_cfg.subtype == 2 then
                count = count + 1
                table.insert(equip_pos_list, pos)
            end
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
            local star = config.equip_attr[equip_info.id].star
            local goods_cfg = config.goods[equip_info.id]
            --7到9星 普通装备 可以镶嵌
            if equip_info.paris == 0 and 7 <= star and star <= 9 and goods_cfg.subtype == 2 then
                equip_item:AddClickEvent(function ()
                    self.top_ui_list:Foreach(function(v)
                        v:SetSelect(false)
                    end)
                    equip_item:SetSelect(true)
                    self:OnSelectEquip(idx)
                end)
            end
        else
            equip_item:ResetItem()
            local image = tostring(pos)
            equip_item:SetItemImage(image)
            equip_item:SetTouchEnable(true)
            equip_item:AddClickEvent(function ()
                game.GameMsgCtrl.instance:PushMsg(config.words[1273])
            end)
        end

        if self.select_index and idx == self.select_index then
            equip_item:SetSelect(true)
        else
            equip_item:SetSelect(false)
        end
    end)

    self.top_ui_list:SetItemNum(count)
end

function RefineInlayView:OnSelectEquip(index)

	self.select_index = index

	self:ShowInInlay()
end

function RefineInlayView:ShowInInlay()

    local pos = self.equip_pos_list[self.select_index]
    local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(pos)

    self.sour_item:SetItemInfo({ id = equip_info.id })
    self.sour_item:AddClickEvent(function()
        game.BagCtrl.instance:OpenWearEquipInfoView(equip_info, true)
    end)

    local cur_paris = equip_info.paris
    local cur_cfg = config.equip_paris[pos][cur_paris]

    if cur_cfg then
        local skill_id1 = cur_cfg.skill[1]
        local skill_lv1 = cur_cfg.skill[2]
        local skill_desc1 = config.skill[skill_id1][skill_lv1].desc
        self._layout_objs["sour_txt1"]:SetText(skill_desc1)
        self._layout_objs["sour_txt2"]:SetText(string.format(config.words[5214], cur_cfg.pert).."%")
    else
         self._layout_objs["sour_txt1"]:SetText("")
        self._layout_objs["sour_txt2"]:SetText("")
    end


    local next_paris = cur_paris+1
    local next_cfg = config.equip_paris[pos][next_paris]

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

        self.target_item:SetItemInfo({ id = equip_info.id, icon_name = next_cfg.icon})
        self.target_item:SetShowTipsEnable(true)
        self.target_item:AddClickEvent(function()
            game.BagCtrl.instance:OpenWearEquipInfoCompareView(equip_info, true, {paris = 1})
        end)

        local skill_id = next_cfg.skill[1]
        local skill_lv = next_cfg.skill[2]
        local skill_desc = config.skill[skill_id][skill_lv].desc
        self._layout_objs["target_txt1"]:SetText(skill_desc)
        self._layout_objs["target_txt2"]:SetText(string.format(config.words[5214], next_cfg.pert).."%")
    else
        self.target_item:ResetItem()
        self._layout_objs["target_txt1"]:SetText("")
        self._layout_objs["target_txt2"]:SetText("")
    end
end

return RefineInlayView
