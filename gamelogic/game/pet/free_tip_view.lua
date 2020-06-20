local FreeTipView = Class(game.BaseView)

function FreeTipView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "free_tip_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function FreeTipView:OnEmptyClick()
    self:Close()
end

function FreeTipView:OpenViewCallBack(info)
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1660])
    self._layout_objs["common_bg/btn_close"]:SetVisible(false)
    self._layout_objs["common_bg/btn_back"]:SetVisible(false)

    self._layout_objs.btn_cancel:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs.btn_ok:AddClickCallBack(function()
        self.ctrl:SendFreePet(info.grid)
        self:Close()
    end)

    self._layout_objs.text:SetText(string.format(config.words[1540], info.name))
    self._layout_objs.level:SetText(info.level)
    self._layout_objs.star:SetText(info.star)
    self._layout_objs.savvy:SetText(info.savvy_lv)
    self._layout_objs.grow:SetText(config.words[1520 + info.growup_lv] .. info.growup_rate)
    local color = cc.GoodsColor[info.growup_lv]
    self._layout_objs.grow:SetColor(color.x, color.y, color.z, color.w)

    local pet_cfg = config.pet[info.cid]
    local free_cfg = config.pet_free[pet_cfg.carry_lv]
    local exp_base = 0
    for _, v in ipairs(free_cfg) do
        if info.growup_rate >= v.min_growup_rate and info.growup_rate <= v.max_growup_rate then
            exp_base = v.exp_base
        end
    end
    local exp_factor = config.pet_level[info.level].exp_factor
    local total = math.floor(exp_base * exp_factor)
    local full_num = math.floor(total / config.pet_common.pet_exp_pill_max)
    local total_num = math.ceil(total / config.pet_common.pet_exp_pill_max)
    local goods_cfg = config.goods[config.pet_common.pet_exp_pill_id].name
    if full_num > 0 then
        self._layout_objs.exp_desc:SetText(string.format(config.words[1498], total, total_num, goods_cfg, full_num, goods_cfg))
    else
        self._layout_objs.exp_desc:SetText(string.format(config.words[1499], total, total_num, goods_cfg))
    end
end

return FreeTipView