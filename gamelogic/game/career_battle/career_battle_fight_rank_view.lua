local CareerBattleFightRankView = Class(game.BaseView)

function CareerBattleFightRankView:_init(ctrl)
    self._package_name = "ui_career_battle"
    self._com_name = "fight_rank_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self:AddPackage("ui_rank")
end

function CareerBattleFightRankView:_delete()
    
end

function CareerBattleFightRankView:OpenViewCallBack(open_idx)
    self:Init(open_idx)
    self:InitBg()
end

function CareerBattleFightRankView:Init(open_idx)
    self.list_page = self._layout_objs["list_page"]
    self.list_page:SetHorizontalBarTop(true)
    self.ctrl_page = self:GetRoot():AddControllerCallback("ctrl_page", function(idx)
        local tpl = self.list_page:GetChildAt(idx)
        self:GetTemplateByObj("game/career_battle/template/fight_rank_template", tpl):Active()
    end)

    self.list_tab = self._layout_objs["list_tab"]

    self:InitView()

    open_idx = open_idx or 1
    self.ctrl_page:SetSelectedIndexEx(open_idx-1)
end

function CareerBattleFightRankView:InitView()
    local career_cfg = config.career_init
    local item_num = #career_cfg

    self.ctrl_page:SetPageCount(item_num)
    self.list_page:SetItemNum(item_num)
    self.list_tab:SetItemNum(item_num)

    for k, v in ipairs(career_cfg) do
        local tab = self.list_tab:GetChildAt(k-1)
        tab:SetText(v.name)
        local tpl = self.list_page:GetChildAt(k-1)
        self:GetTemplateByObj("game/career_battle/template/fight_rank_template", tpl, v.career)
    end
end

function CareerBattleFightRankView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[4822])
end

return CareerBattleFightRankView
