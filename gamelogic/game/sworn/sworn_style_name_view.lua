local SwornStyleNameView = Class(game.BaseView)

function SwornStyleNameView:_init(ctrl)
    self._package_name = "ui_sworn"
    self._com_name = "style_name_view"
    self.ctrl = ctrl

    self._show_money = true

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full
end

function SwornStyleNameView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
end

function SwornStyleNameView:RegisterAllEvents()
    local events = {
        {game.SwornEvent.OnSwornModifyWord, handler(self, self.OnSwornModifyWord)},
    }   
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SwornStyleNameView:Init()
    self.txt_name1 = self._layout_objs.txt_name1
    self.txt_name1:AddFocusInCallback(function()
        self:OnStyleInputEvent(self.txt_name1, game.TextInputType.FocusIn)
    end)
    self.txt_name1:AddFocusOutCallback(function()
        self:OnStyleInputEvent(self.txt_name1, game.TextInputType.FocusOut)
    end)
    self.txt_name1:AddChangeCallback(function()
        self:OnStyleInputEvent(self.txt_name1, game.TextInputType.Change)
    end)
    self.txt_name1:AddSubmitCallback(function()
        self:OnStyleInputEvent(self.txt_name1, game.TextInputType.Submit)
    end)

    self.txt_name2 = self._layout_objs.txt_name2
    self.txt_name2:AddFocusInCallback(function()
        self:OnStyleInputEvent(self.txt_name2, game.TextInputType.FocusIn)
    end)
    self.txt_name2:AddFocusOutCallback(function()
        self:OnStyleInputEvent(self.txt_name2, game.TextInputType.FocusOut)
    end)
    self.txt_name2:AddChangeCallback(function()
        self:OnStyleInputEvent(self.txt_name2, game.TextInputType.Change)
    end)
    self.txt_name2:AddSubmitCallback(function()
        self:OnStyleInputEvent(self.txt_name2, game.TextInputType.Submit)
    end)

    self.btn_dice = self._layout_objs.btn_dice  
    self.btn_dice:AddClickCallBack(function()
        self:RandomName()
    end)

    self.btn_ok = self._layout_objs.btn_ok
    self.btn_ok:AddClickCallBack(function()
        local input_text = self.txt_name1:GetText()..self.txt_name2:GetText()
        if game.Utils.CheckMaskWords(input_text) then
            game.GameMsgCtrl.instance:PushMsg(config.words[1005])
        elseif #string.utf8lens(input_text) < 2 then
            game.GameMsgCtrl.instance:PushMsg(config.words[6293])
        else
            self.ctrl:SendSwornModifyWord(input_text)
            self:Close()
        end
    end)

    self.btn_cancel = self._layout_objs.btn_cancel
    self.btn_cancel:AddClickCallBack(function()
        self:Close()
    end)

    self.txt_group = self._layout_objs.txt_group
    self:SetGroupNameText()
end

function SwornStyleNameView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6287])
end

function SwornStyleNameView:RandomName()
    local rand_word_cfg = config.sworn_rand_word
    local word = rand_word_cfg[math.random(1, #rand_word_cfg)].word
    local lens = string.utf8lens(word)
    
    self.txt_name1:SetText(string.sub(word, 1, lens[1]))
    self.txt_name2:SetText(string.sub(word, lens[1]+1))
end

function SwornStyleNameView:OnStyleInputEvent(txt, event_type)
    local input_text = txt:GetText()

    if event_type == game.TextInputType.Change then
        local style_name = self:ParseInputText(input_text)
        txt:SetText(style_name)
    end
end

function SwornStyleNameView:SplitChinese(str)
    local lens = string.utf8lens(str)
    local words = {}
    for i=1, #lens do
        local start_idx = i>1 and lens[i-1]+1 or 1
        words[i] = string.sub(str, start_idx, lens[i])
    end
    return words
end

function SwornStyleNameView:ParseInputText(input_text)
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

function SwornStyleNameView:OnSwornModifyWord()
    self:Close()
end

function SwornStyleNameView:SetGroupNameText()
    local group_name = self.ctrl:GetTitleGroupName()
    local color = self.ctrl:GetTitleColor()
    local txt = string.format("[color=#%s]%s[/color]%s", color, group_name, config.sworn_base.fix_word)
    self.txt_group:SetText(txt)

    local style_name = self.ctrl:GetMemberInfo().word
    local words = self:SplitChinese(style_name)
    self.txt_name1:SetText(words[1])
    self.txt_name2:SetText(words[2])
end

return SwornStyleNameView
