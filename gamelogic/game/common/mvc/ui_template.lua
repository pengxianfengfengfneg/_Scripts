
local UITemplate = Class(require("game/common/mvc/event_handler"))

local _gameobject = UnityEngine.GameObject
local _template_num = 0
local _ui_mgr = N3DClient.UIManager:GetInstance()

local _et = {}

local layout_mt = {__index = function(t, k)
	if t._root_ then
		local obj = t._root_:GetChild(k)
        t[k] = obj
        return obj
	end
end}

function UITemplate:_init()
	self._package_name = nil
    self._com_name = nil

    self._layout_root = nil
    self._layout_objs = nil
	
	self._is_open = false

	if not self._is_init then
		self._is_init = true
		_template_num = _template_num + 1
	end

	self._template_list_ = {}
	self._ui_effect_list = {}
end

function UITemplate:_delete()
	if self._is_init then
		self._is_init = nil
		_template_num = _template_num - 1
	end

	self:Close()
end

function UITemplate:Open(...)
	if not self._is_open then
		self:_CreateLayout()

		self._is_open = true
		if self.OpenViewCallBack then
			self:OpenViewCallBack(...)
		end
	end
end

function UITemplate:Close()
	if self._is_open then
		self:UnBindAllEvents()
		self:ClearTemplates()
		self:ClearUIEffect()
		self:ClearAsyncSpriteList()
		self:UnRegisterRedPoint()

		if self.CloseViewCallBack then
			self:CloseViewCallBack()
		end

		self:_DestroyLayout()
		self:ClearAsyncSpriteList()
		self._is_open = false
	end
end

function UITemplate:SetParent(parent)
	if self._is_open then
		parent:AddChild(self._layout_root)
	end
end

function UITemplate:SetVirtual(root)
	self._is_virtual = true
	self._layout_root = root
end

function UITemplate:GetRoot()
	return self._layout_root
end

function UITemplate:IsOpen()
    return self._is_open
end

function UITemplate:GetTemplateNum()
	return _template_num
end

function UITemplate:ShowLayout()
    if self._layout_root then
        self._layout_root:SetVisible(true)
    end
end

function UITemplate:HideLayout()
    if self._layout_root then
        self._layout_root:SetVisible(false)
    end
end

function UITemplate:_CreateLayout()
    if not self._layout_root then
        self._layout_root = _ui_mgr:CreateObject(self._package_name, self._com_name)
    end

    if self._layout_root and not self._layout_objs then
        self._layout_objs = {}
        self._layout_objs._root_ = self._layout_root
        setmetatable(self._layout_objs, layout_mt)
    end
end

function UITemplate:_DestroyLayout()
	if self._is_virtual then
		return
	end
    if self._layout_root then
    	self._layout_root:Dispose()
    	self._layout_root = nil
    end
end

function UITemplate:Center()
	if self._layout_root then
		self._layout_root:Center()
	end
end

function UITemplate:SetVisible(val)
	self._layout_root:SetVisible(val)
end

function UITemplate:Active(val, params)
	self._actived = val

	self:OnActived(val, params)
end

function UITemplate:OnActived(val, params)
	
end

function UITemplate:IsActive()
	return self._actived
end

function UITemplate:CreateUIEffect(graph, path)
    local ui_effect = self._ui_effect_list[graph]
    if not ui_effect then
        ui_effect = game.GamePool.UIEffectPool:Create()
        ui_effect:Init(graph)
        self._ui_effect_list[graph] = ui_effect
    end
    return ui_effect:CreateEffect(path)
end

function UITemplate:ClearUIEffect()
	for i, v in pairs(self._ui_effect_list) do
		game.GamePool.UIEffectPool:Free(v)
	end
	self._ui_effect_list = {}
end

function UITemplate:StopUIEffect(graph)
    local ui_effect = self._ui_effect_list[graph]
    if ui_effect then
    	ui_effect:StopEffect()
    end
end

function UITemplate:GetChild(key)
	return self._layout_objs[key]
end

function UITemplate:GetTemplate(class_path, obj_path, params)
	local obj = self:GetChild(obj_path)
	if obj and not self._template_list_[obj] then
		local template = require(class_path).New(self, params)
		template:SetVirtual(obj)
		template:Open()

		self._template_list_[obj] = template
	end
	return self._template_list_[obj]
end

function UITemplate:GetTemplateByObj(class_path, obj, params)
	if obj and not self._template_list_[obj] then
		local template = require(class_path).New(self, params)
		template:SetVirtual(obj)
		template:Open()

		self._template_list_[obj] = template
	end
	return self._template_list_[obj]
end

function UITemplate:GetIconTemplate(obj_path)
    return self:GetTemplate("game/common/ui/head_icon", obj_path)
end

function UITemplate:ClearTemplates()
	for _,v in pairs(self._template_list_ or {}) do
		v:DeleteMe()
	end
	self._template_list_ = {}
end

function UITemplate:CreateList(list_path, class_path, virtual)
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

function UITemplate:SetSpriteAsync(obj, bundle_path, bundle_name, sp_name, is_resource)
    if not self.async_bundle_list then
        self.async_bundle_list = {}
    end

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
    sp_info[3] = is_resource or false

    if bundle_info.is_finish then
        obj:SetSprite(bundle_name, sp_name, is_resource or false)
    end
end

function UITemplate:RefreshAsyncSprite(bundle_name)
    if self.async_sprite_list then
        for k,v in pairs(self.async_sprite_list) do
            if v[1] == bundle_name then
                k:SetSprite(bundle_name, v[2], v[3])
            end
        end
    end
end

function UITemplate:ClearAsyncSpriteList()
    self.async_sprite_list = nil
end

function UITemplate:ClearAsyncBundleList()
    if self.async_bundle_list then
        for k,v in pairs(self.async_bundle_list) do
            _asset_loader:UnLoad(v.id)
        end
        self.async_bundle_list = nil
    end
end


function UITemplate:RegisterRedPoint(node, func_id, set_red_func, ox, oy)
    if not self.red_point_list then
        self.red_point_list = {}
    end

    table.insert(self.red_point_list, node)

    game.RedPointCtrl.instance:RegisterRedPoint(node, func_id, set_red_func, ox, oy)
end

function UITemplate:UnRegisterRedPoint()
	if game.RedPointCtrl.instance then
	    for _,v in ipairs(self.red_point_list or _et) do
	        game.RedPointCtrl.instance:UnRegisterRedPoint(v)
	    end
	end
end

game.UITemplate = UITemplate

return UITemplate
