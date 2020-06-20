local BuffShowItem = Class(game.UITemplate)

local string_format = string.format
local config_effect = config.effect
local config_effect_desc = config.effect_desc

local _buff_show_cfg = {
	[22001] = function()
    	local pioneer_lv = game.MainUICtrl.instance:GetPioneerLv()
    	local world_lv = game.MainUICtrl.instance:GetWorldLv()
    	local role_lv = game.Scene.instance:GetMainRoleLevel()
    	local ratio = config_help.ConfigHelpLevel.GetPioneerLvRatio(role_lv, pioneer_lv)
		return {world_lv, pioneer_lv, math.floor(ratio * 100)}
	end,
	[22002] = function()
    	local pioneer_lv = game.MainUICtrl.instance:GetPioneerLv()
    	local world_lv = game.MainUICtrl.instance:GetWorldLv()
    	local role_lv = game.Scene.instance:GetMainRoleLevel()
    	local ratio = config_help.ConfigHelpLevel.GetWorldLvRatio(role_lv, world_lv)
		return {world_lv, pioneer_lv, math.floor(ratio * 100)}
	end
}

function BuffShowItem:_init()
    
end

function BuffShowItem:OpenViewCallBack()
	self:Init()
end

function BuffShowItem:CloseViewCallBack()
    self:StopCd()
end

function BuffShowItem:Init()	
	self.img_buff = self._layout_objs["img_buff"]

	self.txt_name = self._layout_objs["txt_name"]
	self.txt_time = self._layout_objs["txt_time"]
	self.rtx_desc = self._layout_objs["rtx_desc"]
end

function BuffShowItem:UpdateData(data)
	if self.buff_uid == data.uid and data.end_time and self.end_time==data.end_time then
		return
	end

	self.end_time = data.end_time

	self.buff_uid = data.uid
	self.buff_id = data.id
	self.buff_lv = data.lv
	self.buff_time = (self.end_time and (self.end_time*0.001 - global.Time:GetServerTimeMs()) or nil)

	local cfg = config_effect[self.buff_id][self.buff_lv]
	local desc_cfg = config_effect_desc[self.buff_id]
	if cfg and desc_cfg then
		self.img_buff:SetSprite("ui_main", desc_cfg.icon)
		self.txt_name:SetText(desc_cfg.name)

		local desc_param = cfg.desc_param
		if _buff_show_cfg[self.buff_id] then
			desc_param = _buff_show_cfg[self.buff_id]()
		end
		self.rtx_desc:SetText(string.format(desc_cfg.desc, table.unpack(desc_param or game.EmptyTable)))
	end
	
	self:StartCd()
end

function BuffShowItem:StartCd()
	self:StopCd()

	if not self.buff_time then
		self.txt_time:SetText(config.words[4502])
		return
	end

	local buff_time = math.floor(self.buff_time)

	local seq = DOTween.Sequence()
	seq:AppendCallback(function()
		if buff_time < 0 then
			return
		end

		local hour = math.floor(buff_time/3600)
		local min = math.floor((buff_time%3600)/60)
		local sec = buff_time%60

		local str_word = ""
		if hour > 0 then
			str_word = string_format(config.words[4500], hour, min, sec)
		else
			str_word = string_format(config.words[4501], min, sec)
		end
		self.txt_time:SetText(str_word)

		buff_time = buff_time - 1
	end)
	seq:AppendInterval(1)
	seq:OnComplete(function()
		self:StopCd()

	end)
	seq:SetLoops(math.ceil(self.buff_time))
	seq:SetAutoKill(false)

	self.buff_seq = seq
end

function BuffShowItem:StopCd()
	if self.buff_seq then
		self.buff_seq:Kill(false)
		self.buff_seq = nil
	end
end

function BuffShowItem:GetBuffId()
	return self.buff_id
end

return BuffShowItem
