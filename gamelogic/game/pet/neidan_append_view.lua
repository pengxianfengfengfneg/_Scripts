local NeidanAppendView = Class(game.BaseView)

function NeidanAppendView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "neidan_append_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function NeidanAppendView:OnEmptyClick()
    self:Close()
end

function NeidanAppendView:OpenViewCallBack(zhenfa, grid)
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1539])

    self._layout_objs.btn_learn:SetGray(true)
    self._layout_objs.btn_learn:AddClickCallBack(function()
        if self.cur_dan then
            local attach_info = self.ctrl:GetAttach(zhenfa)
            if attach_info then
                local pet_info = self.ctrl:GetPetInfoById(attach_info.pet_grid)
                if pet_info then
                    local pet_cfg = config.pet[pet_info.cid]
                    if pet_cfg.quality ~= 2 and pet_cfg.carry_lv < config.internal_hole[grid] then
                        local str = string.format(config.words[1487], config.internal_hole[grid])
                        local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(str)
                        tips_view:SetBtn1(nil, function()
                            self.ctrl:SendSetNeidan(zhenfa, grid, self.cur_dan.id)
                            self:Close()
                        end)
                        tips_view:SetBtn2(config.words[101])
                        tips_view:Open()
                        return
                    end
                end
            end

            self.ctrl:SendSetNeidan(zhenfa, grid, self.cur_dan.id)
            self:Close()
        end
    end)

    self.goods_item = self:GetTemplate("game/bag/item/goods_item", "skill_item")
    self.goods_item:SetShowTipsEnable(true)
    self.goods_item:ResetItem()

    local neidan_list = {}
    for i, v in ipairs(config.pet_internal) do
        table.insert(neidan_list, v)
    end
    table.sort(neidan_list, function(a, b)
        local a_own = game.BagCtrl.instance:GetNumById(a.material)
        local b_own = game.BagCtrl.instance:GetNumById(b.material)
        return a_own > b_own
    end)

    self.list = self:CreateList("list", "game/bag/item/goods_item")
    self.list:AddClickItemCallback(function(obj)
        self:SetSelectItem(obj:GetItemInfo())
    end)
    self.list:SetRefreshItemFunc(function(item, index)
        local neidan = neidan_list[index]
        local own = game.BagCtrl.instance:GetNumById(neidan.material)
        item:SetItemInfo({ id = neidan.material, num = own })
        item:SetGray(own == 0)
        item:SetSelect(false)
        item:AddClickEvent(function()
            self:SetSelectItem(neidan)
        end)
    end)
    self.list:SetItemNum(#neidan_list)

    self:SetSelectItem(neidan_list[1])
end

function NeidanAppendView:SetSelectItem(dan)
    self.cur_dan = dan
    local goods_cfg = config.goods[dan.material]
    self._layout_objs.name:SetText(goods_cfg.name)
    self._layout_objs.desc:SetText(goods_cfg.desc)
    self.list:Foreach(function(obj)
        local info = obj:GetItemInfo()
        obj:SetSelect(dan.material == info.id)
    end)
    self.goods_item:SetItemInfo({ id = dan.material })

    local own = game.BagCtrl.instance:GetNumById(dan.material)
    local num = 1
    self.goods_item:SetNumText(own .. "/" .. num)
    self._layout_objs.btn_learn:SetTouchEnable(own >= num)
    self._layout_objs.btn_learn:SetGray(own < num)

    self._layout_objs.ratio:SetText(string.format(config.words[1510], 100))
end

return NeidanAppendView