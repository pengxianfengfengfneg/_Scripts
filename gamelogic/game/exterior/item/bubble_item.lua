local BubbleItem = Class(game.UITemplate)

function BubbleItem:OpenViewCallBack()
	self:Init()    
end

function BubbleItem:CloseViewCallBack()
	if self.goods_item then
		self.goods_item:DeleteMe()
		self.goods_item = nil
	end
end

function BubbleItem:Init()
	self.ctrl = game.RoleCtrl.instance

	self.goods_item = game_help.GetGoodsItem(self._layout_objs["goods_item"])

	self.txt_name = self._layout_objs["txt_name"]
	self.txt_expire = self._layout_objs["txt_expire"]
	self.img_ycd = self._layout_objs["img_ycd"]

	self.icon_id = game.Scene.instance:GetMainRoleIcon()
end

function BubbleItem:UpdateData(data)
	self.item_data = data

	self.txt_name:SetText(data.name)

	local str_time = config.words[5522]
	local bubble_info = self.ctrl:GetBubbleInfo(data.id)
	if bubble_info then
		if bubble_info.expire_time > 0 then
			local left_time = (bubble_info.expire_time - global.Time:GetServerTime())
			if left_time > 24*60*60 then
				str_time = game.Utils.SecToTimeCn(left_time, game.TimeFormatCn.DayHour)
			else
				str_time = game.Utils.SecToTime(left_time, game.TimeFormatEn.HourMinSec)
			end
		else
			str_time = config.words[5521]
		end
	end
	self.txt_expire:SetText(str_time)

	self.goods_item:SetItemInfo({
			id = data.item_id,
		})

	self:UpdateState()
end

function BubbleItem:UpdateState()
	local id = self:GetId()

	local cur_bubble_id = self.ctrl:GetCurBubble()
	self.is_on_use = (cur_bubble_id==id)
	self.img_ycd:SetVisible(self.is_on_use)

	local bubble_info = self.ctrl:GetBubbleInfo(id)
	self.is_actived = (bubble_info~=nil)

	self.goods_item:SetGray(not self.is_actived)
end

function BubbleItem:GetData()
	return self.item_data
end

function BubbleItem:GetId()
	return self.item_data.id
end

function BubbleItem:IsOnUse()
	return self.is_on_use
end

function BubbleItem:IsActived()
	return self.is_actived
end

return BubbleItem
