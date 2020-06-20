local DragonDesignPreView = Class(game.BaseView)

function DragonDesignPreView:_init(ctrl)
    self._package_name = "ui_dragon_design"
    self._com_name = "dragon_design_preview"
    self._view_level = game.UIViewLevel.Third
    self.ctrl = ctrl
    self.dragon_design_data = self.ctrl:GetData()
end

function DragonDesignPreView:_delete()
end

function DragonDesignPreView:OpenViewCallBack()

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[6142])

    self.goods_item_list = {}
    for i = 1, 4 do
        local item = self:GetTemplate("game/bag/item/goods_item", "item"..i)
        item:SetShowTipsEnable(true)
        item:AddClickEvent(function()
            self:OnSelectBotItem(i)
        end)
        self.goods_item_list[i] = item
    end

    self:InitList()
end

function DragonDesignPreView:CloseViewCallBack()
    for k, v in pairs(self.goods_item_list) do
        v:DeleteMe()
    end

    self.goods_item_list = nil

    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function DragonDesignPreView:InitList()

    local dragon_show_cfg = config.dragon_show

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
        local item_id = dragon_show_cfg[idx].relate[1]
        item.idx = idx
        item:SetItemInfo({ id = item_id})
        item:SetItemLevel(string.format(config.words[6266], 50))
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
    end)

    self.ui_list:SetItemNum(#dragon_show_cfg)

    --默认选中第一个
    self.ui_list:Foreach(function(v)
        if v.idx ~= 1 then
            v:SetSelect(false)
        else
            v:SetSelect(true)
        end
    end)

    self:OnSelectItem(1)
end

function DragonDesignPreView:OnSelectItem(idx)

    self.select_index = idx

    local bot_item_list = config.dragon_show[idx].relate

    for index, item_id in ipairs(bot_item_list) do
        self.goods_item_list[index]:SetItemInfo({id = item_id})
        self.goods_item_list[index]:SetItemLevel(string.format(config.words[6266], 50))
    end

    self:OnSelectBotItem(1)
end

function DragonDesignPreView:OnSelectBotItem(index)

    for i = 1, 4 do
        self.goods_item_list[i]:SetSelect(i==index)
    end

    local item_id = config.dragon_show[self.select_index].relate[index]
    local tips_str = config.dragon_show[self.select_index].desc
    local goods_cfg = config.goods[item_id]

    self._layout_objs["name"]:SetText(goods_cfg.name)

    --50级效果
    local desc = ""
    local skill_id = config.dragon_item[item_id].skill
    if skill_id > 0 then
        desc = config.skill[skill_id][1].desc
    end
    self._layout_objs["main_txt"]:SetText(string.format(config.words[6138], desc))

    local attr = config.dragon_attr[item_id][50].attr
    local attr_type = attr[1][1]
    local attr_val = attr[1][2]
    local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)
    local str = attr_name.."+"..attr_val
    self._layout_objs["sub_txt"]:SetText(string.format(config.words[6139], str))

    self._layout_objs["tips_txt"]:SetText(tips_str)
end

return DragonDesignPreView