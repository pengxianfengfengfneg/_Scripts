local FieldBattleAgainstInfoItemList = Class(game.UITemplate)

function FieldBattleAgainstInfoItemList:_init()
    
end

function FieldBattleAgainstInfoItemList:OpenViewCallBack()
    self:Init()
end

function FieldBattleAgainstInfoItemList:CloseViewCallBack()
    self:ClearItemList()
end

function FieldBattleAgainstInfoItemList:Init()
    self.list_item = self._layout_objs["list_item"]

    self.txt_info = self._layout_objs["txt_info"]
    self.txt_tips = self._layout_objs["txt_tips"]
end

local QualityWords = {
    [1] = config.words[5257],
    [2] = config.words[5258],
    [3] = config.words[5259],
}
function FieldBattleAgainstInfoItemList:UpdateData(quality, data_list, is_win_group)
    local item_class = require("game/guild/item/field_battle_against_info_item")

    self.field_quality = quality

    local item_num = #data_list
    self.list_item:SetItemNum(item_num)
    self.list_item:SetSize(660, item_num*60)

    self:ClearItemList()
    for k,v in ipairs(data_list) do
        local obj = self.list_item:GetChildAt(k-1)
        local item = item_class.New()
        item:SetVirtual(obj)
        item:Open()
        item:UpdateData(v)

        table.insert(self.item_list, item)
    end    

    local quality_word = QualityWords[quality]

    local next_quality = quality + 1
    local next_quality_word = QualityWords[next_quality]

    if is_win_group then
        -- 胜者组
        quality = quality + 1
        quality_word = QualityWords[quality]

        next_quality = next_quality + 1
        next_quality_word = QualityWords[next_quality]
        local word_id = (next_quality >= 4 and 5275 or 5273)
        self.txt_tips:SetText(string.format(config.words[word_id], next_quality_word, quality_word))
    else
        -- 败者组        
        local word_id = 5275
        self.txt_tips:SetText(string.format(config.words[word_id], next_quality_word, quality_word))
    end

    self:InitTime()
end

function FieldBattleAgainstInfoItemList:ClearItemList()
    for _,v in ipairs(self.item_list or game.EmptyTable) do
        v:DeleteMe()
    end
    self.item_list = {}
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
function FieldBattleAgainstInfoItemList:InitTime()
    local round = game.FieldBattleCtrl.instance:GetTerritoryRound()

    local cur_act_id = RoundActs[round]
    local next_act_id = RoundActs[round+1]

    if not cur_act_id then
        cur_act_id = RoundActs[1]
    end

    if not next_act_id then
        next_act_id = RoundActs[1]
    end

    local act_info = game.ActivityMgrCtrl.instance:GetActivity(cur_act_id)
    local str_time = config.words[5271]
    if act_info then
        -- 活动进行中        
    else
        -- 活动未开启，预告
        local coming_info = game.ActivityMgrCtrl.instance:GetActComingTime(cur_act_id)

        local wday = coming_info.wday
        local week_word = game.Utils.GetWeekCn(wday)
        local time_word = string.format("%02d:%02d", coming_info.hour, coming_info.min)
        str_time = week_word .. time_word
    end
    local round_words = RoundWords[self.field_quality + 1]
    self.txt_info:SetText(string.format(config.words[5274], round_words, str_time))
end

return FieldBattleAgainstInfoItemList