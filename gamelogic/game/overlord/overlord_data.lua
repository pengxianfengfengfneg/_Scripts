local OverlordData = Class(game.BaseData)

function OverlordData:_init()
end

function OverlordData:_delete()
end

function OverlordData:SetRankData(data)
    self.rank_data = data
end

function OverlordData:GetRankData()
    return self.rank_data
end

function OverlordData:SetInfo(data)
    self.overlord_info = data
    self.boss_hp = data.hp_pert
end

function OverlordData:GetInfo()
    return self.overlord_info
end

function OverlordData:SetBossHp(data)
    self.boss_hp = data
end

function OverlordData:GetBossHp()
    return self.boss_hp
end

function OverlordData:GetSelfScore()
    if self.overlord_info then
        return self.overlord_info.score
    else
        return 0
    end
end

return OverlordData
