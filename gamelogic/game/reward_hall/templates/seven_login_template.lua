local SevenLoginTemplate = Class(game.UITemplate)

local seven_login_config = config.seven_login

function SevenLoginTemplate:_init()
    self._package_name = "ui_reward_hall"
    self._com_name = "seven_login_template"
    self.ctrl = game.RewardHallCtrl.instance
end

function SevenLoginTemplate:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
    self.ctrl:SendSevenLoginInfo()
end

function SevenLoginTemplate:CloseViewCallBack()
    self:ClearModel()
    self.show_model = nil
end

function SevenLoginTemplate:RegisterAllEvents()
    self:BindEvent(game.RewardHallEvent.OnSevenLoginInfo, function(info)
        self.info = info
        self:UpdateLoginList()
        self:Refresh()
    end)
    self:BindEvent(game.RewardHallEvent.OnSevenLoginGet, function(info)
        self:UpdateLoginList()
        self:Refresh()
    end)
end

function SevenLoginTemplate:Init()
    self.img_desc = self._layout_objs.img_desc

    self.list_login = self:CreateList("list_login", "game/reward_hall/item/seven_login_item")
    self.list_login:SetRefreshItemFunc(function(item, idx)
        local item_info = seven_login_config[idx]
        item:SetItemInfo(item_info)
    end)

    self.list_reward = self:CreateList("list_reward", "game/bag/item/goods_item")
    self.list_reward:SetRefreshItemFunc(function(item, idx)
        local item_info = self.reward_list_data[idx]
        item:SetItemInfo({id = item_info[1], num = item_info[2], bind = item_info[3]})
        item:SetShowTipsEnable(true)
    end)

    self.btn_get = self._layout_objs.btn_get
    self.btn_get:AddClickCallBack(function()
        if self.day then
            self.ctrl:SendSevenLoginGet(self.day)
        end
    end)

    local item_num = #seven_login_config
    self.list_login:SetItemNum(item_num)
    self.ctrl_page = self:GetRoot():AddControllerCallback("ctrl_page", function(idx)
        self:OnLoginClick(idx+1)
    end)
    self.ctrl_page:SetPageCount(item_num)
end

