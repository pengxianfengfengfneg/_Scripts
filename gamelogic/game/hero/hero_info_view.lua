local HeroInfoView = Class(game.BaseView)

local guild_lv = config.sys_config.hero_active_lv.value
local senior_guild_lv = config.sys_config.hero_active_legend_lv.value
local cfg_hero_lv = config.hero_level
local _active_item = config.sys_config.hero_active_legend.value

function HeroInfoView:_init(ctrl)
    self._package_name = "ui_hero"
    self._com_name = "hero_info_view"
    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function HeroInfoView:OpenViewCallBack(hero_id)
    self:GetFullBgTemplate("bg")
    self.hero_list = self.ctrl:GetHeroInfoList()
    if self.hero_list == nil then
        return
    end

    local list_story = self._layout_objs["list_story"]
    self.txt_story = list_story:GetChildAt(0):GetChild("story")

    self:BindEvent(game.HeroEvent.HeroActive, function(id)
        if self.hero_list[self.cur_index].id == id then
            self:SetHeroInfo(self.cur_index)
        end
    end)

    self:BindEvent(game.HeroEvent.HeroUpgrade, function(id)
        if self.hero_list[self.cur_index].id == id then
            self:SetHeroLevel(id)
        end
    end)

    self:BindEvent(game.HeroEvent.HeroActiveSenior, function(id)
        if self.hero_list[self.cur_index].id == id then
            self:SetSeniorNum(id)
        end
    end)

    self._layout_objs.btn_left:AddClickCallBack(function()
        self:SetHeroInfo(self.cur_index - 1)
    end)

    self._layout_objs.btn_right:AddClickCallBack(function()
        self:SetHeroInfo(self.cur_index + 1)
    end)
    --真武指点激活
    self._layout_objs.btn_active_senior:AddClickCallBack(function()
        self.ctrl:SendHeroActiveSenior(self.hero_list[self.cur_index].id)
    end)
    --获取材料(寻路英雄试炼)
    self._layout_objs.btn_get:AddClickCallBack(function()
        config.goods_get_way[39].click_func()
    end)
    --提升
    self._layout_objs.btn_upgrade:AddClickCallBack(function()
        local info = self.hero_list[self.cur_index]
        self.ctrl:SendHeroUpgrade(info.id, self.select_upgrade_item, 1)
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_hero/hero_info_view/btn_upgrade"})
    end)
    --一键消耗
    self._layout_objs.btn_use:AddClickCallBack(function()
        local info = self.hero_list[self.cur_index]
        local own_num = game.BagCtrl.instance:GetNumById(self.select_upgrade_item)
        if own_num <= 0 then
            own_num = 1
        end
        self.ctrl:SendHeroUpgrade(info.id, self.select_upgrade_item, own_num)
    end)

    self.active_item = self:GetTemplate("game/bag/item/goods_item", "active_item")
    self.active_item:SetShowTipsEnable(true)

    self.upgrade_item1 = self:GetTemplate("game/bag/item/goods_item", "upgrade_item1")
    self.upgrade_item1:AddClickEvent(function()
        local info = self.upgrade_item1:GetItemInfo()
        self.select_upgrade_item = info.id
        self.upgrade_item1:SetSelect(true)
        self.upgrade_item2:SetSelect(false)
    end)

    self.upgrade_item2 = self:GetTemplate("game/bag/item/goods_item", "upgrade_item2")
    self.upgrade_item2:AddClickEvent(function()
        local info = self.upgrade_item2:GetItemInfo()
        self.select_upgrade_item = info.id
        self.upgrade_item1:SetSelect(false)
        self.upgrade_item2:SetSelect(true)
    end)

    self:InitSeniorItemList()
    --self:InitModel()
    self._layout_objs["bar/bar"]:SetSprite("ui_common", "jyt_06")
    self._layout_objs.txt_guide_lv:SetText(string.format(config.words[3103], guild_lv[1], senior_guild_lv[1]))

    for i, v in ipairs(self.hero_list) do
        if v.id == hero_id then
            self:SetHeroInfo(i)
            break
        end
    end

    self.controller = self:GetRoot():GetController("btn_tab")
    self.controller:SetSelectedIndexEx(0)
end

function HeroInfoView:CloseViewCallBack()
    self.cur_index = nil
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function HeroInfoView:OnEmptyClick()
    self:Close()
end

