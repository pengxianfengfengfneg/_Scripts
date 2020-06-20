local AchieveItem = Class(game.UITemplate)

function AchieveItem:OpenViewCallBack()
    self._layout_objs.btn:AddClickCallBack(function()
        game.AchieveCtrl.instance:SendGetReward(self.cur_achieve_id)
    end)
end

function AchieveItem:SetItemInfo(info)
    self.info = info
    local type_info = game.AchieveCtrl.instance:GetAchieveTaskInfo(info.id)
    self.cur_achieve_id = type_info.id
    local idx = type_info.id % 100
    local cfg = self.info[idx]
    self._layout_objs.name:SetText(cfg.name)
    self._layout_objs.desc:SetText(cfg.desc)
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
    self._layout_objs.icon:SetVisible(type_info.state ~= 4 or cfg.show_star < 5)
    self._layout_objs.num:SetVisible(type_info.state ~= 4 or cfg.show_star < 5)
    self._layout_objs.n17:SetVisible(type_info.state ~= 4 or cfg.show_star < 5)
    self._layout_objs.btn:SetVisible(type_info.state == 3)
    self._layout_objs.got:SetVisible(type_info.state == 4)
    self._layout_objs.progress:SetVisible(type_info.state < 3)
    if type_info.state < 3 then
        self._layout_objs.progress:SetText(string.format(config.words[3403], type_info.current, cfg.condition[2]))
    end
end

function AchieveItem:SetBG(val)
    if val then
        self._layout_objs.bg:SetSprite("ui_common", "009_1")
    else
        self._layout_objs.bg:SetSprite("ui_common", "009_2")
    end
end

return AchieveItem