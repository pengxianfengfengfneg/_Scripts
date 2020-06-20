local OpenFuncCtrl = Class(game.BaseCtrl)

local global_time = global.Time
local event_mgr = global.EventMgr
local config_func = config.func

function OpenFuncCtrl:_init()
    if OpenFuncCtrl.instance ~= nil then
        error("OpenFuncCtrl Init Twice!")
    end
    OpenFuncCtrl.instance = self

    require("game/open_func/open_func_config")

    self.data = require("game/open_func/open_func_data").New()
    self.view = require("game/open_func/open_func_view").New(self)

    self:Init()

    self:RegisterAllEvents() 
    self:RegisterAllProtocals()
end

function OpenFuncCtrl:_delete()
    self.data:DeleteMe()
    self.view:DeleteMe()
    
    self:CloseFolderView()

    if self._func_foreshow_view then
        self._func_foreshow_view:DeleteMe()
    end

    OpenFuncCtrl.instance = nil
end

function OpenFuncCtrl:Init()
end

function OpenFuncCtrl:RegisterAllEvents()
    local events = {
        [game.OpenFuncEvent.OpenFuncNew] = handler(self, self.ShowNewFunc),
        [game.SkillEvent.SkillNew] = handler(self, self.ShowNewSkill),
        [game.SysSettingEvent.OnGetSettingInfo] = handler(self, self.OnGetSettingInfo),
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

function OpenFuncCtrl:RegisterAllProtocals()
    self:RegisterProtocalCallback(25102, "OnFuncInfo")
    self:RegisterProtocalCallback(25103, "OnFuncNew")
end

function OpenFuncCtrl:IsFuncOpened(func_id)
    return self.data:IsFuncOpened(func_id)    
end

function OpenFuncCtrl:IsFuncVisible(func_id)
    local cfg = config_func[func_id] or {}
    local show_cfg = cfg.show_lv or {}
    
    if not show_cfg[1] or not show_cfg[2] then
        return false
    end

    local role_lv = game.Scene.instance:GetMainRoleLevel()
    return (role_lv>=show_cfg[1] and role_lv<=show_cfg[2])
end

function OpenFuncCtrl:GetOpenList(func_id)
    local open_list = {}
    local cfg = config_func[func_id]
    if cfg then
        for _,v in ipairs(cfg.sub_func) do
            if self:IsFuncOpened(v) then
                table.insert(open_list, v)
            end
        end
    end
    return open_list
end

function OpenFuncCtrl:OpenFolderView(open_list)    
    if not self._folder_func_view then
        self._folder_func_view = require("game/open_func/folder_func_view").New(self, open_list)
    end
    self._folder_func_view:Open()
end

function OpenFuncCtrl:CloseFolderView()
    if self._folder_func_view then
        self._folder_func_view:DeleteMe()
        self._folder_func_view = nil
    end
end

function OpenFuncCtrl:OpenFuncForeshowView()
    if not self._func_foreshow_view then
        self._func_foreshow_view = require("game/open_func/func_foreshow_view").New(self)
    end
    self._func_foreshow_view:Open()
end

function OpenFuncCtrl:OnFuncInfo(data)
    --[[
        "funcs__T__id@H",
        "guide__T__id@H##num@C",
    ]]
    self.data:OnFuncInfo(data)
    self.init_func = true
end

function OpenFuncCtrl:OnFuncNew(data)
     --[[
        "funcs__T__id@H",
    ]]
    self.data:OnFuncNew(data)

    game.ViewMgr:FireGuideEvent()
end

function OpenFuncCtrl:OpenFuncView(func_id, ...)
    local cfg = config_func[func_id]
    if cfg then
        if cfg.check_open_func() and cfg.check_visible_func() then
            cfg.open_func(...)
        end
    end
end

function OpenFuncCtrl:ShowNewFunc(data)
    if self.init_func then
        local func_list = {}
        for k, v in pairs(data) do
            table.insert(func_list, {func_id = k})
        end
        self.view:ShowNewFunc(func_list)
    end
end

function OpenFuncCtrl:ShowNewSkill(data)
    local skill_list = {}
    for k, v in pairs(data) do
        if self:CanShowSkill(v.id, v.lv) then
            table.insert(skill_list, {skill_id = v.id, skill_level = v.lv})
        end
    end
    self.view:ShowNewFunc(skill_list)
end

function OpenFuncCtrl:CanShowSkill(id, lv)
    local career = game.RoleCtrl.instance:GetCareer()
    local career_cfg = config.skill_career[career] or {}
    for k, v in pairs(career_cfg) do
        if v.skill_id == id then
            return v.show == 1
        end
    end
    return false
end

function OpenFuncCtrl:GetCurForeshowIndex()
    
    local index = 9999

    local role_lv = game.Scene.instance:GetMainRoleLevel()

    for k, v in ipairs(config.func_foreshow) do

        if role_lv < v.level then

            if k < index then
                index = k
            end
        end
    end

    return index
end

function OpenFuncCtrl:GetFuncEffectEndTime(func_id)
    return self.data:GetFuncEffectEndTime(func_id)
end

function OpenFuncCtrl:IsFuncPlayEffect(func_id)
    return self.data:IsFuncPlayEffect(func_id)
end

function OpenFuncCtrl:ResetFuncEffect(func_id)
    return self.data:ResetFuncEffect(func_id)
end

function OpenFuncCtrl:OnGetSettingInfo()
    return self.data:CheckLoginOpenFunc()
end

game.OpenFuncCtrl = OpenFuncCtrl

return OpenFuncCtrl
