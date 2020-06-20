local ChapterStoryView = Class(game.BaseView)

function ChapterStoryView:_init()
    self._package_name = "ui_task"
    self._com_name = "chapter_view"

    self._ui_order = game.UIZOrder.UIZOrder_Top

    self._layer_name = game.LayerName.UIDefault

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone

    self._cache_time = 0
end

function ChapterStoryView:OnPreOpen()
    self.main_role = game.Scene.instance:GetMainRole()
    self.main_role:SetPauseOperate(true)

    game.RenderUnit:HideUI()
end

function ChapterStoryView:OnPreClose()
    game.RenderUnit:ShowUI()

    self.main_role:SetPauseOperate(false)
end

function ChapterStoryView:OpenViewCallBack(id)

    local cfg = config.chapter_story[id]
    self._layout_objs.title:SetText(cfg.chapter)
    self._layout_objs.first:SetText(cfg.first)
    self._layout_objs.second:SetText(cfg.second)

    self.tween = DOTween.Sequence()
    self.tween:AppendInterval(4.5)
    self.tween:SetAutoKill(false)
    self.tween:OnComplete(function()
        self:Close()
    end)

    global.AudioMgr:PlaySound("jq001")
end

function ChapterStoryView:CloseViewCallBack()
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

return ChapterStoryView