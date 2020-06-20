local HeroTrialTemplate = Class(game.UITemplate)

local _carbon_id = 550
local _dun_cfg = config.dungeon_lv[_carbon_id]

function HeroTrialTemplate:_init()
    self._package_name = "ui_daily_task"
    self._com_name = "hero_trial_template"
end

function HeroTrialTemplate:OpenViewCallBack()
    local fight = game.RoleCtrl.instance:GetCombatPower()
    self._layout_objs.my_fight:SetText(fight)

    self:InitList()
    self:InitBtn()

    self:BindEvent(game.CarbonEvent.RefreshMaterial, function()
        self:SetCurChapter()
    end)

    self:SetCurChapter()
end

function HeroTrialTemplate:SetCurChapter()

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

function HeroTrialTemplate:InitBtn()
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
            local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[1660], str)
            msg_box:SetOkBtn(function()
                game.CarbonCtrl.instance:DungEnterReq(_carbon_id, self.level)
            end)
            msg_box:SetCancelBtn(function()
            end)
            msg_box:Open()
        else
            game.CarbonCtrl.instance:DungEnterReq(_carbon_id, self.level)
        end
    end)
    self._layout_objs.btn_sweep:AddClickCallBack(function()
        game.CarbonCtrl.instance:DungWipeReq(_carbon_id, self.level)
    end)

    self._layout_objs.btn_rank:AddClickCallBack(function()
        game.CarbonCtrl.instance:OpenRankView(game.RankId.HeroTrialCarbon)
    end)

    self._layout_objs.btn_hero:AddClickCallBack(function()
        game.HeroCtrl.instance:OpenView()
    end)
end

function HeroTrialTemplate:InitList()
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

function HeroTrialTemplate:SetChapter(chapter)
    if self.chapter == chapter then
        return
    end
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

    for i = 1, 10 do
        self.hero_items[i]:SetItemInfo(_dun_cfg[(chapter - 1) * 10 + i])
    end

    local now_lv = self.hero_dun_data.now_lv
    if now_lv > #_dun_cfg then
        now_lv = #_dun_cfg
    elseif now_lv == 0 then
        now_lv = 1
    end
    self:SetLevel(now_lv)
end

function HeroTrialTemplate:SetLevel(level)
    if level > 1 and level > self.hero_dun_data.max_lv then
        return
    end
    self.level = level
    local dun_cfg = _dun_cfg[level]
    if dun_cfg.first_award == 0 then
        self.first_reward = {}
    else
        self.first_reward = config.drop[dun_cfg.first_award].client_goods_list
    end
    self.first_list:SetItemNum(#self.first_reward)
    self.pass_reward = config.drop[dun_cfg.daily_award].client_goods_list
    self.pass_list:SetItemNum(#self.pass_reward)

    self._layout_objs.first_got:SetVisible(self.hero_dun_data.max_lv > level and #self.first_reward > 0)
    local pass = false
    for i, v in pairs(self.hero_dun_data.daily_reward) do
        if v.lv == level then
            pass = true
            break
        end
    end
    self._layout_objs.pass_got:SetVisible(pass)

    local idx = level % 10
    if idx == 0 then
        idx = 10
    end
    for i = 1, 10 do
        self.hero_items[i]:SetSelect(i == idx)
    end
end

return HeroTrialTemplate