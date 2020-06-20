local FashionItem = Class(game.UITemplate)

function FashionItem:_init()
    self.ctrl = game.FashionCtrl.instance
end

function FashionItem:OpenViewCallBack()
end

function FashionItem:CloseViewCallBack()
end

function FashionItem:SetItemInfo(data)
    self.item_data = data
    self.img_used = self._layout_objs["img_ycd"]
    self.txt_name = self._layout_objs["txt_name"]

    self.fashion_id = self.item_data.id or 0
    self.item_id = self.item_data.item_id or 0
    self.fashion_name = self.item_data.name or ""
    self.get_way = self.item_data.way or ""
    self.func_id = self.item_data.func_id or 0
    self.fashion_cost = self.item_data.cost or {}
    self.fashion_attr = self.item_data.attr or {}

    self.txt_name:SetText(self.fashion_name)
    local career = game.RoleCtrl.instance:GetCareer()
    local info = {
        id = config.fashion_color[self.fashion_id][career][1].item_id,
    }
    local goods_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")
    goods_item:SetItemInfo(info)

    self:DoUpdate()
end

function FashionItem:OnClick()

end

function FashionItem:GetName()
    return self.fashion_name
end

function FashionItem:GetWay()
    return self.get_way
end

function FashionItem:GetId()
    return self.fashion_id
end

function FashionItem:GetItemId()
    return self.item_id
end

function FashionItem:GetFuncId()
    return self.func_id
end

function FashionItem:GetCost()
    return self.fashion_cost
end

function FashionItem:GetAttr()
    return self.fashion_attr
end

function FashionItem:DoUpdate()
    local is_weared = self.ctrl:IsFashionWeared(self:GetId())
    self.img_used:SetVisible(is_weared)

    local fashion_info = self.ctrl:GetFashionInfo(self:GetId())
    if fashion_info and fashion_info.time >= 0 then
        local cur_num, max_num = self.ctrl:GetFashionColorActivedNum(self:GetId())
        local str_actived = string.format(config.words[2003], cur_num, max_num)
        local color = game.Color.DarkGreen
        if max_num <= 1 then
            color = game.Color.Red
            str_actived = config.words[2004]
        end
        self._layout_objs.color:SetText(str_actived)
        self._layout_objs.color:SetColor(table.unpack(color))
        if fashion_info.time == 0 then
            self._layout_objs.txt_expire:SetText(config.words[2007])
        elseif fashion_info.time - global.Time:GetServerTime() > 0 then
            local str = game.Utils.SecToTimeCn(fashion_info.time - global.Time:GetServerTime(), game.TimeFormatCn.DayHour)
            self._layout_objs.txt_expire:SetText(str)
        else
            self._layout_objs.txt_expire:SetText(config.words[2008])
        end
    else
        self._layout_objs.color:SetText(string.format(config.words[2002], self.get_way))
        self._layout_objs.txt_expire:SetText(config.words[2009])
    end
end

function FashionItem:SetSelect(id)
    self._layout_objs.select:SetVisible(self.fashion_id == id)
end

function FashionItem:SetTips(val)
    game.Utils.SetTip(self:GetRoot(), val, {x = 136, y = 10})
end

return FashionItem
