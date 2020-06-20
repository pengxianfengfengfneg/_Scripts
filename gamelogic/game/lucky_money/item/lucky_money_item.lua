local LuckyMoneyItem = Class(game.UITemplate)

function LuckyMoneyItem:_init()
    self.ctrl = game.LuckyMoneyCtrl.instance
end

function LuckyMoneyItem:OpenViewCallBack()
    self:Init()
end

function LuckyMoneyItem:Init()
    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
    self.txt_name = self._layout_objs.txt_name
    self.txt_desc = self._layout_objs.txt_desc
    self.txt_receive = self._layout_objs.txt_receive

    self:GetRoot():AddClickCallBack(function()
        if self.click_event then
            self.click_event(self.item_info)
        end
    end)
end

function LuckyMoneyItem:SetItemInfo(item_info, index)
    self.item_info = item_info

    self.txt_name:SetText(item_info.name)
    self.txt_desc:SetText(item_info.desc)
    
    local cfg = config.guild_lucky_money[item_info.cid]
    local goods_info = config.goods[cfg.item_id]
    local color = game.ItemColor2[goods_info.color]
    self.txt_desc:SetColor(color[1], color[2], color[3], color[4])
end

function LuckyMoneyItem:AddClickEvent(click_event)
    self.click_event = click_event
end 

function LuckyMoneyItem:SetEnable(val)
    self.ctrl_page:SetSelectedIndexEx(val and 0 or 1)
end

function LuckyMoneyItem:SetReceiveState(state)
    state = state or 1
    local str = ""
    if state == 1 then
        str = config.words[5950]
    elseif state == 2 then
        str = config.words[5956]
    elseif state == 3 then
        str = config.words[5951]
    end
    self.txt_receive:SetText(str)
end

return LuckyMoneyItem