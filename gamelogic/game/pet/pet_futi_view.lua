local PetFutiView = Class(game.BaseView)

function PetFutiView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "pet_futi_view"
    self._view_level = game.UIViewLevel.Second
    self._show_money = true

    self.ctrl = ctrl
end

function PetFutiView:OpenViewCallBack()
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[1654])

    self.cur_zhenfa = nil

    self:BindEvent(game.PetEvent.AttachChange, function(data)
        if self.cur_zhenfa and self.cur_zhenfa == data.attach_id then
            self:SetSelectZhenFa(data.attach_id)
        end
        self:SetNeidanAttr()
    end)

    self.pet_power = self._layout_objs["role_fight_com/txt_fight"]
    self._layout_objs["role_fight_com/btn_look"]:SetVisible(false)

    self._layout_objs.btn_add_futi:SetTouchEnable(false)
    self.pet_icon = self:GetTemplate("game/pet/item/pet_icon_item", "pet_icon")
    self.pet_icon:ResetItem()
    self.pet_icon:AddClickEvent(function()
        if self.cur_zhenfa then
            self.ctrl:OpenZhenFaView(config.pet_zhenfa[self.cur_zhenfa])
        end
    end)

    self._layout_objs.btn_commend:AddClickCallBack(function()
        self.ctrl:OpenNeidanCommendView()
    end)

    self:BindEvent(game.PetEvent.SelectZhenFa, function(id)
        self:SetSelectZhenFa(id)
    end)

    self:InitZhenFa()
    self:InitNeidan()

    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    if role_lv >= config.pet_zhenfa[1].level then
        self:SetSelectZhenFa(1)
    end

    self:SetNeidanAttr()
end

function PetFutiView:InitNeidan()
    self.neidan = {}
    for i = 1, 8 do
        self.neidan[i] = self:GetTemplate("game/pet/item/neidan_item", "neidan" .. i)
        self.neidan[i]:ResetItem()
    end
end

function PetFutiView:InitZhenFa()
    self.zhenfa = {}
    for i = 1, 5 do
        self.zhenfa[i] = self:GetTemplate("game/pet/item/zhenfa_item", "zhenfa" .. i)
        self.zhenfa[i]:SetItemInfo(config.pet_zhenfa[i])
        self.zhenfa[i]:SetSelect(false)
    end
end

function PetFutiView:SetSelectZhenFa(id)
    self.cur_zhenfa = id
    for i = 1, 5 do
        self.zhenfa[i]:SetSelect(i == id)
    end

    for i = 1, 8 do
        self.neidan[i]:ResetItem()
    end
    self.pet_icon:ResetItem()
    self._layout_objs.btn_add_futi:SetVisible(true)
    local info = self.ctrl:GetAttach(id)
    if info then
        local pet_info = self.ctrl:GetPetInfoById(info.pet_grid)
        if pet_info then
            self.pet_icon:SetItemInfo(pet_info)
            self._layout_objs.btn_add_futi:SetVisible(false)
        end
        for _, v in pairs(info.internals) do
            self.neidan[v.grid]:SetItemInfo(v)
            self.neidan[v.grid]:SetPetInfo(info.pet_grid)
            self.neidan[v.grid]:AddClickEvent(function()
                self.ctrl:OpenNeidanUpgradeView(self.cur_zhenfa, v.grid)
            end)
        end
        for i = 1, 8 do
            if self.neidan[i]:GetItemInfo() == nil then
                self.neidan[i]:SetBtnAddVisible(true)
                self.neidan[i]:AddClickEvent(function()
                    self.ctrl:OpenNeidanAppendView(self.cur_zhenfa, i)
                end)
                break
            end
        end
    else
        self.neidan[1]:SetBtnAddVisible(true)
        self.neidan[1]:AddClickEvent(function()
            self.ctrl:OpenNeidanAppendView(self.cur_zhenfa, 1)
        end)
    end
end

function PetFutiView:SetNeidanAttr()
    for i = 1, 16 do
        self._layout_objs["key" .. i]:SetText("")
        self._layout_objs["value" .. i]:SetText("")
    end

    local add_attr = {}
    local total_fight = 0
    for _, v in ipairs(config.pet_zhenfa) do
        local info = self.ctrl:GetAttach(v.id)
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

return PetFutiView