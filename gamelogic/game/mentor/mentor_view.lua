local MentorView = Class(game.BaseView)

local PageIndex = {
    Register = 0,
    Mentor = 1,
    Prentice = 2,
}

local PageConfig = {
    {
        item_path = "register_com",
        item_class = "game/mentor/template/register_com",
    },
    {
        item_path = "mentor_com",
        item_class = "game/mentor/template/mentor_com",
    },
    {
        item_path = "prentice_com",
        item_class = "game/mentor/template/prentice_com",
    },
}

function MentorView:_init(ctrl)
    self._package_name = "ui_mentor"
    self._com_name = "mentor_view"
    self.ctrl = ctrl

    self._show_money = true

    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
end

function MentorView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
    self.ctrl:SendMentorInfo()
end

function MentorView:CloseViewCallBack()
    self.page_idx = nil
end

function MentorView:RegisterAllEvents()
    local events = {
        {game.MentorEvent.UpdateMentorInfo, handler(self, self.UpdateMentorInfo)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MentorView:Init()
    self:InitView()
    self.ctrl_page = self:GetRoot():AddControllerCallback("ctrl_page", function(idx)
        self.page_idx = idx + 1
    end)
    self:UpdateMentorInfo()
end

function MentorView:InitView()
    for _, v in ipairs(PageConfig) do
        self:GetTemplate(v.item_class, v.item_path)
    end
end

function MentorView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6400])
end

function MentorView:UpdateMentorInfo()
    local page_idx = PageIndex.Register
    if self.ctrl:HasMentorInfo() then
        page_idx = self.ctrl:IsMentor() and PageIndex.Mentor or PageIndex.Prentice
    end
    if self.page_idx ~= page_idx then
        self.ctrl_page:SetSelectedIndexEx(page_idx)
    end
end

return MentorView
