local GoodsItem = Class(game.UITemplate)

local config_goods = config.goods

function GoodsItem:_init()
    self.show_tips_enable = false
end

function GoodsItem:SetPackage()
    self._package_name = "ui_common"
    self._com_name = "goods_item"
end

function GoodsItem:OpenViewCallBack()
    local func = function()
        if not self.oper_long_click then
            if self.click_func then
                self.click_func(self)
            elseif self.info.val == true then
                game.BagCtrl.instance:OpenRechargeInfoView(self.info)
            elseif self.show_tips_enable and self.info and self.info.val == nil then
                game.BagCtrl.instance:OpenTipsView(self.info, nil, false)
            end
        end
    end

    self:GetRoot():AddClickCallBack(function(_, _, is_double)
        if self.double_click_func then
            if is_double then
                self:ClearTween()
                self.double_click_func()
            else
                self.tween = DOTween.Sequence()
                self.tween:AppendInterval(0.5)
                self.tween:AppendCallback(function()
                    func()
                end)
                self.tween:SetAutoKill(true)
            end
        else
            func()
        end

        self.oper_long_click = false
    end)

    self:SetShowTipsEnable(self.show_tips_enable)
end

function GoodsItem:SetItemInfo(info)
    self:ResetItem()
    info.id = config.money_type[info.id] and config.money_type[info.id].goods or info.id
    self.info = info
    
    local goods_config = config_goods[info.id]
    self._layout_objs["bg"]:SetSprite("ui_common", "item" .. goods_config.color)
    self._layout_objs["image"]:SetVisible(true)

    if info.icon_name then
        self._layout_objs["image"]:SetSprite("ui_item", info.icon_name, true)
    else
        self._layout_objs["image"]:SetSprite("ui_item", goods_config.icon, true)
    end
    if goods_config.name2 ~= "" then
        self._layout_objs["name2"]:SetText(goods_config.name2)
    end
    if goods_config.name3 ~= "" then
        self._layout_objs["name3"]:SetText(goods_config.name3)
    end
    self:SetNum(info.num)

    self:SetBindImg(info.bind)
    self:SetRareImg(info.rare)
end

function GoodsItem:SetNum(num)
    local num = num or 0
    if num <= 1 then
        self._layout_objs["num"]:SetText("")
    else
        self._layout_objs["num"]:SetText(num)
    end
end

function GoodsItem:ResetItem()
    self.info = nil
    self.select_num = 0

    self._layout_objs["bg"]:SetSprite("ui_common", "item1")
    self._layout_objs["image"]:SetVisible(false)
    self._layout_objs["name2"]:SetText("")
    self._layout_objs["name3"]:SetText("")
    self:SetNum()
    self:SetItemLevel()
    self:ResetComposeItem()
    self:ShowMask(false)
    self:SetBtnAddVisible(false)
    self:SetSelect(false)
    self:SetRingImage("")
    self:SetRedMaskVisible(false)
    self:SetGrayMask(false)
    self:SetEquipWearTips(false)
end

function GoodsItem:ResetFunc()
    self.click_func = nil
    self.double_click_func = nil
end

function GoodsItem:SetItemLevel(lv)
    if lv then
        self._layout_objs.lv_bg:SetVisible(true)
        self._layout_objs.lv:SetText(lv)
    else
        self._layout_objs.lv_bg:SetVisible(false)
        self._layout_objs.lv:SetText("")
    end
end

function GoodsItem:AddClickEvent(func)
    self.click_func = func
    if func then
        self:GetRoot():SetTouchEnable(true)
    end
end

function GoodsItem:AddDoubleClickEvent(func)
    self.double_click_func = func
    if func then
        self:GetRoot():SetTouchEnable(true)
    end
end

function GoodsItem:SetSelect(val)
    self.select_val = val
    self._layout_objs.select:SetVisible(val)
end

function GoodsItem:GetSelect()
    return self.select_val
end

function GoodsItem:SetSelectNum(num)
    self.select_num = num
end

function GoodsItem:GetSelectNum()
    return self.select_num or 0
end

function GoodsItem:SetItemImage(name, boundle)
    self._layout_objs["image"]:SetVisible(true)
    self._layout_objs["image"]:SetSprite(boundle or "ui_item", name, true)
end

function GoodsItem:SetShowTipsEnable(val)
    self.show_tips_enable = val

    local root = self:GetRoot()
    if root then
        root:SetTouchEnable(val)
    end
