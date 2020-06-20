local BlockChangeNameView = Class(game.BaseView)

function BlockChangeNameView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "block_change_name_view"
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function BlockChangeNameView:OpenViewCallBack(block_id, block_name)
	self._layout_objs["txt_title"]:SetText(block_name)

	self._layout_objs["create_btn"]:AddClickCallBack(function()

        local str = self._layout_objs["n2"]:GetText()
        if str ~= "" then
            self.ctrl:CsFriendSysRenameBlock(block_id, str)
        else

        end
        self:Close()
    end)

    self._layout_objs["cancel_btn"]:AddClickCallBack(function()
        self:Close()
    end)
end

return BlockChangeNameView