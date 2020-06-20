local AddToBlockView = Class(game.BaseView)

function AddToBlockView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "add_block_view"
    self._view_level = game.UIViewLevel.Third
    self.ctrl = ctrl
end

function AddToBlockView:OpenViewCallBack(role_id_list)
    
    self.role_id_list = role_id_list

    for i = 1, 3 do
        self._layout_objs["btn_checkbox"..i]:SetSelected(false)
        self._layout_objs["btn_checkbox"..i]:AddClickCallBack(function()
            self.select_index = nil
            if self._layout_objs["btn_checkbox"..i]:GetSelected() then
                self:OnSelect(i)
            end
        end)
    end

    self._layout_objs["cancel_btn"]:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs["ok_btn"]:AddClickCallBack(function()
        self:OnAdd()
        self:Close()
    end)

    self:Init()
end

function AddToBlockView:Init()

    local block_list = self.ctrl:GetData():GetBlockList()

    local count = 0
    for k, v in ipairs(block_list) do

        self._layout_objs["check_group"..k]:SetVisible(true)
        self._layout_objs["btn_name"..k]:SetText(v.block.name)
        count = count + 1
    end

    for j = count+1, 3 do
        self._layout_objs["check_group"..j]:SetVisible(false)
    end

    local role_num = #self.role_id_list
    self._layout_objs["n12"]:SetText(string.format(config.words[1744], role_num))
end

function AddToBlockView:OnSelect(index)
    for i = 1, 3 do
        if i ~= index then
            self._layout_objs["btn_checkbox"..i]:SetSelected(false)
        end
    end

    self.select_index = index
end

function AddToBlockView:OnAdd()

    if self.select_index then

        if #self.role_id_list > 0 then

            local block_list = self.ctrl:GetData():GetBlockList()
            local block_id = block_list[self.select_index].block.id
            self.ctrl:CsFriendSysAdd2Block(block_id, self.role_id_list)
        else
            game.GameMsgCtrl.instance:PushMsg(config.words[1716])
        end
    else
        game.GameMsgCtrl.instance:PushMsg(config.words[1717])
    end
end

return AddToBlockView