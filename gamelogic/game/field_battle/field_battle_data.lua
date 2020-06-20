local FieldBattleData = Class(game.BaseData)

function FieldBattleData:_init()
    self.territory_data = {}
    self.prepare_info = {}
    self.drum_info = {}
    self.battle_info = {}
end

function FieldBattleData:_delete()

end

function FieldBattleData:OnTerritoryInfo(data)
    self.territory_data = data
end


function FieldBattleData:OnTerritoryEnter(data)
    
end

function FieldBattleData:OnTerritoryLeave(data)
    
end

function FieldBattleData:OnTerritorySwitch(data)
    --[[
        "room__C",
    ]]    

    self.prepare_info.select = data.room
end

function FieldBattleData:OnTerritoryBeatDrum(data)
    --[[
        "id__C",
    ]]    
    
    table.insert(self.battle_info.drums, data)
end

function FieldBattleData:OnTerritoryRank(data)
    --[[
        "ranks__T__rank@C##name@s##kill@H##score@L",
    ]]    
    
end

function FieldBattleData:OnTerritoryProgress(data)
    --[[
        "rooms__T__room@C##red@C##blue@C##win@C",
    ]]    
    self.progress_data = data
end

function FieldBattleData:OnTerritoryScenePrepare(data)
    --[[
        "select__C",
        "selection__T__room@C##num@C",
    ]]    
    self.prepare_info = data
end

function FieldBattleData:OnTerritorySceneBattle(data)
    --[[
        "flag__C",
        "occupy__I",
        "camps__T__camp@C##guild@L##name@s",
        "drums__T__id@C",
    ]]    
    
    self.battle_info = data
end

function FieldBattleData:OnTerritoryNotifySelect(data)
    --[[
        "selection__T__room@C##num@C",
    ]]    
    
    self.prepare_info.selection = data.selection
end

function FieldBattleData:OnTerritoryNotifyFlag(data)
    --[[
        "flag__C",
        "occupy__I",
    ]]    
    self.battle_info.flag = data.flag
    self.battle_info.occupy = data.occupy
end

function FieldBattleData:OnTerritoryNotifyDrum(data)
    --[[
        "camp__C",
        "drums__T__id@C",
    ]]    
    self.drum_info = data

    self.battle_info.drums = data.drums
end

function FieldBattleData:GetTerritoryData()
    return self.territory_data
end

function FieldBattleData:GetTerritoryInfo()
    return self.territory_data.territories or game.EmptyTable
end

function FieldBattleData:GetTerritoryMatches()
    return self.territory_data.matches or game.EmptyTable
end

function FieldBattleData:GetTerritoryRound()
    return self.territory_data.round
end

function FieldBattleData:GetTerritoryInfoForId(field_id)
    for _,v in ipairs(self:GetTerritoryInfo()) do
        if v.id == field_id then
            return v
        end
    end
end

function FieldBattleData:GetTerritoryInfoForGuild(guild_id)
    for _,v in ipairs(self:GetTerritoryInfo()) do
        if v.guild == guild_id then
            return v
        end
    end
end

function FieldBattleData:GetPrepareFieldId()
    return self.prepare_info.select
end

function FieldBattleData:GetPrepareSelectionInfo()
    return self.prepare_info.selection
end

function FieldBattleData:GetProgressData()
    return self.progress_data
end

function FieldBattleData:GetDrumState(drum_id)
    return 0
end

function FieldBattleData:GetBattleInfo()
    return self.battle_info
end

function FieldBattleData:GetPrepareRoomNum(room)
    for _,v in ipairs(self:GetPrepareSelectionInfo() or {}) do
        if v.room == room then
            return v.num
        end
    end
    return 0
end

function FieldBattleData:IsDrumUsed(id)
    local drums = self.battle_info.drums or game.EmptyTable
    for _,v in ipairs(drums) do
        if v.id == id then
            return true
        end
    end
    return false
end

return FieldBattleData
