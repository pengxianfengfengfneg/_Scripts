local ExteriorActionTemplate = Class(game.UITemplate)

local _partner_career = {
    [1] = 3,
    [2] = 4,
    [3] = 1,
    [4] = 2,
}

function ExteriorActionTemplate:OpenViewCallBack()
    self.end_time = nil
    self:InitBtn()
    self:InitList()
    self:InitModel()
    self:SetList(1)
    global.Runner:AddUpdateObj(self, 2)
end

function ExteriorActionTemplate:CloseViewCallBack()
    global.Runner:RemoveUpdateObj(self)
    self.cur_type = nil
    if self.role_model then
        self.role_model:DeleteMe()
        self.role_model = nil
    end
    if self.couple_preview then
        self.couple_preview:DeleteMe()
        self.couple_preview = nil
    end
end

function ExteriorActionTemplate:InitBtn()
    self._layout_objs.btn_single:AddClickCallBack(function()
        self:SetList(1)
    end)
    self._layout_objs.btn_couple:AddClickCallBack(function()
        self:SetList(2)
    end)

    self._layout_objs.btn_action:AddClickCallBack(function()
        if self.end_time and self.end_time > global.Time.now_time then
            return
        end
        self.end_time = global.Time.now_time + self.role_model:GetAnimTime(self.cur_select_action.anim)
        if self.cur_type == 1 then
            self.role_model:PlayAnim(self.cur_select_action.anim, game.ModelType.Body + game.ModelType.Hair)
        elseif self.cur_type == 2 then
            self:PlayCoupleAction()
        end
    end)
end

function ExteriorActionTemplate:InitList()
    self.list = self:CreateList("list", "game/exterior/item/action_item")
    self.list:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo(self.action_list[idx])
    end)
    self.list:AddClickItemCallback(function(item)
        self:SetCurAction(item:GetItemInfo())
    end)
end

function ExteriorActionTemplate:SetList(type)
    if self.cur_type == type then
        return
    end
    self.cur_type = type
    self.action_list = {}
    for _, v in pairs(config.exterior_action) do
        if v.type == type then
            table.insert(self.action_list, v)
        end
    end
    table.sort(self.action_list, function(a, b)
        local a_state = game.ExteriorCtrl.instance:GetActionState(a.id)
        local b_state = game.ExteriorCtrl.instance:GetActionState(b.id)
        if a_state == b_state then
            return a.id < b.id
        else
            return a_state
        end
    end)
    self.list:SetItemNum(#self.action_list)
    if #self.action_list > 0 then
        self._layout_objs.list:AddSelection(0, true)
        local obj = self._layout_objs.list:GetChildAt(0)
        local item = self.list:GetItemByObj(obj)
        self:SetCurAction(item:GetItemInfo())
    end
end

function ExteriorActionTemplate:InitModel()
    local main_role = game.Scene.instance:GetMainRole()

    local model_list = {
        [game.ModelType.Body] = 110101,
        [game.ModelType.Hair] = 11001,
    }

    for k, v in pairs(model_list) do
        local id = main_role:GetModelID(k)
        model_list[k] = (id > 0 and id or v)
    end

    self.role_model = require("game/character/model_template").New()
    self.role_model:CreateModel(self._layout_objs.model1, game.BodyType.Role, model_list)
    self.role_model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.Body + game.ModelType.Hair)
    self.role_model:SetPosition(0, -1, 2.75)
    self.role_model:SetRotation(0, 180, 0)

    self.couple_preview = require("game/character/mult_model_template").New(self._layout_objs.model2)
    local body_types = {game.BodyType.Role, game.BodyType.Role}
    local career = main_role:GetCareer()
    local fashion = main_role:GetFashion()
    local hair = main_role:GetHair()
    local partner_model_list = {
        [game.ModelType.Body] = config_help.ConfigHelpModel.GetBodyID(_partner_career[career], fashion),
        [game.ModelType.Hair] = config_help.ConfigHelpModel.GetHairID(_partner_career[career], hair),
    }
    local model_types = {model_list, partner_model_list}
    self.couple_preview:CreateModel(body_types, model_types)
    local anim = {name = game.ObjAnimName.Idle, layer = game.ModelType.Body + game.ModelType.Hair}
    self.couple_preview:PlayAnim({anim, anim})
    self.couple_preview:SetPosition(0, 0, 2.75)
    for i = 1, 2 do
        local model = self.couple_preview:GetModel(i)
        model:SetPosition(-0.3, -1, 0)
        model:SetRotation(0, 90, 0)
    end
end

function ExteriorActionTemplate:SetCurAction(act_cfg)
    self._layout_objs.model1:SetVisible(true)
    self._layout_objs.model2:SetVisible(false)
    self.couple_preview:SetRotateEnable(false)
    self.role_model:SetRotateEnable(true)
    self.cur_select_action = act_cfg
    self._layout_objs.txt_desc:SetText(act_cfg.desc)
    self._layout_objs.txt_name:SetText(act_cfg.name)
    self._layout_objs.get_way:SetText(act_cfg.get_way)
end

function ExteriorActionTemplate:Update(now_time)
    if self.end_time and now_time > self.end_time then
        self.end_time = nil
        self.role_model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.Body + game.ModelType.Hair)
    end
end

function ExteriorActionTemplate:PlayCoupleAction()
    self._layout_objs.model1:SetVisible(false)
    self._layout_objs.model2:SetVisible(true)
    self.couple_preview:SetRotateEnable(true)
    self.role_model:SetRotateEnable(false)
    local anim1 = {name = self.cur_select_action.anim, layer = game.ModelType.Body + game.ModelType.Hair}
    local anim2 = {name = self.cur_select_action.invitee_anim, layer = game.ModelType.Body + game.ModelType.Hair}
    self.couple_preview:PlayAnim({anim1, anim2})
end

return ExteriorActionTemplate