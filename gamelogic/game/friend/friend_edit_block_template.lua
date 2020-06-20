local FriendEditBlockTemplate = Class(game.UITemplate)

function FriendEditBlockTemplate:_init(parent)
	self.parent = parent
    self.friend_data = game.FriendCtrl.instance:GetData()
end

function FriendEditBlockTemplate:OpenViewCallBack()

    self._layout_objs["change_name_btn"]:AddClickCallBack(function()
        game.FriendCtrl.instance:OpenBlockChangeNameView(self.block_id, self.block_name)
    end)

    self._layout_objs["remove_btn"]:AddClickCallBack(function()
        game.FriendCtrl.instance:CsFriendSysDelBlock(self.block_id)
    end)
end

function FriendEditBlockTemplate:RefreshItem(idx)

    local list_data = self.parent:GetBlockListData()
    local block_data = list_data[idx]
    self.block_id = block_data.block.id
    self.block_name = block_data.block.name

    self._layout_objs["grop_name"]:SetText(self.block_name)

    local role_num = #block_data.block.mem_list
    self._layout_objs["role_num"]:SetText(tostring(role_num))
end

return FriendEditBlockTemplate