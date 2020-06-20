local LuckyMoneyCom = Class(game.UITemplate)

local config_guild_lucky_money = config.guild_lucky_money

local LuckyMoneyType = {
    Guild = 1,
}

local PageIndex = {
    Open = 0,
    Grab = 1,
    Pity = 2,
}

function LuckyMoneyCom:_init(view)
    self.parent_view = view

    self.ctrl = game.LuckyMoneyCtrl.instance
end

function LuckyMoneyCom:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
end

function LuckyMoneyCom:CloseViewCallBack()
    self:StopExpireCounter()
end

function LuckyMoneyCom:RegisterAllEvents()
    local events = {
        {game.GuildEvent.OnGuildMoneyChange, handler(self, self.OnGuildMoneyChange)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function LuckyMoneyCom:Init()
    self.head_icon = self:GetIconTemplate("head_icon")
    self.img_money = self._layout_objs.img_money

    self.txt_name = self._layout_objs.txt_name
    self.txt_receive = self._layout_objs.txt_receive
    self.txt_time = self._layout_objs.txt_time
    self.txt_money = self._layout_objs.txt_money

    self.group_bottom = self._layout_objs.group_bottom

    self.btn_open = self._layout_objs.btn_open
    self.btn_open:AddClickCallBack(function()
        if self.info then
            self.ctrl:SendGuildMoneyGet(self.info.id)
        end
    end)

    self.txt_detail = self._layout_objs.txt_detail
    self.txt_detail:AddClickCallBack(function()
        if self.info then
            self.ctrl:OpenLuckyMoneyRankView(self.info)
        end
    end)

    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
    self:SetPageIndex(PageIndex.Open)
    self:SetDetailVisible(true)
end

function LuckyMoneyCom:SetIcon(info)
    self.head_icon:UpdateData(info)
end

function LuckyMoneyCom:SetNameText(name)
    self.txt_name:SetText(name)
end

function LuckyMoneyCom:SetReceiveText(cur_times, total_times)
    self.txt_receive:SetText(string.format(config.words[5952], cur_times, total_times))
end

function LuckyMoneyCom:SetExpireTime(time)
    self:StartExpireCounter(time)
end

function LuckyMoneyCom:SetMoney(type, money)
    self.img_money:SetSprite("ui_common", config.money_type[type].icon)
    self.txt_money:SetText(string.format(config.words[5955], money))
end

function LuckyMoneyCom:StartExpireCounter(expire_time)
    self:StopExpireCounter()
    self.tw_expire = DOTween:Sequence()
    self.tw_expire:AppendCallback(function()
        local time = math.max(0, expire_time - global.Time:GetServerTime())
        if time >= 0 then
            self.txt_time:SetText(string.format(config.words[5953], game.Utils.SecToTime2(time)))
        else
            self:StopExpireCounter()
        end
    end)
    self.tw_expire:AppendInterval(1)
    self.tw_expire:SetLoops(-1)
end

function LuckyMoneyCom:StopExpireCounter()
    if self.tw_expire then
        self.tw_expire:Kill(false)
        self.tw_expire = nil
    end

    if self.lucky_money_type == LuckyMoneyType.Guild then
        self:RefreshMoneyState(self.info)
    end
end

function LuckyMoneyCom:RefreshGuildLuckyMoney(info)
    self.info = info
    self.lucky_money_type = LuckyMoneyType.Guild

    local cfg = config_guild_lucky_money[info.cid]
    local goods_info = config.goods[cfg.item_id]
    local color = game.ItemColor[goods_info.color]

    self:SetIcon(info)
    self:SetNameText(string.format(config.words[5954], info.sender, color, cfg.name))
    self:SetReceiveText(#info.list, cfg.times)
    self:SetExpireTime(info.expire_time)
    self:RefreshMoneyState(info)
end

function LuckyMoneyCom:OnGuildMoneyChange(info)
    if info.id == self.info.id then
        self:RefreshGuildLuckyMoney(info)
    end
end

function LuckyMoneyCom:GetMyRankInfo(info)
    local role_id = game.RoleCtrl.instance:GetRoleId()
    for k, v in ipairs(info.list or game.EmptyTable) do
        if v.role_id == role_id then
            return v
        end
    end
end

function LuckyMoneyCom:RefreshMoneyState(info)
    local rank_info = self:GetMyRankInfo(info)
    if rank_info then
        self:SetMoney(game.MoneyType.BindGold, rank_info.value)
        self:SetPageIndex(PageIndex.Grab)
    else
        if #info.list == config_guild_lucky_money[info.cid].times then
            self:SetPageIndex(PageIndex.Pity)
        else
            self:SetPageIndex(PageIndex.Open)
        end
    end
end

function LuckyMoneyCom:SetPageIndex(index)
    self.ctrl_page:SetSelectedIndexEx(index)
end

function LuckyMoneyCom:SetDetailVisible(val)
    self.txt_detail:SetVisible(val)
    if val then
        self.group_bottom:SetPosition(42, 740)
    else
        self.group_bottom:SetPosition(42, 780)
    end
end

return LuckyMoneyCom
