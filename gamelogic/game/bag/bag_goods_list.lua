local BagGoodsList = Class(game.UITemplate)

local _auto_use_cfg = config.sys_config.auto_use_item.value
local _cfg = config.goods

function BagGoodsList:OpenViewCallBack()
    local auto_use_item = game.BagCtrl.instance.auto_use_item
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    local career = game.RoleCtrl.instance:GetCareer()
    self.list = self:CreateList("list", "game/bag/item/goods_item", true)
    self.list:SetRefreshItemFunc(function(item, idx)
        local info = self.goods_list[idx]
        if info then
            item:SetItemInfo(info)
            local cfg = _cfg[info.id]
            item:SetRedMaskVisible(cfg.lv > role_lv)
            if cfg.pos >= 1 and cfg.pos <= 8 then
                if (cfg.career == career or cfg.career == 0) and game.FoundryCtrl.instance:CalEquipOffsetScore(info) > 0 then
                    item:SetEquipWearTips(true)
                end
            end
            if game.__DEBUG__ and game.BagCtrl.instance:GetShowBagCell() then
                item:SetItemLevel(info.pos)
            end
            item:AddClickEvent(function()
                game.BagCtrl.instance:OpenTipsView(info, 1, true)
            end)
            for i, v in ipairs(auto_use_item) do
                if v.id == info.id and v.cd > 0 then
                    item:SetFillTween(v.cd / _auto_use_cfg[i][2], 0, v.cd)
                end
            end
        else
            item:ResetItem()
            item:ResetFunc()
        end
    end)
end

function BagGoodsList:CloseViewCallBack()
    self.list = nil
    self.goods_list = nil
end

function BagGoodsList:RefreshGoods(goods_list)
    self.goods_list = goods_list
    if self.goods_list == nil then
        self.goods_list = {}
    end

    local max_size = config.bag[1].size
    self.list:SetItemNum(max_size)
end

return BagGoodsList