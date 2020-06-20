local FieldBattleCtrl = Class(game.BaseCtrl)

local handler = handler

function FieldBattleCtrl:_init()
    if FieldBattleCtrl.instance ~= nil then
        error("FieldBattleCtrl Init Twice!")
    end
    FieldBattleCtrl.instance = self

    self.data = require("game/field_battle/field_battle_data").New(self)

    self.drum_view = require("game/field_battle/field_battle_drum_view").New(self)
    self.fight_info_view = require("game/field_battle/field_battle_fight_info_view").New(self)
    self.join_tips_view = require("game/field_battle/field_battle_join_tips_view").New(self)
    self.pk_info_view = require("game/field_battle/field_battle_pk_info_view").New(self)
    self.prepare_view = require("game/field_battle/field_battle_prepare_view").New(self)
    self.side_info_view = require("game/field_battle/field_battle_side_info_view").New(self)
    self.tips_view = require("game/field_battle/field_battle_tips_view").New(self)

    self:RegisterAllEvents() 
    self:RegisterAllProtocals()
end

function FieldBattleCtrl:_delete()
    self.data:DeleteMe()

    self.drum_view:DeleteMe()
    self.fight_info_view:DeleteMe()
    self.join_tips_view:DeleteMe()
    self.pk_info_view:DeleteMe()
    self.prepare_view:DeleteMe()
    self.side_info_view:DeleteMe()
    self.tips_view:DeleteMe()

    FieldBattleCtrl.instance = nil
end

