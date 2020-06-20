local PetTrainView = Class(game.BaseView)

local type_image = { "zs_wai", "zs_nei", "zs_ping" }
local gen_type = { "zs_01", "zs_02", "zs_03" }

function PetTrainView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "pet_train_view"
    self._view_level = game.UIViewLevel.Second
    self._show_money = true

    self.ctrl = ctrl
end

function PetTrainView:OpenViewCallBack(pet_info, open_index)
    self:InitBg()
    self:InitTemplate()
    self:InitBtns()
    self:InitPetList()
    self:RegisterAllEvents()
    self:SetPetList()
    self:SetPetInfo(pet_info)

    open_index = open_index or 1
    global.TimerMgr:CreateTimer(0.1, function()
        self.controller:SetSelectedIndexEx(open_index - 1)
        return true
    end)
end

function PetTrainView:RegisterAllEvents()
    local events = {
        {
            game.PetEvent.PetChange,
            function(data)
                if self.cur_select_pet and data.grid == self.cur_select_pet.grid then
                    self:SetPetInfo(data)
                end
            end
        },
    }
    for _, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function PetTrainView:InitBtns()
    self._layout_objs.btn_rename:AddClickCallBack(function()
        if self.cur_select_pet then
            self.ctrl:OpenRenameView(self.cur_select_pet)
        end
    end)

    self.controller = self:GetRoot():GetController("c1")
end

function PetTrainView:SetPetInfo(info)
    self.cur_select_pet = info
    local pet_cfg = config.pet[info.cid]
    self._layout_objs.type:SetSprite("ui_common", type_image[pet_cfg.type])
    local pet_type = gen_type[1]
    if pet_cfg.quality == 2 then
        pet_type = gen_type[3]
    elseif info.star == 0 then
        pet_type = gen_type[2]
    end
    self._layout_objs.gen_type:SetSprite("ui_common", pet_type)
    self._layout_objs.level:SetText(info.level .. config.words[1217])
    self._layout_objs.name:SetText(info.name)
    for i = 1, 9 do
        self._layout_objs["star" .. i]:SetVisible(info.star >= i)
    end

    self.list:Foreach(function(obj)
        local item_info = obj:GetItemInfo()
        if item_info then
            obj:SetSelect(item_info.grid == info.grid)
        end
    end)

    self.attr_template:SetAttr(info)
    self.skill_template:SetSkill(info)
end

function PetTrainView:InitPetList()
    self.list = self:CreateList("list", "game/pet/item/pet_icon_item")

    self.list:SetRefreshItemFunc(function(item, idx)
        local info = self.pet_list[idx]
        if info then
            item:SetItemInfo(info.pet)
        else
            item:ResetItem()
        end
    end)
    self.list:AddClickItemCallback(function(obj)

        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_pet/pet_train_view/list/pet_icon_item2"})
        game.ViewMgr:FireGuideEvent()

        local info = obj:GetItemInfo()
        if info then
            if self.cur_select_pet and self.cur_select_pet.grid == info.grid then
                return
            end
            self:SetPetInfo(info)
        end
    end)
    self.list:AddScrollEndCallback(function(perX)
        self._layout_objs.left:SetVisible(perX > 0)
        self._layout_objs.right:SetVisible(perX < 1)
    end)
end

function PetTrainView:SetPetList()
    self.pet_list = game.PetCtrl.instance:GetPetInfo()
    table.sort(self.pet_list, function(a, b)
        if a.pet.stat == b.pet.stat then
            if a.pet.stat == 0 then
                if a.pet.star * b.pet.star == 0 then
                    return a.pet.star > b.pet.star
                else
                    return self:CalcFight(a.pet) > self:CalcFight(b.pet)
                end
            else
                return self:CalcFight(a.pet) > self:CalcFight(b.pet)
            end
        else
            return a.pet.stat > b.pet.stat
        end
    end)
    self.list:SetItemNum(10)
end

function PetTrainView:InitBg()
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[1654])
end

function PetTrainView:InitTemplate()
    self.attr_template = self:GetTemplateByObj("game/pet/pet_train_attr_template", self._layout_objs.page:GetChildAt(0))

    self.skill_template = self:GetTemplateByObj("game/pet/pet_train_skill_template", self._layout_objs.page:GetChildAt(1))

    self._layout_objs.page:SetHorizontalBarTop(true, 22)
end


function PetTrainView:CalcFight(pet_info)
    local fight = 0

    for _, v in pairs(pet_info.bt_attr) do
        fight = fight + v.value * config.combat_power_battle[v.type].pet
    end

    for _, v in pairs(pet_info.skills) do
        fight = fight + config.skill[v.id][v.lv].power
    end

    return math.floor(fight)
end

return PetTrainView
