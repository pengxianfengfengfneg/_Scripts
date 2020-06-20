local CareerBattleResultView = Class(game.BaseView)

function CareerBattleResultView:_init(ctrl)
    self._package_name = "ui_career_battle"
    self._com_name = "battle_result_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function CareerBattleResultView:_delete()
    
end

function CareerBattleResultView:OpenViewCallBack(data)
    self:Init()
    self:InitRewardList()
    self:Refresh(data)
    self:StartCloseCounter()
end

function CareerBattleResultView:CloseViewCallBack()
    local scene_id = game.Scene.instance:GetSceneID()
    if scene_id == config.career_battle_info.lounge_scene then
        self.ctrl:SendCareerBattleLoungeInfo()
    end
    self:StopCloseCounter()
end

function CareerBattleResultView:Init()
    self.txt_lose_score = self._layout_objs["txt_lose_score"]
    self.ctrl_state = self:GetRoot():GetController("ctrl_state")
    self.grade = self.ctrl:GetGrade()

    self._layout_objs.btn_back:AddClickCallBack(function()
        self:Close()
    end)
    
    self:InitWinInfo()
end

function CareerBattleResultView:InitWinInfo()
    self.list_win_info = self._layout_objs["list_win_info"]
    self.list_win_info.foldInvisibleItems = true

    self.comp_last_win_times = self.list_win_info:GetChildAt(0)
    self.comp_defend_last_win = self.list_win_info:GetChildAt(1)
    self.comp_extra_score = self.list_win_info:GetChildAt(2)
    self.comp_win_score = self.list_win_info:GetChildAt(3)

    self.txt_last_win_times = self.comp_last_win_times:GetChild("title")
    self.txt_defend_last_win = self.comp_defend_last_win:GetChild("title")
    self.txt_extra_score = self.comp_extra_score:GetChild("title")
    self.txt_win_score = self.comp_win_score:GetChild("title")
end

function CareerBattleResultView:InitRewardList()
    self.list_reward = self:CreateList("list_reward", "game/bag/item/goods_item")
    self.list_reward:SetRefreshItemFunc(function(item, idx)
        local item_info = self.reward_list_data[idx]
        item:SetItemInfo({id = item_info[1], num = item_info[2]})
        item:SetShowTipsEnable(true)
    end)
end

function CareerBattleResultView:UpdateRewardList(res)
    local drop_id = self:GetBattleRewardCfg(res)[2]
    self.reward_list_data = config.drop[drop_id].client_goods_list
    self.list_reward:SetItemNum(#self.reward_list_data)
end

function CareerBattleResultView:Refresh(result_info)
    if result_info.res == 1 then
        local reward_cfg = self:GetBattleRewardCfg(result_info.res)
        self.txt_lose_score:SetText(string.format(config.words[4817], reward_cfg[1]))
    elseif result_info.res == 2 then
        self.txt_last_win_times:SetText(string.format(config.words[4818], result_info.last_win_times, self:GetLastWinScore(result_info.last_win_times)))
        self.txt_defend_last_win:SetText(string.format(config.words[4819], result_info.defend_last_win, self:GetDefendLastWinScore(result_info.defend_last_win)))
        self.txt_extra_score:SetText(string.format(config.words[4820], result_info.extra_score))
        self.txt_win_score:SetText(string.format(config.words[4834], self:GetWinScore(result_info.res)))

        self.comp_defend_last_win:SetVisible(result_info.defend_last_win ~= 0)
        self.comp_extra_score:SetVisible(result_info.extra_score ~= 0)
    end
    self:UpdateRewardList(result_info.res)
    self.ctrl_state:SetSelectedIndexEx(result_info.res - 1)
end

function CareerBattleResultView:GetLastWinScore(last_win_times)
    if last_win_times == 0 then
        return 0
    else
        return config.career_battle_win[self.grade][last_win_times].get_score
    end
end

function CareerBattleResultView:GetDefendLastWinScore(defend_last_win)
    if defend_last_win == 0 then
        return 0
    else
        return config.career_battle_win[self.grade][defend_last_win].defend_get_score
    end
end

function CareerBattleResultView:GetBattleRewardCfg(res)
    local reward_cfg = config.career_battle_info.battle_reward
    local index = res == 1 and 2 or 1
    return reward_cfg[self.grade][2][index]
end

function CareerBattleResultView:GetWinScore(res)
    local reward_cfg = self:GetBattleRewardCfg(res)
    return reward_cfg[1]
end

function CareerBattleResultView:OnEmptyClick()
    self:Close()
end

function CareerBattleResultView:StartCloseCounter()
    self:StopCloseCounter()
    local time = 10
    self.tw_close = DOTween:Sequence()
    self.tw_close:AppendCallback(function()
        time = time - 1
        if time <= 0 then
            self:Close()
            self:StopCloseCounter()
        end
    end)
    self.tw_close:AppendInterval(1)
    self.tw_close:SetLoops(-1)
    self.tw_close:Play()
end

function CareerBattleResultView:StopCloseCounter()
    if self.tw_close then
        self.tw_close:Kill(false)
        self.tw_close = nil
    end
end

function CareerBattleResultView:RegisterAllEvents()
    local events = {
        [game.CareerBattleEvent.BattleEnd] = function(data)
            -- res__C  --1失败|2胜利
            -- last_win_times__C  -- 连胜次数
            -- defend_last_win__C -- 终结对方连胜的场数
            -- extra_score__H  -- 已弱胜强获得积分
            self:Refresh(data)
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return CareerBattleResultView
