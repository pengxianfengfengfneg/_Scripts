local WorldBossView = Class(game.BaseView)

local handler = handler
local clone = table.clone
local config_world_boss_field = config.world_boss_field
local config_monster = config.monster

function WorldBossView:_init(ctrl)
    self._package_name = "ui_world_boss"
    self._com_name = "world_boss_view"

    self._show_money = true

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self.ctrl = ctrl
end

function WorldBossView:OpenViewCallBack()
    self:Init()    
    self:InitBg()
    self:InitMoney()
    self:InitBtns()
    self:InitListAwards()
    self:InitListStage()

    self:RegisterAllEvents()
end

function WorldBossView:CloseViewCallBack()
    for _,v in pairs(self.stage_item_tb or {}) do
        v:DeleteMe()
    end
    self.stage_item_tb = nil

    self:ClearAwards()
    self:ClearModel()
    self:ClearTipsCd()
end

function WorldBossView:RegisterAllEvents()
    local events = {
        {game.ActivityEvent.UpdateActivity, handler(self, self.OnUpdateActivity)},
        {game.ActivityEvent.StopActivity, handler(self, self.OnStopActivity)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function WorldBossView:Init()        
    self.act_id = game.ActivityId.WorldBoss

    self.txt_tips = self._layout_objs["txt_tips"]

    self:UpdateTips()
end

function WorldBossView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1668])
end

function WorldBossView:InitMoney()
    
end

function WorldBossView:InitBtns()
    self.btn_challenge = self._layout_objs["btn_challenge"]
    self.btn_challenge:AddClickCallBack(function()
        if not self:CheckEnter() then
            game.GameMsgCtrl.instance:PushMsg(config.words[4452])
            return
        end

        local item = self.cur_stage_item
        local id = item:GetId()
        local layer = item:GetLayer()
        if game.IsZhuanJia then
            local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[5050])
            msg_box:SetOkBtn(function()
                self.ctrl:SendEnterWorldBossFieldReq(id, layer, self.cur_line or 0)
                msg_box:Close()
                msg_box:DeleteMe()
            end)
            msg_box:Open()
        else
            self.ctrl:SendEnterWorldBossFieldReq(id, layer, self.cur_line or 0)
        end
    end)
end

function WorldBossView:InitListStage()
    self.list_stage = self._layout_objs["list_stage"]

    local world_lv = game.MainUICtrl.instance:GetWorldLv()

    local item_num = table.nums(config_world_boss_field)
    self.list_stage:SetItemNum(item_num)

    self.stage_item_tb = {}

    local idx = 0
    local item_class = require("game/world_boss/world_boss_stage_item")
    for k,v in pairs(config_world_boss_field) do
        local obj = self.list_stage:GetChildAt(idx)
        local item = item_class.New(v, world_lv)
        item:SetVirtual(obj)
        item:Open()

        idx = idx + 1
        table.insert(self.stage_item_tb, item)
    end

    self.stage_controller = self.list_stage:AddControllerCallback("c1", function(idx)
        local item = self.stage_item_tb[idx+1]
        self:OnClickStageItem(item)
    end)

    self.stage_controller:SetPageCount(item_num)
    self.stage_controller:SetSelectedIndexEx(0)
end

function WorldBossView:OnClickStageItem(item)
    if not item then return end

    self.cur_stage_item = item

    self:UpdateView(item)
end

function WorldBossView:UpdateView(item)
    local boss_id = item:GetBossId()
    self:UpdateBoss(boss_id)

    local awards = item:GetAwards()
    self:UpdateAwards(awards)    

end

function WorldBossView:UpdateAwards(awards)
    self:ClearAwards()

    local item_num = #awards
    self.list_awards:SetItemNum(item_num)

    for k,v in ipairs(awards) do
        local obj = self.list_awards:GetChildAt(k-1)
        local item = game_help.GetGoodsItem(obj, true)
        item:SetItemInfo({id=v, num=0})

        table.insert(self.awards_tb, item)
    end
end

function WorldBossView:ClearAwards()
    for _,v in ipairs(self.awards_tb or {}) do
        v:DeleteMe()
    end
    self.awards_tb = {}
end

function WorldBossView:InitListAwards()
    self.list_awards = self._layout_objs["list_awards"]
end

function WorldBossView:UpdateBoss(boss_id)
    if not self.boss_model then
        self.boss_model = require("game/character/model_template").New()
        self.boss_model:CreateDrawObj(self._layout_objs["wrapper"], game.BodyType.Monster)
        self.boss_model:SetPosition(0, -1.51, 3.98)
        self.boss_model:SetModelChangeCallBack(function()
            self.boss_model:SetRotation(0, 160, 0)
        end)
    end

    local cfg = config_monster[boss_id]
    if cfg then
        self.boss_model:SetModel(game.ModelType.Body, cfg.model_id)
        self.boss_model:PlayAnim(game.ObjAnimName.Idle)
    end
end

function WorldBossView:ClearModel()
    if self.boss_model then
        self.boss_model:DeleteMe()
        self.boss_model = nil
    end
end

function WorldBossView:CheckEnter()
    -- 检测是否有帮会


    return true
end

function WorldBossView:UpdateTips()
    local act_info = game.ActivityMgrCtrl.instance:GetActivity(self.act_id)
    if act_info then
        local end_time = act_info.end_time

        local delta_time = end_time - global.Time:GetServerTime()
        self:StartTipsCd(delta_time)
    else
        local coming_info = game.ActivityMgrCtrl.instance:GetActComingTime(self.act_id)
        local str_time = string.format(config.words[4461], coming_info.hour, coming_info.min)
        self.txt_tips:SetText(string.format(config.words[4463], str_time))
    end
end

function WorldBossView:OnUpdateActivity(act_list)
    if not act_list[self.act_id] then
        return
    end

    self:UpdateTips()

    for _,v in ipairs(self.stage_item_tb) do
        v:OnUpdateActivity()
    end
end

function WorldBossView:OnStopActivity(act_id)
    if self.act_id == act_id then
        self:UpdateTips()

        for _,v in ipairs(self.stage_item_tb) do
            v:OnStopActivity()
        end
    end
end

function WorldBossView:StartTipsCd(cd)
    self:ClearTipsCd()

    local cd = cd

    local seq = DOTween.Sequence()
    seq:AppendCallback(function()
        local str_time = game.Utils.SecToTime2(cd)
        self.txt_tips:SetText(string.format(config.words[4462], str_time))

        cd = cd - 1
    end)
    seq:AppendInterval(1)
    seq:OnComplete(function()
        self:ClearTipsCd()
    end)
    seq:SetLoops(cd)
    seq:SetAutoKill(false)
    
    self.seq_cd = seq
end

function WorldBossView:ClearTipsCd()
    if self.seq_cd then
        self.seq_cd:Kill(false)
        self.seq_cd = nil
    end
end

return WorldBossView
