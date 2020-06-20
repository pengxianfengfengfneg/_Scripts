local ChatSettingView = Class(game.BaseView)

function ChatSettingView:_init(ctrl)
    self._package_name = "ui_chat"
    self._com_name = "chat_setting_view"

    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
end

function ChatSettingView:OpenViewCallBack(open_index)
    self.open_index = open_index or 1

    self:Init()

    self:RegisterAllEvents()
end

function ChatSettingView:CloseViewCallBack()
   
end

function ChatSettingView:RegisterAllEvents()
    local events = {

    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function ChatSettingView:Init()
    self:GetTemplate("game/chat/chat_setting_base", "chat_setting_base")
    self:GetTemplate("game/chat/chat_setting_barrage", "chat_setting_barrage")
    self:GetTemplate("game/chat/chat_setting_emoji", "chat_setting_emoji")
    self:GetTemplate("game/chat/chat_setting_info", "chat_setting_info")


    local controller = self:GetRoot():GetController("c1")
    controller:SetSelectedIndex(math.clamp(self.open_index-1, 0, 3))
end

return ChatSettingView
