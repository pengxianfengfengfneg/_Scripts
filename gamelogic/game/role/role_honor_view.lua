local HonorView = Class(game.BaseView)

local base_attr = config.combat_power_base
local bt_attr = config.combat_power_battle
local honor_cfg = config.title_honor
local _carbon_id = 550
local _dun_cfg = config.dungeon_lv[_carbon_id]

function HonorView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "honor_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
end

function HonorView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[3201])
    self:InitBtns()

    self.cost_item = self:GetTemplate("game/bag/item/goods_item", "item")
    self.cost_item:SetShowTipsEnable(true)
    self.controller = self:GetRoot():GetController("c1")
    self.honor_sort_cfg = {}
    for _, v in pairs(honor_cfg) do
        table.insert(self.honor_sort_cfg, v)
    end
    table.sort(self.honor_sort_cfg, function(a, b)
        return a.level < b.level
    end)

    local dunge_data = game.CarbonCtrl.instance:GetData()
    local hero_dun_data = dunge_data:GetDungeDataByID(_carbon_id)
    local max_lv = hero_dun_data.max_lv
    if max_lv > #_dun_cfg then
        max_lv = #_dun_cfg
        self._layout_objs.name:SetText(_dun_cfg[max_lv].name)
    else
        if max_lv == 0 then
            self._layout_objs.name:SetText(config.words[1552])
        else
            max_lv = max_lv - 1
            self._layout_objs.name:SetText(_dun_cfg[max_lv].name)
        end
    end

    self.top_honor_cfg = 0
    for _, v in ipairs(self.honor_sort_cfg) do
        if max_lv >= v.cond then
            self.top_honor_cfg = v
        else
            break
        end
    end

    self:BindEvent(game.RoleEvent.HonorUpgrade, function()
        self:UpdateView()
    end)

    self:UpdateView()
end

function HonorView:OnEmptyClick()
    self:Close()
end

function HonorView:InitBtns()
    self._layout_objs.btn_hero:AddClickCallBack(function()
        config.goods_get_way[39].click_func()
    end)

    self._layout_objs.btn_preview:AddClickCallBack(function()
        self.ctrl:OpenHonorPreview()
    end)

    self._layout_objs.btn_upgrade:AddClickCallBack(function()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_role/honor_view/btn_upgrade"})
        self.ctrl:SendHonorUpgrade()
    end)

    self._layout_objs.btn_dian:AddClickCallBack(function()
    end)
end

