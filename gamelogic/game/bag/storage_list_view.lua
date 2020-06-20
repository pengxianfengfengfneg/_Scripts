local StorageListView = Class(game.BaseView)

function StorageListView:_init(ctrl)
    self._package_name = "ui_bag"
    self._com_name = "storage_list_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.None

    self.ctrl = ctrl
end

function StorageListView:OpenViewCallBack()
    local storages = {}
    for _, v in pairs(config.bag) do
        if v.id >= 3 then
            table.insert(storages, v)
        end
    end
    table.sort(storages, function(a, b)
        return a.id < b.id
    end)

    for i, v in ipairs(storages) do
        local storage_info = self.ctrl:GetGoodsBagByBagId(v.id)
        self._layout_objs["n" .. i]:SetGray(storage_info == nil)
        if storage_info then
            self._layout_objs["n" .. i]:SetText(storage_info.name)
            self._layout_objs["n" .. i]:AddClickCallBack(function()
                self:FireEvent(game.BagEvent.SelectStorage, v.id)
            end)
        else
            self._layout_objs["n" .. i]:SetText(config.words[1505] .. i)
            self._layout_objs["n" .. i]:AddClickCallBack(function()
                local next_page = 0
                local cost = 0
                for _, val in ipairs(storages) do
                    if self.ctrl:GetGoodsBagByBagId(val.id) == nil then
                        next_page = val.id
                        cost = val.cost
                        break
                    end
                end
                if next_page == 0 then
                    game.GameMsgCtrl.instance:PushMsg(config.words[1560])
                    return
                end
                local str = string.format(config.words[1559], next_page - 2, cost)
                local msg_box = game.GameMsgCtrl.instance:CreateMsgTips(str)
                msg_box:SetBtn1(nil, function()
                    self.ctrl:SendStorageExtend(next_page)
                end)
                msg_box:SetBtn2(config.words[101])
                msg_box:Open()
            end)
        end
    end

    self:GetRoot():AddClickCallBack(function()
        self:Close()
    end)
end

return StorageListView
