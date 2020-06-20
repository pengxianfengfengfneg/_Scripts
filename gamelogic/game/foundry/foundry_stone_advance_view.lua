local FoundryStoneAdvanceView = Class(game.BaseView)

function FoundryStoneAdvanceView:_init(ctrl)
    self._package_name = "ui_foundry"
    self._com_name = "stone_advance_view"
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
end

function FoundryStoneAdvanceView:_delete()
end

--宝石提升预览界面
function FoundryStoneAdvanceView:OpenViewCallBack(sour_item)

    self.sour_item_id = sour_item[1]
    self.stone_pos = sour_item[2]

    self._layout_objs["btn_close"]:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs["n34"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:CsEquipAdvStone(self.stone_pos)
        self:Close()
    end)

    self.sour_item = require("game/bag/item/goods_item").New()
    self.sour_item:SetVirtual(self._layout_objs["sour_item"])
    self.sour_item:Open()
    self.sour_item:SetTouchEnable(true)
    self.sour_item:SetShowTipsEnable(true)


    self.target_item = require("game/bag/item/goods_item").New()
    self.target_item:SetVirtual(self._layout_objs["target_item"])
    self.target_item:Open()
    self.target_item:SetTouchEnable(true)
    self.target_item:SetShowTipsEnable(true)

    self.rune_item = require("game/bag/item/goods_item").New()
    self.rune_item:SetVirtual(self._layout_objs["rune_item"])
    self.rune_item:Open()
    self.rune_item:SetTouchEnable(true)
    self.rune_item:ResetItem()
    self.rune_item:SetShowTipsEnable(true)
    self.rune_item:GetRoot():SetVisible(false)

    self:Init()
end

function FoundryStoneAdvanceView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function FoundryStoneAdvanceView:Init()

    local stone_cfg
    for k, v in pairs(config.equip_stone) do

        for item_id, vt in pairs(v) do

            if item_id == self.sour_item_id then
                stone_cfg = vt
                break
            end
        end

        if stone_cfg then
            break
        end
    end

    local sour_item_num = game.BagCtrl.instance:GetNumById(self.sour_item_id)
    local target_item_id = stone_cfg.next_id

    self.sour_item:SetItemInfo({id = self.sour_item_id})
    self.sour_item:SetItemName()

    self.target_item:SetItemInfo({id = target_item_id})
    self.target_item:SetItemName()

    self._layout_objs["n12"]:SetText(string.format(config.words[1223], stone_cfg.cost_num))


    --提升符
    if stone_cfg.rune_num == 0 then
        self._layout_objs["n35"]:SetVisible(false)
    else
        self._layout_objs["n35"]:SetVisible(true)

        local rune_item_id =  config.sys_config["equip_stone_adv_rune"].value
        self.rune_item:SetItemInfo({id = rune_item_id, num = stone_cfg.rune_num})

        local cur_num = game.BagCtrl.instance:GetNumById(rune_item_id)

        self.rune_item:SetNumText(cur_num.."/"..stone_cfg.rune_num)
        self.rune_item:GetRoot():SetVisible(true)

        if cur_num >= stone_cfg.rune_num then
            self.rune_item:SetColor(224, 214, 189)
        else
            self.rune_item:SetColor(255, 0, 0)
        end
    end

    --背包宝石 消耗元宝

    local foundry_data = game.FoundryCtrl.instance:GetData()
    local result, bgold, gold = foundry_data:GetStoneAdvanceCost(target_item_id)
    local length = #result
    local cur_bgold = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.BindGold)
    local cur_gold = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.Gold)
    self._layout_objs["gold_txt"]:SetText(gold)
    self._layout_objs["bgold_txt"]:SetText(bgold)

    if cur_gold >= gold then
        self._layout_objs["gold_txt"]:SetColor(54,122,33,255)
    else
        self._layout_objs["gold_txt"]:SetColor(255, 0, 0,255)
    end

    if cur_bgold >= bgold then
        self._layout_objs["bgold_txt"]:SetColor(54,122,33,255)
    else
        self._layout_objs["bgold_txt"]:SetColor(255, 0, 0,255)
    end

    self.list = self._layout_objs["n22"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/bag/item/goods_item").New()
        item:SetParent(self)
        item:SetVirtual(obj)
        item:Open()
        item:SetShowTipsEnable(true)
        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        local item_info = result[idx]
        item:SetItemInfo({ id = item_info.item_id, num = item_info.item_num})
        item:SetItemName()
    end)

    self.ui_list:SetItemNum(length)
end

return FoundryStoneAdvanceView
