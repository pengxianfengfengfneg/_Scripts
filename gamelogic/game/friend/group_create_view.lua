local GroupCreateView = Class(game.BaseView)

function GroupCreateView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "group_create_view"
    self._view_level = game.UIViewLevel.Third
    self.ctrl = ctrl
end

function GroupCreateView:OpenViewCallBack()

    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1719])

    self._layout_objs["cancel_btn"]:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs["ok_btn"]:AddClickCallBack(function()
        self:OnCreate()
    end)

    for i = 1, 8 do
        self._layout_objs["btn_checkbox"..i]:SetSelected(false)
        self._layout_objs["btn_checkbox"..i]:AddClickCallBack(function()
            self.select_index = nil
            if self._layout_objs["btn_checkbox"..i]:GetSelected() then
                self:OnSelect(i)
            end
        end)
    end

    self._layout_objs["btn_checkbox1"]:SetSelected(true)
    self.select_index = 1
end

function GroupCreateView:OnCreate()

    local group_name = self._layout_objs["input_title"]:GetText()
    local group_notice = self._layout_objs["input_notice"]:GetText()

    if group_name ~= "" then

        if group_notice ~= "" then

            if self.select_index then
                if game.Utils.CheckMaskChatWords(group_name) then
                    game.GameMsgCtrl.instance:PushMsgCode(1413)
                else
                    if game.Utils.CheckMaskChatWords(group_notice) then
                        game.GameMsgCtrl.instance:PushMsgCode(1413)
                    else
                        self.ctrl:CsFriendSysCreateGroup(self.select_index, group_name, group_notice)
                        self:Close()
                    end
                end
            else
                game.GameMsgCtrl.instance:PushMsg(config.words[1722])
            end
        else
            game.GameMsgCtrl.instance:PushMsg(config.words[1721])
        end
    else
        game.GameMsgCtrl.instance:PushMsg(config.words[1720])
    end
end

function GroupCreateView:OnSelect(index)
    for i = 1, 8 do
        if i ~= index then
            self._layout_objs["btn_checkbox"..i]:SetSelected(false)
        end
    end

    self.select_index = index
end

return GroupCreateView