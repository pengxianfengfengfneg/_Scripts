
local SelectServerView = Class(game.BaseView)

function SelectServerView:_init(ctrl)
	self._package_name = "ui_login"
    self._com_name = "select_server_view"
	self._cache_time = 60
    self._mask_type = game.UIMaskType.Full

	self.ctrl = ctrl
	self.data = ctrl:GetData()
end

function SelectServerView:_delete()
	
end

function SelectServerView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1680])
    self:InitPersonServerList()
    self:InitZoneList()

    self.ui_server_list = game.UIList.New(self._layout_objs["server_list"])
    self.ui_server_list:SetCreateItemFunc(function(obj)
        local item = require("game/login/server_template").New(self.data)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)
    self.ui_server_list:SetRefreshItemFunc(function(item, idx)
        item:Refresh(self.zone_list[self.zone_index].server_list[idx])
    end)
    self.ui_server_list:AddClickItemCallback(function(item)
        local id = item:GetServerID()
        self.data:SetLastServerID(id)
        self:Close()
    end)
    self.ui_server_list:SetVirtual(true)


    self.ui_zone_list = game.UIList.New(self._layout_objs["zone_list"])
    self.ui_zone_list:SetCreateItemFunc(function(obj)
        local item = require("game/login/zone_template").New()
        item:SetVirtual(obj)
        item:Open()
        return item
    end)
    self.ui_zone_list:SetRefreshItemFunc(function(item, idx)
        item:Refresh(idx, self.zone_list[idx])
    end)
    self.ui_zone_list:SetVirtual(true)
    self.ui_zone_list:SetItemNum(#self.zone_list)

    local zone_idx = 1
    if #self.person_server_list > 0 then
        zone_idx = 1
    else    
        local last_server = self.data:GetLastServerInfo()
        if last_server then
            local has_found = false
            for i,v in ipairs(self.zone_list) do
                for k1,v1 in pairs(v.server_list) do
                    if v1.server_id == last_server.server_id then
                        zone_idx = i
                        has_found = true
                        break
                    end
                end
                if has_found then
                    break
                end
            end
        end
    end

    self.page_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
        self:SelectZone(idx+1)
    end)
    self.page_controller:SetPageCount(#self.zone_list)
    self.page_controller:SetSelectedIndexEx(zone_idx-1)
end

function SelectServerView:CloseViewCallBack()
    self.zone_index = nil
    self.ui_server_list:DeleteMe()
    self.ui_server_list = nil
    self.ui_zone_list:DeleteMe()
    self.ui_zone_list = nil
end

function SelectServerView:SelectZone(idx)
    if self.zone_index == idx then
        return
    end
    
    self.zone_index = idx
    self.ui_server_list:SetItemNum(#self.zone_list[idx].server_list)
    self.ui_server_list:RefreshVirtualList()
end

function SelectServerView:InitZoneList()
    self.zone_list = {}
    table.insert(self.zone_list, {name = config.words[1051], server_list = self.person_server_list})

    local is_white_list = self.data:IsWhiteList()
    local server_time = self.data:GetServerTime()
    local zone_list = self.data:GetZoneList()
    local server_info
    for i=#zone_list,1,-1 do
        local server_list = {}
        for k,v in ipairs(zone_list[i].list) do
            server_info = self.data:GetServerInfo(v)
            if is_white_list or (not server_info.is_test and server_time > server_info.open_time) then
                table.insert(server_list, server_info)
            end 
        end

        local zone = {id = i, name = zone_list[i].name, server_list = server_list}
        table.insert(self.zone_list, zone)
    end
end

function SelectServerView:InitPersonServerList()
    self.person_server_list = {}
    local person_list = self.data:GetPersonList()
    for i,v in ipairs(person_list) do
        local is_exist = false
        for k,v1 in pairs(self.person_server_list) do
            if v.server_id == v1.server_id then
                is_exist = true
                break
            end
        end

        if not is_exist then
            local server_info = self.data:GetServerInfo(v.server_id)
            if server_info then
                table.insert(self.person_server_list, server_info)
            end
        end
    end
end

return SelectServerView
