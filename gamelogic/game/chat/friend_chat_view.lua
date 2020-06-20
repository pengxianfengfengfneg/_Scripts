local FriendChatView = Class(require("game/chat/chat_view"))

local handler = handler
local string_gsub = string.gsub
local string_format = string.format
local string_split = string.split
local string_find = string.find
local serialize = serialize

local StageInstance = FairyGUI.Stage.inst

function FriendChatView:_init(ctrl)
    self._package_name = "ui_chat"
    self._com_name = "friend_chat_view"

    self._show_money = true

    self._view_level = game.UIViewLevel.Standalone

    self:AddPackage("ui_friend")

    self.ctrl = ctrl
end

function FriendChatView:OpenViewCallBack(chat_info)
    self.chat_info = chat_info or {}
    self.cur_chat_channel = self.chat_info.channel or game.ChatChannel.Private

    self:FireEvent(game.FriendEvent.OpenFriendChat, self.chat_info)

    self:Init()
    self:InitBg()
    self:InitPage()
    self:InitBtns()
    self:InitInput()
    self:InitChatFuncs()
    self:InitOperate()
    
    self:OnUpdateNewChat()

    self:RegisterAllEvents()
end

function FriendChatView:CloseViewCallBack()
    FriendChatView.super.CloseViewCallBack(self)

    self:FireEvent(game.FriendEvent.CloseFriendChat, self.chat_info)
end

function FriendChatView:Init()
    FriendChatView.super.Init(self)
    
    self.root_obj = self:GetRoot()

    self.cur_func_idx = 0

    self.group_chat = self._layout_objs["group_chat"]
    self.chat_voice_com = self._layout_objs["chat_voice_com"]

    self.friend_chat = self._layout_objs["friend_chat"]
    self.group_room = self._layout_objs["group_room"]


    self.txt_target_group = self._layout_objs["txt_target_group"]
    self.btn_friend_oper = self._layout_objs["btn_friend_oper"]
    

    self.is_private_chat = (self.cur_chat_channel==game.ChatChannel.Private)
    self.is_group_chat = (self.cur_chat_channel==game.ChatChannel.Group)

    self.friend_chat:SetVisible(self.is_private_chat)
    self.group_room:SetVisible(self.is_group_chat)

    if self.is_private_chat then
        local txt_target_name = self._layout_objs["txt_target_name"]
        txt_target_name:SetText(self.chat_info.name)

        local txt_target_lv = self._layout_objs["txt_target_lv"]
        txt_target_lv:SetText(self.chat_info.lv)

        local res = game.CareerRes[self.chat_info.career] or game.CareerRes[game.Career.GaiBang]
        local img_target_career = self._layout_objs["img_target_career"]
        img_target_career:SetSprite("ui_main", res)

        self.txt_target_group:SetText(game.FriendRelationName[self.chat_info.stat] or "")

        self.btn_friend_oper:AddClickCallBack(function()
            local info = {
                role_id = self.chat_info.id,
                type_index = 1,                   
            }
            self:ShowFriendDetail(true, info)
        end)
    end

    self.group_info = nil
    self.group_id = nil
    if self.is_group_chat then
        self.group_info = self.chat_info.group_info
        self.group_id = self.group_info.id
        local txt_room_name = self._layout_objs["txt_room_name"]

        local online_num = 0
        local friend_data = game.FriendCtrl.instance:GetData()
        for _,v in ipairs(self.group_info.mem_list) do
            local info = friend_data:GetRoleInfoById(v.roleId)
            if info and info.unit.offline <= 0 then
                online_num = online_num + 1
            end
        end
        txt_room_name:SetText(string.format(config.words[1330], self.group_info.name, online_num, #self.group_info.mem_list))

        self.btn_room_info = self._layout_objs["btn_room_info"]
        self.btn_room_info:AddClickCallBack(function()
            game.FriendCtrl.instance:OpenFriendNoticeView(self.group_info.announce)
        end)

        self.btn_room_oper = self._layout_objs["btn_room_oper"]
        self.btn_room_oper:AddClickCallBack(function()
            local info = {
                group = self.group_info   
            }
            self:ShowGroupDetail(true, info)
        end)
    end
end

function FriendChatView:InitOperate()
    self.group_operate = self._layout_objs["group_operate"]
    self.friend_operate = self._layout_objs["friend_operate"]

    self.group_operate_temp = self:GetTemplateByObj("game/friend/group_operate", self.group_operate)
    self.friend_operate_temp = self:GetTemplateByObj("game/friend/friend_operate", self.friend_operate)
end

function FriendChatView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1700])
end

function FriendChatView:InitPage()
    self.cur_chat_page = require("game/chat/chat_page").New(self.ctrl, self.cur_chat_channel, true, self.chat_info.id, self.group_id)
    self.cur_chat_page:SetVirtual(self._layout_objs["chat_template"])
    self.cur_chat_page:SetParentView(self)
    self.cur_chat_page:Open()
    self.cur_chat_page._actived = true

    self.page_list = {
        self.cur_chat_page   
    }
end

function FriendChatView:OnClickBtnSend()
    local input_text = self.txt_input:GetText()
    if input_text == "" then
        self:ShowEmptyTips()
        return
    end

    local str_content = input_text

    local extra,str_content = self:ParseExtra(str_content)
    if str_content == "" then
        self:ShowEmptyTips()

        self.txt_input:SetText("")
        self.rtx_input:SetText(config.words[1321])
        return
    end

    if self.is_group_chat then
        local params = {
            channel = self.cur_chat_page:GetChatChannel(),
            target = self.group_id,
            content = str_content,
            voice = "",
            voice_time = 0,
            extra = extra,
        }
        self.ctrl:SendChatGroup(params)
    else
        local params = {
            id = self.chat_info.id,
            svr_num = self.chat_info.svr_num,
            channel = self.cur_chat_page:GetChatChannel(),
            content = str_content,
            extra = extra,
        }
        self.ctrl:SendChatPrivate(params)
    end

    self.txt_input:SetText("")
    self.rtx_input:SetText(config.words[1321])
end

function FriendChatView:ShowFriendDetail(val, role_info)
    self.group_operate:SetVisible(false)
    self.friend_operate:SetVisible(val)

    if val then
        self.friend_operate_temp:UpdateData(role_info)
    end
end

function FriendChatView:ShowGroupDetail(val, group_info)
    self.group_operate:SetVisible(val)
    self.friend_operate:SetVisible(false)

    if val then
        self.group_operate_temp:UpdateData(group_info)
    end
end

return FriendChatView
