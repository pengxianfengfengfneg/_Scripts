local FuncGroupOne = Class(game.UITemplate)

local et = {}
local config_func = config.func

function FuncGroupOne:_init()
    
end

function FuncGroupOne:OpenViewCallBack()
	self:Init()
	
    self:RegisterUpdateEvents()
end

function FuncGroupOne:CloseViewCallBack()
    
end

function FuncGroupOne:Init()
	self.func_group = 1
	self.num_per_page = 8
	self.cur_list_func_idx = 0

    self.ctrl = game.OpenFuncCtrl.instance

	self.root_obj = self:GetRoot()

	self.func_controller = self.root_obj:AddControllerCallback("c1", function(idx)
		self.cur_list_func_idx = idx
        self:UpdateArrowVisible()
        self:UpdateFuncGroupRedPoint()
        self:UpdateFuncVisible()

        game.GuideCtrl.instance:CheckTabHideGuide(idx+1)
	end)

    self.list_tab = self._layout_objs["list_tab"]

    local img_bg = self._layout_objs["img_bg"]
    --img_bg:SetVisible(false)

    self.btn_right = self._layout_objs["btn_right"]
    self.btn_right:AddClickCallBack(function()
        local idx = self.cur_list_func_idx + 1
        if idx < self.func_page_num then
            self.cur_list_func_idx = idx
            self.func_controller:SetSelectedIndexEx(idx)
        end
    end)

    self.btn_left = self._layout_objs["btn_left"]
    self.btn_left:AddClickCallBack(function()
        local idx = self.cur_list_func_idx - 1
        if idx >= 0 then
            self.cur_list_func_idx = idx
            self.func_controller:SetSelectedIndexEx(idx)
        end
    end)
    

    self.ui_func_list = self:CreateList("list_page", "game/main/main_new/btn_func", false)

    self.func_to_btn_list = {}
    self.ui_func_list:SetRefreshItemFunc(function(item, idx)
    	local page_num = math.ceil(idx/self.num_per_page)

        local data = self:GetFuncData(idx)
        item:SetRedPointCallback(handler(self,self.OnRedPointCallback))
        item:UpdateData(data)
        item:SetPageNum(page_num)

        self.func_to_btn_list[data.id] = item
    end)

    self:UpdateFuncList()
    
    self.func_controller:SetSelectedIndexEx(self.cur_list_func_idx)
end

function FuncGroupOne:RegisterUpdateEvents()
    for k,v in pairs(config_func or {}) do
        if v.group == self.func_group then
            for _,cv in ipairs(v.update_event or et) do
                self:BindEvent(cv, function()
                        self:UpdateFuncList()
                    end)
            end
        end
    end
end

function FuncGroupOne:UpdateFuncList()
    self.func_data = {}
    for k,v in pairs(config_func or {}) do
        if v.group==self.func_group and v.icon and v.icon~="" then
            if self.ctrl:IsFuncOpened(v.id) and v.check_visible_func() then
                table.insert(self.func_data, v)
            end
        end
    end

    self:DoSortFunc()
end

function FuncGroupOne:DoSortFunc()
	table.sort(self.func_data, function(v1,v2)
        return (v1.group+v1.idx)<(v2.group+v2.idx)
    end)

	self.func_to_btn_list = {}
    local item_num = #self.func_data
    self.ui_func_list:SetItemNum(item_num)
    
    self.func_page_num = math.ceil(item_num/self.num_per_page)
    self.list_tab:SetItemNum(self.func_page_num)

    self:UpdateArrowVisible()
    self:UpdateFuncGroupRedPoint()
    self:UpdateFuncVisible()
end

function FuncGroupOne:GetFuncData(idx)
    return self.func_data[idx]
end

function FuncGroupOne:GetFuncBtn(func_id)
    if self.func_to_btn_list then
        return self.func_to_btn_list[func_id]
    end
end

function FuncGroupOne:OnUpdateRedPoint(func_id, is_red)
    local btn_func = self.func_to_btn_list[func_id]
    if btn_func then
        btn_func:SetRedPoint(is_red)

        self:UpdateFuncGroupRedPoint()
    end
end

function FuncGroupOne:RefreshAllFuncs()
	self:UpdateFuncList()
end

function FuncGroupOne:AddFunc(func_id)
	local data = config_func[func_id]
	if not data then
		return
	end

	if data.group ~= self.func_group then
		return
	end

	local icon = data.icon or ""
	if icon == "" then
		return
	end

	if not data.check_visible_func() then 
		return
	end

	table.insert(self.func_data, data)

	self:DoSortFunc()
end

function FuncGroupOne:DelFunc(func_id)
	local data = config_func[func_id]
	if not data then
		return
	end

	if data.group ~= self.func_group then
		return
	end

	local is_update = false
	for k,v in ipairs(self.func_data or {}) do
		if v.id == func_id then
			is_update = true
			table.remove(self.func_data, k)
			break
		end
	end

	if is_update then
		self:DoSortFunc()
	end
end

function FuncGroupOne:SetFuncVisible(func_id, val)
	if val then
		self:AddFunc(func_id)
	else
		self:DelFunc(func_id)
	end
end

function FuncGroupOne:SwitchToFighting()
	
end

function FuncGroupOne:UpdateFuncGroupRedPoint()
	local cur_page_num = self.cur_list_func_idx + 1

    local is_left_red = false
    local is_right_red = false
    local is_self_red = false

    for k,v in pairs(self.func_to_btn_list or {}) do
    	local page_num = v:GetPageNum()
    	if not is_left_red and page_num < cur_page_num then
    		if v:IsRedPoint() then
	            is_left_red = true
	        end
    	end

    	if not is_right_red and page_num > cur_page_num then
    		if v:IsRedPoint() then
	            is_right_red = true
	        end
    	end

        if not is_self_red and page_num == cur_page_num then
            is_self_red = v:IsRedPoint()
        end
    end

    game_help.SetRedPoint(self.btn_left, is_left_red, -0, 0)
    game_help.SetRedPoint(self.btn_right, is_right_red, -0, 0)

    self.is_left_red = is_left_red
    self.is_right_red = is_right_red
    self.is_self_red = is_self_red
end

function FuncGroupOne:IsRedPoint()
    return (self.is_self_red or self.is_left_red or self.is_right_red)
end

function FuncGroupOne:UpdateArrowVisible()
    local idx = self.cur_list_func_idx
    self.btn_left:SetVisible(idx>0)     
    self.btn_right:SetVisible(idx<(self.func_page_num-1))
end

function FuncGroupOne:OnRedPointCallback(btn_func)
    self:UpdateFuncGroupRedPoint()
end

function FuncGroupOne:UpdateFuncVisible()
    self.ui_func_list:Foreach(function(item)
        local page = item:GetPageNum()
        item:SetVisible(page==self.cur_list_func_idx+1)
    end)
end

function FuncGroupOne:ShowFuncBtn(func_id)
    local func_btn = self:GetFuncBtn(func_id)
    if func_btn then
        local page = func_btn:GetPageNum()
        self.func_controller:SetSelectedIndexEx(page-1)
    end
end

function FuncGroupOne:SwitchPage(page_idx)
    if page_idx > self.func_page_num then
        page_idx = self.func_page_num
    end
    self.func_controller:SetSelectedIndexEx(page_idx-1)
end

return FuncGroupOne
