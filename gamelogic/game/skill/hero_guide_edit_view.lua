local HeroGuideEditView = Class(game.BaseView)

function HeroGuideEditView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "hero_guide_edit_view"

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function HeroGuideEditView:OpenViewCallBack(name, desc)
    self:Init(name, desc)
    self:InitBg()
    self:InitBtns() 

    self:RegisterAllEvents()
end

function HeroGuideEditView:CloseViewCallBack()
    
end

function HeroGuideEditView:RegisterAllEvents()
    local events = {
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function HeroGuideEditView:OnEmptyClick()
    self:Close()
end

function HeroGuideEditView:Init(name, desc)
    self.input_guide_name = self._layout_objs["input_guide_name"]
    self.input_guide_desc = self._layout_objs["input_guide_desc"]

    self.input_guide_name:SetText(name)
    self.input_guide_desc:SetText(desc)
end

function HeroGuideEditView:InitBtns()
    self.btn_ok = self._layout_objs["btn_ok"]
    self.btn_ok:AddClickCallBack(function()
        local name = self.input_guide_name:GetText()
        local desc = self.input_guide_desc:GetText()
        self:FireEvent(game.HeroEvent.HeroGuideEdit, name, desc)
        self:Close()
    end)

    self.btn_cancle = self._layout_objs["btn_cancle"]
    self.btn_cancle:AddClickCallBack(function()
        self:Close()
    end)
end

function HeroGuideEditView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1667]):HideBtnBack()
end

return HeroGuideEditView
