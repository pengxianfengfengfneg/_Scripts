local GuildTaskItem = Class(game.UITemplate)

function GuildTaskItem:_init()
    self.ctrl = game.DailyTaskCtrl.instance
end

function GuildTaskItem:OpenViewCallBack()
	self:Init()
end

function GuildTaskItem:CloseViewCallBack()
    
end

function GuildTaskItem:Init()
    self.txt_name = self._layout_objs["txt_name"]
    self.txt_reward = self._layout_objs["txt_reward"]
    self.txt_multiply = self._layout_objs["txt_multiply"]

    self.txt_reward:SetText(config.words[5114])

    self.bar_progress = self._layout_objs["bar_progress"]
    self.txt_progress = self.bar_progress:GetChild("title")
    
    self.btn_get = self._layout_objs["btn_get"]
    self.btn_get:SetText(config.words[5113])
    self.btn_get:AddClickCallBack(function()
        if self.type then
            self.ctrl:SendGuildTaskGet(self.type)
        end
    end)

    self.list_star = self._layout_objs["list_star"]

    self.img_bg = self._layout_objs["img_bg"]
    self.img_bg2 = self._layout_objs["img_bg2"]
end

function GuildTaskItem:SetItemInfo(item_info, idx)
    self.type = item_info.type
    self.txt_name:SetText(item_info.name)
    self.txt_multiply:SetText("x" .. item_info.multiply)

    self.bar_progress:SetProgressValue(math.min(100, item_info.cur_times / item_info.total_times * 100))
    self.txt_progress:SetText(item_info.cur_times .. "/" .. item_info.total_times)

    self.list_star:SetItemNum(item_info.star)
    self.list_star:ResizeToFit(item_info.star)

    self.img_bg:SetVisible(idx % 2 == 1)
    self.img_bg2:SetVisible(idx % 2 == 0)
end

return GuildTaskItem
