local GuildTaskCtrl = Class(game.BaseCtrl)

function GuildTaskCtrl:_init()
    if GuildTaskCtrl.instance ~= nil then
        error("GuildTaskCtrl Init Twice!")
    end
    GuildTaskCtrl.instance = self

    self.view = require("game/guild_task/guild_task_view").New(self)
    self.roraty_view = require("game/guild_task/guild_task_roraty_view").New(self)
    self:RegisterAllProtocal()
end

function GuildTaskCtrl:_delete()
    self.view:DeleteMe()
    self.roraty_view:DeleteMe()

    GuildTaskCtrl.instance = nil
end

function GuildTaskCtrl:RegisterAllProtocal()
    local proto = {
        [51411] = "OnGuildTaskRotary",
        [51413] = "OnGuildTaskRotaryChoose",
        [51415] = "OnGuildTaskRotaryGet",
    }
    for id, func in pairs(proto) do
        self:RegisterProtocalCallback(id, func)
    end
end

function GuildTaskCtrl:PrintTable(data)
    if self.log_enable then
        PrintTable(data)
    end
end

function GuildTaskCtrl:print(...)
    if self.log_enable then
        print(...)
    end
end

function GuildTaskCtrl:OpenView()
    self.view:Open()
end

function GuildTaskCtrl:OpenRoratyView(...)
    self.roraty_view:Open(...)
end

function GuildTaskCtrl:CloseView()
    self.view:Close()
end

-- 触发转盘
function GuildTaskCtrl:OnGuildTaskRotary(data)
    --[[ 
        "end_time__I",
        "list__T__id@C",
    ]]
    self:PrintTable(data)
    self:OpenRoratyView(data.end_time, data.list)
end

-- 抽取转盘奖励
function GuildTaskCtrl:SendGuildTaskRotaryChoose()
    self:SendProtocal(51412)
end

function GuildTaskCtrl:OnGuildTaskRotaryChoose(data)
    --[[ 
        "choose_id__C",
    ]]
    self:PrintTable(data)
    if self.roraty_view:IsOpen() then
        self.roraty_view:Play(data.choose_id)
    end
end

-- 领取转盘奖励
function GuildTaskCtrl:SendGuildTaskRotaryGet()
    self:SendProtocal(51414)
end

function GuildTaskCtrl:OnGuildTaskRotaryGet(data)
    --[[ 
        "end_time__I",
    ]]
    self:PrintTable(data)
    if self.roraty_view:IsOpen() then
        self.roraty_view:StartCloseCounter()
    end
end

game.GuildTaskCtrl = GuildTaskCtrl

return GuildTaskCtrl