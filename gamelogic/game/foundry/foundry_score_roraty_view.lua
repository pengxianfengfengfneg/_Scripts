local FoundryScoreRoratyView = Class(game.BaseView)

local reward_num = 8

function FoundryScoreRoratyView:_init(ctrl)
    FoundryScoreRoratyView.instance = self

    self._package_name = "ui_daily_task"
    self._com_name = "daily_thief_roraty_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

end

function FoundryScoreRoratyView:_delete()
    FoundryScoreRoratyView.instance = nil
end

function FoundryScoreRoratyView:OpenViewCallBack(end_time)
    self:Init()
    self:InitRewardList()
    self:RegisterAllEvents()
end

function FoundryScoreRoratyView:CloseViewCallBack()
    self:StopCountTime()
    self:StopRoratyTween()
end

function FoundryScoreRoratyView:Init()

    self._layout_objs["n14"]:SetSprite("ui_daily_task", "mz_11")
    self.btn_play = self._layout_objs["btn_play"]
    self.btn_play:SetEnable(true)
    self.btn_play:AddClickCallBack(function()
        self.ctrl:CsRefineForgeWheel()
        self:Setvisibles(true)
    end)

    self.btn_close = self._layout_objs["btn_close"]
    self.btn_close:AddClickCallBack(function()
        self:Close()
    end)

    self.txt_time = self._layout_objs["txt_time"]
    self.txt_time:SetVisible(false)

    self.img_arrow = self._layout_objs["img_arrow"]
end

--检测转盘是否停止
function FoundryScoreRoratyView:Setvisibles(isval)
    self.index = isval
end

--获取转盘是否停止
function FoundryScoreRoratyView:Getvisibles()
    return self.index or false
end

--获取抽奖物品
function FoundryScoreRoratyView:GetMsgValue(msg_list,drop_list)
    self.msg_list = msg_list
    self.drop_list = drop_list
end

function FoundryScoreRoratyView:InitRewardList()
    for i=1, 8 do
        local item = self:GetTemplate("game/bag/item/goods_item", "goods_"..i)
        item:SetShowTipsEnable(true)
        self["goods_"..i] = item
    end
    self:UpdateRewardList()
end

function FoundryScoreRoratyView:UpdateRewardList()

    local role_lv = game.Scene.instance:GetMainRoleLevel()
    local index = 1
    for k, v in ipairs(config.equip_forge_wheel) do

        if v.level > role_lv then
            break
        end

        index = k
    end

    local cfg = config.equip_forge_wheel[index]
    local items = cfg.items

    for i=1, 8 do
        local drop_id = items[i][2]
        local goods = config.drop[drop_id].client_goods_list[1]
        self["goods_"..i]:SetItemInfo({id = goods[1], num = goods[2]})
    end
end

function FoundryScoreRoratyView:Play(tar_index)
    self.btn_play:SetEnable(false)

    self.cur_index = self.cur_index or 1
    self.angle = self.angle and (self.angle % 360) or 0
    self.img_arrow:SetRotation(self.angle)

    local round = 4

    local turn_num = tar_index - self.cur_index
    if turn_num < 0 then
        turn_num = turn_num + reward_num
    end
    turn_num = turn_num + round * reward_num

    local slow_num = 7
    local midle_num = math.floor((turn_num - slow_num) / 2.5)
    local fast_num = turn_num - slow_num - midle_num

    local fast_speed = 0.05
    local midle_speed = 0.1
    local slow_speed = 0.2

    local angle = 360 / reward_num

    self:StopRoratyTween()

    self.tween = DOTween:Sequence()
    self.tween:AppendCallback(function() 
        self.angle = self.angle + angle * fast_num
        self.cur_index = (self.cur_index + fast_num - 1) % reward_num + 1
        self.img_arrow:TweenRotate(self.angle, fast_speed * fast_num)
    end)
    self.tween:AppendInterval(fast_speed * fast_num)

    self.tween:AppendCallback(function()
        self.angle = self.angle + angle * midle_num
        self.cur_index = (self.cur_index + midle_num - 1) % reward_num + 1
        self.img_arrow:TweenRotate(self.angle, midle_speed * midle_num)
    end)
    self.tween:AppendInterval(midle_speed * midle_num)

    self.tween:AppendCallback(function()
        self.angle = self.angle + angle * slow_num
        self.cur_index = (self.cur_index + slow_num - 1) % reward_num + 1
        self.img_arrow:TweenRotate(self.angle, slow_speed * slow_num)
    end)
    self.tween:AppendInterval(slow_speed * slow_num)
    self.tween:OnComplete(function()
        self.btn_play:SetEnable(true)
        self:Setvisibles(false)
        game.GameMsgCtrl.instance:PushMsg(self.msg_list)
        game.MainUICtrl.instance:ShowDrop(self.drop_list)
    end)
    self.tween:Play()
end

function FoundryScoreRoratyView:StopRoratyTween()
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

function FoundryScoreRoratyView:StartCountTime()
    self:StopCountTime()
    self.time_tween = DOTween:Sequence()
    self.time_tween:AppendCallback(function()
        local time = self.end_time - global.Time:GetServerTime()
        time = math.max(0, time)
        self.txt_time:SetText(string.format(config.words[1943], game.Utils.SecToTime2(time)))
        if time == 0 then
            self:StopCountTime()
            self:Close()
        end
    end)
    self.time_tween:AppendInterval(1)
    self.time_tween:SetLoops(-1)
end

function FoundryScoreRoratyView:StopCountTime()
    if self.time_tween then
        self.time_tween:Kill(false)
        self.time_tween = nil
    end
end

function FoundryScoreRoratyView:RegisterAllEvents()
    local events = {
        [game.FoundryEvent.ScoreRotaty] = function(index)
            self:Play(index)
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

function FoundryScoreRoratyView:RorateToIndex(id)
    local angle = 360 / reward_num * (id - 1)
    self.angle = angle % 360
    self.cur_index = id
    self.img_arrow:SetRotation(self.angle)
end

game.FoundryScoreRoratyView = FoundryScoreRoratyView

return FoundryScoreRoratyView
