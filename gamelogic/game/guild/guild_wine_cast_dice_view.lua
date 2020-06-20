local GuildWineCastDiceView = Class(game.BaseView)

function GuildWineCastDiceView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_wine_cast_dice_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildWineCastDiceView:_delete()
    
end

function GuildWineCastDiceView:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
end

function GuildWineCastDiceView:CloseViewCallBack()

end

function GuildWineCastDiceView:Init()
    self.txt_exp = self._layout_objs["txt_exp"]
    self.txt_dice_num = self._layout_objs["txt_dice_num"]

    self.btn_cast_dice = self._layout_objs["btn_cast_dice"]
    self.btn_cast_dice:SetText(config.words[4752])
    self.btn_cast_dice:AddClickCallBack(function()
        if not self.dice_data then
            self.ctrl:SendGuildWineActDice()
        else
            self:Close()
        end
    end)

    self.dice_data = self.ctrl:GetGuildWineDiceData()
    self:SetDiceData(self.dice_data)
    self:SetDiceNumText(self.dice_data)
    self:SetBtnDiceText()
end

function GuildWineCastDiceView:SetDiceData(data)
    if not data then
        for i=1, 5 do
            self._layout_objs["img_dice"..i]:SetSprite("ui_guild", "dice"..math.random(1, 6))
        end
    else
        for k, v in ipairs(data) do
            local num = v.num
            self._layout_objs["img_dice"..k]:SetSprite("ui_guild", "dice"..num)
        end
    end
end

function GuildWineCastDiceView:OnWineDice(data)
    self:SetDiceNumText(data)

    for k, v in ipairs(data) do
        local num = v.num
        self._layout_objs["img_dice"..k]:SetSprite("ui_guild", "dice"..num)
        self._layout_objs["mc_dice"..k]:SetPlaySettings(k - 1, -1 , 0, -1)
    end
    self:GetRoot():PlayTransition("t0")
    self:SetBtnDiceText()
end

function GuildWineCastDiceView:OnEmptyClick()
    self:Close()
end

function GuildWineCastDiceView:SetBtnDiceText()
    if not self.dice_data then
        self.btn_cast_dice:SetText(config.words[4752])
    else
        self.btn_cast_dice:SetText(config.words[4770])
    end
end

function GuildWineCastDiceView:SetDiceNumText(data)
    local count = 0
    if data and table.nums(data) > 0 then
        table.walk(data, function(v)
            count = count + v.num
        end)
    end
    self.txt_dice_num:SetText(string.format(config.words[4753], count))
end

function GuildWineCastDiceView:RegisterAllEvents()
    local events = {
        [game.GuildEvent.OnWineDice] = function(data)
            -- dice_num__T__num@C			// 5个骰子结果列表
            self.dice_data = data.dice_num
            self:OnWineDice(data.dice_num)
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return GuildWineCastDiceView