end

function GoodsItem:SetGray(val)
    self:GetRoot():SetGray(val)
end

function GoodsItem:PlayEffect()
    self:CreateUIEffect(self._layout_objs.effect, "effect/ui/zb_shengji.ab")
end

function GoodsItem:GetItemInfo()
    return self.info
end

function GoodsItem:SetNumText(text)
    self._layout_objs["num"]:SetText(text)
end

function GoodsItem:SetLongClickFunc(func)
    self.long_click_func = func

    self:InitLongClick()
end

function GoodsItem:InitLongClick()

    local callback = function ()
        if self.long_click_func then
            self.oper_long_click = true
            self.long_click_func()
        end
    end
    self:GetRoot():SetLongClickLinkCallBack(callback)
end

function GoodsItem:SetTouchEnable(val)
    self:GetRoot():SetTouchEnable(val)
end

function GoodsItem:ResetComposeItem()

    if self._layout_objs["sub_btn"] then
        self._layout_objs["sub_btn"]:SetVisible(false)
    end

    if self._layout_objs["item_name"] then
        self._layout_objs["item_name"]:SetText("")
    end

    if self._layout_objs["bind_img"] then
        self._layout_objs["bind_img"]:SetVisible(false)
    end
end

function GoodsItem:SetBindImg(bind)

    if self._layout_objs["bind_img"] then
        if bind == 1 then
            self._layout_objs["bind_img"]:SetVisible(true)
        else
            self._layout_objs["bind_img"]:SetVisible(false)
        end
    end
end

function GoodsItem:SetColor(r, g, b)
    self._layout_objs["num"]:SetColor(r, g, b, 255)
end

function GoodsItem:ShowTips()
    if self.show_tips_enable and self.info then
        game.BagCtrl.instance:OpenTipsView(self.info, nil, false)
    end
end

function GoodsItem:SetItemName()
    if self._layout_objs["item_name"] then
        local item_id = self.info.id
        self._layout_objs["item_name"]:SetText(config.goods[item_id].name)
    end
end

function GoodsItem:ShowMask(val)
    if self._layout_objs.mask then
        self._layout_objs.mask:SetVisible(val)
    end
end

function GoodsItem:SetAddCallBack(func)
    if self._layout_objs.btn_add then
        self._layout_objs.btn_add:AddClickCallBack(func)
    end
end

function GoodsItem:SetBtnAddVisible(val)
    if val then
        self:GetRoot():SetTouchEnable(val)
    end
    if self._layout_objs.btn_add then
        self._layout_objs.btn_add:SetVisible(val)
    end
end

function GoodsItem:ClearTween()
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

function GoodsItem:SetRareImg(rare)
    if self._layout_objs.rare then
        self._layout_objs.rare:SetVisible(rare == 1)
    end
end

function GoodsItem:SetFillTween(start_value, end_value, duration)
    self._layout_objs.mask:SetFillAmount(start_value)
    self:ShowMask(true)
    self._layout_objs.mask:TweenFillValue(end_value, duration)
end

function GoodsItem:SetGrayImgCover(val)
    if self._layout_objs["gray_img"] then
        self._layout_objs["gray_img"]:SetVisible(val)
    end
end

function GoodsItem:SetArrowVisibel(val)
    if self._layout_objs["arrow_img"] then
        self._layout_objs["arrow_img"]:SetVisible(val)
    end
end

function GoodsItem:SetHdVisible(val)
    if self._layout_objs["hd"] then
        self._layout_objs["hd"]:SetVisible(val)
    end
end

function GoodsItem:SetRingImage(name, pkg)
    if self._layout_objs.ring_img then
        if name ~= "" then
            self._layout_objs.ring_img:SetVisible(true)
            self._layout_objs.ring_img:SetSprite(pkg or "ui_common", name, true)
        else
            self._layout_objs.ring_img:SetVisible(false)
        end
    end
end

function GoodsItem:SetGrayMask(val)
    if self._layout_objs["gray_img"] then
        self._layout_objs["gray_img"]:SetVisible(val)
    end
end

function GoodsItem:SetRedMaskVisible(val)
    if self._layout_objs.red_mask then
        self._layout_objs.red_mask:SetVisible(val)
    end
end

function GoodsItem:SetEquipWearTips(val)
    if self._layout_objs.jt then
        self._layout_objs.jt:SetVisible(val)
    end
end

return GoodsItem