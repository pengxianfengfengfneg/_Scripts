local GodEquipCtrl = Class(game.BaseCtrl)


function GodEquipCtrl:_init()
    if GodEquipCtrl.instance ~= nil then
        error("GodEquipCtrl Init Twice!")
    end
    GodEquipCtrl.instance = self

    self.god_equip_view = require("game/god_equip/god_equip_view").New(self)
    self.resonance_view = require("game/god_equip/resonance_view").New(self)

    self:RegisterAllProtocal()
end

function GodEquipCtrl:_delete()
    self.god_equip_view:DeleteMe()
    self.resonance_view:DeleteMe()

    GodEquipCtrl.instance = nil
end

function GodEquipCtrl:RegisterAllProtocal()
    -- self:RegisterProtocalCallback(20212, "OnGodEquipWash")
    -- self:RegisterProtocalCallback(20214, "OnGodEquipUpgrade")
end

function GodEquipCtrl:OpenView()
    self.god_equip_view:Open()
end

function GodEquipCtrl:OpenResonanceView()
    self.resonance_view:Open()
end

function GodEquipCtrl:SendGodEquipWash(type, pos)
    --    类型（1 种类; 2 属性）
    self:SendProtocal(20211, { type = type, pos = pos })
end

function GodEquipCtrl:OnGodEquipWash(data_list)
    local equip_info = game.FoundryCtrl.instance:GetEquipInfo()
    if equip_info then
        for i, v in pairs(equip_info.equips) do
            if v.equip.pos == data_list.pos then
                v.equip.god = data_list.attr
                break
            end
        end
        game.FoundryCtrl.instance:SetEquipInfo(equip_info)
    end
    self:FireEvent(game.RoleEvent.GodEquipWash, data_list)
end

function GodEquipCtrl:SendGodEquipUpgrade(pos, wash)
    self:SendProtocal(20213, { pos = pos, refresh = wash })
end

function GodEquipCtrl:OnGodEquipUpgrade(data_list)
    local equip_info = game.FoundryCtrl.instance:GetEquipInfo()
    if equip_info then
        for i, v in pairs(equip_info.equips) do
            if v.equip.pos == data_list.equip.pos then
                v.equip = data_list.equip
                break
            end
        end
        game.FoundryCtrl.instance:SetEquipInfo(equip_info)
    end
    self:FireEvent(game.RoleEvent.GodEquipUpgrade, data_list)
end

function GodEquipCtrl:CheckRedPoint()
    
    return false
end

game.GodEquipCtrl = GodEquipCtrl

return GodEquipCtrl