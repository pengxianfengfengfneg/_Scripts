local MemberItem = Class(game.UITemplate)

local PageIndex = {
    Member = 0,
    EmptyPrentice = 1,
}

function MemberItem:_init(ctrl)
    self.ctrl = game.MentorCtrl.instance
end

function MemberItem:OpenViewCallBack()
    self.head_icon = self:GetIconTemplate("head_icon")

    self.img_bg = self._layout_objs["img_bg"]
    self.img_bg2 = self._layout_objs["img_bg2"]
    self.img_career = self._layout_objs["img_career"]
    self.img_sel = self._layout_objs["img_sel"]

    self.txt_lv = self._layout_objs["txt_lv"]
    self.txt_name = self._layout_objs["txt_name"]
    self.txt_pos = self._layout_objs["txt_pos"]
    self.txt_senior = self._layout_objs["txt_senior"]
    self.txt_check = self._layout_objs["txt_check"]

    self.btn_practice = self._layout_objs["btn_practice"]
    self.btn_practice:AddClickCallBack(function()
        self:TalkToNpc(config.mentor_base.npc_id)
    end)

    self.btn_more = self._layout_objs["btn_more"]
    self.btn_more:AddClickCallBack(function()
        if self.info then
            local global_x, global_y = self:GetRoot():ToGlobalPos(0, 0)
            local global_pos = {x = global_x, y = global_y}
            self.ctrl:OpenOptionView(self.info, global_pos)
        end
    end)
    
    self.touch_com = self._layout_objs["touch_com"]
    self.touch_com:AddClickCallBack(function()
        if self.page_idx == PageIndex.EmptyPrentice then
            self.ctrl:OpenRegisterView(1)
        end
    end)

    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
end

function MemberItem:SetItemInfo(item_info, idx)
    self.info = item_info
    self.page_idx = PageIndex.Member
    if item_info then
        self.head_icon:UpdateData(item_info)
        self.img_career:SetSprite("ui_common", "career"..item_info.career)
        
        if self.ctrl:IsMentor() then
            self.txt_senior:SetText(self.ctrl:GetSeniorName(item_info.senior))
        else
            self.txt_senior:SetText(item_info.role_id == self.ctrl:GetMentorID() and self.ctrl:GetSeniorName(item_info.senior) or self.ctrl:GetSeniorName(item_info.senior, item_info.gender))
        end

        self.txt_lv:SetText(item_info.lv)
        self.txt_name:SetText(item_info.name)
        self.txt_pos:SetText(self:GetPos(item_info.offline_time, item_info.scene))

        local practice_visible = false
        if self.ctrl:IsMentor() then
            practice_visible = self.ctrl:GetMemberType(item_info.role_id)==2
        else
            practice_visible = item_info.role_id == self.ctrl:GetMentorID() and self.ctrl:GetMemberType(game.RoleCtrl.instance:GetRoleId())==2
        end
        self.btn_practice:SetVisible(practice_visible)
    else
        self.page_idx = PageIndex.EmptyPrentice
    end
    self.img_bg:SetVisible(idx%2==1)
    self.img_bg2:SetVisible(idx%2==0)
    
    self.ctrl_page:SetSelectedIndexEx(self.page_idx)
end

function MemberItem:GetPos(offline_time, scene_id)
    if offline_time == 0 then
        local scene_cfg = config.scene[scene_id]
        if scene_cfg then
            return scene_cfg.name
        end
    else
        local sec = global.Time:GetServerTime() - offline_time
        local time = math.floor(sec / 86400)
        local unit = config.words[107]
        if time == 0 then
            time = math.max(1, math.floor((sec % 86400) / 3600))
            unit = config.words[108]
        end
        return string.format(config.words[6423], time, unit)
    end
end

function MemberItem:TalkToNpc(npc_id)
    local scene = game.Scene.instance
    local main_role = scene and scene:GetMainRole()
    if main_role then
        main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
    end
    game.ViewMgr:CloseAllView()
end

function MemberItem:SetSelVisible(val)
    self.img_sel:SetVisible(val)
end

return MemberItem