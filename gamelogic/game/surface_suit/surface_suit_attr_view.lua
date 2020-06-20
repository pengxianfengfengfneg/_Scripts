local SurfaceSuitAttrView = Class(game.BaseView)

function SurfaceSuitAttrView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "surface_suit_attr_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Fouth

    self.ctrl = ctrl
end

function SurfaceSuitAttrView:OpenViewCallBack(id)
    self.suit_id = id

    self:Init()    
    self:InitBg()

    self:RegisterAllEvents()
end

function SurfaceSuitAttrView:CloseViewCallBack()

end

function SurfaceSuitAttrView:RegisterAllEvents()
    local events = {
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SurfaceSuitAttrView:Init()
    self.suit_config = config.surface_suit[self.suit_id]

    self.txt_name = self._layout_objs["txt_name"]
    
    self.btn_look = self._layout_objs["role_fight_com/btn_look"]
    self.btn_look:SetVisible(false)

    self.txt_fight = self._layout_objs["role_fight_com/txt_fight"]
    self.txt_fight:SetText(self:CalcSuitPower())

    self:UpdateAttr()
end

function SurfaceSuitAttrView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1665])
end

function SurfaceSuitAttrView:CalcSuitPower()
    local power = 0

    for k,v in pairs(self.suit_config) do
        if string.match(k,"attr") then
            power = power + game.Utils.CalculateCombatPower(v)
        end
    end

    return power
end

function SurfaceSuitAttrView:UpdateAttr()
    for k,v in pairs(self.suit_config) do
        if string.match(k,"attr") then
            local key = string.format("txt_%s_", k)
            for ck,cv in ipairs(v) do
                local txt = self._layout_objs[key .. ck]
                if txt then
                    local attr_name = config_help.ConfigHelpAttr.GetAttrName(cv[1])
                    txt:SetText(string.format("%s：%s", attr_name, cv[2]))
                end
            end
        end
    end
end

return SurfaceSuitAttrView
