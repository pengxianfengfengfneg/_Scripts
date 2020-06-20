local PassBossView = Class(game.BaseView)

local config_scene = config.scene

function PassBossView:_init(ctrl)
    self._package_name = "ui_pass_boss"
    self._com_name = "pass_boss_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
end

function PassBossView:OpenViewCallBack(pass_id)
    self:Init(pass_id)    
    self:InitBg()
    self:InitBtns()
    self:InitRankInfo()
    self:InitBossRewards()
    self:UpdatePassInfo()

    

    self:RegisterAllEvents()
end

function PassBossView:CloseViewCallBack()
    self:ClearRewards() 
    self:ClearModel()

    if self.item_pass_reward then
        self.item_pass_reward:DeleteMe()
        self.item_pass_reward = nil
    end

    self.model_id = nil
end

function PassBossView:RegisterAllEvents()
    local events = {       
        {game.PassBossEvent.UpdatePass, function(pass_id, state)
            self:OnUpdatePass(pass_id, state)
        end},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function PassBossView:Init(pass_id)
    self.pass_id = pass_id

    self.pass_cfg = config.task_pass[self.pass_id]

    self.txt_pass_name = self._layout_objs["txt_pass_name"]
    self.bar_pass_reward = self._layout_objs["bar_pass_reward"]

    self.txt_chall_word = self._layout_objs["txt_chall_word"]
    self.txt_doing_chall = self._layout_objs["txt_doing_chall"]    
    self.txt_challenge_cond = self._layout_objs["txt_challenge_cond"]
    self.txt_challenge_cond:AddClickLinkCallBack(function(data)
        self:OnClickLink(data)
    end)

    self.list_rewards = self._layout_objs["list_rewards"]

    self.item_pass_reward = game_help.GetGoodsItem(self._layout_objs["item_pass_reward"])
    self.item_pass_reward:SetShowTipsEnable(true)
end

function PassBossView:InitBtns()
    self.btn_help = self._layout_objs["btn_help"]
    self.btn_help:AddClickCallBack(function()
        self.ctrl:OpenHelpView(self.pass_id)
    end)

    self.btn_challenge = self._layout_objs["btn_challenge"]
    self.btn_challenge:AddClickCallBack(function()
        self:OnClickBtnChallenge()
    end)

    self.btn_rank = self._layout_objs["btn_rank"]
    self.btn_rank:AddClickCallBack(function()

    end)

    self.btn_get_reward = self._layout_objs["btn_get_reward"]
    self.btn_get_reward:AddClickCallBack(function()
        self.ctrl:SendGetPassRewardReq(self.pass_id)
    end)

    if game.IsZhuanJia then
        self._layout_objs["group_help"]:SetVisible(false)

        self._layout_objs["group_rank"]:SetVisible(false)
    end
end

function PassBossView:InitRankInfo()
    self.txt_first_name = self._layout_objs["txt_first_name"]
    self.txt_sec_name = self._layout_objs["txt_sec_name"]
    self.txt_third_name = self._layout_objs["txt_third_name"]

    self.txt_first_lv = self._layout_objs["txt_first_lv"]
    self.txt_sec_lv = self._layout_objs["txt_sec_lv"]
    self.txt_third_lv = self._layout_objs["txt_third_lv"]
end

function PassBossView:InitBossRewards()
    self:ClearRewards()

    local drop_goods = {
        {
            id = 16220001,
            num = 0,
        },  
        {
            id = 16220002,
            num = 0,
        },  
        {
            id = 16220003,
            num = 0,
        },  
        {
            id = 16220004,
            num = 0,
        },  
        {
            id = 16160103,
            num = 0,
        },   
    }

    local item_num = #drop_goods
    
    self.list_rewards:SetItemNum(item_num)

    for k,v in ipairs(drop_goods) do
        local child = self.list_rewards:GetChildAt(k-1)
        local item = game_help.GetGoodsItem(child)
        local info = {
            id = v.id,
            num = v.num,
        }
        item:SetItemInfo(info)
        item:SetShowTipsEnable(true)
        table.insert(self.rewards_tb, item)
    end
end

function PassBossView:UpdatePassInfo()
    self:UpdateHelpInfo()
    self:UpdateRewards()
    self:UpdateModel()
    self:UpdatePassRewardBar()
    self:UpdateChallenge()
end

function PassBossView:UpdateRewards()
    
    if self.item_pass_reward then
        local drop_id = self.ctrl:GetPassSectionRewardId(self.pass_id)
        local drop_cfg = config.drop[drop_id] or {}
        local drop_goods = drop_cfg.client_goods_list or {}
        local drop_item = drop_goods[1]
        if drop_item then
            local info = {
                id = drop_item[1],
                num = drop_item[2]
            }
            self.item_pass_reward:SetItemInfo(info)
        end
    end
end

function PassBossView:ClearRewards()
    for _,v in ipairs(self.rewards_tb or {}) do
        v:DeleteMe()
    end
    self.rewards_tb = {}
end

function PassBossView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1656])
end

