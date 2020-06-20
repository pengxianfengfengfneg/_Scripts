local MentorOptionView = Class(game.BaseView)

local words_list = string.split(config.words[6426], "|")

local OptionConfig = {
    --出师
    [1] = {
        words = words_list[1],
        click_func = function(info)
            local prentice_info = game.MentorCtrl.instance:GetPrenticeInfo(info.role_id)
            local data = {
                role_id = info.role_id,
                name = info.name,
                mark = prentice_info.mark,
                max_mark = game.MentorCtrl.instance:GetMaxStudyMark(),
            }
            game.MentorCtrl.instance:ShowMentorGraduateUI(data)
        end,
    },
    --逐出师门
    [2] = {
        words = words_list[2],
        click_func = function(info)
            game.MentorCtrl.instance:OpenDismissView(info.role_id)
        end,
    },
    --聊天
    [3] = {
        words = words_list[3],
        click_func = function(info)
            local chat_info = {
                id = info.role_id,
                name = info.name,
                lv = info.lv,
                career = info.career,
                svr_num = 1,
            }
            game.ChatCtrl.instance:OpenFriendChatView(chat_info)
        end,
    },
    --邀请组队
    [4] = {
        words = words_list[4],
        click_func = function(info)
            game.MakeTeamCtrl.instance:DoTeamInviteJoin(info.role_id)
        end,
    },
    --叛离师门
    [5] = {
        words = words_list[5],
        click_func = function()
            game.MentorCtrl.instance:ShowMentorSayGoodBuyUI()
        end,
    },
}

local OptionList = {
    --普通弟子
    [1] = {1, 2, 3, 4},

    --亲传弟子
    [2] = {2, 3, 4},

    --师父
    [3] = {5, 3, 4},

    --同门弟子
    [4] = {3, 4},
}

function MentorOptionView:_init(ctrl)
    self._package_name = "ui_mentor"
    self._com_name = "option_view"
    self.ctrl = ctrl

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.None
end

function MentorOptionView:OpenViewCallBack(info, global_pos)
    self:Init(info, global_pos)
end

function MentorOptionView:CloseViewCallBack()

end

function MentorOptionView:Init(info, global_pos)
    self.list_option = self._layout_objs["list_option"]
    local option_type = 0
    local mentor_info = self.ctrl:GetMentorInfo()

    if self.ctrl:IsMentor() then
        option_type = self.ctrl:GetMemberType(info.role_id)
    else       
        if info.role_id == mentor_info.mentor_id then
            option_type = 3
        else
            option_type = 4
        end
    end

    local option_list = OptionList[option_type]
    local item_num = option_list and #option_list or 0
    self.list_option:SetItemNum(item_num)
    self.list_option:ResizeToFit(item_num)

    for i=1, item_num do
        local btn = self.list_option:GetChildAt(i-1)
        local cfg = OptionConfig[option_list[i]]
        btn:SetText(cfg.words)
        btn:AddClickCallBack(function()
            cfg.click_func(info)
            self:Close()
        end)
    end

    self:GetRoot():AddClickCallBack(function()
        self:Close()
    end)

    local x, y = self:GetRoot():ToLocalPos(global_pos.x, global_pos.y)
    self._layout_objs["group"]:SetPositionY(y)
end

return MentorOptionView
