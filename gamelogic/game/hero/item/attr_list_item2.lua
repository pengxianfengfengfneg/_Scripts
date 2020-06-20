local AttrListItem = Class(game.UITemplate)

function AttrListItem:SetItemInfo(attrs)
    for i = 1, 2 do
        if attrs[i] then
            if attrs[i][1] < 100 then
                self._layout_objs["key" .. i]:SetText(config.combat_power_battle[attrs[i][1]].name)
            else
                self._layout_objs["key" .. i]:SetText(config.combat_power_base[attrs[i][1] - 100].name)
            end
            self._layout_objs["value" .. i]:SetText(attrs[i][2])
        else
            self._layout_objs["key" .. i]:SetText("")
            self._layout_objs["value" .. i]:SetText("")
        end
    end
end

function AttrListItem:SetBg(val)
    self._layout_objs.bg:SetVisible(val)
end

return AttrListItem