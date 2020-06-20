local FightRankTabItem = Class(game.UITemplate)

function FightRankTabItem:_init(ctrl)
    self.ctrl = ctrl
end

function FightRankTabItem:_delete()

end

function FightRankTabItem:OpenViewCallBack()
    self.txt_title = self._layout_objs["title"]

    self:InitChildList(config.career_init)
end

function FightRankTabItem:CloseViewCallBack()
    
end

function FightRankTabItem:InitChildList(child_list_data)
    self.child_list_data = child_list_data or {}

    local item_num = #child_list_data
    self.list_child = self._layout_objs["list_child"]
    self.list_child:SetItemNum(item_num)
    
    self.ctrl_child = self.list_child:AddControllerCallback("ctrl_child", function(idx, obj)
        self:OnChildClick(idx + 1)
    end)
    self.ctrl_child:SetPageCount(item_num)

    for i=1, item_num do
        local item = self.list_child:GetChildAt(i-1)
        item:SetText(child_list_data[i].name)
    end
end

function FightRankTabItem:ShowChildren()
    local item_num = self.list_child:GetItemNum()
    self.list_child:ResizeToFit(item_num)
end

function FightRankTabItem:HideChildren()
    self.list_child:ResizeToFit(0)
end

function FightRankTabItem:OnChildClick(index)
    local page = 1
    local career = self.child_list_data[index].career
    if self.grade and self.parent then
        self.parent:UpdateRankList()
        self.parent:RefreshRankPage(career, self.grade, page)
        self.parent:SetArrowCtrl(0)
        self.parent:SetMyRankCtrl(career, self.grade)
    end
end

function FightRankTabItem:RefreshChild(index)
    index = index or 1
    self.ctrl_child:SetSelectedIndexEx(index - 1)
end

function FightRankTabItem:SetItemInfo(item_info)
    self.grade = item_info.grade
    self.txt_title:SetText(string.format(config.words[4830], config.career_battle_grade[self.grade].name))
end

function FightRankTabItem:SetParent(parent)
    self.parent = parent
end

return FightRankTabItem