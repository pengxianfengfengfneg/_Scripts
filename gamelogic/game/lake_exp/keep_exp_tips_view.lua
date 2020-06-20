local KeepExpTipsView = Class(game.BaseView)

function KeepExpTipsView:_init(ctrl)
    self._package_name = "ui_lake_exp"
    self._com_name = "keep_exp_tips_view"
    self.ctrl = ctrl

    self._ui_order = game.UIZOrder.UIZOrder_Tips
    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Standalone
end

function KeepExpTipsView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
end

function KeepExpTipsView:CloseViewCallBack()

end

function KeepExpTipsView:RegisterAllEvents()
    local events = {
        
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function KeepExpTipsView:Init()
    self._layout_objs.btn_ok:AddClickCallBack(function()
        game.ShopCtrl.instance:OpenViewByItemId(config.kill_mon_exp_info.item_id)
        self:Close()
    end)

    self:GetRoot():GetController("ctrl_page"):SetSelectedIndexEx(1)
end

function KeepExpTipsView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[102])
end

return KeepExpTipsView
