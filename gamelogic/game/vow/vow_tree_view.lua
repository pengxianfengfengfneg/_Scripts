local VowTreeView = Class(game.BaseView)

function VowTreeView:_init(ctrl)
    self._package_name = "ui_vow"
    self._com_name = "ui_vow_tree"
    self.ctrl = ctrl
    self.vow_data = self.ctrl:GetData()
end

function VowTreeView:_delete()
end

function VowTreeView:OpenViewCallBack()
	self.ctrl:CsVowPanelInfo()

	self:BindEvent(game.VowEvent.UpdatgeVowInfo, function(is_my_like)
        self:InitView(is_my_like)
    end)

    --许愿
    self._layout_objs["n46"]:AddClickCallBack(function()
        self.ctrl:OpenVowSendView()
    end)

    --刷新
    self._layout_objs["n45"]:AddClickCallBack(function()
        self.ctrl:CsVowRefresh()
    end)

    --三生树
    self._layout_objs["n44"]:AddClickCallBack(function()

        local npc_id = 45
        game.Scene.instance:GetMainRole():GetOperateMgr():DoGoToNpc(npc_id, function()
            local npc = game.Scene.instance:GetNpc(npc_id)
            npc:ShowTalk()
        end)

        self:Close()
    end)

    self._layout_objs["btn_close"]:AddClickCallBack(function()
        self:Close()
    end)

    for i = 1, 4 do
        self._layout_objs["bg"..i]:SetTouchDisabled(false)
        self._layout_objs["bg"..i]:AddClickCallBack(function()
            self:OnClickOtherVow(i)
        end)
    end

    local match_type = self.ctrl:GetMatchType()
    self._layout_objs.btn_checkbox:SetSelected(match_type)
    self._layout_objs.btn_checkbox:AddClickCallBack(function()
        if self._layout_objs.btn_checkbox:GetSelected() then
            local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[6161])
            msg_box:SetOkBtn(function()
                self.ctrl:SetMatchType(true)
                msg_box:DeleteMe()
            end)
            msg_box:SetCancelBtn(function()
                self._layout_objs.btn_checkbox:SetSelected(false)
                msg_box:DeleteMe()
            end)
            msg_box:Open()
        else
            self.ctrl:SetMatchType(false)
        end
    end)

    self._layout_objs.btn_checkbox2:SetSelected(false)
    self._layout_objs.btn_checkbox2:AddClickCallBack(function()
        if self._layout_objs.btn_checkbox2:GetSelected() then
            self.ctrl:CsVowMyLike()
        else
            self.ctrl:CsVowPanelInfo()
        end
    end)
end

function VowTreeView:InitView(is_my_like)
	local vow_list = self.vow_data:GetVowList()
    local all_vow_data = self.vow_data:GetVowInfo()
    local exist = false

    for i = 1, 4 do
        local single_vow_data = vow_list[i]
        if single_vow_data then
            
            exist = true

            self._layout_objs["role_name"..i]:SetText(single_vow_data.name)

            if single_vow_data.like_num > 0 then
                self._layout_objs["heart_num"..i]:SetText(single_vow_data.like_num)
            else
                self._layout_objs["heart_num"..i]:SetText("")
            end

            self:SetVowMess(i, single_vow_data.context)

            self._layout_objs["info"..i]:SetVisible(true)
        else
            self._layout_objs["info"..i]:SetVisible(false)
        end
    end

    if is_my_like then
        self._layout_objs["tips"]:SetText(config.words[6165])
    else
        self._layout_objs["tips"]:SetText(config.words[6164])
    end
    self._layout_objs["tips"]:SetVisible(not exist)

    self._layout_objs["times"]:SetText(tostring(5-all_vow_data.refresh_times).."/5")
end

function VowTreeView:SetVowMess(index, mess_str)

    local str_len = string.len(mess_str)
    local str1 = mess_str
    local str2 = ""
    if str_len > 13*3 then
        str1 = game.Utils.SubStringUTF8(mess_str, 1, 13)
        str2 = game.Utils.SubStringUTF8(mess_str, 14, 26)
    end

    self._layout_objs["mess_"..index.."_1"]:SetText(str1)
    if str2 == "" then
        self._layout_objs["mess_"..index.."_2"]:SetText("")
    else
        self._layout_objs["mess_"..index.."_2"]:SetText(str2)
    end
end

function VowTreeView:OnClickOtherVow(index)
    local vow_list = self.vow_data:GetVowList()
    local single_vow_data = vow_list[index]
    if single_vow_data then
        self.ctrl:OpenVowRecvView(single_vow_data)
    end
end

return VowTreeView