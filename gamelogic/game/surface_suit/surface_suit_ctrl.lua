local SurfaceSuitCtrl = Class(game.BaseCtrl)

local event_mgr = global.EventMgr

function SurfaceSuitCtrl:_init()
    if SurfaceSuitCtrl.instance ~= nil then
        error("SurfaceSuitCtrl Init Twice!")
    end
    SurfaceSuitCtrl.instance = self

    self.view = require("game/surface_suit/surface_suit_view").New(self)
    self.data = require("game/surface_suit/surface_suit_data").New(self)

    self.attr_view = require("game/surface_suit/surface_suit_attr_view").New(self)

    self:RegisterAllEvents()
    self:RegisterAllProtocal()
end

function SurfaceSuitCtrl:_delete()
    self.view:DeleteMe()
    self.data:DeleteMe()

    self.attr_view:DeleteMe()

    SurfaceSuitCtrl.instance = nil
end

function SurfaceSuitCtrl:RegisterAllEvents()
    local events = {
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SurfaceSuitCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(41702, "OnSurfaceInfo")
    self:RegisterProtocalCallback(41703, "OnSurfaceChange")


end

function SurfaceSuitCtrl:OpenView(open_index)
    self.view:Open(open_index)
end

function SurfaceSuitCtrl:CloseView()
    self.view:Close()
end

function SurfaceSuitCtrl:OpenSuitAttrView(id)
    self.attr_view:Open(id)
end

function SurfaceSuitCtrl:SendGetSurfaceInfo()
    local proto = {

    }
    -- PrintTable(proto)
    self:SendProtocal(41701, proto)
end

function SurfaceSuitCtrl:OnSurfaceInfo(data)
    --[[
        "surfaces__T__surface@U|CltSurface|",

        proto.CltSurface = {
                "id__C",
                "num__C",
                "fashion__H",
                "mount__H",
                "wing__H",
                "god__H",
        }
    ]]
    -- PrintTable(data)

    self.data:OnSurfaceInfo(data)
end

function SurfaceSuitCtrl:OnSurfaceChange(data)
    --[[
        "surfaces__T__surface@U|CltSurface|",
    ]]
    -- PrintTable(data)
    
    self.data:OnSurfaceChange(data)
end

function SurfaceSuitCtrl:CheckRedPoint()
    
    return self.data:CheckRedPoint()
end

function SurfaceSuitCtrl:GetSuitInfo(id)
    return self.data:GetSuitInfo(id)
end

function SurfaceSuitCtrl:IsMountActived(id)
    return self.data:IsMountActived(id)
end

function SurfaceSuitCtrl:IsFashionActived(id)
    return self.data:IsFashionActived(id)
end

function SurfaceSuitCtrl:IsWingActived(id)
    return self.data:IsWingActived(id)
end

function SurfaceSuitCtrl:IsWeaponActived(id)
    return self.data:IsWeaponActived(id)
end

function SurfaceSuitCtrl:CalcSuitPower(id)
    return self.data:CalcSuitPower(id)
end

game.SurfaceSuitCtrl = SurfaceSuitCtrl

return SurfaceSuitCtrl