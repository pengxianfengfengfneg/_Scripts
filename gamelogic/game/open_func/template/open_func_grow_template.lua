local OpenFuncGrowTemplate = Class(game.UITemplate)

-- 2001 坐骑
-- 2002 翅膀
-- 2003 神器
-- 2004 附体
-- 2005 悟性
-- 2008 背饰
-- 2009 名号
-- 2010 小师妹
-- 2011 魅力
-- 2012 灵器
-- 2013 发簪

local model_type = {
    [2001] = game.ModelType.Mount,
    [2002] = game.ModelType.WingUI,
    [2003] = game.ModelType.WeaponUI,
    [2008] = game.ModelType.BeiShiUI,
    [2013] = game.ModelType.FaZanUI,
}
local body_type = {
    [2001] = game.BodyType.Mount,
    [2002] = game.BodyType.WingUI,
    [2003] = game.BodyType.WeaponUI,
    [2008] = game.BodyType.BeiShiUI,
    [2013] = game.BodyType.FaZanUI,
}
local HangNodeType = {
    [2002] = true,
    [2003] = true,
    [2008] = true,
    [2013] = true,
}
local model_pos = {
    [2001] = cc.vec3(0, -1.2, 5.3),
    [2002] = cc.vec3(0, 0, 3),
    [2003] = cc.vec3(0, 0, 3),
    [2008] = cc.vec3(0, 0, 3),
    [2013] = cc.vec3(0, 0, 1.5),
}
local model_rotate = {
    [2001] = cc.vec3(0, 92, 0),
    [2002] = cc.vec3(0, 180, 0),
    [2003] = cc.vec3(0, 100, 0),
    [2008] = cc.vec3(0, 45, 0),
    [2013] = cc.vec3(0, 100, 0),
}
local model_anim = {
    [2001] = game.ObjAnimName.RideIdle,
}
local model_layer = {
    [2001] = game.ModelType.Mount,
    [2002] = game.ModelType.WingUI,
    [2003] = game.ModelType.WeaponUI,
    [2008] = game.ModelType.BeiShiUI,
    [2013] = game.ModelType.FaZanUI,
}

function OpenFuncGrowTemplate:_init(parent)
    self.parent = parent
    self.ctrl = game.OpenFuncCtrl.instance
    self._package_name = "ui_open_func"
    self._com_name = "open_func_grow_template"
end

function OpenFuncGrowTemplate:OpenViewCallBack()
    self:Init()
end

function OpenFuncGrowTemplate:CloseViewCallBack()
    self:Inactive()
end

function OpenFuncGrowTemplate:Init()
    self.img_func = self._layout_objs["img_func"]
    self.btn_ok = self._layout_objs["btn_ok"]
    self.btn_ok:AddClickCallBack(function()
        self.parent:CreateShowTimer()
    end)
end

function OpenFuncGrowTemplate:OnEmptyClick()
    self.parent:CreateShowTimer()
end

function OpenFuncGrowTemplate:Active(func_id)
    self.open_attr = config.func[func_id].open_attr[1]    
    if self.open_attr then
        self:SetFuncSprite()
        self:InitModel(func_id)
        self:PlayFade()
    end
end

function OpenFuncGrowTemplate:Inactive()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function OpenFuncGrowTemplate:InitModel(func_id)
    local model_id = self.open_attr[3]
    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.wrapper, body_type[func_id])
    self.model:SetPosition(model_pos[func_id].x, model_pos[func_id].y, model_pos[func_id].z)
    self.model:SetRotation(model_rotate[func_id].x, model_rotate[func_id].y, model_rotate[func_id].z)
    self.model:SetModel(model_type[func_id], model_id, HangNodeType[func_id])
    self.model:PlayAnim(model_anim[func_id] or game.ObjAnimName.Idle, model_layer[func_id])
end

function OpenFuncGrowTemplate:SetFuncSprite()
    self.img_func:SetSprite("ui_open_func", self.open_attr[2])
end

function OpenFuncGrowTemplate:PlayFade()
    self:GetRoot():PlayTransition("trans_fade")
end

return OpenFuncGrowTemplate
