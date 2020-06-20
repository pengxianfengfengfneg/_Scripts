local WorldBossCtrl = Class(game.BaseCtrl)

function WorldBossCtrl:_init()
    if WorldBossCtrl.instance ~= nil then
        error("WorldBossCtrl Init Twice!")
    end
    WorldBossCtrl.instance = self

    self.view = require("game/world_boss/world_boss_view").New(self)
    self.data = require("game/world_boss/world_boss_data").New(self)

    self.side_info_view = require("game/world_boss/world_boss_side_info_view").New(self)
    self.hurt_rank_view = require("game/world_boss/world_boss_hurt_rank_view").New(self)
    self.shield_view = require("game/world_boss/world_boss_shield_view").New(self)

    self:RegisterAllEvents()
    self:RegisterAllProtocal()
end

function WorldBossCtrl:_delete()
    self.view:DeleteMe()
    self.data:DeleteMe()

    self.side_info_view:DeleteMe()
    self.hurt_rank_view:DeleteMe()
    self.shield_view:DeleteMe()

    WorldBossCtrl.instance = nil
end

function WorldBossCtrl:RegisterAllEvents()
    local events = {
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function WorldBossCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(30905, "OnGetWorldBossRoleRankResp")
    self:RegisterProtocalCallback(30907, "OnGetWorldBossGuildRankResp")
    self:RegisterProtocalCallback(30908, "OnNotifyWbGuildRanks")
    self:RegisterProtocalCallback(30910, "OnGetWorldBossSeqResp")

    self:RegisterProtocalCallback(53302, "OnRollDiceResp")
    self:RegisterProtocalCallback(53303, "OnNotifyNewDice")
    self:RegisterProtocalCallback(53304, "OnNotifyRoleDice")

end

function WorldBossCtrl:OpenView()
    self.view:Open()
end

function WorldBossCtrl:OpenSideInfoView()
    self.side_info_view:Open()
end

function WorldBossCtrl:CloseSideInfoView()
    self.side_info_view:Close()
end

function WorldBossCtrl:OpenHurtRankView(boss_id, hp_lmt, rank_list)
    self.hurt_rank_view:Open(boss_id, hp_lmt, rank_list)
end

function WorldBossCtrl:CloseHurtRankView()
    self.hurt_rank_view:Close()
end

function WorldBossCtrl:OpenShieldView(data)
    self.shield_view:Open(data)
end

function WorldBossCtrl:CloseShieldView()
    self.shield_view:Close()
end

function WorldBossCtrl:SendExitWorldBossFieldReq()
    local proto = {

    }
    self:SendProtocal(30902, proto)
end

function WorldBossCtrl:SendEnterWorldBossFieldReq(field_id, layer, line_id)
    local proto = {
        layer = layer,
        field_id = field_id,
        line_id = line_id,
    }
    self:SendProtocal(30903, proto)
end

function WorldBossCtrl:SendGetWorldBossRoleRankReq()
    local proto = {

    }
    self:SendProtocal(30904, proto)
end

function WorldBossCtrl:OnGetWorldBossRoleRankResp(data)
    PrintTable(data)
end

function WorldBossCtrl:SendGetWorldBossGuildRankReq()
    local proto = {

    }
    self:SendProtocal(30906, proto)
end

function WorldBossCtrl:OnGetWorldBossGuildRankResp(data)
    PrintTable(data)
end

function WorldBossCtrl:OnNotifyWbGuildRanks(data)
    --[[
        "boss_rank_list__T__boss_rank@U|WbGuildRank|",
    ]]
    PrintTable(data)

    self:FireEvent(game.WorldBossEvent.UpdateHurtRank, data.boss_rank_list)
end

function WorldBossCtrl:SendGetWorldBossSeqReq()
    local proto = {

    }
    self:SendProtocal(30909, proto)

    print("SendGetWorldBossSeqReq() XXXXXX")
end

function WorldBossCtrl:OnGetWorldBossSeqResp(data)
    --[[
        "boss_ids__T__boss_id@I",
    ]]
    --PrintTable(data)

    self:FireEvent(game.WorldBossEvent.OnGetWorldBossSeq, data.boss_ids)
end

function WorldBossCtrl:SendRollDiceReq(id)
    local proto = {
        id = id,
    }
    self:SendProtocal(53301, proto)
end

function WorldBossCtrl:OnRollDiceResp(data)
    --[[
        "id__I",
        "val__C",
    ]]
    PrintTable(data)

    self:FireEvent(game.WorldBossEvent.RolldiceCallback, data)
end

function WorldBossCtrl:OnNotifyNewDice(data)
     --[[
        "id__I",
        "reward__I",
        "expire_time__I",
    ]]
    PrintTable(data)

    self:OpenShieldView(data)
end

function WorldBossCtrl:OnNotifyRoleDice(data)
     --[[
        "id__I",
        "self__U|CltDiceVal|",
        "best__U|CltDiceVal|",
    ]]
    PrintTable(data)

    self:FireEvent(game.WorldBossEvent.UpdateRolldice, data)
end

game.WorldBossCtrl = WorldBossCtrl

return WorldBossCtrl