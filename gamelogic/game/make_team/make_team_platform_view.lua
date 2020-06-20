local MakeTeamPlatformView = Class(game.BaseView)

local handler = handler
local string_gsub = string.gsub
local string_format = string.format
local TimerMgr = global.TimerMgr

local TeamTargetConfig = require("game/make_team/team_target_config")

function MakeTeamPlatformView:_init(ctrl)
    self._package_name = "ui_make_team"
    self._com_name = "make_team_platform_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self.ctrl = ctrl
end

function MakeTeamPlatformView:OpenViewCallBack(target, auto_match)
    self.open_target = target or 0
    self.auto_match = auto_match

    self:Init()
    self:InitBg()
    self:InitListItem()
    self:InitListTab()
    self:InitBtns()

    self:RegisterAllEvents()
end

function MakeTeamPlatformView:CloseViewCallBack()
    if self.ui_item_list then
        self.ui_item_list:DeleteMe()
        self.ui_item_list = nil
    end

    if self.ui_tab_list then
        self.ui_tab_list:DeleteMe()
        self.ui_tab_list = nil
    end

    self:ClearTimer()
end

function MakeTeamPlatformView:RegisterAllEvents()
    local events = {
        {game.MakeTeamEvent.UpdateTargetList, handler(self, self.OnUpdateTargetList)},
        {game.MakeTeamEvent.OnTeamMatch, handler(self, self.OnTeamMatch)},
        {game.MakeTeamEvent.OnTeamGetNearby, handler(self, self.OnTeamGetNearby)},        
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MakeTeamPlatformView:Init()
    self.cur_target = 0
    self.team_item_data = {}

    self.main_role_lv = game.Scene.instance:GetMainRoleLevel()

    self.is_team_matching = false

    self.txt_no_team = self._layout_objs["txt_no_team"]
end

function MakeTeamPlatformView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1672]):HideBtnBack()
end

