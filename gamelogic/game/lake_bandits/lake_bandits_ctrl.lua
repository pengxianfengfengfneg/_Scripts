local LakeBanditsCtrl = Class(game.BaseCtrl)

function LakeBanditsCtrl:_init()
    if LakeBanditsCtrl.instance ~= nil then
        error("LakeBanditsCtrl Init Twice!")
    end
    LakeBanditsCtrl.instance = self

    self.view = require("game/lake_bandits/lake_bandits_side_info_view").New(self)
    self.tips_view = require("game/lake_bandits/lake_bandits_tips_view").New(self)
    self.data = require("game/lake_bandits/lake_bandits_data").New(self)

    self:RegisterAllProtocal()
end

function LakeBanditsCtrl:_delete()
    self.view:DeleteMe()
    self.tips_view:DeleteMe()
    self.data:DeleteMe()
    
    LakeBanditsCtrl.instance = nil
end

function LakeBanditsCtrl:PrintTable(...)
    if self.log_enable then
        PrintTable(...)
    end
end

function LakeBanditsCtrl:print(...)
    if self.log_enable then
        print(...)
    end
end

function LakeBanditsCtrl:RegisterAllProtocal()
    local proto = {
        [51302] = "OnLakeBanditsEnter",
        [51304] = "OnLakeBanditsLeave",
        [51306] = "OnLakeBanditsSwitch",
        [51311] = "OnLakeBanditsDragonBelong",
        [51313] = "OnLakeBanditsDragonRole",
        [51315] = "OnLakeBanditsDragonMon",
        [51317] = "OnLakeBanditsDragonInfo",
    }
    for id, func_name in pairs(proto) do
        self:RegisterProtocalCallback(id, func_name)
    end
end

function LakeBanditsCtrl:OpenSideInfoView()
    self.view:Open()
end

function LakeBanditsCtrl:CloseSideInfoView()
    self.view:Close()
end

function LakeBanditsCtrl:OpenTipsView()
    self.tips_view:Open()
end

function LakeBanditsCtrl:CloseTipsView()
    self.tips_view:Close()
end

-- 进入
function LakeBanditsCtrl:SendLakeBanditsEnter()
    self:SendProtocal(51301)
end

-- 离开
function LakeBanditsCtrl:SendLakeBanditsLeave()
    self:SendProtocal(51303)
end

-- 切换
function LakeBanditsCtrl:SendLakeBanditsSwitch(line_id)
    -- line_id__C
    self:SendProtocal(51305, {line_id = line_id})
end

-- 分线人数请求
function LakeBanditsCtrl:SendLakeBanditsDragonRole()
    self:SendProtocal(51312)
end

-- 怪物数量请求
function LakeBanditsCtrl:SendLakeBanditsDragonMon(line_id)
    -- line_id__C
    self:SendProtocal(51314, {line_id = line_id})
end

function LakeBanditsCtrl:OnLakeBanditsEnter(data)
    -- line_id__C
    self:PrintTable(data)
    self.data:SetLineId(data.line_id)
end

function LakeBanditsCtrl:OnLakeBanditsLeave(data)
    self:PrintTable(data)
end

function LakeBanditsCtrl:OnLakeBanditsSwitch(data)
    -- line_id__C
    self:PrintTable(data)
    self.data:SetLineId(data.line_id)
end

-- 大龙小龙归属者
function LakeBanditsCtrl:OnLakeBanditsDragonBelong(data)
    -- role_id__L  -- 为0时没有归属者
    -- mon_id__L
    self:PrintTable(data)
    self:SetMonsterOwnerType(game.Scene.instance:GetObjByUniqID(data.mon_id), data.role_id)
    self.data:SetDragonOwnerId(data.mon_id, data.role_id)
end

function LakeBanditsCtrl:OnLakeBanditsDragonRole(data)
    -- line_role_num__T__line_id@C##num@H
    self:PrintTable(data)
    self.data:SetLineRoleInfo(data.line_role_num)
end

function LakeBanditsCtrl:OnLakeBanditsDragonMon(data)
    -- mon_list__T__mon_id@I##mon_num@C
    self:PrintTable(data)
    self.data:SetMonsterInfo(data.mon_list)
end

function LakeBanditsCtrl:GetMonsterConfig(world_lv)
    local world_lv = world_lv or game.MainUICtrl.instance:GetWorldLv()
    if config.lake_bandits_mon[world_lv] then
        return config.lake_bandits_mon[world_lv]
    end
    for _, config in ipairs(game.Utils.SortByKey(config.lake_bandits_mon)) do
        if world_lv <= config.world_lv then
            return config
        end
    end
end

function LakeBanditsCtrl:SetLineId(line_id)
    self.data:SetLineId(line_id)
end

function LakeBanditsCtrl:GetLineId()
    return game.Scene.instance:GetServerLine()
end

function LakeBanditsCtrl:GetMonsterNum(mon_id)
    return self.data:GetMonsterNum(mon_id)
end

function LakeBanditsCtrl:GetLineRoleNum(line_id)
    return self.data:GetLineRoleNum(line_id)
end

function LakeBanditsCtrl:GetLineRoleState(role_num)
    local max_role_num = config.lake_bandits_info.line_max_role
    
    if role_num then
        local percent = role_num / max_role_num * 100
        for _, v in pairs(config.lake_bandits_line_info) do
            if percent <= v.percent then
                return game.Utils.ColorWrapper("(" .. v.name .. ")", v.color, 1)
            end
        end
    end
end

function LakeBanditsCtrl:SetMonsterOwnerType(monster, owner_id)
    if monster then
        if not owner_id or owner_id == 0 then
            monster:SetOwnerType(game.OwnerType.None)
        elseif owner_id == game.Scene.instance:GetMainRoleID() or game.MakeTeamCtrl.instance:IsTeamMember(owner_id) then
            monster:SetOwnerType(game.OwnerType.Self)
        else
            monster:SetOwnerType(game.OwnerType.Others)
        end
        self:FireEvent(game.SceneEvent.TargetOwnerTypeChange, monster)
    end
end

function LakeBanditsCtrl:GetDragonOwnerId(mon_id)
    return self.data:GetDragonOwnerId(mon_id)
end

function LakeBanditsCtrl:OnLakeBanditsDragonInfo(data)
    -- info__T__type@C##x@H##y@H##lv@H
    self.data:UpdateDragonPosInfo(data.info)
end

function LakeBanditsCtrl:GetDragonPosInfo()
    return self.data:GetDragonPosInfo()
end

game.LakeBanditsCtrl = LakeBanditsCtrl

return LakeBanditsCtrl