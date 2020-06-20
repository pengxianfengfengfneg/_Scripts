local RoleInfoView = Class(game.BaseView)

local handler = handler

function RoleInfoView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "role_info_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
end

function RoleInfoView:OpenViewCallBack(info)
    self.role_info = info or self.ctrl:GetRoleInfo()

    self:InitInfos()
    self:InitBg()
    self:InitBtns()
    self:InitModel()

    self:RegisterAllEvents()
end

function RoleInfoView:CloseViewCallBack()
    if self.role_model then
        self.role_model:DeleteMe()
        self.role_model = nil
    end
end

function RoleInfoView:RegisterAllEvents()
    if self:IsSelf() then
        local events = {
            {game.RoleEvent.UpdateMainRoleInfo, handler(self, self.OnUpdateMainRoleInfo)}
        }
        for _,v in ipairs(events) do
            self:BindEvent(v[1], v[2])
        end
    end
end

function RoleInfoView:InitInfos()
    self.txt_fight = self._layout_objs["role_fight_com/txt_fight"]

    local txt_name = self._layout_objs["txt_name"]
    local txt_career = self._layout_objs["txt_career"]
    local txt_atk_type = self._layout_objs["txt_atk_type"]
    local txt_guild = self._layout_objs["txt_guild"]
    local txt_lover = self._layout_objs["txt_lover"]
    local txt_title = self._layout_objs["txt_title"]

    self.txt_fight:SetText(self.role_info.combat_power or 0)

    txt_name:SetText(self.role_info.name or "")
    txt_career:SetText(game_help.GetCareerName(self.role_info.career))
    txt_atk_type:SetText(game_help.GetCareerAtkName(self.role_info.career))
    txt_guild:SetText(game.GuildCtrl.instance:GetGuildName() or "")
    txt_lover:SetText(self.role_info.lover_name or "")
    txt_title:SetText(game_help.GetTileName(self.role_info.title_id))

    self:InitDesc()

    if game.IsZhuanJia then
        self._layout_objs["n42"]:SetVisible(false)
        txt_lover:SetVisible(false)

        self._layout_objs["n40"]:SetText("等级")
        txt_title:SetText(self.role_info.level or 1)
    end
end

function RoleInfoView:InitBtns()
    local btn_setting = self._layout_objs["btn_setting"]
    btn_setting:AddClickCallBack(function()
        game.SysSettingCtrl.instance:OpenView()
    end)

    local btn_modify_name = self._layout_objs["btn_modify_name"]
    btn_modify_name:AddClickCallBack(function()
        --self.ctrl:OpenModifyNameView()
    end)

    local btn_private_chat = self._layout_objs["btn_private_chat"]
    btn_private_chat:AddClickCallBack(function()
        --game.ChatCtrl.instance:OpenView()
    end)

    local btn_add_friend = self._layout_objs["btn_add_friend"]
    btn_add_friend:AddClickCallBack(function()
        --game.FriendCtrl.instance:OpenView()
    end)

    local btn_invite_guild = self._layout_objs["btn_invite_guild"]
    btn_invite_guild:AddClickCallBack(function()
        game.GuildCtrl.instance:SendInviteJoinGuild(self.role_info.id)
    end)

    --拉黑按钮
    local btn_add_child = self._layout_objs["btn_add_child"]
    btn_add_child:AddClickCallBack(function()
        game.FriendCtrl.instance:FriendAddBlackReq(self.role_info.id)
    end)

    local btn_look = self._layout_objs["role_fight_com/btn_look"]
    btn_look:AddClickCallBack(function()
        
    end)

    local is_self = self:IsSelf()

    self.self_btns = {
        btn_setting,
        btn_modify_name,
    }

    self.other_btns = {
        btn_private_chat,
        btn_add_friend,
        btn_invite_guild,
        btn_add_child,
    }

    for _,v in ipairs(self.self_btns) do
        v:SetVisible(is_self)
    end

    for _,v in ipairs(self.other_btns) do
        v:SetVisible(not is_self)
    end

    if game.IsZhuanJia then
        btn_setting:SetPosition(360-73, 1095)
        btn_modify_name:SetVisible(false)
        
        btn_look:SetVisible(false)
        btn_invite_guild:SetVisible(false)
    end
end

function RoleInfoView:InitModel()
    if self.role_model then return end

    local model_list = {
        [game.ModelType.Body]    = 110101,
        [game.ModelType.Wing]    = 101,
        [game.ModelType.Hair]    = 11001,
        [game.ModelType.Weapon]    = 1001,
    }

    for k,v in pairs(model_list) do
        local id = game_help.GetModelID(k, self.role_info)
        model_list[k] = (id>0 and id or v)
    end

    self.role_model = require("game/character/model_template").New()
    self.role_model:CreateModel(self._layout_objs["wrapper"], game.BodyType.Role, model_list)

    self.role_model:SetModelChangeCallBack(function(model_type)
        if model_type == game.ModelType.Wing then
            local growup_id = game.GrowupType.Wing
            local image_lv = 0
            local growups = self.role_info.growups
            for _,v in ipairs(growups or {}) do
                if v.id == growup_id then
                    image_lv = v.image
                    break
                end
            end

        end

        if model_type == game.ModelType.Hair then
            local color_hex = (self.role_info.hair&0x00ffffff)
            self.role_model:UpdateHairColorHex(color_hex)
        end
    end)

    self.role_model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.Body + game.ModelType.Wing + game.ModelType.Hair)
    self.role_model:SetPosition(0,-0.6,3.2)
    self.role_model:SetRotation(0,180,0)
    
end

function RoleInfoView:IsSelf()
    return self.ctrl:IsSelf(self.role_info)
end

function RoleInfoView:OnUpdateMainRoleInfo(data)
    self.txt_fight:SetText(data.combat_power or "")
end

function RoleInfoView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1653])
end

function RoleInfoView:OnEmptyClick()
    self:Close()
end

function RoleInfoView:InitDesc()
    local txt_desc = self._layout_objs["txt_desc"]

    local desc = self.role_info.desc or ""
    if desc ~= "" then
        txt_desc:SetText(desc)
    end

    local is_self = self:IsSelf()
    txt_desc:SetTouchEnable(is_self)

    txt_desc:AddFocusInCallback(function()
        self:OnInputEvent(game.TextInputType.FocusIn)
    end)

    txt_desc:AddFocusOutCallback(function()
        self:OnInputEvent(game.TextInputType.FocusOut)
    end)

    txt_desc:AddChangeCallback(function()
        self:OnInputEvent(game.TextInputType.Change)
    end)

    txt_desc:AddSubmitCallback(function()
        self:OnInputEvent(game.TextInputType.Submit)
    end)

    self.txt_desc = txt_desc
end

function RoleInfoView:OnInputEvent(event_type)
    if event_type == game.TextInputType.Submit or event_type == game.TextInputType.Change then    
        local input_text = self.txt_desc:GetText()

       if game.Utils.CheckMaskChatWords(input_text) then
            input_text = game.Utils.TranslateMaskWords(input_text)
        end

        self.txt_desc:SetText(input_text)
    end
end

return RoleInfoView
