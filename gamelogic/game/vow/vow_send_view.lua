local VowSendView = Class(game.BaseView)

function VowSendView:_init(ctrl)
    self._package_name = "ui_vow"
    self._com_name = "ui_vow_send"
    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
    self.ctrl = ctrl
end

function VowSendView:_delete()
end

function VowSendView:OpenViewCallBack()

	self.ctrl:CsVowSeeVow()

	self:BindEvent(game.VowEvent.GetMyVow, function(data)
        self:InitView(data)
    end)

    self.head_icon = self:GetIconTemplate("head_icon")
    local main_role_vo = game.Scene.instance:GetMainRoleVo()
    if main_role_vo then
        self.head_icon:UpdateData(main_role_vo)
    end

    self._layout_objs["n58"]:AddClickCallBack(function()
		local str = self._layout_objs["input_txt"]:GetText()
		if game.Utils.CheckMaskWords(str) then
            game.GameMsgCtrl.instance:PushMsg(config.words[1005])
            return
        else
        	self.ctrl:CsVow(str)
            self:Close()
        end
    end)

    self._layout_objs["remove_btn"]:AddClickCallBack(function ()
        self.ctrl:CsVowRevoke()
        self:Close()
    end)

    self._layout_objs["change_btn"]:AddClickCallBack(function ()
        local str = self._layout_objs["input_txt"]:GetText()
        if game.Utils.CheckMaskWords(str) then
            game.GameMsgCtrl.instance:PushMsg(config.words[1005])
            return
        else
            self.ctrl:CsVow(str)
            self:Close()
        end
    end)

    self._layout_objs["n72"]:AddClickCallBack(function()
        self:Close()
    end)
end

function VowSendView:InitView(data)
    
    if data.is_post == 0 then
        self._layout_objs["n58"]:SetVisible(true)
        self._layout_objs["remove_btn"]:SetVisible(false)
        self._layout_objs["change_btn"]:SetVisible(false)
    else
        self._layout_objs["n58"]:SetVisible(false)
        self._layout_objs["remove_btn"]:SetVisible(true)
        self._layout_objs["change_btn"]:SetVisible(true)
    end

	self._layout_objs["role"]:SetText(tostring(data.level).."."..data.name)

	self._layout_objs["career_img"]:SetSprite("ui_common", "career" .. data.career)

	self._layout_objs["input_txt"]:SetText(data.context)
end

return VowSendView