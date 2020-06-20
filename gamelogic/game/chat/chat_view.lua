local ChatView = Class(game.BaseView)

local handler = handler
local string_gsub = string.gsub
local string_format = string.format
local string_split = string.split
local string_find = string.find
local serialize = serialize

local EmojiNum = 92

local _et = {}

local StageInstance = FairyGUI.Stage.inst

local NoticeItemId = 16990001

function ChatView:_init(ctrl)
    self._package_name = "ui_chat"
    self._com_name = "chat_view"

    self._show_money = true

    self._cache_time = 300
    self._view_level = game.UIViewLevel.Standalone

    self.ctrl = ctrl
end

function ChatView:OpenViewCallBack(open_channel)
    self:Init()
    self:InitBg()
    self:InitListTab()
    self:InitListPage(open_channel)
    self:InitBtns()
    self:InitInput()
    self:InitChatFuncs()
    
    self:RegisterAllEvents()
end

function ChatView:CloseViewCallBack()
    for _,v in ipairs(self.page_list or {}) do
        v:DeleteMe()
    end
    self.page_list = nil

    self:ClearBagGoods()
    self:ClearQuickChatItem()
    self:ClearPetItems()

    self.func_item_info = nil
    self.func_pet_info = nil
    self.func_pos_info = nil
    self.chat_at_info = nil
end

function ChatView:RegisterAllEvents()
    local events = {
        {game.ChatEvent.UpdateNewChat, handler(self, self.OnUpdateNewChat)},
        {game.BagEvent.BagItemChange, handler(self, self.OnBagItemChange)},
        {game.ChatEvent.UpdateChatAt, handler(self, self.OnUpdateChatAt)},
        {game.ChatEvent.RevcieveChatAt, handler(self, self.OnRevcieveChatAt)},
        {game.ChatEvent.OnChatPublic, handler(self, self.OnChatPublic)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function ChatView:Init()
    self.root_obj = self:GetRoot()

    self.cur_func_idx = 0
    self.cur_chat_page = nil

    self.group_chat = self._layout_objs["group_chat"]
    self.group_no_chat = self._layout_objs["group_no_chat"]

    self.txt_no_chat = self._layout_objs["txt_no_chat"]
    
    self.chat_voice_com = self._layout_objs["chat_voice_com"]

    self.chat_at_notice = self._layout_objs["chat_at_notice"]
    self.chat_at_notice:AddClickCallBack(function()
        self:OnClickCahtAtNotice()
    end)
    self:OnRevcieveChatAt()

    self.btn_notice = self._layout_objs["btn_notice"]
    self:UpdateNoticeItemNum()

    self.btn_lucky_money = self._layout_objs.btn_lucky_money
    self.btn_lucky_money:AddClickCallBack(function()
        game.LuckyMoneyCtrl.instance:OpenView()
    end)
    self.btn_lucky_money:SetText("")

    self.new_chat_num = 0

    self.chat_at_info = {}
end

function ChatView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1324])
end

function ChatView:InitListTab()
    local item_num = #game.ChatChannelSort

    self.list_tab = self._layout_objs["list_tab"]
    self.list_tab:SetItemNum(item_num)

    for k,v in ipairs(game.ChatChannelSort) do
        local word = game.ChatChannelWord[v[1]]
        local obj = self.list_tab:GetChildAt(k-1)
        obj:SetText(word)
    end
end

