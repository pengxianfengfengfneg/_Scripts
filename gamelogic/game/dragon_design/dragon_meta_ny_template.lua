--龙元凝元
local DragonMetaNYTemplate = Class(game.UITemplate)

function DragonMetaNYTemplate:_init(parent)
	self.parent = parent
	self.ctrl = game.DragonDesignCtrl.instance
	self.dragon_design_data = self.ctrl:GetData()
end

function DragonMetaNYTemplate:_delete()

end

function DragonMetaNYTemplate:OpenViewCallBack()

	self._layout_objs["ny_btn"]:AddClickCallBack(function()
        self:DoCreateDragon(1)
    end)

    self._layout_objs["ny_ten_btn"]:AddClickCallBack(function()
        self:DoCreateDragon(10)
    end)

    self:InitView()

    self:BindEvent(game.DragonDesignEvent.UpdateGetDragon, function(data)
        self:InitView()
    end)

    self:PlayKeepEffect()
end

function DragonMetaNYTemplate:InitView()

    local cfg = config.sys_config["dragon_condense_cost"].value
    self._layout_objs["require1"]:SetText(tostring(cfg[2]))

    local cur_copper = game.BagCtrl.instance:GetCopper()
    self._layout_objs["cur_coin1"]:SetText(tostring(cur_copper))


    self._layout_objs["require2"]:SetText(tostring(cfg[1]))

    local cur_item = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.DragonDesign)
    self._layout_objs["cur_coin2"]:SetText(tostring(cur_item))

    local condense_state = self.dragon_design_data:GetCondenseState()

    for i = 1, 5 do
        self._layout_objs["type"..i]:SetVisible(i==condense_state)
    end
end

function DragonMetaNYTemplate:DoCreateDragon(times)

    local cfg = config.sys_config["dragon_condense_cost"].value
    local cur_copper = game.BagCtrl.instance:GetCopper()
    local cur_item = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.DragonDesign)

    if cur_item >= cfg[1]*times and  cur_copper < cfg[2]*times then
        game.MainUICtrl.instance:OpenAutoMoneyExchangeView(game.MoneyType.Copper, cfg[2]*times - cur_copper, function()
            self.ctrl:CsDragonCondense(times)
        end)
    elseif cur_item >= cfg[1]*times and  cur_copper >= cfg[2]*times then
        self.ctrl:CsDragonCondense(times)
    else
        local item_name = config.goods[16160125].name
        local title = config.words[102]
        local content = string.format(config.words[1332], item_name)
        local tips_view = game.GameMsgCtrl.instance:CreateMsgBox(title, content)
        tips_view:SetOkBtn(function()
            game.ShopCtrl.instance:OpenViewByItemId(16490202)
        end, config.words[5010], true)
        tips_view:SetCancelBtn(function()
        end, config.words[5011])
        tips_view:Open()
    end
end

function DragonMetaNYTemplate:PlayKeepEffect()
    local ui_effect = self:CreateUIEffect(self._layout_objs["effect1"], "effect/ui/dragon_state_ball.ab")
    ui_effect:SetLoop(true)

    local ui_effect2 = self:CreateUIEffect(self._layout_objs["effect2"], "effect/ui/dragon_state_flash.ab")
    ui_effect2:SetLoop(true)
end

return DragonMetaNYTemplate