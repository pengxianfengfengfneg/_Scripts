local GuildWineCommentView = Class(game.BaseView)

function GuildWineCommentView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_wine_comment_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildWineCommentView:_delete()
    
end

function GuildWineCommentView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
    self.ctrl:SendGuildWineActCommentInfo()
end

function GuildWineCommentView:CloseViewCallBack()

end

function GuildWineCommentView:Init()
    self._layout_objs["txt_info"]:SetText(config.words[4756])

    self.comment_item_good = self:GetTemplate("game/guild/item/guild_wine_comment_item", "comment_item_good")
    self.comment_item_bad = self:GetTemplate("game/guild/item/guild_wine_comment_item", "comment_item_bad")

    self.item_list = {}

    self.ctrl_state = self:GetRoot():GetController("ctrl_state")
    self.ctrl_state:SetSelectedIndex(0)
end

function GuildWineCommentView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[4747]):HideBtnBack()
end

function GuildWineCommentView:UpdateCommentInfo(comment_info)
    local dice_max_role = comment_info.dice_max_role
    local dice_min_role = comment_info.dice_min_role

    if dice_max_role.role_id == 0 or dice_min_role.role_id == 0 then
        self.ctrl_state:SetSelectedIndex(2)
        return
    else
        self.ctrl_state:SetSelectedIndex(1)
    end

    self.comment_item_good:SetItemInfo({
        name = dice_max_role.role_name,
        type = 1,
        dice_num = dice_max_role.dice_num,
        like_value = dice_max_role.like_num - dice_max_role.dislike_num,
        role_id = dice_max_role.role_id,
        career = dice_max_role.career,
    })
    table.insert(self.item_list, self.comment_item_good)

    self.comment_item_bad:SetItemInfo({
        name = dice_min_role.role_name,
        type = 2,
        dice_num = dice_min_role.dice_num,
        like_value = dice_min_role.like_num - dice_min_role.dislike_num,
        role_id = dice_min_role.role_id,
        career = dice_min_role.career,
    })
    table.insert(self.item_list, self.comment_item_bad)
end

function GuildWineCommentView:UpdateCommentRoleInfo(comment_role_info)
    for k, v in pairs(self.item_list or {}) do
        if v:GetRoleId() == comment_role_info.role_id then
            v:SetLikeValue(comment_role_info.like_num - comment_role_info.dislike_num)
        end
    end
end

function GuildWineCommentView:RegisterAllEvents()
    local events = {
        [game.GuildEvent.UpdateWineCommentInfo] = function(data)
            -- dice_max_role__U|GuildCommentRole|        -- 手气极好的玩家信息
            -- dice_min_role__U|GuildCommentRole|        -- 手气极差的玩家信息

            -- role_id__I							// 玩家ID
            -- role_name__s						// 玩家名
            -- career__C       					// 职业
            -- gender__C       					// 性别
            -- like_num__I							// 被点赞次数
            -- dislike_num__I						// 被点踩次数
            -- dice_num__C							// 骰子总点数
            -- reward_id__I						// 获得的奖励ID
            self:UpdateCommentInfo(data)
        end,
        [game.GuildEvent.UpdateWineCommentRoleInfo] = function(data)
            -- role_id__I                            -- 玩家ID
            -- like_num__I                           -- 被点赞次数
            -- dislike_num__I                        -- 被点踩次数
            self:UpdateCommentRoleInfo(data)
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return GuildWineCommentView