function ChatView:InitListPage(open_channel)
    local item_num = #game.ChatChannelSort

    local list_page = self._layout_objs["list_page"]
    list_page:SetItemNum(item_num)

    self.tab_group_ctrl = self:GetRoot():AddControllerCallback("tab_group", function(idx)
        self.list_tab:ScrollToView(idx, true)

        for k,v in ipairs(self.page_list) do
            v:Active(k==(idx+1))
        end

        self.cur_chat_page = self.page_list[idx+1]
        self.cur_chat_channel = self.cur_chat_page:GetChatChannel()

        self.open_channel = self.cur_chat_channel

        local is_chat = self.cur_chat_page:IsChat()
        self.group_chat:SetVisible(is_chat)
        self.group_no_chat:SetVisible(not is_chat)

        if not is_chat then
            local channel_word = game.ChatChannelWord[self.cur_chat_channel] or ""
            self.txt_no_chat:SetText(string.format(config.words[1331],channel_word))

            self:HideFuns()
        end

        self.btn_lucky_money:SetVisible(self.cur_chat_channel == game.ChatChannel.Guild)
    end)
    
    self.page_list = {}
    local open_idx = 1
    self.open_channel = open_channel or self.open_channel
    local page_class = require("game/chat/chat_page")
    for k,v in ipairs(game.ChatChannelSort) do
        local channel = v[1]
        local page_obj = list_page:GetChildAt(k-1)
        local page = page_class.New(self.ctrl, channel, v[2])
        page:SetVirtual(page_obj)
        page:SetParentView(self)
        page:Open()

        table.insert(self.page_list, page)

        if channel == self.open_channel then
            open_idx = k
        end
    end
    global.TimerMgr:CreateTimer(0.01, function()
        self.tab_group_ctrl:SetSelectedIndexEx(open_idx-1)
        return true    
    end)
end

function ChatView:InitBtns()
    local btn_voice = self._layout_objs["btn_voice"]
    local btn_chat = self._layout_objs["btn_chat"]
    local btn_send = self._layout_objs["btn_send"]
    local btn_press_voice = self._layout_objs["btn_press_voice"]

    btn_send:AddClickCallBack(function()
        self:OnClickBtnSend()
    end)

    btn_chat:AddClickCallBack(function()
        self.func_controller:SetSelectedIndex(0)
    end)

    btn_voice:AddClickCallBack(function()
        self.func_controller:SetSelectedIndex(0)
    end)

    -- 语音
    btn_press_voice:SetTouchBeginCallBack(function(x, y)
        if game.VoiceMgr:InitEngine() then
            self:OpenChatVoice()
        end
    end)

    btn_press_voice:SetTouchEndCallBack(function(x, y)
        self:CloseChatVoice()
    end)

    btn_press_voice:SetTouchRollOutCallBack(function(x, y)
        self:CancelChatVoice()
    end)
end

function ChatView:InitInput()
    self.txt_input = self._layout_objs["txt_input"]
    self.txt_input:AddFocusInCallback(function()
        self:OnInputChatEvent(game.TextInputType.FocusIn)
    end)

    self.txt_input:AddFocusOutCallback(function()
        self:OnInputChatEvent(game.TextInputType.FocusOut)
    end)

    self.txt_input:AddChangeCallback(function()
        self:OnInputChatEvent(game.TextInputType.Change)
    end)

    self.txt_input:AddSubmitCallback(function()
        self:OnInputChatEvent(game.TextInputType.Submit)
    end)

    self.rtx_input = self._layout_objs["rtx_input"]
    self.rtx_input:SetupEmoji("ui_emoji", 32, 32)
    self.rtx_input:SetText(config.words[1321])
end

function ChatView:InitChatFuncs()
    self.chat_funcs = {
        {
            is_init = false,
            func = function()
                self:InitFuncEmoji()
            end,
        },
        {
            is_init = false,
            func = function()
                self:InitFuncNotice()
            end,
        },
        {
            is_init = false,
            func = function()
                self:InitFuncItem()
            end,
        },
        {
            is_init = false,
            func = function()
                self:InitFuncQuickChat()
            end,
        },
        {
            is_init = false,
            func = function()
                self:InitFuncPet()
            end,
        },
        {
            is_init = false,
            func = function()
                self:InitFuncPos()
            end,
            update = function(idx)
                self:UpdateFuncPos(idx)
            end,
        },
    }

    self.voice_controller = self:GetRoot():GetController("c2")

    self.func_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
        self.voice_controller:SetSelectedIndex(0)

        self:OnClickChatFunc(idx)
    end)
    self.func_controller:SetSelectedIndexEx(0)
end

function ChatView:OnClickChatFunc(idx)
    local func_cfg = self.chat_funcs[idx]
    if func_cfg then
        if not func_cfg.is_init then
            func_cfg.is_init = true
            func_cfg.func()
        end

        if func_cfg.update then
            func_cfg.update(idx)
        end
    end

    self.cur_func_idx = idx
    if self.cur_chat_page then
        self.cur_chat_page:OnShowFunc(self:IsShowFunc())
    end
end

