local HeroSetGuideView = Class(game.BaseView)

function HeroSetGuideView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "change_guide_view"

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function HeroSetGuideView:OpenViewCallBack(id)
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2207])

    local hero_list = self:GetHeroList(id)

    self.list = game.UIList.New(self._layout_objs.list)
    self.list:SetCreateItemFunc(function(obj)
        local item = require("game/skill/hero_set_guide_item").New()
        item:SetVirtual(obj)
        item:Open()
        item:SetClickCallback(function()
            self:Close()
        end)
        return item
    end)
    self.list:SetRefreshItemFunc(function(item, idx)
        local info = hero_list[idx]
        item:SetHeroInfo(info, id)
    end)
    self.list:SetVirtual(true)
    self.list:SetItemNum(#hero_list)
end

function HeroSetGuideView:CloseViewCallBack()
    if self.list then
        self.list:DeleteMe()
        self.list = nil
    end
end

function HeroSetGuideView:OnEmptyClick()
    self:Close()
end

function HeroSetGuideView:GetHeroList(id)
    local career = game.RoleCtrl.instance:GetCareer()
    local hero_list = {}
    for i, v in pairs(config.hero) do
        for k, val in pairs(v.skill) do
            if val[1] == career and val[2] == id then
                table.insert(hero_list, v)
                break
            end
        end
    end
    return hero_list
end

return HeroSetGuideView
