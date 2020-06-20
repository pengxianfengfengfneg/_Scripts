local MakeTeamTargetView = Class(game.BaseView)

local handler = handler
local string_gsub = string.gsub
local string_format = string.format

local TeamTargetConfig = require("game/make_team/team_target_config")

function MakeTeamTargetView:_init(ctrl)
    self._package_name = "ui_make_team"
    self._com_name = "make_team_target_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
end

function MakeTeamTargetView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
end

function MakeTeamTargetView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function MakeTeamTargetView:RegisterAllEvents()
    local events = {
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MakeTeamTargetView:Init()    
    self.main_role_lv = game.Scene.instance:GetMainRoleLevel()

    self:InitBtns()
    self:InitLevelNums()
    self:InitItems()
end

function MakeTeamTargetView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1671]):HideBtnBack()
end

function MakeTeamTargetView:InitBtns()
    self.btn_ok = self._layout_objs["btn_ok"]
    --切换队伍目标副本
    self.btn_ok:AddClickCallBack(function()
        local item = self.list_num_l:GetItemByIdx(3)
        local lv_left = item:GetNum()

        local item = self.list_num_r:GetItemByIdx(3)
        local lv_right = item:GetNum()

        local min_lv = math.min(lv_left, lv_right)
        local max_lv = math.max(lv_left, lv_right)


        local now_target = self.ctrl:GetTeamTarget()
        local now_min,now_max = self.ctrl:GetTeamTargetLv()
        if now_target == self.cur_target then
            if (now_min~=min_lv) or (now_max~=max_lv) then
                self.ctrl:SendTeamSetLevel(min_lv, max_lv)
            end
        else
            self.ctrl:SendTeamSetTarget(self.cur_target, min_lv, max_lv)
        end

        self:Close()
    end)
end

