local SettingSysTemplate = Class(game.UITemplate)

local math_floor = math.floor
local AudioMgr = global.AudioMgr 
local platform_ctrl = game.PlatformCtrl.instance

function SettingSysTemplate:_init()
   	self.ctrl = game.SysSettingCtrl.instance

end

function SettingSysTemplate:OpenViewCallBack()
	self:Init()
	
end

function SettingSysTemplate:CloseViewCallBack()
	self:DoSave()
   
end

function SettingSysTemplate:Init()
	self.list_item = self._layout_objs["list_item"]

	self.sys_volume_start = self.ctrl:GetSysVolume()
	self.setting_value_start = self.ctrl:GetSysSettingValue()

	self:InitCom1()
	self:InitCom2()
	self:InitCom3()
	self:InitCom4()
	self:InitCom5()
	self:InitCom6()
end

function SettingSysTemplate:InitCom1()
	self.quality_keys = {
		game.SysSettingKey.ImageQuality_Low,
		game.SysSettingKey.ImageQuality_Mid,
		game.SysSettingKey.ImageQuality_High,
	}

	self.com_1 = self.list_item:GetChildAt(0)

	self.quality_ctrl = self.com_1:AddControllerCallback("c1", function(idx)
		self:OnClickBtnQuality(idx)
	end)

	local quality_idx = self.ctrl:GetQualityIdx()
	self.quality_ctrl:SetSelectedIndexEx(quality_idx-1)

	self.txt_desc = self.com_1:GetChild("txt_desc")
	self:UpdateRecommandQuality()
end

function SettingSysTemplate:OnClickBtnQuality(idx)
	for k,v in ipairs(self.quality_keys) do
		self:SetCommonValue(v, k==idx+1)
	end
end

function SettingSysTemplate:UpdateRecommandQuality()
	
	
end

function SettingSysTemplate:InitCom2()
	self.com_2 = self.list_item:GetChildAt(1)

	self.btn_music = self.com_2:GetChild("btn_music")
	self.btn_music:AddChangeCallback(function(event_type)
		local is_selected = (event_type==game.ButtonChangeType.Selected)
		AudioMgr:EnableMusic(is_selected)

		self:SetCommonValue(game.SysSettingKey.MusicOn, is_selected)
	end)

	local enable = self.ctrl:IsSettingActived(game.SysSettingKey.MusicOn)
	self.btn_music:SetSelected(enable)

	self.btn_sound = self.com_2:GetChild("btn_sound")
	self.btn_sound:AddChangeCallback(function(event_type)
		local is_selected = (event_type==game.ButtonChangeType.Selected)
		AudioMgr:EnableSound(is_selected)

		self:SetCommonValue(game.SysSettingKey.SoundOn, is_selected)
	end)

	local enable = self.ctrl:IsSettingActived(game.SysSettingKey.SoundOn)
	self.btn_sound:SetSelected(enable)

	self.slider_volume = self.com_2:GetChild("slider_volume")
	self.slider_volume:AddChangeCallback(function(value)
		self:UpdateVolume(value)
	end)

	self.slider_volume:AddGripEndCallback(function(value)
		self:UpdateVolume(value)

	end)

	local volume = self.ctrl:GetSysVolume()
	self.slider_volume:SetValue(volume)
end

function SettingSysTemplate:UpdateVolume(value)
	value = math_floor(value)

	AudioMgr:SetSoundVolume(value*0.01)
	AudioMgr:SetMusicVolume(value*0.01)

	self.ctrl:SetSysVolume(value)
end

local Com3Config = {
	name = config.words[4950],
	{
		desc = config.words[4951],
		key = game.SysSettingKey.LowPowerMode,
		click = function(is_selected)
			
		end,
	},
	
}
function SettingSysTemplate:InitCom3()
	self.com_3 = self.list_item:GetChildAt(2)

	self:InitToggleCom(self.com_3, Com3Config)
end

