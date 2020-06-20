local FireworkTipsView = Class(game.BaseView)

local _et = {}
local handler = handler

function FireworkTipsView:_init(ctrl)
    self._package_name = "ui_firework"
    self._com_name = "firework_tips_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
end

function FireworkTipsView:OpenViewCallBack(item_id)
    self:Init(item_id)
    self:InitBg()
    self:InitList()

    self:RegisterAllEvents()
end

function FireworkTipsView:CloseViewCallBack()
    
end

function FireworkTipsView:RegisterAllEvents()
    local events = {
        {game.FireworkEvent.OnFireworkUse, handler(self,self.OnFireworkUse)}
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1],v[2])
    end
end

function FireworkTipsView:Init(item_id)
    self.item_id = item_id

    self.txt_tips = self._layout_objs["txt_tips"]

    local item_cfg = config.goods[self.item_id]
    if item_cfg then
        local color_string = game.ItemColor[item_cfg.color]
        local tips = string.format(config.words[6451], color_string, item_cfg.name)
        self.txt_tips:SetText(tips)
    end

    self.btn_ok = self._layout_objs["btn_ok"]
    self.btn_ok:AddClickCallBack(function()
        if self.cur_item then
            self.ctrl:SendFireworkUse(self.item_id, self.cur_item:GetRoleId())
        else
            game.GameMsgCtrl.instance:PushMsg(config.words[6452])
        end
    end)

end

function FireworkTipsView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6450])
end

function FireworkTipsView:InitList()
    self.ui_list = self:CreateList("list_item", "game/firework/firework_tips_item", true)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetData(idx)
        item:UpdateData(data)
    end)

    self.ui_list:AddClickItemCallback(function(item)
        self:OnClickItem(item)
    end)

    self:UpdateList()
end

function FireworkTipsView:OnClickItem(item)
    self.cur_item = item

end

function FireworkTipsView:GetData(idx)
    return self.friend_info[idx]
end

function FireworkTipsView:UpdateList()
    local friend_data = game.FriendCtrl.instance:GetData()
    local friend_list = friend_data:GetFriendList()
    self.friend_info = {}
    for _,v in ipairs(friend_list or _et) do
        local info = friend_data:GetRoleInfoById(v.roleId)
        if info and info.unit.offline==0 then
            table.insert(self.friend_info, info.unit)
        end
    end

    local item_num = #self.friend_info
    self.ui_list:SetItemNum(item_num)

    if item_num > 0 then
        local item = self.ui_list:GetItemByIdx(0)
        if item then
            self.ui_list:AddSelection(0,true)
            self:OnClickItem(item)
        end
    end
end

function FireworkTipsView:OnFireworkUse(target_id, is_succ)
    if is_succ then
        if self.cur_item then
            local role_id = self.cur_item:GetRoleId()
            if role_id == target_id then
                self:Close()
                game.BagCtrl.instance:CloseView()
            end
        end
    else
        self:UpdateList()
    end
end

function FireworkTipsView:OnEmptyClick()
    self:Close()
end

return FireworkTipsView
