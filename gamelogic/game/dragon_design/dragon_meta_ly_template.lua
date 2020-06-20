--龙元
local DragonMetaLYTemplate = Class(game.UITemplate)

function DragonMetaLYTemplate:_init(parent)
	self.parent = parent
	self.ctrl = game.DragonDesignCtrl.instance
	self.dragon_design_data = self.ctrl:GetData()
end

function DragonMetaLYTemplate:_delete()
end

function DragonMetaLYTemplate:OpenViewCallBack()

	self.goods_item_list = {}
	for i = 1, 4 do
		local item = self:GetTemplate("game/bag/item/goods_item", "item"..i)
        item:SetShowTipsEnable(true)
        item:ResetItem()
        self.goods_item_list[i] = item
	end

	for i = 1, 4 do
		self._layout_objs["fu_item"..i]:SetTouchDisabled(false)
		self._layout_objs["fu_item"..i]:AddClickCallBack(function()
			self:OnClickMid(i)
		end)
	end

	self:InitBotItem()

	self:InitMainItem()

	self:InitSubMetaAttr()

	self:BindEvent(game.DragonDesignEvent.UpdateEquip, function(data)
		if self.select_bot_index then
			self:OnClickBot(self.select_bot_index)
		end

		self:InitMainItem()

		self:InitSubMetaAttr()
    end)

    self:BindEvent(game.DragonDesignEvent.UpdateEat, function(data)
		if self.select_bot_index then
			self:OnClickBot(self.select_bot_index)
		end

		self:InitMainItem()

		self:InitSubMetaAttr()
    end)
end

function DragonMetaLYTemplate:CloseViewCallBack()
	for k, v in pairs(self.goods_item_list) do
		v:DeleteMe()
	end

	self.goods_item_list = nil
end

function DragonMetaLYTemplate:InitBotItem()

	local all_data = self.dragon_design_data:GetAllData()
	local growth_lv = all_data.growth_lv			--等级

	for i = 1, 4 do

		local start_index = (i-1)*4+1
		local unlock_lv = config.dragon_pos[start_index].unlock

		--已解锁
		if growth_lv >= unlock_lv then
			self._layout_objs["unlock_lv"..i]:SetText("")
			self._layout_objs["bot"..i]:SetAlpha(1)
			self._layout_objs["bot"..i]:SetTouchDisabled(false)
			self._layout_objs["bot"..i]:AddClickCallBack(function()
				self:OnClickBot(i)
			end)

			--首次默认选择
			if not self.select_bot_index then
				self:OnClickBot(i)
			end
		--未解锁
		else
			self._layout_objs["unlock_lv"..i]:SetText(string.format(config.words[6126], unlock_lv))
			self._layout_objs["bot"..i]:SetAlpha(0.4)
			self._layout_objs["bot"..i]:SetTouchDisabled(true)
		end
	end
end

function DragonMetaLYTemplate:OnClickBot(index)

	self.select_bot_index = index

	for i = 1, 4 do
		self._layout_objs["sel"..i]:SetVisible(i== index)
	end

	self:ShowInlayItem(index)
end

function DragonMetaLYTemplate:ShowInlayItem(index)

	for i = 1, 4 do

		local pos = (index-1)*4 + i
		local inlay_info = self.dragon_design_data:GetInlayInfoByPos(pos)
		if inlay_info and inlay_info.id > 0 then
			local color = config.goods[inlay_info.id].color
			self._layout_objs["fu_item"..i]:SetSprite("ui_item", config.goods[inlay_info.id].icon, true)
			self._layout_objs["item_lv"..i]:SetText(string.format(config.words[6266], inlay_info.level))
			if i == 1 then
				self._layout_objs["inlay_bg"..i]:SetSprite("ui_common", "item"..color, true)
			else
				self._layout_objs["inlay_bg"..i]:SetSprite("ui_common", "ndk_0"..color, true)
			end
		else
			self._layout_objs["fu_item"..i]:SetSprite("ui_common", "jh", true)
			self._layout_objs["item_lv"..i]:SetText("")
			if i == 1 then
				self._layout_objs["inlay_bg"..i]:SetSprite("ui_common", "item1", true)
			else
				self._layout_objs["inlay_bg"..i]:SetSprite("ui_common", "ndk_01", true)
			end
		end
	end
end

--主龙元
function DragonMetaLYTemplate:InitMainItem()

	local all_data = self.dragon_design_data:GetAllData()
	local growth_lv = all_data.growth_lv			--等级

	for i = 1, 4 do

		local pos = (i-1)*4 + 1
		local inlay_info = self.dragon_design_data:GetInlayInfoByPos(pos)
		self._layout_objs["mid_unlock_lv"..i]:SetText("")
		if inlay_info and inlay_info.id > 0 then
			self.goods_item_list[i]:SetItemInfo({id = inlay_info.id})
			self.goods_item_list[i]:SetItemLevel(string.format(config.words[6266], inlay_info.level))
			self.goods_item_list[i]:AddClickEvent(function()
				self.ctrl:OpenDragonOperView(inlay_info, true)
			end)
		else
			--是否解锁
			local unlock_lv = config.dragon_pos[pos].unlock
			if growth_lv >= unlock_lv then
				self.goods_item_list[i]:ResetItem()
			else
				self._layout_objs["mid_unlock_lv"..i]:SetText(string.format(config.words[6126], unlock_lv))
			end
			self.goods_item_list[i]:AddClickEvent(function()
			end)
		end
	end
end

--辅龙元属性
function DragonMetaLYTemplate:InitSubMetaAttr()
	
	local attr_list = self.dragon_design_data:GetSubMetaAttr()

	for i = 1, 9 do
		self._layout_objs["attr"..i]:SetText("")
	end

	local count = 0
	for k, v in pairs(attr_list) do
		count = count + 1

		local attr_name = config_help.ConfigHelpAttr.GetAttrName(k)
		self._layout_objs["attr"..count]:SetText(attr_name..":  "..v)
	end
end

function DragonMetaLYTemplate:OnClickMid(index)

	if self.select_bot_index then

		local pos = (self.select_bot_index-1)*4 + index
		local inlay_info = self.dragon_design_data:GetInlayInfoByPos(pos)
		local equip_type_t = (index==1) and 0 or 1

		--已镶嵌
		if inlay_info and inlay_info.id > 0 then
			self.ctrl:OpenDragonOperView(inlay_info)
		--未镶嵌	
		else
			local main_role = game.Scene.instance:GetMainRole()
	        if main_role then     
	            if main_role:IsFightState() then
	                game.GameMsgCtrl.instance:PushMsg(config.words[535])
	                return
	            end
	        end
			self.ctrl:OpenDragonEquipView({equip_type = equip_type_t, equip_pos = pos})
		end
	end
end

return DragonMetaLYTemplate