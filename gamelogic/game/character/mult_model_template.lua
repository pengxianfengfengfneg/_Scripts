local MultModelTemplate = Class()

function MultModelTemplate:_init(graph)
    self.objs = {}
    self.render_image = graph:GetRenderImage()
end

function MultModelTemplate:_delete()
    for _, v in pairs(self.objs) do
        game.GamePool.DrawObjPool:Free(v)
        self.objs = nil
    end
    if self.render_image then
        self.render_image:Dispose()
        self.render_image = nil
    end
end

function MultModelTemplate:CreateModel(body_types, model_list)
    for _, body_type in ipairs(body_types) do
        local draw_obj = game.GamePool.DrawObjPool:Create()
        draw_obj:Init(body_type)
        draw_obj:SetModelChangeCallBack(function(model_type)
            draw_obj:SetLayer(game.LayerName.UI)
            draw_obj:ExchangeShader(model_type)
        end)
        table.insert(self.objs, draw_obj)
        self.render_image:LoadModel(draw_obj.root_obj.obj)
    end

    if model_list then
        self:SetModel(model_list)
    end
end

function MultModelTemplate:SetModel(model_list)
    for i, model_type in ipairs(model_list) do
        local model = self:GetModel(i)
        if model then
            for k, v in pairs(model_type) do
                model:SetModelID(k, v)
            end
        end
    end
end

local _anim_fade_time = config.custom.default_anim_fade_time
local _anim_default_layer = game.ModelType.Body
function MultModelTemplate:PlayAnim(anim_list)
    for i, v in ipairs(anim_list) do
        local model = self:GetModel(i)
        if model then
            model:PlayLayerAnim(v.layer or _anim_default_layer, v.name or game.ObjAnimName.Idle, v.speed or 1.0, v.fade_time or _anim_fade_time, true)
        end
    end
end

function MultModelTemplate:GetModel(index)
    return self.objs[index]
end

function MultModelTemplate:SetPosition(x, y, z)
    self.render_image.modelRoot:SetPosition(x, y, z)
end

function MultModelTemplate:SetRotateEnable(val)
    self.render_image:SetRotateEnable(val)
end

return MultModelTemplate