local FashionView = Class(game.BaseView)

function FashionView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "role_fashion_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function FashionView:OpenViewCallBack(open_index)
    self.open_index = open_index

    self:Init()    
    self:InitBg()
    self:InitModel()
    self:InitTemplate()
    self:InitBtns()
    self:InitList()
    

    self:RegisterAllEvents()
end

function FashionView:CloseViewCallBack()
    if self.role_model then
        self.role_model:DeleteMe()
        self.role_model = nil
    end
end

function FashionView:RegisterAllEvents()
    local events = {
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function FashionView:Init()
    
    self.txt_fight = self._layout_objs["role_fight_com/txt_fight"]
    self.img_item = self._layout_objs["img_item"]
    self.txt_name = self._layout_objs["txt_name"]
    self.txt_num = self._layout_objs["txt_num"]
    self.txt_get_way = self._layout_objs["txt_get_way"]


    
    self.role_attr1 = self._layout_objs["role_attr1"]
    self.role_attr2 = self._layout_objs["role_attr2"]
    self.role_attr3 = self._layout_objs["role_attr3"]

    self.txt_total_fight = self._layout_objs["txt_total_fight"]
    self.txt_active_num = self._layout_objs["txt_active_num"]


end

function FashionView:InitBtns()

end

function FashionView:InitList()
   
end

function FashionView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1652])
end

function FashionView:InitTemplate()
    self.template_cfg = {
        {"game/fashion/fashion_template", "role_fashion_template"},
        {"game/fashion/hair_template", "role_hair_template"},
    }

    self.list_tabs = self._layout_objs["list_tabs"]

    local tab_control = self:GetRoot():AddControllerCallback("tab_control",function(idx)
        self:OnClickTab(idx+1)
    end)

    local idx = self.open_index or 1
    tab_control:SetSelectedIndexEx(idx-1)
end

function FashionView:InitModel()
    if self.role_model then return end

    local main_role = game.Scene.instance:GetMainRole()

    local model_list = {
        [game.ModelType.Body]    = 110101,
        [game.ModelType.Wing]    = 101,
        [game.ModelType.Hair]    = 11001,
        [game.ModelType.Weapon]    = 1001,
    }

    for k,v in pairs(model_list) do
        local id = main_role:GetModelID(k)
        model_list[k] = (id>0 and id or v)
    end

    self.role_model = require("game/character/model_template").New()
    self.role_model:CreateModel(self._layout_objs["wrapper"], game.BodyType.Role, model_list)
    self.role_model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.Body + game.ModelType.Wing + game.ModelType.Hair)
    self.role_model:SetPosition(0,-1.15,3.2)
    self.role_model:SetRotation(0,180,0)

    self.role_model:SetModelChangeCallBack(function(model_type)
        if model_type == game.ModelType.Hair then
            local hair = main_role:GetHair()
            self.role_model:UpdateHairColorHex(hair)
        end
    end)
end

function FashionView:GetRoleModel()
    return self.role_model
end

function FashionView:OnEmptyClick()
    self:Close()
end

function FashionView:OnClickTab(idx)
    local cfg = self.template_cfg[idx]
    if cfg then
        local template = self:GetTemplate(cfg[1], cfg[2])
        template:Active()
    end
end

return FashionView