function SevenLoginTemplate:OnLoginClick(idx)
    local cfg = seven_login_config[idx]
    self.reward_list_data = config.drop[cfg.reward].client_goods_list
    self.list_reward:SetItemNum(#self.reward_list_data)

    self.img_desc:SetSprite("ui_reward_hall", cfg.desc, true)

    local red = false
    local enable = true

    if idx <= self.info.login_day then
        if self.ctrl:IsGetLoginReward(idx) then
            self.btn_get:SetText(config.words[3062])
            enable = false
        else
            self.btn_get:SetText(config.words[3061])
            red = true
        end
    else
        self.btn_get:SetText(string.format(config.words[3058], idx))
        enable = false
    end

    game.Utils.SetTip(self.btn_get, red, {x=195, y=-11})
    self.btn_get:SetEnable(enable)

    self:UpdateModel(cfg.model, cfg.type, cfg.day)
    self:PlayEffect(cfg.day)

    self.day = idx
end

function SevenLoginTemplate:UpdateLoginList()
    self.list_login:SetItemNum(#seven_login_config)
end

local BodyTypeConfig = {
    [1] = game.BodyType.Monster,
    [2] = game.BodyType.Mount,
}
local ModelTypeConfig = {
    [1] = game.ModelType.Body,
    [2] = game.ModelType.Mount,
}
local ShowConfig = {
    [0] = {x=0, y=0, z=1, rot=180},
    [2] = {x=0, y=-0.8, z=2.11, rot=180},
    [3] = {x=0, y=0, z=3, rot=180},
    [4] = {x=0, y=-0.1, z=1, rot=180},
    [5] = {x=0, y=-0.6, z=3.3, rot=180},
}
local EffectConfig = {
    [1] = {
        name = "ui_seven_gift",
        scale = {1, 1, 1},
    },
    [4] = {
        name = "hd_jinzi",
        hang_node = "tx1",
        rorate = false,
    },
    [6] = {
        name = "hd_shu",
        hang_node = "tx1",
        rorate = false,
    },
    [7] = {
        name = "hd_shuijing",
        hang_node = "tx1",
        rorate = false,
    },
}
function SevenLoginTemplate:UpdateModel(model_id, type, day)
    self:ClearModel()

    if day == 1 then
        return
    end

    local model_type = ModelTypeConfig[type]
    local body_type = BodyTypeConfig[type]
    local anim = game.ObjAnimName.Idle

    if model_type == game.ModelType.Mount then
        local mount_cfg = config.exterior_mount[model_id]
        model_id = mount_cfg.model_id

        if mount_cfg.is_wing == 1 then
            model_type = game.ModelType.WingUI
            body_type = game.BodyType.WingUI
        end

        anim = config_help.ConfigHelpModel.GetMountIdleAnimName(mount_cfg.ani)
    end

    local model_list = {
        [game.ModelType.Body]    = 0,
        [game.ModelType.WingUI]    = 0,
        [game.ModelType.Mount]   = 0,
    }

    model_list[model_type] = model_id

    self.show_model = require("game/character/model_template").New()
    self.show_model:CreateModel(self._layout_objs["wrapper"], body_type, model_list)
    self.show_model:PlayAnim(anim, game.ModelType.Body + game.ModelType.WingUI + game.ModelType.Mount)

    local show_cfg = ShowConfig[day] or ShowConfig[0]
    self.show_model:SetPosition(show_cfg.x, show_cfg.y, show_cfg.z)
    self.show_model:SetRotation(0, show_cfg.rot, 0)
end

function SevenLoginTemplate:ClearModel()
    if self.show_model then
        self.show_model:DeleteMe()
        self.show_model = nil
    end
end

function SevenLoginTemplate:PlayEffect(day)
    self:ClearUIEffect()

    local effect_cfg = EffectConfig[day]
    if self.show_model then
        self.show_model:SetRotateEnable(not effect_cfg or effect_cfg.rorate ~= false)
    end

    if effect_cfg then
        local hang_node = effect_cfg.hang_node
        if hang_node then
            self.show_model:SetModelChangeCallBack(function()
                self.show_model:SetEffect(hang_node, effect_cfg.name, game.ModelType.Body, true)
            end)
        else
            local ui_effect = self:CreateUIEffect(self._layout_objs.effect, string.format("effect/ui/%s.ab", effect_cfg.name))
            ui_effect:SetLoop(true)
            ui_effect:Play()

            local scale = effect_cfg.scale
            ui_effect:SetScale(scale[1], scale[2], scale[3])
        end
    end
end

function SevenLoginTemplate:GetOpenIndex(data)
    local login_day = data.login_day
    local list = data.list
    local day = #seven_login_config + 1
    local dirty = false

    -- 可领取、天数最前标签页
    for k, v in ipairs(seven_login_config) do
        if v.day <= login_day and not self.ctrl:IsGetLoginReward(v.day) then
            if v.day < day then
                day = v.day
                dirty = true
                break
            end
        end
    end

    -- 未领取、天数最前标签页    
    if not dirty then
        for k, v in ipairs(seven_login_config) do
            if not self.ctrl:IsGetLoginReward(v.day) then
                day = v.day
                dirty = true
                break
            end
        end
    end

    if not dirty then
        return 0
    end

    return day
end

function SevenLoginTemplate:Refresh()
    self.info = self.ctrl:GetServerLoginInfo()
    local index = self:GetOpenIndex(self.info)
    if index ~= 0 then
        self.ctrl_page:SetSelectedIndexEx(index-1)
    else
        self.ctrl_page:SetSelectedIndexEx(self.day-1)
    end
end

return SevenLoginTemplate