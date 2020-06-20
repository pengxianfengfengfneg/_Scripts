local GuildCreateItem = Class(game.UITemplate)

function GuildCreateItem:_init(ctrl)
    self.ctrl = ctrl
end

function GuildCreateItem:_delete()

end

function GuildCreateItem:OpenViewCallBack()
    self:Init()
end

function GuildCreateItem:CloseViewCallBack()
    self.click_func = nil
end

function GuildCreateItem:Init()
    self.label_consume = self._layout_objs["label_consume"]
    self.txt_guild_level = self._layout_objs["txt_guild_level"]
    self.txt_vip = self._layout_objs["txt_vip"]
    self.txt_member_nums = self._layout_objs["txt_member_nums"]
    self.txt_price = self._layout_objs["txt_price"]
    self.img_price = self._layout_objs["img_price"]
    self.img_select = self._layout_objs["img_select"]

    self:SetConsumeLabel()
    self:SetPriceSprite(game.MoneyType.Gold)
    self:GetRoot():AddClickCallBack(function()
        if self.click_func then
            self.click_func()
        end
    end)
end

function GuildCreateItem:SetItemInfo(item_info)
    self:SetGuildLevelText(item_info.level)
    self:SetVipText(item_info.vip)
    self:SetMemberNumsText(item_info.level)
    self:SetPriceText(item_info.gold)
end

function GuildCreateItem:SetConsumeLabel()
    self.label_consume:SetText(config.words[2312])
end

function GuildCreateItem:SetGuildLevelText(level)
    self.txt_guild_level:SetText(string.format(config.words[2313], level))
end

function GuildCreateItem:SetVipText(vip)
    self.txt_vip:SetText(string.format(config.words[2314], vip))
end

function GuildCreateItem:SetMemberNumsText(level)
    local max_nums = self.ctrl:GetGuildMaxMemberNum()
    -- local member_nums = self.ctrl:GetGuildLevelConfig(level).mem_num
    self.txt_member_nums:SetText(string.format(config.words[2315], max_nums))
end

function GuildCreateItem:SetPriceText(price)
    self.txt_price:SetText(price)
end

function GuildCreateItem:SetPriceSprite(type)
    local goods_id = game.MoneyGoodsId[type]
    local sprite = config.goods[goods_id].icon
    self.img_price:SetSprite("ui_item", sprite)
end

function GuildCreateItem:SetSelect(val)
    self.img_select:SetVisible(val)
end

function GuildCreateItem:SetClickFunc(click_func)
    self.click_func = click_func
end


return GuildCreateItem