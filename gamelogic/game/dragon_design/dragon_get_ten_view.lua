local DragonGetTenView = Class(game.BaseView)

function DragonGetTenView:_init(ctrl)
    self._package_name = "ui_dragon_design"
    self._com_name = "dragon_get_ten_view"
    self._view_level = game.UIViewLevel.Third
    self.ctrl = ctrl

    self.dragon_design_data = self.ctrl:GetData()
end

function DragonGetTenView:_delete()

end

function DragonGetTenView:OpenViewCallBack(get_items)

    self._layout_objs.btn_ok:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs.btn_again:AddClickCallBack(function()
        self:DoCreateDragon(10)
    end)

    local reward_list = get_items

    self.list = self:CreateList("list", "game/bag/item/goods_item")
    self.list:SetRefreshItemFunc(function(item, idx)
        local info = reward_list[idx]
        item:SetItemInfo({ id = info.id, num = info.num})
        item:SetShowTipsEnable(true)
    end)
    self.list:SetItemNum(#reward_list)

    local cfg = config.sys_config["dragon_condense_cost"].value

    local cur_copper = game.BagCtrl.instance:GetCopper()

    local cur_item = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.DragonDesign)
 
    self._layout_objs["require1"]:SetText(cur_copper.."/"..tostring(cfg[2]*10))
    self._layout_objs["require2"]:SetText(cur_item.."/"..tostring(cfg[1]*10))

    if cur_copper >= cfg[2]*10 then
        self._layout_objs["require1"]:SetColor(224, 214, 189, 255)
    else
        self._layout_objs["require1"]:SetColor(255, 0, 0, 255)
    end

    if cur_item >= cfg[1]*10 then
        self._layout_objs["require2"]:SetColor(224, 214, 189, 255)
    else
        self._layout_objs["require2"]:SetColor(255, 0, 0, 255)
    end

end

function DragonGetTenView:OnEmptyClick()
    self:Close()
end

function DragonGetTenView:DoCreateDragon(times)

    local cfg = config.sys_config["dragon_condense_cost"].value
    local cur_copper = game.BagCtrl.instance:GetCopper()
    local cur_item = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.DragonDesign)

    if cur_item >= cfg[1]*times and  cur_copper < cfg[2]*times then
        game.MainUICtrl.instance:OpenAutoMoneyExchangeView(game.MoneyType.Copper, cfg[2]*times - cur_copper, function()
            self.ctrl:CsDragonCondense(times)
            self:Close()
        end)
    elseif cur_item >= cfg[1]*times and  cur_copper >= cfg[2]*times then
        self.ctrl:CsDragonCondense(times)
        self:Close()
    else
        game.GameMsgCtrl.instance:PushMsg(config.words[6158])
    end
end


return DragonGetTenView