local ExteriorFashionTemplate = Class(game.UITemplate)

local _npc_id = config.sys_config.coloration_npc_id.value

function ExteriorFashionTemplate:_init()
    self.ctrl = game.FashionCtrl.instance
end

function ExteriorFashionTemplate:OpenViewCallBack()
    self.is_first_open = true
    self:Init()
    self:InitModel()
    self:InitColorList()
    self:InitFashionList()

    self:RegisterAllEvents()
end

function ExteriorFashionTemplate:CloseViewCallBack()
    self.cur_color_item = nil
    self.cur_fashion_item = nil
    if self.role_model then
        self.role_model:DeleteMe()
        self.role_model = nil
    end
    self.is_first_open = false
end

function ExteriorFashionTemplate:RegisterAllEvents()
    local events = {
        { game.FashionEvent.ActiveFashion, function(id, color)
            self:OnActiveFashion(id, color)
        end },
        { game.FashionEvent.WearFashion, function(id)
            self:UpdateFashionList()
            self:OnWearFashion(id)
        end },
        { game.FashionEvent.DyeingFashion, function(id, color)
            self:OnDyeingFashion(id, color)
        end },
        { game.ExteriorEvent.OnFashionSettingChange, function()
            self:UpdateFashionList()
        end },
    }
    for _, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function ExteriorFashionTemplate:Init()
    self.txt_name = self._layout_objs["txt_name"]

    self.btn_wear = self._layout_objs["btn_wear"]
    self.btn_color = self._layout_objs["btn_color"]

    self.btn_wear:AddClickCallBack(function()
        if not self.cur_fashion_item or not self.cur_color_item then
            return
        end
        self.ctrl:SendFashionWear(self.cur_fashion_item:GetId(), self.cur_color_item:GetColor())
    end)

    self.btn_color:AddClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then
            game.ExteriorCtrl.instance:CloseView()
            game.MainUICtrl.instance:SwitchToFighting()
            main_role:GetOperateMgr():DoGoToTalkNpc(_npc_id)
        end
    end)

    self._layout_objs.btn_sift:AddClickCallBack(function()
        game.ExteriorCtrl.instance:OpenFashionSettingView()
    end)

    self._layout_objs.btn_color_list:AddClickCallBack(function()
        self.controller:SetSelectedIndexEx(0)
    end)

    self.controller = self:GetRoot():GetController("c1")
end

function ExteriorFashionTemplate:InitFashionList()

    self.fashion_list = self:CreateList("list", "game/exterior/item/fashion_item")
    self.fashion_list:SetRefreshItemFunc(function(item, idx)
        local info = self.fashion_cfg[idx]
        item:SetItemInfo(info)
        item:SetSelect(false)
        item:SetTips(game.FashionCtrl.instance:GetFashionNewActionState(info.id))
        if self.cur_fashion_item == nil then
            self.cur_fashion_item = item
            item:SetSelect(true)
            self:UpdateFashion(true)
        end
    end)
    self.fashion_list:AddClickItemCallback(function(item)
        self.cur_fashion_item = item
        item:SetTips(false)
        game.FashionCtrl.instance:RemoveNewActionFashionState(item:GetId())
        self:UpdateFashion()
    end)

    self:UpdateFashionList()
end

