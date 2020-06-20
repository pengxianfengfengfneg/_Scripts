local HangSceneItem = Class(game.UITemplate)

local PageIndex = {
    YanWang = 0,
    QinHuang = 1,
    Other = 2,
}

function HangSceneItem:_init()
	self.ctrl = game.LakeExpCtrl.instance
end

function HangSceneItem:OpenViewCallBack()
    self:GetRoot():AddClickCallBack(handler(self, self.OnItemClick))
    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
end

function HangSceneItem:SetItemInfo(item_info, idx)
    self.item_info = item_info

    self._layout_objs["txt_exp"]:SetText(item_info.exp .. config.words[5413])
    self._layout_objs["img_bg"]:SetSprite("ui_lake_exp", item_info.icon)

    self:SetLevelText(item_info.monster_lv)
    self:SetSceneType(idx)
    self:SetParams(config.kill_mon_exp_scene_info[item_info.scene_id].params)
end

function HangSceneItem:SetSceneType(type)
    local sprite = ""
    if type == 2 then
        sprite = "ll_02"
    elseif type == 3 then
        sprite = "ll_03"
    end
    self._layout_objs["img_type"]:SetSprite("ui_lake_exp", sprite)
    self._layout_objs["img_type"]:SetVisible(sprite ~= "")
end

function HangSceneItem:SetLevelText(monster_lv)
    local str = ""
    if #monster_lv == 1 or monster_lv[1] == monster_lv[2] then
        str = string.format(config.words[5412] .. "%d", monster_lv[1])
    else
        str = string.format(config.words[5412] .. "%d-%d", monster_lv[1], monster_lv[2])
    end
    self._layout_objs["txt_level"]:SetText(str)
end

function HangSceneItem:SetParams(params)
    local index = PageIndex.Other
    
    local package = "ui_lake_exp"
    local default_bg = "ll_10"

    if params[1] == 1 then
        index = PageIndex.YanWang
        self._layout_objs["img_param1"]:SetSprite(package, "g_"..params[2], true)
    elseif params[1] == 2 then
        index = PageIndex.QinHuang
        self._layout_objs["img_param2"]:SetSprite(package, "q_"..params[2], true)
    elseif params[1] == 3 then
        self._layout_objs["img_name"]:SetSprite(package, params[2], true)
    else
        self._layout_objs["img_bg"]:SetSprite(package, default_bg)
    end

    self.ctrl_page:SetSelectedIndexEx(index)
end

function HangSceneItem:OnItemClick()
    if self.item_info then
        local scene_id = self.item_info.scene_id
        local hang_pos = self.item_info.hang_pos

        local cur_scene = game.Scene.instance
        local main_role = cur_scene and cur_scene:GetMainRole()
        if not main_role then
            return
        end

        local pos = self.ctrl:GetNextHangPos(scene_id, hang_pos)
        local tar_x, tar_y = game.LogicToUnitPos(pos.x, pos.y)

        if cur_scene:GetSceneID() == scene_id or cur_scene:GetSceneLogic():CanChangeScene(scene_id, true) then

            if game.MakeTeamCtrl.instance:IsSelfLeader() then
                game.MakeTeamCtrl.instance:SendTeamFollow(1)

                main_role:GetOperateMgr():DoGoToScenePos(scene_id, tar_x, tar_y, function()
                    game.MakeTeamCtrl.instance:SendTeamFollow(0)
                    game.MakeTeamCtrl.instance:SendTeamCommand(game.MakeTeamCommand.LakeExp)
                end)
            else
                main_role:GetOperateMgr():DoGoToScenePos(scene_id, tar_x, tar_y, function()
                    self:DoSceneHang()
                end)
            end
            self.ctrl:CloseView()
        end

        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_lake_exp/lake_exp_view/list_page/item3"})
    end
end

function HangSceneItem:DoSceneHang()
    local scene = game.Scene.instance
    local main_role = scene and scene:GetMainRole()
    if main_role then
        main_role:GetOperateMgr():DoSceneHang()
    end
end

return HangSceneItem