function PassBossView:OnEmptyClick()
    self:Close()
end

function PassBossView:UpdateModel()
    local monster_id = self.pass_cfg.monster

    local monster_cfg = config.monster[monster_id]
    if not monster_cfg then
        return
    end

    if self.model_id == monster_cfg.model_id then
        return
    end

    self.model_id = monster_cfg.model_id

    local model_list = {
        [game.ModelType.Body]    = self.model_id,
    }

    self:ClearModel()

    if not self.show_model then
        self.show_model = require("game/character/model_template").New()
        self.show_model:CreateModel(self._layout_objs["wrapper"], game.BodyType.Monster, model_list)
        self.show_model:PlayAnim(game.ObjAnimName.Idle)
        self.show_model:SetPosition(0,-1.44,4)
        self.show_model:SetRotation(0,180,0)
    else
        self.show_model:SetModel(game.ModelType.Body, self.model_id)
    end

    self.show_model:SetScale((monster_cfg.ui_zoom or 1))
end

function PassBossView:ClearModel()
    if self.show_model then
        self.show_model:DeleteMe()
        self.show_model = nil
    end
end

function PassBossView:UpdatePassRewardBar()
    local pass_name = self:GetPassName()
    self.txt_pass_name:SetText(pass_name)

    local percent = self:GetSectionProgress()
    self.bar_pass_reward:SetProgressValue(percent)
end

function PassBossView:GetPassName()
    local scene_cfg = config.scene[self.pass_cfg.scene]
    return string.format("%s %s%s", scene_cfg.name, config.words[2150 + self.pass_cfg.chapter - 1], string.format("%s-%s",self.pass_cfg.section,self.pass_cfg.subsection))
end

function PassBossView:GetSectionProgress()
    return self.ctrl:CalcSectionProgress(self.pass_id)
end

function PassBossView:UpdateHelpInfo()
    
end

function PassBossView:UpdateChallenge()
    local pass_state = self.ctrl:GetCurPassState()

    self.btn_challenge:SetVisible(pass_state==2)

    self.txt_challenge_cond:SetVisible(pass_state==1)
    self.txt_chall_word:SetVisible(pass_state==1)

    self.txt_doing_chall:SetVisible(pass_state==3)

    self.btn_get_reward:SetVisible(pass_state==4)

    if pass_state == 1 then
        -- 不可挑战
        local require_info = self.ctrl:GetPassAcceptRequireInfo()
        local kill_info = require_info[1] or {}
        local cur_num = kill_info.cur
        local require_num = kill_info.require        
        local kill_desc = string.format("<font color='#%s'>(%s/%s)</font>", game.ColorString.Red, cur_num, require_num)
        self.txt_challenge_cond:SetText(string.format(config.words[2155], self.ctrl:GetChapterName(self.pass_id), kill_desc))
    end

    if pass_state == 2 then
        -- 可挑战

    end

    if pass_state == 3 then
        -- 挑战中

    end
end

function PassBossView:OnUpdatePass(pass_id, state)
    self.pass_id = pass_id
    self.pass_cfg = config.task_pass[self.pass_id]

    self:UpdatePassInfo()
end

function PassBossView:OnKillMonster(monster_id)
    
end

function PassBossView:OnClickLink(str_herf)
    self:OnClickBtnChallenge()
end

function PassBossView:OnClickBtnChallenge()
    local is_auto,is_pass_scene,pass_scene_id,is_tips = self.ctrl:SetAutoPass(true)
    if is_tips then
        self:ShowNotAutoTips()
        return
    end

    if not is_pass_scene then
        game.Scene.instance:SendChangeSceneReq(pass_scene_id)
        return
    end

    self:FireEvent(game.SceneEvent.MainRoleAutoPass, true)
    self:Close() 
end

function PassBossView:ShowNotAutoTips()
    game.GameMsgCtrl.instance:PushMsg(config.words[2159])
end

return PassBossView
