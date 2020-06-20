local SkillUpgradeView = Class(game.BaseView)

function SkillUpgradeView:_init(ctrl)
    self._package_name = "ui_marry"
    self._com_name = "skill_upgrade_view"

    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function SkillUpgradeView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2619])

    local skill_cfg = {}
    for k, v in pairs(config.marry_skill) do
        v.id = k
        table.insert(skill_cfg, v)
    end
    table.sort(skill_cfg, function(a, b)
        return a.id < b.id
    end)
    self.tab_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
        self:SetMarrySkill(skill_cfg[idx + 1])
    end)
    self.tab_controller:SetSelectedIndexEx(0)

    self._layout_objs.btn_upgrade:AddClickCallBack(function()
        game.MarryCtrl.instance:SendMarryUpgradeSkill(self.select_skill.id)
    end)

    self:SetLoveValue()

    self:BindEvent(game.MarryEvent.SkillUpgrade, function()
        self:SetMarrySkill(self.select_skill)
    end)
end

function SkillUpgradeView:SetLoveValue()
    self._layout_objs.own_love:SetText(game.MarryCtrl.instance:GetHisLove())
end

function SkillUpgradeView:SetMarrySkill(cfg)
    self.select_skill = cfg
    local skill_info = game.MarryCtrl.instance:GetMarrySkill(cfg.id)
    local skill_cfg = config.skill[cfg.id][skill_info.level]
    self._layout_objs.name:SetText(skill_cfg.name)
    self._layout_objs.effect:SetText(skill_cfg.desc)
    self._layout_objs.need_love:SetText(skill_cfg.cost)
    self._layout_objs.cur_level:SetText(skill_info.level .. config.words[1217])
    self._layout_objs.cur_txt:SetText(cfg[skill_info.level].desc)
    if skill_info.level >= #cfg then
        self._layout_objs.next_level:SetText(config.words[1219])
        self._layout_objs.next_txt:SetText("")
        self._layout_objs.btn_upgrade:SetVisible(false)
    else
        self._layout_objs.next_level:SetText(skill_info.level + 1 .. config.words[1217])
        self._layout_objs.next_txt:SetText(cfg[skill_info.level + 1].desc)
        self._layout_objs.btn_upgrade:SetVisible(true)
    end
end

return SkillUpgradeView
