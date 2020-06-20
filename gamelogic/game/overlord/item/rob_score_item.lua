local RobScoreItem = Class(game.UITemplate)

function RobScoreItem:OpenViewCallBack(info)
    self._layout_objs.btn:AddClickCallBack(function()
        if game.IsZhuanJia then
            local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[5050])
            msg_box:SetOkBtn(function()
                game.OverlordCtrl.instance:SendEnterRob(self.info.id)
                msg_box:Close()
                msg_box:DeleteMe()
            end)
            msg_box:Open()
        else
            game.OverlordCtrl.instance:SendEnterRob(self.info.id)
        end
    end)
end

function RobScoreItem:SetItemInfo(info)
    self.info = info
    self._layout_objs.rank:SetText(info.rank)
    self._layout_objs.name:SetText(info.name)
    self._layout_objs.score:SetText(info.score)
    self._layout_objs.career:SetText(config.career_init[info.career].name)

    local role_id = game.RoleCtrl.instance:GetRoleId()
    local text = config.words[4606]
    if role_id == info.id then
        text = config.words[4605]
    elseif game.GuildCtrl.instance:GetGuildMemberInfo(info.id) ~= nil then
        text = config.words[4607]
    end
    self._layout_objs.relation:SetText(text)
end

return RobScoreItem