local PetIconItem = Class(game.UITemplate)

function PetIconItem:OpenViewCallBack()
    self:BindEvent(game.PetEvent.PetChange, function(data)
        if self.info and data.grid == self.info.grid then
            self:SetItemInfo(data)
        end
    end)
    self:SetSelect(false)
end

function PetIconItem:SetItemInfo(info)
    self.info = info

    if info.level then
        self._layout_objs.level:SetText(info.level .. config.words[1217])
    else
        self._layout_objs.level:SetText("")
    end

    local pet_cfg = config.pet[info.cid or info.id]
    local icon = pet_cfg.icon[1]
    if info.grid then
        icon = game.PetCtrl.instance:GetPetIcon(info)
    end
    self._layout_objs["icon"]:SetVisible(true)
    self._layout_objs["icon"]:SetScale(0.76, 0.76)
    self._layout_objs["icon"]:SetSprite("ui_headicon", tostring(icon), true)

    local color = 2
    if info.star then
        if info.star >= 1 and info.star <= 3 then
            color = 3
        elseif info.star >= 4 and info.star <= 6 then
            color = 4
        elseif info.star >= 7 and info.star <= 9 then
            color = 5
        end
    else
        color = 1
    end
    self._layout_objs.bg:SetSprite("ui_common", "item" .. color)

    -- 0:休息 2:附体 5:出战
    self._layout_objs.tag:SetVisible(true)
    if info.stat == 2 then
        self._layout_objs.tag:SetSprite("ui_common", "zs_05")
    elseif info.stat == 5 then
        self._layout_objs.tag:SetSprite("ui_common", "zs_04")
    else
        self._layout_objs.tag:SetVisible(false)
    end
end

function PetIconItem:ResetItem()
    self.info = nil
    self._layout_objs.level:SetText("")
    self._layout_objs["icon"]:SetVisible(false)
    self._layout_objs.tag:SetVisible(false)
    self._layout_objs.bg:SetSprite("ui_common", "item1")
    self:SetSelect(false)
end

function PetIconItem:SetSelect(val)
    self._layout_objs.select:SetVisible(val)
end

function PetIconItem:SetGrayIcon(val)
    self._layout_objs["icon"]:SetGray(val)
end

function PetIconItem:GetItemInfo()
    return self.info
end

function PetIconItem:AddClickEvent(func)
    self.click_func = func
    self:GetRoot():AddClickCallBack(function()

        if self.click_func then
            self.click_func()
        end
    end)
end

return PetIconItem