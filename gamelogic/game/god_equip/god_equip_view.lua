local GodEquipView = Class(game.BaseView)

function GodEquipView:_init(ctrl)
    self._package_name = "ui_god_equip"
    self._com_name = "god_equip_view"

    self.ctrl = ctrl
end

function GodEquipView:_delete()
end

function GodEquipView:OpenViewCallBack()
    self:BindEvent(game.RoleEvent.GodEquipWash, function(data)
        if self.cur_select_equip and data.pos == self.cur_select_equip.pos then
            if data.type == 1 then
                self:UpdateAttrType(data.attr)
            else
                self:UpdateAttrValue(data.attr)
            end
        end
        self:UpdateWashItemNum()
    end)

    self:BindEvent(game.RoleEvent.GodEquipUpgrade, function(data)
        if self.cur_select_equip and data.equip.pos == self.cur_select_equip.pos then
            self:SelectEquipUpgrade(data.equip)
        end
    end)

    self._layout_objs.btn_back:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs.btn_close:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs.btn_resonance:AddClickCallBack(function()
        self.ctrl:OpenResonanceView()
    end)

    self._layout_objs.btn_wash_type:AddClickCallBack(function()
        if self.cur_select_equip then
            self.ctrl:SendGodEquipWash(1, self.cur_select_equip.pos)
        end
    end)

    self._layout_objs.btn_wash_attr:AddClickCallBack(function()
        if self.cur_select_equip then
            self.ctrl:SendGodEquipWash(2, self.cur_select_equip.pos)
        end
    end)

    self._layout_objs.btn_upgrade:AddClickCallBack(function()
        local change_attr = self._layout_objs.btn_checkbox:GetSelected()
        if self.cur_select_equip then
            self.ctrl:SendGodEquipUpgrade(self.cur_select_equip.pos, change_attr and 1 or 0)
        end
    end)

    self.equip_list = {}
    self.god_equip_num = 0
    local own_god_equip = 0
    for i = 1, 10 do
        local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(i)
        local equip_item = require("game/bag/item/goods_item").New()
        table.insert(self.equip_list, equip_item)
        equip_item:SetVirtual(self._layout_objs["equip" .. i])
        equip_item:Open()
        if equip_info and #equip_info.god ~= 0 then
            own_god_equip = own_god_equip + 1
            equip_item:SetItemInfo({ id = equip_info.id })
            self.god_equip_num = self.god_equip_num + 1
            equip_item:AddClickEvent(function()
                self._layout_objs.group0:SetVisible(false)
                self._layout_objs.group1:SetVisible(true)
                self._layout_objs.group2:SetVisible(true)
                self:SelectEquipUpgrade(game.FoundryCtrl.instance:GetEquipInfoByType(i))
            end)
        else
            equip_item:ResetItem()
            local image = tostring(i)
            if i == 1 then
                local career = game.RoleCtrl.instance:GetCareer()
                image = image .. "_" .. career
            end
            equip_item:SetItemImage(image)
            equip_item:AddClickEvent(function()
                self._layout_objs.group0:SetVisible(true)
                self._layout_objs.group1:SetVisible(false)
                self._layout_objs.group2:SetVisible(false)
            end)
        end
    end
    self._layout_objs.btn_label2:SetVisible(own_god_equip > 0)

    self.cur_equip_item = require("game/bag/item/goods_item").New()
    table.insert(self.equip_list, self.cur_equip_item)
    self.cur_equip_item:SetVirtual(self._layout_objs["cur_equip"])
    self.cur_equip_item:Open()
    self.cur_equip_item:ResetItem()
    self._layout_objs["cur_equip_name"]:SetText("")

    self.next_equip_item = require("game/bag/item/goods_item").New()
    table.insert(self.equip_list, self.next_equip_item)
    self.next_equip_item:SetVirtual(self._layout_objs["next_equip"])
    self.next_equip_item:Open()
    self.next_equip_item:ResetItem()
    self._layout_objs["next_equip_name"]:SetText("")

    self.wash_equip_item = require("game/bag/item/goods_item").New()
    table.insert(self.equip_list, self.wash_equip_item)
    self.wash_equip_item:SetVirtual(self._layout_objs["wash_equip"])
    self.wash_equip_item:Open()
    self.wash_equip_item:ResetItem()
    self._layout_objs["wash_equip_name"]:SetText("")

    self:UpdateWashItemNum()

    local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(1)
    if equip_info and #equip_info.god ~= 0 then
        self._layout_objs.group0:SetVisible(false)
        self._layout_objs.group1:SetVisible(true)
        self:SelectEquipUpgrade(equip_info)
    else
        self._layout_objs.group0:SetVisible(true)
        self._layout_objs.group1:SetVisible(false)
    end
end

function GodEquipView:CloseViewCallBack()
    for i, v in pairs(self.equip_list) do
        v:DeleteMe()
    end
end

