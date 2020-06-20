local DragonDesignEatView = Class(game.BaseView)

function DragonDesignEatView:_init(ctrl)
    self._package_name = "ui_dragon_design"
    self._com_name = "dragon_design_eat_view"
    self._view_level = game.UIViewLevel.Third
    self.ctrl = ctrl

    self.dragon_design_data = self.ctrl:GetData()
end

function DragonDesignEatView:_delete()
end

function DragonDesignEatView:OpenViewCallBack(item_info, in_bag_flag)

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[6130])

    self.sour_item_info = item_info

    self.in_bag_flag = in_bag_flag
    
    self:InitSourItem()

    self:InitList()

    self:UpdateList()

    self:SetExpBar()

    self._layout_objs["eat_btn"]:AddClickCallBack(function()
        self:OnEat()
    end)

    self._layout_objs["one_key_btn"]:AddClickCallBack(function()
        self:OneKey()
    end)

    self._layout_objs["set_btn"]:AddClickCallBack(function()
        self.ctrl:OpenDragonEatSetView()
    end)

    self:BindEvent(game.DragonDesignEvent.UpdateSetColor, function(data)
        self:UpdateList()
    end)

    self:BindEvent(game.DragonDesignEvent.UpdateEat, function(data)
        if data.type == 2 then
            self.sour_item_info.level = data.level
            self.sour_item_info.exp = data.exp
        end
        self.select_items = {}
        self:InitSourItem()
        self:UpdateList()
        self:SetExpBar()
    end)
end

function DragonDesignEatView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function DragonDesignEatView:InitList()

    self.item_list = {}
    self.select_items = {}

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
            if self.select_items[idx] then
                self.select_items[idx] = false
                item:SetSelect(false)
            else
                self.select_items[idx] = true
                item:SetSelect(true)
            end

            self:SetExpBar()
        end)
    end)

    self.ui_list:SetItemNum(#self.item_list)
end

function DragonDesignEatView:UpdateList()
    local color = self.ctrl:GetEatColor()

    if self.in_bag_flag then
        local filter_pos = self.sour_item_info.pos
        self.item_list = self.dragon_design_data:GetCanEquipList(color, filter_pos)
    else
        self.item_list = self.dragon_design_data:GetCanEquipList(color)
    end

    self.ui_list:SetItemNum(#self.item_list)

    self.ui_list:Foreach(function(v)
        v:SetSelect(false)
        v:SetTouchEnable(true)
    end)
end

function DragonDesignEatView:SetExpBar()

    local cur_exp = 0

    for k,v in pairs(self.select_items) do

        if v then
            local idx = k
            local item_info = self.item_list[idx]
            cur_exp = cur_exp + item_info.goods.exp * item_info.goods.num

            local cfg_exp = config.dragon_item[item_info.goods.id].eat_exp * item_info.goods.num
            cur_exp = cur_exp + cfg_exp


            local lv_exp = 0
            local lv = item_info.goods.level - 1
            local color = config.goods[item_info.goods.id].color

            for i = 1, lv do
                lv_exp = lv_exp + config.dragon_level[color][i].exp
            end
            cur_exp = cur_exp + lv_exp
        end
    end

    local item_id = self.sour_item_info.id
    local level = self.sour_item_info.level
    local color = config.goods[item_id].color
    local need_exp = config.dragon_level[color][level].exp

    if cur_exp > 0 then
        self._layout_objs["select_exp"]:SetText("+"..tostring(cur_exp))
    else
        self._layout_objs["select_exp"]:SetText("")
    end

    self._layout_objs["bar"]:SetProgressValue((self.sour_item_info.exp+cur_exp)/need_exp*100)

    self._layout_objs["bar"]:GetChild("title"):SetText(tostring(self.sour_item_info.exp).."/"..need_exp)
end

function DragonDesignEatView:OneKey()
    if self.all_select then
        self.all_select = false
        self.ui_list:Foreach(function(v)
            v:SetSelect(false)
            self.select_items[v.idx] = false
        end)
        self._layout_objs["one_key_btn"]:SetText(config.words[6131])
    else
        self.all_select = true
        self.ui_list:Foreach(function(v)
            v:SetSelect(true)
            self.select_items[v.idx] = true
        end)
        self._layout_objs["one_key_btn"]:SetText(config.words[6132])
    end

    self:SetExpBar()
end

function DragonDesignEatView:OnEat()
    local type_t = 1
    if self.in_bag_flag then
        type_t = 2
    end

    local item_id = self.sour_item_info.id
    local sour_color = config.goods[item_id].color
    local show_msg_box = false

    local pos_t = self.sour_item_info.pos
    local bag_pos_t = {}

    for k,v in pairs(self.select_items) do
        if v then
            local idx = k
            local item_info = self.item_list[idx]
            local t = {}
            t.pos = item_info.goods.pos
            table.insert(bag_pos_t, t)

            local color = config.goods[item_info.goods.id].color
            if color > sour_color then
                show_msg_box = true
            end
        end
    end

    if show_msg_box then
        local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[6156])
        msg_box:SetOkBtn(function()
            self.ctrl:CsDragonEat(type_t, pos_t, bag_pos_t)
            msg_box:DeleteMe()
        end)
        msg_box:SetCancelBtn(function()
        end)
        msg_box:Open()
    else
        self.ctrl:CsDragonEat(type_t, pos_t, bag_pos_t)
    end
end

function DragonDesignEatView:InitSourItem()

    local equip_type_t = 0
    local item_id = self.sour_item_info.id
    local level = self.sour_item_info.level
    local pos = self.sour_item_info.pos
    local goods_cfg = config.goods[item_id]

    local item = self:GetTemplate("game/bag/item/goods_item", "item")
    item:SetItemInfo({id = item_id})
    item:SetShowTipsEnable(true)

    self._layout_objs["name"]:SetText(goods_cfg.name)

    self._layout_objs["lv"]:SetText(string.format(config.words[6260], tostring(level)))

    local desc = ""
    local skill_id = config.dragon_item[item_id].skill
    if skill_id > 0 then
        desc = config.skill[skill_id][1].desc
    end
    self._layout_objs["desc"]:SetText(string.format(config.words[6129], desc))

    local attr = config.dragon_attr[item_id][level].attr
    if attr[1] then
        local attr_type = attr[1][1]
        local attr_val = attr[1][2]
        local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)
        local str = attr_name.."+"..attr_val
        self._layout_objs["desc2"]:SetText(string.format(config.words[6129], str))
    else
        self._layout_objs["desc2"]:SetText(string.format(config.words[6129], config.words[6140]))
    end

    self.all_select = false
    self._layout_objs["one_key_btn"]:SetText(config.words[6131])
end

return DragonDesignEatView