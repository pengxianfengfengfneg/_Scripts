local ExamineRankItem = Class(game.UITemplate)

function ExamineRankItem:_init()
    self.ctrl = game.DailyTaskCtrl.instance
end

function ExamineRankItem:OpenViewCallBack()
	self:Init()
end

function ExamineRankItem:CloseViewCallBack()
    
end

function ExamineRankItem:Init()
    self.txt_index = self._layout_objs["txt_index"]
    self.txt_name = self._layout_objs["txt_name"]
    
    self.img_rank = self._layout_objs["img_rank"]
    self.img_bg = self._layout_objs["img_bg"]
    self.img_bg2 = self._layout_objs["img_bg2"]

    self.ctrl_rank = self:GetRoot():GetController("ctrl_rank")
end

function ExamineRankItem:SetItemInfo(item_info, idx)
    if item_info then
        self.txt_index:SetText(item_info.rank)
        self.txt_name:SetText(item_info.name)

        if item_info.rank <= 3 then
            self.img_rank:SetSprite("ui_daily_task", "kj00"..4+item_info.rank)
            self.ctrl_rank:SetSelectedIndex(1)
        else
            self.ctrl_rank:SetSelectedIndex(0)
        end
    else
        self.txt_index:SetText("")
        self.txt_name:SetText("")
        self.ctrl_rank:SetSelectedIndex(0)
    end

    self.img_bg:SetVisible(idx % 2 == 1)
    self.img_bg2:SetVisible(idx % 2 == 0)
end

return ExamineRankItem
