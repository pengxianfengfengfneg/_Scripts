local LuckyMoneyRankItem = Class(game.UITemplate)

function LuckyMoneyRankItem:_init()
    self.ctrl = game.LuckyMoneyCtrl.instance
end

function LuckyMoneyRankItem:OpenViewCallBack()
    self:Init()
end

function LuckyMoneyRankItem:Init()
    self.img_rank = self._layout_objs.img_rank 
    self.img_money = self._layout_objs.img_money 
    self.img_bg = self._layout_objs.img_bg
    self.img_bg2 = self._layout_objs.img_bg2

    self.txt_name = self._layout_objs.txt_name 
    self.txt_money = self._layout_objs.txt_money 
    self.txt_rank = self._layout_objs.txt_rank

    self.group = self._layout_objs.group

    self.ctrl_rank = self:GetRoot():GetController("ctrl_rank")
end

function LuckyMoneyRankItem:SetItemInfo(item_info, index)
    self.itme_info = item_info

    local group_visible = item_info~=nil
    self.group:SetVisible(group_visible)

    if group_visible then
        self.txt_rank:SetText(item_info.rank)
        self.txt_name:SetText(item_info.name)
        self.txt_money:SetText(item_info.value)

        self.img_money:SetSprite("ui_common", config.money_type[game.MoneyType.BindGold].icon)

        if item_info.rank <= 3 then
            self.img_rank:SetSprite("ui_common", "pm_" .. item_info.rank)
            self.txt_rank:SetVisible(false)
        else
            self.img_rank:SetVisible(false)
        end
    end

    self.img_bg:SetVisible(index%2==1)
    self.img_bg2:SetVisible(index%2==0)
end

return LuckyMoneyRankItem