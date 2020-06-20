local SkillBloodSettingView = Class(game.BaseView)

function SkillBloodSettingView:_init()
    self._package_name = "ui_role"
    self._com_name = "role_skill_blood_setting_view"

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full
end

function SkillBloodSettingView:OpenViewCallBack()
    self:Init()
    self:InitBg()
end

function SkillBloodSettingView:CloseViewCallBack()
    for i,v in ipairs(self.skill_item_list) do
        v:DeleteMe()
    end
    self.skill_item_list = nil

    for k,v in pairs(self.value_map) do
        global.EventMgr:Fire(game.SkillEvent.SkillBloodSettingChange, k, v)
        game.SysSettingCtrl.instance:SaveLocal(k, math.floor(v))
    end
end

function SkillBloodSettingView:Init()
    local career = game.RoleCtrl.instance:GetCareer()
    self.skill_career_cfg = config.skill_career[career]
    table.sort(self.skill_career_cfg, function(v1,v2)
        return v1.index < v2.index
    end)

    self.skill_item_list = {}
    self.value_map = {}

    local num = 0
    for i,v in ipairs(self.skill_career_cfg) do
        local skill_cfg = config.skill[v.skill_id][1]
        if #skill_cfg.condition > 0 and skill_cfg.condition[1] == 2 then
            num = num + 1

            local com = self._layout_objs["s" .. num]

            local skill_item = require("game/skill/item/skill_item_circle").New()
            skill_item:SetVirtual(com:GetChild("item"))
            skill_item:Open()
            skill_item:SetItemInfo({id = v.skill_id, lv = 1})
            table.insert(self.skill_item_list, skill_item)

            com:GetChild("txt_name"):SetText(skill_cfg.name)

            local txt_detail = com:GetChild("txt_detail")
            com:GetChild("slider"):AddChangeCallback(function(value)
                self.value_map[v.skill_id] = value
                txt_detail:SetText(string.format(config.words[2230], math.floor(value)))
            end)

            local val = game.SysSettingCtrl.instance:GetLocal(v.skill_id)
            if val == -1 then
                val = math.floor(skill_cfg.condition[2] * 100)
            end
            com:GetChild("slider"):SetValue(val)
            txt_detail:SetText(string.format(config.words[2230], math.floor(val)))
        end

        if num >= 2 then
            break
        end
    end
end

function SkillBloodSettingView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1670])
end

return SkillBloodSettingView
