local HeroView = Class(game.BaseView)

function HeroView:_init(ctrl)
    self._package_name = "ui_hero"
    self._com_name = "hero_view"
    self:AddPackage("ui_heroicon")

    self._show_money = true

    self.ctrl = ctrl
end

function HeroView:OpenViewCallBack(open_idx)
    open_idx = open_idx or 1
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.func[game.OpenFuncId.Hero].name)

    self.controller = self:GetRoot():GetController("c1")

    self:InitTempalte()

    --设置经脉界面打开
    local flag = self:SetPulseOpen()
    if flag == false and open_idx == 2 then
        open_idx = 1
    end
    global.TimerMgr:CreateTimer(0.1, function()
        self.controller:SetSelectedIndexEx(open_idx - 1)
        return true
    end)
end

function HeroView:CloseViewCallBack()
    self.controller = nil
    self:DelTimer()
end

function HeroView:SetPulseOpen()
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    local low_lv = 100
    for _, v in pairs(config.pulse) do
        if v.level < low_lv then
            low_lv = v.level
        end
    end

    local btn_pulse = self._layout_objs.list_tab:GetChildAt(1)
    if role_lv >= low_lv then
        btn_pulse:AddClickCallBack(function()
            self.controller:SetSelectedIndexEx(1)
        end)
        self._layout_objs.list_page:SetLastPageCallBack(2, function()
        end)
    else
        btn_pulse:AddClickCallBack(function()
            game.GameMsgCtrl.instance:PushMsg(low_lv .. config.words[2101])
        end)
        self._layout_objs.list_page:SetLastPageCallBack(1, function()
            game.GameMsgCtrl.instance:PushMsg(low_lv .. config.words[2101])
        end)
    end

    return role_lv >= low_lv
end

function HeroView:InitTempalte()
    self.book_template = self:GetTemplateByObj("game/hero/book_template", self._layout_objs.list_page:GetChildAt(0))
    self:GetTemplateByObj("game/hero/pulse_template", self._layout_objs.list_page:GetChildAt(1))

    self._layout_objs.list_page:SetHorizontalBarTop(true, 23)
end

function HeroView:SetBookToBot()

    -- local time = 1.5
    -- self.timer = global.TimerMgr:CreateTimer(0.5,
    --     function()
    --         time = time - 1
    --         if time <= 0 then
    --             self.book_template:SetListScrollToBot()
    --             self:DelTimer()
    --         end
    --     end)
end

function HeroView:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

return HeroView
