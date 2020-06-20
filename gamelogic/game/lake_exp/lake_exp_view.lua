local LakeExpView = Class(game.BaseView)

local config_kill_mon_exp_scene = config.kill_mon_exp_scene

function LakeExpView:_init(ctrl)
    self._package_name = "ui_lake_exp"
    self._com_name = "lake_exp_view"

    self._show_money = true

    self.ctrl = ctrl
end

function LakeExpView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:InitPageList()
    self:RegisterAllEvents()

    self.ctrl:SendLakeExperienceInfo()
    game.MainUICtrl.instance:SendGetCommonlyKeyValue(game.CommonlyKey.DailyOutsideKillMon)
end

function LakeExpView:CloseViewCallBack()
    
end

function LakeExpView:RegisterAllEvents()
    local events = {
        {game.LakeExpEvent.UpdateKillMonNum, handler(self, self.OnUpdateKillMonNum)},
        {game.LakeExpEvent.UpdateLakeExpInfo, handler(self, self.OnLakeExpInfo)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function LakeExpView:Init()
    self.btn_buy = self._layout_objs["btn_buy"]
    self.btn_buy:SetText(config.words[5407])
    self.btn_buy:AddClickCallBack(function()
        local item_id = config.kill_mon_exp_info.item_id
        game.ShopCtrl.instance:OpenViewByShopId(1, item_id)
    end)

    self.btn_quick_team = self._layout_objs["btn_quick_team"]
    self.btn_quick_team:SetText(config.words[5408])
    self.btn_quick_team:AddClickCallBack(function()
        game.MakeTeamCtrl.instance:OpenView()
    end)

    self.btn_near_team = self._layout_objs["btn_near_team"]
    self.btn_near_team:SetText(config.words[5409])
    self.btn_near_team:AddClickCallBack(function()
        game.MakeTeamCtrl.instance:OpenView()
    end)

    self.bar_progress = self._layout_objs["bar_progress"]
    self.txt_progress = self.bar_progress:GetChild("title")

    self.txt_exp = self._layout_objs["txt_exp"]
    self.txt_info = self._layout_objs["txt_info"]
    self.txt_use_num = self._layout_objs["txt_use_num"]

    self._layout_objs["txt_kill"]:SetText(config.words[5403])

    self.list_tab = self._layout_objs["list_tab"]
    self.ctrl_tab = self:GetRoot():GetController("ctrl_tab")

    self.target_kill_num = 3000

    self:SetProgress(self.ctrl:GetKillMonNum(), self.target_kill_num)
end

function LakeExpView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5400])
end

function LakeExpView:InitPageList()
    local item_name = "game/lake_exp/item/hang_scene_page_item"
    local item_num = #config.kill_mon_exp_scene

    self.list_page = self:CreateList("list_page", item_name)
    self.list_page:SetRefreshItemFunc(function(item, idx)
        local item_info = {page = idx}
        item:SetItemInfo(item_info)
    end)
    self.list_page:SetItemNum(item_num)

    self.list_page:AddScrollEndCallback(function(perX, perY)
        local index = self._layout_objs["list_page"]:GetFirstChildInView()
        self.ctrl_tab:SetSelectedIndex(index)
    end)

    self.list_tab:SetItemNum(item_num)
    self.list_tab:ResizeToFit(item_num)

    self.ctrl_tab:SetPageCount(item_num)

    if item_num > 0 then
        local open_page = self:GetOpenPage()-1
        self.list_page:ScrollToView(open_page)
        self.ctrl_tab:SetSelectedIndex(open_page)
        self.list_tab:GetChildAt(open_page):SetSelected(true)
    end
end

function LakeExpView:SetProgress(cur_num, total_num)
    self.bar_progress:SetProgressValue(cur_num / total_num * 100)
    self.txt_progress:SetText(string.format("%d/%d", cur_num, total_num))
end

function LakeExpView:SetExpText()
    local cur_kill_mon_num = self.ctrl:GetKillMonNum()
    local exp_str = (cur_kill_mon_num <= self.target_kill_num) and config.words[5410] or config.words[5411]
    local reduce = 90
    self.txt_exp:SetText(string.format(config.words[5401], exp_str))
    self.txt_info:SetText(string.format(config.words[5405], self.target_kill_num, reduce))
end

function LakeExpView:SetUseText(have_times)
    self.txt_use_num:SetText(string.format(config.words[5406], have_times))
end 

function LakeExpView:OnUpdateKillMonNum(kill_mon_num)
    self:SetProgress(kill_mon_num, self.target_kill_num)
    self:SetExpText()
end

function LakeExpView:OnLakeExpInfo(data)
    self.lake_exp_info = data
    self:SetUseText(data.have_times)
end

function LakeExpView:GetOpenPage()
    local role_level = game.RoleCtrl.instance:GetRoleLevel()
    for page, v in ipairs(config_kill_mon_exp_scene) do
        for id, cfg in ipairs(v) do
            local monster_lv = cfg.monster_lv
            local min_lv = monster_lv[1]
            local max_lv = monster_lv[2] or monster_lv[1]
            if role_level <= max_lv then
                return page
            end
        end
    end
    return #config_kill_mon_exp_scene
end

function LakeExpView:SetGuideOper()
    local open_page = 1
    self.list_page:ScrollToView(open_page)
    self.ctrl_tab:SetSelectedIndex(open_page)
    self.list_tab:GetChildAt(open_page):SetSelected(true)
end

return LakeExpView
