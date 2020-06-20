local FutiTemplate = Class(game.UITemplate)

function FutiTemplate:_init(parent, info)
    self.parent_view = parent
    self.attach_info = info.attach_list
    self.pet_info = info.pet_list
end

function FutiTemplate:OpenViewCallBack()
    self.cur_zhenfa = nil

    self.pet_power = self._layout_objs["role_fight_com/txt_fight"]
    self._layout_objs["role_fight_com/btn_look"]:SetVisible(false)

    self.pet_icon = self:GetTemplate("game/pet/item/pet_icon_item", "pet_icon")
    self.pet_icon:ResetItem()

    self:BindEvent(game.PetEvent.SelectZhenFa, function(id)
        self:SetSelectZhenFa(id)
    end)

    self:InitZhenFa()
    self:InitNeidan()

    self:SetSelectZhenFa(1)

    self:SetNeidanAttr()
end

function FutiTemplate:InitNeidan()
    self.neidan = {}
    for i = 1, 8 do
        self.neidan[i] = self:GetTemplate("game/pet/item/neidan_item", "neidan" .. i)
        self.neidan[i]:ResetItem()
    end
end

function FutiTemplate:InitZhenFa()
    self.zhenfa = {}
    for i = 1, 5 do
        self.zhenfa[i] = self:GetTemplate("game/pet/item/zhenfa_item", "zhenfa" .. i)
        self.zhenfa[i]:SetOthersMode()
        self.zhenfa[i]:SetItemInfo(config.pet_zhenfa[i])
        self.zhenfa[i]:SetSelect(false)
    end
end

function FutiTemplate:SetSelectZhenFa(id)
    self.cur_zhenfa = id
    for i = 1, 5 do
        self.zhenfa[i]:SetSelect(i == id)
    end

    for i = 1, 8 do
        self.neidan[i]:ResetItem()
    end
    self.pet_icon:ResetItem()
    local info = self:GetAttach(id)
    if info then
        local pet_info = self:GetPetInfoById(info.pet_grid)
        if pet_info then
            self.pet_icon:SetItemInfo(pet_info)
        end
        for _, v in pairs(info.internals) do
            self.neidan[v.grid]:SetItemInfo(v)
        end
    end
end

function FutiTemplate:SetNeidanAttr()
    for i = 1, 16 do
        self._layout_objs["key" .. i]:SetText("")
        self._layout_objs["value" .. i]:SetText("")
    end

    local add_attr = {}
    local total_fight = 0
    for _, v in ipairs(config.pet_zhenfa) do
        local info = self:GetAttach(v.id)
        if info then
            for _, val in pairs(info.bt_attr) do
                if add_attr[val.type] then
                    add_attr[val.type] = add_attr[val.type] + val.value
                else
                    add_attr[val.type] = val.value
                end
            end
            total_fight = total_fight + info.fight
        end
    end
    self.pet_power:SetText(total_fight)

    local i = 1
    for k, v in pairs(add_attr) do
        self._layout_objs["key" .. i]:SetText(config.combat_power_battle[k].name)
        self._layout_objs["value" .. i]:SetText(v)
        i = i + 1
    end
end

function FutiTemplate:GetAttach(id)
    if self.attach_info then
        for _, v in pairs(self.attach_info) do
            if v.attach.attach_id == id then
                return v.attach
            end
        end
    end
end

function FutiTemplate:GetPetInfoById(id)
    for _, v in pairs(self.pet_info) do
        if v.pet.grid == id then
            return v.pet
        end
    end
end

return FutiTemplate