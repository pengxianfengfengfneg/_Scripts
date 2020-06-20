local GuildDefendTripodItem = Class(game.UITemplate)

local _table_insert = table.insert

function GuildDefendTripodItem:_init(ctrl)
    self.ctrl = ctrl
end

function GuildDefendTripodItem:_delete()

end

function GuildDefendTripodItem:OpenViewCallBack()
    self:Init()
    self:GetRoot():AddClickCallBack(handler(self, self.OnClick))
end

function GuildDefendTripodItem:CloseViewCallBack()

end

function GuildDefendTripodItem:Init()
    self.img_red = self._layout_objs["img_red"]
    self.txt_info = self._layout_objs["txt_info"]
    self.img_name = self._layout_objs["img_name"]
    self.img_effect = self._layout_objs["img_effect"]
    
    self.effect = self:GetRoot():GetTransition("t0")
    self.max_hp = 100
end

function GuildDefendTripodItem:SetItemInfo(item_info)
    self:SetHp(item_info.hp or self.max_hp)
    self:SetTripodId(item_info.id)
    if item_info.sprite then
        self.img_name:SetSprite("ui_guild", item_info.sprite, true)
    end
end

function GuildDefendTripodItem:SetHp(hp)
    self.img_red:SetFillAmount(hp / self.max_hp)
end

function GuildDefendTripodItem:SetInfo(info)
    self.txt_info:SetText(info)
end

function GuildDefendTripodItem:SetTripodId(id)
    self.tripod_id = id
end

function GuildDefendTripodItem:PlayEffect()
    self.effect:Stop()
    self.effect:Play()
end

function GuildDefendTripodItem:GetTripodId()
    return self.tripod_id
end

function GuildDefendTripodItem:OnClick()
    local main_role = game.Scene.instance:GetMainRole()
    local tripod_info = self:GetTripodInfo()
    if tripod_info then
        local unit_x, unit_y = game.LogicToUnitPos(tripod_info.x, tripod_info.y)
        local dist = 2
        main_role:GetOperateMgr():DoGoToScenePos(main_role.scene:GetSceneID(), unit_x, unit_y, function()
            main_role:GetOperateMgr():DoSceneHang()
        end, dist)
    end
end

function GuildDefendTripodItem:GetTripodInfo()
    if self.tripod_info then
        return self.tripod_info
    else
        for glv, list in pairs(config.guild_defend_tripod) do
            for id, tripod in pairs(list) do
                if tripod.mon_id == self.tripod_id then
                    self.tripod_info = tripod
                    return tripod
                end
            end
        end
    end
end

return GuildDefendTripodItem