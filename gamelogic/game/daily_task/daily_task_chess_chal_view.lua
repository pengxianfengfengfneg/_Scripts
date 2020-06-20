local DailyTaskChessChalView = Class(game.BaseView)

function DailyTaskChessChalView:_init(ctrl)
    self._package_name = "ui_daily_task"
    self._com_name = "daily_task_chess_chal_view"
    self.ctrl = ctrl
    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function DailyTaskChessChalView:_delete()

end

function DailyTaskChessChalView:OpenViewCallBack(chess_data, dung_id)
    self:Init(chess_data, dung_id)
    self:InitBg()
    self:InitModel()
    self:InitStarList()
    self:InitRewardList()
    self:RegisterAllEvents()
end

function DailyTaskChessChalView:CloseViewCallBack()
    self.list_reward:DeleteMe()
    self.list_reward = nil
    self.model:DeleteMe()
    self.model = nil
end

function DailyTaskChessChalView:Init(chess_data, dung_id)
    self.txt_title = self._layout_objs["common_bg/txt_title"]
    self.txt_boss_name = self._layout_objs["txt_boss_name"]
    self.txt_reward_star_desc = self._layout_objs["txt_reward_star_desc"]

    for i=1, 7 do
        local star_name = "txt_reward_star_"..i
        self[star_name] = self._layout_objs[star_name]
    end

    self.btn_plus = self._layout_objs["btn_plus"]
    self.btn_chal = self._layout_objs["btn_chal"]
    self.btn_close = self._layout_objs["common_bg/btn_close"]
    self.btn_back = self._layout_objs["common_bg/btn_back"]

    self.list_star = self._layout_objs["list_star"]
    
    self.chess_data = chess_data    
    self.dung_id = dung_id
end

function DailyTaskChessChalView:RegisterAllEvents()
    local events = {
        [game.DailyTaskEvent.UpdateChessStar] = function(star)
            self.chess_data.star = star
            self:RefreshStarList(star)
            self:RefreshRewardList()
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

function DailyTaskChessChalView:OnEmptyClick()
    self:Close()
end

function DailyTaskChessChalView:InitBg()
    self.txt_title:SetText(config.words[1901])
    self.txt_reward_star_desc:SetText(string.format(config.words[1914], config.sys_config["chess_refresh_star_gold"].value))

    for i=1, 7 do
        local rate = config.daily_task_chess_star[i].rate
        self["txt_reward_star_"..i]:SetText(string.format(config.words[1916+i], math.floor(rate / 100) .. "%"))
    end

    self.btn_plus:AddClickCallBack(function()
        if self.chess_data.star == 7 then
            game.GameMsgCtrl.instance:PushMsg(config.ret_code[3301])
        else
            self.ctrl:OpenChessTipsView(2)
        end
    end)
    self.btn_chal:AddClickCallBack(function()
        game.CarbonCtrl.instance:DungEnterReq(self.dung_id, 1)
    end)
    self.btn_close:AddClickCallBack(function()
        self:Close()
    end)
    self.btn_back:AddClickCallBack(function()
        self:Close()
    end)
end

function DailyTaskChessChalView:InitModel()   
    local monster_cfg = config.dungeon_lv[self.dung_id][1].wave_list[1][3][1]
    local monster_id = monster_cfg[1]
    local monster = config.monster[monster_id]
    local model_id = monster.model_id
    self.txt_boss_name:SetText(monster.name)

    self.model = require("game/character/model_template").New()
    self.model:CreateModel(self._layout_objs["wrapper"], game.BodyType.Monster)
    self.model:SetModel(game.ModelType.Body, model_id)
    self.model:PlayAnim(game.ObjAnimName.Idle)
    self.model:SetPosition(0, -1.22, 4)
    self.model:SetRotation(0, 180, 0)
end

function DailyTaskChessChalView:InitStarList()
    self.list_star:SetItemNum(7)
    self:RefreshStarList(self.chess_data.star)
end

function DailyTaskChessChalView:InitRewardList()
    self.list_reward = game.UIList.New(self._layout_objs["list_reward"]) 
    self.list_reward:SetCreateItemFunc(function(obj)
        local item = require("game/bag/item/goods_item").New()
        item:SetVirtual(obj)
        item:Open()
        item:SetShowTipsEnable(true)      
        return item
    end)
    self.list_reward:SetRefreshItemFunc(function(item, idx)
        local goods_id = self.reward_list_data[idx][1]
        local num = math.floor(self.ctrl:GetChessRewardRate(self.chess_data.star) * self.reward_list_data[idx][2])
        item:SetItemInfo({id = goods_id, num = num})
    end)
    self.list_reward:SetVirtual(true)
    self:RefreshRewardList()
end

function DailyTaskChessChalView:RefreshStarList(star_num)
    for i=1, 7 do
        local sprite = self.list_star:GetChildAt(i-1)
        local sprite_name = i <= star_num and "xing" or "xing2"
        sprite:SetSprite("ui_common", sprite_name)
    end
end

function DailyTaskChessChalView:RefreshRewardList()
    self.chal_data = self.ctrl:GetChessChalData()
    local dung_data = config.dungeon_lv[self.dung_id][1]
    self.reward_list_data = config.drop[dung_data.daily_award].client_goods_list
    self.list_reward:SetItemNum(#self.reward_list_data)
end

return DailyTaskChessChalView
