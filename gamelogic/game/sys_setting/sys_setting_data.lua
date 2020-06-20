local SysSettingData = Class(game.BaseData)

local AudioMgr = global.AudioMgr

function SysSettingData:_init()
    self.sys_setting_value = 0
    self.sys_setting_default_value = 0

    self.sys_volume = 100

    self.quality_keys = {
		game.SysSettingKey.ImageQuality_Low,
		game.SysSettingKey.ImageQuality_Mid,
		game.SysSettingKey.ImageQuality_High,
	}

    self.auto_use_setting = {
        1050,
        1050,
        1050,
    }

    self:InitDefaultSetting()
end

function SysSettingData:InitDefaultSetting()
	for k,v in pairs(game.SysSettingKey) do
		local flag = game.DefaultSysSetting[v]
		local val = (flag and 0 or v)
		self.sys_setting_default_value = self.sys_setting_default_value + val
	end
end

function SysSettingData:InitSetting()
    self.sys_setting_value = self:GetSettingInt(game.CommonlyKey.SysSetting)

    if not self:IsUserSetting() then
    	self.sys_setting_value = self.sys_setting_default_value
	end
    
    local enable = self:IsMusicOn()
    AudioMgr:EnableMusic(enable)

    local enable = self:IsSoundOn()
    AudioMgr:EnableSound(enable)

    -------------------------------------
    
    self.sys_volume = self:GetSettingInt(game.CommonlyKey.SysSetVolume)

    if not self:IsUserSetting() then
    	self.sys_volume = 100
	end
    -------------------------------------

    local value = self:GetSettingInt(game.CommonlyKey.AutoUseItem)
    if value ~= 0 then
        for i = 1, 3 do
            local setting = value % (1 << 8)
            if setting > (1 << 7) then
                self.auto_use_setting[i] = 1000 + (setting - (1 << 7))
            else
                self.auto_use_setting[i] = setting
            end
        end
    end
    game.BagCtrl.instance:InitAutoUse()
end

function SysSettingData:IsUserSetting()
	return (not self:IsSettingActived(game.SysSettingKey.UserSettingFlag))
end

function SysSettingData:SetSettingValue(key, is_selected)
	if not self:IsUserSetting() then
		self.sys_setting_value = self.sys_setting_value + game.SysSettingKey.UserSettingFlag
	end

    if self:IsSettingActived(key) == is_selected then
        return self.sys_setting_value
    end

    local set_val = key*(is_selected and -1 or 1)
    self.sys_setting_value = self.sys_setting_value + set_val

    -- 保存客户端
    if not self.role_id then
        self.role_id = game.Scene.instance:GetMainRoleID()
    end
    global.UserDefault:SetInt(self.role_save_key, self.sys_setting_value)

    return self.sys_setting_value
end

function SysSettingData:IsSettingActived(key)
    return (not ((self.sys_setting_value&key)==key))
end

function SysSettingData:IsMusicOn()
	return self:IsSettingActived(game.SysSettingKey.MusicOn)
end

function SysSettingData:IsSoundOn()
	return self:IsSettingActived(game.SysSettingKey.SoundOn)
end

function SysSettingData:SetSysVolume(val)
    self.sys_volume = val
end

function SysSettingData:GetSysVolume()
    return self.sys_volume
end

function SysSettingData:GetSysSettingValue()
	return self.sys_setting_value
end

function SysSettingData:GetQualityIdx()
	for k,v in ipairs(self.quality_keys) do
		if self:IsSettingActived(v) then
			return k
		end
	end
	return 1
end

function SysSettingData:GetAutoUseSetting()
    return self.auto_use_setting
end

function SysSettingData:SetAutoUseSetting(setting)
    self.auto_use_setting = setting
end

function SysSettingData:OnUpdateEnterSceneInfo(data)
    if self.role_id then
        return
    end

    self.role_id = data.role_id
    self.role_save_key = string.format("SysSettingSaveKey_%s", self.role_id)

    local value = global.UserDefault:GetInt(self.role_save_key, 0)
    local info = {
        key = game.CommonlyKey.SysSetting,
        val = value
    }
    self:OnSettingSetInt(info)
end

function SysSettingData:OnSettingGetAll(data)
    self.setting_int_data = {}
    self.setting_string_data = {}

    for _,v in ipairs(data.ints) do
        self.setting_int_data[v.key] = v.val
    end

    for _,v in ipairs(data.strings) do
        self.setting_string_data[v.key] = v.val
    end

    self:InitSetting()
end

function SysSettingData:SendSettingSetInt(key, val)
    self.setting_int_data[key] = val
end

function SysSettingData:OnSettingSetInt(data)
    self.setting_int_data[data.key] = data.val
end

function SysSettingData:SendSettingSetString(key, val)
    self.setting_string_data[key] = val
end

function SysSettingData:OnSettingSetString(data)
    self.setting_string_data[data.key] = data.val
end

function SysSettingData:GetSettingInt(key)
    return self.setting_int_data[key] or 0
end

function SysSettingData:GetSettingString(key)
    return self.setting_string_data[key]
end

return SysSettingData
