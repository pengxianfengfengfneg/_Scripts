local ExteriorBubbleTemplate = Class(game.UITemplate)

function ExteriorBubbleTemplate:_init()
    self.ctrl = game.ExteriorCtrl.instance
end

function ExteriorBubbleTemplate:OpenViewCallBack()
	self:UpdateData()
    self:Init()
    self:InitModel()

    self:RegisterAllEvents()
end

function ExteriorBubbleTemplate:CloseViewCallBack()
    if self.role_model then
        self.role_model:DeleteMe()
        self.role_model = nil
    end
end

function ExteriorBubbleTemplate:RegisterAllEvents()
    local events = {
        {game.ExteriorEvent.OnBubbleSettingChange, handler(self,self.OnBubbleSettingChange)},
        {game.RoleEvent.UpdateCurBubble, handler(self,self.OnUpdateCurBubble)},
    }
    for _, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function ExteriorBubbleTemplate:UpdateData()
	local setting_val = self.ctrl:GetBubbleSettingValue()
	self.bubble_setting_vale = setting_val

	local ExteriorSettingKey = self.ctrl:GetExteriorSettingKey()

	local is_forever = (setting_val & ExteriorSettingKey.Forever)>0
	local is_no_active = (setting_val & ExteriorSettingKey.NotActive)>0
	local is_expire = (setting_val & ExteriorSettingKey.Expire)>0

	local is_all = (is_forever and is_no_active and is_expire)

	local role_ctrl = game.RoleCtrl.instance
	self.sort_data = {}
	for _,v in pairs(config.chat_bubble) do
		local bubble_info = role_ctrl:GetBubbleInfo(v.id)
		if bubble_info then
			if bubble_info.expire_time > 0 then
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

function ExteriorBubbleTemplate:Init()
	self.list_item = self._layout_objs["list_item"]
	self.txt_desc = self._layout_objs["txt_desc"]
	self.txt_get_way = self._layout_objs["txt_get_way"]
	self.txt_name = self._layout_objs["txt_name"]
	self.txt_state = self._layout_objs["txt_state"]

	self.img_frame = self._layout_objs["img_frame"]
	self.txt_content = self._layout_objs["txt_content"]

	self.btn_sift = self._layout_objs["btn_sift"]
	self.btn_sift:AddClickCallBack(function()
		game.ExteriorCtrl.instance:OpenBubbleSettingView()
	end)
	
	self.btn_use = self._layout_objs["btn_use"]
	self.btn_use:AddClickCallBack(function()
		game.RoleCtrl.instance:SendExteriorBubbleChoose(self.cur_bubble_item:GetId())
	end)

	self:InitList()
end

function ExteriorBubbleTemplate:InitList()
	self.ui_list = self:CreateList("list_item", "game/exterior/item/bubble_item", true)

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

function ExteriorBubbleTemplate:UpdateList()
	local item_num = #self.sort_data
	self.ui_list:SetItemNum(item_num)

	if item_num > 0 then
		local obj = self.list_item:GetChildAt(0)
		self.list_item:AddSelection(0,true)

		local item = self.ui_list:GetItemByObj(obj)
		self:OnClickItem(item)
	end
end

function ExteriorBubbleTemplate:GetData(idx)
	return self.sort_data[idx]
end

local RoleCtrl = game.RoleCtrl.instance
local function GetSeq(data)
	if RoleCtrl:GetCurBubble() == data.id then
		return 0
	end

	if RoleCtrl:GetBubbleInfo(data.id) then
		return data.id + 10000
	end

	return data.id + 1000000
end

function ExteriorBubbleTemplate:DoSortData()
	table.sort(self.sort_data, function(v1,v2)
		return GetSeq(v1)<GetSeq(v2)
	end)
end

function ExteriorBubbleTemplate:OnClickItem(item)
	self.cur_bubble_item = item

	local data = item:GetData()

	self.txt_name:SetText(data.name)
	self.txt_desc:SetText(data.desc)
	self.txt_get_way:SetText(data.get_way)

	self:UpdateItemState(item)

	local bubble_id = item:GetId()
	local cfg = config.chat_bubble[bubble_id]
	if cfg then
		self.img_frame:SetSprite("ui_main", cfg.res)
	end
end

function ExteriorBubbleTemplate:UpdateItemState(item)
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

function ExteriorBubbleTemplate:OnBubbleSettingChange(val)
	if self.bubble_setting_vale == val then
		return
	end
	self.bubble_setting_vale = val

	self:UpdateData()
	self:DoSortData()
	self:UpdateList()
end

function ExteriorBubbleTemplate:InitModel()
    if self.role_model then
        return
    end

    local main_role = game.Scene.instance:GetMainRole()

    local model_list = {
        [game.ModelType.Body] = 110101,
        [game.ModelType.Hair] = 11001,
        [game.ModelType.Weapon] = 1001,
    }

    for k, v in pairs(model_list) do
        local id = main_role:GetModelID(k)
        model_list[k] = (id > 0 and id or v)
    end

    self.role_model = require("game/character/model_template").New()
    self.role_model:CreateModel(self._layout_objs["wrapper"], game.BodyType.Role, model_list)
    self.role_model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.Body + game.ModelType.Hair)
    self.role_model:SetPosition(0.14, -1.4, 3.2)
    self.role_model:SetRotation(0, 180, 0)

    self.role_model:SetModelChangeCallBack(function(model_type)
        if model_type == game.ModelType.Hair then
            local hair = main_role:GetHair()
            self.role_model:UpdateHairColorHex(hair)
        end
    end)
end

function ExteriorBubbleTemplate:OnUpdateCurBubble()	
	self.ui_list:Foreach(function(item)
		item:UpdateState()
	end)

	self:UpdateItemState(self.cur_bubble_item)
end

return ExteriorBubbleTemplate