function MakeTeamTargetView:InitItems()
    self.list_tab = self._layout_objs["list_tab"]

    self.ui_list = game.UIList.New(self.list_tab)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/make_team/make_team_target_item").New(self.ctrl)
        item:SetVirtual(obj)
        item:Open()        
        item:SetClickCallback(function(click_item)
            self:OnClickItem(click_item)
        end)

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetItemData(idx)
        item:UpdateData(data)
    end)

    self.ui_list:AddItemProviderCallback(function(idx)
        local data = self:GetItemData(idx) or {}

        local package = (data.cate and "ui_make_team:btn_sub_target" or "ui_make_team:btn_target")
        return package
    end)

    local item_data = self:CalcItemData(0)
    self.ui_list:SetItemNum(#item_data)


    self.cur_target = self.ctrl:GetTeamTarget()
    local cfg = config.team_target[self.cur_target] or game.EmptyTable
    local cate = cfg.cate or 0
    local item_list = self.ui_list:GetItemList()
    for _,v in pairs(item_list) do
        if v:IsMain() and v:GetCate() == cate then
            self:OnClickItem(v)
        end
    end

    local select_item = nil
    local item_list = self.ui_list:GetItemList()
    for _,v in pairs(item_list) do
        if v:IsSelected() then
            select_item = v
            break
        end
    end

    if select_item then
        local obj = select_item:GetRoot()
        local idx = self.list_tab:GetChildIndex(obj)
        self.list_tab:ScrollToView(idx)
    end
end

function MakeTeamTargetView:InitLevelNums()
    local role_lv = game.Scene.instance:GetMainRoleLevel()
    local max_lv = #config.level

    
    self.list_num_l = self:CreateList("list_num_l", "game/make_team/num_item", true)

    self.list_num_l:SetRefreshItemFunc(function(item, idx)
        local data = self:GetLeftData(idx)
        item:UpdateData(data)
    end)

    -------------------------------------
    self.list_num_r = self:CreateList("list_num_r", "game/make_team/num_item", true)

    self.list_num_r:SetRefreshItemFunc(function(item, idx)
        local data = self:GetLeftData(idx)
        item:UpdateData(data)
    end)

end

function MakeTeamTargetView:GetLeftData(idx)
    return self.left_num_data[idx]
end

function MakeTeamTargetView:GetRightData(idx)
    return self.right_num_data[idx]
end

function MakeTeamTargetView:GetItemData(idx)
    return self.item_data[idx]
end

local default = {
    id = 0,
    name = "无",
    level = 0,
    target = 0,
    target_num = 0,
    apply_lv = {{1,#config.level}},
}
function MakeTeamTargetView:CalcItemData(cate)
    self.item_data = {
        default,
    }
    for _,v in ipairs(config.team_target_cate) do
        if self.main_role_lv >= v.level then
            table.insert(self.item_data, v) 

            local cate_cfg = config.team_target_sort[v.id] or game.EmptyTable
            v.target = (cate_cfg[1] or game.EmptyTable).id or 0
            v.target_num = #cate_cfg

            if not v.apply_lv then
                v.apply_lv = cate_cfg[1].apply_lv
            end

            if v.id == cate then
                if v.target_num > 1 then
                    local seq = 0
                    for ck,cv in ipairs(cate_cfg) do
                        if self.main_role_lv >= cv.level then
                            local cfg = TeamTargetConfig[cv.id]
                            if cfg.check_func(cv) then
                                seq = seq + 1
                                cv.seq = seq
                                table.insert(self.item_data, cv)
                            end
                        end
                    end
                end
            end
        end
    end    

    return self.item_data
end

function MakeTeamTargetView:OnClickItem(item)
    local sub_item = nil
    if item:IsMain() then
        local cate = item:GetCate()
        self:CalcItemData(cate)

        local item_num = #self.item_data
        self.ui_list:SetItemNum(item_num)

        local item_list = self.ui_list:GetItemList()
        for _,v in pairs(item_list) do
            if v:IsMain() then
                v:SetSelected(v:GetTarget() == item:GetTarget())
            else
                local is_select = (v:GetSeq() == 1)
                v:SetSelected(is_select)

                if is_select then
                    sub_item = v
                end
            end
        end
    else
        local item_list = self.ui_list:GetItemList()
        for _,v in pairs(item_list) do
            if not v:IsMain() then
                v:SetSelected(v==item)
            end
        end
    end

    self.cur_target = (sub_item or item):GetTarget()

    self.cur_target_item = sub_item or item

    self:UpdateLevelNums()
end

function MakeTeamTargetView:UpdateLevelNums()
    if not self.cur_target_item then
        return
    end

    local min_lv,max_lv = self.cur_target_item:GetMinMaxLv()
    local recommend_min_lv,recommend_max_lv = self.cur_target_item:GetRecommendMinMaxLv()

    local lv_offset = 3

    local target_idx = 1
    self.left_num_data = {}
    for i=min_lv-lv_offset,max_lv+lv_offset do
        local lv = i
        if lv < min_lv then
            lv = 0
        elseif lv > max_lv then
            lv = 0
        end

        if i == recommend_min_lv then
            target_idx = i - (min_lv-lv_offset) + 1
        end
        table.insert(self.left_num_data, lv)
    end
    self.list_num_l:SetItemNum(#self.left_num_data)
    self.list_num_l:ScrollToView(math.max(target_idx-lv_offset-1,0))

    local target_idx = 1
    self.right_num_data = {}
    for i=min_lv-lv_offset,max_lv+lv_offset do
        local lv = i
        if lv < min_lv then
            lv = 0
        elseif lv > max_lv then
            lv = 0
        end

        if i == recommend_max_lv then
            target_idx = i - (min_lv-lv_offset) + 1
        end

        table.insert(self.right_num_data, lv)
    end

    local item_num = #self.right_num_data
    self.list_num_r:SetItemNum(item_num)

    self.list_num_r:ScrollToView(math.min(target_idx-lv_offset-1,max_lv))
end

return MakeTeamTargetView

