
local BaseView = Class(require("game/common/mvc/event_handler"))

local _asset_loader = global.AssetLoader
local _timer_mgr = global.TimerMgr
local _runner = global.Runner
local _gameobject = UnityEngine.GameObject
local _ui_mgr = N3DClient.UIManager:GetInstance()
local AudioMgr = global.AudioMgr
local drag_start = 50
local drag_dist = 100

local _et = {}

local Status = {
    Close = 0,
    Caching = 1,
    Loading = 2,
    Open = 3,
}

local layout_mt = {__index = function(t, k)
	if t._root_ then
		local obj = t._root_:GetChild(k)
        t[k] = obj
        return obj
	end
end}

function BaseView:_init()
    self._package_name = nil
    self._com_name = nil
    self._ref_package_list = {}
    self._ui_order = game.UIZOrder.UIZOrder_Common
    self._swallow_touch = true
    self._status = Status.Close

    self._res_req_list = {}
    self._load_res_finish = false

    self._ui_obj = nil
    self._layout_root = nil
    self._layout_objs = nil
    self._ui_panel = nil 

    self._cache_time = 60
    self._cache_time_id = nil

    self._view_type = game.UIViewType.None

    self._layer_name = game.LayerName.UI

    self._view_level = game.UIViewLevel.First
    self._mask_type = game.UIMaskType.Full

    self._template_list_ = {}
    self._ui_effect_list = {}

    self._drag_x = drag_start
end

function BaseView:_delete()
    self:Close()
    self:_UnLoadRes()
    self._status = Status.Close

    if self._cache_time_id then
        _timer_mgr:DelTimer(self._cache_time_id)
        self._cache_time_id = nil
    end
end

function BaseView:AddPackage(package)
    table.insert(self._ref_package_list, package)
end

function BaseView:GetRoot()
    return self._layout_root
end

function BaseView:GetRootObj()
    return self._ui_obj
end

function BaseView:IsOpen()
    return self._status == Status.Open
end

function BaseView:IsLoading()
    return self._status == Status.Loading
end

function BaseView:Open(...)
    if self:IsOpen() then
        self:ShowLayout()
        return
    end

    if self._status == Status.Close then
        self._open_param = {...}
        self:OnPreOpen(...)
        game.ViewMgr:PreAddView(self)

        self._status = Status.Loading
        self:_LoadPackage()
    elseif self._status == Status.Caching then
        self._open_param = {...}
        self:OnPreOpen(...)
        game.ViewMgr:PreAddView(self)
        
        if self._cache_time_id then
            _timer_mgr:DelTimer(self._cache_time_id)
            self._cache_time_id = nil
        end
        self:_LoadResFinish()
    end
end

function BaseView:Close()
    if self._status == Status.Open then
        self:OnPreClose()

        game.ViewMgr:PreCloseView(self)

        self:UnBindAllEvents()
        self:ClearTemplates()
        self:ClearUIEffect()
        self:ClearAsyncSpriteList()
        self:UnScheduleUpdate()
        self:UnRegisterRedPoint()

        if not self.not_add_mgr then
            game.ViewMgr:RemoveView(self)
            game.ViewMgr:FireGuideEvent()
        end

        self:FireEvent(game.ViewEvent.CloseView, self)

        if self.CloseViewCallBack then
            self:CloseViewCallBack()
        end

        if self._cache_time <= 0 then
            self:_UnLoadRes()
            self._status = Status.Close
        else
            if not self._cache_time_id then
                local del_func = function()
                    self:_UnLoadRes()
                    self._status = Status.Close
                    self._cache_time_id = nil
                    return true
                end
                self._cache_time_id = _timer_mgr:CreateTimer(self._cache_time, del_func)
            end
            self:HideLayout()
            self._status = Status.Caching
        end

        AudioMgr:PlaySound("ui002")
    elseif self._status == Status.Loading then
        self:OnPreClose()
        game.ViewMgr:PreCloseView(self)
        
        self:_UnLoadRes()
        self._status = Status.Close
    end
end

function BaseView:ShowLayout()
    if self._layout_root then
        self._layout_root:SetVisible(true)
        if self._ui_panel then
            self._ui_panel:SetSortingOrder(self._ui_order, true)
        end
    end
end

function BaseView:HideLayout()
    if self._layout_root then
        self._layout_root:SetVisible(false)
    end
end

function BaseView:_LoadPackage()
    local package_list = {self._package_name}
    for i,v in ipairs(self._ref_package_list) do
        table.insert(package_list, v)
    end

    local loading_count = #package_list
    for i,v in ipairs(package_list) do
        local bundle_name = self:GetPackageBundle(v)
        local req_id = global.AssetLoader:LoadAllAsset(bundle_name, true, function()
            loading_count = loading_count - 1
            if loading_count == 0 then
                self:_LoadResFinish()
            end
        end)
        table.insert(self._res_req_list, req_id)
    end
end