function SettingSysTemplate:InitToggleCom(com, cfg)
	com:SetText(cfg.name)

	local item_num = #cfg
	local list_item = com:GetChild("list_item")
	list_item:SetItemNum(item_num)

	local com_height = 50 + 35 * item_num
	com:SetSize(684, com_height)

	for k,v in ipairs(cfg) do
		local child = list_item:GetChildAt(k-1)
		child:SetText(v.desc)
		local btn_checkbox = child:GetChild("btn_checkbox")
		btn_checkbox:SetSelected(self.ctrl:IsSettingActived(v.key))
		btn_checkbox:AddChangeCallback(function(event_type)
			local is_selected = (event_type==game.ButtonChangeType.Selected)
			self:OnClickToggle(v, is_selected)
		end)
	end
end

function SettingSysTemplate:OnClickToggle(data, is_selected)
	if data.click then
		data.click(is_selected)

		self:SetCommonValue(data.key, is_selected)
	end
end


local Com4Config = {
	name = config.words[4952],
	{
		desc = config.words[4953],
		key = game.SysSettingKey.MaskMonster,
		click = function(is_selected)

		end,
	},
	{
		desc = config.words[4954],
		key = game.SysSettingKey.MaskFriend,
		click = function(is_selected)

		end,
	},
	{
		desc = config.words[4955],
		key = game.SysSettingKey.MaskPlayer,
		click = function(is_selected)

		end,
	},
	{
		desc = config.words[4956],
		key = game.SysSettingKey.MaskPet,
		click = function(is_selected)

		end,
	},
	{
		desc = config.words[4957],
		key = game.SysSettingKey.MaskShake,
		click = function(is_selected)

		end,
	},
	{
		desc = config.words[4958],
		key = game.SysSettingKey.MaskPlayerTitle,
		click = function(is_selected)

		end,
	},
	{
		desc = config.words[4959],
		key = game.SysSettingKey.MaskPlayerEffect,
		click = function(is_selected)

		end,
	},
}
function SettingSysTemplate:InitCom4()
	self.com_4 = self.list_item:GetChildAt(3)

	self:InitToggleCom(self.com_4, Com4Config)
end

function SettingSysTemplate:InitCom5()
	self.btn_account = self._layout_objs["com_5/btn_account"]
	self.btn_account:AddClickCallBack(function()
		game.SDKMgr:Logout()
	end)

	local role_id = game.Scene.instance:GetMainRoleID()
	self.txt_role_id = self._layout_objs["com_5/txt_role_id"]
	self.txt_role_id:SetText(role_id)
end

local Com6Config = {
	name = config.words[4962],
	{
		desc = config.words[4963],
		key = game.SysSettingKey.AutoUseKeepExp,
		click = function(is_selected)

		end,
	},
}
function SettingSysTemplate:InitCom6()
	self.com_6 = self.list_item:GetChildAt(4)

	self:InitToggleCom(self.com_6, Com6Config)
end

function SettingSysTemplate:SetCommonValue(idx, is_selected)
	local setting_value = self.ctrl:SetSettingValue(idx, is_selected)
end

function SettingSysTemplate:SendCommonValue()
	local setting_value = self.ctrl:GetSysSettingValue()
	if game.MainUICtrl.instance then
		game.MainUICtrl.instance:SendSetCommonlyKeyValue(game.CommonlyKey.SysSetting, setting_value)
	end
end

function SettingSysTemplate:SendSetVolumeValue()
	local sys_volume = self.ctrl:GetSysVolume()
	if game.MainUICtrl.instance then
		game.MainUICtrl.instance:SendSetCommonlyKeyValue(game.CommonlyKey.SysSetVolume, sys_volume)
	end
end

function SettingSysTemplate:DoSetting()
	if game.Scene.instance then
		game.Scene.instance:RefreshShow()
	end
end

function SettingSysTemplate:DoSave()
	local setting_value_end = self.ctrl:GetSysSettingValue()
	if self.setting_value_start ~= setting_value_end then
		self:SendCommonValue()
	    self:DoSetting()
	end

	local sys_volume_end = self.ctrl:GetSysVolume()
	if self.sys_volume_start ~= sys_volume_end then
		self:SendSetVolumeValue()
	end
end

return SettingSysTemplate
