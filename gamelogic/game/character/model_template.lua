local ModelTemplate = Class()

local config_fashion_color = config.fashion_color

function ModelTemplate:_init()
end

function ModelTemplate:_delete()
    if self.draw_obj then
        game.GamePool.DrawObjPool:Free(self.draw_obj)
        self.draw_obj = nil
    end
    if self.render_image then
        self.render_image:Dispose()
        self.render_image = nil
    end
end

function ModelTemplate:CreateDrawObj(parent, body_type)
    if not self.draw_obj then
        self.draw_obj = game.GamePool.DrawObjPool:Create()
        self.draw_obj:Init(body_type)
        self.draw_obj:SetModelChangeCallBack(function(model_type)            
            self:OnModelChangeCallBack(model_type)
        end)
        self.render_image = parent:SetModel(self.draw_obj.root_obj.obj)
    end
end

function ModelTemplate:SetBodyType(body_type)
    if self.draw_obj then
        self.draw_obj.body_type = body_type
    end
end

function ModelTemplate:SetCameraRotation(x, y, z)
    self.render_image:SetCameraRotation(x, y, z)
end

function ModelTemplate:SetModel(model_type, id)
    self.draw_obj:SetModelID(model_type, id)
end

function ModelTemplate:SetModelVisible(model_type, val)
    self.draw_obj:SetModelVisible(model_type, val)
end

function ModelTemplate:SetPosition(x, y, z)
    self.draw_obj:SetPosition(x, y, z)
end

function ModelTemplate:SetScale(val)
    self.draw_obj:SetScale(val)
end

function ModelTemplate:SetRotation(x, y, z)
    self.draw_obj:SetRotation(x, y, z)
end

function ModelTemplate:SetRotationY(y)
    self.draw_obj:SetRotationY(y)
end

local _anim_fade_time = config.custom.default_anim_fade_time
local _anim_default_layer = game.ModelType.Body
function ModelTemplate:PlayAnim(name, layer, speed, fade_time)
    self.draw_obj:PlayLayerAnim(layer or _anim_default_layer, name or game.ObjAnimName.Idle, speed or 1.0, fade_time or _anim_fade_time)
end

function ModelTemplate:CreateModel(parent, body_type, model_list)
    self:CreateDrawObj(parent, body_type)

    self:SetModelList(model_list)
end

function ModelTemplate:SetModelList(model_list)
    for k,v in pairs(model_list or {}) do
        self:SetModel(k, v)
    end
end

function ModelTemplate:OnModelChangeCallBack(model_type)
    self.draw_obj:SetLayer(game.LayerName.UI)
    self.draw_obj:ExchangeShader(model_type)

    if self.model_change_callback then
        self.model_change_callback(model_type)
    end
end

function ModelTemplate:SetModelChangeCallBack(callback)
    self.model_change_callback = callback
end

function ModelTemplate:UpdateFashion(id, career, color)
    local cfg = config_fashion_color[id]
    if cfg == nil or id == nil then
        return
    end
    local fashion_id = cfg[career][color].fashion_id
    self:SetModel(game.ModelType.Body, fashion_id)
end

function ModelTemplate:UpdateHair(hair_id)
    --self:SetModel(game.ModelType.Hair, hair_id)
end

local property = game.MaterialProperty.Color
function ModelTemplate:UpdateHairColor(r, g, b)
    self.draw_obj:SetMatPropertyColor(property, r/255, g/255, b/255, 1, game.ModelType.Hair)
end

local color_mask = 0xff
function ModelTemplate:UpdateHairColorHex(color)
    local b = color&color_mask
    local g = (color>>8)&color_mask
    local r = (color>>16)&color_mask
    self:UpdateHairColor(r,g,b)
end

function ModelTemplate:SetRotateEnable(val)
    self.render_image:SetRotateEnable(val)
end

function ModelTemplate:SetEffect(hang_node, id, hang_model_type)
    self.draw_obj:SetEffectID(hang_node, id, hang_model_type, true)
end

function ModelTemplate:SetAlwaysAnim(val)
    self.draw_obj:SetAlwaysAnim(val)
end

function ModelTemplate:GetAnimTime(name)
    return self.draw_obj:GetAnimTime(name)
end

return ModelTemplate