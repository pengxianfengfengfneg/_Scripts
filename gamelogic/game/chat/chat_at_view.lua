local ChatAtView = Class(game.BaseView)

local handler = handler

function ChatAtView:_init(ctrl)
    self._package_name = "ui_chat"
    self._com_name = "chat_at_view"

    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
end

function ChatAtView:OpenViewCallBack(open_channel, group_id)
    self.open_channel = open_channel
    self.group_id = group_id

    self:Init()
    self:InitBg()
    self:InitList()
    self:InitInput()
    
    self:RegisterAllEvents()
end

function ChatAtView:CloseViewCallBack()
    
end

function ChatAtView:RegisterAllEvents()
    local events = {

    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function ChatAtView:Init()
    self.btn_look = self._layout_objs["btn_look"]
    self.btn_look:AddClickCallBack(function()
        self:OnClickBtnLook()
    end)
    
    self.btn_ok = self._layout_objs["btn_ok"]
    self.btn_ok:AddClickCallBack(function()
        if table.nums(self.click_item_list) > 0 then
            local info_list = {}
            for k,v in pairs(self.click_item_list) do
                table.insert(info_list,{
                        k:GetId(),
                        k:GetName(),
                        v
                    })
            end

            table.sort(info_list, function(v1,v2)
                return v1[3]<v2[3]
            end)

            self:FireEvent(game.ChatEvent.UpdateChatAt, info_list)
            self:Close()
        else
            game.GameMsgCtrl.instance:PushMsg(config.words[1335])
        end
    end)

    self.btn_clear = self._layout_objs["btn_clear"]
    self.btn_clear:AddClickCallBack(function()
        self.txt_input:SetText("")
        self:SetClearVisible(false)

        self:UpdateList(self.at_data)
    end)

end

function ChatAtView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1334])
end

function ChatAtView:InitList()
    self.click_item_list = {}

    self.ui_list = self:CreateList("list_item", "game/chat/chat_at_item", true)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetData(idx)
        item:UpdateData(data)
    end)

    self.ui_list:AddClickItemCallback(function(item, idx)
        self.click_item_list[item] = (item:IsSelected() and os.time() or nil)
    end)

    self.at_data = self:GetChannelData()

    self:UpdateList(self.at_data)
end

function ChatAtView:GetData(idx)
    return self.item_data[idx]
end

function ChatAtView:UpdateList(data)
    if self.item_data == data then
        return
    end

    self.click_item_list = {}
    self.ui_list:ClearSelection()

    self.item_data = data
    local item_num = #self.item_data
    self.ui_list:SetItemNum(item_num)
end

function ChatAtView:GetChannelData()
    local data = {}
    if self.open_channel == game.ChatChannel.Guild then
        local main_role_id = game.Scene.instance:GetMainRoleID()
        local members = game.GuildCtrl.instance:GetGuildMembers()
        for _,v in ipairs(members) do
            if v.mem.offline<=0 and (v.mem.id~=main_role_id) then
                table.insert(data, v.mem)
            end
        end
    end

    if self.open_channel == game.ChatChannel.Team then
        local main_role_id = game.Scene.instance:GetMainRoleID()
        local members = game.MakeTeamCtrl.instance:GetTeamMembers()
        for _,v in ipairs(members) do
            if v.member.id ~= main_role_id and v.member.offline<=0 then
                table.insert(data, v.member)
            end
        end
    end

    if self.open_channel == game.ChatChannel.Group then
        local friend_data = game.FriendCtrl.instance:GetData()
        local group_info = friend_data:GetGroupData(self.group_id)
        if group_info then
            local main_role_id = game.Scene.instance:GetMainRoleID()
            for _,v in ipairs(group_info.mem_list) do
                local info = friend_data:GetRoleInfoById(v.roleId)
                if info and info.unit.offline<=0 and info.unit.id~=main_role_id then
                    table.insert(data, info.unit)
                end
            end
        end
    end

    return data
end

function ChatAtView:InitInput()
    self.txt_input = self._layout_objs["txt_input"]
    self.txt_input:AddFocusInCallback(function()
        
    end)

    self.txt_input:AddFocusOutCallback(function()
        local input_txt = self.txt_input:GetText()
        if input_txt == "" then
            self:UpdateList(self.at_data)
        end
    end)

    self.txt_input:AddChangeCallback(function()
        local input_txt = self.txt_input:GetText()
        self:SetClearVisible(input_txt~="")
    end)

    self.txt_input:AddSubmitCallback(function()
        
    end)
end

function ChatAtView:OnClickBtnLook()
    local input_txt = self.txt_input:GetText()
    if input_txt == "" then
        game.GameMsgCtrl.instance:PushMsg(config.words[1336])
        return
    end

    local list = {}
    self.ui_list:Foreach(function(item)
        local name = item:GetName()
        if string.find(name, input_txt) then
            table.insert(list, item:GetData())
        end
    end)

    self:UpdateList(list)
end

function ChatAtView:SetClearVisible(val)
    if self.clear_visible == val then
        return
    end

    self.clear_visible = val
    self.btn_clear:SetVisible(val)
end

return ChatAtView
