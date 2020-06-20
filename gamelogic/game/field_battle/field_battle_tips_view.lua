local FieldBattleTipsView = Class(game.BaseView)

function FieldBattleTipsView:_init(ctrl)
    self._package_name = "ui_field_battle"
    self._com_name = "field_battle_tips_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third
end

function FieldBattleTipsView:OpenViewCallBack(str_content, ok_callback, cancel_callback)
    self.str_content = str_content
    self.ok_callback = ok_callback
    self.cancel_callback = cancel_callback

    self:Init()
end

function FieldBattleTipsView:CloseViewCallBack()
    
end

function FieldBattleTipsView:Init()
    self.rtx_content = self._layout_objs["rtx_content"]
    self.rtx_content:SetText(self.str_content)

    self.btn_ok = self._layout_objs["btn_ok"]
    self.btn_ok:AddClickCallBack(function()
        if self.ok_callback then
            self.ok_callback()
        end
        self:Close()
    end)

    self.btn_cancel = self._layout_objs["btn_cancel"]
    self.btn_cancel:AddClickCallBack(function()
        if self.cancel_callback then
            self.cancel_callback()
        end
        self:Close()
    end)
   
end

function FieldBattleTipsView:UpdateData()
    
end

function FieldBattleTipsView:OnEmptyClick()
    self:Close()
end

return FieldBattleTipsView
