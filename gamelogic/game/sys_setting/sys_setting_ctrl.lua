local SysSettingCtrl = Class(game.BaseCtrl)

local AudioMgr = global.AudioMgr

local MinSettingKey = 4001
local MaxSettingKey = 5000

function SysSettingCtrl:_init()
    if SysSettingCtrl.instance ~= nil then
        error("SysSettingCtrl Init Twice!")
    end
    SysSettingCtrl.instance = self

    self.view = require("game/sys_setting/sys_setting_view").New(self)
    self.data = require("game/sys_setting/sys_setting_data").New(self)

    self:RegisterAllEvents()
    self:RegisterAllProtocal()

    self.local_data = {}
end

function SysSettingCtrl:_delete()
    self.view:DeleteMe()
    self.data:DeleteMe()

    SysSettingCtrl.instance = nil
end

function SysSettingCtrl:RegisterAllEvents()
    local events = {
        {game.SceneEvent.UpdateEnterSceneInfo, handler(self, self.OnUpdateEnterSceneInfo)},

        {game.ViewEvent.MainViewReady, function()
            local sys_volume = self:GetSysVolume()
            AudioMgr:SetMusicVolume(sys_volume*0.01)
            AudioMgr:SetSoundVolume(sys_volume*0.01)
        end}
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SysSettingCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(11002, "OnSettingGetAll")
    self:RegisterProtocalCallback(11010, "OnSettingSetInt")
    self:RegisterProtocalCallback(11012, "OnSettingSetString")
end

function SysSettingCtrl:OpenView(open_index)
    self.view:Open(open_index)
end

function SysSettingCtrl:CloseView()
    self.view:Close()
end

function SysSettingCtrl:OnUpdateEnterSceneInfo(data)
    self.data:OnUpdateEnterSceneInfo(data)
end

function SysSettingCtrl:SetSettingValue(key, is_selected)
    return self.data:SetSettingValue(key, is_selected)
end

function SysSettingCtrl:IsSettingActived(key)
    return self.data:IsSettingActived(key)
end

function SysSettingCtrl:SetSysVolume(val)
    self.data:SetSysVolume(val)
end

function SysSettingCtrl:GetSysVolume()
    return self.data:GetSysVolume()
end

function SysSettingCtrl:GetSysSettingValue()
    return self.data:GetSysSettingValue()
end

function SysSettingCtrl:GetQualityIdx()
    return self.data:GetQualityIdx()
end

function SysSettingCtrl:GetAutoUseSetting()
    return self.data:GetAutoUseSetting()
end

function SysSettingCtrl:SetAutoUseSetting(setting)
    self.data:SetAutoUseSetting(setting)
end

-- 本地存储
function SysSettingCtrl:SaveLocal(key, val)
    if not self.main_role_id then
        self.main_role_id = game.Scene.instance:GetMainRoleID()
    end

    if self.main_role_id then
        key = self.main_role_id .. "_" .. key
        self.local_data[key] = val
        global.UserDefault:SetInt(key, val)
    end
end

function SysSettingCtrl:GetLocal(key)
    if not self.main_role_id then
        self.main_role_id = game.Scene.instance:GetMainRoleID()
    end

    if self.main_role_id then
        key = self.main_role_id .. "_" .. key
        if self.local_data[key] then
            return self.local_data[key]
        else
            local val = global.UserDefault:GetInt(key, -1)
            self.local_data[key] = val
            return val
        end
    end

    return 0
end


function SysSettingCtrl:OnSettingGetAll(data)
    --[[
        "ints__T__key@H##val@L",
        "strings__T__key@H##val@s",
    ]]
    -- PrintTable(data)

    self.data:OnSettingGetAll(data)

    self:FireEvent(game.SysSettingEvent.OnGetSettingInfo)
end

function SysSettingCtrl:IsVaildKey(key)
    return (key>=MinSettingKey and key<=MaxSettingKey)
end

function SysSettingCtrl:SendSettingSetInt(key, val)
    if not self:IsVaildKey(key) then
        game.GameMsgCtrl.instance:PushMsg(config.words[146])
        return
    end

    local proto = {
        key = key,
        val = tonumber(val),   
    }
    self:SendProtocal(11009, proto)

    self.data:SendSettingSetInt(key, val)
end

function SysSettingCtrl:OnSettingSetInt(data)
    --[[
        "key__H",
        "val__L",
    ]]
    -- PrintTable(data)

    self.data:OnSettingSetInt(data)

    self:FireEvent(game.SysSettingEvent.OnSetSettingInt, data.key, data.val)
end

function SysSettingCtrl:SendSettingSetString(key, val)
    if not self:IsVaildKey(key) then
        game.GameMsgCtrl.instance:PushMsg(config.words[146])
        return
    end

    local proto = {
        key = key,
        val = tostring(val),   
    }
    self:SendProtocal(11011, proto)

    self.data:SendSettingSetString(key, val)
end

function SysSettingCtrl:OnSettingSetString(data)
    --[[
        "key__H",
        "val__s",
    ]]
    -- PrintTable(data)

    self.data:OnSettingSetString(data)

    self:FireEvent(game.SysSettingEvent.OnSetSettingString, data.key, data.val)
end

function SysSettingCtrl:GetSettingInt(key)
    return self.data:GetSettingInt(key)
end

function SysSettingCtrl:GetSettingString(key)
    return self.data:GetSettingString(key)
end

function SysSettingCtrl:SetInt(key, val)
    self:SendSettingSetInt(key, val)
end

function SysSettingCtrl:GetInt(key)
    return self.data:GetSettingInt(key)
end

function SysSettingCtrl:SetString(key, val)
    self:SendSettingSetString(key, val)
end

function SysSettingCtrl:GetString(key)
    return self.data:GetSettingString(key)
end

game.SysSettingCtrl = SysSettingCtrl

return SysSettingCtrl