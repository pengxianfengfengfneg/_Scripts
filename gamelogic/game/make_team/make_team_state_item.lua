local MakeTeamStateItem = Class(game.UITemplate)

function MakeTeamStateItem:_init()
    self.ctrl = game.MakeTeamCtrl.instance
end

function MakeTeamStateItem:OpenViewCallBack()
	self:Init()
end

function MakeTeamStateItem:CloseViewCallBack()
    
end

function MakeTeamStateItem:Init()
	self.img_bg = self._layout_objs["img_bg"]
	self.txt_name = self._layout_objs["txt_name"]
	self.txt_dist = self._layout_objs["txt_dist"]
	self.txt_lv = self._layout_objs["txt_lv"]
	self.txt_times = self._layout_objs["txt_times"]
	self.txt_dead = self._layout_objs["txt_dead"]

end

function MakeTeamStateItem:UpdateData(data, idx)
	self.data = data

	self.img_bg:SetVisible((idx%2)==1)

	self.txt_name:SetText(data.name)

	local is_online = (data.online==1)
	if not is_online then
		local color = game.Color.Red
		local word_id = 5020

		self.txt_dist:SetText(config.words[word_id])
		self.txt_dist:SetColor(table.unpack(color))

		self.txt_lv:SetText(config.words[word_id])
		self.txt_lv:SetColor(table.unpack(color))

		self.txt_dead:SetText(config.words[word_id])
		self.txt_dead:SetColor(table.unpack(color))

		self.txt_times:SetText(config.words[word_id])
		self.txt_times:SetColor(table.unpack(color))

		return
	end

	local is_dist_match = (data.distance==1)
	local word_id = (is_dist_match and 5018 or 5019)
	local color = (is_dist_match and game.Color.DarkGreen or game.Color.Red)
	self.txt_dist:SetText(config.words[word_id])
	self.txt_dist:SetColor(table.unpack(color))

	local is_lv_match = (data.level==1)
	local word_id = (is_lv_match and 5018 or 5019)
	local color = (is_lv_match and game.Color.DarkGreen or game.Color.Red)
	self.txt_lv:SetText(config.words[word_id])
	self.txt_lv:SetColor(table.unpack(color))

	local is_dead_match = (data.alive==1)
	local word_id = (is_dead_match and 5018 or 5019)
	local color = (is_dead_match and game.Color.DarkGreen or game.Color.Red)
	self.txt_dead:SetText(config.words[word_id])
	self.txt_dead:SetColor(table.unpack(color))

	local word_id = 5017
	local color = game.Color.Red
	if data.times > 0 then
		local is_assist = (data.assist==1)
		word_id = (is_assist and 5017 or 5018)

		color = ((not is_assist) and game.Color.DarkGreen or game.Color.Red)
	else
		word_id = 5019
	end
	self.txt_times:SetText(config.words[word_id])
	self.txt_times:SetColor(table.unpack(color))
end

function MakeTeamStateItem:GetRoleId()
	return self.data.role_id
end

return MakeTeamStateItem
