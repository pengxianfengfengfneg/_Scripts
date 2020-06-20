local OperateList = Class(game.BaseView)

function OperateList:_init()
    self._package_name = "ui_view_others"
    self._com_name = "operate_list"

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Fouth

end

function OperateList:OpenViewCallBack(role_info)
    self.role_info = role_info
    self.info = role_info.info
    self:GetRoot():AddClickCallBack(function()
        self:Close()
    end)


    local func_list = {
        [1] = {
            name = config.words[3320],
            func = function()
                game.ViewOthersCtrl.instance:OpenViewOthers(self.role_info)
            end,
        },
        [2] = {
            name = config.words[3321],
            func = function()
                game.MakeTeamCtrl.instance:DoTeamInviteJoin(self.info.id)
            end,
        },
        [3] = {
            name = config.words[3322],
            func = function()
                game.GuildCtrl.instance:SendInviteJoinGuild(self.info.id)
            end,
        },
        [4] = {
            name = config.words[3323],
            func = function()
                game.ChatCtrl.instance:CloseView()
                game.ChatCtrl.instance:CloseFriendChatView()
                
                game.ChatCtrl.instance:OpenFriendChatView({
                    id = self.info.id,
                    name = self.info.name,
                    lv = self.info.level,
                    career = self.info.career,
                    svr_num = self.info.server_num,
                })
            end,
        },
        [5] = {
            name = config.words[3324],
            func = function()
                game.Scene.instance:SendDeclearWarReq(self.info.id)
            end,
        },
        [6] = {
            name = config.words[3325],
            func = function()
                game.FriendCtrl.instance:CsFriendSysApplyAdd(self.info.id)
            end,
        },
        [7] = {
            name = config.words[3326],
            func = function()
                game.FriendCtrl.instance:CsFriendSysBanRole(self.info.id)
            end,
        },
    }

    self._layout_objs.list:SetItemNum(#func_list)
    for i = 1, #func_list do
        local item = self._layout_objs.list:GetChildAt(i - 1)
        item:SetText(func_list[i].name)
        item:AddClickCallBack(function()
            func_list[i].func()
        end)
    end

    self._layout_objs.name:SetText(self.info.name)
    if self.info.guild_name == "" then
        self._layout_objs.guild:SetText(config.words[1552])
    else
        self._layout_objs.guild:SetText(self.info.guild_name)
    end
    self._layout_objs.relation:SetText(config.words[self.info.stat + 3310])
    self._layout_objs.team:SetText(self.info.team_num .. "/5")
    if config.scene[self.info.scene_id] then
        self._layout_objs.scene:SetText(config.scene[self.info.scene_id].name)
    else
        self._layout_objs.scene:SetText(config.words[3327])
    end

    local head_icon = self:GetIconTemplate("head_icon")
    head_icon:UpdateData({icon = self.info.icon, frame = self.info.frame})
end

function OperateList:CloseViewCallBack()
    self._layout_objs.list:SetItemNum(0)
end

return OperateList
