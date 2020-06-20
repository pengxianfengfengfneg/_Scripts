local PetTeamBreedView = Class(game.BaseView)

function PetTeamBreedView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "pet_breed_view"
    self._view_level = game.UIViewLevel.Standalone
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function PetTeamBreedView:OnEmptyClick()
    self.ctrl:SendCancelHatch()
    self:Close()
end

function PetTeamBreedView:OpenViewCallBack(babies)
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1530])

    self._layout_objs["common_bg/btn_close"]:AddClickCallBack(function()
        self.ctrl:SendCancelHatch()
        self:Close()
    end)
    self._layout_objs["common_bg/btn_back"]:AddClickCallBack(function()
        self.ctrl:SendCancelHatch()
        self:Close()
    end)

    self._layout_objs.btn_reset1:AddClickCallBack(function()
        self.ctrl:SendCancelSelectHatchPet()
    end)
    self._layout_objs.btn_reset2:AddClickCallBack(function()
        self.ctrl:SendCancelSelectHatchPet()
    end)

    self._layout_objs.lock1:AddClickCallBack(function()
        if self._layout_objs.lock1:GetSelected() then
            self.ctrl:SendLockHatchPet()
        else
            self.ctrl:SendUnlockHatchPet()
        end
    end)
    self._layout_objs.lock2:AddClickCallBack(function()
        if self._layout_objs.lock2:GetSelected() then
            self.ctrl:SendLockHatchPet()
        else
            self.ctrl:SendUnlockHatchPet()
        end
    end)

    local is_leader = game.MakeTeamCtrl.instance:IsSelfLeader()
    self._layout_objs.btn_breed:AddClickCallBack(function()
        if is_leader then
            if self._layout_objs.pet1:IsVisible() == false then
                game.GameMsgCtrl.instance:PushMsg(config.words[1476])
                return
            end
            if self._layout_objs.lock1:GetSelected() == false then
                game.GameMsgCtrl.instance:PushMsg(config.words[1475])
                return
            end
            if self._layout_objs.pet2:IsVisible() == false then
                game.GameMsgCtrl.instance:PushMsg(config.words[1474])
                return
            end
            if self._layout_objs.lock2:GetSelected() == false then
                game.GameMsgCtrl.instance:PushMsg(config.words[1473])
                return
            end
            self.ctrl:SendStartHatch()
        else
            game.GameMsgCtrl.instance:PushMsg(config.words[5012])
        end
    end)

    self._layout_objs.lucky_value:SetText(self.ctrl:GetLucky())
    self._layout_objs.btn_lucky:AddClickCallBack(function()
        self.ctrl:OpenLuckyView()
    end)

    self:InitModel()

    for i = 1, 2 do
        self._layout_objs["pet" .. i]:SetVisible(false)
    end

    self._layout_objs["u_pet1"]:SetVisible(is_leader)
    self._layout_objs["u_pet2"]:SetVisible(not is_leader)

    self.list = self:CreateList("list", "game/pet/item/pet_item")
    self.list:AddClickItemCallback(function(obj)
        self:SetSelectPet(obj:GetItemInfo())
    end)
    local pets = self.ctrl:GetPetInfo()
    local pet_list = {}
    for _, v in pairs(pets or {}) do
        local pet_cfg = config.pet[v.pet.cid]
        if v.pet.star == 0 and pet_cfg.quality ~= 2 and v.pet.stat == 0 then
            table.insert(pet_list, v)
        end
    end
    self.list:SetRefreshItemFunc(function(item, index)
        local pet = pet_list[index].pet
        item:SetItemInfo(pet)
        item:SetSelect(false)

        local pet_cfg = config.pet[pet.cid]
        item:SetText1(string.format(config.words[1497], pet_cfg.carry_lv))
        item:SetText2(string.format(config.words[1496], cc.GoodsColor2[pet.growup_lv], config.words[1520 + pet.growup_lv] .. pet.growup_rate))
    end)
    self.list:SetItemNum(#pet_list)

    self._layout_objs.group_cost:SetVisible(false)

    local ui_effect = self:CreateUIEffect(self._layout_objs.effect, "effect/ui/ui_cw_aixin.ab")
    ui_effect:SetLoop(true)
    self._layout_objs.effect:SetVisible(false)

    self._layout_objs.star_ratio:SetText(config.words[1469])

    self:UpdateMemberPet(babies)
end

function PetTeamBreedView:CloseViewCallBack()
    for i = 1, 2 do
        if self.model[i] then
            self.model[i]:DeleteMe()
            self.model[i] = nil
        end
    end
    self.select_pet = nil
end

function PetTeamBreedView:SetSelectPet(info)
    if self.select_pet ~= nil then
        return
    end
    self.select_pet = info

    local grid = self.select_pet and self.select_pet.grid
    self.list:Foreach(function(obj)
        local item_info = obj:GetItemInfo()
        obj:SetSelect(item_info.grid == grid)
    end)
    self.ctrl:SendSelectHatchPet(grid)
end

function PetTeamBreedView:CancelSelectPet()
    self.list:Foreach(function(obj)
        obj:SetSelect(false)
    end)
    self.select_pet = nil
end

function PetTeamBreedView:InitModel()
    self.model = {}
    for i = 1, 2 do
        self.model[i] = require("game/character/model_template").New()
        self.model[i]:CreateDrawObj(self._layout_objs["pet_model" .. i], game.BodyType.Monster)
        self.model[i]:SetPosition(0, -0.85, 2.5)
        self.model[i]:SetRotation(0, 140, 0)
    end
end

function PetTeamBreedView:UpdateMemberPet(pet_list)
    local role_id = game.RoleCtrl.instance:GetRoleId()
    local self_pet = true
    local pets = {}
    for _, v in pairs(pet_list) do
        if v.role_id == role_id then
            self_pet = false
        end
        if game.MakeTeamCtrl.instance:IsLeader(v.role_id) then
            pets[1] = v
        else
            pets[2] = v
        end
    end
    if self_pet then
        self:CancelSelectPet()
    end
    local is_leader = game.MakeTeamCtrl.instance:IsSelfLeader()
    for i = 1, 2 do
        local info = pets[i]
        if info then
            self._layout_objs["pet" .. i]:SetVisible(true)
            self._layout_objs["u_pet" .. i]:SetVisible(false)
            local pet_cfg = config.pet[info.cid]
            self._layout_objs["name" .. i]:SetText(info.name)
            self.model[i]:SetModel(game.ModelType.Body, pet_cfg.model_id[1])
            self.model[i]:PlayAnim(game.ObjAnimName.Idle)
            self.model[i]:SetScale(pet_cfg.scale)
            self._layout_objs["ratio" .. i]:SetText(string.format(config.words[1496], cc.GoodsColor2[info.growup_lv], config.words[1520 + info.growup_lv] .. info.growup))
            self._layout_objs["lock" .. i]:SetSelected(info.is_lock == 1)
            self._layout_objs["btn_reset" .. i]:SetVisible(false)
            self._layout_objs["lock" .. i]:SetTouchEnable(false)
            if i == 1 and is_leader then
                self._layout_objs["btn_reset1"]:SetVisible(true)
                self._layout_objs["lock1"]:SetTouchEnable(true)
            end
            if i == 2 and not is_leader then
                self._layout_objs["btn_reset2"]:SetVisible(true)
                self._layout_objs["lock2"]:SetTouchEnable(true)
            end
        else
            self._layout_objs["pet" .. i]:SetVisible(false)
            self._layout_objs["u_pet" .. i]:SetVisible(false)
            if i == 1 and is_leader then
                self._layout_objs["u_pet1"]:SetVisible(true)
            end
            if i == 2 and not is_leader then
                self._layout_objs["u_pet2"]:SetVisible(true)
            end
        end
    end

    if pets[1] and pets[2] then
        local total_grow = pets[1].growup_lv + pets[2].growup_lv
        local star_range = config.pet_star_ratio[total_grow]
        local min_star = star_range[1][1]
        local max_star = star_range[#star_range][1]
        self._layout_objs.star_ratio:SetText(string.format(config.words[1495], min_star, max_star) .. "\n" .. config.words[1470])
        self._layout_objs.effect:SetVisible(true)
    else
        self._layout_objs.star_ratio:SetText(config.words[1469])
        self._layout_objs.effect:SetVisible(false)
    end
end

return PetTeamBreedView
