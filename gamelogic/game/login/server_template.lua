local ServerTemplate = Class(game.UITemplate)

function ServerTemplate:_init(data)
    self.data = data
end

function ServerTemplate:OpenViewCallBack()
end

function ServerTemplate:Refresh(data)
    self.server_id = data.server_id
    self._layout_objs["name"]:SetText(data.title)
    self._layout_objs["stat"]:SetSprite("ui_login", "cj_" .. data.state)

    local sel_server = self.data:GetLastServerInfo()
    if sel_server and sel_server.server_id == data.server_id then
	    self._layout_objs["sel_bg"]:SetVisible(true)
	else
	    self._layout_objs["sel_bg"]:SetVisible(false)
	end
end

function ServerTemplate:GetServerID()
	return self.server_id
end

return ServerTemplate
