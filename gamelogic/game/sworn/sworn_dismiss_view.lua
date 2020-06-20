local SwornDissmissView = Class(game.BaseView)

function SwornDissmissView:_init(ctrl)
    self._package_name = "ui_sworn"
    self._com_name = "dismiss_view"
    self.ctrl = ctrl

    self._show_money = true

    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
end

function SwornDissmissView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
end

function SwornDissmissView:RegisterAllEvents()
    local events = {
        {game.SwornEvent.UpdateMemberList, handler(self, self.UpdateMemberList)},
        {game.SwornEvent.DeleteMember, handler(self, self.OnDeleteMember)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SwornDissmissView:Init()
    self.list_member = self:CreateList("list_member", "game/sworn/item/dismiss_item")
    self.list_member:SetRefreshItemFunc(function(item, idx)
        local item_info = self.member_list_data[idx].mem
        item:SetItemInfo(item_info)
    end)
    self:UpdateMemberList()

    self.btn_ok = self._layout_objs.btn_ok
    self.btn_ok:AddClickCallBack(function()
        if self.member_idx > 0 and self.checkbox_idx > 0 then
            local mem_info = self.member_list_data[self.member_idx].mem
            self.ctrl:SendSwornDismissMember(mem_info.role_id, self.checkbox_idx)
        end
    end)

    self.btn_cancel = self._layout_objs.btn_cancel
    self.btn_cancel:AddClickCallBack(function()
        self:Close()
    end)

    local max_reason = 6
    for i=1, max_reason do
        local reason_cfg = config.sworn_dismiss_reason[i]
        local txt_reason = self._layout_objs["txt_reason"..i]
        local cb_reason = self._layout_objs["checkbox"..i]

        if reason_cfg then
            txt_reason:SetText(reason_cfg.reason)
        end

        txt_reason:SetVisible(reason_cfg ~= nil)
        cb_reason:SetVisible(reason_cfg ~= nil)
    end

    self.ctrl_checkbox = self:GetRoot():AddControllerCallback("ctrl_checkbox", function(idx)
        self.checkbox_idx = idx + 1
    end)

    self.ctrl_member = self:GetRoot():AddControllerCallback("ctrl_member", function(idx)
        self.member_idx = idx + 1
    end)

    self.ctrl_checkbox:SetSelectedIndexEx(0)
    self.ctrl_member:SetSelectedIndexEx(0)
end

function SwornDissmissView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6276])
end

function SwornDissmissView:UpdateMemberList()
    local member_list = self.ctrl:GetMemberList()
    for k, v in ipairs(member_list) do
        if v.mem.role_id == game.RoleCtrl.instance:GetRoleId() then
            table.remove(member_list, k)
            break
        end
    end
    self.member_list_data = member_list
    self.list_member:SetItemNum(#self.member_list_data)
end

function SwornDissmissView:OnDeleteMember()
    self:Close()
end

return SwornDissmissView
