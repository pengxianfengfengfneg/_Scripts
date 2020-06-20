local PlayActionView = Class(game.BaseView)

function PlayActionView:_init()
    self._package_name = "ui_main"
    self._com_name = "play_action_view"

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone

end

function PlayActionView:OpenViewCallBack()
    self._layout_objs.n2:SetTouchDisabled(false)
    self._layout_objs.touch:AddClickCallBack(function()
        self:Close()
    end)

    self:SetActionList()
    self:SetNearPlayerList()
end

function PlayActionView:CloseViewCallBack()
    self.cur_couple_action = nil
end

function PlayActionView:SetActionList()
    local single_list = self:CreateList("single_list", "game/main/action_item")
    local single_actions = {}
    local couple_actions = {}
    for _, v in pairs(config.exterior_action) do
        if v.type == 1 then
            table.insert(single_actions, v)
        else
            table.insert(couple_actions, v)
        end
    end
    table.sort(single_actions, function(a, b)
        local a_state = game.ExteriorCtrl.instance:GetActionState(a.id)
        local b_state = game.ExteriorCtrl.instance:GetActionState(b.id)
        if a_state == b_state then
            return a.id < b.id
        else
            return a_state
        end
    end)
    single_list:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo(single_actions[idx])
    end)
    single_list:AddClickItemCallback(function(item)
        if not game.Scene.instance:GetMainRole():CanPlayAction(true) then
            return
        end
        local item_info = item:GetItemInfo()
        local state = game.ExteriorCtrl.instance:GetActionState(item_info.id)
        if state then
            local time = game.ExteriorCtrl.instance:GetActionSingleTime()
            if global.Time:GetServerTime() > time then
                game.ExteriorCtrl.instance:SendActionUse(0, item_info.id)
            else
                game.GameMsgCtrl.instance:PushMsg(config.ret_code[253])
            end
        end
    end)
    single_list:SetItemNum(#single_actions)

    local couple_list = self:CreateList("couple_list", "game/main/action_item")
    table.sort(couple_actions, function(a, b)
        local a_state = game.ExteriorCtrl.instance:GetActionState(a.id)
        local b_state = game.ExteriorCtrl.instance:GetActionState(b.id)
        if a_state == b_state then
            return a.id < b.id
        else
            return a_state
        end
    end)
    couple_list:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo(couple_actions[idx])
    end)
    couple_list:AddClickItemCallback(function(item)
        if not game.Scene.instance:GetMainRole():CanPlayAction(true) then
            return
        end
        local item_info = item:GetItemInfo()
        local state = game.ExteriorCtrl.instance:GetActionState(item_info.id)
        self._layout_objs.n13:SetVisible(state)
        if state then
            self.cur_couple_action = item_info.id
            couple_list:Foreach(function(obj)
                local info = obj:GetItemInfo()
                obj:SetSelect(state and info.id == self.cur_couple_action)
            end)
        end
    end)
    couple_list:SetItemNum(#couple_actions)
    if couple_actions[1] then
        local state = game.ExteriorCtrl.instance:GetActionState(couple_actions[1].id)
        if state then
            self.cur_couple_action = couple_actions[1].id
            couple_list:Foreach(function(obj)
                local info = obj:GetItemInfo()
                obj:SetSelect(state and info.id == self.cur_couple_action)
            end)
        end
    end
end

function PlayActionView:SetNearPlayerList()
    local near_list = {}
    local func = function(target, obj)
        if target.obj_type == game.ObjType.Role and obj:GetLogicDistSq(target:GetLogicPosXY()) <= 100 then
            table.insert(near_list, target)
        end
    end
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        main_role:ForeachAoiObj(func)
    end
    self._layout_objs.tips:SetVisible(#near_list == 0)

    self._layout_objs.player_list:SetItemNum(#near_list)
    for i = 0, #near_list - 1 do
        local player = self._layout_objs.player_list:GetChildAt(i)
        player:SetText(near_list[i + 1]:GetName())
        player:AddClickCallBack(function()
            local time = game.ExteriorCtrl.instance:GetActionCoupleTime()
            if self.cur_couple_action then
                if global.Time:GetServerTime() > time then
                    game.ExteriorCtrl.instance:SendActionUse(near_list[i + 1]:GetUniqueId(), self.cur_couple_action)
                else
                    game.GameMsgCtrl.instance:PushMsg(config.ret_code[253])
                end
            end
        end)
    end
end

return PlayActionView
