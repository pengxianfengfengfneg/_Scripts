local WorldBossSideInfoView = Class(game.BaseView)

local handler = handler
local string_gsub = string.gsub
local string_format = string.format

function WorldBossSideInfoView:_init(ctrl)
    self._package_name = "ui_side_info"
    self._com_name = "world_boss_side_info_view"

    self._view_type = game.UIViewType.Fight

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone

    self.ctrl = ctrl
end

function WorldBossSideInfoView:OpenViewCallBack()
    self:Init()

    self:RegisterAllEvents()
end

function WorldBossSideInfoView:CloseViewCallBack()
    if self.boss_icon_tb then
        for _,v in ipairs(self.boss_icon_tb or {}) do
            v:DeleteMe()
        end
        self.boss_icon_tb = nil
    end

    if self.boss_icon_item then
        self.boss_icon_item:DeleteMe()
        self.boss_icon_item = nil
    end

    self:ClearTime()
end

function WorldBossSideInfoView:RegisterAllEvents()
    local events = {
        {game.WorldBossEvent.UpdateHurtRank, handler(self, self.OnUpdateHurtRank)},
        {game.WorldBossEvent.OnGetWorldBossSeq, handler(self, self.OnGetWorldBossSeq)},
        {game.ActivityEvent.UpdateActivity, handler(self, self.OnUpdateActivity)},
        {game.ActivityEvent.StopActivity, handler(self, self.OnStopActivity)},
        {game.SceneEvent.TargetHpChange, handler(self, self.OnTargetHpChange)},
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function WorldBossSideInfoView:Init()
    self.is_assign = false
    self.assign_rank_list = nil

    self.list_layout = self._layout_objs["list_layout"]
    self.list_layout.foldInvisibleItems = true

    self.btn_back = self._layout_objs["btn_back"]
    self.btn_back:AddClickCallBack(function()
        self.ctrl:SendExitWorldBossFieldReq()
    end)

    self.group_ready = self._layout_objs["group_ready"]
    self.txt_ready = self._layout_objs["txt_ready"]

    self.txt_time_word = self._layout_objs["txt_time_word"]
    self.txt_time = self._layout_objs["txt_time"]
    self.rtx_coming = self._layout_objs["rtx_coming"]

    self:InitCfg()

    self:InitCom1()
    self:InitCom2()
    self:InitCom3()

    self:InitTime()

    self:OnClickBossIcon(self.boss_icon_tb[1], true)
end

function WorldBossSideInfoView:InitCfg()
    local scene_id = game.Scene.instance:GetSceneID()
    local field_id = config.world_boss_scene[scene_id]
    self.enter_field_id = field_id
    self.field_cfg = config.world_boss_field[self.enter_field_id]

    self.boss_list = self.field_cfg.boss_list or {}
    self.born_list = self.field_cfg.born_pos or {}
end

function WorldBossSideInfoView:InitCom1()
    local com1 = self.list_layout:GetChild("com1")
    self.com1 = com1

    self.list_boss_icon = com1:GetChild("list_boss_icon")

    local item_num = #self.boss_list
    self.list_boss_icon:SetItemNum(item_num)

    self.boss_icon_tb = {}
    local item_class = require("game/world_boss/boss_icon_item")
    for k,v in ipairs(self.boss_list) do
        local obj = self.list_boss_icon:GetChildAt(k-1)

        local item = item_class.New(k, v, self.born_list[k])
        item:SetVirtual(obj)
        item:Open()

        obj:AddClickCallBack(function()
            self:OnClickBossIcon(item)
        end)

        table.insert(self.boss_icon_tb, item)
    end
end

function WorldBossSideInfoView:InitCom2()
    local com2 = self.list_layout:GetChild("com2")
    self.com2 = com2
    self.com2:SetVisible(false)

    local shape_click = com2:GetChild("shape_click")
    shape_click:AddClickCallBack(function()
        self:OnClickBtnGo()
    end)

    self.boss_icon = com2:GetChild("boss_icon")
    self.boss_icon_item = require("game/world_boss/boss_icon_item").New(1, self.boss_list[1])
    self.boss_icon_item:SetVirtual(self.boss_icon)
    self.boss_icon_item:Open()
    self.boss_icon_item:HideName()

    self.txt_guild = com2:GetChild("txt_guild")
    
    self.txt_name = com2:GetChild("txt_name")
    self.bar_hp = com2:GetChild("bar_hp")
    self.txt_hp_percent = com2:GetChild("txt_hp_percent")

    self.btn_go = com2:GetChild("btn_go")
    self.btn_go:AddClickCallBack(function()
        self:OnClickBtnGo()
    end)

    self.btn_rank = com2:GetChild("btn_rank")
    self.btn_rank:AddClickCallBack(function()
        local rank_list = self.cur_boss_icon_item:GetRankList()
        if rank_list then
            local boss_id = self.cur_boss_icon_item:GetBossId()
            local hp_lmt = self.cur_boss_icon_item:GetBossHpLmt()
            self.ctrl:OpenHurtRankView(boss_id, hp_lmt, rank_list)
        else
            -- 活动未开启
            game.GameMsgCtrl.instance:PushMsg(config.words[4453])
        end
    end)
end

function WorldBossSideInfoView:InitCom3()
    local com3 = self.list_layout:GetChild("com3")
    self.com3 = com3

    self.is_boss_info_visible = false
    self.btn_fold = com3:GetChild("btn_fold")
    self.btn_fold:SetSelected(false)
    self.btn_fold:AddClickCallBack(function()
        self.is_boss_info_visible = not self.is_boss_info_visible
        self.com2:SetVisible(self.is_boss_info_visible)

        local idx = self.boss_icon_item:GetIdx()
        local item = self.boss_icon_tb[idx]
        if item then
            item:SetSelect(self.is_boss_info_visible)
        end
    end)
end

function WorldBossSideInfoView:OnClickBossIcon(item, not_click)
    self.cur_boss_icon_item = item

    if not not_click then
        for _,v in ipairs(self.boss_icon_tb or {}) do
            v:SetSelect(v==item)
        end
    end
    
    local is_assign = item:GetAssign()
    self.bar_hp:SetValue(item:GetHpPercent())
    self.txt_hp_percent:SetText(string.format("%.2f%%", item:GetHpPercent()))

    if is_assign then
        local boss_name = item:GetBossName()
        local boss_lv = item:GetBossLv()
        self.txt_name:SetText(string.format(config.words[4451], boss_name, boss_lv))
    else
        self.txt_name:SetText(config.words[4457])
    end

    self.boss_icon_item:SetIdx(item:GetIdx())
    self.boss_icon_item:SetBornPos(item:GetBornPos())
    self.boss_icon_item:SetAssign(is_assign)
    self.boss_icon_item:SetBossId(item:GetBossId())
    self.boss_icon_item:SetDeadFlag(item:IsDead())
    self.boss_icon_item:SetGray(item:IsGray())

    local top_data = item:GetTopGuildData()
    if top_data then
        self.txt_guild:SetText(top_data.guild_name)
    else
        self.txt_guild:SetText(config.words[4450])
    end

    if not not_click then
        if not self.is_boss_info_visible then
            self.is_boss_info_visible = true
            self.com2:SetVisible(self.is_boss_info_visible)
        end
    end
end

function WorldBossSideInfoView:OnUpdateHurtRank(rank_list)
    if not self.is_assign then
        self.assign_rank_list = rank_list
        self.ctrl:SendGetWorldBossSeqReq()
        return
    end

    for k,v in ipairs(rank_list) do
        for ck,cv in ipairs(self.boss_icon_tb or {}) do
            if v.boss_rank.boss_id == cv:GetBossId() then
                cv:UpdateData(v.boss_rank)
                break
            end
        end

        if self.boss_icon_item:GetBossId() == v.boss_rank.boss_id then
            self.boss_icon_item:UpdateData(v.boss_rank)

            local hp_percent = self.boss_icon_item:GetHpPercent()
            self.bar_hp:SetValue(hp_percent)


            self.txt_hp_percent:SetText(string.format("%.2f%%", self.boss_icon_item:GetHpPercent()))

            local boss_name = self.boss_icon_item:GetBossName()
            local boss_lv = self.boss_icon_item:GetBossLv()
            self.txt_name:SetText(string.format(config.words[4451], boss_name, boss_lv))
        end
    end

end

function WorldBossSideInfoView:OnClickBtnGo()
    local born_pos = self.cur_boss_icon_item:GetBornPos()
    if not born_pos then return end

    local ux,uy = game.LogicToUnitPos(born_pos[1], born_pos[2])
    local main_role = game.Scene.instance:GetMainRole()
    main_role:GetOperateMgr():DoFindWay(ux, uy)
end

function WorldBossSideInfoView:CalcIdx(x,y)
    for k,v in ipairs(self.boss_icon_tb) do
        if v:IsInBornPos(x, y) then
            return k
        end
    end
end

function WorldBossSideInfoView:OnGetWorldBossSeq(data)
    if self.is_assign then return end

    PrintTable(data)
    for k,v in ipairs(data) do
        local item = self.boss_icon_tb[k]
        if item then
            item:SetBossId(v.boss_id)
        end

        if self.boss_icon_item:GetIdx() == k then
            self.boss_icon_item:SetBossId(v.boss_id)
        end
    end

    self.is_assign = true

    if self.assign_rank_list then
        self:OnUpdateHurtRank(self.assign_rank_list)
    end
end

function WorldBossSideInfoView:OnUpdateActivity(act_list)
    local act_info = act_list[game.ActivityId.WorldBoss]
    if not act_info then return end

    self:InitTime()
end

function WorldBossSideInfoView:OnStopActivity(act_id)
    if act_id ~= game.ActivityId.WorldBoss then
        return
    end

    for _,v in ipairs(self.boss_icon_tb or {}) do
        v:ResetItem()
    end

    self.boss_icon_item:ResetItem()

    self.is_assign = false
    self.assign_rank_list = nil

    self.bar_hp:SetValue(0)
    self.txt_hp_percent:SetText(string.format("%s%%", 0))

    self:InitTime()
end

function WorldBossSideInfoView:InitTime()
    local act_info = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.WorldBoss)

    self:ClearTime()
    if act_info then
        local end_time = act_info.end_time
        local left_time = math.ceil(end_time - global.Time:GetServerTime())

        local seq = DOTween.Sequence()
        seq:AppendCallback(function()
            self.txt_time:SetText(string.format(config.words[4458], game.Utils.SecToTime(left_time)))

            if left_time == 10 then
                self.group_ready:SetVisible(true)
            end

            if left_time <= 10 then
                self.txt_ready:SetText(string.format(config.words[4459], left_time))
            end

            left_time = left_time - 1
        end)
        seq:AppendInterval(1)
        seq:SetLoops(left_time)
        seq:OnComplete(function()
            self.group_ready:SetVisible(false)

            self:ClearTime()
        end)
        seq:SetAutoKill(false)

        self.cd_seq = seq
    else
        -- 预告开启时间
        local str_time = self:GetActComingTime()
        self.rtx_coming:SetText(string.format(config.words[4460], str_time))
    end

    local is_on = act_info~=nil
    self.txt_time:SetVisible(is_on)
    self.txt_time_word:SetVisible(is_on)
    self.rtx_coming:SetVisible(not is_on)
end

function WorldBossSideInfoView:ClearTime()
    if self.cd_seq then
        self.cd_seq:Kill(false)
        self.cd_seq = nil
    end
end

function WorldBossSideInfoView:GetActComingTime()
    local coming_info = game.ActivityMgrCtrl.instance:GetActComingTime(game.ActivityId.WorldBoss)

    return string.format(config.words[4461], coming_info.hour, coming_info.min)
end

function WorldBossSideInfoView:OnTargetHpChange(percent, obj_type, uniq_id)
    if obj_type ~= game.ObjType.Monster then
        return
    end

    local monster = game.Scene.instance:GetObjByUniqID(uniq_id)
    if monster then
        local monster_id = monster:GetMonsterId()
        local cur_boss_id = self.boss_icon_item:GetBossId()
        if monster_id == cur_boss_id then
            local hp_percent = monster:GetHpPercent() * 100
            self.bar_hp:SetValue(math.floor(hp_percent))
            self.txt_hp_percent:SetText(string.format("%.2f%%", hp_percent))

            self.cur_boss_icon_item:SetHpFillAmount(hp_percent*0.01)
        end
    end
end

return WorldBossSideInfoView
