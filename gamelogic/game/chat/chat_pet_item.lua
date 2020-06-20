local ChatPetItem = Class(game.UITemplate)

function ChatPetItem:_init()

end

function ChatPetItem:OpenViewCallBack()
	self:Init()
end

function ChatPetItem:CloseViewCallBack()
    
end

function ChatPetItem:Init()
    self.pet_icon = self:GetTemplate("game/pet/item/pet_icon_item", "pet_item")

    self.txt_name = self._layout_objs["txt_name"]
    self.txt_fight = self._layout_objs["txt_fight"]

    self:GetRoot():AddClickCallBack(function()
        if self.click_event then
            self.click_event(self)
        end
    end)
end

function ChatPetItem:SetItemInfo(info)
    self.item_info = info

    self.pet_icon:SetItemInfo(info)

    self.txt_name:SetText(info.name)
    self.txt_fight:SetText(string.format(config.words[1327], self:CalcFight(info)))
end

function ChatPetItem:GetItemInfo()
    return self.item_info
end

function ChatPetItem:CalcFight(info)
    return game.PetCtrl.instance:CalcFight(info)
end

function ChatPetItem:AddClickEvent(click_event)
    self.click_event = click_event
end

return ChatPetItem