function BaseView:_LoadResFinish()
    if not self._ui_obj then
        self:_CreateLayout()
        if self._layout_root then
            self._status = Status.Open

            self._layout_root:SetTouchEnable(self._swallow_touch)

            self._load_res_finish = true
            if self.LoadResCallBack then
                self:LoadResCallBack()
            end

            if self._view_level > game.UIViewLevel.Standalone then
                self:AddDragCloseEvent()
            end
        else
            self:Close()
            return
        end
    else
        self._status = Status.Open
        self:ShowLayout()
    end

    if not self.not_add_mgr then
        game.ViewMgr:AddView(self)
        game.ViewMgr:FireGuideEvent()
    end

    if self.OpenViewCallBack then
        self:OpenViewCallBack(table.unpack(self._open_param))
    end

    AudioMgr:PlaySound("ui001")

    self:FireEvent(game.ViewEvent.OpenView, self)
end

function BaseView:_UnLoadRes()
    if self._load_res_finish then
        if self.ReleaseResCallBack then
            self:ReleaseResCallBack()
        end
        self._load_res_finish = false
    end

    self:_DestroyLayout()

    for i,v in ipairs(self._res_req_list) do
        _asset_loader:UnLoad(v)
    end
    self._res_req_list = {}

    self:ClearAsyncBundleList()
end

function BaseView:_CreateLayout()
    if not self._ui_obj then
        self._ui_obj, self._layout_root, self._ui_panel = _ui_mgr:CreateUIPanel(self._package_name, self._com_name, self._ui_order)
        if self._layout_root then
            self._layout_objs = {}
            self._layout_objs._root_ = self._layout_root
            setmetatable(self._layout_objs, layout_mt)

            self._ui_obj:SetLayer(self._layer_name, true)
        end
    end
end

function BaseView:_DestroyLayout()
    if self._ui_obj then
        _gameobject.Destroy(self._ui_obj)
        self._layout_root = nil
        self._layout_objs = nil
        self._ui_obj = nil
    end
end

function BaseView:GetPackageBundle(name)
    return string.format("ui/%s.ab", name)
end

function BaseView:AddChildAt(gobj, idx)
    self._layout_root:AddChildAt(gobj, idx or 0)
end

function BaseView:AddChild(gobj)
    self._layout_root:AddChild(gobj)
end

function BaseView:GetChild(key)
    return self._layout_objs[key]
end

function BaseView:OnEmptyClick()
end

function BaseView:GetTemplate(class_path, obj_path, params)
    local obj = self:GetChild(obj_path)
    if obj and not self._template_list_[obj] then
        local template = require(class_path).New(self, params)
        template:SetVirtual(obj)
        template:Open()

        self._template_list_[obj] = template
    end
    return self._template_list_[obj]
end

function BaseView:GetTemplateByObj(class_path, obj, params)
    if obj and not self._template_list_[obj] then
        local template = require(class_path).New(self, params)
        template:SetVirtual(obj)
        template:Open()

        self._template_list_[obj] = template
    end
    return self._template_list_[obj]
end

function BaseView:ClearTemplates()
    for _,v in pairs(self._template_list_ or {}) do
        v:DeleteMe()
    end
    self._template_list_ = {}
end

function BaseView:GetBgTemplate(obj_path)
    return self:GetTemplate("game/common/ui/common_bg", obj_path)
end

function BaseView:GetFullBgTemplate(obj_path)
    return self:GetTemplate("game/common/ui/common_fullbg", obj_path)
end

function BaseView:GetMoneyTemplate(obj_path)
    return self:GetTemplate("game/main/money_template", obj_path)
end

function BaseView:GetIconTemplate(obj_path)
    return self:GetTemplate("game/common/ui/head_icon", obj_path)
end

function BaseView:GetName()
    if not self._ui_name then
        self._ui_name = string.format("%s/%s", self._package_name, self._com_name)
    end
    return self._ui_name
end

function BaseView:CreateUIEffect(graph, path, layer)
    local ui_effect = self._ui_effect_list[graph]
    if not ui_effect then
        ui_effect = game.GamePool.UIEffectPool:Create()
        ui_effect:Init(graph, layer)
        self._ui_effect_list[graph] = ui_effect
    end
    return ui_effect:CreateEffect(path)
end

function BaseView:ClearUIEffect()
    for i, v in pairs(self._ui_effect_list) do
        game.GamePool.UIEffectPool:Free(v)
    end
    self._ui_effect_list = {}
end

function BaseView:StopUIEffect(graph)
    local ui_effect = self._ui_effect_list[graph]
    if ui_effect then
        ui_effect:StopEffect()
    end
end

function BaseView:SetGuideIndex(index)
    self.guide_index = index
end

function BaseView:GetGuideIndex()
    return self.guide_index
end

function BaseView:CreateList(list_path, class_path, virtual)
    local list_obj = self:GetChild(list_path)
    if list_obj and not self._template_list_[list_obj] then
        local list = game.UIList.New(list_obj)
        list:SetCreateItemFunc(function(obj)
            local item = require(class_path).New()
            item:SetVirtual(obj)
            item:Open()
            return item
        end)
        list:SetVirtual(virtual or false)
        self._template_list_[list_obj] = list
    end
    return self._template_list_[list_obj]
