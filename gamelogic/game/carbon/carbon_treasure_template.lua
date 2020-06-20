local CarbonTresaureTemplate = Class(game.UITemplate)

local _carbon_id = 200
local _dun_cfg = config.dungeon_lv[_carbon_id]

function CarbonTresaureTemplate:_init()
    self._package_name = "ui_carbon"
    self._com_name = "carbon_treasure_template"
end

function CarbonTresaureTemplate:OpenViewCallBack()
    local dunge_data = game.CarbonCtrl.instance:GetData()
    self.trea_dun_data = dunge_data:GetDungeDataByID(_carbon_id)

    self:BindEvent(game.CarbonEvent.GetChapterReward, function(data)
        self.trea_dun_data = dunge_data:GetDungeDataByID(_carbon_id)
        self:SetChapterReward(self.chapter)
    end)
    self:BindEvent(game.CarbonEvent.RefreshMaterial, function()
        self.trea_dun_data = dunge_data:GetDungeDataByID(_carbon_id)
        self:SetLevel(self.level)
    end)

    self:InitList()
    self:InitBtn()
    self._layout_objs.name:SetText(config.dungeon_type[2].name)

    local now_lv = self.trea_dun_data.now_lv
    if now_lv > 0 then
        now_lv = now_lv - 1
    end
    now_lv = self.trea_dun_data.now_lv
    if now_lv > #_dun_cfg then
        now_lv = #_dun_cfg
    elseif now_lv == 0 then
        now_lv = 1
    end
    self:SetLevel(now_lv)
end

function CarbonTresaureTemplate:CloseViewCallBack()
    self.first_list:DeleteMe()
    self.pass_list:DeleteMe()
    self:StopCountTime()
end

function CarbonTresaureTemplate:InitBtn()
    self.controller = self:GetRoot():GetController("con_lv")
    for i = 1, 6 do
        self._layout_objs["treasure_lv" .. i]:AddClickCallBack(function()
            local lv = self.chapter * 6 - 6 + i
            if lv <= self.trea_dun_data.max_lv then
                self:SetLevel(lv)
            end
        end)
    end

    self._layout_objs.btn_left:AddClickCallBack(function()
        self:SetLevel(self.chapter * 6 - 11)
    end)
    self._layout_objs.btn_right:AddClickCallBack(function()
        self:SetLevel(self.chapter * 6 + 1)
    end)

    self._layout_objs.btn_dig:AddClickCallBack(function()
        game.CarbonCtrl.instance:DungEnterReq(_carbon_id, self.level)
    end)
    self._layout_objs.btn_all:AddClickCallBack(function()
        game.CarbonCtrl.instance:DungWipeReq(_carbon_id, self.level)
    end)
    local vip_lv = game.VipCtrl.instance:GetVipLevel()
    self._layout_objs.btn_all:SetGray(vip_lv < 4)
    self._layout_objs.btn_all:SetTouchEnable(vip_lv >= 4)
    self._layout_objs.vip_text:SetVisible(vip_lv < 4)

    self._layout_objs.btn_rank:AddClickCallBack(function()
        game.CarbonCtrl.instance:OpenRankView(game.RankId.TreasureCarbon)
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
            game.CarbonCtrl.instance:OpenChapterRewardView(_carbon_id, self.chapter, i * 6)
        end)
    end
end

function CarbonTresaureTemplate:InitList()
    self.first_list = game.UIList.New(self._layout_objs.first_list)
    self.first_list:SetCreateItemFunc(function(obj)
        local item = require("game/bag/item/goods_item").New()
        item:SetVirtual(obj)
        item:Open()
        return item
    end)
    self.first_list:SetRefreshItemFunc(function(item, idx)
        local info = self.first_reward[idx]
        item:SetItemInfo({ id = info[1], num = info[2] })
        item:SetShowTipsEnable(true)
    end)
    self.first_list:SetVirtual(false)

    self.pass_list = game.UIList.New(self._layout_objs.pass_list)
    self.pass_list:SetCreateItemFunc(function(obj)
        local item = require("game/bag/item/goods_item").New()
        item:SetVirtual(obj)
        item:Open()
        return item
    end)
    self.pass_list:SetRefreshItemFunc(function(item, idx)
        local info = self.pass_reward[idx]
        item:SetItemInfo({ id = info[1], num = info[2] })
        item:SetShowTipsEnable(true)
    end)
    self.pass_list:SetVirtual(false)
