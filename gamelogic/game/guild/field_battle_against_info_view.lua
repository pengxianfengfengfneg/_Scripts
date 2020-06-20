local FieldBattleAgainstInfoView = Class(game.BaseView)

local config_territory = config.territory

function FieldBattleAgainstInfoView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "field_battle_against_info_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third
end

function FieldBattleAgainstInfoView:_delete()

end

function FieldBattleAgainstInfoView:OpenViewCallBack()
    self:Init()
    self:InitBg()
end

function FieldBattleAgainstInfoView:CloseViewCallBack()
    for _,v in ipairs(self.item_list or {}) do
        v:DeleteMe()
    end
    self.item_list = nil
end

function FieldBattleAgainstInfoView:Init()
    self.txt_info = self._layout_objs["txt_info"]
    self.txt_tips = self._layout_objs["txt_tips"]

    self.list_item = self._layout_objs["list_item"]
    self:InitItemList()

    --self:InitInfos()
end

function FieldBattleAgainstInfoView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5250])
end

function FieldBattleAgainstInfoView:OnEmptyClick()
    self:Close()
end

function FieldBattleAgainstInfoView:GetSortMatches()
    local sort_matches = {}
    local matches = game.FieldBattleCtrl.instance:GetTerritoryMatches() 
    for _,v in ipairs(matches) do
        local cfg = config_territory[v.blue_id] or game.EmptyTable
        local quality = cfg.quality or 0
        if not sort_matches[quality] then
            sort_matches[quality] = {}
        end
        table.insert(sort_matches[quality], v)
    end

    local final = {}
    for k,v in pairs(sort_matches) do
        table.insert(final, {k,v,true})
    end
    table.sort(final,function(v1,v2)
        return v1[1]<v2[1]
    end)

    if #final >= 2 then
        final[1][3] = false
        final[2][3] = true
    end
    return final
end

function FieldBattleAgainstInfoView:InitItemList()
    local matches = self:GetSortMatches()

    self.item_list = {}
    local item_num = #matches
    self.list_item:SetItemNum(item_num)

    local width,height = 660,0
    local item_class = require("game/guild/item/field_battle_against_info_item_list")
    for k,v in ipairs(matches) do
        local obj = self.list_item:GetChildAt(k-1)
        local item = item_class.New()
        item:SetVirtual(obj)
        item:Open()
        item:UpdateData(v[1],v[2],v[3])

        table.insert(self.item_list, item)

        local size = obj:GetSize()
        width = size[1]
        height = height + size[2]
    end

    height = math.max(height,300)
    self.list_item:SetSize(width, height)
end

local RoundActs = {
    [1] = 1010,
    [2] = 1011,
    [3] = 1012,
}
local RoundWords = {
    [1] = config.words[5257],
    [2] = config.words[5258],
    [3] = config.words[5259],
}
function FieldBattleAgainstInfoView:InitInfos()
    local round = game.FieldBattleCtrl.instance:GetTerritoryRound() or 4

    local cur_act_id = RoundActs[round]
    local next_act_id = RoundActs[round+1]

    if not cur_act_id then
        cur_act_id = RoundActs[1]
    end

    if not next_act_id then
        next_act_id = RoundActs[1]
    end

    local round_words = RoundWords[round]
    local act_info = game.ActivityMgrCtrl.instance:GetActivity(cur_act_id)
    local str_time = config.words[5271]
    if act_info then
        -- 活动进行中        
    else
        -- 活动未开启，预告
        local coming_info = game.ActivityMgrCtrl.instance:GetActComingTime(next_act_id)

        local wday = coming_info.wday
        local week_word = game.Utils.GetWeekCn(wday)
        local time_word = string.format("%02d:%02d", coming_info.hour, coming_info.min)
        str_time = week_word .. time_word
    end
    self.txt_info:SetText(string.format(config.words[5274], round_words, str_time))

    -- local next_round = round + 1
    -- local next_round_word = RoundWords[next_round]
    -- local pre_round = round - 1
    -- local pre_round_word = RoundWords[pre_round]
    -- if not next_round_word then
    --     self.txt_tips:SetText(string.format(config.words[5275], round_words, pre_round_word))
    -- else
    --     self.txt_tips:SetText(string.format(config.words[5273], next_round_word, round_words))
    -- end
end

function FieldBattleAgainstInfoView:CheckActOpen()
    for _,v in ipairs(RoundActs) do
        local act_info = game.ActivityMgrCtrl.instance:GetActivity(v)
        if act_info then
            return true
        end
    end
    return false
end

return FieldBattleAgainstInfoView
