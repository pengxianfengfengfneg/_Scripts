local PulseHeroView = Class(game.BaseView)

function PulseHeroView:_init(ctrl)
    self._package_name = "ui_hero"
    self._com_name = "pulse_hero_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function PulseHeroView:OpenViewCallBack(id)
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[3120])
    self._layout_objs["common_bg/btn_back"]:SetVisible(false)

    self.list = self:CreateList("list", "game/hero/item/pulse_hero_item")
    self.list:SetRefreshItemFunc(function(item, idx)
        local info = self.hero_list[idx]
        item:SetHeroInfo(info)
        item:SetPulseID(id)
    end)

    self.tab_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
        self:RefreshList(idx + 1)
    end)
    self.tab_controller:SetSelectedIndexEx(0)
end

function PulseHeroView:OnEmptyClick()
    self:Close()
end

function PulseHeroView:RefreshList(idx)
    self.hero_list = {}
    for i, v in pairs(config.hero) do
        local info = self.ctrl:GetHeroInfo(v.id)
        if info and (idx == 1 or idx == v.color) then
            table.insert(self.hero_list, v)
        end
    end

    self.list:SetItemNum(#self.hero_list)
end

return PulseHeroView
