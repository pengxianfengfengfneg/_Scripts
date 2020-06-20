local HonorView = Class(game.BaseView)

function HonorView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "honor_preview"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function HonorView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[3206])

    self._layout_objs.total:SetText(string.format(config.words[3207], table.nums(config.title_honor)))

    local honor_cate = {}
    for _, v in pairs(config.title_honor) do
        if honor_cate[v.color] == nil then
            honor_cate[v.color] = {}
        end
        table.insert(honor_cate[v.color], v)
    end

    local list = self:CreateList("list", "game/role/item/honor_list_item")
    list:SetRefreshItemFunc(function(item, idx)
        local info = honor_cate[idx + 1]
        item:SetItemInfo(info)
    end)
    list:SetItemNum(table.nums(honor_cate))
end

function HonorView:OnEmptyClick()
    self:Close()
end

return HonorView
