local PetBreedView = Class(game.BaseView)

function PetBreedView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "pet_breed_view"
    self._view_level = game.UIViewLevel.Standalone
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function PetBreedView:OnEmptyClick()
    self.ctrl:SendCancelHatch()
    self:Close()
end

function PetBreedView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1530])

    self._layout_objs["common_bg/btn_close"]:AddClickCallBack(function()
        self.ctrl:SendCancelHatch()
        self:Close()
    end)
    self._layout_objs["common_bg/btn_back"]:AddClickCallBack(function()
        self.ctrl:SendCancelHatch()
        self:Close()
    end)

    local ui_effect = self:CreateUIEffect(self._layout_objs.effect, "effect/ui/ui_cw_aixin.ab")
    ui_effect:SetLoop(true)
    self._layout_objs.effect:SetVisible(false)

    self._layout_objs.btn_reset1:AddClickCallBack(function()
        if self.select_pets[1] then
            self:SetSelectPet(self.select_pets[1])
        end
    end)
    self._layout_objs.btn_reset2:AddClickCallBack(function()
        if self.select_pets[2] then
            self:SetSelectPet(self.select_pets[2])
        end
    end)

    self._layout_objs.lock1:AddClickCallBack(function()
    end)
    self._layout_objs.lock2:AddClickCallBack(function()
    end)

    self._layout_objs.btn_breed:AddClickCallBack(function()
        if self.select_pets[1] and self.select_pets[2] then
            local ids = {}
            table.insert(ids, { grid = self.select_pets[1].grid })
            table.insert(ids, { grid = self.select_pets[2].grid })
            self.ctrl:SendHatchSelf(ids)
            game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_pet/pet_breed_view/btn_breed"})
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
    self.list:SetScrollEnable(true)
    self.list:AddClickItemCallback(function(obj)
        if obj.index == 1 then
            game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_pet/pet_breed_view/list/pet_item1"})
            game.ViewMgr:FireGuideEvent()
        elseif obj.index == 2 then
            game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_pet/pet_breed_view/list/pet_item2"})
            game.ViewMgr:FireGuideEvent()
        end

        self:SetSelectPet(obj:GetItemInfo())
    end)
    local pets = self.ctrl:GetPetInfo()
    self.pet_list = {}
    for _, v in pairs(pets or {}) do
        local pet_cfg = config.pet[v.pet.cid]
        if v.pet.star == 0 and pet_cfg.quality ~= 2 and v.pet.stat == 0 then
            table.insert(self.pet_list, v)
        end
    end
    self.list:SetRefreshItemFunc(function(item, index)
        local pet = self.pet_list[index].pet
        item.index = index
        item:SetItemInfo(pet)
        item:SetSelect(false)

        local pet_cfg = config.pet[pet.cid]
        item:SetText1(string.format(config.words[1497], pet_cfg.carry_lv))
        item:SetText2(string.format(config.words[1496], cc.GoodsColor2[pet.growup_lv], config.words[1520 + pet.growup_lv] .. pet.growup_rate))
    end)
    self.list:SetItemNum(#self.pet_list)

    self._layout_objs.star_ratio:SetText(config.words[1469])

    self.select_pets = {}
end

function PetBreedView:CloseViewCallBack()
    for i = 1, 2 do
        if self.model[i] then
            self.model[i]:DeleteMe()
            self.model[i] = nil
        end
    end
end

function PetBreedView:SetSelectPet(info)
    if self.select_pets[1] then
        if self.select_pets[1].grid == info.grid then
            self.select_pets[1] = nil
        else
            if self.select_pets[2] then
                if self.select_pets[2].grid == info.grid then
                    self.select_pets[2] = nil
                else
                    game.GameMsgCtrl.instance:PushMsg(config.words[1532])
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

    if self.select_pets[1] and self.select_pets[2] then
        local total_grow = self.select_pets[1].growup_lv + self.select_pets[2].growup_lv
        local star_range = config.pet_star_ratio[total_grow]
        local min_star = star_range[1][1]
        local max_star = star_range[#star_range][1]
        self._layout_objs.star_ratio:SetText(string.format(config.words[1495], min_star, max_star) .. "\n" .. config.words[1470])
        self._layout_objs.effect:SetVisible(true)
    else
        self._layout_objs.star_ratio:SetText(config.words[1469])
        self._layout_objs.effect:SetVisible(false)
    end

    for i = 1, 2 do
        if self.select_pets[i] then
            self._layout_objs["pet" .. i]:SetVisible(true)
            self._layout_objs["u_pet" .. i]:SetVisible(false)
            self._layout_objs["name" .. i]:SetText(self.select_pets[i].name)
            self._layout_objs["ratio" .. i]:SetText(string.format(config.words[1496], cc.GoodsColor2[self.select_pets[i].growup_lv], config.words[1520 + self.select_pets[i].growup_lv] .. self.select_pets[i].growup_rate))
            self.model[i]:SetModel(game.ModelType.Body, config.pet[self.select_pets[i].cid].model_id[1])
            self.model[i]:PlayAnim(game.ObjAnimName.Idle)
            self.model[i]:SetScale(config.pet[self.select_pets[i].cid].scale)
        else
            self._layout_objs["pet" .. i]:SetVisible(false)
            self._layout_objs["u_pet" .. i]:SetVisible(true)
        end
    end
end

function PetBreedView:InitModel()
    self.model = {}
    for i = 1, 2 do
        self.model[i] = require("game/character/model_template").New()
        self.model[i]:CreateDrawObj(self._layout_objs["pet_model" .. i], game.BodyType.Monster)
        self.model[i]:SetPosition(0, -0.85, 2.5)
        self.model[i]:SetRotation(0, 140, 0)
    end
end

function PetBreedView:RefreshPetList()
    local pets = self.ctrl:GetPetInfo()
    self.pet_list = {}
    for _, v in pairs(pets or {}) do
        local pet_cfg = config.pet[v.pet.cid]
        if v.pet.star == 0 and pet_cfg.quality ~= 2 and v.pet.stat == 0 then
            table.insert(self.pet_list, v)
        end
    end
    table.sort(self.pet_list, function(a, b)
        if a.pet.cid == 1005 and b.pet.cid ~= 1005 then
            return true
        elseif a.pet.cid ~= 1005 and b.pet.cid == 1005 then
            return false
        else
            return a.pet.cid < b.pet.cid
        end
    end)
    self.list:SetItemNum(#self.pet_list)
    self.list:SetScrollEnable(false)
end

return PetBreedView
