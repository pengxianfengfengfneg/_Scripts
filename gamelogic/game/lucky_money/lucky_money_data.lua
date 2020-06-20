
local LuckyMoneyData = Class(game.BaseData)

function LuckyMoneyData:SetDailyLuckyMoneyTimes(times)
    self.daily_lucky_money_times = times
end

function LuckyMoneyData:GetDailyLuckyMoneyTimes()
    return self.daily_lucky_money_times or 0
end

return LuckyMoneyData