function ChatView:InitFuncEmoji()
    self.func_emoji = self._layout_objs["func_emoji"]

    local item_num = EmojiNum
    local num_per_page = 24
    local page_num = math.ceil(item_num / num_per_page)

    local list_emoji_page = self._layout_objs["func_emoji/list_emoji_page"]
    local list_page = self._layout_objs["func_emoji/list_page"]

    list_emoji_page:SetItemNum(page_num)
    list_page:SetItemNum(page_num)

    local idx = 0
    for i=1,page_num do
        if idx >= item_num then
            break
        end

        local emoji_page = list_emoji_page:GetChildAt(i-1)
        local list_emoji = emoji_page:GetChild("list_emoji")

        for j=1,num_per_page do
            idx = idx + 1

            local emoji_id = idx
            local emoji_item = list_emoji:AddItemFromPool()
            emoji_item:AddClickCallBack(function()
                self:OnClickEmojiItem(emoji_id)
            end)

            local anim = emoji_item:GetChild("anim")
            anim:SetPackageItem("ui_emoji_chat", tostring(idx))

            if idx >= item_num then
                break
            end
        end
    end
    
    local controller = self.func_emoji:GetController("c1")
    controller:SetSelectedIndexEx(0)
end

function ChatView:InitFuncNotice()
    self.func_notice = self._layout_objs["func_notice"]

    self.func_notice_txt_input = self._layout_objs["func_notice/txt_input"]
    self.func_notice_rtx_input = self._layout_objs["func_notice/rtx_input"]

    local btn_send = self._layout_objs["func_notice/btn_send"]
    btn_send:AddClickCallBack(function()
        self:OnClickNoticeSend()
    end)

    local btn_effect = self._layout_objs["func_notice/btn_effect"]
    local btn_history = self._layout_objs["func_notice/btn_history"]

    local item_num = EmojiNum
    local num_per_page = 12
    local page_num = math.ceil(item_num / num_per_page)

    local list_emoji_page = self._layout_objs["func_notice/list_emoji_page"]
    local list_page = self._layout_objs["func_notice/list_page"]

    list_emoji_page:SetItemNum(page_num)
    list_page:SetItemNum(page_num)

    local idx = 0
    for i=1,page_num do
        if idx >= item_num then
            break
        end

        local emoji_page = list_emoji_page:GetChildAt(i-1)
        local list_emoji = emoji_page:GetChild("list_emoji")

        for j=1,num_per_page do
            idx = idx + 1

            local emoji_id = idx
            local emoji_item = list_emoji:AddItemFromPool()
            emoji_item:AddClickCallBack(function()
                self:OnClickNoticeEmojiItem(emoji_id)
            end)

            local anim = emoji_item:GetChild("anim")
            anim:SetPackageItem("ui_emoji_chat", tostring(idx))

            if idx >= item_num then
                break
            end
        end
    end
    
    local controller = self.func_notice:GetController("c1")
    controller:SetSelectedIndexEx(0) 

    self:InitNoticeInput()
end

function ChatView:InitNoticeInput()
    self.func_notice_txt_input:AddFocusInCallback(function()
        self:OnNoticeInputEvent(game.TextInputType.FocusIn)
    end)

    self.func_notice_txt_input:AddFocusOutCallback(function()
        self:OnNoticeInputEvent(game.TextInputType.FocusOut)
    end)

    self.func_notice_txt_input:AddChangeCallback(function()
        self:OnNoticeInputEvent(game.TextInputType.Change)
    end)

    self.func_notice_txt_input:AddSubmitCallback(function()
        self:OnNoticeInputEvent(game.TextInputType.Submit)
    end)

    self.func_notice_rtx_input:SetupEmoji("ui_emoji", 32, 32)
    self.func_notice_rtx_input:SetText(config.words[1328])
end

function ChatView:OnNoticeInputEvent(event_type)
    local input_text = self.func_notice_txt_input:GetText()

    if event_type == game.TextInputType.FocusIn then
        if input_text == "" then
            self.func_notice_rtx_input:SetText(input_text)
        end
    end

    if event_type == game.TextInputType.FocusOut then
        if input_text == "" then
            self.func_notice_rtx_input:SetText(config.words[1328])
        end
    end

    if event_type == game.TextInputType.Change then        
        input_text = self:ParseNoticeInputText(input_text)

        if input_text == "" then
            input_text = config.words[1328]
        end
        self.func_notice_rtx_input:SetText(input_text)
    end
