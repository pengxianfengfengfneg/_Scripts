local OpenFuncTemplate = Class(game.UITemplate)

function OpenFuncTemplate:_init(parent)
    self.parent = parent
    self.ctrl = game.OpenFuncCtrl.instance    
    self._package_name = "ui_open_func"
    self._com_name = "open_func_template"
end

function OpenFuncTemplate:OpenViewCallBack()
    self:Init()
end

function OpenFuncTemplate:CloseViewCallBack()
    self:Inactive()
end

function OpenFuncTemplate:Init()
    self.icon = self._layout_objs["icon"]
    self.img_icon = self._layout_objs["icon/img_icon"]
    self.img_func = self._layout_objs["img_func"]
    self.img_title = self._layout_objs["img_title"]
    self.icon_origin_pos = self.icon.position
    self.group_title = self._layout_objs["group_title"]
    self.ctrl_move = self:GetRoot():GetController("ctrl_move")
    self.ctrl_page = self:GetRoot():GetController("ctrl_page")

    self.duration = 1
    self.delay = 1.85
    self:GetRoot():AddClickCallBack(handler(self, self.OnEmptyClick))
end

local FuncTargetConfig = {
    [game.OpenFuncId.Pet] = function()
        return game.MainUICtrl.instance:GetPetCom()
    end,
}

function OpenFuncTemplate:InitOriginPos()
    local target_func_id = self.open_attr[4] or self.cfg.id
    local target = nil
    if FuncTargetConfig[target_func_id] then
        target = FuncTargetConfig[target_func_id]()
    else
        local func_btn = game.MainUICtrl.instance:GetFuncBtn(target_func_id)
        target = func_btn and func_btn:GetRoot()
    end
    if target then
        local global_pos_x, global_pos_y = target:ToGlobalPos(0, 0)
        self.target_pos_x, self.target_pos_y = self:GetRoot():ToLocalPos(global_pos_x, global_pos_y)
    else
        self.target_pos_x = 0
        self.target_pos_y = 0
    end
end

--打开功能模板
function OpenFuncTemplate:Active(func_id)
    self.cfg = config.func[func_id]
    self.open_attr = self.cfg.open_attr[1]
    
    if self.open_attr then
        if not game.GuideCtrl.instance:IsOpenView() and game.MainUICtrl.instance:IsViewOpen() then
            local target_func_id = self.open_attr[4] or func_id
            game.MainUICtrl.instance:ShowFuncBtn(target_func_id)
        end
        self:SetIconSprite()
        self:PlayFade()
        self:PlayEffect()
        self:TweenMoveIcon(self.delay)
    end
end
    
function OpenFuncTemplate:Inactive()
    self.icon:SetPosition(self.icon_origin_pos[1], self.icon_origin_pos[2])
    self:ClearUIEffect()
    self:StopTween()
    self:DelTimer()
    self:GetRoot():StopAllTransition()
end

function OpenFuncTemplate:OnEmptyClick()
    if not self.is_moving then
        self:TweenMoveIcon()
    end
end

function OpenFuncTemplate:SetIconSprite()
    local show_type = self.open_attr[1]
    local title = self.open_attr[2]
    local visible = title and type(title)=="string" and title~=""
    if visible then
        if show_type == 1 then
            self.img_func:SetSprite("ui_open_func", title)
        elseif show_type == 2 then
            self.img_title:SetSprite("ui_open_func", title, true)
        end
    end
    self.ctrl_page:SetSelectedIndexEx(show_type-1)

    self.group_title:SetVisible(visible)
    self.img_icon:SetSprite("ui_main", self.open_attr[3])

    self.icon.scaleX = 1
    self.icon.scaleY = 1

    self:GetRoot():StopAllTransition()
end

function OpenFuncTemplate:PlayFade()
    self:GetRoot():PlayTransition("trans_fade")
end

function OpenFuncTemplate:TweenMoveIcon(delay)
    self.ctrl_move:SetSelectedIndexEx(0)

    local MoveFunction = function()
        self:StopTween()
        self:InitOriginPos()

        local seq = DOTween.Sequence()
        self.tween = seq
        seq:AppendCallback(function()
            self.is_moving = true
            self.ctrl_move:SetSelectedIndexEx(1)
            local play_action = self:GetRoot():GetTransition("trans_scale")
            play_action:Play(1, 0, nil)
        end)
        seq:Append(self.icon:TweenMove({self.target_pos_x, self.target_pos_y}, self.duration))
        seq:SetAutoKill(true)
        seq:OnComplete(function()
            self.is_moving = false
            self.parent:CreateShowTimer()
        end)
    end

    self:DelTimer()
    if delay and delay > 0 then
        self.timer = global.TimerMgr:CreateTimer(delay, function()
            MoveFunction()
            self.timer = nil
            return true
        end)
    else
        MoveFunction()
    end
end

function OpenFuncTemplate:PlayEffect()
    local ui_effect = self:CreateUIEffect(self._layout_objs["icon/wrapper"],  "effect/ui/new_function.ab")
    ui_effect:SetLoop(true)
    ui_effect:Play()
end

function OpenFuncTemplate:StopTween()
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

function OpenFuncTemplate:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

return OpenFuncTemplate
