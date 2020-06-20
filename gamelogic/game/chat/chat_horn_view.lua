local ChatHornView = Class(game.BaseView)

local string_gsub = string.gsub
local string_format = string.format

local ChatGenderColor = game.ChatGenderColor

function ChatHornView:_init(ctrl)
    self._package_name = "ui_chat"
    self._com_name = "chat_horn_view"

    self._mask_type = game.UIMaskType.None
    self._ui_order = game.UIZOrder.UIZOrder_Tips
    self._view_level = game.UIViewLevel.Standalone
    self.not_add_mgr = true

    self.ctrl = ctrl
end

function ChatHornView:OpenViewCallBack(open_index)
    self:Init()

    self:RegisterAllEvents()
end

function ChatHornView:CloseViewCallBack()
   
end

function ChatHornView:RegisterAllEvents()
    local events = {
        {game.ChatEvent.NoticeHorn, handler(self,self.OnNoticeHorn)}
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function ChatHornView:Init()
    self.rtx_horn = self._layout_objs["rtx_horn"]    
    self.rtx_horn:SetupEmoji("ui_emoji", 24, 24)

    self.img_n1 = self._layout_objs["n1"]
    self.img_n2 = self._layout_objs["n2"]

    self:SetVisible(false)

    self.next_show_time = 0
    self.delta_show_time = 10
    self.horn_list_data = {}
end

function ChatHornView:OnNoticeHorn(data)

    table.insert(self.horn_list_data, data)
end

function ChatHornView:SetVisible(val)
    if self.is_visible == val then
        return
    end

    self.is_visible = val
    self.rtx_horn:SetVisible(val)
    self.img_n1:SetVisible(val)
    self.img_n2:SetVisible(val)
end

function ChatHornView:GetHornText(data)
    local sender = data.sender
    local name = sender.name
    local gender = sender.gender
    local content = self:ParseEmoji(data.content)

    return string.format(config.words[1329], ChatGenderColor[gender], name, content)
end

function ChatHornView:Update(now_time, elapse_time)
    if now_time >= self.next_show_time then
        local data = self:PopOneHornData()
        if data then
            self.next_show_time = now_time + self.delta_show_time

            self:SetVisible(true)
            self.rtx_horn:SetText(self:GetHornText(data))
        else
            self:SetVisible(false)
        end
    end
end

function ChatHornView:PopOneHornData()
    local data = self.horn_list_data[1]
    if data then
        table.remove(self.horn_list_data, 1)
    end
    return data
end

function ChatHornView:ParseEmoji(input_text)
    return string_gsub(input_text, "#%d+#", function(s)
        local idx = string_gsub(s, "#", "")

        return string_format("<img asset=\'ui_emoji_chat:%s\' width=26 height=26 />", idx)
    end)
end

return ChatHornView
