
local UIList = Class()

local et = {}
function UIList:_init(list_obj)
    self._list_obj = list_obj

    self._virtual = false
    self._item_list = {}
end

function UIList:_delete()
	self:ClearList()

	self._list_obj:SetItemNum(0)
end

function UIList:ClearList()
	for k,v in pairs(self._item_list or et) do
		if v.DeleteMe then
			v:DeleteMe()
		end
	end
	self._item_list = {}
end

function UIList:SetVirtual(val)
	self._virtual = val or false
	if self._virtual then
		self._list_obj:SetVirtual()
	end
	self._list_obj:AddRenderCallback(function(idx, obj)
		local item = self._item_list[obj]
		if not item then
			item = self.create_func(obj, idx)
			self._item_list[obj] = item
		end
		self.refresh_func(self._item_list[obj], idx + 1)
	end)
end

function UIList:SetTaskVirtual()
	self._list_obj:AddRenderCallback(function(idx, obj)
		local item = self._item_list[obj]
		if not item then
			item = self.create_func(obj, idx)
			self._item_list[obj] = item
		end
		self.refresh_func(self._item_list[obj], idx + 1)
	end)
end

function UIList:SetCreateItemFunc(func)
	self.create_func = func
end

function UIList:SetRefreshItemFunc(func)
    self.refresh_func = func
end

function UIList:AddItemProviderCallback(callback)
	self._list_obj:AddItemProviderCallback(function(idx)
		return callback(idx + 1)
	end)
end

function UIList:AddClickItemCallback(callback)
	self._list_obj:AddClickItemCallback(function(obj, idx)
		callback(self._item_list[obj], idx)
	end)
end

function UIList:AddControllerCallback(cName, callback)
	return self._list_obj:AddControllerCallback(cName, function(idx, obj)
		callback(idx+1, self._item_list[obj])
	end)
end

function UIList:SetItemNum(num)
	self:ClearList()
	self._list_obj:SetItemNum(num)
end

function UIList:GetItemNum()
	return self._list_obj:GetItemNum()
end

function UIList:Foreach(callback)
	for k,v in pairs(self._item_list) do
		callback(v)
	end
end

function UIList:AddItem(template)
	self._list_obj:AddChild(template:GetRoot())
	table.insert(self._item_list, template)
end

function UIList:GetItem(idx)
	return self._item_list[idx]
end

function UIList:GetItemByObj(obj)
	return self._item_list[obj]
end

function UIList:GetItemByIdx(idx)
	local obj = self._list_obj:GetChildAt(idx)
	return self:GetItemByObj(obj)
end

function UIList:GetItemList()
	return self._item_list
end

function UIList:AddScrollEndCallback(callback)
	self._list_obj:AddScrollEndCallback(callback)
end

function UIList:AddPullDownReleaseCallback(callback)
	self._list_obj:AddPullDownReleaseCallback(callback)
end

function UIList:AddPullUpReleaseCallback(callback)
	self._list_obj:AddPullUpReleaseCallback(callback)
end

function UIList:RefreshVirtualList()
	self._list_obj:RefreshVirtualList()
end

function UIList:ScrollToView(idx, ani, setFirst)
	self._list_obj:ScrollToView(idx, ani or false, setFirst or false)
end

function UIList:ResizeToFit(item_count, min_size)
	self._list_obj:ResizeToFit(item_count, min_size or 0)
end

function UIList:AddSelection(idx, val)
	self._list_obj:AddSelection(idx, val or false)
end

function UIList:ClearSelection()
	self._list_obj:ClearSelection()
end

function UIList:GetChildAt(idx)
	return self._list_obj:GetChildAt(idx)
end

function UIList:SetScrollEnable(val)
	self._list_obj:SetScrollEnable(val)
end

game.UIList = UIList

return UIList
