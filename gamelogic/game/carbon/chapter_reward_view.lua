local ChapterRewardView = Class(game.BaseView)

function ChapterRewardView:_init(ctrl)
    self._package_name = "ui_carbon"
    self._com_name = "chapter_reward_view"
    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
    self.ctrl = ctrl
end

function ChapterRewardView:OpenViewCallBack(dun_id, chapter, star)
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1416])

    self._layout_objs.btn_get:AddClickCallBack(function()
        self.ctrl:SendGetChapterRwd(dun_id, chapter, star)
        self:Close()
    end)

    self.list = game.UIList.New(self._layout_objs.list_reward)
    self.list:SetCreateItemFunc(function(obj)
        local item = require("game/bag/item/goods_item").New()
        item:SetVirtual(obj)
        item:Open()
        return item
    end)
    self.list:SetRefreshItemFunc(function(item, idx)
        local info = self.chapter_reward[idx]
        item:SetItemInfo({ id = info[1], num = info[2] })
        item:SetShowTipsEnable(true)
    end)
    self.list:SetVirtual(false)

    local carbon_data = self.ctrl:GetData()
    local dun_data = carbon_data:GetDungeDataByID(dun_id)
    local chapter_cfg = config.dungeon_chapter[dun_id][chapter]
    for i, v in pairs(chapter_cfg) do
        if v.star == star then
            self.chapter_reward = config.drop[v.reward].client_goods_list
            break
        end
    end
    self.list:SetItemNum(#self.chapter_reward)

    local total = 0
    for i, v in pairs(dun_data.star_info) do
        if config.dungeon_lv[dun_id][v.lv].chapter == chapter then
            total = total + v.star
        end
    end

    local got = true
    for k, v in pairs(dun_data.chapter_reward) do
        if v.id == chapter and v.star == star then
            got = false
        end
    end

    self._layout_objs.btn_get:SetVisible(total >= star and got)
end

function ChapterRewardView:CloseViewCallBack()
    self.list:DeleteMe()
end

function ChapterRewardView:OnEmptyClick()
    self:Close()
end

return ChapterRewardView