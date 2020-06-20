local GuildBlessItem = Class(game.UITemplate)

function GuildBlessItem:_init()
    self.ctrl = game.GuildCtrl.instance
end

function GuildBlessItem:OpenViewCallBack()
    self:Init()
end

function GuildBlessItem:CloseViewCallBack()
    self:StopTimeCounter()
end

function GuildBlessItem:Init()
    self.img_icon = self._layout_objs.img_icon
    self.txt_name = self._layout_objs.txt_name
    self.txt_desc = self._layout_objs.txt_desc
end

function GuildBlessItem:SetItemInfo(item_info)
    self.item_info = item_info
    self.txt_name:SetText(item_info.name)
    local expire_time = self.ctrl:GetBlessExpireTime(item_info.id)
    self:StartTimeCounter(expire_time)
end

function GuildBlessItem:StartTimeCounter(end_time)
    self:StopTimeCounter()
    local start_time = game.Utils.NowDaytimeStart(end_time)
    self.tw_time = DOTween:Sequence()
    self.tw_time:AppendCallback(function()
        local now_time = global.Time:GetServerTime()
        local delta_time = math.max(0, end_time - now_time)
        if now_time < start_time then
            self.txt_desc:SetText(config.words[4793])
        elseif delta_time > 0 then
            self.txt_desc:SetText(string.format(config.words[4792], game.Utils.SecToTime2(delta_time)))
        else
            self:StopTimeCounter()
            self.txt_desc:SetText(config.words[4791])
        end
    end)
    self.tw_time:AppendInterval(1)
    self.tw_time:SetLoops(-1)
end

function GuildBlessItem:StopTimeCounter()
    if self.tw_time then
        self.tw_time:Kill(false)
        self.tw_time = nil
    end
end

return GuildBlessItem