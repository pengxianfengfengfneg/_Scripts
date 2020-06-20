local BattleWarItem = Class(game.UITemplate)

function BattleWarItem:_init()
    self.ctrl = game.GuildCtrl.instance
end

function BattleWarItem:OpenViewCallBack()
    self:Init()
end

function BattleWarItem:CloseViewCallBack()
    self:StopTimeCounter()
end

function BattleWarItem:Init()
    self.txt_state = self._layout_objs.txt_state
    self.txt_index = self._layout_objs.txt_index
    self.txt_name = self._layout_objs.txt_name
    self.txt_time = self._layout_objs.txt_time
    self.txt_exploit = self._layout_objs.txt_exploit

    self.img_bg = self._layout_objs.img_bg
    self.img_bg2 = self._layout_objs.img_bg2
end

function BattleWarItem:SetItemInfo(item_info, idx)
    self.item_info = item_info

    self.txt_state:SetText(self.ctrl:IsDeclareWar(item_info.num) and config.words[4785] or config.words[4786])
    self.txt_index:SetText(item_info.num)
    self.txt_name:SetText(item_info.guild_name)
    self.txt_exploit:SetText(item_info.exploit)

    self:StartTimeCounter(item_info.time)

    self.img_bg:SetVisible(idx % 2 == 1)
    self.img_bg2:SetVisible(idx % 2 == 0)
end

function BattleWarItem:StartTimeCounter(end_time)
    self:StopTimeCounter()
    self.tw_time = DOTween:Sequence()
    self.tw_time:AppendCallback(function()
        local time = math.max(0, end_time - global.Time:GetServerTime())
        self.txt_time:SetText(game.Utils.SecToTimeEn(time, game.TimeFormatEn.HourMinSec))
        if time == 0 then
            self:StopTimeCounter()
        end
    end)
    self.tw_time:AppendInterval(1)
    self.tw_time:SetLoops(-1)
    self.tw_time:Play()
end

function BattleWarItem:StopTimeCounter()
    if self.tw_time then
        self.tw_time:Kill(false)
        self.tw_time = nil
    end
end

return BattleWarItem