function ExteriorFashionTemplate:UpdateFashionList()
    self.cur_fashion_item = nil
    self.fashion_cfg = {}

    local setting_value = game.ExteriorCtrl.instance:GetFashionSettingValue()
    local _FashionSettingKey = game.ExteriorCtrl.instance:GetFashionSettingKey()

    for _, v in pairs(config.fashion or {}) do
        local info = self.ctrl:GetFashionInfo(v.id)
        if setting_value & _FashionSettingKey.Forever > 0 and info ~= nil and info.time == 0 then
            table.insert(self.fashion_cfg, v)
        elseif setting_value & _FashionSettingKey.Expire > 0 and info ~= nil and info.time ~= 0 then
            table.insert(self.fashion_cfg, v)
        elseif setting_value & _FashionSettingKey.NotActive > 0 and info == nil then
            table.insert(self.fashion_cfg, v)
        end
    end

    table.sort(self.fashion_cfg, function(v1, v2)
        if game.FashionCtrl.instance:IsFashionWeared(v1.id) then
            return true
        elseif game.FashionCtrl.instance:IsFashionWeared(v2.id) then
            return false
        else
            if game.FashionCtrl.instance:IsFashionActived(v1.id) == game.FashionCtrl.instance:IsFashionActived(v2.id) then
                return v1.id < v2.id
            else
                return game.FashionCtrl.instance:IsFashionActived(v1.id)
            end
        end
    end)

    self.fashion_list:SetItemNum(#self.fashion_cfg)
end

function ExteriorFashionTemplate:InitColorList()
    self.color_list = self:CreateList("list_color", "game/exterior/item/color_item")

    self.color_list:AddClickItemCallback(function(item)
        self.cur_color_item = item
        self:UpdateFashionColor()
    end)
end

function ExteriorFashionTemplate:UpdateColorList()
    local career = game.RoleCtrl.instance:GetCareer()
    local fashion_id = self.cur_fashion_item:GetId()

    local fashion_cfg = config.fashion[fashion_id]
    local color_cfg = config.fashion_color[fashion_id][career]
    local default_color
    self.color_list:SetRefreshItemFunc(function(item, idx)
        if idx == 1 then
            default_color = item
        end
        local index = fashion_cfg.colors[idx]
        item:UpdateData(color_cfg[index])
        if item:IsUsed() then
            self.cur_color_item = item
        end
    end)
    self.cur_color_item = nil
    self.color_list:SetItemNum(#fashion_cfg.colors)
    if self.cur_color_item == nil then
        self.cur_color_item = default_color
    end

    if self.cur_color_item then
        self:UpdateFashionColor()
    end

end

function ExteriorFashionTemplate:UpdateFashion(is_refresh)
    if not self.cur_fashion_item then
        return
    end

    self.controller:SetSelectedIndexEx(1)

    self.fashion_list:Foreach(function(item)
        item:SetSelect(self.cur_fashion_item:GetId())
    end)

    local fashion_name = self.cur_fashion_item:GetName()
    self.txt_name:SetText(fashion_name)

    self:UpdateColorList()

    self:UpdateFashionColor()
end

function ExteriorFashionTemplate:UpdateFashionColor()
    if not self.cur_color_item or not self.cur_fashion_item then
        return
    end

    self.color_list:Foreach(function(item)
        item:SetSelect(self.cur_color_item:GetColor())
    end)

    local fashion_id = self:GetFashionId()
    local fashion_color = self:GetFashionColor()
    local career = game.RoleCtrl.instance:GetCareer()
    self.role_model:UpdateFashion(fashion_id, career, fashion_color)
end

function ExteriorFashionTemplate:GetFashionId()
    return self.cur_fashion_item:GetId()
end

function ExteriorFashionTemplate:GetFashionColor()
    return self.cur_color_item:GetColor()
end

function ExteriorFashionTemplate:OnActiveFashion()
    self:UpdateColorItemState()
end

function ExteriorFashionTemplate:OnWearFashion()
    self.fashion_list:Foreach(function(item)
        item:DoUpdate()
    end)
    self.color_list:Foreach(function(item)
        item:DoUpdate()
    end)

end

function ExteriorFashionTemplate:UpdateColorItemState()
    self.color_list:Foreach(function(item)
        item:UpdateState()
    end)
end

function ExteriorFashionTemplate:OnDyeingFashion()
    self.color_list:Foreach(function(item)
        item:UpdateState()
    end)
end

function ExteriorFashionTemplate:InitModel()
    if self.role_model then
        return
    end

    local main_role = game.Scene.instance:GetMainRole()

    local model_list = {
        [game.ModelType.Body] = 110101,
        [game.ModelType.Hair] = 11001,
        [game.ModelType.Weapon] = 1001,
    }

    for k, v in pairs(model_list) do
        if main_role == nil then 
            return
        end
        local id = main_role:GetModelID(k)
        model_list[k] = (id > 0 and id or v)
    end

    self.role_model = require("game/character/model_template").New()
    self.role_model:CreateModel(self._layout_objs["wrapper"], game.BodyType.Role, model_list)
    self.role_model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.Body + game.ModelType.Hair)
    self.role_model:SetPosition(0, -1.15, 3.2)
    self.role_model:SetRotation(0, 180, 0)

    self.role_model:SetModelChangeCallBack(function(model_type)
        if model_type == game.ModelType.Hair then
            local hair = main_role:GetHair()
            self.role_model:UpdateHairColorHex(hair)
        end
    end)
end

return ExteriorFashionTemplate