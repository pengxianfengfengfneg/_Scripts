local StorageRenameView = Class(game.BaseView)

function StorageRenameView:_init(ctrl)
    self._package_name = "ui_bag"
    self._com_name = "storage_rename_view"
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function StorageRenameView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1675])

    self:InitBtn()

    self:SetStorageInfo()
end

function StorageRenameView:InitBtn()
    self._layout_objs.btn_cancel:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs.btn_save:AddClickCallBack(function()
        self.list:Foreach(function(item)
            item:SaveNewName()
        end)
        self:Close()
    end)
end

function StorageRenameView:SetStorageInfo()
    local storages = {}
    for _, v in pairs(config.bag) do
        if v.id >= 3 then
            table.insert(storages, v)
        end
    end
    table.sort(storages, function(a, b)
        return a.id < b.id
    end)

    self.list = self:CreateList("list", "game/bag/item/rename_item")
    self.list:SetRefreshItemFunc(function(item, idx)
        local info = storages[idx]
        if info then
            item:SetItemInfo(info)
        end
    end)
    self.list:SetItemNum(#storages)
end

return StorageRenameView
