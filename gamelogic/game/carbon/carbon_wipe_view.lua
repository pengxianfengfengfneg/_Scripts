local CarbonWipeView = Class(game.BaseView)

local _cfg_dun_lv = config.dungeon_lv

function CarbonWipeView:_init(ctrl)
    self._package_name = "ui_carbon"
    self._com_name = "carbon_wipe_view"
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function CarbonWipeView:OnEmptyClick()
    self:Close()
end

function CarbonWipeView:OpenViewCallBack(result_info)

    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1404])

    local list = self:CreateList("list", "game/carbon/item/wipe_item")
    list:SetRefreshItemFunc(function(item, idx)
        local item_info = result_info.rewards[idx]
        item:SetDunID(result_info.dung.id)
        item:SetItemInfo(item_info.reward)
        item:SetBG(idx % 2 == 1)
    end)
    list:SetItemNum(#result_info.rewards)

    local dun_cfg = _cfg_dun_lv[result_info.dung.id]
    local max_lv = result_info.dung.max_lv
    if max_lv > #dun_cfg then
        max_lv = #dun_cfg
    else
        max_lv = max_lv - 1
    end
    local now_lv = result_info.dung.now_lv
    if now_lv > #dun_cfg then
        now_lv = #dun_cfg
    else
        now_lv = now_lv - 1
    end
    self._layout_objs.first_name:SetText(dun_cfg[1].name)
    self._layout_objs.max_name:SetText(dun_cfg[now_lv].name)
    self._layout_objs.bar:SetMax(max_lv)
    self._layout_objs.bar:SetValue(now_lv)
end

return CarbonWipeView