local AchieveView = Class(game.BaseView)

function AchieveView:_init()
    self._package_name = "ui_achieve"
    self._com_name = "achieve_view"

    self._view_level = game.UIViewLevel.Second
    self._show_money = true
end

function AchieveView:OpenViewCallBack()
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[3401])
    self:InitTemplate()
    self:BindEvent(game.AchieveEvent.AchieveInfo, function()
        self:SetBtnTips()
    end)
end

function AchieveView:CloseViewCallBack()
    self._layout_objs.list_tab:SetItemNum(0)
end

function AchieveView:InitTemplate()

    self._layout_objs.list_tab:SetItemNum(#config.achieve_cate)
    self.btn_list = {}
    self.btn_data = {}
    for i = 1, #config.achieve_cate do
        local item = self._layout_objs.list_tab:GetChildAt(i - 1)
        table.insert(self.btn_data, config.achieve_cate[i])
        table.insert(self.btn_list, item)
        item:SetText(config.achieve_cate[i].name)
    end

    local achieve_page = self:CreateList("list_page", "game/achieve/item/achieve_template")
    achieve_page:SetRefreshItemFunc(function(item, idx)
        item:SetTemplateInfo(config.achieve_cate[idx].cate)
    end)
    achieve_page:SetItemNum(#config.achieve_cate)
    self._layout_objs.list_page:SetHorizontalBarTop(true)

    self.controller = self:GetRoot():GetController("c1")
    self.controller:SetPageCount(#config.achieve_cate)
    self.controller:SetSelectedIndexEx(0)

    self:SetBtnTips()
end

function AchieveView:SetBtnTips()
    for i, v in ipairs(self.btn_list) do
        local tips = game.AchieveCtrl.instance:GetAchieveCateTips(self.btn_data[i].cate)
        game.Utils.SetTip(v, tips, {x = 120, y = 0})
    end
end

return AchieveView