end

function ChatView:InitFuncItem()
    self.func_item_info = nil

    self.func_item = self._layout_objs["func_item"]
    local list_item = self._layout_objs["func_item/list_item"]

    local bag_goods = game.BagCtrl.instance:GetGoodsBagByBagId(1)
    bag_goods = bag_goods.goods
    local bag_item_num = #bag_goods

    list_item:SetItemNum(bag_item_num)

    self.bag_goods_list = {}
    for k,v in ipairs(bag_goods) do
        local item_obj = list_item:GetChildAt(k-1)
        local item = game_help.GetGoodsItem(item_obj, false)
        item:SetItemInfo(v.goods)
        item:AddClickEvent(function(item)
            self:OnClickBagItem(item)
        end)

        table.insert(self.bag_goods_list, item)
    end
end

function ChatView:InitFuncQuickChat()
    self.func_quick_chat = self._layout_objs["func_quick_chat"]
    local list_item = self._layout_objs["func_quick_chat/list_item"]

    local item_num = #config.quick_chat
    list_item:SetItemNum(item_num)

    self.quick_chat_item_list = {}
    local item_class = require("game/chat/quick_chat_item")
    for k,v in ipairs(config.quick_chat) do
        local item_obj = list_item:GetChildAt(k-1)
        local item = item_class.New(v)
        item:SetVirtual(item_obj)
        item:Open()

        item_obj:AddClickCallBack(function()
            self:OnClickQuickChat(item)
        end)

        table.insert(self.quick_chat_item_list, item)
    end
end

function ChatView:InitFuncPet()
    self.func_pet_info = nil

    self.func_pet = self._layout_objs["func_pet"]
    local list_item = self._layout_objs["func_pet/list_item"]

    local pet_info = game.PetCtrl.instance:GetPetInfo()
    
    local item_num = #pet_info
    list_item:SetItemNum(item_num)

    local item_calss = require("game/chat/chat_pet_item")
    self.pet_item_list = {}
    for k,v in ipairs(pet_info) do
        local obj = list_item:GetChildAt(k-1)
        local item = item_calss.New()
        item:SetVirtual(obj)
        item:Open()
        item:SetItemInfo(v.pet)
        item:AddClickEvent(function(item)
            self:OnClickPetItem(item)
        end)

        table.insert(self.pet_item_list, item)
    end
end

function ChatView:ClearPetItems()
    for _,v in ipairs(self.pet_item_list or {}) do
        v:DeleteMe()
    end
    self.pet_item_list = nil
end

function ChatView:InitFuncPos()
    self.func_pos_info = {
        id = 0,
        name = "",
        line = 1,
        lx = 0,
        ly = 0,
    }

    self.func_pos = self._layout_objs["func_pos"]
end

function ChatView:UpdateFuncPos(idx)
    local scene_id = game.Scene.instance:GetSceneID()
    local scene_cfg = config.scene[scene_id]

    local main_role = game.Scene.instance:GetMainRole()
    local lx,ly = main_role:GetLogicPosXY()

    local line = 1

    self.func_pos_info.id = scene_id
    self.func_pos_info.name = scene_cfg.name
    self.func_pos_info.line = line
    self.func_pos_info.lx = lx
    self.func_pos_info.ly = ly
    
    local str_pos = string_format(config.words[1326], scene_cfg.name, line, lx, ly)
    self.func_pos:SetText(str_pos)

    local input_text = self.txt_input:GetText()
    if not string_find(input_text, "#s#") then
        input_text = string_format("%s%s", input_text, "#s#")
    end

    self.txt_input:SetText(input_text)

    input_text = self:ParseInputText(input_text)
    self.rtx_input:SetText(input_text)
end

function ChatView:ClearQuickChatItem()
    for _,v in ipairs(self.quick_chat_item_list or {}) do
        v:DeleteMe()
    end
    self.quick_chat_item_list = nil
end

function ChatView:ClearBagGoods()
    for _,v in ipairs(self.bag_goods_list or {}) do
        v:DeleteMe()
    end
    self.bag_goods_list = nil
end