function HonorView:UpdateView()

    local honor_id = self.ctrl:GetRoleHonor()
    local career = self.ctrl:GetCareer()
    self._layout_objs.text1:SetVisible(honor_id == 0)
    self._layout_objs.text2:SetVisible(false)
    self._layout_objs.text3:SetVisible(honor_id == 0)
    self._layout_objs.text4:SetVisible(honor_id == 0)
    self._layout_objs.text5:SetVisible(false)
    self._layout_objs.cur_honor:SetVisible(true)
    self._layout_objs.next_honor:SetVisible(true)
    self._layout_objs.top_honor:SetVisible(true)
    local cost_num = 0
    local cost_id = 0
    if honor_id == 0 then
        local next_honor = self.honor_sort_cfg[1]
        self._layout_objs.condition:SetText(config.words[3203] .. next_honor.desc)
        self._layout_objs.next_honor:SetSprite("ui_title", next_honor.icon, true)
        self._layout_objs.cur_honor:SetVisible(false)
        if self.top_honor_cfg == 0 then
            self._layout_objs.top_honor:SetVisible(false)
        else
            self._layout_objs.text3:SetVisible(false)
            self._layout_objs.top_honor:SetSprite("ui_title", self.top_honor_cfg.icon, true)
        end
        self._layout_objs.l_addition:SetText("")
        if next_honor.addition > 0 then
            self._layout_objs.r_addition:SetText(string.format(config.words[3205], cc.GoodsColor2[next_honor.color], next_honor.name, next_honor.addition))
        else
            self._layout_objs.r_addition:SetText("")
        end
        local attr = {}
        local career_attr = next_honor.career_attr[career]
        table.insert(attr, {career_attr[2], career_attr[3]})
        for _, v in ipairs(next_honor.attr) do
            table.insert(attr, v)
        end
        for i = 1, 4 do
            self._layout_objs["l_attr_" .. i]:SetText("")
            self._layout_objs["l_value_" .. i]:SetText("")

            local key = attr[i][1]
            if key > 100 then
                self._layout_objs["r_attr_" .. i]:SetText(base_attr[key - 100].name)
            else
                self._layout_objs["r_attr_" .. i]:SetText(bt_attr[key].name)
            end
            self._layout_objs["r_value_" .. i]:SetText(attr[i][2])
        end
    elseif honor_cfg[honor_id].level == table.nums(honor_cfg) then
        self._layout_objs.text2:SetVisible(true)
        self._layout_objs.text5:SetVisible(true)
        self._layout_objs.next_honor:SetVisible(false)
        local cur_honor = honor_cfg[honor_id]
        self._layout_objs.cur_honor:SetSprite("ui_title", cur_honor.icon, true)
        self._layout_objs.top_honor:SetSprite("ui_title", cur_honor.icon, true)
        self._layout_objs.condition:SetText(config.words[3204])
        self._layout_objs.r_addition:SetText("")
        if cur_honor.addition > 0 then
            self._layout_objs.l_addition:SetText(string.format(config.words[3205], cc.GoodsColor2[cur_honor.color], cur_honor.name, cur_honor.addition))
        else
            self._layout_objs.l_addition:SetText("")
        end
        local attr = {}
        local career_attr = cur_honor.career_attr[career]
        table.insert(attr, {career_attr[2], career_attr[3]})
        for _, v in ipairs(cur_honor.attr) do
            table.insert(attr, v)
        end
        for i = 1, 4 do
            self._layout_objs["r_attr_" .. i]:SetText("")
            self._layout_objs["r_value_" .. i]:SetText("")

            local key = attr[i][1]
            if key > 100 then
                self._layout_objs["l_attr_" .. i]:SetText(base_attr[key - 100].name)
            else
                self._layout_objs["l_attr_" .. i]:SetText(bt_attr[key].name)
            end
            self._layout_objs["l_value_" .. i]:SetText(attr[i][2])
        end
    else
        local cur_honor = honor_cfg[honor_id]
        local next_honor = self.honor_sort_cfg[cur_honor.level + 1]
        cost_num = next_honor.num
        cost_id = next_honor.cost
        self._layout_objs.condition:SetText(config.words[3203] .. next_honor.desc)
        self._layout_objs.cur_honor:SetSprite("ui_title", cur_honor.icon, true)
        self._layout_objs.top_honor:SetSprite("ui_title", self.top_honor_cfg.icon, true)
        self._layout_objs.next_honor:SetSprite("ui_title", next_honor.icon, true)
        if cur_honor.addition > 0 then
            self._layout_objs.l_addition:SetText(string.format(config.words[3205], cc.GoodsColor2[cur_honor.color], cur_honor.name, cur_honor.addition))
        else
            self._layout_objs.l_addition:SetText("")
        end
        if next_honor.addition > 0 then
            self._layout_objs.r_addition:SetText(string.format(config.words[3205], cc.GoodsColor2[next_honor.color], next_honor.name, next_honor.addition))
        else
            self._layout_objs.r_addition:SetText("")
        end
        local attr = {}
        local career_attr = cur_honor.career_attr[career]
        table.insert(attr, {career_attr[2], career_attr[3]})
        for _, v in ipairs(cur_honor.attr) do
            table.insert(attr, v)
        end
        local next_attr = {}
        career_attr = next_honor.career_attr[career]
        table.insert(next_attr, {career_attr[2], career_attr[3]})
        for _, v in ipairs(next_honor.attr) do
            table.insert(next_attr, v)
        end
        for i = 1, 4 do
            local key = attr[i][1]
            if key > 100 then
                self._layout_objs["l_attr_" .. i]:SetText(base_attr[key - 100].name)
            else
                self._layout_objs["l_attr_" .. i]:SetText(bt_attr[key].name)
            end
            self._layout_objs["l_value_" .. i]:SetText(attr[i][2])

            key = next_attr[i][1]
            if key > 100 then
                self._layout_objs["r_attr_" .. i]:SetText(base_attr[key - 100].name)
            else
                self._layout_objs["r_attr_" .. i]:SetText(bt_attr[key].name)
            end
            self._layout_objs["r_value_" .. i]:SetText(next_attr[i][2])
        end
    end

    if cost_num == 0 then
        self.controller:SetSelectedIndexEx(0)
    else
        self.controller:SetSelectedIndexEx(1)
        local own = game.BagCtrl.instance:GetNumById(cost_id)
        self.cost_item:SetItemInfo({ id = cost_id })
        self.cost_item:SetNumText(own .. "/" .. cost_num)
    end

    game.Utils.SetTip(self._layout_objs.btn_upgrade, self.ctrl:GetHonorTipState(), {x = 190, y = -9})
end

return HonorView
