local MsgTipsView2 = Class(game.BaseView)

function MsgTipsView2:_init()
    self._package_name = "ui_game_msg"
    self._com_name = "msg_tips_view2"

    self._ui_order = game.UIZOrder.UIZOrder_Tips
    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Standalone
end

function MsgTipsView2:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(self.title or config.words[102])
    self._layout_objs["txt_content"]:SetText(self.content)
    self._layout_objs["btn1"]:SetText(self.btn1_txt or config.words[100])
    local btn_func1 = function()
        if self.btn1_func then
            self.btn1_func()
        end
        self:Close()
    end
    self._layout_objs["btn1"]:AddClickCallBack(btn_func1)
    self._layout_objs["btn2"]:SetText(self.btn2_txt or config.words[101])
    local btn_func2 = function()
        if self.btn2_func then
            self.btn2_func()
        end
        self:Close()
    end
    self._layout_objs["btn2"]:AddClickCallBack(btn_func2)

    self._layout_objs.btn_checkbox:AddChangeCallback(function(event_type)
        local is_selected = (event_type == game.ButtonChangeType.Selected)
        if self.check_func then
            self.check_func(is_selected)
        end
    end)
    self._layout_objs.txt_checkbox:SetText(self.check_text or config.words[124])
    self._layout_objs.btn_checkbox:SetSelected(self.check_state or false)

    local c_btn = self:GetRoot():GetController("c_btn")
    if self.btn2_txt then
        c_btn:SetSelectedIndexEx(0)
    else
        c_btn:SetSelectedIndexEx(1)
    end
    local c_checkbox = self:GetRoot():GetController("c_checkbox")
    if self.check_func then
        c_checkbox:SetSelectedIndexEx(1)
    else
        c_checkbox:SetSelectedIndexEx(0)
    end
end

function MsgTipsView2:CloseViewCallBack()
    self.btn1_txt = nil
    self.btn1_func = nil
    self.btn2_txt = nil
    self.btn2_func = nil
    self.title = nil
    self.content = nil
    self.check_state = nil
    self.check_text = nil
    self.check_func = nil
    self.empty_func = nil
end

function MsgTipsView2:SetBtn1(str, func)
    self.btn1_txt = str
    self.btn1_func = func
end

function MsgTipsView2:SetBtn2(str, func)
    self.btn2_txt = str
    self.btn2_func = func
end

function MsgTipsView2:SetTitle(str)
    self.title = str
end

function MsgTipsView2:SetContent(str)
    self.content = str
end

function MsgTipsView2:SetCheckBox(state, func, text)
    self.check_state = state
    self.check_func = func
    self.check_text = text
end

function MsgTipsView2:OnEmptyClick()
    if self.empty_func then
        self.empty_func()
    end
end

function MsgTipsView2:SetEmptyClickFunc(func)
    self.empty_func = func
end

return MsgTipsView2
