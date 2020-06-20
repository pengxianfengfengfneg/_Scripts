
local LakeExpData = Class(game.BaseData)

function LakeExpData:_init()
    self.hang_pos_config = {}
end

function LakeExpData:SetKillMonNum(data)
    self.kill_mon_num = data.value
    self:FireEvent(game.LakeExpEvent.UpdateKillMonNum, self.kill_mon_num)
end

function LakeExpData:GetKillMonNum()
    return self.kill_mon_num or 0
end

function LakeExpData:GetKeepExpUseTimes()
    if self.lake_exp_info then
        return self.lake_exp_info.have_times
    end
    return 0
end

function LakeExpData:GetLakeExpInfo()
    return self.lake_exp_info
end

function LakeExpData:SetLakeExpInfo(data)
    self.lake_exp_info = data
    self:FireEvent(game.LakeExpEvent.UpdateLakeExpInfo, self.lake_exp_info)
end

function LakeExpData:UpdateLakeExpInfo(data)
    if self.lake_exp_info == nil then
        return
    end
    if data.type == 1 then
        self.lake_exp_info.keep_exp = data.keep_exp
        self.lake_exp_info.have_times = data.have_times
    else
        self.lake_exp_info.dl_keep_exp = data.keep_exp
    end
    self:FireEvent(game.LakeExpEvent.UpdateLakeExpInfo, self.lake_exp_info)
end

function LakeExpData:GetNextHangPos(scene_id, hang_pos)
    local num = #hang_pos
    local last_pos = self.hang_pos_config[scene_id]
    local pos
    while true do
        pos = hang_pos[math.random(1, num)]
        if not last_pos or (last_pos[1] ~= pos[1] and last_pos[2] ~= pos[2]) then
            self.hang_pos_config[scene_id] = pos
            break
        end
    end
    return cc.vec2(pos[1], pos[2])
end

function LakeExpData:ResetHangPos(scene_id)
    self.hang_pos_config[scene_id] = 0
end

function LakeExpData:GetKeepExp()
    if self.lake_exp_info then
        return self.lake_exp_info.keep_exp
    end
    return 0
end

function LakeExpData:GetPetExp()
    if self.lake_exp_info then
        return self.lake_exp_info.dl_keep_exp
    end
    return 0
end

return LakeExpData