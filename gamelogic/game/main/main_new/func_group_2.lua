local FuncGroupTwo = Class(game.UITemplate)

local config_func = config.func

function FuncGroupTwo:_init()
    
end

function FuncGroupTwo:OpenViewCallBack()
	self:Init()
	
    self:RegisterUpdateEvents()
end

function FuncGroupTwo:CloseViewCallBack()
    
end

function FuncGroupTwo:Init()
    self.func_group = 2

    self.ctrl = game.OpenFuncCtrl.instance

	self.root_obj = self:GetRoot()

    self.is_act_visible = nil
    self.btn_act_funcs = self._layout_objs["btn_act_funcs"]
    self.btn_act_funcs:AddClickCallBack(function()
        
        self:SetShowFuncs(not self.is_act_visible)
    end)

    self.list_acts = self._layout_objs["list_acts"]
    self.ui_func_list = self:CreateList("list_acts", "game/main/main_new/btn_func", false)

    self.func_to_btn_list = {}
    self.ui_func_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetFuncData(idx)
        item:SetRedPointCallback(handler(self,self.OnRedPointCallback))
        item:UpdateData(data)

        self.func_to_btn_list[data.id] = item
    end)

    self.ui_func_list:AddItemProviderCallback(function(idx)
        local data = self:GetFuncData(idx) or {}

        local package = "ui_main:btn_func"
        if data.is_empty then
            package = "ui_main:btn_empty"
        end
        return package
    end)

    self:UpdateFuncList()

    self:SetShowFuncs(false)
end

function FuncGroupTwo:RegisterUpdateEvents()
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

function FuncGroupTwo:UpdateFuncList()
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

function FuncGroupTwo:DoSortFunc()
	table.sort(self.func_data, function(v1,v2)
        return (v1.group+v1.idx)<(v2.group+v2.idx)
    end)

	self.func_to_btn_list = {}
    local item_num = #self.func_data
    self.ui_func_list:SetItemNum(item_num)

    self:UpdateFuncGroupRedPoint()
end

function FuncGroupTwo:GetFuncData(idx)
    return self.func_data[idx]
end

function FuncGroupTwo:GetFuncBtn(func_id)
    if self.func_to_btn_list then
        return self.func_to_btn_list[func_id]
    end
end

function FuncGroupTwo:OnUpdateRedPoint(func_id, is_red)
    local btn_func = self.func_to_btn_list[func_id]
    if btn_func then
        btn_func:SetRedPoint(is_red)

        self:UpdateFuncGroupRedPoint()
    end
end

function FuncGroupTwo:RefreshAllFuncs()
	self:UpdateFuncList()
end

function FuncGroupTwo:AddFunc(func_id)
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

function FuncGroupTwo:DelFunc(func_id)
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

function FuncGroupTwo:SetFuncVisible(func_id, val)
	if val then
		self:AddFunc(func_id)
	else
		self:DelFunc(func_id)
	end
end

function FuncGroupTwo:SetShowFuncs(val)
    if self.is_act_visible == val then
        return
    end

    self.is_act_visible = val
    self.btn_act_funcs:SetSelected(val)
    self.list_acts:SetVisible(val)
end

function FuncGroupTwo:SwitchToFighting()
    self:SetShowFuncs(false)
end

function FuncGroupTwo:UpdateFuncGroupRedPoint()
    local is_red = false
    for k,v in pairs(self.func_to_btn_list or {}) do
        if v:IsRedPoint() then
            is_red = true
            break
        end
    end

    game_help.SetRedPoint(self.btn_act_funcs, is_red, -5, 5)
end

function FuncGroupTwo:IsRedPoint()
    return false
end

function FuncGroupTwo:OnRedPointCallback(btn_func)
    self:UpdateFuncGroupRedPoint()
end

return FuncGroupTwo
