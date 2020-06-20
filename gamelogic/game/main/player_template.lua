local PlayerTemplate = Class(game.UITemplate)

function PlayerTemplate:_init(ctrl)

end

function PlayerTemplate:OpenViewCallBack()
    self._layout_objs["ko_btn"]:AddClickCallBack(function()
        if self.role_id then
            game.Scene.instance:SendDeclearWarReq(self.role_id)
        end
        game.MainUICtrl.instance:CloseOtherPlayerView()
    end)
end

function PlayerTemplate:CloseViewCallBack()

end

function PlayerTemplate:SetData(idx, data)
    self.role_id = data.id
    self._layout_objs["bg1"]:SetVisible(idx % 2 == 1)
    self._layout_objs["bg2"]:SetVisible(idx % 2 == 0)
    self._layout_objs["lv_txt"]:SetText(data.lv)
    self._layout_objs["name_txt"]:SetText(data.name)
    self._layout_objs["career_img"]:SetSprite("ui_common", "career" .. data.career)
    self._layout_objs["head_img"]:SetSprite("ui_common", "head" .. data.career)
    self._layout_objs["relation_txt"]:SetText(data.relation)
    if data.guild_name == "" then
        self._layout_objs["guild_txt"]:SetText("")
    else
        self._layout_objs["guild_txt"]:SetText(string.format("<%s>", data.guild_name))
    end

    self._layout_objs["ko_btn"]:SetVisible(not data.is_rival)
end

function PlayerTemplate:OnClick()
    if self.role_id then
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then
            local obj = game.Scene.instance:GetObjByUniqID(self.role_id)
            if obj then
                main_role:SelectTarget(obj)
            end
        end
    end
    game.MainUICtrl.instance:CloseOtherPlayerView()
end

return PlayerTemplate
