local AchieveCompleteView = Class(game.BaseView)

function AchieveCompleteView:_init()
    self._package_name = "ui_achieve"
    self._com_name = "achieve_complete_view"
    self._ui_order = game.UIZOrder.UIZOrder_Main_UI
    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone

end

function AchieveCompleteView:OpenViewCallBack(info)
    self.info = info

    self:BindEvent(game.AchieveEvent.AchieveInfo, function(data)
        self:CheckGetState(data)
    end)
    self._layout_objs.btn:AddClickCallBack(function()
        game.AchieveCtrl.instance:SendGetReward(info.id)
    end)

    local id = math.floor(info.id / 100)
    local idx = info.id % 100
    local cfg = config.achieve_task[id][idx]
    self._layout_objs.name:SetText(cfg.name)
    for i = 1, 5 do
        self._layout_objs["star" .. i]:SetVisible(cfg.show_star >= i)
    end
    local reward = config.drop[cfg.reward].client_goods_list[1]
    if config.money_type[reward[1]] then
        self._layout_objs.num:SetText(reward[2])
        self._layout_objs.icon:SetSprite("ui_common", config.money_type[reward[1]].icon)
    else
        self._layout_objs.num:SetText("")
    end

    self:GetRoot():PlayTransition("t0", function()
        self:Close()
    end)

end

function AchieveCompleteView:CheckGetState(data)
    for _, v in pairs(data.tasks) do
        if v.id == self.info.id and v.state == 4 then
            self:Close()
            break
        end
    end
end

return AchieveCompleteView