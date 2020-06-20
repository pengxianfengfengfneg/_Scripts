local FightRankTemplate = Class(game.UITemplate)

local StateIndex = {
    Rank = 0,
    None = 1,
}

local min_rank_num = 9

function FightRankTemplate:_init(view, career)
    self.ctrl = game.CareerBattleCtrl.instance
    self.career = career
end

function FightRankTemplate:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
end

function FightRankTemplate:CloseViewCallBack()
    
end

function FightRankTemplate:RegisterAllEvents()
    local events = {
        {game.CareerBattleEvent.UpdateBattleRankInfo, handler(self, self.UpdateBattleRankInfo)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function FightRankTemplate:Init()
    self.list_rank = self:CreateList("list_rank", "game/career_battle/item/fight_rank_item")
    self.list_rank:SetRefreshItemFunc(function(item, idx)
        local item_info = self.rank_list_data[idx]
        if item_info then
            item_info.career = self.career
            item_info.drop_id = self.ctrl:GetRankDropId(self.grade, item_info.rank)
        end
        item:SetItemInfo(item_info, idx)
    end)

    self.txt_my_rank = self._layout_objs.txt_my_rank

    self.ctrl_grade = self:GetRoot():AddControllerCallback("ctrl_grade", function(idx)
        self:OnGradeClick(idx+1)
    end)

    self.ctrl_state = self:GetRoot():GetController("ctrl_state")

    local grade_cfg = config.career_battle_grade
    local package = "ui_career_battle"

    self.list_grade = self._layout_objs.list_grade
    self.list_grade:SetItemNum(#grade_cfg)

    for k, v in ipairs(grade_cfg) do
        local grade = self.list_grade:GetChildAt(k-1)
        grade:GetChild("img_icon"):SetSprite(package, v.icon1)
        grade:GetChild("img_icon_select"):SetSprite(package, v.icon2)
        grade:SetText(v.name)
    end

    self.ctrl_state:SetSelectedIndexEx(StateIndex.None)

    self.grade = self.grade or 1
    self.ctrl_grade:SetSelectedIndexEx(self.grade-1)
end

function FightRankTemplate:OnGradeClick(idx)
    self.grade = idx
    self.ctrl:SendCareerBattleRank(self.career, self.grade)
end

function FightRankTemplate:OnActived()
    -- career__C  // 职业
    -- grade__C  // 段位(1:青铜…4:钻石)
    self.ctrl:SendCareerBattleRank(self.career, self.grade or 1)
end

function FightRankTemplate:UpdateBattleRankInfo(data)
	-- career__C  // 职业
	-- grade__C  // 段位(1:青铜…4:钻石)
	-- role_rank__I  // 玩家排名
    -- ranks__T__rank@I##name@s##guild_name@s##score@I##icon@I
    if data.career == self.career and data.grade == self.grade then
        self.rank_list_data = {}
        for k, v in ipairs(data.ranks) do
            table.insert(self.rank_list_data, v)
        end
        table.sort(self.rank_list_data, function(m, n)
            return m.rank < n.rank
        end)
        self.list_rank:SetItemNum(math.max(min_rank_num, #self.rank_list_data))
    end

    if data.career == game.Scene.instance:GetMainRoleCareer() then
        self.txt_my_rank:SetText(string.format(config.words[4829], data.role_rank))
        self.ctrl_state:SetSelectedIndexEx(StateIndex.Rank)
    else
        self.ctrl_state:SetSelectedIndexEx(StateIndex.None)
    end
end

return FightRankTemplate