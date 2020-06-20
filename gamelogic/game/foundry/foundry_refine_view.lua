local FoundryRefineView = Class(game.BaseView)

function FoundryRefineView:_init(ctrl)
    self._package_name = "ui_foundry"
    self._com_name = "foundry_refine_view"

    self.ctrl = ctrl
end

function FoundryRefineView:_delete()
end

function FoundryRefineView:OpenViewCallBack(template_index)

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[5213])
    self:InitItems()

    self.tab_controller = self:GetRoot():AddControllerCallback("btn_tab", function(idx)
        self.tab_index = idx+1

        self:OnClickTab(idx+1)
        self:OnDefaultClickTop()
    end)
    self.tab_index = template_index or 1
    self.tab_controller:SetSelectedIndexEx((template_index and template_index -1) or 0)
    self:OnClickTab(self.tab_index)
    self:OnDefaultClickTop()

    --镶嵌
    self._layout_objs["inlay_btn"]:AddClickCallBack(function()

        if self.select_index then
            local pos = self.equip_pos_list[self.select_index]
            self.ctrl:CsEquipInlayParis(pos)
        end
    end)

    --强化
    self._layout_objs["stren_btn"]:AddClickCallBack(function()
        if self.select_index then
            local pos = self.equip_pos_list[self.select_index]
            self.ctrl:CsEquipInlayParis(pos)
        end
    end)

    --拆卸
    self._layout_objs["unwear_btn"]:AddClickCallBack(function()
        if self.select_index then
            local pos = self.equip_pos_list[self.select_index]
            self.ctrl:CsEquipStripParis(pos)
        end
    end)

    self:BindEvent(game.FoundryEvent.UpdateInlayStren, function(data)

        if self.tab_index then

            local old_select = self.select_index

            self:OnClickTab(self.tab_index)

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
        end
    end)

    self:BindEvent(game.FoundryEvent.UpdateStrip, function(data)
        self:OnClickTab(3)
    end)
end

function FoundryRefineView:CloseViewCallBack()
    if self.top_ui_list then
        self.top_ui_list:DeleteMe()
        self.top_ui_list = nil
    end
end

function FoundryRefineView:InitItems()

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

function FoundryRefineView:InitTopInlayEquips()

    if self.top_ui_list then
        self.top_ui_list:DeleteMe()
        self.top_ui_list = nil
    end

    local equip_pos_list = {}
    local count = 0
    for pos, v in pairs(config.equip_paris) do
        local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(pos)
        if (not equip_info) or (equip_info and equip_info.paris == 0) then
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
            local star = config.equip_attr[equip_info.id].star
            --7到9星 普通装备 可以镶嵌
            if equip_info.paris == 0 and 7 <= star and star <= 9 then
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

function FoundryRefineView:InitTopStrenEquips()

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

function FoundryRefineView:InitTopUnwearEquips()

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

function FoundryRefineView:OnSelectEquip(index)
    self.select_index = index

    if self.tab_index == 1 then
        self:ShowInInlay()
    elseif self.tab_index == 2 then
        self:ShowInStren()
    elseif self.tab_index == 3 then
        self:ShowInUnwear()
    end
end

function FoundryRefineView:ShowInInlay()

    local pos = self.equip_pos_list[self.select_index]
    local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(pos)

    self.sour_item:SetItemInfo({ id = equip_info.id })
    local cur_paris = equip_info.paris
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

        self.target_item:SetItemInfo({ id = equip_info.id })
        self.target_item:SetShowTipsEnable(true)

        self._layout_objs["sour_txt1"]:SetText("")
        self._layout_objs["sour_txt2"]:SetText("")


        local skill_id = next_cfg.skill[1]
        local skill_lv = next_cfg.skill[2]
        local skill_desc = config.skill[skill_id][skill_lv].desc
        self._layout_objs["target_txt1"]:SetText(skill_desc)
        self._layout_objs["target_txt2"]:SetText(string.format(config.words[5214], next_cfg.pert).."%")
    else

    end
end

function FoundryRefineView:ShowInStren()

    local pos = self.equip_pos_list[self.select_index]
    local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(pos)
    self.sour_item:SetItemInfo({ id = equip_info.id })

    local cur_paris = equip_info.paris
    local cur_cfg = config.equip_paris[pos][cur_paris]

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

        self.target_item:SetItemInfo({ id = equip_info.id })
        self.target_item:SetShowTipsEnable(true)

        local skill_id1 = cur_cfg.skill[1]
        local skill_lv1 = cur_cfg.skill[2]
        local skill_desc1 = config.skill[skill_id1][skill_lv1].desc
        self._layout_objs["sour_txt1"]:SetText(skill_desc1)
        self._layout_objs["sour_txt2"]:SetText(string.format(config.words[5214], cur_cfg.pert).."%")

        local skill_id = next_cfg.skill[1]
        local skill_lv = next_cfg.skill[2]
        local skill_desc = config.skill[skill_id][skill_lv].desc
        self._layout_objs["target_txt1"]:SetText(skill_desc)
        self._layout_objs["target_txt2"]:SetText(string.format(config.words[5214], next_cfg.pert).."%")
    else

    end
end

function FoundryRefineView:ShowInUnwear()

    local pos = self.equip_pos_list[self.select_index]
    local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(pos)
    self.sour_item:SetItemInfo({ id = equip_info.id })

    local cur_paris = equip_info.paris
    local cur_cfg = config.equip_paris[pos][cur_paris]

    local next_paris = cur_paris+1
    local next_cfg = config.equip_paris[pos][next_paris]

    self.need_item:SetItemInfo({ id = cur_cfg.cost[1], num = cur_cfg.cost[2] })
    self.need_item:SetShowTipsEnable(true)
    self.need_item:SetColor(224, 214, 189)


    self.target_item:SetItemInfo({ id = equip_info.id })
    self.target_item:SetShowTipsEnable(true)

    local skill_id1 = cur_cfg.skill[1]
    local skill_lv1 = cur_cfg.skill[2]
    local skill_desc1 = config.skill[skill_id1][skill_lv1].desc
    self._layout_objs["sour_txt1"]:SetText(skill_desc1)
    self._layout_objs["sour_txt2"]:SetText(string.format(config.words[5214], cur_cfg.pert).."%")

    if next_cfg then
        local skill_id = next_cfg.skill[1]
        local skill_lv = next_cfg.skill[2]
        local skill_desc = config.skill[skill_id][skill_lv].desc
        self._layout_objs["target_txt1"]:SetText(skill_desc)
        self._layout_objs["target_txt2"]:SetText(string.format(config.words[5214], next_cfg.pert).."%")
    end
end

function FoundryRefineView:OnClickTab(tab_index)

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

    if tab_index == 1 then
        self._layout_objs["opet_txt"]:SetText(config.words[5215])
        self:InitTopInlayEquips()
    elseif tab_index == 2 then
        self._layout_objs["opet_txt"]:SetText(config.words[5216])
        self:InitTopStrenEquips()
    elseif tab_index == 3 then
        self._layout_objs["opet_txt"]:SetText(config.words[5217])
        self:InitTopUnwearEquips()
    end

    self.top_ui_list:Foreach(function(v)
        v:SetSelect(false)
    end)
end

function FoundryRefineView:OnDefaultClickTop()
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

return FoundryRefineView
