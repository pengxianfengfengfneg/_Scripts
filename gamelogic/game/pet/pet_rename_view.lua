local PetRenameView = Class(game.BaseView)

function PetRenameView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "pet_rename_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function PetRenameView:OnEmptyClick()
    self:Close()
end

function PetRenameView:OpenViewCallBack(info)
    self._layout_objs.btn_cancel:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs.btn_ok:AddClickCallBack(function()
        local new_name = self._layout_objs.input_text:GetText()
        if game.Utils.CheckMaskWords(new_name) then
            game.GameMsgCtrl.instance:PushMsg(config.words[1005])
        else
            self.ctrl:SendPetRename(info.grid, new_name)
            self:Close()
        end
    end)
end

function PetRenameView:CloseViewCallBack()
end


return PetRenameView
