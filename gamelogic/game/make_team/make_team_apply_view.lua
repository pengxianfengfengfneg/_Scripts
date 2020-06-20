local MakeTeamApplyView = Class(game.BaseView)

local handler = handler
local string_gsub = string.gsub
local string_format = string.format

function MakeTeamApplyView:_init(ctrl)
    self._package_name = "ui_make_team"
    self._com_name = "make_team_apply_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self.ctrl = ctrl
end

function MakeTeamApplyView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    --self:RequestApplyList()

    self:RegisterAllEvents()
end

function MakeTeamApplyView:CloseViewCallBack()
    self.ctrl:OpenView()
end

function MakeTeamApplyView:RegisterAllEvents()
    local events = {
        {game.MakeTeamEvent.UpdateApplyList, handler(self, self.OnUpdateApplyList)},
        {game.MakeTeamEvent.UpdateAcceptApply, handler(self, self.OnUpdateAcceptApply)},
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MakeTeamApplyView:RequestApplyList()
    self.ctrl:SendTeamApplyList()
end

function MakeTeamApplyView:Init()
    self.txt_target = self._layout_objs["txt_target"]

    self.item_data = {}

    self:InitBtns()
    self:InitMembers()
end

function MakeTeamApplyView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1671]):HideBtnBack()
end

function MakeTeamApplyView:InitBtns()
    self.btn_clear = self._layout_objs["btn_clear"]
    self.btn_clear:AddClickCallBack(function()
        -- 一键清空
        self.ctrl:SendTeamAcceptApply(0,0)
    end)
end

function MakeTeamApplyView:InitMembers()
    self.list_item = self._layout_objs["list_item"]

    self.ui_list = self:CreateList("list_item", "game/make_team/make_team_apply_item", true)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetItemData(idx)
        item:UpdateData(data)
    end)

    self:DoUpdateApplyList()
end

function MakeTeamApplyView:GetItemData(idx)
    return self.item_data[idx]
end

function MakeTeamApplyView:OnUpdateApplyList(data)
    self:DoUpdateApplyList()
end

function MakeTeamApplyView:DoUpdateApplyList()
    self.item_data = self.ctrl:GetApplyList()

    self.ui_list:SetItemNum(#self.item_data)
end

function MakeTeamApplyView:OnUpdateAcceptApply(data)
    self:DoUpdateApplyList()
end

return MakeTeamApplyView

