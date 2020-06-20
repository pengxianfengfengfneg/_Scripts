local FeedbackView = Class(game.BaseView)

function FeedbackView:_init(ctrl)
    self._package_name = "ui_feedback"
    self._com_name = "feedback_view"

    self.ctrl = ctrl
end

function FeedbackView:OpenViewCallBack()
    self:Init()

    self:UpdateView()
end

function FeedbackView:Init()
    for i = 1, 5 do
        self._layout_objs["star_bg" .. i]:SetTouchDisabled(false)
        self._layout_objs["star_bg" .. i]:AddClickCallBack(function()
            self.star_num = i
            for j = 1, 5 do
                self._layout_objs["star" .. j]:SetVisible(j <= self.star_num)
            end
        end)
    end

    self.star_num = 5
    for j = 1, 5 do
        self._layout_objs["star" .. j]:SetVisible(j <= self.star_num)
    end

    self._layout_objs.btn:AddClickCallBack(function()
        local content = self._layout_objs.content:GetText()
        if game.Utils.CheckMaskWords(content) then
            game.GameMsgCtrl.instance:PushMsg(config.words[1005])
            return
        end
        game.FeedbackCtrl.instance:SendFeedbackCommit(self.star_num, content)
    end)

    self._layout_objs.content:AddChangeCallback(function()
        local words_num = self._layout_objs.content:GetTextlength()
        self._layout_objs.count:SetText(words_num .. "/100")
    end)
    self._layout_objs.content:SetText("")
    self._layout_objs.count:SetText("0/100")

    self:GetBgTemplate("common_bg"):SetTitleName(config.words[3270])

    local info = game.FeedbackCtrl.instance:GetFeedbackInfo()
    local cfg = config.feedback[info.id]
    self._layout_objs.title:SetText(cfg.title)
    self.list = self:CreateList("list", "game/bag/item/goods_item")
    local drop_list = config.drop[cfg.reward].client_goods_list
    self.list:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo({ id = drop_list[idx][1], num = drop_list[idx][2] })
        item:SetShowTipsEnable(true)
    end)
    self.list:SetItemNum(#drop_list)
end

function FeedbackView:UpdateView()
    local info = game.FeedbackCtrl.instance:GetFeedbackInfo()
    self._layout_objs.got_img:SetVisible(info.flag == 2)
end

function FeedbackView:OnEmptyClick()
    self:Close()
end

return FeedbackView
