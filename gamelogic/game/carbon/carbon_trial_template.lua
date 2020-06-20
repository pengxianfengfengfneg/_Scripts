local CarbonTrialTemplate = Class(game.UITemplate)

local _carbon_id = 400
local _dun_cfg = config.dungeon_lv[_carbon_id]

function CarbonTrialTemplate:_init()
    self._package_name = "ui_carbon"
    self._com_name = "carbon_trial_template"
end

function CarbonTrialTemplate:OpenViewCallBack()
    local dunge_data = game.CarbonCtrl.instance:GetData()
    self.dun_data = dunge_data:GetDungeDataByID(_carbon_id)

    self:BindEvent(game.CarbonEvent.GetFirstReward, function(data)
        self.dun_data = dunge_data:GetDungeDataByID(_carbon_id)
        self:SetFirstPassReward(self.cur_page)
    end)
    self:BindEvent(game.CarbonEvent.RefreshMaterial, function()
        self.dun_data = dunge_data:GetDungeDataByID(_carbon_id)
        self:SetLevel()
    end)

    self:InitFirstPassLevel()

    self:InitBtn()

    local max_lv = self.dun_data.max_lv
    if max_lv > 0 then
        max_lv = max_lv - 1
    end
    self._layout_objs.max_level:SetText(string.format(config.words[1419], max_lv))

    self:SetLevel()

    self:SetFirstPassReward(1)
end

function CarbonTrialTemplate:CloseViewCallBack()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
    self:StopCountTime()
end

function CarbonTrialTemplate:InitBtn()

    self._layout_objs.btn_left:AddClickCallBack(function()
        self:SetFirstPassReward(self.cur_page - 1)
    end)
    self._layout_objs.btn_right:AddClickCallBack(function()
        self:SetFirstPassReward(self.cur_page + 1)
    end)

    self._layout_objs.btn_start:AddClickCallBack(function()
        game.CarbonCtrl.instance:DungEnterReq(_carbon_id, self.level)
    end)
    self._layout_objs.btn_all:AddClickCallBack(function()
        game.CarbonCtrl.instance:DungWipeReq(_carbon_id, self.level)
    end)

    self._layout_objs.btn_rank:AddClickCallBack(function()
        game.CarbonCtrl.instance:OpenRankView(game.RankId.TrialCarbon)
    end)

    self._layout_objs.btn_checkbox:AddClickCallBack(function()
        if self._layout_objs.btn_checkbox:GetSelected() then
            self:StartCountTime(10)
        else
            game.CarbonCtrl.instance:SetAutoStart(_carbon_id, false)
            self:StopCountTime()
        end
    end)
    local auto_start = game.CarbonCtrl.instance:GetAutoStart(_carbon_id)
    self._layout_objs.btn_checkbox:SetSelected(auto_start == true)
    if auto_start then
        self:StartCountTime(10)
    end

    for i = 1, 3 do
        self._layout_objs["btn_treasure" .. i]:AddClickCallBack(function()
            game.CarbonCtrl.instance:OpenFirstRewardView(_carbon_id, self.first_reward_level[i])
        end)
    end
end

function CarbonTrialTemplate:SetLevel()
    local now_lv = self.dun_data.now_lv
    if now_lv > #_dun_cfg then
        now_lv = #_dun_cfg
    elseif now_lv == 0 then
        now_lv = 1
    end
    self.level = now_lv
    self._layout_objs.cur_level:SetText(self.level .. config.words[1414])

    local cfg = config.dungeon_lv[_carbon_id][self.level]
    local monster_id = cfg.pass_cond[1][2][1][1]
    local mon_model_id = config.monster[monster_id].model_id

    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.graph, game.BodyType.Monster)
    self.model:SetPosition(0, -0.9, 3)
    local ui_zoom = config.monster[monster_id].ui_zoom
    self.model:SetScale(ui_zoom)
    self.model:SetRotation(0, 180, 0)
    self.model:SetModel(game.ModelType.Body, mon_model_id)
    self.model:PlayAnim(game.ObjAnimName.Idle)
end

function CarbonTrialTemplate:SetFirstPassReward(page)
    self.cur_page = page
    self.first_reward_level = {}
    for i = 1, 3 do
        local lv = (page - 1) * 3 + i
        if self.fist_pass_level[lv] then
            table.insert(self.first_reward_level, self.fist_pass_level[lv].level)
        else
            table.insert(self.first_reward_level, self.fist_pass_level[lv - 3].level)
        end
    end
    table.sort(self.first_reward_level, function(a, b)
        return a < b
    end)

    self._layout_objs.btn_right:SetVisible(page < math.ceil(#self.fist_pass_level / 3))
    self._layout_objs.btn_left:SetVisible(page > 1)

    local progress = 0
    for i, val in ipairs(self.first_reward_level) do
        if self.dun_data.max_lv > val then
            progress = progress + 1
        end
        game.Utils.SetTip(self._layout_objs["btn_treasure" .. i], self.dun_data.max_lv > val, cc.vec2(90, 9))
        self._layout_objs["btn_treasure" .. i .. "/got"]:SetVisible(false)
        self._layout_objs["level" .. i]:SetText(val .. config.words[1414])
    end
    self._layout_objs.bar:SetProgressValue(progress / 3 * 100)
    for k, v in pairs(self.dun_data.first_reward) do
        for i, val in ipairs(self.first_reward_level) do
            if v.lv == val then
                self._layout_objs["btn_treasure" .. i .. "/got"]:SetVisible(true)
                game.Utils.SetTip(self._layout_objs["btn_treasure" .. i], false)
            end
        end
    end
end

function CarbonTrialTemplate:StartCountTime(count_time)
    self:StopCountTime()
    self.tween = DOTween.Sequence()
    self.tween:AppendCallback(function()
        if count_time < 0 then
            self:StopCountTime()
            game.CarbonCtrl.instance:DungEnterReq(_carbon_id, self.level)
        else
            self._layout_objs.auto_start:SetText(config.words[1418] .. "(" .. count_time .. ")")
        end
        count_time = count_time - 1
    end)
    self.tween:AppendInterval(1)
    self.tween:SetLoops(-1)
end

function CarbonTrialTemplate:StopCountTime()
    self._layout_objs.auto_start:SetText(config.words[1418])
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

function CarbonTrialTemplate:InitFirstPassLevel()
    self.fist_pass_level = {}
    for i, v in pairs(_dun_cfg) do
        if v.first_award ~= 0 then
            table.insert(self.fist_pass_level, v)
        end
    end
    table.sort(self.fist_pass_level, function(a, b)
        return a.level < b.level
    end)
end

return CarbonTrialTemplate