local ViewMgr = Class()

local table_insert = table.insert
local table_remove = table.remove

local UIViewLevel = game.UIViewLevel
local UIMaskType = game.UIMaskType

function ViewMgr:_init()
    self.managed_view_list = {}

    self.view_stack = {}

    self.view_pre_stack = {}

    self:InitMaskLayer()
end

function ViewMgr:_delete()
    if self._mask_layer_ then
        self._mask_layer_:Dispose()
        self._mask_layer_ = nil
    end
end

local view = {
    _view_level = UIViewLevel.First
}
function ViewMgr:CloseAllView()    
    self:CloseView(view)
end

function ViewMgr:AddView(view)
    local view_level = view._view_level or UIViewLevel.Keep
    if view_level <= UIViewLevel.Keep then
        return
    end

    self:CloseView(view)

    table_insert(self.view_stack, view)

    self:AdjustMaskLayer()
end

function ViewMgr:CloseView(view)
    local view_level = view._view_level
    if view_level <= UIViewLevel.Standalone then
        return
    end

    local keep_list = {}
    local close_list = {}
    for _,v in ipairs(self.view_stack or {}) do
        if view_level <= v._view_level then
            table_insert(close_list, v)
        else
            table_insert(keep_list, v)
        end
    end

    self.view_stack = keep_list

    for _,v in ipairs(close_list) do
        v:Close()
    end
end

function ViewMgr:RemoveView(view)
    for k,v in ipairs(self.view_stack or {}) do
        if v == view then
            table_remove(self.view_stack, k)
            break
        end
    end

    self:AdjustMaskLayer()
end

function ViewMgr:PreAddView(view)
    self.view_pre_stack[view] = 1
end

function ViewMgr:PreCloseView(view)
    self.view_pre_stack[view] = nil
end

function ViewMgr:InitMaskLayer()
    if not self._mask_layer_ then
        self.full_size = {
            game.DesignWidth,
            game.UIHeight
        }

        self.dark_color = UnityEngine.Color(0.0,0.0,0.0,0.6)
        self.alpha_color = UnityEngine.Color(0.0,0.0,0.0,0.0)

        local graph = FairyGUI.GGraph()
        graph:SetSize(self.full_size[1], self.full_size[2])
        graph:DrawRect(self.full_size[1], self.full_size[2], 0, self.dark_color, self.dark_color)
        graph:AddClickCallBack(function()
            if self.mask_view then
                self.mask_view:OnEmptyClick()
            end
        end)

        self._mask_layer_ = graph
    end
end

function ViewMgr:AdjustMaskLayer()
    self.mask_view = nil

    if #self.view_stack > 0 then
        for i=#self.view_stack,1,-1 do
            local view = self.view_stack[i]
            if view._mask_type ~= UIMaskType.None then
                self.mask_view = view
                break
            end
        end
    end

    if self._mask_layer_ then
        self._mask_layer_:RemoveFromParent()
        if self.mask_view then
            local root = self.mask_view:GetRoot()
            local mask_type = self.mask_view._mask_type
            local mask_size = self.full_size

            local color = self.dark_color
            if mask_type == UIMaskType.FullAlpha then
                color = self.alpha_color
            end

            self._mask_layer_.color = color
            self._mask_layer_:SetSize(mask_size[1], mask_size[2])
            self.mask_view:AddChildAt(self._mask_layer_, 0)

            self._mask_layer_:Center()
        end
    end
end

function ViewMgr:GetTopView()

    if self.view_stack then
        local max_num = #self.view_stack
        return self.view_stack[max_num]
    end
end

function ViewMgr:HideView(view_type)
    for i, v in pairs(self.view_stack) do
        if v._view_type == view_type then
            v:HideLayout()
        end
    end
end

function ViewMgr:ShowView(view_type)
    for i, v in pairs(self.view_stack) do
        if v._view_type == view_type then
            v:ShowLayout()
        end
    end
end

function ViewMgr:FireGuideEvent()

    local top_view = self:GetTopView()
    if top_view then
        local ctrl = game.GuideCtrl.instance
        if ctrl then
            ctrl:OnFocusOnView(top_view)
        end
    end
end

function ViewMgr:GetViewStack()
    return self.view_stack
end

function ViewMgr:HasViewLevel(level)
    for k,v in pairs(self.view_pre_stack) do
        if k._view_level == level then
            return true
        end
    end
    return false
end

function ViewMgr:HasViewGuideLevel()
    return self:HasViewLevel(UIViewLevel.Guide)
end

function ViewMgr:HasViewMask()
    for k,v in pairs(self.view_pre_stack) do
        if k:GetMaskType() >= UIMaskType.Full then
            return true
        end
    end
    return false
end

game.ViewMgr = ViewMgr.New()