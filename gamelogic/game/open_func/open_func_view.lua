local OpenFuncView = Class(game.BaseView)

local open_func_type = {
    new_skill = 0,
    new_func = 1,
}

function OpenFuncView:_init(ctrl)
    self._package_name = "ui_open_func"
    self._com_name = "open_func_view"
    self.ctrl = ctrl
    self._view_level = game.UIViewLevel.Standalone
    self._mask_type = game.UIMaskType.None

    self:AddPackage("ui_main")
    self.show_list = {}
end

function OpenFuncView:_delete()
    self.func_id = nil
    self.skill_data = nil
end

function OpenFuncView:OnPreOpen()
    local scene = game.Scene.instance
    self.main_role = scene and scene:GetMainRole()
    if self.main_role then
        self.main_role:SetPauseOperate(true)
    end
end

function OpenFuncView:OnPreClose()
    if self.main_role then
        self.main_role:SetPauseOperate(false)
    end
end

function OpenFuncView:OpenViewCallBack()
    self:InitTemplate()
    self:InitController()
    self:CreateShowTimer()
end

function OpenFuncView:CloseViewCallBack()
     self.is_open = false
     self:StopShowTimer()
     self:StopNextTimer()
end

function OpenFuncView:ShowNewFunc(data)
    for _, v in ipairs(data) do
        if self:CheckFunc(v) then
            v.type = self:GetFuncType(v)
            table.insert(self.show_list, v)
        end
    end
    table.sort(self.show_list, function(m, n)
        if m.skill_id and n.skill_id then
            return m.skill_id < n.skill_id
        elseif m.func_id and n.func_id then
            return m.func_id < n.func_id
        else
            return (m.func_id or 0) > (n.func_id or 0)
        end
    end)
    if not self.is_open and table.nums(self.show_list) > 0 then
        self:Open()
        self.is_open = true
    end
end

function OpenFuncView:ShowNextFunc()
    if table.nums(self.show_list) > 0 then
        local data = self.show_list[1]
        table.removebyvalue(self.show_list, data)
        local delay = self:GetShowInterval(data)
        if delay > 0 then
            self.next_timer = global.TimerMgr:CreateTimer(delay, function()
                self:DoShowNextFunc(data)
                self.next_timer = nil
                return true
            end)     
        else
            self:DoShowNextFunc(data)
        end  
    else
        self:Close()
    end
end

function OpenFuncView:DoShowNextFunc(data)
    self.cur_new_func = data
    self:ShowLayout()
    self:Refresh(data)
end

function OpenFuncView:CheckFunc(data)
    if not data then
        return false
    elseif data.func_id then
        local func = config.func[data.func_id]
        return func and func.open_attr and func.open_attr[1] ~= nil or false
    elseif data.skill_id then
        return config.skill[data.skill_id] ~= nil
    else
        return false
    end
end

function OpenFuncView:OnEmptyClick()
    local cfg = self.template_cfg[self.type]
    if cfg then
        local template = self:GetTemplate(cfg[1], cfg[2])
        if template then
            template:OnEmptyClick()
        end
    end
end

function OpenFuncView:InitTemplate()
    self.template_cfg = {
        {"game/open_func/template/open_func_skill_template", "open_func_skill_template"},
        {"game/open_func/template/open_func_template", "open_func_template"},
        {"game/open_func/template/open_func_grow_template", "open_func_grow_template"},
    }
    for _, v in pairs(self.template_cfg) do  
        local template = self:GetTemplate(v[1], v[2])
    end
end

function OpenFuncView:InitController()
    self.ctrl_func = self:GetRoot():AddControllerCallback("ctrl_func", function(idx)
        self:ShowTemplate(idx+1)
    end)
end

function OpenFuncView:ShowTemplate(idx)
    if self.cur_act_tpl and self.cur_act_tpl.Inactive then
        self.cur_act_tpl:Inactive()
        self.cur_act_tpl = nil
    end
    local cfg = self.template_cfg[idx]
    local template = self:GetTemplate(cfg[1], cfg[2])
    template:Active(self.func_id or self.skill_data)
    self.cur_act_tpl = template
end

function OpenFuncView:Refresh(data)
    self.func_id = data.func_id
    self.skill_data = data
    local index = 0
    if self.func_id then
        local open_attr = config.func[self.func_id].open_attr[1]
        index = open_attr and open_attr[1]
        if not index then 
            self:Close()
        else
            index = 1
        end
    end
    self.ctrl_func:SetSelectedIndexEx(index)
end

function OpenFuncView:GetFuncType(data)
    if data.func_id then
        return config.func[data.func_id].open_attr[1][1]
    else
        return 0
    end
end

function OpenFuncView:GetShowInterval(cur_new_func)
    local last_new_func = self.cur_new_func
    if last_new_func and last_new_func.type == cur_new_func.type and cur_new_func.type == open_func_type.new_func then
        return 0
    else
        return 0
    end
end

function OpenFuncView:CanShowFunc()
    local check_func_list = {
        function()
            return not game.DailyTaskCtrl.instance:IsPuzzleGamePlayEnd()
        end,
    }
    for _, func in pairs(check_func_list) do
        if not func() then
            return false
        end
    end
    return true
end

function OpenFuncView:CreateShowTimer()
    self:HideLayout()
    self.show_tween = DOTween:Sequence()
    self.show_tween:AppendCallback(function()
        if self:CanShowFunc() then
            self:ShowNextFunc()
            self:StopShowTimer()
        end
    end)
    self.show_tween:AppendInterval(0.15)
    self.show_tween:SetLoops(-1)
end

function OpenFuncView:StopShowTimer()
    if self.show_tween then
        self.show_tween:Kill(false)
        self.show_tween = nil
    end
end

function OpenFuncView:StopNextTimer()
    if self.next_timer then
        global.TimerMgr:DelTimer(self.next_timer)
        self.next_timer = nil
    end
end

return OpenFuncView
