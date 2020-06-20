local GuildDefendRankItem = Class(game.UITemplate)

local _number_format = game.Utils.NumberFormat

function GuildDefendRankItem:_init(ctrl)
    self.ctrl = ctrl
end

function GuildDefendRankItem:_delete()

end

function GuildDefendRankItem:OpenViewCallBack()
    self:Init()
end

function GuildDefendRankItem:CloseViewCallBack()

end

function GuildDefendRankItem:Init()
    self.txt_rank = self._layout_objs["txt_rank"]
    self.txt_name = self._layout_objs["txt_name"]
    self.txt_career = self._layout_objs["txt_career"]
    self.txt_hurt = self._layout_objs["txt_hurt"]
    self.txt_recover = self._layout_objs["txt_recover"]
    self.txt_score = self._layout_objs["txt_score"]
    
    self.img_rank = self._layout_objs["img_rank"]

    self.ctrl_state = self:GetRoot():GetController("ctrl_state")
    self:GetRoot():AddClickCallBack(handler(self, self.OnClick))
end

function GuildDefendRankItem:SetItemInfo(item_info)
    self.txt_rank:SetText(item_info.rank)
    self.txt_name:SetText(item_info.name)
    self.txt_career:SetText(config.career_init[item_info.career].name)
    self.txt_hurt:SetText(_number_format(item_info.hurt))
    self.txt_recover:SetText(_number_format(item_info.recover))
    self.txt_score:SetText(_number_format(item_info.score))

    local index = item_info.rank > 3 and 0 or 1
    self.ctrl_state:SetSelectedIndexEx(index)
    if index == 1 then
        self.img_rank:SetSprite("ui_common", "sl_".. 12 + item_info.rank)
    end
end

function GuildDefendRankItem:OnClick()
    if self.click_func then
        self.click_func()
    end
end

function GuildDefendRankItem:SetClickFunc(func)
    self.click_func = func
end

return GuildDefendRankItem