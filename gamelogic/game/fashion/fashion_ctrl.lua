local FashionCtrl = Class(game.BaseCtrl)

local event_mgr = global.EventMgr

function FashionCtrl:_init()
    if FashionCtrl.instance ~= nil then
        error("FashionCtrl Init Twice!")
    end
    FashionCtrl.instance = self

    self.view = require("game/fashion/fashion_view").New(self)
    self.color_view = require("game/fashion/fashion_color_view").New(self)
    self.data = require("game/fashion/fashion_data").New(self)

    self:RegisterAllEvents()
    self:RegisterAllProtocal()
end

function FashionCtrl:_delete()
    self.view:DeleteMe()
    self.data:DeleteMe()

    self.color_view:DeleteMe()

    FashionCtrl.instance = nil
end

function FashionCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginSuccess, function()
            self:SendFashionGetInfo()
        end},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function FashionCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(40702, "OnFashionGetInfo")
    self:RegisterProtocalCallback(40704, "OnFashionActivate")
    self:RegisterProtocalCallback(40706, "OnFashionWear")
    self:RegisterProtocalCallback(40708, "OnFashionDyeing")
    self:RegisterProtocalCallback(40709, "OnFashionExpire")
    self:RegisterProtocalCallback(40712, "OnHairSwitch")
end

function FashionCtrl:OpenView(open_index)
    self.view:Open(open_index)
end

function FashionCtrl:CloseView()
    self.view:Close()
end

function FashionCtrl:OpenColorView(fashion_id)
    self.color_view:Open(fashion_id)
end

function FashionCtrl:CloseColorView()
    self.color_view:Close()
end

function FashionCtrl:SendFashionGetInfo()
    local proto = {

    }
    self:SendProtocal(40701, proto)
end

function FashionCtrl:OnFashionGetInfo(data)
    --[[
        "current__I",
        "fashions__T__id@H##colors@H##time@I",
    ]]
    ----PrintTable(data)

    self.data:OnFashionGetInfo(data)
end

function FashionCtrl:SendFashionActivate(id)
    local proto = {
        id = id,
    }
    self:SendProtocal(40703, proto)
end

function FashionCtrl:OnFashionActivate(data)
    --[[
        "id__H",
        "colors__H",
        "exp_time__I",
    ]]
    --PrintTable(data)
    
    self.data:OnFashionActivate(data)

    self:FireEvent(game.FashionEvent.ActiveFashion, data.id, data.colors)
end

function FashionCtrl:SendFashionWear(id, color)
    local proto = {
        id = (id<<16)+(1<<((color or 1)-1)),
    }
    self:SendProtocal(40705, proto)
end

function FashionCtrl:OnFashionWear(data)
    --[[
        "id__I",
    ]]
    --PrintTable(data)
    self.data:OnFashionWear(data)

    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        main_role:RefreshFashion(data.id)
    end

    self:FireEvent(game.FashionEvent.WearFashion, data.id)
end

function FashionCtrl:SendFashionDyeing(id)
    local proto = {
        id = id,
    }
    self:SendProtocal(40707, proto)
end

function FashionCtrl:OnFashionDyeing(data)
    --[[
        "id__H",
        "dyeing__H",
    ]]

    --PrintTable(data)
    
    local old_colors = self:GetFashionColors(data.id)
    self.data:OnFashionDyeing(data)

    self:FireEvent(game.FashionEvent.DyeingFashion, data.id, data.dyeing, old_colors)
end

function FashionCtrl:OnFashionExpire(data)
    --[[
        "current__I",
        "expires__id@H",
    ]]
    --PrintTable(data)
    self.data:OnFashionExpire(data)
end

function FashionCtrl:SendHairSwitch(id)
    local proto = {
        id = id,
    }
    self:SendProtocal(40711, proto)
end

function FashionCtrl:OnHairSwitch(data)
    --[[
        "id__I",
    ]]
    --PrintTable(data)
    self.data:OnHairSwitch(data)

    self:FireEvent(game.FashionEvent.SwithHairId, data.id)
end

function FashionCtrl:OnHairChange(data)
    --[[
        "role_id__L",
        "id__I",
    ]]
    PrintTable(data)
    self.data:OnHairChange(data)

    self:FireEvent(game.FashionEvent.ChangeHair, data.role_id, data.id)
end

function FashionCtrl:GetFashionInfo(id)
    return self.data:GetFashionInfo(id)
end

function FashionCtrl:GetFashionColors(id)
    return self.data:GetFashionColors(id)
end

function FashionCtrl:IsFashionActived(id)
    return self.data:IsFashionActived(id)
end

function FashionCtrl:IsFashionWeared(id)
    return self.data:IsFashionWeared(id)
end

function FashionCtrl:IsColorActived(id, color)
    return self.data:IsColorActived(id, color)
end

function FashionCtrl:IsColorUsed(id, color)
    return self.data:IsColorUsed(id, color)
end

function FashionCtrl:IsAllColorActived(id)
    return self.data:IsAllColorActived(id)
end

function FashionCtrl:IsHairUsed(id)
    return self.data:IsHairUsed(id)
end

local color_mask = 0xffff
function FashionCtrl:ParseFashionValue(fashion_val)
    local fashion_id = (fashion_val>>16)
    local colors = (fashion_val&color_mask)
    local color_tmp = colors
    
    local color_idx = 0
    if color_tmp > color_idx then
        for i=1,16 do
            color_tmp = color_tmp>>1
            color_idx = color_idx + 1       
            if color_tmp <= 0 then
                break
            end            
        end
    end
    return fashion_id, color_idx
end

function FashionCtrl:GetFashionColorActivedNum(id)
    return self.data:GetFashionColorActivedNum(id)
end

function FashionCtrl:CheckRedPoint()
    
    return self.data:CheckRedPoint()
end

function FashionCtrl:RemoveNewActionFashionState(id)
    self.data:RemoveNewActionFashionState(id)
end

function FashionCtrl:GetAllFashionNewActionState()
    return self.data:GetAllFashionNewActionState()
end

function FashionCtrl:GetFashionNewActionState(id)
    return self.data:GetFashionNewActionState(id)
end

game.FashionCtrl = FashionCtrl

return FashionCtrl