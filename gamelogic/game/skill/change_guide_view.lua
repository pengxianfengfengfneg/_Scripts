local ChangeGuideView = Class(game.BaseView)

function ChangeGuideView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "change_guide_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function ChangeGuideView:OpenViewCallBack(id)
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2207])

    self.cur_skill_id = id

    self.list = self:CreateList("list", "game/skill/item/hero_guide_item")
    self.list:SetRefreshItemFunc(function(item, idx)
        local info = self.hero_list[idx]
        item:SetHeroInfo(info, id)
    end)

    local tab_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
        self:SelectType(idx)
    end)
    self._layout_objs.btn_label1:SetVisible(#self:GetHeroList(id, 0) > 0)
    self._layout_objs.btn_label2:SetVisible(#self:GetHeroList(id, 1) > 0)
    tab_controller:SetSelectedIndexEx(0)
end

function ChangeGuideView:SelectType(type)
    self.hero_list = self:GetHeroList(self.cur_skill_id, type)
    self.list:SetItemNum(#self.hero_list)
    self.list:Foreach(function(obj)
        obj:SetGuideType(type)
    end)
end

function ChangeGuideView:OnEmptyClick()
    self:Close()
end

function ChangeGuideView:GetHeroList(id, guide_type)
    local career = game.RoleCtrl.instance:GetCareer()
    local hero_list = {}
    for i, v in pairs(config.hero) do
        if v.legend >= guide_type then
            for k, val in pairs(v.skill) do
                if val[1] == career and val[2] == id then
                    table.insert(hero_list, v)
                    break
                end
            end
        end
    end
    return hero_list
end

return ChangeGuideView
