local SwornTitleGroupView = Class(game.BaseView)

function SwornTitleGroupView:_init(ctrl)
    self._package_name = "ui_sworn"
    self._com_name = "title_group_view"
    self.ctrl = ctrl

    self._show_money = true

    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
end

function SwornTitleGroupView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
end

function SwornTitleGroupView:CloseViewCallBack()

end

function SwornTitleGroupView:RegisterAllEvents()
    local events = {
        {game.SwornEvent.UpdateSwornInfo, handler(self, self.SetGroupNameText)},
        {game.SwornEvent.UpdateMemberList, handler(self, self.UpdateMemberList)},
        {game.MoneyEvent.Change, handler(self, self.OnMoneyChange)},
        {game.SwornEvent.ModifyGroupName, handler(self, self.ModifyGroupName)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SwornTitleGroupView:Init()
    for i=1, config.sworn_base.num_limit do
        self["senior_"..i] = self:GetTemplate("game/sworn/item/senior_item", "senior_item"..i)
    end

    self.txt_cost = self._layout_objs.txt_cost
    self.txt_cost:SetText(config.sworn_base.modify_name_coin_cost)
    
    self.txt_money = self._layout_objs.txt_money

    self.txt_name1 = self._layout_objs.txt_name1
    self.txt_name2 = self._layout_objs.txt_name2
    self.txt_name3 = self._layout_objs.txt_name3
    self.txt_name4 = self._layout_objs.txt_name4

    self.img_rope1 = self._layout_objs.img_rope1
    self.img_rope2 = self._layout_objs.img_rope2

    self:InitInputText(self.txt_name1)
    self:InitInputText(self.txt_name2)
    self:InitInputText(self.txt_name4)

    self.btn_dice = self._layout_objs.btn_dice
    self.btn_dice:AddClickCallBack(function()
        self:RandomName()
    end)

    self.btn_ok = self._layout_objs.btn_ok  
    self.btn_ok:AddClickCallBack(function()
        local name_head = self.txt_name1:GetText() .. self.txt_name2:GetText()
        local name_tail = self.txt_name4:GetText()
        if game.Utils.CheckMaskWords(name_head) or game.Utils.CheckMaskWords(name_tail) then
            game.GameMsgCtrl.instance:PushMsg(config.words[1005])
        elseif #string.utf8lens(name_head .. name_tail) < 3 then
            game.GameMsgCtrl.instance:PushMsg(config.words[6293])
        elseif self:IsSameGroupName(name_head, name_tail) then
            game.GameMsgCtrl.instance:PushMsg(config.words[6298])
        else
            self.ctrl:SendSwornModifyName(name_head, name_tail)
        end
    end)

    self:SetGroupNameText()
    self:SetMoneyInfo()
    self:UpdateMemberList()
end

function SwornTitleGroupView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6286])
end

function SwornTitleGroupView:RandomName()
    local name_head_cfg = config.sworn_name_head
    local name_tail_cfg = config.sworn_name_tail

    local head = name_head_cfg[math.random(1, #name_head_cfg)].word
    local tail = name_tail_cfg[math.random(1, #name_tail_cfg)].word

    local lens = string.utf8lens(head)
    local words = self:SplitChinese(head)
    self.txt_name1:SetText(words[1])
    self.txt_name2:SetText(words[2])
    self.txt_name4:SetText(tail)
end

function SwornTitleGroupView:SetGroupNameText()
    if self.ctrl:HaveSwornGroup() then
        local sworn_info = self.ctrl:GetSwornInfo()
        local words = self:SplitChinese(sworn_info.group_name)
        local color = self.ctrl:GetTitleColor()
        
        for i=1, 4 do
            local str = words[i]
            if i==3 then
                self:SetGroupNameNumberText()
            else
                self["txt_name"..i]:SetText(str)
            end
        end
    end
end

function SwornTitleGroupView:SetGroupNameNumberText()
    local member_list = self.ctrl:GetMemberList()
    local str = string.format("[color=#%s]%s[/color]", color, config.words[6243+#member_list])
    self.txt_name3:SetText(str)
end

function SwornTitleGroupView:SplitChinese(str)
    local lens = string.utf8lens(str)
    local words = {}
    for i=1, #lens do
        local start_idx = i>1 and lens[i-1]+1 or 1
        words[i] = string.sub(str, start_idx, lens[i])
    end
    return words
end

function SwornTitleGroupView:SetMoneyInfo()
    self.txt_money:SetText(game.BagCtrl.instance:GetMoneyByType(game.MoneyType.Copper))
end

function SwornTitleGroupView:OnMoneyChange(change_list)
    if change_list[game.MoneyType.Copper] then
        self:SetMoneyInfo()
    end
end

function SwornTitleGroupView:UpdateMemberList()
    local member_list_data = self.ctrl:GetMemberList()
    local member_num = #member_list_data

    for i=1, config.sworn_base.num_limit do
        local info = member_list_data[i]
        if info then
            self["senior_"..i]:SetItemInfo(info.mem)
        end
        self["senior_"..i]:SetVisible(info ~= nil)
    end

    self.img_rope1:SetVisible(member_num > 0)
    self.img_rope2:SetVisible(member_num > 3)

    self:SetGroupNameNumberText()
end

function SwornTitleGroupView:InitInputText(txt)
    txt:AddFocusInCallback(function()
        self:OnInputEvent(txt, game.TextInputType.FocusIn)
    end)
    txt:AddFocusOutCallback(function()
        self:OnInputEvent(txt, game.TextInputType.FocusOut)
    end)
    txt:AddChangeCallback(function()
        self:OnInputEvent(txt, game.TextInputType.Change)
    end)
    txt:AddSubmitCallback(function()
        self:OnInputEvent(txt, game.TextInputType.Submit)
    end)
end

function SwornTitleGroupView:OnInputEvent(txt, event_type)
    local input_text = txt:GetText()

    if event_type == game.TextInputType.Change then
        local parse_text = self:ParseInputText(input_text)
        txt:SetText(parse_text)
    end
end

function SwornTitleGroupView:ParseInputText(input_text)
    local lens = string.utf8lens(input_text)
    local max_words = 1
    local count = 0
    local words = ""

    for i=1, #lens do
        local start_idx = i > 1 and lens[i - 1] + 1 or 1
        local str = string.sub(input_text, start_idx, lens[i])
        if game.Utils.IsChinese(str) then
            words = words .. str
            count = count + 1
            if count == max_words then
                break
            end
        end
    end

    return words
end

function SwornTitleGroupView:ModifyGroupName()
    self:Close()
end

function SwornTitleGroupView:IsSameGroupName(name_head, name_tail)
    local group_name = self.ctrl:GetTitleGroupName()
    local words = self:SplitChinese(group_name)
    if group_name ~= "" and name_head == words[1]..words[2] and name_tail == words[4] then
        return true
    end
    return false
end

return SwornTitleGroupView
