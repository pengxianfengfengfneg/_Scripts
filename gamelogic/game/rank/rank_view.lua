local RankView = Class(game.BaseView)

function RankView:_init(ctrl)
	self._package_name = "ui_rank"
    self._com_name = "rank_view"
    self.ctrl = ctrl

    self._show_money = true
end

function RankView:OpenViewCallBack()

    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1413])

    self:GetTemplateByObj("game/rank/rank_main_template", self._layout_objs["n16"]:GetChildAt(0), 1)
    self:GetTemplateByObj("game/rank/rank_main_template", self._layout_objs["n16"]:GetChildAt(1), 2)
    self:GetTemplateByObj("game/rank/rank_main_template", self._layout_objs["n16"]:GetChildAt(2), 3)
    self:GetTemplateByObj("game/rank/rank_main_template", self._layout_objs["n16"]:GetChildAt(3), 4)
end

function RankView:CloseViewCallBack()

end

return RankView