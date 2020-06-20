local MountItem = Class(game.UITemplate)

function MountItem:_init()
    self.ctrl = game.ExteriorCtrl.instance
end

function MountItem:OpenViewCallBack()
    self:Init()
    self:GetRoot():AddClickCallBack(handler(self, self.OnItemClick))
end

function MountItem:CloseViewCallBack()
    self:StopTimeCounter()
end

function MountItem:Init()
    self.txt_name = self._layout_objs["txt_name"]
    self.txt_expire = self._layout_objs["txt_expire"]

    self.img_ycd = self._layout_objs["img_ycd"]
    self.mount_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")
end

function MountItem:SetItemInfo(item_info)
    self.item_info = item_info

    local mount_cfg = config.exterior_mount[item_info.id]
    self.txt_name:SetText(mount_cfg.name)
    self.mount_item:SetItemInfo({id = mount_cfg.item_id})
    
    self:StartTimeCounter(item_info.expire_time)
end

function MountItem:SetExpireText(expire_time)
    local str = ""
    local server_time = global.Time:GetServerTime()
    if not expire_time or (server_time >= expire_time and expire_time ~= 0) then
        str = config.words[5510]
    elseif expire_time == 0 then
        str = config.words[5509]
    else
        local second = expire_time - server_time
        str = self:GetTime(second)
    end
    self.txt_expire:SetText(str)
    return (not expire_time) or (server_time >= expire_time) or (expire_time == 0)
end

function MountItem:OnItemClick()
    if self.click_func then
        self.click_func()
    end
end

function MountItem:SetClickFunc(click_func)
    self.click_func = click_func
end

function MountItem:GetTime(second)
    local day = math.floor(second / 86400)
    local hour = math.floor(second % 86400 / 3600)
    local minute = second % 3600 / 60
    if day > 0 then
        return string.format("[color=#367a21]%d%s%d%s[/color]", day, config.words[107], hour, config.words[108])
    elseif hour > 1 then
        return string.format("[color=#367a21]%d%s[/color]", math.ceil(hour), config.words[108])
    else
        return string.format("[color=#367a21]%d%s[/color]", math.ceil(minute), config.words[103])
    end
end

function MountItem:GetItemInfo()
    return self.item_info
end

function MountItem:SetEquipState(val)
    self.img_ycd:SetVisible(val)
end

function MountItem:StartTimeCounter(expire_time)
    self:StopTimeCounter()
    self.tw_time = DOTween:Sequence()
    self.tw_time:AppendCallback(function()
        local is_stop = self:SetExpireText(expire_time)
        if is_stop then
            self:StopTimeCounter()
        end
    end)
    self.tw_time:AppendInterval(1)
    self.tw_time:SetLoops(-1)
    self.tw_time:Play()
end

function MountItem:StopTimeCounter()
    if self.tw_time then
        self.tw_time:Kill(false)
        self.tw_time = nil
    end
end

return MountItem
