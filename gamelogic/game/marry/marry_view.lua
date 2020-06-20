local MarryView = Class(game.BaseView)

function MarryView:_init(ctrl)
    self._package_name = "ui_marry"
    self._com_name = "marry_view"

    self._show_money = true
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function MarryView:OpenViewCallBack()
    local view = self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[2601])
    view:SetBtnWhVisible(true)
    view:SetInfoCallback(function()
        game.GameMsgCtrl.instance:OpenInfoDescView(10)
    end)

    self:SetMarryView()

    self:InitBtn()

    self:InitSkill()
    self:UpdateSkillCD()

    local skill_cfg = {}
    for k, v in pairs(config.marry_skill) do
        v.id = k
        table.insert(skill_cfg, v)
    end
    table.sort(skill_cfg, function(a, b)
        return a.id < b.id
    end)
    self.tab_controller = self:GetRoot():AddControllerCallback("btn_tab", function(idx)
        self:SetMarrySkill(skill_cfg[idx + 1])
    end)
    self.tab_controller:SetSelectedIndexEx(0)

    self:BindEvent(game.MarryEvent.UpdateSkillCD, function()
        self:UpdateSkillCD()
    end)
end

function MarryView:CloseViewCallBack()
end

function MarryView:SetMarryView()
    local info = game.MarryCtrl.instance:GetMarryInfo()
    local my_info = game.RoleCtrl.instance:GetChatRoleInfo()
    local groom_icon = self:GetIconTemplate("groom_icon")
    local bride_icon = self:GetIconTemplate("bride_icon")
    if my_info.gender == game.Gender.Male then
        self._layout_objs.groom_name:SetText(my_info.name)
        self._layout_objs.bride_name:SetText(info.mate_name)
        groom_icon:UpdateData({icon = my_info.icon, frame = my_info.frame})
        bride_icon:UpdateData({icon = info.mate_icon, frame = info.mate_frame})
    else
        self._layout_objs.groom_name:SetText(info.mate_name)
        self._layout_objs.bride_name:SetText(my_info.name)
        bride_icon:UpdateData({icon = my_info.icon, frame = my_info.frame})
        groom_icon:UpdateData({icon = info.mate_icon, frame = info.mate_frame})
    end
    self._layout_objs.date:SetText(os.date("%Y-%m-%d", info.marry_time))
    local married_time = global.Time:GetServerTime() - info.marry_time
    married_time = math.ceil(married_time / 86400)
    self._layout_objs.days:SetText(married_time)
    local title_name = ""
    for _, v in ipairs(config.marry_title) do
        if married_time >= v.low then
            title_name = v.name
        end
    end
    self._layout_objs.title:SetText(title_name)

    self._layout_objs.cur_love:SetText(game.BagCtrl.instance:GetMoneyByType(game.MoneyType.LoveValue))
    self._layout_objs.his_love:SetText(info.love_value)
end

function MarryView:SetMarrySkill(cfg)
    self.select_skill = cfg
    local skill_info = game.MarryCtrl.instance:GetMarrySkill(cfg.id)
    local skill_cfg = config.skill[cfg.id][skill_info.level]
    self._layout_objs.name:SetText(skill_cfg.name)
    self._layout_objs.level:SetText(skill_info.level .. config.words[1217])
    self._layout_objs.effect:SetText(skill_cfg.desc)
end

function MarryView:InitBtn()
    self._layout_objs.btn_go:AddClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then
            main_role:GetOperateMgr():DoGoToTalkNpc(config.marry_npc[4])
            self:Close()
        end
    end)

    self._layout_objs.btn_love:AddClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then
            main_role:GetOperateMgr():DoGoToTalkNpc(config.marry_npc[5])
            self:Close()
        end
    end)

    self._layout_objs.btn_use:AddClickCallBack(function()
        local last_use = game.MarryCtrl.instance:GetSkillCD(self.select_skill.id)
        local skill_info = game.MarryCtrl.instance:GetMarrySkill(self.select_skill.id)
        local total_cd = config.marry_skill[self.select_skill.id][skill_info.level].cd
        if global.Time:GetServerTime() - last_use > total_cd then
            game.MarryCtrl.instance:SendUseSkill(self.select_skill.id)
        else
            game.GameMsgCtrl.instance:PushMsg(config.words[2624])
        end
    end)
end

function MarryView:InitSkill()
    self.skill_masks = {}
    local skill_cfg = {}
    for k, _ in pairs(config.marry_skill) do
        table.insert(skill_cfg, k)
    end
    table.sort(skill_cfg, function(a, b)
        return a < b
    end)
    for i, v in ipairs(skill_cfg) do
        self.skill_masks[v] = self._layout_objs["skill" .. i]:GetChild("mask")
    end
end

function MarryView:UpdateSkillCD()
    local cd_list = game.MarryCtrl.instance:GetSkillCDList()
    if cd_list then
        local server_time = global.Time:GetServerTime()
        for _, v in pairs(cd_list) do
            local skill_info = game.MarryCtrl.instance:GetMarrySkill(v.skill_id)
            local total_cd = config.marry_skill[v.skill_id][skill_info.level].cd
            local cd = total_cd + v.last_use - server_time
            if cd > 0 then
                self:SetFillTween(self.skill_masks[v.skill_id], cd / total_cd, 0, cd)
            else
                self.skill_masks[v.skill_id]:SetVisible(false)
            end
        end
    end
end

function MarryView:SetFillTween(mask, start_value, end_value, duration)
    mask:SetFillAmount(start_value)
    mask:SetVisible(true)
    mask:TweenFillValue(end_value, duration)
end

return MarryView
