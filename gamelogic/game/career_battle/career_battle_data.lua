local CareerBattleData = Class(game.BaseData)

function CareerBattleData:_init(ctrl)
    self.ctrl = ctrl
end

function CareerBattleData:UpdateBattleEndTime(battle_end_time)
    self.battle_end_time = battle_end_time
    self:FireEvent(game.CareerBattleEvent.EnterBattleScene, battle_end_time)
end

function CareerBattleData:GetBattleEndTime()
    return self.battle_end_time or 0
end

function CareerBattleData:SetTopInfo(data)
    self.top_info = data

    for _, id in pairs(config.career_battle_info.statue_list) do
        local scene = game.Scene.instance
        local npc = scene and scene:GetNpc(id)
        if npc then
            npc:RefreshName()
            npc:RefreshFuncName()
        end
    end
    local dialog_npc_id = game.TaskCtrl.instance:GetDialogNpcId()
    if self.ctrl:IsStatue(dialog_npc_id) then
        global.EventMgr:Fire(game.NpcEvent.UpdateEventList, dialog_npc_id)
    end
end

function CareerBattleData:GetTopInfo(career, grade)
    for k, v in pairs(self.top_info or game.EmptyTable) do
        if v.career == career and v.grade == grade then
            return v
        end
    end
end

function CareerBattleData:GetStatueCareer(npc_id)
    for k, v in pairs(config.career_battle_info.statue_list or game.EmptyTable) do
        if v == npc_id then
            return k
        end
    end
    return 0
end

function CareerBattleData:GetStatueFuncName(npc_id, grade)
    local career = self:GetStatueCareer(npc_id)
    local top_info = self:GetTopInfo(career, grade)
    local grade_name = config.career_battle_grade[grade].name
    if top_info then
        return string.format("%s-%s", grade_name, top_info.name)
    end
    return string.format("%s-%s", grade_name, config.words[4841])
end

return CareerBattleData