function GodEquipView:SelectEquipUpgrade(info)
    self.cur_select_equip = info
    self.cur_equip_item:SetItemInfo({ id = info.id })
    self._layout_objs["cur_equip_name"]:SetText(config.goods[info.id].name)
    self._layout_objs["wash_equip_name"]:SetText(config.goods[info.id].name)
    local next_equip_config = config.god_equip[info.id]
    local next_id = next_equip_config.upgrade
    if next_id == 0 then
        next_id = info.id
        self._layout_objs["next_equip_name"]:SetText(config.words[1219])
    else
        self._layout_objs["next_equip_name"]:SetText(config.goods[next_id].name)
    end
    self.next_equip_item:SetItemInfo({ id = next_id })
    self.wash_equip_item:SetItemInfo({ id = info.id })

    for i = 1, 2 do
        if next_equip_config.material[i] then
            local own_num = game.BagCtrl.instance:GetNumById(next_equip_config.material[i][1])
            self._layout_objs["cost" .. i]:SetText(own_num .. "/" .. next_equip_config.material[i][2])
        else
            self._layout_objs["cost" .. i]:SetText("0/0")
        end
    end

    local cur_attr = config.goods[info.id].attr
    local next_attr = config.goods[next_id].attr
    local next_senior_attr = config.god_equip[next_id].attr
    local total_percent = 0
    for i = 1, 3 do
        self._layout_objs["cur_attr_item" .. i]:SetVisible(cur_attr[i] ~= nil)
        if cur_attr[i] then
            self._layout_objs["cur_attr" .. i]:SetText(config.combat_power[cur_attr[i][1]].name .. " " .. cur_attr[i][2])
        end
        if next_attr[i] then
            self._layout_objs["next_attr" .. i]:SetText(next_attr[i][2])
        end

        self._layout_objs["senior_attr_item" .. i]:SetVisible(info.god[i] ~= nil)
        self._layout_objs["wash_attr_item" .. i]:SetVisible(info.god[i] ~= nil)
        if info.god[i] then
            self._layout_objs["cur_senior_attr" .. i]:SetText(config.combat_power[info.god[i].type].name .. " " .. math.ceil(info.god[i].val * next_equip_config.attr[info.god[i].type] / 10000))
            self._layout_objs["next_senior_attr" .. i]:SetText(math.ceil(info.god[i].val * next_senior_attr[info.god[i].type] / 10000))

            self._layout_objs["wash_attr_name" .. i]:SetText(config.combat_power[info.god[i].type].name)
            self._layout_objs["wash_attr" .. i]:SetText(math.ceil(info.god[i].val * next_equip_config.attr[info.god[i].type] / 10000))
            self._layout_objs["bar" .. i]:SetProgressValue(info.god[i].val / 100)
            self._layout_objs["attr_plus" .. i]:SetText("")
            total_percent = total_percent + info.god[i].val
        end
    end

    local star_num = 0
    for i, v in ipairs(config.god_equip_star) do
        if total_percent >= v.low and total_percent <= v.high then
            star_num = i
        end
    end
    for i = 1, 9 do
        self._layout_objs["star" .. i]:SetVisible(i <= star_num)
    end
end

function GodEquipView:UpdateAttrType(attr)
    local next_equip_config = config.god_equip[self.cur_select_equip.id]
    local next_id = next_equip_config.upgrade
    if next_id == 0 then
        next_id = info.id
    end
    local next_senior_attr = config.god_equip[next_id].attr
    for i = 1, 3 do
        if attr[i] then
            self._layout_objs["cur_senior_attr" .. i]:SetText(config.combat_power[attr[i].type].name .. " " .. math.ceil(attr[i].val * next_equip_config.attr[attr[i].type] / 10000))
            self._layout_objs["next_senior_attr" .. i]:SetText(math.ceil(attr[i].val * next_senior_attr[attr[i].type] / 10000))

            self._layout_objs["wash_attr_name" .. i]:SetText(config.combat_power[attr[i].type].name)
        end
    end
end


function GodEquipView:UpdateAttrValue(attr)
    local next_equip_config = config.god_equip[self.cur_select_equip.id]
    local total_percent = 0
    for i = 1, 3 do
        if attr[i] then
            self._layout_objs["cur_senior_attr" .. i]:SetText(config.combat_power[attr[i].type].name .. " " .. math.ceil(attr[i].val * next_equip_config.attr[attr[i].type] / 10000))

            local last_val = tonumber(self._layout_objs["wash_attr" .. i]:GetText())
            local now_val = math.ceil(attr[i].val * next_equip_config.attr[attr[i].type] / 10000)
            local add_val = now_val - last_val
            if add_val > 0 then
                self._layout_objs["attr_plus" .. i]:SetText("+" .. add_val)
            else
                self._layout_objs["attr_plus" .. i]:SetText("")
            end
            self._layout_objs["wash_attr" .. i]:SetText(now_val)
            self._layout_objs["bar" .. i]:SetProgressValueTween(attr[i].val / 100, 0.2)
            total_percent = total_percent + attr[i].val
        end
    end

    local star_num = 0
    for i, v in ipairs(config.god_equip_star) do
        if total_percent >= v.low and total_percent <= v.high then
            star_num = i
        end
    end
    for i = 1, 9 do
        self._layout_objs["star" .. i]:SetVisible(i <= star_num)
    end
end

function GodEquipView:UpdateWashItemNum()
    local cost_cfg = config.sys_config.god_equip_refine_material_type.value
    local own_num = game.BagCtrl.instance:GetNumById(cost_cfg[1][1])
    self._layout_objs.type_cost:SetText(own_num .. "/" .. cost_cfg[1][2])
    cost_cfg = config.sys_config.god_equip_refine_material_ratio.value
    own_num = game.BagCtrl.instance:GetNumById(cost_cfg[1][1])
    self._layout_objs.attr_cost:SetText(own_num .. "/" .. cost_cfg[1][2])
end

return GodEquipView