function ChatView:OnInputChatEvent(event_type)
    local input_text = self.txt_input:GetText()

    if event_type == game.TextInputType.FocusIn then
        if input_text == "" then
            self.rtx_input:SetText(input_text)
        end
    end

    if event_type == game.TextInputType.FocusOut then
        if input_text == "" then
            self.rtx_input:SetText(config.words[1321])
        end
    end

    if event_type == game.TextInputType.Change then        
        input_text = self:ParseInputText(input_text)

        if input_text == "" then
            input_text = config.words[1321]
        else
            if game.ChatAtChannel[self.cur_chat_channel] then
                local last = string.last(input_text)
                if last == "@" then
                    self.ctrl:OpenChatAtView(self.cur_chat_channel, self.group_id)

                    StageInstance:CloseKeyboard()
                end
            end
        end
        self.rtx_input:SetText(input_text)
    end
end

function ChatView:OnUpdateNewChat()
    for _,v in ipairs(self.page_list) do
        v:OnUpdateNewChat()
    end
end

function ChatView:GetChatData(chat_channel)
    return self.ctrl:GetChatData(chat_channel)
end

function ChatView:OnClickBtnSend()
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

    local params = {
        channel = self.cur_chat_page:GetChatChannel(),
        content = str_content,
        extra = extra,
    }
    self.ctrl:SendChatPublic(params)

    -- self.txt_input:SetText("")
    -- self.rtx_input:SetText(config.words[1321])
end

function ChatView:OnClickEmojiItem(idx)
    local input_text = self.txt_input:GetText()
    input_text = string_format("%s#%s#", input_text, idx)

    self.txt_input:SetText(input_text)

    input_text = self:ParseInputText(input_text)
    self.rtx_input:SetText(input_text)
end

function ChatView:OnClickNoticeEmojiItem(idx)
    local input_text = self.func_notice_txt_input:GetText()
    input_text = string_format("%s#%s#", input_text, idx)

    self.func_notice_txt_input:SetText(input_text)

    input_text = self:ParseNoticeInputText(input_text)
    self.func_notice_rtx_input:SetText(input_text)
end

function ChatView:OnClickNoticeSend()
    local item_num = game.BagCtrl.instance:GetNumById(NoticeItemId)
    if item_num <= 0 then
        self:ShowNoticeMsg()
        return
    end

    local input_text = self.func_notice_txt_input:GetText()
    if input_text == "" then
        game.GameMsgCtrl.instance:PushMsg(config.words[1333])
        return
    end

    local extra = ""
    local horn_type = 0
    self.ctrl:SendChatHorn(input_text, extra, horn_type)

    self.func_notice_txt_input:SetText("")
    self.func_notice_rtx_input:SetText(config.words[1328])
end

function ChatView:ShowNoticeMsg()
    local item_name = config.goods[NoticeItemId].name

    local title = config.words[102]
    local content = string.format(config.words[1332], item_name)
    local tips_view = game.GameMsgCtrl.instance:CreateMsgBox(title, content)
    tips_view:SetOkBtn(function()
        game.ShopCtrl.instance:OpenViewByItemId(NoticeItemId)
    end, config.words[5010], true)
    tips_view:SetCancelBtn(function()
        
    end, config.words[5011])
    tips_view:Open()
end

function ChatView:OnClickBagItem(goods_item)
    local item_info = goods_item:GetItemInfo()

    self.func_item_info = item_info

    local item_id = item_info.id
    local item_cfg = config.goods[item_id]
    local item_name = item_cfg.name
    local item_color = item_cfg.color

    local input_text = self.txt_input:GetText()
    if not string_find(input_text, "#i#") then
        input_text = string_format("%s%s", input_text, "#i#")
    end

    self.txt_input:SetText(input_text)

    input_text = self:ParseInputText(input_text)
    self.rtx_input:SetText(input_text)
end

function ChatView:OnClickQuickChat(item)
    local id = item:GetId()
    local content = item:GetContent()
    
    local role_name = game.Scene.instance:GetMainRoleName()
    local role_gender = game.Scene.instance:GetMainRoleGender()
    role_name = string_format("[%s]", role_name)

    self.txt_input:SetText(string_format("#f#%s|%s|%s", id, role_name, role_gender))
    
    self:OnClickBtnSend()

    self:HideFuns()
end

