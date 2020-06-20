
local HttpService = Class()

function HttpService:_init()
	self.http_request_id = 0
	self.http_request_map = {}
end

function HttpService:_delete()

end

function HttpService:SendGetRequest(url, callback)
	N3DClient.HttpRequest.CreateGetRequest(url, function(msg, data)
		callback(true, msg, data)
	end, function(err)
		callback(false, err)
	end)
end

function HttpService:SendOperURLRequest(url)
	UnityEngine.Application.OpenURL(url)
	--N3DClient.HttpRequest.OpenWebURL(url)
end

function HttpService:SendSaveFileRequest(url)
	N3DClient.HttpRequest.SaveFile(url)
end

function HttpService:SendPostRequest(url, form_map, callback)
	local form = UnityEngine.WWWForm()

	if form_map ~= "" then
		for k,v in pairs(form_map) do
			form:AddField(k, v)
		end
	end

	N3DClient.HttpRequest.CreatePostRequest(url, form, function(msg, data)
		callback(true, msg, data)
	end, function(err)
		callback(false, err)
	end)
end

global.HttpService = HttpService.New()