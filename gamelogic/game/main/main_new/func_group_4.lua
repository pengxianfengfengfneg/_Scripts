local FuncGroupFour = Class(game.UITemplate)

local config_func = config.func

function FuncGroupFour:_init()
    
end

function FuncGroupFour:OpenViewCallBack()
	self:Init()
	
	self:RegisterUpdateEvents()
end

function FuncGroupFour:CloseViewCallBack()
    
end

function FuncGroupFour:Init()
    self.func_group = 4

    self.ctrl = game.OpenFuncCtrl.instance

	self.root_obj = self:GetRoot()

    self.list_funcs = {
        self:GetTemplate("game/main/main_new/btn_func", "btn_func_1"),
    }

    self:UpdateFuncList() 
end

function FuncGroupFour:RegisterUpdateEvents()
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

function FuncGroupFour:UpdateFuncList()
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

function FuncGroupFour:DoSortFunc()
	table.sort(self.func_data, function(v1,v2)
        return (v1.group+v1.idx)<(v2.group+v2.idx)
    end)

	self.func_to_btn_list = {}
    for k,v in ipairs(self.list_funcs) do
        local data = self.func_data[k]
        v:UpdateData(data)
        v:SetVisible(data~=nil)

        self.func_to_btn_list[v:GetFuncId()] = v
    end
end

function FuncGroupFour:GetFuncData(idx)
    return self.func_data[idx]
end

function FuncGroupFour:GetFuncBtn(func_id)
    if self.func_to_btn_list then
        return self.func_to_btn_list[func_id]
    end
end

function FuncGroupFour:OnUpdateRedPoint(func_id, is_red)
    local btn_func = self.func_to_btn_list[func_id]
    if btn_func then
        btn_func:SetRedPoint(is_red)
    end
end

function FuncGroupFour:RefreshAllFuncs()
	self:UpdateFuncList()
end

function FuncGroupFour:AddFunc(func_id)
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

function FuncGroupFour:DelFunc(func_id)
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

function FuncGroupFour:SetFuncVisible(func_id, val)
	if val then
		self:AddFunc(func_id)
	else
		self:DelFunc(func_id)
	end
end

function FuncGroupFour:SwitchToFighting()
    
end

function FuncGroupFour:IsRedPoint()
    return false
end

return FuncGroupFour