function MakeTeamPlatformView:InitListTab()
    self.list_tab = self._layout_objs["list_tab"]

    self.ui_tab_list = game.UIList.New(self.list_tab)
    self.ui_tab_list:SetVirtual(true)

    self.ui_tab_list:SetCreateItemFunc(function(obj)
        local item = require("game/make_team/make_team_platform_tab").New(self.ctrl)
        item:SetVirtual(obj)
        item:Open()        
        item:SetClickCallback(function(click_item)
            self:OnClickTabItem(click_item)
        end)

        return item
    end)

    self.ui_tab_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetTabItemData(idx)
        item:UpdateData(data)
    end)

    self.ui_tab_list:AddItemProviderCallback(function(idx)
        local data = self:GetTabItemData(idx) or {}

        local package = (data.cate and "ui_common:btn_pm" or "ui_common:btn_label")
        return package
    end)

    local team_item_data = self:CalcTabItemData(0)
    self.ui_tab_list:SetItemNum(#team_item_data)


    self.cur_target = self.ctrl:GetTeamTarget()
    local cfg = config.team_target[self.cur_target]
    if cfg then
        local cate = cfg.cate or 0
        local item_list = self.ui_tab_list:GetItemList()
        for _,v in pairs(item_list) do
            if v:IsMain() and v:GetCate() == cate then
                self:OnClickTabItem(v)
                break
            end
        end
    else
        local open_idx = 1
        for k,v in ipairs(team_item_data) do
            if v.id == self.open_target then
                open_idx = k
                break
            end
        end
        self.ui_tab_list:AddSelection(open_idx-1)

        local item = self.ui_tab_list:GetItemByIdx(open_idx-1)
        self:OnClickTabItem(item)
    end

    if self.auto_match then
        self.ctrl:SendTeamMatch(self.cur_target)
    end
end

function MakeTeamPlatformView:InitBtns()
    self.btn_refresh = self._layout_objs["btn_refresh"]
    self.btn_refresh:AddClickCallBack(function()
        self:SendGetTeamTargetList()
    end)

    self.btn_create = self._layout_objs["btn_create"]
    self.btn_create:AddClickCallBack(function()
        local team_target = (self.cur_target>=0 and self.cur_target or 0)
        self.ctrl:SendTeamCreate(team_target)
    end)

    self.btn_match = self._layout_objs["btn_match"]
    self.btn_match:AddClickCallBack(function()
        if self.cur_target <= 0 then
            game.GameMsgCtrl.instance:PushMsg(config.words[4988])
            return
        end

        local target = (self.is_team_matching and 0 or self.cur_target)
        self.ctrl:SendTeamMatch(target)
    end)
    self:UpdateTeamMatching()
end

function MakeTeamPlatformView:InitListItem()
    self.list_item = self._layout_objs["list_item"]

    self.ui_item_list = game.UIList.New(self.list_item)
    self.ui_item_list:SetVirtual(true)

    self.ui_item_list:SetCreateItemFunc(function(obj)
        local item = require("game/make_team/make_team_platform_item").New(self.ctrl)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_item_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetTeamItemData(idx)
        item:UpdateData(data)
    end)

end

function MakeTeamPlatformView:OnEmptyClick()
    self:Close()
end

function MakeTeamPlatformView:GetTeamItemData(idx)
    return self.team_item_data[idx]
end

function MakeTeamPlatformView:GetTabItemData(idx)
    return self.tab_item_data[idx]
end

local default = {
    id = 0,
    name = "全部队伍",
    level = 0,
    target = 0,
    target_num = 0,
}
local default2 = {
    id = -1,
    name = "附近队伍",
    level = 0,
    target = -1,
    target_num = 0,
}
function MakeTeamPlatformView:CalcTabItemData(cate)
    self.tab_item_data = {
        default,
        default2,
    }
    for _,v in ipairs(config.team_target_cate) do
        if self.main_role_lv >= v.level then            
            table.insert(self.tab_item_data, v)

            local cate_cfg = config.team_target_sort[v.id] or game.EmptyTable
            v.target = (cate_cfg[1] or game.EmptyTable).id or 0
            v.target_num = #cate_cfg

            if v.id == cate then
                if v.target_num > 1 then
                    local seq = 0
                    for ck,cv in ipairs(cate_cfg) do
                        if self.main_role_lv >= cv.level then
                            local cfg = TeamTargetConfig[cv.id]
                            if cfg.check_func(cv) then
                                seq = seq + 1
                                cv.seq = seq
                                table.insert(self.tab_item_data, cv)
                            end
                        end
                    end
                end
            end
        end
    end    

    return self.tab_item_data
end


function MakeTeamPlatformView:OnClickTabItem(item)
    local sub_item = nil
    if item:IsMain() then
        local cate = item:GetCate()
        self:CalcTabItemData(cate)

        local item_num = #self.tab_item_data
        self.ui_tab_list:SetItemNum(item_num)

        local item_list = self.ui_tab_list:GetItemList()
        for _,v in pairs(item_list) do
            if v:IsMain() then
                v:SetSelected(v:GetTarget()==item:GetTarget())
            else
                local is_select = (v:GetSeq() == 1)
                v:SetSelected(is_select)

                if is_select then
                    sub_item = v
                end
            end
        end
    else
        local item_list = self.ui_tab_list:GetItemList()
        for _,v in pairs(item_list) do
            if not v:IsMain() then
                v:SetSelected(v==item)
            end
        end
    end

    self.cur_target = (sub_item or item):GetTarget()

    self:SendGetTeamTargetList()
end

function MakeTeamPlatformView:OnUpdateTargetList(data)
    if self.cur_target ~= data.target then
        return
    end

    self.team_item_data = data.teams

    local item_num = #self.team_item_data --+ math.random(1,6)
    self.ui_item_list:SetItemNum(item_num)
    self.ui_item_list:RefreshVirtualList()

    local is_visible = item_num<=0
    self.txt_no_team:SetVisible(is_visible)

    if is_visible then
        self.txt_no_team:SetText(config.words[5007])
    end
end

function MakeTeamPlatformView:OnTeamMatch(target)
    self:UpdateTeamMatching()

    -- 设置匹配标记
    -- SetTeamMatchFlag()
end

function MakeTeamPlatformView:UpdateTeamMatching()
    self.is_team_matching = self.ctrl:IsTeamMatching()

    local word_id = (self.is_team_matching and 4987 or 4986)
    self.btn_match:SetText(config.words[word_id])
end

function MakeTeamPlatformView:SendGetTeamTargetList()
    self:ClearTimer()

    self.ui_item_list:SetItemNum(0)

    self.txt_no_team:SetVisible(true)
    self.txt_no_team:SetText(config.words[5008])

    self.timer_id = TimerMgr:CreateTimer(0.3, function()
        if self.cur_target >= 0 then
            self.ctrl:SendTeamTargetList(self.cur_target)
        else
            self.ctrl:SendTeamGetNearby()
        end
        return true
    end)    
end

function MakeTeamPlatformView:ClearTimer()
    if self.timer_id then
        TimerMgr:DelTimer(self.timer_id)
        self.timer_id = nil
    end
end

function MakeTeamPlatformView:OnTeamGetNearby(data)
    if self.cur_target > 0 then
        return
    end

    self.team_item_data = data.teams

    local item_num = #self.team_item_data
    self.ui_item_list:SetItemNum(item_num)
    self.ui_item_list:RefreshVirtualList()

    local is_visible = item_num<=0
    self.txt_no_team:SetVisible(is_visible)

    if is_visible then
        self.txt_no_team:SetText(config.words[5007])
    end
end

return MakeTeamPlatformView

