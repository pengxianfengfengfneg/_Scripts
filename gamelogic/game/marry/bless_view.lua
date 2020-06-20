local BlessView = Class(game.BaseView)

function BlessView:_init(ctrl)
    self._package_name = "ui_marry"
    self._com_name = "bless_view"

    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function BlessView:OpenViewCallBack()
    local view = self:GetBgTemplate("common_bg"):SetTitleName(config.words[2618])
    view:SetBtnWhVisible(true)
    view:SetInfoCallback(function()
        game.GameMsgCtrl.instance:OpenInfoDescView(9)
    end)

    self.cur_icon = self:GetTemplate("game/bag/item/goods_item", "cur_icon")
    self.next_icon = self:GetTemplate("game/bag/item/goods_item", "next_icon")

    self:SetLoveValue()
    self._layout_objs.role_lv:SetText(game.RoleCtrl.instance:GetRoleLevel())

    self:SetBless()

    self._layout_objs.btn_bless:AddClickCallBack(function()
        game.MarryCtrl.instance:SendMarryBless()
    end)

    self:BindEvent(game.MarryEvent.Bless, function()
        self:SetBless()
    end)
    self:BindEvent(game.MoneyEvent.Change, function()
        self:SetLoveValue()
    end)
end

function BlessView:SetLoveValue()
    self._layout_objs.own_love:SetText(game.BagCtrl.instance:GetMoneyByType(game.MoneyType.LoveValue))
end

function BlessView:SetBless()
    local cur_bless = game.MarryCtrl.instance:GetBless()
    local equip_ring = game.FoundryCtrl.instance:GetEquipInfoByType(7)
    if equip_ring and equip_ring.id ~= 0 then
        self.cur_icon:SetItemInfo({ id = equip_ring.id })
        self.next_icon:SetItemInfo({ id = equip_ring.id })
        self.cur_icon:AddClickEvent(function()
            game.BagCtrl.instance:OpenWearEquipInfoView(equip_ring, true)
        end)
        self.next_icon:AddClickEvent(function()
            local next_ring_info = table.clone(equip_ring)
            if equip_ring.marry_bless + 1 > #config.marry_bless then
                next_ring_info.marry_bless = equip_ring.marry_bless
            else
                next_ring_info.marry_bless = equip_ring.marry_bless + 1
            end
            game.BagCtrl.instance:OpenWearEquipInfoView(next_ring_info, true)
        end)
    else
        self.cur_icon:ResetItem()
        self.next_icon:ResetItem()
    end
    local cur_bless_cfg = config.marry_bless[cur_bless]
    if cur_bless_cfg and cur_bless_cfg.level > 0 then
        self._layout_objs.cur_lv:SetText(config.words[2618] .. cur_bless_cfg.level .. config.words[1217])
        local str = ""
        for i, v in ipairs(cur_bless_cfg.attr) do
            str = str .. config.combat_power_battle[v[1]].name .. "：+" .. v[2]
            if i < #cur_bless_cfg.attr then
                str = str .. "\n"
            end
        end
        self._layout_objs.cur_attr:SetText(str)
        self.cur_icon:SetRingImage(cur_bless_cfg.frame)
    else
        self._layout_objs.cur_lv:SetText("")
        self._layout_objs.cur_attr:SetText("")
        self.cur_icon:SetRingImage("")
    end

    local next_bless_cfg = config.marry_bless[cur_bless + 1]
    if next_bless_cfg then
        self._layout_objs.next_lv:SetText(config.words[2618] .. next_bless_cfg.level .. config.words[1217])
        local str = ""
        for i, v in ipairs(next_bless_cfg.attr) do
            str = str .. config.combat_power_battle[v[1]].name .. "：+" .. v[2]
            if i < #cur_bless_cfg.attr then
                str = str .. "\n"
            end
        end
        self._layout_objs.next_attr:SetText(str)
        self._layout_objs.cost:SetText(next_bless_cfg.love)
        self._layout_objs.need_lv:SetText(next_bless_cfg.role_lv)
        self.next_icon:SetRingImage(next_bless_cfg.frame)
    else
        self._layout_objs.next_lv:SetText(config.words[1219])
        self._layout_objs.next_attr:SetText("")
        self._layout_objs.cost:SetText(config.words[1219])
        self._layout_objs.need_lv:SetText(cur_bless_cfg.role_lv)
        self.next_icon:SetRingImage(cur_bless_cfg.frame)
    end
end

return BlessView
