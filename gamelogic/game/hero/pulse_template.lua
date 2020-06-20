local PulseTemplate = Class(game.UITemplate)

function PulseTemplate:OpenViewCallBack()

    self:BindEvent(game.HeroEvent.HeroPulseActive, function()
        self:UpdateFight()
        for _, v in pairs(self.pulse_items) do
            v:SetPulseState()
        end
    end)

    self:BindEvent(game.HeroEvent.HeroPulseTrain, function()
        self:UpdateFight()
    end)

    self:BindEvent(game.HeroEvent.HeroChangePotential, function()
        self:UpdateFight()
    end)

    self:BindEvent(game.HeroEvent.HeroPulseWearEquip, function()
        self:UpdateFight()
    end)

    self.power = self._layout_objs["role_fight_com/txt_fight"]
    self._layout_objs["role_fight_com/btn_look"]:SetVisible(false)

    self:InitBtns()
    self:InitList()
    self:SetPulseItem()
    self:UpdateFight()
end

function PulseTemplate:InitBtns()
    self._layout_objs.btn_treasure:AddClickCallBack(function()
        game.HeroCtrl.instance:OpenTreasureView()
    end)
end

function PulseTemplate:InitList()
    self.list = self:CreateList("list", "game/hero/item/attr_list_item2")

    self.list:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo({ self.attr_list[idx * 2 - 1], self.attr_list[idx * 2] })
        item:SetBg(idx % 2 == 1)
    end)
end

function PulseTemplate:SetPulseItem()
    self.pulse_items = {}
    for _, v in pairs(config.pulse) do
        self.pulse_items[v.id] = self:GetTemplate("game/hero/item/pulse_item", "pulse_item" .. v.id)
        self.pulse_items[v.id]:SetPulseInfo(v)
    end
end

function PulseTemplate:UpdateFight()
    self.power:SetText(game.HeroCtrl.instance:GetPulseFight())

    local attr_map = game.HeroCtrl.instance:GetPulseAttr()
    self.attr_list = {}
    for k, v in pairs(attr_map) do
        table.insert(self.attr_list, { k, v })
    end
    self.list:SetItemNum(math.ceil(#self.attr_list / 2))
end

return PulseTemplate