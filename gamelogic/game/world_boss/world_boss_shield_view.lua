local WorldBossShieldView = Class(game.BaseView)

local handler = handler
local string_gsub = string.gsub
local string_format = string.format

function WorldBossShieldView:_init(ctrl)
    self._package_name = "ui_world_boss"
    self._com_name = "world_boss_shield_view"

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone

    self.ctrl = ctrl
end

function WorldBossShieldView:OpenViewCallBack(data)
    self:Init(data)


    self:RegisterAllEvents()
end

function WorldBossShieldView:CloseViewCallBack()
    self:Reset()
end

function WorldBossShieldView:Reset()
    self.btn_rand:SetVisible(true)
    self.img_rand:SetVisible(false)
    self.txt_self_rand:SetVisible(false)

    self.txt_top_name:SetText("")
    self.rtx_top_rand:SetText("")
end

function WorldBossShieldView:RegisterAllEvents()
    local events = {
        --{game.WorldBossEvent.UpdateRolldice, handler(self, self.OnRolldiceCallback)},
        {game.WorldBossEvent.UpdateRolldice, handler(self, self.OnUpdateRolldice)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function WorldBossShieldView:Init(data)
    self.roll_id = data.id
    self.reward_id = data.reward
    self.roll_dice_expire_time = data.expire_time


    self.btn_rand = self._layout_objs["btn_rand"]
    self.btn_rand:AddClickCallBack(function()
        self.ctrl:SendRollDiceReq(self.roll_id)
    end)
    
    self.btn_back = self._layout_objs["btn_back"]
    self.btn_back:AddClickCallBack(function()
        self:Close()
    end)

    self.bar_cd = self._layout_objs["bar_cd"]
    self.txt_top_name = self._layout_objs["txt_top_name"]
    self.rtx_top_rand = self._layout_objs["rtx_top_rand"]
    self.txt_cd = self._layout_objs["txt_cd"]

    self.img_rand = self._layout_objs["img_rand"]
    self.txt_self_rand = self._layout_objs["txt_self_rand"]

    self:StartCd()
end

function WorldBossShieldView:OnRolldiceCallback(data)
    self.btn_rand:SetVisible(false)
    self.img_rand:SetVisible(true)

    self.txt_self_rand:SetVisible(true)
    self.txt_self_rand:SetText(data.val)
end

function WorldBossShieldView:OnUpdateRolldice(data)
     --[[
        "id__I",
        "self__U|CltDiceVal|",
        "best__U|CltDiceVal|",
    ]]
    if self.roll_id ~= data.id then
        return
    end

    self.txt_top_name:SetVisible(true)

    -- 最佳
    local best_data = data.best
    self.txt_top_name:SetText(best_data.role_name)
    self.rtx_top_rand:SetText(tostring(best_data.val))

    self:OnRolldiceCallback(data.self)
end

function WorldBossShieldView:StartCd()
    local factor = 30
    local delta_time = (self.roll_dice_expire_time - global.Time:GetServerTimeMs()) * factor
    local counter = delta_time
    
    local start_count = math.floor(counter*(1/factor))
    self.txt_cd:SetText(start_count)

    local seq = DOTween.Sequence()
    seq:AppendCallback(function()
        local val = math.floor(counter*(1/factor))
        if start_count ~= val then
            start_count = val
            self.txt_cd:SetText(val)
        end
        self.bar_cd:SetValue((counter*100/delta_time))
        counter = counter - 1
    end)
    seq:AppendInterval(1/factor)
    seq:OnComplete(function()
        self:Close()
    end)
    seq:SetLoops(math.ceil(delta_time))
    seq:SetAutoKill(true)
end

return WorldBossShieldView
