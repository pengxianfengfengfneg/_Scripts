local ForgeTemplate = Class(game.UITemplate)

function ForgeTemplate:_init(view)   
    self.parent_view = view
end

function ForgeTemplate:OpenViewCallBack()

    self:InitList()
    
    --选择当前等级
    local main_role_lv = game.Scene.instance:GetMainRoleLevel()
    local min_role_lv = 50
    local max_role_lv = 90
    local pop_index
    if main_role_lv >= max_role_lv then
        self.level_index = max_role_lv
    elseif main_role_lv > min_role_lv then
        self.level_index = main_role_lv - (main_role_lv%10)
    else
        self.level_index = min_role_lv
    end
    pop_index = math.ceil((self.level_index - min_role_lv)/10)

    self._layout_objs["n56"]:AddChangeCallback(function()
        local t = self._layout_objs["n56"]:GetSelectIndex()
        self.level_index = (t+5)*10
        self:UpdateTopListData()
    end)
    self._layout_objs["n56"]:SetSelectIndex(pop_index)

	self.page_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
		self.tab_index = idx + 1
		self:UpdateTopListData()
    end)
    self.page_controller:SetSelectedIndexEx(0)
end

function ForgeTemplate:CloseViewCallBack()
	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end
end

function ForgeTemplate:InitList()

	self.list1 = self._layout_objs["list1"]
    self.ui_list = game.UIList.New(self.list1)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/skill/forge_item_template").New(self)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:SetItemNum(0)
end

function ForgeTemplate:UpdateTopListData()

	local foundry_data = game.FoundryCtrl.instance:GetData()
	self.top_item_list = foundry_data:GetForgeItems(self.tab_index, self.level_index)

	self.ui_list:SetItemNum(#self.top_item_list)
end

function ForgeTemplate:GetTopItemList()
	return self.top_item_list
end

function ForgeTemplate:CheckRedPoint()
    
    
end

return ForgeTemplate