function FieldBattleCtrl:RegisterAllEvents()
    local events = {

    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function FieldBattleCtrl:RegisterAllProtocals()
    self:RegisterProtocalCallback(31102, "OnTerritoryInfo")

    self:RegisterProtocalCallback(31112, "OnTerritoryEnter")
    self:RegisterProtocalCallback(31114, "OnTerritoryLeave")
    self:RegisterProtocalCallback(31116, "OnTerritorySwitch")
    self:RegisterProtocalCallback(31118, "OnTerritoryBeatDrum")
    self:RegisterProtocalCallback(31120, "OnTerritoryRank")
    self:RegisterProtocalCallback(31122, "OnTerritoryProgress")
    self:RegisterProtocalCallback(31131, "OnTerritoryScenePrepare")
    self:RegisterProtocalCallback(31132, "OnTerritorySceneBattle")
    self:RegisterProtocalCallback(31133, "OnTerritoryNotifySelect")
    self:RegisterProtocalCallback(31134, "OnTerritoryNotifyFlag")
    self:RegisterProtocalCallback(31135, "OnTerritoryNotifyDrum")
end

function FieldBattleCtrl:SendTerritoryInfo()
    local proto = {

    }
    self:SendProtocal(31101, proto)
end

function FieldBattleCtrl:OnTerritoryInfo(data)
    --[[
        "round__C",
        "matches__T__red_id@C##red_name@s##blue_id@C##blue_name@s",
        "territories__T__id@C##guild@L##name@s",
    ]]
    -- PrintTable(data)

    self.data:OnTerritoryInfo(data)

    self:FireEvent(game.FieldBattleEvent.OnTerritoryInfo, data)
end

function FieldBattleCtrl:SendTerritoryEnter()
    local proto = {

    }
    self:SendProtocal(31111, proto)
end

function FieldBattleCtrl:OnTerritoryEnter(data)
    
    self.data:OnTerritoryEnter(data) 
end

function FieldBattleCtrl:SendTerritoryLeave()
    local proto = {

    }
    self:SendProtocal(31113, proto)
end

function FieldBattleCtrl:OnTerritoryLeave(data)
   
   self.data:OnTerritoryLeave(data) 
end

function FieldBattleCtrl:SendTerritorySwitch(room)
    local proto = {
        room = room
    }
    self:SendProtocal(31115, proto)
end

function FieldBattleCtrl:OnTerritorySwitch(data)
    --[[
        "room__C",
    ]]
    -- PrintTable(data)

    self.data:OnTerritorySwitch(data)
end

function FieldBattleCtrl:SendTerritoryBeatDrum(id)
    local proto = {
        id = id
    }
    self:SendProtocal(31117, proto)
end

function FieldBattleCtrl:OnTerritoryBeatDrum(data)
    --[[
        "id__C",
    ]]
    -- PrintTable(data)
    
    self.data:OnTerritoryBeatDrum(data)

    self:FireEvent(game.FieldBattleEvent.OnTerritoryBeatDrum, data.id)
end

function FieldBattleCtrl:SendTerritoryRank()
    local proto = {
        
    }
    self:SendProtocal(31119, proto)
end

function FieldBattleCtrl:OnTerritoryRank(data)
    --[[
         "ranks__T__rank@C##id@L##name@s##kill@H##score@L",
    ]]
    -- PrintTable(data)
    
    self.data:OnTerritoryRank(data)

    self:FireEvent(game.FieldBattleEvent.OnTerritoryRank, data)
end

function FieldBattleCtrl:SendTerritoryProgress()
    local proto = {
        
    }
    self:SendProtocal(31121, proto)
end

function FieldBattleCtrl:OnTerritoryProgress(data)
    --[[
        "rooms__T__room@C##fin@C##red@C##blue@C##win@C",
    ]]
    -- PrintTable(data)
    
    self.data:OnTerritoryProgress(data)

    self:FireEvent(game.FieldBattleEvent.OnTerritoryProgress, data)
end

function FieldBattleCtrl:OnTerritoryScenePrepare(data)
    --[[
        "select__C",
        "selection__T__room@C##num@C",
    ]]
    -- PrintTable(data)
    
    self.data:OnTerritoryScenePrepare(data)

    self:FireEvent(game.FieldBattleEvent.OnTerritoryScenePrepare, data)
end

function FieldBattleCtrl:OnTerritorySceneBattle(data)
    --[[
        "flag__C",
        "occupy__I",
        "camps__T__camp@C##guild@L##name@s",
        "drums__T__id@C",
    ]]
    -- PrintTable(data)
    
    self.data:OnTerritorySceneBattle(data)

    self:FireEvent(game.FieldBattleEvent.OnTerritorySceneBattle, data)
end

function FieldBattleCtrl:OnTerritoryNotifySelect(data)
    --[[
        "selection__T__room@C##num@C",
    ]]
    -- PrintTable(data)
    
    self.data:OnTerritoryNotifySelect(data)

    self:FireEvent(game.FieldBattleEvent.OnTerritoryNotifySelect, data)
end

function FieldBattleCtrl:OnTerritoryNotifyFlag(data)
    --[[
        "flag__C",
        "occupy__I",
    ]]
    -- PrintTable(data)
    
    self.data:OnTerritoryNotifyFlag(data)

    self:FireEvent(game.FieldBattleEvent.OnTerritoryNotifyFlag, data)
end

function FieldBattleCtrl:OnTerritoryNotifyDrum(data)
    --[[
        "camp__C",
        "drums__T__id@C",
    ]]
    -- PrintTable(data)
    
    self.data:OnTerritoryNotifyDrum(data)

    self:FireEvent(game.FieldBattleEvent.OnTerritoryNotifyDrum, data)
end





function FieldBattleCtrl:OpenDrumView()
    self.drum_view:Open()
end

function FieldBattleCtrl:OpenFightInfoView()
    self.fight_info_view:Open()
end

function FieldBattleCtrl:CloseFightInfoView()
    self.fight_info_view:Close()
end

function FieldBattleCtrl:OpenJoinTipsView(act_id)
    self.join_tips_view:Open(act_id)
    return self.join_tips_view
end

function FieldBattleCtrl:OpenPkInfoView()
    self.pk_info_view:Open()
end

function FieldBattleCtrl:ClosePkInfoView()
    self.pk_info_view:Close()
end

function FieldBattleCtrl:OpenPrepareView()
    self.prepare_view:Open()
end

function FieldBattleCtrl:ClosePrepareView()
    self.prepare_view:Close()
end

function FieldBattleCtrl:OpenSideInfoView()
    self.side_info_view:Open()
end

function FieldBattleCtrl:CloseSideInfoView()
    self.side_info_view:Close()
end

function FieldBattleCtrl:OpenTipsView(str_content, ok_callback, cancel_callback)
    self.tips_view:Open(str_content, ok_callback, cancel_callback)
end



function FieldBattleCtrl:GetTerritoryData()
    return self.data:GetTerritoryData()
end

function FieldBattleCtrl:GetTerritoryMatches()
    return self.data:GetTerritoryMatches()
end

function FieldBattleCtrl:GetTerritoryRound()
    return self.data:GetTerritoryRound()
end


function FieldBattleCtrl:GetTerritoryInfo()
    return self.data:GetTerritoryInfo()
end

function FieldBattleCtrl:GetTerritoryInfoForId(field_id)
    return self.data:GetTerritoryInfoForId(field_id)
end

function FieldBattleCtrl:GetTerritoryInfoForGuild(guild_id)
    return self.data:GetTerritoryInfoForGuild(guild_id)
end

function FieldBattleCtrl:GetPrepareFieldId()
    return self.data:GetPrepareFieldId()
end

function FieldBattleCtrl:GetPrepareSelectionInfo()
    return self.data:GetPrepareSelectionInfo()
end

function FieldBattleCtrl:GetDrumState(drum_id)
    return self.data:GetDrumState(drum_id)
end

function FieldBattleCtrl:GetBattleInfo()
    return self.data:GetBattleInfo()
end

function FieldBattleCtrl:GetPrepareRoomNum(room)
    return self.data:GetPrepareRoomNum(room)
end

function FieldBattleCtrl:IsDrumUsed(id)
    return self.data:IsDrumUsed(id)
end

function FieldBattleCtrl:IsGuildJoin(guild_id)
    local guild_id = guild_id or game.GuildCtrl.instance:GetGuildId()
    local territories = self:GetTerritoryInfo()

    for _,v in ipairs(territories or {}) do
        if guild_id == v.guild then
            return true
        end
    end
    return false
end

function FieldBattleCtrl:GetGuildAgainstInfo(guild_id)
    local guild_id = guild_id or game.GuildCtrl.instance:GetGuildId()
    local info = self:GetTerritoryInfoForGuild(guild_id)

    local matches = self:GetTerritoryMatches()

    local against_info = {}
    for _,v in ipairs(matches) do
        if v.blue_id == info.id or v.red_id == info.id then
            against_info.blue_id = v.blue_id
            against_info.red_id = v.red_id

            against_info.blue_name = self:GetTerritoryInfoForId(v.blue_id).name
            against_info.red_name = self:GetTerritoryInfoForId(v.red_id).name
            break
        end
    end
    return against_info
end

game.FieldBattleCtrl = FieldBattleCtrl

return FieldBattleCtrl
