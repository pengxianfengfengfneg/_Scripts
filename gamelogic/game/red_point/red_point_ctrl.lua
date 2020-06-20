local RedPointCtrl = Class(game.BaseCtrl)

local global_time = global.Time
local event_mgr = global.EventMgr
local config_func = config.func

local _et = {}

function RedPointCtrl:_init()
    if RedPointCtrl.instance ~= nil then
        error("RedPointCtrl Init Twice!")
    end
    RedPointCtrl.instance = self

    self:Init()

    self:RegisterAllEvents() 

    global.Runner:AddUpdateObj(self, 2)
end

function RedPointCtrl:_delete()
    global.Runner:RemoveUpdateObj(self)

    RedPointCtrl.instance = nil
end

function RedPointCtrl:Init()
    self.red_point_list = {}
    self.red_point_update_list = {}

    self.red_point_register_list = {}
end

--ºìµã¿ØÖÆ
function RedPointCtrl:RegisterAllEvents()
    self:BindEvent(game.ViewEvent.MainViewReady, handler(self,self.OnMainViewReady))

    for k,v in pairs(config_func or {}) do
        for _,cv in ipairs(v.red_events or {}) do
            self:BindEvent(cv,function(...)
                self:OnEvent(v.id, v.red_delta, ...)
            end)
        end

        local update_cfg = {
            update_time = 0,
            is_update = false,
            is_init = true,
        }
        self.red_point_update_list[k] = update_cfg
    end
end

function RedPointCtrl:RegisterRedPoint(node, func_id, set_red_func, ox, oy)
    local cfg = self.red_point_register_list[node]
    if not cfg then
        cfg = {}
        self.red_point_register_list[node] = cfg
    end

    cfg.set_red_func = set_red_func or cfg.set_red_func
    cfg.ox = ox or cfg.ox
    cfg.oy = oy or cfg.oy

    if not cfg[func_id] then
        cfg[func_id] = 1
    end

    local is_red = self:GetRedPoint(func_id)
    self:SetRedPoint(node, is_red)

    return node
end

function RedPointCtrl:UnRegisterRedPoint(node)
    self.red_point_register_list[node] = nil
end

function RedPointCtrl:SetRedPoint(node, is_red)
    local ox = 0
    local oy = 0

    local set_red_func = nil
    local cfg = self.red_point_register_list[node]
    if cfg then
        ox = cfg.ox or ox
        oy = cfg.oy or oy

        set_red_func = cfg.set_red_func
    end

    if set_red_func then
        set_red_func(is_red)
    else
        game_help.SetRedPoint(node, is_red, ox, oy)
    end
end

function RedPointCtrl:CheckRedPoint(func_id)
    local cfg = config_func[func_id]
    if not cfg then
        return false
    end
    return cfg.check_red_func()
end

function RedPointCtrl:DoCheckRedPoint(func_id)
    local is_red = self:CheckRedPoint(func_id)
    if self.red_point_list[func_id] ~= is_red then
        self.red_point_list[func_id] = is_red

        for k,v in pairs(self.red_point_register_list) do
            for ck,cv in pairs(v) do
                if ck == func_id then
                    self:SetRedPoint(k, is_red)
                    break
                end
            end
        end
    end
end

function RedPointCtrl:GetRedPoint(func_id)
    return (self.red_point_list[func_id]==true)
end

local update_delta = 0.1
function RedPointCtrl:OnEvent(func_id, delta_time, params)
    local update_cfg = self.red_point_update_list[func_id]
    if not update_cfg then
        update_cfg = {
            update_time = 0,
            is_update = true,
            is_init = true,
        }
        self.red_point_update_list[func_id] = update_cfg
    end

    local delta_time = delta_time or update_delta
    update_cfg.update_time = global_time.now_time + delta_time
    update_cfg.is_update = true
end

function RedPointCtrl:Update(now_time, delta_time)
    if not self.is_main_view_ready then
        return
    end

    for k,v in pairs(self.red_point_update_list or {}) do
        if now_time >= v.update_time then
            if v.is_init or v.is_update then
                v.is_update = false
                v.is_init = false
                self:DoCheckRedPoint(k)
                break
            end
        end
    end
end

function RedPointCtrl:OnMainViewReady(is_ready)
    self.is_main_view_ready = is_ready
end

game.RedPointCtrl = RedPointCtrl

return RedPointCtrl
