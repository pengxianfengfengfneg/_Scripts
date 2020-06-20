local SeniorVoteItem = Class(game.UITemplate)

function SeniorVoteItem:_init(ctrl)
    self.ctrl = game.SwornCtrl.instance
end

function SeniorVoteItem:OpenViewCallBack()
    self.img_icon = self._layout_objs.img_icon
    self.txt_name = self._layout_objs.txt_name
    self.txt_votes = self._layout_objs.txt_votes

    self.img_bg = self._layout_objs.img_bg
    self.img_bg2 = self._layout_objs.img_bg2
    self.head_icon = self:GetIconTemplate("head_icon")

    self.btn_vote = self._layout_objs.btn_vote
    self.btn_vote:AddClickCallBack(function()
        if self.click_event then
            if self.info then
                self.click_event(self.info.role_id)
            end
        end
    end)
end

function SeniorVoteItem:SetItemInfo(item_info, idx)
    self.info = item_info

    self.txt_name:SetText(item_info.name)
    self.txt_votes:SetText(string.format(config.words[6269], item_info.votes))

    self.head_icon:UpdateData(item_info)

    self:SetVoteEnable(true)

    self.img_bg:SetVisible(idx%2==1)
    self.img_bg2:SetVisible(idx%2==0)
end

function SeniorVoteItem:SetVoteEnable(val)
    self.btn_vote:SetEnable(val)
end

function SeniorVoteItem:AddClickEvent(click_event)
    self.click_event = click_event
end

return SeniorVoteItem