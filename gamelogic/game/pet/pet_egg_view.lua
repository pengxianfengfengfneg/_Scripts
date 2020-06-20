local PetEggView = Class(game.BaseView)

local egg_model = config.pet_common.egg_model

function PetEggView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "pet_egg_view"
    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function PetEggView:OpenViewCallBack()

    self:BindEvent(game.PetEvent.PetAdd, function(data)
        self:ShowGetPet(data)
    end)

    self._layout_objs.btn_close:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs.btn_get:AddClickCallBack(function()
        self.ctrl:SendGetHatchPet()
    end)

    self._layout_objs.btn_ok:AddClickCallBack(function()
        local info = self.ctrl:GetHatchInfo()
        if info.stat == 3 then
            self:SetInfo()
        else
            self:Close()
        end
    end)

    self:InitModel()

    self:SetInfo()
end

function PetEggView:CloseViewCallBack()
    self:StopCountTime()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function PetEggView:SetInfo()
    local info = self.ctrl:GetHatchInfo()
    self._layout_objs.btn_get:SetVisible(info.stat == 3)
    self._layout_objs.btn_ok:SetVisible(false)
    self._layout_objs.group_star:SetVisible(false)
    self._layout_objs.btn_get:SetVisible(true)
    self.model:SetModelChangeCallBack(function()
        self.model:SetEffect(game.ModelNodeName.Root, "chongwudan_tx0", game.ModelType.Body)
        self.model:SetEffect(game.ModelNodeName.Effect1, "chongwudan_tx1", game.ModelType.Body)
    end)
    self.model:SetModel(game.ModelType.Body, egg_model)
    self.model:PlayAnim(game.ObjAnimName.Idle)
    if info.data > 2 then
        self:StartCountTime(info.data)
        local count = 0
        local total_grow = 0
        local role_id = game.RoleCtrl.instance:GetRoleId()
        for _, v in pairs(info.materials) do
            if v.role_id == role_id then
                count = count + 1
            end
            total_grow = total_grow + v.growup_lv
        end
        local star_range = config.pet_star_ratio[total_grow]
        local min_star = star_range[1][1]
        local max_star = star_range[#star_range][1]
        self._layout_objs.star_range:SetText(string.format(config.words[1495], min_star, max_star))
        self._layout_objs.star_range:SetVisible(true)
        self._layout_objs.times:SetText(count)
    else
        self._layout_objs.times:SetText(info.data)
        self._layout_objs.time:SetText("00:00")
        self._layout_objs.star_range:SetVisible(false)
    end
end

function PetEggView:StartCountTime(refresh_time)
    self:StopCountTime()
    self.tween = DOTween.Sequence()
    self.tween:AppendCallback(function()
        local count_time = refresh_time - global.Time:GetServerTime()
        if count_time < 0 then
            self._layout_objs.time:SetText("00:00")
            self._layout_objs.star_range:SetVisible(false)
            self._layout_objs.btn_get:SetVisible(true)
            self:StopCountTime()
        else
            self._layout_objs.time:SetText(string.format("%02d:%02d", count_time // 60, count_time % 60))
        end
    end)
    self.tween:AppendInterval(1)
    self.tween:SetLoops(-1)
end

function PetEggView:StopCountTime()
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

function PetEggView:InitModel()
    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.pet, game.BodyType.Monster)
    self.model:SetPosition(0, -1.2, 3)
end

function PetEggView:ShowGetPet(pet)
    self:StopCountTime()
    self._layout_objs.btn_get:SetVisible(false)
    self.tween = DOTween.Sequence()
    self.tween:AppendCallback(function()
        self.model:SetModel(game.ModelType.Body, egg_model)
        self.model:PlayAnim(game.ObjAnimName.Show1)
        self.model:SetEffect(game.ModelNodeName.Root, "chongwudan_show", game.ModelType.Body)
    end)
    local anim_cfg = game.AnimMgr:GetAnimConfig(game.BodyType.Monster, egg_model)
    self.tween:AppendInterval(anim_cfg.show1)
    self.tween:AppendCallback(function()
        self.model:SetModelChangeCallBack(function()
            self.model:SetRotation(0, 140, 0)
            self.model:SetPosition(0, -1.2, 3.5)
        end)
        self.model:SetModel(game.ModelType.Body, game.PetCtrl.instance:GetPetModel(pet))
        self.model:PlayAnim(game.ObjAnimName.Idle)
        self._layout_objs.btn_ok:SetVisible(true)
        self._layout_objs.group_star:SetVisible(true)
        for i = 1, 9 do
            self._layout_objs["star" .. i]:SetVisible(pet.star >= i)
        end
    end)
    self.tween:SetAutoKill(false)
end

return PetEggView