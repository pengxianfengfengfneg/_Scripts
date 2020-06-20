local NeidanCommendView = Class(game.BaseView)

function NeidanCommendView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "commend_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function NeidanCommendView:OnEmptyClick()
    self:Close()
end

function NeidanCommendView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1537])

    local list = self:CreateList("list", "game/pet/item/neidan_commend_item")
    list:AddItemProviderCallback(function(idx)
        return "ui_pet:neidan_commend_item"
    end)
    list:SetRefreshItemFunc(function(item, idx)
        local info = config.pet_neidan_commend[idx]
        item:SetItemInfo(info)
        item:SetBg(idx % 2 == 1)
    end)
    list:SetItemNum(#config.pet_neidan_commend)
end


return NeidanCommendView