function ChatView:OnClickPetItem(item)
    self.func_pet_info = item:GetItemInfo()

    local pet_info = self.func_pet_info

    local pet_id = pet_info.cid
    local pet_name = pet_info.name

    local pet_cfg = config.pet[pet_id]
    local quality = pet_cfg.quality

    pet_info.quality = quality

    local input_text = self.txt_input:GetText()
    if not string_find(input_text, "#p#") then
        input_text = string_format("%s%s", input_text, "#p#")
    end

    self.txt_input:SetText(input_text)

    input_text = self:ParseInputText(input_text)
    self.rtx_input:SetText(input_text)
end

function ChatView:ShowEmoji()
    self.list_emoji:SetVisible(true)
    self.img_emoji_bg:SetVisible(true)
    self.shape_mask:SetVisible(true)
end

function ChatView:HideEmoji()
    self.list_emoji:SetVisible(false)
    self.img_emoji_bg:SetVisible(false)
    self.shape_mask:SetVisible(false)
end

local PetStarColor = {
    [0] = game.ColorString.Green,
    [1] = game.ColorString.NavyBlue,
    [2] = game.ColorString.NavyBlue,
    [3] = game.ColorString.NavyBlue,
    [4] = game.ColorString.Purple,
    [5] = game.ColorString.Purple,
    [6] = game.ColorString.Purple,
    [7] = game.ColorString.Orange,
    [8] = game.ColorString.Orange,
    [9] = game.ColorString.Orange,
}

function ChatView:ParseInputText(input_text)
    local input_text = input_text or self.txt_input:GetText()

    input_text = string_gsub(input_text, "#%d+#", function(s)
        local idx = string_gsub(s, "#", "")

        return string_format("<img asset=\'ui_emoji_chat:%s\' width=32 height=32 />", idx)
    end)

    input_text = string_gsub(input_text, "#i#", function(s)
        if not self.func_item_info then
            return ""
        end

        local item_info = self.func_item_info
        local item_id = item_info.id
        local item_cfg = config.goods[item_id]

        return string_format("<font color='#%s'>[%s]</font>", game.ItemColor[item_cfg.color], item_cfg.name)
    end)

    input_text = string_gsub(input_text, "#s#", function(s)
        if not self.func_pos_info then
            return ""
        end

        local str_pos = string_format(config.words[1326], self.func_pos_info.name, self.func_pos_info.line, self.func_pos_info.lx, self.func_pos_info.ly)
        return string_format("<font color='#%s'>%s</font>", game.ColorString.Green, str_pos)
    end)

    input_text = string_gsub(input_text, "#p#", function(s)
        if not self.func_pet_info then
            return ""
        end

        local pet_info = self.func_pet_info

        local pet_name = pet_info.name

        local quality = pet_info.quality

        local color = PetStarColor[pet_info.star] or PetStarColor[0]

        return string_format("<font color='#%s'>[%s]</font>", color, pet_name)
    end)

    input_text = string_gsub(input_text, "#@#", function(s)
        if not self.chat_at_info then
            return ""
        end

        local color = game.ColorString.NavyBlue
        return string_format("<font color='#%s'>@%s</font>", color, self.chat_at_info.str_name)
    end)

    return input_text
end

function ChatView:ParseNoticeInputText(input_text)
    local input_text = input_text or self.func_notice_txt_input:GetText()

    input_text = string_gsub(input_text, "#%d+#", function(s)
        local idx = string_gsub(s, "#", "")

        return string_format("<img asset=\'ui_emoji_chat:%s\' width=32 height=32 />", idx)
    end)

    return input_text
end

function ChatView:ParseExtra(str_content)
    local list_extra = {}
    if string_find(str_content,"#i#") then
        if self.func_item_info then
            local str = serialize(self.func_item_info)
            
            table.insert(list_extra, string_format("extra_item|%s|%s", self.func_item_info.id, str))
        else
            str_content = string_gsub(str_content, "#i#", "")
        end
    end

    if string_find(str_content,"#s#") then
        if self.func_pos_info then
            local str = serialize(self.func_pos_info)
            str = string_format("extra_pos|%s", str)
            table.insert(list_extra, str)
        else
            str_content = string_gsub(str_content, "#s#", "")
        end
    end

    if string_find(str_content,"#p#") then
        if self.func_pet_info then
            local str = serialize(self.func_pet_info)
            str = string_format("extra_pet|%s|%s|%s", self.func_pet_info.name, self.func_pet_info.star, str)
            table.insert(list_extra, str)
        else
            str_content = string_gsub(str_content, "#p#", "")
        end
    end

    if string_find(str_content,"#f#") then
        local tb = string.split(str_content, "|")
        if #tb < 3 then
            str_content = ""
        end
    end

    if string_find(str_content,"#@#") then
        if self.chat_at_info then
            local str = string_format("extra_@|%s|%s", self.chat_at_info.str_name, self.chat_at_info.str_id)
            table.insert(list_extra, str)
        else
            str_content = string_gsub(str_content, "#@#", "")
        end
    end

    if #list_extra > 0 then
        return table.concat(list_extra, "$"),str_content
    end

    return "",str_content
