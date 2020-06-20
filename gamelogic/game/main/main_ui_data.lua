local MainUIData = Class(game.BaseData)

function MainUIData:_init()
    self.battle_info_list ={}
end

function MainUIData:_delete()

end

function MainUIData:SetBattleInfo(logs)
    self.battle_info_list ={}
    for i,v in ipairs(logs) do
        table.insert(self.battle_info_list, v.log)
    end
    self:FireEvent(game.SceneEvent.BattleInfoChange)
end

function MainUIData:AddBattleInfo(log)
    table.insert(self.battle_info_list, log)
    self:FireEvent(game.SceneEvent.BattleInfoChange)
end

function MainUIData:DelBattleInfo(id)
    for i,v in ipairs(self.battle_info_list) do
        if v.id == id then
            table.remove(self.battle_info_list, i)
            break
        end
    end
    self:FireEvent(game.SceneEvent.BattleInfoChange)
end

function MainUIData:GetBattleInfo()
    return self.battle_info_list
end

function MainUIData:SortBattleInfo()
    table.sort(self.battle_info_list, function(a, b)
        return a.id > b.id
    end)
end


return MainUIData
