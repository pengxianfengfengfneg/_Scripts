local SkillSettingView = Class(game.BaseView)

function SkillSettingView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "role_skill_setting_view"

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function SkillSettingView:OpenViewCallBack(open_index)
    self:Init()
    self:InitBg()
    self:InitList()

    self:RegisterAllEvents()
end

function SkillSettingView:CloseViewCallBack()
    for _,v in ipairs(self.setting_item_list or {}) do
        v:DeleteMe()
    end
    self.setting_item_list = {}
end

function SkillSettingView:RegisterAllEvents()
    local events = {
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SkillSettingView:Init()
    local career = game.RoleCtrl.instance:GetCareer()
    self.skill_career_cfg = config.skill_career[career]
    table.sort(self.skill_career_cfg, function(v1,v2)
        return v1.index<v2.index
    end)
end

function SkillSettingView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1659])
end

function SkillSettingView:InitList()
    local list_items = self._layout_objs["list_items"]
    local item_num = list_items:GetItemNum()

    self.setting_item_list = {}
    local item_class = require("game/skill/skill_setting_item")
    for i=0,item_num-1 do
        local idx = i + 1
        local skill_id = self:GetSkillIdForIdx(idx)
        local item_obj = list_items:GetChildAt(i)
        local is_actived = self.ctrl:IsSkillSettingActived(idx)
        local item = item_class.New(skill_id, idx)
        item:SetVirtual(item_obj)
        item:Open()
        item:SetSelected(is_actived)
        item:AddSelectEvent(function(select_item)
            self:OnSelectItem(select_item)
        end)

        table.insert(self.setting_item_list, item)
    end
end

function SkillSettingView:OnSelectItem(item)
    local index = item:GetIndex()
    local is_selected = item:IsSelected()
    local setting_value = self.ctrl:SetSkillSettingValue(index, is_selected)

    game.SysSettingCtrl.instance:SetInt(game.CommonlyKey.SkillSetting, setting_value)

    local main_role = game.Scene.instance:GetMainRole()
    main_role:SetSkillEnabled(item:GetSkillId(), is_selected)
end

function SkillSettingView:GetSkillIdForIdx(idx)
    return (self.skill_career_cfg[idx] or {}).skill_id or 0
end

return SkillSettingView
