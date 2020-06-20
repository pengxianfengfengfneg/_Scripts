local SpeakBubbleTemplate = Class(game.UITemplate)

local _ui_mgr = N3DClient.UIManager:GetInstance()

local config_chat_bubble = config.chat_bubble

local layout_mt = { __index = function(t, k)
    if t._root_ then
        local obj = t._root_:GetChild(k)
        t[k] = obj
        return obj
    end
end }

function SpeakBubbleTemplate:_init()
    self._package_name = "ui_scene"
    self._com_name = "speak_bubble"
end

function SpeakBubbleTemplate:_delete()
end

function SpeakBubbleTemplate:Init()
    self._layout_root:SetVisible(false)

    self.img_bubble_bg = self._layout_objs["n0"]
    self.txt_content = self._layout_objs["txt"]

    self.orign_x = 10
end

function SpeakBubbleTemplate:Reset()
    self._layout_root:SetVisible(false)
end

function SpeakBubbleTemplate:OpenViewCallBack()

end

function SpeakBubbleTemplate:CloseViewCallBack()
end

function SpeakBubbleTemplate:_CreateLayout()
    if not self._ui_obj then
        self._ui_obj, self._layout_root, self._ui_panel = _ui_mgr:CreatePanel(self._package_name, self._com_name, game.LayerName.HeadWidget)
        if self._layout_root then
            self._ui_obj:SetHudComponent(0, 50, 0.001, 0.03)
            self._layout_objs = {}
            self._layout_objs._root_ = self._layout_root
            self._ui_panel:SetSortingOrder(10000, true)
            setmetatable(self._layout_objs, layout_mt)

            self._layout_root:SetTouchEnable(false)
        end
    end
end

function SpeakBubbleTemplate:_DestroyLayout()
    if self._layout_root then
        self._layout_root:Dispose()
        self._layout_root = nil
    end

    if self._ui_obj then
        UnityEngine.GameObject.Destroy(self._ui_obj)
        self._ui_obj = nil
    end
end

function SpeakBubbleTemplate:SetParent(parent)
    if self._is_open and self.hud_item then
        parent:AddChild(self.hud_item)
    end
end

function SpeakBubbleTemplate:SetOwner(obj, offset)
    if self._ui_obj then
        self._layout_root:SetPosition(0, 0, 0)
        self._ui_obj:SetParent(obj)
        self._ui_obj:SetPosition(0, offset + 0.8, 0)
    end
end

function SpeakBubbleTemplate:SetText(content, time, bubble_id)
    self._layout_root:SetVisible(true)
    self.txt_content:SetText(content)
    
    self.bubble_time = (time or 3) + global.Time.now_time
    self.bubble_id = bubble_id or 0

    local cfg = config_chat_bubble[self.bubble_id]
    if cfg then
        local res = (self.bubble_id<=0 and "ltk_00" or cfg.res)
        self.txt_content:SetPositionX(self.orign_x + (cfg.offset_x or 0))
        self.img_bubble_bg:SetSprite("ui_main", res)
    end
end

function SpeakBubbleTemplate:GetObj()
    return self._ui_obj
end

function SpeakBubbleTemplate:Update(now_time, elapse_time)
    if self.bubble_time then
        if now_time >= self.bubble_time then
            self._layout_root:SetVisible(false)

            self.bubble_time = nil
        end
    end
end

return SpeakBubbleTemplate