end

function CarbonTresaureTemplate:SetChapter(chapter)
    if self.chapter == chapter then
        return
    end
    self.chapter = chapter
    local chapter_star = 0
    for i, v in ipairs(config.dungeon_chapter[_carbon_id][chapter]) do
        self._layout_objs["chapter_star" .. i]:SetText(v.star)
        chapter_star = v.star
    end
    local total_star = 0
    for i = 1, 18 do
        self._layout_objs["star" .. i]:SetVisible(false)
    end
    for i, v in pairs(self.trea_dun_data.star_info) do
        if _dun_cfg[v.lv].chapter == chapter then
            total_star = total_star + v.star
            for j = 1, 3 do
                self._layout_objs["star" .. j + v.lv * 3 - chapter * 18 + 15]:SetVisible(v.star >= j)
            end
        end
    end
    self._layout_objs.total_star:SetText(total_star .. "/" .. chapter_star)
    local bar_val = 0
    if total_star >= 18 then
        bar_val = 100
    elseif total_star >= 12 then
        bar_val = 50
    end
    self._layout_objs.bar:SetProgressValue(bar_val)
    local max_lv = self.trea_dun_data.max_lv
    if max_lv > #_dun_cfg then
        max_lv = #_dun_cfg
    end
    local max_chapter = _dun_cfg[max_lv == 0 and 1 or max_lv].chapter
    self._layout_objs.btn_right:SetVisible(chapter < max_chapter)
    self._layout_objs.btn_left:SetVisible(chapter > 1)

    self:SetChapterReward(chapter)
end

function CarbonTresaureTemplate:SetLevel(level)
    self.level = level
    local dun_cfg = _dun_cfg[level]
    self.first_reward = config.drop[dun_cfg.first_award].client_goods_list
    self.first_list:SetItemNum(#self.first_reward)
    self.pass_reward = config.drop[dun_cfg.daily_award].client_goods_list
    self.pass_list:SetItemNum(#self.pass_reward)

    self._layout_objs.first_got:SetVisible(self.trea_dun_data.max_lv > level)
    local pass = false
    for i, v in pairs(self.trea_dun_data.daily_reward) do
        if v.lv == level then
            pass = true
            break
        end
    end
    self._layout_objs.pass_got:SetVisible(pass)

    local sub_lv = level % 6
    if sub_lv == 0 then
        sub_lv = 6
    end
    self._layout_objs.level_text:SetText(dun_cfg.chapter .. "-" .. sub_lv)
    self.controller:SetSelectedIndexEx(sub_lv - 1)
    self:SetChapter(dun_cfg.chapter)
end

function CarbonTresaureTemplate:SetChapterReward(chapter)
    local total = 0
    for i, v in pairs(self.trea_dun_data.star_info) do
        if _dun_cfg[v.lv].chapter == chapter then
            total = total + v.star
        end
    end
    for i, val in ipairs(config.dungeon_chapter[_carbon_id][chapter]) do
        game.Utils.SetTip(self._layout_objs["btn_treasure" .. i], total >= val.star, cc.vec2(90, 9))
        self._layout_objs["btn_treasure" .. i .. "/got"]:SetVisible(false)
    end
    for k, v in pairs(self.trea_dun_data.chapter_reward) do
        if v.id == chapter then
            for i, val in ipairs(config.dungeon_chapter[_carbon_id][chapter]) do
                if v.star == val.star then
                    self._layout_objs["btn_treasure" .. i .. "/got"]:SetVisible(true)
                    game.Utils.SetTip(self._layout_objs["btn_treasure" .. i], false)
                end
            end
        end
    end
end

function CarbonTresaureTemplate:StartCountTime(count_time)
    self:StopCountTime()
    self.tween = DOTween.Sequence()
    self.tween:AppendCallback(function()
        if count_time < 0 then
            self:StopCountTime()
            game.CarbonCtrl.instance:DungEnterReq(_carbon_id, self.level)
        else
            self._layout_objs.auto_start:SetText(config.words[1415] .. "(" .. count_time .. ")")
        end
        count_time = count_time - 1
    end)
    self.tween:AppendInterval(1)
    self.tween:SetLoops(-1)
end

function CarbonTresaureTemplate:StopCountTime()
    self._layout_objs.auto_start:SetText(config.words[1415])
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

return CarbonTresaureTemplate