end

function BaseView:ScheduleUpdate(priority)
    if not self._is_schedule_update then
        self._is_schedule_update = true
        _runner:AddUpdateObj(self,priority or 2)
    end
end

function BaseView:UnScheduleUpdate()
    if self._is_schedule_update then
        self._is_schedule_update = false
        _runner:RemoveUpdateObj(self)
    end
end

function BaseView:Update(now_time, elapse_time)
    
end

function BaseView:SetLayer(layer, val)
    if self._ui_obj then
        self._ui_obj:SetLayer(layer, val)
    end
end

function BaseView:AddDragCloseEvent()
    self._layout_root:SetTouchBeginCallBack(function(x)
        if x < drag_start then
            self._drag_x = x
        end
    end)
    self._layout_root:SetTouchMoveCallBack(function(x)
        if self._drag_x < drag_start then
            self._layout_root:SetPositionX(x)
        end
    end)
    self._layout_root:SetTouchEndCallBack(function(x)
        if self._drag_x < drag_start then
            if x - self._drag_x >= drag_dist then
                local tween = DOTween.Sequence()
                tween:Append(self._layout_root:TweenMoveX(UnityEngine.Screen.width, 0.1))
                tween:AppendInterval(0.1)
                tween:AppendCallback(function()
                    self:Close()
                    self._layout_root:SetPositionX(0)
                    self._drag_x = drag_start
                end)
                tween:SetAutoKill(true)
            else
                self._layout_root:SetPositionX(0)
                self._drag_x = drag_start
            end
        end
    end)
end

function BaseView:OnPreOpen()
    
end

function BaseView:OnPreClose()
    
end

function BaseView:GetViewGuideName()
    if self._view_guide_name then
        return self._view_guide_name
    end

    return self:GetName()
end

function BaseView:SetSpriteAsync(obj, bundle_path, bundle_name, sp_name, is_resource, callback)
    if not self.async_bundle_list then
        self.async_bundle_list = {}
    end

    local bundle_name = tostring(bundle_name)
    local sp_name = tostring(sp_name)
    local is_resource = (is_resource and true or false)

    local bundle_info = self.async_bundle_list[bundle_path]
    if not bundle_info then
        bundle_info = {}
        self.async_bundle_list[bundle_path] = bundle_info
    end

    if not bundle_info.id then
        bundle_info.id = _asset_loader:LoadAllAsset(bundle_path, true, function()
            bundle_info.is_finish = true
            self:RefreshAsyncSprite(bundle_name)
        end)
    end

    if not self.async_sprite_list then
        self.async_sprite_list = {}
    end

    obj:ClearSprite()
    local sp_info = self.async_sprite_list[obj]
    if not sp_info then
        sp_info = {}
        self.async_sprite_list[obj] = sp_info
    end

    sp_info[1] = bundle_name
    sp_info[2] = sp_name
    sp_info[3] = is_resource
    sp_info[4] = callback

    if bundle_info.is_finish then
        obj:SetSprite(bundle_name, sp_name, is_resource or false)

        if callback then
            callback()
        end
    end
end

function BaseView:RefreshAsyncSprite(bundle_name)
    if self.async_sprite_list then
        for k,v in pairs(self.async_sprite_list) do
            if v[1] == bundle_name then
                k:SetSprite(bundle_name, v[2], v[3])

                if v[4] then
                    v[4]()
                end
            end
        end
    end
end

function BaseView:ClearAsyncSpriteList()
    self.async_sprite_list = nil
end

function BaseView:ClearAsyncBundleList()
    if self.async_bundle_list then
        for k,v in pairs(self.async_bundle_list) do
            _asset_loader:UnLoad(v.id)
        end
        self.async_bundle_list = nil
    end
end

function BaseView:GetViewLevel()
    return self._view_level
end

function BaseView:RegisterRedPoint(node, func_id, set_red_func, ox, oy)
    if not self.red_point_list then
        self.red_point_list = {}
    end

    table.insert(self.red_point_list, node)

    game.RedPointCtrl.instance:RegisterRedPoint(node, func_id, set_red_func, ox, oy)
end

function BaseView:UnRegisterRedPoint()
    if game.RedPointCtrl.instance then
        for _,v in ipairs(self.red_point_list or _et) do
            game.RedPointCtrl.instance:UnRegisterRedPoint(v)
        end
    end
end

function BaseView:GetMaskType()
    return self._mask_type
end

function BaseView:PlayTransition(name, callback)
    self:GetRoot():PlayTransition(name, callback)
end

function BaseView:StopTransition(name)
    self:GetRoot():StopTransition(name)
end

function BaseView:StopAllTransition()
    self:GetRoot():StopAllTransition()
end

game.BaseView = BaseView

return BaseView