function HeroInfoView:SetHeroInfo(index)
    self.cur_index = index
    self._layout_objs.btn_left:SetVisible(index > 1)
    self._layout_objs.btn_right:SetVisible(#self.hero_list > index)

    local hero_cfg = self.hero_list[index]
    global.AudioMgr:PlayVoice(hero_cfg.sound)
    self.txt_story:SetText(hero_cfg.story)
    self._layout_objs.name_bg:SetSprite("ui_common", "yx_bg" .. hero_cfg.color)
    self.hero_scale = hero_cfg.zoom
    self.hero_offset = hero_cfg.offset
    --self.model:SetModel(game.ModelType.Body, hero_cfg.hero_bg)
    --self.model:PlayAnim(game.ObjAnimName.Show1)
    local bundle_name = "npc_" .. hero_cfg.hero_bg
    local bundle_path = self:GetPackageBundle("npc/" .. bundle_name)
    local asset_name = hero_cfg.hero_bg
    self:SetSpriteAsync(self._layout_objs.hero, bundle_path, bundle_name, asset_name, true)

    local ui_effect = self:CreateUIEffect(self._layout_objs.effect,  string.format("effect/ui/%s.ab",hero_cfg.effect))
    ui_effect:SetLoop(true)

    self._layout_objs.name:SetText(hero_cfg.name)
    self.active_item:SetItemInfo({ id = hero_cfg.card })
    local own_num = game.BagCtrl.instance:GetNumById(hero_cfg.card)
    self._layout_objs.item_name:SetText(config.goods[hero_cfg.card].name .. string.format(config.words[1214], own_num, 1))

    self.upgrade_item1:SetItemInfo({ id = hero_cfg.item_id })

    self._layout_objs.upgrade_text1:SetText(config.words[3101] .. "+" .. hero_cfg.exp)
    local upgrade_item_id = hero_cfg.item_id
    for k, v in pairs(config.hero_item) do
        if v.color == hero_cfg.color then
            upgrade_item_id = k
        end
    end
    self.upgrade_item2:SetItemInfo({ id = upgrade_item_id })

    self._layout_objs.upgrade_text2:SetText(config.words[3101] .. "+" .. config.hero_item[upgrade_item_id].exp)

    local role_career = game.RoleCtrl.instance:GetCareer()
    local skill_id
    for _, v in pairs(hero_cfg.skill) do
        if v[1] == role_career then
            skill_id = v[2]
            break
        end
    end
    self._layout_objs.skill_name:SetText(config.skill[skill_id][1].name)
    self._layout_objs.guide_text:SetText(config.hero_effect[hero_cfg.id][skill_id][0][1].zd_desc .. string.format(config.words[3107], guild_lv[2]))
    local zd_text = ""
    if hero_cfg.legend == 1 then
        zd_text = config.hero_effect[hero_cfg.id][skill_id][0][1].zd_desc
        zd_text = zd_text .. string.format(config.words[3107], senior_guild_lv[2])
    else
        zd_text = config.words[3105]
    end
    self._layout_objs.senior_text:SetText(zd_text)

    self:SetHeroLevel(hero_cfg.id)
    self:SetSeniorNum(hero_cfg.id)
end

function HeroInfoView:SetHeroLevel(id)
    local info = self.ctrl:GetHeroInfo(id)
    self._layout_objs.group_active:SetVisible(info == nil)
    self._layout_objs.group_upgrade:SetVisible(info ~= nil)
    local level, cur_exp = 0, 0
    if info then
        level = info.level
        cur_exp = info.exp
    end
    self._layout_objs.level:SetText(level .. config.words[1217])
    local favor_lv = ""
    for _, v in ipairs(config.hero_favor) do
        if level >= v.level then
            favor_lv = v.name
        end
    end
    self._layout_objs.txt_favor:SetText(favor_lv)
    if level == 0 then
        level = 1
    end
    local level_cfg = cfg_hero_lv[id][level]
    self._layout_objs.bar:SetMax(level_cfg.exp)
    self._layout_objs.bar:SetValue(cur_exp)

    local attr_text = ""
    for i, v in ipairs(level_cfg.attr) do
        attr_text = attr_text .. config.combat_power_battle[v[1]].name .. "+" .. v[2]
        if level < #cfg_hero_lv[id] then
            attr_text = attr_text .. string.format(config.words[3102], cfg_hero_lv[id][level + 1].attr[i][2])
        end
        if i < #level_cfg.attr then
            attr_text = attr_text .. "\n"
        end
    end
    self._layout_objs.attr:SetText(attr_text)

    local item = self.upgrade_item1:GetItemInfo()
    local own_num = game.BagCtrl.instance:GetNumById(item.id)
    self.upgrade_item1:SetNumText(own_num)
    local item2 = self.upgrade_item2:GetItemInfo()
    local own_num2 = game.BagCtrl.instance:GetNumById(item2.id)
    self.upgrade_item2:SetNumText(own_num2)
    if own_num2 > 0 and own_num == 0 then
        self.select_upgrade_item = item2.id
        self.upgrade_item1:SetSelect(false)
        self.upgrade_item2:SetSelect(true)
    else
        self.select_upgrade_item = item.id
        self.upgrade_item1:SetSelect(true)
        self.upgrade_item2:SetSelect(false)
    end
end

function HeroInfoView:InitSeniorItemList()
    self.senior_item_list = self:CreateList("active_item_list", "game/bag/item/goods_item")
    self.senior_item_list:SetRefreshItemFunc(function(item, idx)
        local info = _active_item[idx]
        item:SetItemInfo({id = info[1]})
        local own_num = game.BagCtrl.instance:GetNumById(info[1])
        item:SetNumText(own_num .. "/" .. info[2])
        item:SetShowTipsEnable(true)
    end)
end

function HeroInfoView:SetSeniorNum(id)
    self.senior_item_list:SetItemNum(#_active_item)

    local info = self.ctrl:GetHeroInfo(id)
    if config.hero[id].legend == 1 and info and info.legend == 0 then
        self._layout_objs.group_active_senior:SetVisible(true)
    else
        self._layout_objs.group_active_senior:SetVisible(false)
    end
end

function HeroInfoView:InitModel()
    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.hero, game.BodyType.ModelSp)
    self.model:SetPosition(0, -9.46, 20)
    self.model:SetRotateEnable(false)
    self.model:SetModelChangeCallBack(function()
        self.model:SetScale(self.hero_scale)
        self.model:SetPosition(self.hero_offset[1], self.hero_offset[2], 20)
    end)
end

return HeroInfoView
