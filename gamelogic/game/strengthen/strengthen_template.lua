local StrengthenTemplate = Class(game.UITemplate)
local GetWayConfig = require("game/bag/goods_get_way_config")

local TitleState = {
    None = 0,
    Active = 1,
    Fire = 2,
}

local PageType = {
	Cate = 2,
	Func = 1,
    Star = 0,
    None = 3,
}

local PageLevel = {
    [PageType.Cate] = 1,
    [PageType.Func] = 2,
    [PageType.Star] = 2,
    [PageType.None] = 2,
}

function StrengthenTemplate:_init(view, type)
    self.parent = view
    self.ctrl = game.StrengthenCtrl.instance
    self.type = type
    self.package_name = "ui_strengthen"
end

function StrengthenTemplate:OpenViewCallBack()
    self:Init()
    self:InitTitles()
    self:InitFuncList()
    self:InitTagList()
end

function StrengthenTemplate:Init()
    self.list_cate = self._layout_objs.list_cate
    self.list_tag = self._layout_objs.list_tag

    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
    self.ctrl_tag_page = self:GetRoot():GetController("ctrl_tag_page")

    self.btn_tips = self._layout_objs.btn_tips
    self.btn_tips:AddClickCallBack(function()
        self.ctrl:OpenFightView(self.type)
    end)

    self.page_list = {}
end

function StrengthenTemplate:InitTitles()
    self.title_list_data = self.ctrl:GetTitleList(self.type)

    self.title_com = {}

    for i=1, #self.title_list_data do
        local cfg = self.title_list_data[i]
        local title_com = self._layout_objs["title"..i]

        title_com:GetChild("img_icon"):SetSprite(self.package_name, cfg.icon1)
        title_com:GetChild("img_icon2"):SetSprite(self.package_name, cfg.icon2)

        self.title_com[i] = title_com
    end

    self:UpdateTitles()
end

function StrengthenTemplate:UpdateTitles()
    local idx = nil
    local fight = game.Scene.instance:GetMainRolePower()
    
    for k, v in ipairs(self.title_com) do
        local state = TitleState.None
        if fight >= self.title_list_data[k].fight then
            state = TitleState.Active
        else
            if not idx then
                idx = k
            end
        end
        self:SetTitleState(k, state)
    end

    if idx then
        self:SetTitleState(idx, TitleState.Fire)
    end
end

function StrengthenTemplate:InitTagList()
    self.ctrl_tag = self:GetRoot():AddControllerCallback("ctrl_tag", function(idx)
        self:OnTagClick(idx+1)
    end)

    self.tag_list_data = self.ctrl:GetTagList(self.type)
    local item_num = #self.tag_list_data

    self.list_tag:SetItemNum(item_num)
    self.ctrl_tag:SetPageCount(item_num)
    self.ctrl_tag_page:SetPageCount(math.ceil(item_num/10))

    for i=1, item_num do
        local tag_com = self.list_tag:GetChildAt(i-1)
        local tag_data = self.tag_list_data[i]

        tag_com:GetChild("img_icon"):SetSprite(self.package_name, tag_data.icon1)
        tag_com:GetChild("img_icon2"):SetSprite(self.package_name, tag_data.icon2)
        tag_com:SetText(tag_data.name)
    end

    self.ctrl_tag:SetSelectedIndexEx(0)
end

function StrengthenTemplate:InitFuncList()
    self.list_func = self:CreateList("list_func", "game/strengthen/item/func_item")
    self.list_func:SetRefreshItemFunc(function(item, idx)
        local func_info = self.func_list_data[idx]
        item:SetFuncList(func_info.func_id, self.type, idx)
    end)

    self.list_func_star = self:CreateList("list_func2", "game/strengthen/item/func_item")
    self.list_func_star:SetRefreshItemFunc(function(item, idx)
        local func_info = self.func_list_data[idx]
        item:SetStarInfo(func_info.func_id, idx)
    end)
end

function StrengthenTemplate:SetTitleState(idx, state)
    self.title_com[idx]:GetController("ctrl_state"):SetSelectedIndexEx(state)
end

function StrengthenTemplate:OnTagClick(idx)
    local tag_info = self.tag_list_data[idx]
    local tag_id = tag_info.id

    self.cate_list_data = self.ctrl:GetCateList(tag_id)
    local cate_num = #self.cate_list_data

    if cate_num == 0 then
        self:SetPageIndex(PageType.None)
    elseif cate_num > 1 then
        self.list_cate:SetItemNum(cate_num)

        for i=1, #self.cate_list_data do
            local cate_info = self.cate_list_data[i]
            local cate_com = self.list_cate:GetChildAt(i-1)
            cate_com:SetText(cate_info.name)
            cate_com:AddClickCallBack(function()
                self:OnCateClick(i)
            end)
        end

        self:SetPageIndex(PageType.Cate)
    else
        self:OnCateClick(1)
    end
end

function StrengthenTemplate:OnCateClick(idx)
    local cate_id = self.cate_list_data[idx].cate_id
    local show_type = self.cate_list_data[idx].show_type

    self.func_list_data = self.ctrl:GetFuncList(cate_id)
    local page_index = PageType.None

    if show_type == 1 then
        self.list_func:SetItemNum(#self.func_list_data)
        page_index = PageType.Func
    elseif show_type == 2 then
        self.list_func_star:SetItemNum(#self.func_list_data)
        page_index = PageType.Star
    end
    self:SetPageIndex(page_index)
end

function StrengthenTemplate:AddClickGoEvent(com, acquire)
    local get_way = GetWayConfig[acquire]
    com:AddClickCallBack(function()
        if get_way and get_way.click_func then
            get_way.click_func()
        end
    end)
end

function StrengthenTemplate:SetPageIndex(index)
    for i=#self.page_list, 1, -1 do
        local last_idx = self.page_list[i]
        local level = PageLevel[last_idx]
        if level >= PageLevel[index] then
            self.page_list[i] = nil
        end
    end

    table.insert(self.page_list, index)
    self.ctrl_page:SetSelectedIndexEx(index)
end

function StrengthenTemplate:BackPage()
    local num = #self.page_list
    if num > 1 then
        local index = self.page_list[num-1]
        self.page_list[num] = nil
        self.ctrl_page:SetSelectedIndexEx(index)
        return true
    end
    return false
end

return StrengthenTemplate