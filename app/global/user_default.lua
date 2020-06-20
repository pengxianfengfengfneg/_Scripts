
local UserDefault = Class()

local _UserRecord = N3DClient.UserRecord:GetInstance()

function UserDefault:_init()

end

function UserDefault:_delete()

end

function UserDefault:GetString(key, default_val)
	return _UserRecord:GetString(key, default_val or "")
end

function UserDefault:SetString(key, val)
	_UserRecord:SetString(key, val)
end

function UserDefault:GetInt(key, default_val)
	return _UserRecord:GetInt(key, default_val or 0)
end

function UserDefault:SetInt(key, val)
	_UserRecord:SetInt(key, val)
end

function UserDefault:GetBool(key, default_val)
	return _UserRecord:GetBool(key, default_val or false)
end

function UserDefault:SetBool(key, val)
	_UserRecord:SetBool(key, val)
end

global.UserDefault = UserDefault.New()
