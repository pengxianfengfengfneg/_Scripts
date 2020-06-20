local ChatRecord = Class()

local _ChatRecord = N3DClient.ChatRecord:GetInstance()

function ChatRecord:_init()

end

function ChatRecord:_delete()

end

function ChatRecord:GetString(key, default_val)
	return _ChatRecord:GetString(key, default_val or "")
end

function ChatRecord:SetString(key, val)
	_ChatRecord:SetString(key, val)
end

function ChatRecord:GetInt(key, default_val)
	return _ChatRecord:GetInt(key, default_val or 0)
end

function ChatRecord:SetInt(key, val)
	_ChatRecord:SetInt(key, val)
end

function ChatRecord:GetBool(key, default_val)
	return _ChatRecord:GetBool(key, default_val or false)
end

function ChatRecord:SetBool(key, val)
	_ChatRecord:SetBool(key, val)
end

global.ChatRecord = ChatRecord.New()
