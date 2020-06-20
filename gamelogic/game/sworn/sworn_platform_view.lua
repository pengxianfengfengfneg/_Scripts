local SwornPlatformView = Class(game.BaseView)

local PageConfig = {
    {
        item_path = "list_page/person_template",
        item_class = "game/sworn/template/platform_person_template",
    },
    {
        item_path = "list_page/group_template",
        item_class = "game/sworn/template/platform_group_template",
    },
}

function SwornPlatformView:_init(ctrl)
    self._package_name = "ui_sworn"
    self._com_name = "sworn_platform_view"
    self.ctrl = ctrl

    self._show_money = true

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full
end

function SwornPlatformView:OpenViewCallBack(open_idx)
    self:Init(open_idx)
    self:InitBg()
    self:RegisterAllEvents()
end

function SwornPlatformView:RegisterAllEvents()
    local events = {
        {game.SwornEvent.UpdatePlatformInfo, handler(self, self.UpdatePlatformInfo)},
        {game.SwornEvent.OnSwornGreet, handler(self, self.SetGreetText)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SwornPlatformView:Init(open_idx)
    self.ctrl:ClearGreetInfo()

    self.list_page = self._layout_objs["list_page"]
    self.list_page:SetHorizontalBarTop(true)

    self:InitView()
    
    self.type_info = {}
    self.ctrl_page = self:GetRoot():AddControllerCallback("ctrl_page", function(idx)
        self.type = idx + 1
        if not self.type_info[self.type] then
            self.ctrl:SendSwornGetPlatformList(self.type)
            self.type_info[self.type] = true
        end
    end)

    open_idx = open_idx or 1
    self.ctrl_page:SetSelectedIndexEx(open_idx-1)
end

function SwornPlatformView:InitView()
    self.txt_times = self._layout_objs.txt_times

    self.btn_register = self._layout_objs.btn_register
    self.btn_register:AddClickCallBack(function()
        local platform_info = self.ctrl:GetPlatformInfo()
        if not platform_info then
            return
        elseif platform_info.registered == 0 then
            self.ctrl:OpenSwornRegisterView()
        else
            self:ShowRegisterCancelView()
        end
    end)

    self.btn_change = self._layout_objs.btn_change
    self.btn_change:AddClickCallBack(function()
        if self.type then
            self.ctrl:SendSwornGetPlatformList(self.type)
        end
    end)

    for _, v in ipairs(PageConfig) do
        self:GetTemplate(v.item_class, v.item_path)
    end
end

function SwornPlatformView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6255])
end

function SwornPlatformView:SetGreetText()
    local platform_info = self.ctrl:GetPlatformInfo()
    local daily_greet_num = config.sworn_base.daily_greet_num
    self.txt_times:SetText(string.format(config.words[6256], daily_greet_num - platform_info.greet_num, daily_greet_num))
end

function SwornPlatformView:SetRegisterText()
    local platform_info = self.ctrl:GetPlatformInfo()
    local txt = platform_info.registered == 0 and config.words[6278] or config.words[6279]
    self.btn_register:SetText(txt)
end

function SwornPlatformView:UpdatePlatformInfo()
    self:SetGreetText()
    self:SetRegisterText()
end

function SwornPlatformView:ShowRegisterCancelView()
    local confirm_view = self.ctrl.SwornConfirmView
    confirm_view:SetTitle(config.words[6277])
    confirm_view:SetContent(config.words[6280])

    confirm_view:SetOkBtn(function()
        self.ctrl:SendSwornCancelRegister()
    end, config.words[100])

    confirm_view:SetCancelBtn(function()
    end, config.words[101])

    confirm_view:Open()
end

return SwornPlatformView
