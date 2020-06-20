local FuncItem = Class(game.UITemplate)
local GetWayConfig = require("game/bag/goods_get_way_config")

local ArrowIndex = {
    Show = 1,
    Hide = 0,
}

function FuncItem:OpenViewCallBack()
    self.txt_desc = self._layout_objs.txt_desc
    self.txt_name = self._layout_objs.txt_name
    self.txt_grade = self._layout_objs.txt_grade

    self.bar_progress = self._layout_objs.bar_progress
    self.list_star = self._layout_objs.list_star

    self.btn_go = self._layout_objs.btn_go
    self.btn_arrow = self._layout_objs.btn_arrow

    self.img_bg = self._layout_objs.img_bg
    self.img_bg2 = self._layout_objs.img_bg2
    self.img_icon = self._layout_objs.img_icon

    self.ctrl_arrow = self:GetRoot():GetController("ctrl_arrow")

    self.package_name = "ui_strengthen"
    self.ctrl = game.StrengthenCtrl.instance
end

function FuncItem:SetItemInfo(info, idx)
    self.info = info
    local package, sprite = self:ParseSprite(info.icon)
    self.img_icon:SetSprite(package, sprite)

    local content = string.len(info.desc) > 0 and info.desc or info.name
    self.txt_desc:SetText(content)

    self.img_bg:SetVisible(idx%2==1)
    self.img_bg2:SetVisible(idx%2==0)
end

function FuncItem:ParseSprite(icon)
    local params = string.split(icon, ":")
    if #params > 1 then
        if params[1] == "ui_skill_icon" then
            params[2] = string.gsub(params[2], "#%d+#", function(str)
                local skill_idx = tonumber(string.sub(str, string.find(str,"%d+")))
                local career = game.RoleCtrl.instance:GetCareer()
                local skill_id = config.skill_career[career][skill_idx].skill_id
                return config.skill[skill_id][1].icon
            end)
        end
        return table.unpack(params)
    else
        return self.package_name, params[1]
    end
end

function FuncItem:AddGoEvent(acquire)
    self.btn_go:AddClickCallBack(function()
        local get_way = GetWayConfig[acquire]
        if get_way and get_way.click_func then
            get_way.click_func()
        end
    end)
end

function FuncItem:SetFuncList(func_id, type, idx)
    self.func_list_data = self.ctrl:GetFuncChildList(func_id)

    local item_num = #self.func_list_data
    if item_num == 0 then
        return
    end

    if not self.list_func then
        self.list_func = self:CreateList("list_func", "game/strengthen/item/func_item")
        self.list_func:SetRefreshItemFunc(function(item, func_idx)
            local info = self.func_list_data[func_idx+1]
            local show_idx = (idx % 2 == 1) and func_idx + 1 or func_idx
            item:SetItemInfo(info, show_idx)
            item:UpdateFight(type)
        end)
    end

    self:SetItemInfo(self.func_list_data[1], idx)

    self.list_func:SetItemNum(math.max(0, item_num-1))

    self.btn_arrow:SetVisible(item_num>1)
    self.btn_arrow:AddClickCallBack(function()
        local arrow_index = (self.arrow_index + 1) % table.nums(ArrowIndex)
        self:SetArrowIndex(arrow_index)
    end)
    self:SetArrowIndex(ArrowIndex.Hide)

    self:AddGoEvent(self.func_list_data[1].acquire)
    self:UpdateFight(type)
end

function FuncItem:SetArrowIndex(index)
    self.arrow_index = index
    if index == ArrowIndex.Hide then
        self:HideFuncList()
    else
        self:ShowFuncList()
    end
    self.ctrl_arrow:SetSelectedIndexEx(index)
end

function FuncItem:ShowFuncList()
    if self.list_func then
        local item_num = #self.func_list_data-1
        self.list_func:SetItemNum(item_num)
        self.list_func:ResizeToFit(item_num)
        self.ctrl_arrow:SetSelectedIndexEx(ArrowIndex.Show)
    end
end

function FuncItem:HideFuncList()
    if self.list_func then
        self.list_func:SetItemNum(0)
        self.list_func:ResizeToFit(0)
        self.ctrl_arrow:SetSelectedIndexEx(ArrowIndex.Hide)
    end
end

function FuncItem:SetStarInfo(func_id, idx)
    local func_list = config.strengthen_func[func_id] or game.EmptyTable
    local func_data = nil

    for k, v in pairs(func_list) do
        func_data = v
        break
    end

    if func_data then
        self.list_star:SetItemNum(func_data.star)
        self.txt_name:SetText(func_data.name)
        self:AddGoEvent(func_data.acquire)
        self:SetItemInfo(func_data, idx)
    end
end

function FuncItem:UpdateFight(type)
    local func_type = self.info.func_type
    local params = self.info.params
    local func_fight = self.ctrl:GetFuncFight(func_type)
    
    local title_idx = 1

    for k, v in ipairs(params) do
        if func_fight < v or k == #params then
            title_idx = k
            break
        end
    end

    local cate_id = self.info.cate_id
    local max_value = params[#params]
    self.txt_grade:SetText(self.ctrl:GetGrade(type, title_idx))

    self.bar_progress:SetProgressValue(func_fight/max_value*100)
    self.bar_progress:GetChild("title"):SetText("")
end

return FuncItem