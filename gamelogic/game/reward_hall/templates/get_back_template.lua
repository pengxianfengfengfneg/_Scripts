local GetBackTemplate = Class(game.UITemplate)

function GetBackTemplate:_init()
    self._package_name = "ui_reward_hall"
    self._com_name = "get_back_template"
end

function GetBackTemplate:OpenViewCallBack()
    self:BindEvent(game.RewardHallEvent.UpdateGetBackInfo, function()
        self:UpdateList()
    end)
    self:InitGetBack()
    self:UpdateList()
end

function GetBackTemplate:InitGetBack()
    self.list = self:CreateList("list", "game/reward_hall/item/get_back_item")
    self.list:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo(self.info[idx])
        item:SetBG(idx % 2 == 1)
    end)
end

function GetBackTemplate:UpdateList()
    local info = game.RewardHallCtrl.instance:GetGetBackInfo()
    if info == nil then
        return
    end
    table.sort(info, function(a, b)
        if a.times ~= b.times then
            if a.times == 0 then
                return false
            elseif b.times == 0 then
                return true
            else
                return a.id < b.id
            end
        else
            return a.id < b.id
        end
    end)
    self.info = info
    self.list:SetItemNum(#info)
end

return GetBackTemplate