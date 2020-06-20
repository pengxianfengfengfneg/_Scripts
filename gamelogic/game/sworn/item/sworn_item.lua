local SwornItem = Class(game.UITemplate)

local PageIndex = {
    Member = 0,
    None = 1,
}

function SwornItem:_init(ctrl)
    self.ctrl = game.SwornCtrl.instance
end

function SwornItem:OpenViewCallBack()
    self.txt_senior = self._layout_objs.txt_senior
    self.txt_level = self._layout_objs.txt_level
    self.txt_name = self._layout_objs.txt_name
    self.txt_title = self._layout_objs.txt_title
    self.txt_pos = self._layout_objs.txt_pos

    self.img_bg = self._layout_objs.img_bg
    self.img_bg2 = self._layout_objs.img_bg2
    self.img_career = self._layout_objs.img_career

    self.head_icon = self:GetIconTemplate("head_icon")

    self.btn_modify = self._layout_objs.btn_modify
    self.btn_modify:AddClickCallBack(function()
        local sworn_info = self.ctrl:GetSwornInfo()
        local group_name = sworn_info.group_name
        if group_name ~= "" then
            self.ctrl:OpenSwornStyleNameView()
        else
            game.GameMsgCtrl.instance:PushMsg(config.words[6242])
        end
    end)
    
    self.btn_platform = self._layout_objs.btn_platform
    self.btn_platform:AddClickCallBack(function()
        self.ctrl:OpenSwornPlatformView()
    end)

    self.btn_option = self._layout_objs.btn_option
    self.btn_option:AddClickCallBack(function()
        if self.info then
            self.ctrl:OpenSwornItemOptionView(self.info, self.idx)
        end
    end)

    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
end

function SwornItem:SetItemInfo(item_info, idx)
    local page_idx = PageIndex.None
    self.info = item_info
    self.idx = idx

    if item_info then
        local is_self = item_info.role_id == game.RoleCtrl.instance:GetRoleId()
        self.btn_option:SetVisible(not is_self)

        local senior_name = is_self and config.words[6252] or self.ctrl:GetSeniorName2(item_info.senior, item_info.gender)
        self.txt_senior:SetText(senior_name)
        self.txt_level:SetText(item_info.lv)
        self.txt_name:SetText(item_info.name)

        self.txt_title:SetText(self.ctrl:GetColoredTitle(item_info.role_id))

        if item_info.scene == 0 then
            self.txt_pos:SetText(config.words[6254])
        else
            self.txt_pos:SetText(string.format(config.words[6253], config.scene[item_info.scene].name))
        end

        self.img_career:SetSprite("ui_common", "career"..item_info.career)
        self.head_icon:UpdateData(item_info)

        self.btn_modify:SetVisible(is_self)

        page_idx = PageIndex.Member
    end

    self.img_bg:SetVisible(idx%2==1)
    self.img_bg2:SetVisible(idx%2==0)

    self.ctrl_page:SetSelectedIndexEx(page_idx)
end

return SwornItem