local LakeBanditsData = Class(game.BaseData)

function LakeBanditsData:_init(ctrl)
    self.ctrl = ctrl
    self.dragon_owner_info = {}
end

function LakeBanditsData:_delete()
    
end

function LakeBanditsData:SetLineId(line_id)
    self.line_id = line_id
    self:FireEvent(game.LakeBanditsEvent.OnLineChange, line_id)
end

function LakeBanditsData:GetLineId()
    return self.line_id
end

function LakeBanditsData:SetMonsterInfo(mon_list)
    self.monster_info = {}
    for _, v in pairs(mon_list) do
        self.monster_info[v.mon_id] = v.mon_num
    end
    self:FireEvent(game.LakeBanditsEvent.UpdateDragonMon, self.monster_info)
end

function LakeBanditsData:GetMonsterNum(mon_id)
    if self.monster_info then
        return self.monster_info[mon_id] or 0
    end
    return 0
end

function LakeBanditsData:SetLineRoleInfo(line_role)
    self.line_role_info = line_role
    self:FireEvent(game.LakeBanditsEvent.UpdateLineRole, self.line_role_info)
end

function LakeBanditsData:GetLineRoleNum(line_id)
    if self.line_role_info then
        for _, v in pairs(self.line_role_info) do
            if v.line_id == line_id then
                return v.num
            end
        end
    end
end

function LakeBanditsData:SetDragonOwnerId(mon_id, role_id)
    self.dragon_owner_info[mon_id] = role_id
    self:FireEvent(game.LakeBanditsEvent.DragonBelong, mon_id, role_id)
end

function LakeBanditsData:GetDragonOwnerId(mon_id)
    return self.dragon_owner_info[mon_id]
end

function LakeBanditsData:UpdateDragonPosInfo(info)
    self.dragon_pos_info = info
    self:FireEvent(game.LakeBanditsEvent.UpdateDragonPosInfo, info)
end

function LakeBanditsData:GetDragonPosInfo()
    return self.dragon_pos_info
end

return LakeBanditsData