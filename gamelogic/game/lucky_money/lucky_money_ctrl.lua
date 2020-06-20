local LuckyMoneyCtrl = Class(game.BaseCtrl)

function LuckyMoneyCtrl:_init()
	if LuckyMoneyCtrl.instance ~= nil then
		error("LuckyMoneyCtrl Init Twice!")
	end
	LuckyMoneyCtrl.instance = self
	
    self.view = require("game/lucky_money/lucky_money_view").New(self)
    self.open_view = require("game/lucky_money/lucky_money_open_view").New(self)
    self.rank_view = require("game/lucky_money/lucky_money_rank_view").New(self)
    self.data = require("game/lucky_money/lucky_money_data").New(self)

    self:RegisterAllProtocal()
    self:RegisterAllEvents()
end

function LuckyMoneyCtrl:_delete()
    self.view:DeleteMe()
    self.open_view:DeleteMe()
    self.rank_view:DeleteMe()
    self.data:DeleteMe()
    
	LuckyMoneyCtrl.instance = nil
end

function LuckyMoneyCtrl:RegisterAllProtocal()
	local proto = {
        [53515] = "OnGuildMoneyChange",
        [53517] = "OnGuildMoneyRemove",
    }
    for id, func_name in pairs(proto) do
        self:RegisterProtocalCallback(id, func_name)
    end
end

function LuckyMoneyCtrl:RegisterAllEvents()
    local events = {
        {game.SceneEvent.CommonlyValueRespon, handler(self, self.OnCommonlyKeyValue)},
        {game.LoginEvent.LoginRoleRet, handler(self, self.OnLoginRoleRet)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function LuckyMoneyCtrl:OnCommonlyKeyValue(data)
    if data.key == game.CommonlyKey.DailyGetLuckyMoneyTimes then
        local times = config.guild_lucky_money_info.max_times - data.value
        self.data:SetDailyLuckyMoneyTimes(times)
        if times <= 0 then
            self:FireEvent(game.GuildEvent.UpdateGuildLuckyMoneyReceiveNum, 0)
        end
    end
end

function LuckyMoneyCtrl:OnLoginRoleRet(val)
    if val then
        game.MainUICtrl.instance:SendGetCommonlyKeyValue(game.CommonlyKey.DailyGetLuckyMoneyTimes)
    end
end

function LuckyMoneyCtrl:PrintTable(tbl)
    if self.log_enable then
        PrintTable(tbl)
    end
end

function LuckyMoneyCtrl:print(...)
    if self.log_enable then
        print(...)
    end
end

function LuckyMoneyCtrl:OpenView()
    self.view:Open()
end

function LuckyMoneyCtrl:OpenLuckyMoneyOpenView(info)
    self.open_view:Open(info)
end

function LuckyMoneyCtrl:OpenLuckyMoneyRankView(info)
    self.rank_view:Open(info)
end

function LuckyMoneyCtrl:IsOpenView()
    return self.view:IsOpen()
end

function LuckyMoneyCtrl:SendGuildMoneyGet(id)
    --[[
        "id__I",                                   -- 红包ID
    ]]
    self:SendProtocal(53516, {id = id})
    self:print('SendGuildMoneyGet[53516]', string.format('id = %s', id))
end

function LuckyMoneyCtrl:OnGuildMoneyChange(data)
    --[[
        "lucky_money__T__info@U|CltLuckyMoney|",   
        "type__C",                                 -- 推送类型:1:发红包|2:抢红包
    ]]
    self:PrintTable(data)
    game.GuildCtrl.instance:OnGuildMoneyChange(data)
end

-- 移除红包
function LuckyMoneyCtrl:OnGuildMoneyRemove(data)
    --[[
        "remove_list__T__id@I",                    -- 红包唯一ID
    ]]
    self:PrintTable(data)
    game.GuildCtrl.instance:OnGuildMoneyRemove(data)
end

function LuckyMoneyCtrl:GetDailyLuckyMoneyTimes()
    return self.data:GetDailyLuckyMoneyTimes()
end

game.LuckyMoneyCtrl = LuckyMoneyCtrl

return LuckyMoneyCtrl