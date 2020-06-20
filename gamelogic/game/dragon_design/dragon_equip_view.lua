local DragonEquipView = Class(game.BaseView)

function DragonEquipView:_init(ctrl)
    self._package_name = "ui_dragon_design"
    self._com_name = "dragon_equip_view"
    self._view_level = game.UIViewLevel.Third
    self.ctrl = ctrl

    self.dragon_design_data = self.ctrl:GetData()
end

function DragonEquipView:_delete()
end

function DragonEquipView:OpenViewCallBack(equip_info)

    self.equip_type = equip_info.equip_type or 0   --镶嵌龙元位置 0是主龙元  1是辅龙元位置
    self.equip_pos = equip_info.equip_pos          --镶嵌龙元位置 1-16

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[6127])

    self:InitList()

    self.tab_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
        if idx > 0 then
            self:UpdateList(6 - idx)
        else
            self:UpdateList(0)
        end
    end)

    self.tab_controller:SetSelectedIndexEx(0)
    self:UpdateList(0)

    self._layout_objs["n8"]:AddClickCallBack(function()
        if self.select_pos then
            self.ctrl:CsDragonEquip(self.equip_pos, self.select_pos)
            self:Close()
        else
            game.GameMsgCtrl.instance:PushMsg(config.words[6128])
        end
    end)
end

function DragonEquipView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end

    self.select_pos = nil
end

function DragonEquipView:InitList()

    self.item_list = {}

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
        local item_info = self.item_list[idx]
        item.idx = idx
        item:SetItemInfo({ id = item_info.goods.id, num = item_info.goods.num, bind = item_info.goods.bind})
        item:SetItemLevel(string.format(config.words[6266], item_info.goods.level))
        item:AddClickEvent(function()

            self.ui_list:Foreach(function(v)
                if v.idx ~= item.idx then
                    v:SetSelect(false)
                else
                    v:SetSelect(true)
                end
            end)

            self:OnSelectItem(idx)
        end)
        item:SetLongClickFunc(function()
            item:ShowTips()
        end)
    end)

    self.ui_list:SetItemNum(#self.item_list)
end

function DragonEquipView:UpdateList(color)
    self.item_list = self.dragon_design_data:GetCanEquipListByFixColor(color)
    self.ui_list:SetItemNum(#self.item_list)

    self.ui_list:Foreach(function(v)
        v:SetSelect(false)
        v:SetTouchEnable(true)
    end)

    if #self.item_list > 0 then
        self.ui_list:Foreach(function(v)
            if v.idx ~= 1 then
                v:SetSelect(false)
            else
                v:SetSelect(true)
            end
        end)

        self:OnSelectItem(1)
    end
end

function DragonEquipView:OnSelectItem(idx)

    local item_info = self.item_list[idx]
    local item_id = item_info.goods.id
    local level = item_info.goods.level
    local goods_cfg = config.goods[item_id]

    self.select_pos = item_info.goods.pos

    self._layout_objs["n11"]:SetText(goods_cfg.name)
    self._layout_objs["lv"]:SetText(tostring(level))

    if self.equip_type == 0 then
        local desc = ""
        local skill_id = config.dragon_item[item_id].skill
        if skill_id > 0 then
            desc = config.skill[skill_id][1].desc
        end

        self._layout_objs["desc"]:SetText(desc)
    else

        local attr = config.dragon_attr[item_id][level].attr
        if attr[1] then
            local attr_type = attr[1][1]
            local attr_val = attr[1][2]
            local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)
            self._layout_objs["desc"]:SetText(attr_name.."+"..attr_val)
        else
            self._layout_objs["desc"]:SetText("")
        end
    end
end

return DragonEquipView