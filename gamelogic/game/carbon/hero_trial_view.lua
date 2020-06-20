local HeroTrialView = Class(game.BaseView)

local _carbon_id = 550
local _dun_cfg = config.dungeon_lv[_carbon_id]

function HeroTrialView:_init()
    self._package_name = "ui_carbon"
    self._com_name = "hero_trial_view"

    self._show_money = true
end

function HeroTrialView:OpenViewCallBack()
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.dungeon[_carbon_id].name)
    local fight = game.RoleCtrl.instance:GetCombatPower()
    self._layout_objs.my_fight:SetText(fight)

    self:InitList()
    self:InitBtn()

    self:BindEvent(game.CarbonEvent.RefreshMaterial, function()
        self:SetCurChapter()
    end)

    self:BindEvent(game.CarbonEvent.GetFirstReward, function()
        self:SetChapter(self.chapter)
    end)

    self:SetCurChapter()
end

function HeroTrialView:SetCurChapter()

    local dunge_data = game.CarbonCtrl.instance:GetData()
    self.hero_dun_data = dunge_data:GetDungeDataByID(_carbon_id)

    local max_lv = self.hero_dun_data.max_lv
    if max_lv > #_dun_cfg then
        max_lv = #_dun_cfg
        self._layout_objs.history:SetText(_dun_cfg[max_lv].name)
    else
        if max_lv == 0 then
            self._layout_objs.history:SetText(config.words[1552])
        else
            self._layout_objs.history:SetText(_dun_cfg[max_lv - 1].name)
        end
    end
    local now_lv = self.hero_dun_data.now_lv
    if now_lv > #_dun_cfg then
        now_lv = #_dun_cfg
    elseif now_lv == 0 then
        now_lv = 1
    end
    local max_chapter = math.ceil(now_lv / 10)
    self:SetChapter(max_chapter)
end

function HeroTrialView:InitBtn()
    self.hero_items = {}
    for i = 1, 10 do
        self.hero_items[i] = self:GetTemplate("game/daily_task/item/hero_item", "hero_item" .. i)
    end

    self._layout_objs.btn_left:AddClickCallBack(function()
        self:SetChapter(self.chapter - 1)
    end)
    self._layout_objs.btn_right:AddClickCallBack(function()
        self:SetChapter(self.chapter + 1)
    end)

    self._layout_objs.btn_start:AddClickCallBack(function()
        local dun_cfg = _dun_cfg[self.level]
        local role_fight = game.RoleCtrl.instance:GetCombatPower()
        if dun_cfg.fight > role_fight then
            local str = string.format(config.words[1422], dun_cfg.fight)
            local msg_box = game.GameMsgCtrl.instance:CreateMsgTips(str)
            msg_box:SetBtn1(nil, function()
                game.CarbonCtrl.instance:DungEnterReq(_carbon_id, self.level)
            end)
            msg_box:SetBtn2(config.words[101])
            msg_box:Open()
        else
            game.CarbonCtrl.instance:DungEnterReq(_carbon_id, self.level)
        end
    end)
    self._layout_objs.btn_sweep:AddClickCallBack(function()
        game.CarbonCtrl.instance:DungWipeReq(_carbon_id, self.level)
    end)

    self._layout_objs.btn_rank:AddClickCallBack(function()
        local rank_cfg = config.rank[4]
        game.RankCtrl.instance:OpenRankSubView(rank_cfg.main_type, rank_cfg.id)
    end)

    self._layout_objs.btn_hero:AddClickCallBack(function()
        game.HeroCtrl.instance:OpenView()
    end)
end

function HeroTrialView:InitList()
    self.first_list = self:CreateList("first_list", "game/bag/item/goods_item")
    self.first_list:SetRefreshItemFunc(function(item, idx)
        local info = self.first_reward[idx]
        item:SetItemInfo({ id = info[1], num = info[2] })
        item:SetShowTipsEnable(true)
    end)

    self.pass_list = self:CreateList("pass_list", "game/bag/item/goods_item")
    self.pass_list:SetRefreshItemFunc(function(item, idx)
        local info = self.pass_reward[idx]
        item:SetItemInfo({ id = info[1], num = info[2] })
        item:SetShowTipsEnable(true)
    end)
end

function HeroTrialView:SetChapter(chapter)
    self.chapter = chapter
    self._layout_objs.name:SetText(_dun_cfg[(chapter - 1) * 10 + 1].chapter_name)

    local max_lv = self.hero_dun_data.max_lv
    if max_lv > #_dun_cfg then
        max_lv = #_dun_cfg
    elseif max_lv == 0 then
        max_lv = 1
    end
    local max_chapter = math.ceil(max_lv / 10)
    self._layout_objs.btn_right:SetVisible(chapter < max_chapter)
    self._layout_objs.btn_left:SetVisible(chapter > 1)

    local left_tips, right_tips = false, false
    for i = 1, 10 do
        self.hero_items[i]:SetItemInfo(_dun_cfg[(chapter - 1) * 10 + i])

        if chapter > 1 and left_tips == false then
            local item_info = _dun_cfg[(chapter - 2) * 10 + i]
            local flag = true
            for _, v in pairs(self.hero_dun_data.first_reward) do
                if v.lv == item_info.level then
                    flag = false
                end
            end
            if item_info.first_award ~= 0 and flag and self.hero_dun_data.max_lv > item_info.level then
                left_tips = true
            end
        end

        if chapter < max_chapter and right_tips == false then
            local item_info = _dun_cfg[chapter * 10 + i]
            local flag = true
            for _, v in pairs(self.hero_dun_data.first_reward) do
                if v.lv == item_info.level then
                    flag = false
                end
            end
            if item_info.first_award ~= 0 and flag and self.hero_dun_data.max_lv > item_info.level then
                right_tips = true
            end
        end
    end
    game.Utils.SetTip(self._layout_objs.btn_left, left_tips, {x = 21, y = 46})
    game.Utils.SetTip(self._layout_objs.btn_right, right_tips, {x = 32, y = 46})

    local now_lv = self.hero_dun_data.now_lv
    if now_lv > #_dun_cfg then
        now_lv = #_dun_cfg
    elseif now_lv == 0 then
        now_lv = 1
    end

    local reward_id = config.dungeon_chapter[_carbon_id][chapter][1].reward
    self.first_reward = config.drop[reward_id].client_goods_list
    self.first_list:SetItemNum(#self.first_reward)
    local flag = false
    for _, v in pairs(self.hero_dun_data.chapter_reward) do
        if v.id == chapter then
            flag = true
            break
        end
    end
    self._layout_objs.first_got:SetVisible(flag)

    self:SetLevel(now_lv)
end

function HeroTrialView:SetLevel(level)
    if level > 1 and level > self.hero_dun_data.max_lv then
        return
    end
    self.level = level
    local dun_cfg = _dun_cfg[level]

    self.pass_reward = config.drop[dun_cfg.daily_award].client_goods_list
    self.pass_list:SetItemNum(#self.pass_reward)

    local pass = false
    for _, v in pairs(self.hero_dun_data.daily_reward) do
        if v.lv == level then
            pass = true
            break
        end
    end
    self._layout_objs.pass_got:SetVisible(pass)

    for i = 1, 10 do
        self.hero_items[i]:SetSelect(i + (self.chapter - 1) * 10 == level)
    end
end

return HeroTrialView