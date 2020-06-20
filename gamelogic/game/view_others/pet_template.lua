local PetTemplate = Class(game.UITemplate)

local type_image = { "zs_wai", "zs_nei", "zs_ping" }
local gen_type = { "zs_01", "zs_02", "zs_03" }

function PetTemplate:_init(parent, info)
    self.parent_view = parent
    self.pet_list = info
end

function PetTemplate:OpenViewCallBack()
    self:InitTemplate()
    self:InitPetList()
    self:SetPetList()
end

function PetTemplate:InitTemplate()
    self.view_template = self:GetTemplateByObj("game/view_others/pet_view_com", self._layout_objs.list_page:GetChildAt(0))
    self.attr_template = self:GetTemplateByObj("game/view_others/pet_attr_com", self._layout_objs.list_page:GetChildAt(1))
    self.skill_template = self:GetTemplateByObj("game/view_others/pet_skill_com", self._layout_objs.list_page:GetChildAt(2))
    self._layout_objs.list_page:SetHorizontalBarTop(true)
end


function PetTemplate:InitPetList()
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

function PetTemplate:SetPetList()
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
    if self.pet_list and #self.pet_list > 0 then
        self:SetPetInfo(self.pet_list[1].pet)
    else
        self:SetPetInfo()
    end
end

function PetTemplate:CalcFight(pet_info)
    local fight = 0

    for _, v in pairs(pet_info.bt_attr) do
        fight = fight + v.value * config.combat_power_battle[v.type].pet
    end

    for _, v in pairs(pet_info.skills) do
        fight = fight + config.skill[v.id][v.lv].power
    end

    return math.floor(fight)
end

function PetTemplate:SetPetInfo(info)
    self.cur_select_pet = info
    if info then
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
    else
        self:Reset()
    end

    self.attr_template:SetAttr(info)
    self.skill_template:SetSkill(info)
    self.view_template:SetPetInfo(info)
end

function PetTemplate:Reset()
    self._layout_objs.level:SetText("")
    self._layout_objs.name:SetText("")
    for i = 1, 9 do
        self._layout_objs["star" .. i]:SetVisible(false)
    end
end

return PetTemplate