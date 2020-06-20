local SwornView = Class(game.BaseView)

local PageIndex = {
    Sworn = 0,
    None = 1,
    Empty = 2,
}

function SwornView:_init(ctrl)
    self._package_name = "ui_sworn"
    self._com_name = "sworn_view"
    self.ctrl = ctrl

    self._show_money = true

    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
end

function SwornView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
    self.ctrl:SendSwornInfo()
end

function SwornView:RegisterAllEvents()
    local events = {
        {game.SwornEvent.UpdateSwornInfo, handler(self, self.UpdateSwornInfo)},
        {game.SwornEvent.OnSwornModifyEnounce, handler(self, self.SetNoticeText)},
        {game.SwornEvent.UpdateMemberList, handler(self, self.UpdateMemberList)},
        {game.SwornEvent.UpdateQuality, handler(self, self.UpdateSwornInfo)},
        {game.SwornEvent.UpdateSwornValue, handler(self, self.SetSwornValueInfo)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SwornView:Init()
    self.list_member = self:CreateList("list_member", "game/sworn/item/sworn_item")
    self.list_member:SetRefreshItemFunc(function(item, idx)
        local mem_info = self.member_list_data[idx]
        local item_info = mem_info and mem_info.mem
        item:SetItemInfo(item_info, idx)
    end)

    self.txt_name = self._layout_objs.txt_name
    self.txt_notice = self._layout_objs.txt_notice

    self.sworn_value_com = self._layout_objs.sworn_value_com
    self.txt_sworn_value = self.sworn_value_com:GetChild("txt_sworn_value")
    self.txt_exp = self.sworn_value_com:GetChild("txt_exp")

    self.btn_name = self._layout_objs.btn_name
    self.btn_name:AddClickCallBack(function()
        self.ctrl:OpenSwornTitleChangeView()
    end)

    self.btn_exp = self.sworn_value_com:GetChild("btn_exp")
    self.btn_exp:AddClickCallBack(function()
        self.ctrl:OpenSwornValueView()
    end)

    self.btn_notice = self._layout_objs.btn_notice
    self.btn_notice:AddClickCallBack(function()
        self.ctrl:OpenSwornNoticeView()
    end)

    self.btn_call = self._layout_objs.btn_call
    self.btn_call:AddClickCallBack(function()
        self.ctrl:SendSwornGatherMember()
    end)

    self.btn_change = self._layout_objs.btn_change
    self.btn_change:AddClickCallBack(function()
        self:TalkToNpc(config.sworn_base.npc2)
    end)

    self.btn_go = self._layout_objs.btn_go
    self.btn_go:AddClickCallBack(function()
        self:TalkToNpc(config.sworn_base.npc1)
    end)

    self.btn_platform = self._layout_objs.btn_platform
    self.btn_platform:AddClickCallBack(function()
        self.ctrl:OpenSwornPlatformView()
    end)

    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
    self.ctrl_page:SetSelectedIndexEx(self.ctrl:HaveSwornGroup() and PageIndex.Sworn or PageIndex.None)
end

function SwornView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6250])
end

function SwornView:UpdateMemberList(member_list_data)
    self.member_list_data = member_list_data or self.ctrl:GetSwornInfo().mem_list
    self.list_member:SetItemNum(config.sworn_base.num_limit)
end

function SwornView:UpdateSwornInfo()
    local have_group = self.ctrl:HaveSwornGroup()
    local page_idx = have_group and PageIndex.Sworn or PageIndex.None
    self.ctrl_page:SetSelectedIndexEx(page_idx)

    if have_group then
        local sworn_info = self.ctrl:GetSwornInfo()
        self.txt_name:SetText(string.format("[color=#%s]%s[/color]", self.ctrl:GetTitleColor(), sworn_info.group_name))
        
        self:UpdateMemberList(sworn_info.mem_list)
        self:SetNoticeText(sworn_info.enounce)
        self:SetSwornValueInfo(sworn_info.sworn_value)
    end
end

function SwornView:SetSwornValueInfo(sworn_value)
    self.txt_exp:SetText(string.format(config.words[6251], self.ctrl:GetExpAddValue()))
    self.txt_sworn_value:SetText(string.format(config.words[6299], sworn_value))
    self.sworn_value_com:SetPositionX(self:GetRoot().width * 0.5)
end

function SwornView:SetNoticeText(enounce)
    enounce = enounce or self.ctrl:GetSwornInfo().enounce
    self.txt_notice:SetText(enounce)
end

function SwornView:TalkToNpc(npc_id)
    local scene = game.Scene.instance
    local main_role = scene and scene:GetMainRole()
    if main_role then
        main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
    end
    self.ctrl:CloseHomeView()
    self:Close()
end

return SwornView
