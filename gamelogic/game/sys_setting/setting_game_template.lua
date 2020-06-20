local SettingGameTemplate = Class(game.UITemplate)

local _auto_use_cfg = config.sys_config.auto_use_item.value
local _cfg_goods = config.goods

local _pet_skill_list = {16010008, 16010003}

function SettingGameTemplate:OpenViewCallBack()
    self:Init()
end

function SettingGameTemplate:CloseViewCallBack()
    self:SaveSetting()
end

function SettingGameTemplate:Init()
    local auto_use_setting = game.SysSettingCtrl.instance:GetAutoUseSetting()
    for i, v in ipairs(_auto_use_cfg) do
        local goods_item = self:GetTemplate("game/bag/item/goods_item", "item_" .. i)
        local own = game.BagCtrl.instance:GetNumById(v[1])
        goods_item:SetItemInfo({ id = v[1], num = own })
        goods_item:SetShowTipsEnable(true)

        self._layout_objs["slider_" .. i]:AddChangeCallback(function(value)
            self:OnSliderChange(i, value)
        end)

        local check_item = self._layout_objs["check_" .. i]
        local btn_checkbox = check_item:GetChild("btn_checkbox")

        local setting = auto_use_setting[i]
        btn_checkbox:SetSelected(math.floor(setting / 1000) == 1)
        self._layout_objs["slider_" .. i]:SetValue(setting % 1000)
        self._layout_objs["check_" .. i]:SetText(string.format(config.words[4960], setting % 1000, _cfg_goods[v[1]].name))
    end

    self.pet_skill_setting = {}

    for i,v in ipairs(_pet_skill_list) do
        local sk_cfg = config.skill[v][1]

        local item = self:GetTemplate("game/skill/item/skill_item_rect", "sk_" .. i)
        item:SetItemInfo({ id = v, lv = 1 })
        item:SetShowInfo()

        local val = game.SysSettingCtrl.instance:GetLocal(v)
        if val == -1 then
            val = 50 
        end

        self.pet_skill_setting[v] = val

        self._layout_objs["slider_sk" .. i]:AddChangeCallback(function(value)
            self.pet_skill_setting[v] = self.pet_skill_setting[v] // 1000 * 1000 + math.floor(value)
            self._layout_objs["check_sk" .. i]:SetText(string.format(config.words[4961], math.floor(value), sk_cfg.name))
        end)
        self._layout_objs["slider_sk" .. i]:SetValue(val % 1000)

        self._layout_objs["check_sk" .. i .. "/btn_checkbox"]:AddChangeCallback(function(event_type)
            local is_selected = (event_type == game.ButtonChangeType.Selected)
            local tmp_val = is_selected and 0 or 1000
            self.pet_skill_setting[v] = tmp_val + self.pet_skill_setting[v] % 1000
        end)
        self._layout_objs["check_sk" .. i .. "/btn_checkbox"]:SetSelected(val < 1000)
        self._layout_objs["check_sk" .. i]:SetText(string.format(config.words[4961], val % 1000, sk_cfg.name))
    end
end

function SettingGameTemplate:SaveSetting()
    local new_setting = {}
    local setting = 0
    for i = 1, #_auto_use_cfg do
        local check_item = self._layout_objs["check_" .. i]
        local btn_checkbox = check_item:GetChild("btn_checkbox")
        local stat = btn_checkbox:GetSelected() and 1 or 0
        local value = math.floor(self._layout_objs["slider_" .. i]:GetValue())
        if value > 99 then
            value = 99
        elseif value < 1 then
            value = 1
        end
        new_setting[i] = stat * 1000 + value
        setting = (((stat << 7) + value) << (8 * (i - 1))) + setting
    end

    local setting_ctrl = game.SysSettingCtrl.instance

    local auto_use_setting = setting_ctrl:GetAutoUseSetting()
    for i, v in ipairs(new_setting) do
        if v ~= auto_use_setting[i] then
            setting_ctrl:SetInt(game.CommonlyKey.AutoUseItem, setting)
            break
        end
    end
    setting_ctrl:SetAutoUseSetting(new_setting)

    for k,v in pairs(self.pet_skill_setting) do
        global.EventMgr:Fire(game.SkillEvent.PetSkillBloodSettingChange, k, v)
        game.SysSettingCtrl.instance:SaveLocal(k, math.floor(v))
    end
end

function SettingGameTemplate:OnSliderChange(idx, value)
    value = math.floor(value)
    if value > 99 then
        value = 99
    elseif value < 1 then
        value = 1
    end
    local goods_id = _auto_use_cfg[idx][1]
    self._layout_objs["check_" .. idx]:SetText(string.format(config.words[4960], value, _cfg_goods[goods_id].name))
end

return SettingGameTemplate