end

function ChatView:ShowEmptyTips()
    game.GameMsgCtrl.instance:PushMsg(config.words[1325])
end

function ChatView:ShowNewChatTips(num)
    self.group_new_chat:SetVisible(true)

    self.rtx_messege:SetText(string.format(config.words[1320], num))
end

function ChatView:ClearNewChatTips()
    self.group_new_chat:SetVisible(false)
end

function ChatView:ScrollToBottom()
    self.new_chat_num = 0
    self.list_chat:ScrollToView(self.cur_chat_item_num - 1)

    self:ClearNewChatTips()
end

function ChatView:OpenChatVoice()
    if not self.chat_voice_template then
        self.chat_voice_template = require("game/chat/chat_voice_template").New(self.cur_chat_channel)
        self.chat_voice_template:SetVirtual(self.chat_voice_com)
        self.chat_voice_template:Open()
    end
end

function ChatView:CloseChatVoice()
    if self.chat_voice_template then
        self.chat_voice_template:DeleteMe()
        self.chat_voice_template = nil
    end
end

function ChatView:CancelChatVoice()
    if self.chat_voice_template then
        self.chat_voice_template:CancelChatVoice()
    end
end

function ChatView:IsShowFunc()
    return (self.cur_func_idx>0)
end

function ChatView:HideFuns()
    self.cur_func_idx = 0
    self.func_controller:SetSelectedIndexEx(0)
end

function ChatView:UpdateNoticeItemNum()
    local item_num = game.BagCtrl.instance:GetNumById(NoticeItemId)
    local color = game.Color.Red
    if item_num > 0 then
        color = game.Color.DarkGreen
    end
    self.btn_notice:SetTitleColor(table.unpack(color))
    self.btn_notice:SetText(item_num)
end

function ChatView:OnBagItemChange(change_list)
    if not change_list[NoticeItemId] then
        return
    end

    self:UpdateNoticeItemNum()
end

function ChatView:OnUpdateChatAt(info_list)
    local id_list = {}
    local name_list = {}
    for _,v in ipairs(info_list) do
        table.insert(id_list, v[1])
        table.insert(name_list, v[2])
    end

    local str_id = table.concat(id_list, "&")
    local str_name = table.concat(name_list, "@")

    self.chat_at_info.str_id = str_id
    self.chat_at_info.str_name = str_name

    local input_text = self.txt_input:GetText()

    local start_idx,end_idx = string.lastPos(input_text)
    input_text = string.sub(input_text, 1, start_idx-1)
    input_text = string_format("%s#@#", input_text)

    self.txt_input:SetText(input_text)

    input_text = self:ParseInputText(input_text)
    self.rtx_input:SetText(input_text)
end

function ChatView:OnRevcieveChatAt(id_list, data)
    local id_list = id_list or _et
    local main_role_id = game.Scene.instance:GetMainRoleID()
    local is_chat_at = (id_list[main_role_id]~=nil)
    self.chat_at_notice:SetVisible(is_chat_at)

    self.chat_at_data = data
end

function ChatView:OnChatPublic()
    self.txt_input:SetText("")
    self.rtx_input:SetText(config.words[1321])
end

function ChatView:OnClickCahtAtNotice()
    self.chat_at_notice:SetVisible(false)

    -- local chat_channel = self.chat_at_data.channel
    -- if self.cur_chat_channel == chat_channel then
    --     self.cur_chat_page:ScrollToData(self.chat_at_data)
    -- end  

    self.ctrl:OpenChatSettingView()  
end

return ChatView
