local FireworkCtrl = Class(game.BaseCtrl)

local _et = {}
local global_Time = global.Time
local config_firework = config.firework

function FireworkCtrl:_init()
    if FireworkCtrl.instance ~= nil then
        error("FireworkCtrl Init Twice!")
    end
    FireworkCtrl.instance = self

    self.data = require("game/firework/firework_data").New(self)

    self.firework_tips_view = require("game/firework/firework_tips_view").New(self)

    self:RegisterAllEvents()
    self:RegisterAllProtocals()
end

function FireworkCtrl:_delete()
    self.data:DeleteMe()

    self.firework_tips_view:DeleteMe()

    FireworkCtrl.instance = nil
end

function FireworkCtrl:RegisterAllEvents()
    local events = {
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function FireworkCtrl:RegisterAllProtocals()
    self:RegisterProtocalCallback(54302, "OnFireworkInfo")
    self:RegisterProtocalCallback(54304, "OnFireworkNotify")
    self:RegisterProtocalCallback(54305, "OnFireworkUse")
end

function FireworkCtrl:OpenTipsView(item_id)
    self.firework_tips_view:Open(item_id)
end

function FireworkCtrl:SendFireworkInfo()
    local proto = {

    }
    self:SendProtocal(54301, proto)
end

function FireworkCtrl:OnFireworkInfo(data)
    --[[
        "hero__I",
        "charm__I",
    ]]
    --PrintTable(data)

    self.data:OnFireworkInfo(data)
end

function FireworkCtrl:SendFireworkUse(item_id, target_id)
    --[[
        "item_id__I",
        "target_id__L",
    ]]
    local proto = {
        item_id = item_id,
        target_id = target_id,
    }
    self:SendProtocal(54303, proto)
end

function FireworkCtrl:OnFireworkUse(data)
    --[[
        "target_id__L",
        "res__I",
    ]]
    --PrintTable(data)
    if data.res == 0 then
        -- 使用成功
    else
        -- 使用失败
        game.GameMsgCtrl.instance:PushMsg(config.ret_code[data.res])
    end

    if data.target_id > 0 then
        -- 对目标使用的烟花
        self:FireEvent(game.FireworkEvent.OnFireworkUse, data.target_id, data.res==0)
    end
end

function FireworkCtrl:OnFireworkNotify(data)
    --[[
        "item_id__I",
    ]]
    --PrintTable(data)

    self:ShowFireworkUIEffect(data.item_id)
end

function FireworkCtrl:ShowFireworkUIEffect(item_id)
    local cfg = config_firework[item_id]
    if not cfg then
        return
    end

    if cfg.ui_effect_time <= 0 then
        return
    end

    self:FireEvent(game.FireworkEvent.ShowFireworkUIEffect, cfg.ui_effect_id, cfg.ui_effect_time)
end

game.FireworkCtrl = FireworkCtrl

return FireworkCtrl
