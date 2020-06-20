local MakeTeamSideInfoView = Class(game.BaseView)

local handler = handler
local string_gsub = string.gsub
local string_format = string.format

function MakeTeamSideInfoView:_init(ctrl)
    self._package_name = "ui_make_team"
    self._com_name = "make_team_side_info_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self.ctrl = ctrl
end

function MakeTeamSideInfoView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
end

function MakeTeamSideInfoView:CloseViewCallBack()
    
end

function MakeTeamSideInfoView:RegisterAllEvents()
    local events = {
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MakeTeamSideInfoView:Init()
    self.txt_target = self._layout_objs["txt_target"]

    self:InitBtns()
    self:InitMembers()
end

function MakeTeamSideInfoView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1671]):HideBtnBack()
end

function MakeTeamSideInfoView:InitBtns()
    self.btn_modify = self._layout_objs["btn_modify"]
    self.btn_modify:AddClickCallBack(function()

    end)

    self.btn_match = self._layout_objs["btn_match"]
    self.btn_match:AddClickCallBack(function()

    end)

    self.btn_apply_list = self._layout_objs["btn_apply_list"]
    self.btn_apply_list:AddClickCallBack(function()
        self.ctrl:OpenApplyView()
    end)

    self.btn_invite = self._layout_objs["btn_invite"]
    self.btn_invite:AddClickCallBack(function()
        self.ctrl:SendTeamRecruit()
    end)

    self.btn_exit = self._layout_objs["btn_exit"]
    self.btn_exit:AddClickCallBack(function()
        self.ctrl:SendTeamLeave()
    end)
end

function MakeTeamSideInfoView:InitMembers()
    self.list_members = self._layout_objs["list_members"]
end

return MakeTeamSideInfoView

