local DailytaskTipsView = Class(game.BaseView)

function DailytaskTipsView:_init(ctrl)
    self._package_name = "ui_daily_task"
    self._com_name = "daily_task_tips_view"
    self.ctrl = ctrl
    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Fouth
end

function DailytaskTipsView:_delete()
    
end

function DailytaskTipsView:OpenViewCallBack(tips_id, ...)
    self:InitConfig(tips_id)
    self:InitView(...)
end

function DailytaskTipsView:CloseViewCallBack()
    local tips_data = self.tips_config[self.tips_id]

    if tips_data.close_func then
        tips_data.close_func()
    end
end

function DailytaskTipsView:InitConfig(tips_id)
    self.tips_id = tips_id
    self.def_id = 0
    self.tips_config = {
        [0] = {
            style = 1,
            title = config.words[102],
            content = "",
            init_func = function(...)
                self:SetTextStyle()
            end,
            ok_func = function()
                self:Close()
            end,
            cancel_func = function()
                self:Close()
            end,
            desc = "default",
        },
        [1] = {
            style = 1,
            init_func = function(find_info)
                self.txt_content:SetText(string.format(config.words[1931], find_info.cost, find_info.exp))
                self:SetTextStyle()
            end,
            ok_func = function()
                self.ctrl:SendRetrieveDailyEvent()
                self:Close()
            end,
            desc = "one_key_find_back",
        },
        [2] = {
            style = 1,
            init_func = function(find_info)
                self.find_info = find_info
                self.txt_content:SetText(string.format(config.words[1931], find_info.cost, find_info.exp))
                self:SetTextStyle()
            end,
            ok_func = function()
                self.ctrl:SendRetrieveSingleDailyEvent(self.find_info.id)
                self:Close()
            end,
            desc = "find_one",
        },
        [3] = {
            style = 1,
            content = config.words[1940],
            ok_func = function()
                self.ctrl:SendDailyThiefCancel()
                self:Close()
            end,
            desc = "cancel_thief_task",
        },
        [4] = {
            style = 1,
            content = config.words[5102],
            init_func = function()
                self:SetTextStyle(0)
            end,
            ok_func = function()
                self.ctrl:SendGuildTaskCancel()
                self:Close()
            end,
            desc = "cancel_guild_task",
        },
    }
end

function DailytaskTipsView:InitView(...)
    local tips_data = self.tips_config[self.tips_id]

    for k, v in pairs(self.tips_config[self.def_id]) do
        if not tips_data[k] then
            tips_data[k] = v
        end
    end

    self.txt_title = self._layout_objs["txt_title"]
    self.txt_title:SetText(tips_data.title)

    self.txt_content = self._layout_objs["txt_content"]
    self.txt_content:SetText(tips_data.content)
    
    self.btn_ok = self._layout_objs["btn_ok"]
    self.btn_ok:SetText(config.words[100])
    self.btn_ok:AddClickCallBack(tips_data.ok_func)

    self.btn_cancel = self._layout_objs["btn_cancel"]
    self.btn_cancel:SetText(config.words[101])
    self.btn_cancel:AddClickCallBack(tips_data.cancel_func)

    self.ctrl_tips = self:GetRoot():GetController("ctrl_tips")
    self.ctrl_tips:SetSelectedIndexEx(tips_data.style)

    tips_data.init_func(...)
end

function DailytaskTipsView:SetTextStyle(align, vertical_align, font_size)
    self.txt_content.align = align or 1
    self.txt_content.verticalAlign = vertical_align or 1
    self.txt_content:SetFontSize(font_size or 28)
end

function DailytaskTipsView:OnEmptyClick()
    self:Close()
end

return DailytaskTipsView
