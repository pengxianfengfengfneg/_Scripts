local PracticeTemplate = Class(game.UITemplate)

local config_skill = config.skill
local config_hero_effect = config.hero_effect

function PracticeTemplate:_init(view)
    self.ctrl = game.GuildCtrl.instance
    self.parent_view = view
end

function PracticeTemplate:OpenViewCallBack()
    self:Init()
    self:InitSkillItems()
    self:RegisterAllEvents()
    self.ctrl:SendGuildPracticeInfo()
end

function PracticeTemplate:CloseViewCallBack()
	self:SetSelect()
end

function PracticeTemplate:RegisterAllEvents()
    local events = {
    	{game.GuildEvent.UpdatePracticeInfo, function(info)
            self.info = info
            self:OnUpdatePracticeInfo()
        end},
        {game.MoneyEvent.Change, function(change_list)
            if change_list[game.MoneyType.GuildCont] or change_list[game.MoneyType.Exp] then
                self:UpdateSkillItems()
                self:UpdateCostText()
            end
        end},
        {game.RoleEvent.LevelChange, function()
            self:UpdateSkillItems()
            self:UpdateCostText()
            self:UpdateInfoText()
        end},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function PracticeTemplate:Init()
    self.txt_level_info = self._layout_objs["txt_level_info"]
    self.txt_bottom_info = self._layout_objs["txt_bottom_info"]
    self.txt_cost1 = self._layout_objs["txt_cost1"]
    self.txt_cost2 = self._layout_objs["txt_cost2"]
    self.txt_cost3 = self._layout_objs["txt_cost3"]
    self.txt_cost4 = self._layout_objs["txt_cost4"]

    self.txt_attr = self._layout_objs["txt_attr"]
    self.txt_cur_lv = self._layout_objs["txt_cur_lv"]
    self.txt_next_lv = self._layout_objs["txt_next_lv"]
    self.txt_cur_val = self._layout_objs["txt_cur_val"]
    self.txt_next_val = self._layout_objs["txt_next_val"]

    self.btn_practice = self._layout_objs["btn_practice"]
    self.btn_practice:SetText(config.words[2780])
    self.btn_practice:AddClickCallBack(handler(self, self.OnPractice))
    
    self._layout_objs["img_money1"]:SetSprite("ui_item", config.goods[game.MoneyGoodsId[game.MoneyType.GuildCont]].icon)
    self._layout_objs["img_money2"]:SetSprite("ui_item", config.goods[game.MoneyGoodsId[game.MoneyType.GuildCont]].icon)
    self._layout_objs["img_money3"]:SetSprite("ui_item", config.goods[game.MoneyGoodsId[game.MoneyType.Exp]].icon)
    self._layout_objs["img_money4"]:SetSprite("ui_item", config.goods[game.MoneyGoodsId[game.MoneyType.Exp]].icon)
end

function PracticeTemplate:InitSkillItems()
    for i=1, 10 do
        local item = self:GetTemplate("game/skill/item/skill_item_circle", "skill_item_" .. i)
        item:ResetItem()
        item:AddClickEvent(function()
            if self.select_index then
                self["skill_item_" .. self.select_index]:DoSelected(false)
            end
            self:SetSelect(i)
            self:UpdateAttrInfo()
            self:UpdateCostText()
        end)
        self["skill_item_" .. i] = item
    end

    self:SetSelect(1)
end

function PracticeTemplate:SetSelect(index)
    if self.select_index and self.select_index ~= index then
        self["skill_item_" .. self.select_index]:DoSelected(false)
    end
    if index then
        self["skill_item_" .. index]:DoSelected(true)
    end
    self.select_index = index
    self:UpdateRedPoint()
end

function PracticeTemplate:UpdateSkillItems()
    if self.info then 
        self.info.practice_skill = game.Utils.SortByField(self.info.practice_skill, 'id')
        for k, v in ipairs(self.info.practice_skill) do
            local item = self["skill_item_" .. v.id]
            local skill_cfg = config.guild_practice[v.id][v.lv]

            item:SetSkillIcon(skill_cfg.icon)
            item:SetShowLv(true,  v.lv)
            item:SetShowLvUp(self.ctrl:CanSkillUpPracticeSkill(v.id, v.lv))
        end
    end 
end

function PracticeTemplate:UpdateAttrInfo()
    self.select_index = self.select_index or 1
    if not self.info then return end

    local pct_data = self.info.practice_skill[self.select_index]
    self.cur_pct_cfg = config.guild_practice[pct_data.id][pct_data.lv]
    self.next_pct_cfg = config.guild_practice[pct_data.id][pct_data.lv + 1]

    self.cur_attr_data =  self.cur_pct_cfg and self.cur_pct_cfg.attr or {}
    self.next_attr_data = self.next_pct_cfg and self.next_pct_cfg.attr or nil

    self.txt_cur_lv:SetText(string.format(config.words[2221], self.cur_pct_cfg.lv))
    self.txt_next_lv:SetText(self.next_pct_cfg and string.format(config.words[2221], self.next_pct_cfg.lv) or config.words[2786])

    local type = self.cur_attr_data[1][1]    
    local name = type > 100 and config.combat_power_base[type - 100].name or config.combat_power_battle[type].name
    local next_val_words = self.next_attr_data and self:NumberFormat(self.next_attr_data[1][2] / 100) .. "%" or config.words[2786]
    self.txt_attr:SetText(string.format(config.words[2222], name))
    self.txt_cur_val:SetText(self:NumberFormat(self.cur_attr_data[1][2] / 100) .. "%")
    self.txt_next_val:SetText(next_val_words)
end

function PracticeTemplate:UpdateCostText()
    if self.cur_pct_cfg then
        self.txt_cost1:SetText(self:GetGuildContCost(self.cur_pct_cfg.cost_cont))
        self.txt_cost3:SetText(self.cur_pct_cfg.cost_exp)
    else
        self.txt_cost1:SetText(config.words[2786])
        self.txt_cost3:SetText(config.words[2786])
    end
    self.txt_cost2:SetText(game.BagCtrl.instance:GetMoneyByType(game.MoneyType.GuildCont))
    self.txt_cost4:SetText(game.RoleCtrl.instance:GetRoleExp())
end

function PracticeTemplate:UpdateInfoText()
    local role_level = game.RoleCtrl.instance:GetRoleLevel()
    local max_lv = self.ctrl:GetRealPracticeMaxLv()

    self.txt_level_info:SetText(string.format(config.words[2224], max_lv))

    local need_practice_idx = self:GetNeedPracticeIndex()
    local bottom_text = need_practice_idx and string.format(config.words[2223], config.level[need_practice_idx].is_need_practice, need_practice_idx + 1) or ""
    self.txt_bottom_info:SetText(bottom_text)
end

function PracticeTemplate:UpdateRedPoint()
    self.select_index = self.select_index or 1
    local visible = false
    if self.info then 
        local skill_data = self.info.practice_skill[self.select_index]
        visible = self.ctrl:CanSkillUpPracticeSkill(skill_data.id, skill_data.lv)
    end
    game.Utils.SetTip(self.btn_practice, visible, cc.vec2(193, -7))
end

function PracticeTemplate:GetNeedPracticeIndex()
    local lv = game.RoleCtrl.instance:GetRoleLevel()
    local lv_cfg = config.level

    while lv_cfg[lv] ~= nil and lv_cfg[lv].is_need_practice == 0 do
        lv = lv + 1
    end
    if lv_cfg[lv] then
        return lv
    end
end

function PracticeTemplate:OnUpdatePracticeInfo()
    self:UpdateSkillItems()
    self:UpdateAttrInfo()
    self:UpdateCostText()
    self:UpdateInfoText()
    self:UpdateRedPoint()
end

function PracticeTemplate:OnPractice()
    if self.info then
        local id = self.info.practice_skill[self.select_index].id
        local lv = self.info.practice_skill[self.select_index].lv
        local max_lv = self.ctrl:GetRealPracticeMaxLv()
        if lv == max_lv then
            game.GameMsgCtrl.instance:PushMsgCode(5401)
        else
            self.ctrl:SendGuildPracticeUp(id)
        end
    end
end

function PracticeTemplate:NumberFormat(val)
    local integer, decimal = math.modf(val)
    if decimal > 0 then
        return val
    else
        return integer
    end
end

function PracticeTemplate:GetGuildContCost(cost_cont)
    local skill_effect = game.GuildCtrl.instance:GetResearchEffect(1001)
    local cost = math.max(0, cost_cont - skill_effect)
    return cost
end

function PracticeTemplate:CheckRedPoint()
    
end

return PracticeTemplate
