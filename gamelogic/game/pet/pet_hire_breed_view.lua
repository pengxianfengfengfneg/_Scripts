local PetHireBreedView = Class(game.BaseView)

function PetHireBreedView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "pet_breed_view"
    self._view_level = game.UIViewLevel.Standalone
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function PetHireBreedView:OnEmptyClick()
    self.ctrl:SendCancelHatch()
    self:Close()
end

function PetHireBreedView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1530])

    self._layout_objs["common_bg/btn_close"]:AddClickCallBack(function()
        self.ctrl:SendCancelHatch()
        self:Close()
    end)
    self._layout_objs["common_bg/btn_back"]:AddClickCallBack(function()
        self.ctrl:SendCancelHatch()
        self:Close()
    end)

    self._layout_objs.btn_lucky:AddClickCallBack(function()
    end)

    self._layout_objs.btn_reset1:AddClickCallBack(function()
        if self.select_pet then
            self:SetSelectPet(self.select_pet)
        end
    end)
    self._layout_objs.btn_reset2:SetVisible(false)

    self._layout_objs.lock1:AddClickCallBack(function()
    end)
    self._layout_objs.lock2:AddClickCallBack(function()
    end)

    self._layout_objs.btn_breed:AddClickCallBack(function()
        if self.select_pet then
            local ids = {}
            table.insert(ids, { grid = self.select_pet.grid })
            self.ctrl:SendHatchSelf(ids)
        end
    end)

    self._layout_objs.lucky_value:SetText(self.ctrl:GetLucky())
    self._layout_objs.btn_lucky:AddClickCallBack(function()
        self.ctrl:OpenLuckyView()
    end)

    self:InitModel()

    for i = 1, 2 do
        self._layout_objs["lock" .. i]:SetVisible(false)
        self._layout_objs["pet" .. i]:SetVisible(false)
        self._layout_objs["u_pet" .. i]:SetVisible(true)
    end

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

    self._layout_objs.group_cost:SetVisible(true)
    self._layout_objs.cost:SetText(0)

    self._layout_objs.star_ratio:SetText(config.words[1469])
end

function PetHireBreedView:CloseViewCallBack()
    for i = 1, 2 do
        if self.model[i] then
            self.model[i]:DeleteMe()
            self.model[i] = nil
        end
    end
end

function PetHireBreedView:SetSelectPet(info)
    if self.select_pet and self.select_pet.grid == info.grid then
        self.select_pet = nil
    else
        self.select_pet = info
    end

    local grid = self.select_pet and self.select_pet.grid
    self.list:Foreach(function(obj)
        local item_info = obj:GetItemInfo()
        obj:SetSelect(item_info.grid == grid)
    end)

    for i = 1, 2 do
        if self.select_pet then
            self._layout_objs["pet" .. i]:SetVisible(true)
            self._layout_objs["u_pet" .. i]:SetVisible(false)
            self._layout_objs["name" .. i]:SetText(self.select_pet.name)
            self._layout_objs["ratio" .. i]:SetText(string.format(config.words[1496], cc.GoodsColor2[self.select_pet.growup_lv], config.words[1520 + self.select_pet.growup_lv] .. self.select_pet.growup_rate))
            self.model[i]:SetModel(game.ModelType.Body, config.pet[self.select_pet.cid].model_id[1])
            self.model[i]:PlayAnim(game.ObjAnimName.Idle)
            self.model[i]:SetScale(config.pet[self.select_pet.cid].scale)
            local pet_cfg = config.pet[self.select_pet.cid]
            local grow_cfg = config.pet_growup[pet_cfg.growup_id]
            local cost_cfg = grow_cfg[self.select_pet.growup_lv].breed_cost
            self._layout_objs.cost:SetText(cost_cfg[2])
        else
            self._layout_objs["pet" .. i]:SetVisible(false)
            self._layout_objs["u_pet" .. i]:SetVisible(true)
            self._layout_objs.cost:SetText(0)
        end
    end

    if self.select_pet then
        local total_grow = self.select_pet.growup_lv + self.select_pet.growup_lv
        local star_range = config.pet_star_ratio[total_grow]
        local min_star = star_range[1][1]
        local max_star = star_range[#star_range][1]
        self._layout_objs.star_ratio:SetText(string.format(config.words[1495], min_star, max_star) .. "\n" .. config.words[1470])
    else
        self._layout_objs.star_ratio:SetText(config.words[1469])
    end
end

function PetHireBreedView:InitModel()
    self.model = {}
    for i = 1, 2 do
        self.model[i] = require("game/character/model_template").New()
        self.model[i]:CreateDrawObj(self._layout_objs["pet_model" .. i], game.BodyType.Monster)
        self.model[i]:SetPosition(0, -0.85, 2.5)
        self.model[i]:SetRotation(0, 140, 0)
    end
end

return PetHireBreedView
