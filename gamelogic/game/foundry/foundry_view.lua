local FoundryView = Class(game.BaseView)

function FoundryView:_init(ctrl)
    self._package_name = "ui_foundry"
    self._com_name = "foundry_view2"
    --self.guide_index = 1
    self._show_money = true

    self.ctrl = ctrl

    self.foundry_data = self.ctrl:GetData()
end

function FoundryView:_delete()
end

function FoundryView:OpenViewCallBack(template_index)
    
    
    self._layout_objs["list_page"]:SetHorizontalBarTop(true)
    self.list_page = self._layout_objs["list_page"]

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[1200])

    --self:SetGuideIndex(1)
    self:SetGuideIndex()
    self.tab_controller = self:GetRoot():AddControllerCallback("btn_tab", function(idx)
        self:OnClickPage(idx)
        self.select_view_index = idx+1
        if idx == 3 then
            self.compose_template:ResetView()
        elseif idx == 0 then
            self.stren_template:UpdateMidInfo()
        end
        self:SetGuideIndex(idx+1)
    end)

    local mainrole_lv = game.Scene.instance:GetMainRoleLevel()
    if mainrole_lv < 17 then
        self.list_page:SetLastPageCallBack(1, function()
        end)
        if template_index == 2 then
            template_index = 1
        end
    elseif mainrole_lv < 20 then
        self.list_page:SetLastPageCallBack(2, function()
        end)
        if template_index == 3 then
            template_index = 2
        end
    else
        self.list_page:SetLastPageCallBack(4, function()
        end)
    end

    self.stren_template = self:GetTemplateByObj("game/foundry/foundry_stren_template", self._layout_objs["list_page"]:GetChildAt(0))
    self.stone_template = self:GetTemplateByObj("game/foundry/foundry_stone_template", self._layout_objs["list_page"]:GetChildAt(1))
    self.smelt_template = self:GetTemplateByObj("game/foundry/foundry_smelt_template", self._layout_objs["list_page"]:GetChildAt(2))
    self.compose_template = self:GetTemplateByObj("game/foundry/foundry_compose_template", self._layout_objs["list_page"]:GetChildAt(3))

    if not template_index then
        self.tab_controller:SetSelectedIndex((self.select_view_index and self.select_view_index -1) or 0, true)
    else
        local time = 1
        self.timer = global.TimerMgr:CreateTimer(0.5,
            function()
                time = time - 1
                if time <= 0 then
                    self.tab_controller:SetSelectedIndex((template_index and template_index -1) or 0, true)
                    self:DelTimer()
                end
            end)
    end

    self:SetStrenHd()

    self:SetStoneHd()

    self:SetComposeHd()

    self:BindEvent(game.FoundryEvent.StrenSucc, function(data)
        self:SetStrenHd()
        self:SetComposeHd()
    end)

    self:BindEvent(game.FoundryEvent.OneKeyStrenSucc, function(data)
        self:SetStrenHd()
        self:SetComposeHd()
    end)

    self:BindEvent(game.FoundryEvent.InlaySucc, function(data)
        self:SetStoneHd()
    end)

    self:BindEvent(game.FoundryEvent.ComposeSucc, function(data)
        self:SetComposeHd()
    end)

    self._layout_objs["list_tab"]:GetChildAt(1):AddClickCallBack(function()
        self:OnClickPage(1)
        self.tab_controller:SetSelectedIndex(1)
        self:SetGuideIndex(2)
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_view2/btn_stone"})
        game.ViewMgr:FireGuideEvent()
    end)

    self._layout_objs["list_tab"]:GetChildAt(2):AddClickCallBack(function()
        self:OnClickPage(2)
        self.tab_controller:SetSelectedIndex(2)
        self:SetGuideIndex(3)
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_view2/btn_smelt"})
        game.ViewMgr:FireGuideEvent()
    end)

    self._layout_objs["list_tab"]:GetChildAt(3):AddClickCallBack(function()
        self:OnClickPage(3)
        self.tab_controller:SetSelectedIndex(3)
        self.compose_template:ResetView()
        self:SetGuideIndex(4)
    end)
end

function FoundryView:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function FoundryView:CloseViewCallBack()
    self:DelTimer()
    if game.GuideCtrl.instance then
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_view2/btn_close"})
    end

    self:FireEvent(game.FoundryEvent.MainUIRedpoint)
end

function FoundryView:SetStrenHd()
    local can_stren = self.foundry_data:CheckCanStren()
    self._layout_objs["hd1"]:SetVisible(can_stren)
end

function FoundryView:SetStoneHd()
    local can_stone = self.foundry_data:CheckAllEquipCanStone()
    self._layout_objs["hd2"]:SetVisible(can_stone) 
end

function FoundryView:SetComposeHd()
    local can_compose = self.foundry_data:CheckCanCompose()
    self._layout_objs["hd4"]:SetVisible(can_compose) 
end

function FoundryView:OnClickPage(idx)
    local mainrole_lv = game.Scene.instance:GetMainRoleLevel()

    --修炼44级，打造50级开启提示
    if idx == 1 then
        if mainrole_lv < 17 then
            game.GameMsgCtrl.instance:PushMsg("17" .. config.words[2101])
        end
    elseif idx == 2 or idx == 3 then
        if mainrole_lv < 20 then
            game.GameMsgCtrl.instance:PushMsg("20" .. config.words[2101])
        end
    end

    game.GuideCtrl.instance:CheckTabHideGuide(idx+1)
end

return FoundryView
