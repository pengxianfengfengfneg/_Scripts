local InfoDescView = Class(game.BaseView)

function InfoDescView:_init()
    self._package_name = "ui_game_msg"
    self._com_name = "info_desc_view"

    self._view_level = game.UIViewLevel.Fouth
    self._mask_type = game.UIMaskType.Full
end

function InfoDescView:OpenViewCallBack(id, param)
    local info = config.activity_desc[id]

    self:GetBgTemplate("common_bg"):SetTitleName(info.title)

    local list = self:CreateList("list", "game/gamemsg/info_desc_item")
    list:SetRefreshItemFunc(function(item, idx)
        local desc = info.desc[idx]
        item:SetItemInfo(desc, param and param[idx] or nil)
        item:SetBGVisible(idx % 2 == 1)
    end)

    list:SetItemNum(#info.desc)
end

function InfoDescView:OnEmptyClick()
    self:Close()
end

return InfoDescView