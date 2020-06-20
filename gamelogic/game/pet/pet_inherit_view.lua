local PetInheritView = Class(game.BaseView)

function PetInheritView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "pet_inherit_view"
    self._view_level = game.UIViewLevel.Second
    self._show_money = true

    self.ctrl = ctrl
end

function PetInheritView:OpenViewCallBack()
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[1654])
    self:InitModel()

    self:BindEvent(game.PetEvent.PetChange, function()
        local pets = game.PetCtrl.instance:GetPetInfo()
        self.pet_list = {}
        for _, v in pairs(pets or {}) do
            local pet_cfg = config.pet[v.pet.cid]
            if v.pet.star > 0 or pet_cfg.quality == 2 then
                table.insert(self.pet_list, v)
            end
        end
        self.list:SetItemNum(#self.pet_list)
    end)

    self:BindEvent(game.PetEvent.BagPetDelete, function()
        local pets = game.PetCtrl.instance:GetPetInfo()
        self.pet_list = {}
        for _, v in pairs(pets or {}) do
            local pet_cfg = config.pet[v.pet.cid]
            if v.pet.star > 0 or pet_cfg.quality == 2 then
                table.insert(self.pet_list, v)
            end
        end
        self.list:SetItemNum(#self.pet_list)
        self.select_pets = {}
        self:SetSelectPet()
        self._layout_objs.btn_checkbox1:SetSelected(false)
        self._layout_objs.btn_checkbox2:SetSelected(false)
    end)

    self._layout_objs.btn_next:AddClickCallBack(function()
        local skill_stat = self._layout_objs.btn_checkbox1:GetSelected()
        local savvy_stat = self._layout_objs.btn_checkbox2:GetSelected()
        if self.select_pets[1] and self.select_pets[2] then
            if skill_stat == false and savvy_stat == false then
                game.GameMsgCtrl.instance:PushMsg(config.words[1488])
                return
            end
            game.PetCtrl.instance:OpenInheritPreview(self.select_pets[1], self.select_pets[2], savvy_stat, skill_stat)
        end
    end)

    self._layout_objs.btn_minus1:AddClickCallBack(function()
        self:SetSelectPet(self.select_pets[1])
    end)
    self._layout_objs.btn_minus2:AddClickCallBack(function()
        self:SetSelectPet(self.select_pets[2])
    end)

    self.list = self:CreateList("list", "game/pet/item/pet_item")
    self.list:AddClickItemCallback(function(obj)
        local info = obj:GetItemInfo()
        if info.stat ~= 0 then
            game.GameMsgCtrl.instance:PushMsg(config.words[1489])
            return
        end
        self:SetSelectPet(info)
    end)
    local pets = game.PetCtrl.instance:GetPetInfo()
    self.pet_list = {}
    for _, v in pairs(pets or {}) do
        local pet_cfg = config.pet[v.pet.cid]
        if v.pet.star > 0 or pet_cfg.quality == 2 then
            table.insert(self.pet_list, v)
        end
    end
    self.list:SetRefreshItemFunc(function(item, index)
        local pet = self.pet_list[index].pet
        item:SetItemInfo(pet)
        item:SetSelect(false)
    end)
    self.list:SetItemNum(#self.pet_list)

    self.select_pets = {}

    self:SetSelectPet()
    self._layout_objs.btn_checkbox1:SetSelected(false)
    self._layout_objs.btn_checkbox2:SetSelected(false)
end

function PetInheritView:CloseViewCallBack()
    self.model1:DeleteMe()
    self.model1 = nil
    self.model2:DeleteMe()
    self.model2 = nil

    self.list = nil
end

function PetInheritView:InitModel()
    self.model1 = require("game/character/model_template").New()
    self.model1:CreateDrawObj(self._layout_objs.original_pet, game.BodyType.Monster)
    self.model1:SetPosition(0, -0.7, 4.4)
    self.model1:SetRotation(0, 140, 0)
    self.model1:SetModelChangeCallBack(function()
        self.model1:SetPosition(0, 0.3 - self.pet_height1, 4.4)
    end)

    self.model2 = require("game/character/model_template").New()
    self.model2:CreateDrawObj(self._layout_objs.target_pet, game.BodyType.Monster)
    self.model2:SetPosition(0, -0.7, 4.4)
    self.model2:SetRotation(0, 140, 0)
    self.model2:SetModelChangeCallBack(function()
        self.model2:SetPosition(0, 0.3 - self.pet_height2, 4.4)
    end)
end

function PetInheritView:SetSelectPet(info)
    if self.select_pets[1] then
        if self.select_pets[1].grid == info.grid then
            self.select_pets[1] = nil
        else
            if self.select_pets[2] then
                if self.select_pets[2].grid == info.grid then
                    self.select_pets[2] = nil
                else
                    return
                end
            else
                self.select_pets[2] = info
            end
        end
    else
        if self.select_pets[2] and self.select_pets[2].grid == info.grid then
            self.select_pets[2] = nil
        else
            self.select_pets[1] = info
        end
    end

    local grid1 = self.select_pets[1] and self.select_pets[1].grid
    local grid2 = self.select_pets[2] and self.select_pets[2].grid
    self.list:Foreach(function(obj)
        local item_info = obj:GetItemInfo()
        obj:SetSelect(item_info.grid == grid1 or item_info.grid == grid2)
    end)

    for i = 1, 2 do
        if self.select_pets[i] then
            self["pet_height" .. i] = config.pet[self.select_pets[i].cid].height
            self["model" .. i]:SetModel(game.ModelType.Body, game.PetCtrl.instance:GetPetModel(self.select_pets[i]))
            self["model" .. i]:PlayAnim(game.ObjAnimName.Idle)
            self["model" .. i]:SetModelVisible(game.ModelType.Body, true)
            self._layout_objs["name" .. i]:SetText(self.select_pets[i].name)
            self._layout_objs["savvy" .. i]:SetText(config.words[1506] .. self.select_pets[i].savvy_lv .. config.words[1217])
            self._layout_objs["btn_minus" .. i]:SetVisible(true)
        else
            self["model" .. i]:SetModelVisible(game.ModelType.Body, false)
            self._layout_objs["name" .. i]:SetText("")
            self._layout_objs["savvy" .. i]:SetText("")
            self._layout_objs["btn_minus" .. i]:SetVisible(false)
        end
    end
end

return PetInheritView