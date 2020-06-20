local ExteriorFrameTemplate = Class(game.UITemplate)

function ExteriorFrameTemplate:_init()
    self.ctrl = game.ExteriorCtrl.instance
end

function ExteriorFrameTemplate:OpenViewCallBack()
	self:UpdateData()
    self:Init()

    self:RegisterAllEvents()
end

function ExteriorFrameTemplate:CloseViewCallBack()
    
end

function ExteriorFrameTemplate:RegisterAllEvents()
    local events = {
        {game.ExteriorEvent.OnFrameSettingChange, handler(self,self.OnFrameSettingChange)},
        {game.RoleEvent.UpdateCurFrame, handler(self,self.OnUpdateCurFrame)},
    }
    for _, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function ExteriorFrameTemplate:UpdateData()
	local setting_val = self.ctrl:GetFrameSettingValue()
	self.frame_setting_val = setting_val

	local ExteriorSettingKey = self.ctrl:GetExteriorSettingKey()

	local is_forever = (setting_val & ExteriorSettingKey.Forever)>0
	local is_no_active = (setting_val & ExteriorSettingKey.NotActive)>0
	local is_expire = (setting_val & ExteriorSettingKey.Expire)>0

	local role_ctrl = game.RoleCtrl.instance
	self.sort_data = {}
	for _,v in pairs(config.icon_frame) do
		local frame_info = role_ctrl:GetFrameInfo(v.id)
		if frame_info then
			if frame_info.expire_time > 0 then
				if is_expire then
					table.insert(self.sort_data, v)
				end
			else
				if is_forever then
					table.insert(self.sort_data, v)
				end
			end
		else
			if is_no_active then
				table.insert(self.sort_data, v)
			end
		end
	end
end

function ExteriorFrameTemplate:Init()
	self.list_item = self._layout_objs["list_item"]
	self.txt_desc = self._layout_objs["txt_desc"]
	self.txt_get_way = self._layout_objs["txt_get_way"]
	self.txt_name = self._layout_objs["txt_name"]
	self.txt_state = self._layout_objs["txt_state"]

	self.btn_shop = self._layout_objs["btn_shop"]

	self.head_icon = self:GetIconTemplate("head_icon")

	self.btn_sift = self._layout_objs["btn_sift"]
	self.btn_sift:AddClickCallBack(function()
		game.ExteriorCtrl.instance:OpenFrameSettingView()
	end)
	
	self.btn_use = self._layout_objs["btn_use"]
	self.btn_use:AddClickCallBack(function()
		game.RoleCtrl.instance:SendExteriorFrameChoose(self.cur_frame_item:GetId())
	end)

	self.btn_shop:SetVisible(false)

	self:InitList()
end

function ExteriorFrameTemplate:InitList()
	self.ui_list = self:CreateList("list_item", "game/exterior/item/frame_item", true)

	self.ui_list:SetRefreshItemFunc(function(item, idx)
		local data = self:GetData(idx)
        item:UpdateData(data)
    end)

    self.ui_list:AddClickItemCallback(function(item)
		self:OnClickItem(item)
	end)

	self:DoSortData()
	self:UpdateList()
end

function ExteriorFrameTemplate:UpdateList()
	local item_num = #self.sort_data
	self.ui_list:SetItemNum(item_num)

	if item_num > 0 then
		local obj = self.list_item:GetChildAt(0)
		self.list_item:AddSelection(0,true)

		local item = self.ui_list:GetItemByObj(obj)
		self:OnClickItem(item)
	end
end

function ExteriorFrameTemplate:GetData(idx)
	return self.sort_data[idx]
end

local RoleCtrl = game.RoleCtrl.instance
local function GetSeq(data)
	if RoleCtrl:GetCurFrame() == data.id then
		return 0
	end

	if RoleCtrl:GetFrameInfo(data.id) then
		return data.id + 10000
	end

	return data.id + 1000000
end

function ExteriorFrameTemplate:DoSortData(fliter_func)
	table.sort(self.sort_data, function(v1,v2)
		return GetSeq(v1)<GetSeq(v2)
	end)
end

function ExteriorFrameTemplate:OnClickItem(item)
	self.cur_frame_item = item

	local data = item:GetData()

	self.txt_name:SetText(data.name)
	self.txt_desc:SetText(data.desc)
	self.txt_get_way:SetText(data.get_way)

	self:UpdateItemState(item)

	local icon_data = item:GetIconData()
	icon_data.lock = false
	self.head_icon:UpdateData(icon_data)
end

function ExteriorFrameTemplate:UpdateItemState(item)
	local is_on_use = item:IsOnUse()
	local is_actived = item:IsActived()

	local is_show_state = false
	local show_state_word = ""
	if is_on_use then
		is_show_state = true
		show_state_word = config.words[5523]
	else
		is_show_state = not is_actived
		if is_show_state then
			show_state_word = config.words[5522]
		end
	end

	self.txt_state:SetVisible(is_show_state)
	self.btn_use:SetVisible(not is_show_state)

	self.txt_state:SetText(show_state_word)
end

function ExteriorFrameTemplate:OnFrameSettingChange(val)
	if self.frame_setting_val == val then
		return
	end

	self.frame_setting_val = val

	self:UpdateData()
	self:DoSortData()
	self:UpdateList()
end

function ExteriorFrameTemplate:OnUpdateCurFrame()	
	self.ui_list:Foreach(function(item)
		item:UpdateState()
	end)

	self:UpdateItemState(self.cur_frame_item)
end

return ExteriorFrameTemplate