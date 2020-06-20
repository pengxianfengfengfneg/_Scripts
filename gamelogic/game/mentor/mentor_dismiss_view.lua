local MentorDismissView = Class(game.BaseView)

local _config_kick_reason = config.mentor_kick_reason

function MentorDismissView:_init(ctrl)
    self._package_name = "ui_mentor"
    self._com_name = "dismiss_view"
    self.ctrl = ctrl

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full
end

function MentorDismissView:OpenViewCallBack(role_id)
    self.role_id = role_id
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
end

function MentorDismissView:CloseViewCallBack()
    self.member_idx = nil
    self.reason_idx = nil
end

function MentorDismissView:RegisterAllEvents()
    local events = {
        
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MentorDismissView:Init()
    self.list_member = self:CreateList("list_member", "game/mentor/template/dismiss_item")
    self.list_member:SetRefreshItemFunc(function(item, idx)
        local item_info = self.member_list_data[idx].info
        item:SetItemInfo(item_info)
    end)

    self.ctrl_member = self:GetRoot():AddControllerCallback("ctrl_member", function(idx)
        self.member_idx = idx + 1
    end)

    self.btn_cancel = self._layout_objs["btn_cancel"]
    self.btn_cancel:AddClickCallBack(function()
        self:Close()
    end)

    self.btn_ok = self._layout_objs["btn_ok"]
    self.btn_ok:AddClickCallBack(function()
        if self.member_idx and self.reason_idx then
            local member_info = self.member_list_data[self.member_idx].info
            local data = {}
            data.role_id = member_info.role_id
            data.name = member_info.name
            data.reason_idx = self.reason_idx
            self.ctrl:ShowMentorKickUI(data)
            self:Close()
        end
    end)

    for i=1, 3 do
        self._layout_objs["txt_reason"..i]:SetText(_config_kick_reason[i].desc)
    end

    self.ctrl_reason = self:GetRoot():AddControllerCallback("ctrl_reason", function(idx)
        self.reason_idx = idx + 1
    end)
    self.ctrl_reason:SetSelectedIndexEx(0)

    self:UpdateMemberList()
end

function MentorDismissView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6418])
end

function MentorDismissView:UpdateMemberList()
    self.member_list_data = self.ctrl:GetMemberList()

    if self.member_list_data then
        local item_num = #self.member_list_data
        self.list_member:SetItemNum(item_num)
        self.ctrl_member:SetPageCount(item_num)

        if not self.member_idx then
            local idx = 0
            if self.role_id then
                for k, v in ipairs(self.member_list_data) do
                    if v.info.role_id == self.role_id then
                        idx = k - 1
                        break
                    end
                end
            end
            self.ctrl_member:SetSelectedIndexEx(idx)
        end
    end
end

return MentorDismissView
