local FashionDyeView = Class(game.BaseView)

function FashionDyeView:_init()
    self._package_name = "ui_exterior"
    self._com_name = "fashion_dye_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
    self._show_money = true

    self.ctrl = game.FashionCtrl.instance
end

function FashionDyeView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:InitBtns()
    self:InitModel()
    self:InitColorList()
    self:InitFashionList()

    self:RegisterAllEvents()
end

function FashionDyeView:CloseViewCallBack()
    self.cur_color_item = nil
    self.cur_fashion_item = nil
    if self.role_model then
        self.role_model:DeleteMe()
        self.role_model = nil
    end
end

function FashionDyeView:RegisterAllEvents()
    local events = {
        { game.FashionEvent.DyeingFashion, function(id, color)
            self:OnDyeingFashion(id, color)
        end },
        { game.BagEvent.BagItemChange, function(change_list)
            self:OnBagItemChange(change_list)
        end },
        { game.FashionEvent.WearFashion, function(id)
            self:OnWearFashion(id)
        end },
    }
    for _, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function FashionDyeView:Init()

    self.item_fashion = self:GetTemplate("game/exterior/item/color_item", "item_fashion")
    self.item_fashion:AddClickEvent(function(item)
        self.cur_color_item = item
        self:UpdateFashionColor()
    end)
    self.item_color = self:GetTemplate("game/bag/item/goods_item", "item_color")
    self.item_color:SetShowTipsEnable(true)
end

function FashionDyeView:InitBtns()
    self.btn_color = self._layout_objs["btn_color"]
    self.btn_color:AddClickCallBack(function()
        if self:CheckColorable() then
            self.ctrl:SendFashionDyeing(self.fashion_id)
        end
    end)

    self.btn_wear = self._layout_objs["btn_wear"]
    self.btn_wear:AddClickCallBack(function()
        if not self.cur_fashion_item or not self.cur_color_item then
            return
        end
        self.ctrl:SendFashionWear(self.cur_fashion_item:GetId(), self.cur_color_item:GetColor())
    end)
end

function FashionDyeView:CheckColorable()
    local is_all_actived = self.ctrl:IsAllColorActived(self.fashion_id)
    if is_all_actived then
        game.GameMsgCtrl.instance:PushMsg(config.words[2001])
        return false
    end

    local cur_num = game.BagCtrl.instance:GetNumById(self.cost_id)
    if cur_num < self.cost_num then
        game.GameMsgCtrl.instance:PushMsg(config.words[2000])
        return false
    end
    return true
end

function FashionDyeView:InitBg()
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[1652])
end

function FashionDyeView:UpdateCost()
    local info = config.fashion[self.fashion_id]
    if not info then
        return
    end

    local cost = info.cost or {}
    local cost_id = cost[1][1]
    local cost_num = cost[1][2]

    self.cost_id = cost_id
    self.cost_num = cost_num

    local item_info = {
        id = cost_id,
        num = 0
    }
    self.item_color:SetItemInfo(item_info)

    local item_num = game.BagCtrl.instance:GetNumById(self.cost_id)
    self.item_color:SetNumText(item_num .. "/" .. self.cost_num)

end

function FashionDyeView:OnDyeingFashion()
    self:UpdateCost()

    local dye_name = self:UpdateColorItemState()

    if dye_name ~= "" then
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[2005], dye_name))
    end

    self:UpdateFashionItem()
end

function FashionDyeView:UpdateColorItemState()
    local dye_name = ""
    self.color_list:Foreach(function(item)
        item:UpdateState()

        if item:IsStateDirty() then
            dye_name = item:GetName()
            item:ClearStateDirty()
        end
    end)
    return dye_name
end

function FashionDyeView:UpdateFashionItem()
    local is_actived = self.ctrl:IsColorActived(self.fashion_id, self.active_color_id)
    self.item_fashion:SetGray(not is_actived)
end

function FashionDyeView:OnBagItemChange(change_list)
    if not change_list[self.cost_id] then
        return
    end
    self:UpdateCost()
end

function FashionDyeView:InitFashionList()

    local fashion_cfg = {}
    for _, v in pairs(config.fashion or {}) do
        if #v.colors > 1 and game.FashionCtrl.instance:IsFashionActived(v.id) then
            table.insert(fashion_cfg, v)
        end
    end

    table.sort(fashion_cfg, function(v1, v2)
        return v1.id < v2.id
    end)

    self.fashion_list = self:CreateList("list", "game/exterior/item/fashion_item")
    self.fashion_list:SetRefreshItemFunc(function(item, idx)
        local info = fashion_cfg[idx]
        item:SetItemInfo(info)
        if self.cur_fashion_item == nil then
            self.cur_fashion_item = item
            self:UpdateFashion()
        end
    end)
    self.fashion_list:AddClickItemCallback(function(item)
        self.cur_fashion_item = item
        self:UpdateFashion()
    end)
    self.fashion_list:SetItemNum(#fashion_cfg)
end

function FashionDyeView:UpdateFashion()
    if not self.cur_fashion_item then
        return
    end

    self.fashion_id = self.cur_fashion_item:GetId()

    self.fashion_list:Foreach(function(item)
        item:SetSelect(self.fashion_id)
    end)

    local fashion_name = self.cur_fashion_item:GetName()
    self._layout_objs.txt_name:SetText(fashion_name)

    self:UpdateColorList()
end

function FashionDyeView:InitColorList()
    self.color_list = self:CreateList("list_color", "game/exterior/item/color_item")

    self.color_list:AddClickItemCallback(function(item)
        self.cur_color_item = item
        self:UpdateFashionColor()
    end)
end

function FashionDyeView:UpdateColorList()
    local career = game.RoleCtrl.instance:GetCareer()
    local fashion_id = self.cur_fashion_item:GetId()

    local fashion_cfg = config.fashion[fashion_id]
    local color_cfg = config.fashion_color[fashion_id][career]
    self.color_list:SetRefreshItemFunc(function(item, idx)
        local index = fashion_cfg.unlock[idx]
        item:UpdateData(color_cfg[index])
        if self.cur_color_item == nil then
            self.cur_color_item = item
        end
    end)
    self.cur_color_item = nil
    self.color_list:SetItemNum(#fashion_cfg.unlock)

    local active_color_id = fashion_cfg.active
    local active_cfg = color_cfg[active_color_id]
    self.item_fashion:UpdateData(active_cfg)

    if self.cur_color_item then
        self:UpdateFashionColor()
    end

    self.active_color_id = active_cfg.color
    self:UpdateFashionItem()
    self:UpdateCost()
end

function FashionDyeView:UpdateFashionColor()
    if not self.cur_color_item or not self.cur_fashion_item then
        return
    end
    self.color_list:Foreach(function(item)
        item:SetSelect(self.cur_color_item:GetColor())
    end)
    self.item_fashion:SetSelect(self.cur_color_item:GetColor())

    local fashion_id = self:GetFashionId()
    local fashion_color = self:GetFashionColor()
    local career = game.RoleCtrl.instance:GetCareer()
    self.role_model:UpdateFashion(fashion_id, career, fashion_color)
end

function FashionDyeView:GetFashionId()
    return self.cur_fashion_item:GetId()
end

function FashionDyeView:GetFashionColor()
    return self.cur_color_item:GetColor()
end

function FashionDyeView:InitModel()
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

function FashionDyeView:OnWearFashion()
    self.color_list:Foreach(function(item)
        item:DoUpdate()
    end)

end

return FashionDyeView
