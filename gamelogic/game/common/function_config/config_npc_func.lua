local funcs = {
    -- 单人繁殖
    [100] = {
        click_func = function(npc_cfg)
            local ctrl = game.PetCtrl.instance
            ctrl:SetHireBreed(false)
            ctrl:SendHatchType(1)
        end
    },
    -- 领取珍兽
    [101] = {
        click_func = function(npc_cfg)
            local ctrl = game.PetCtrl.instance
            local hatch_info = ctrl:GetHatchInfo()
            if hatch_info and (hatch_info.stat == 3 or hatch_info.stat == 2) then
                ctrl:OpenPetEggView()
            end
        end,
    },
    -- 雇佣繁殖
    [102] = {
        click_func = function(npc_cfg)
            local ctrl = game.PetCtrl.instance
            ctrl:SetHireBreed(true)
            ctrl:SendHatchType(1)
        end,
    },    
    -- 召唤神兽
	[103] = {
        click_func = function(npc_cfg)
            game.PetCtrl.instance:OpenGodPetCallView()
        end
    },
    -- 神兽觉醒
    [104] = {
        click_func = function(npc_cfg)
            game.PetCtrl.instance:OpenGodPetAwakeView()
        end
    },
    -- 老三环
    [105] = {
        click_func = function(npc_cfg)
            local dun_id = 700
            game.CarbonCtrl.instance:SendDungEnterTeam(dun_id)
        end
    },
    -- 燕子坞
    [106] = {
        click_func = function(npc_cfg)
            local dun_id = 800
            game.CarbonCtrl.instance:SendDungEnterTeam(dun_id)
        end
    },
    -- 四绝庄
    [107] = {
        click_func = function(npc_cfg)
            local dun_id = 900
            game.CarbonCtrl.instance:SendDungEnterTeam(dun_id)
        end
    },
    -- 缥缈峰
    [108] = {
        click_func = function(npc_cfg)
            local dun_id = 1000
            game.CarbonCtrl.instance:SendDungEnterTeam(dun_id)
        end
    },
    -- 离开
    [109] = {
        click_func = function(npc_cfg)
            
        end
    },
    -- 帮会任务
    [110] = {
        click_func = function(npc_cfg)
            game.DailyTaskCtrl.instance:TryCompleteNpcGuildTask(npc_cfg)
        end,
        visible_func = function(npc_cfg)
            local task_info = game.DailyTaskCtrl.instance:GetGuildTaskInfo()
            local npc_id = game.DailyTaskCtrl.instance:GetGuildTaskNpcId()
            if task_info then
                return (task_info.flag==1 and npc_id==npc_cfg.id) and 
                    (task_info.type~=1 and task_info.type~=2 and task_info.type~=3)
            end
            return false
        end,
    },
    -- 重楼肩升级
    [111] = {
        click_func = function(npc_cfg)
            game.FoundryCtrl.instance:OpenRefineUpgradeView()
        end
    },
    -- 重楼镶嵌
    [112] = {
        click_func = function(npc_cfg)
            game.FoundryCtrl.instance:OpenRefineInlayView()
        end
    },
    -- 重楼强化
    [113] = {
        click_func = function(npc_cfg)
            game.FoundryCtrl.instance:OpenRefineStrenView()
        end
    },
    -- 重楼拆卸
    [114] = {
        click_func = function(npc_cfg)
            game.FoundryCtrl.instance:OpenRefineTakeoffView()
        end
    },
    -- 帮会运镖
    [115] = {
        click_func = function(npc_cfg)
            game.GuildCtrl.instance:OpenGuildYunbiaoView()
        end,
        check_func = function(is_tips) 
            if not game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.GuildCarry) then
                -- 活动未开启
                if is_tips then
                    game.GameMsgCtrl.instance:PushMsg(config.words[4453])
                end
                return false
            end

            if game.GuildCtrl.instance:IsTransformAlchemist() then
                if is_tips then
                    game.GameMsgCtrl.instance:PushMsg(config.words[5526])
                end
                return false
            end

            local limit_lv = 30
            local role_level = game.Scene.instance:GetMainRoleLevel()
            for _,v in pairs(config.activity_hall) do
                if v.act_id == game.ActivityId.GuildCarry then
                    limit_lv = v.limit_lv
                    break
                end
            end

            if role_level < limit_lv then
                if is_tips then
                    game.GameMsgCtrl.instance:PushMsg(string.format(config.words[5310], limit_lv))
                end
                return false
            end

            -- local yunbiao_data = game.GuildCtrl.instance:GetYunbiaoData()
            -- if yunbiao_data.carry_times >= config.carry_common.carry_times then
            --     if is_tips then
            --         game.GameMsgCtrl.instance:PushMsg(config.words[5302])
            --     end
            --     return false
            -- end
            return true
        end,
    },
    [116] = {
        click_func = function(npc_cfg)
            local ctrl = game.PetCtrl.instance
            ctrl:SendHatchType(2)
        end
    },
    -- 帮会练功
    [117] = {
        click_func = function(npc_cfg)
            game.GuildCtrl.instance:TryPractice()
        end,
        check_func = function(is_tips) 
            if game.GuildCtrl.instance:IsTransformAlchemist() then
                if is_tips then
                    game.GameMsgCtrl.instance:PushMsg(config.words[5526])
                end
                return false
            end
            return true
        end,
    },
    [118] = {
        click_func = function(npc_cfg)
            game.GuildArenaCtrl.instance:CsJoustsHallEnter()
        end
    },
    -- 挑战珍珑棋局
    [119] = {
        click_func = function(npc_cfg)
            game.DailyTaskCtrl.instance:JoinInChessAct()
        end
    },
    -- 珍珑棋局快捷组队
    [120] = {
        click_func = function(npc_cfg)
            game.MakeTeamCtrl.instance:QuickMakeTeam(15)
        end
    },
    -- 消灭夺宝马贼
    [121] = {
        click_func = function(npc_cfg)
            game.DailyTaskCtrl.instance:StartThiefTask()
        end
    },
    [122] = {
        click_func = function(npc_cfg)
            game.ExteriorCtrl.instance:OpenFashionDyeView()
        end
    },
    [123] = {
        click_func = function(npc_cfg)
            game.CarbonCtrl.instance:OpenGuildTeamCarbonView()
        end
    },
    -- 结拜金兰
    [124] = {
        click_func = function()
            game.SwornCtrl.instance:StartSworn()
        end
    },
    -- 辈分排序
    [125] = {
        click_func = function()
            game.SwornCtrl.instance:SendSwornChangeSenior()
        end
    },
    -- 江湖名号
    [126] = {
        click_func = function()
            game.SwornCtrl.instance:SendSwornModifyNameReq()
        end
    },
    -- 接纳新人
    [127] = {
        click_func = function()
            game.SwornCtrl.instance:SendSwornRecruitMember()
        end
    },
    -- 请离旧人
    [128] = {
        click_func = function()
            game.SwornCtrl.instance:SendSwornDismissMemberReq()
        end
    },
    -- 割袍断义
    [129] = {
        click_func = function()
            if not game.SwornCtrl.instance:HaveSwornGroup() then
                game.GameMsgCtrl.instance:PushMsg(config.words[6289])
            else
                game.SwornCtrl.instance:ShowLeaveGroupView()
            end
        end
    },
    -- 结拜平台
    [130] = {
        click_func = function()
            game.SwornCtrl.instance:OpenSwornPlatformView()
        end
    },
    -- 申请结婚
    [131] = {
        click_func = function()
            game.MarryCtrl.instance:SendMarryInvite()
        end
    },
    --结婚迅游
    [132] = {
        click_func = function()
            game.MarryProcessCtrl.instance:CsMarryParadeBegin()
        end
    },
    -- 开启礼堂
    [133] = {
        click_func = function()
            game.MarryProcessCtrl.instance:CsMarryHallOpen()
        end
    },
    -- 进入礼堂
    [134] = {
        click_func = function()
            game.MarryProcessCtrl.instance:CsMarryHallInfo()
        end
    },
    -- 恩爱排行榜
    [135] = {
        click_func = function()
            game.MarryCtrl.instance:OpenRankView()
        end
    },
    -- 爱的祝福
    [136] = {
        click_func = function()
            game.MarryCtrl.instance:OpenBlessView()
        end
    },
    -- 协议离婚
    [137] = {
        click_func = function()
            game.MarryCtrl.instance:SendDivorce(1)
        end
    },
    -- 强制离婚
    [138] = {
        click_func = function()
            game.MarryCtrl.instance:SendDivorce(2)
        end
    },
    --购买烟花
    [139] = {
        click_func = function()
            game.ShopCtrl.instance:OpenViewByShopId(40)
        end
    },
    --银两答谢
    [140] = {
        click_func = function()
            local str = string.format(config.words[6168], config.marry_hall_gift[1].cost[2])
            local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], str)
            msg_box:SetOkBtn(function()
                game.MarryProcessCtrl.instance:CsMarryHallThank(1)
                msg_box:DeleteMe()
            end)
            msg_box:SetCancelBtn(function()
            end)
            msg_box:Open()
        end
    },
    --元宝答谢
    [141] = {
        click_func = function()
            local str = string.format(config.words[6169], config.marry_hall_gift[2].cost[2])
            local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102],str)
            msg_box:SetOkBtn(function()
                game.MarryProcessCtrl.instance:CsMarryHallThank(2)
                msg_box:DeleteMe()
            end)
            msg_box:SetCancelBtn(function()
            end)
            msg_box:Open()
        end
    },
    -- 拜天地
    [142] = {
        click_func = function()
            game.MarryProcessCtrl.instance:CsMarryHallBaitang()
        end
    },
    -- 闹洞房
    [143] = {
        click_func = function()
            if game.MarryProcessCtrl.instance:IsInMyHall() then
                --夫妻切换到上床按钮
                game.MarryProcessCtrl.instance:SetClickNDFBtn(true)
                game.TaskCtrl.instance:OpenNpcDialogView(2104)
            else
                --其他人发送传闻
                game.MarryProcessCtrl.instance:CsMarryHallNosiy()
            end
        end,
        visible_func = function()
            return not game.MarryProcessCtrl.instance:GetClickNDFBtn()
        end,
    },
    -- 躺上新床
    [144] = {
        click_func = function()
            game.MarryProcessCtrl.instance:CsMarryHallSleep()
        end,
        visible_func = function()
            return game.MarryProcessCtrl.instance:GetClickNDFBtn()
        end,
    },
    -- 品尝美食
    [149] = {
        click_func = function()
            game.MarryProcessCtrl.instance:CsMarryHallTaste()
        end
    },
    -- 夫妻技能
    [150] = {
        click_func = function()
            game.MarryCtrl.instance:OpenSkillUpgradeView()
        end
    },
    -- 恩爱兑换商店
    [153] = {
        click_func = function()
            game.ShopCtrl.instance:OpenViewByShopId(23)
        end
    },
    -- 英雄老三环
    [154] = {
        click_func = function()
            game.CarbonCtrl.instance:SendDungEnterTeam(1800)
        end,
        visible_func = function(npc_cfg)
            return game.CarbonCtrl.instance:CheckHeroDungeVisible(1800)
        end,
    },
    -- 英雄燕子坞
    [155] = {
        click_func = function()
            game.CarbonCtrl.instance:SendDungEnterTeam(1900)
        end,
        visible_func = function(npc_cfg)
            return game.CarbonCtrl.instance:CheckHeroDungeVisible(1900)
        end,
    },
    -- 英雄四绝庄
    [156] = {
        click_func = function()
            game.CarbonCtrl.instance:SendDungEnterTeam(2000)
        end,
        visible_func = function(npc_cfg)
            return game.CarbonCtrl.instance:CheckHeroDungeVisible(2000)
        end,
    },
    -- 英雄缥缈峰
    [157] = {
        click_func = function()
            game.CarbonCtrl.instance:SendDungEnterTeam(2100)
        end,
        visible_func = function(npc_cfg)
            return game.CarbonCtrl.instance:CheckHeroDungeVisible(2100)
        end,
    },
    -- 马贼快捷组队
    [158] = {
        click_func = function(npc_cfg)
            game.MakeTeamCtrl.instance:QuickMakeTeam(2)
        end
    },
    -- 完成运镖
    [159] = {
        click_func = function(npc_cfg)
            game.GuildCtrl.instance:SendSubmitCarryReq()
        end,
        visible_func = function()
            local yunbiao_data = game.GuildCtrl.instance:GetYunbiaoData()
            if yunbiao_data then
                return (yunbiao_data.stat==2)
            end
            return false
        end,
    },
    -- 传送苏州
    [201] = {
        click_func = function()
            if game.GuildCtrl.instance:IsTransformAlchemist() then
                game.GameMsgCtrl.instance:PushMsg(config.words[5526])
            end
        end,
        check_func = function(is_tips) 
            if game.GuildCtrl.instance:IsTransformAlchemist() then
                if is_tips then
                    game.GameMsgCtrl.instance:PushMsg(config.words[5526])
                end
                return false
            end
            return true
        end,
    },
    -- 传送洛阳
    [202] = {
        click_func = function()
           
        end,
        check_func = function(is_tips) 
            if game.GuildCtrl.instance:IsTransformAlchemist() then
                if is_tips then
                    game.GameMsgCtrl.instance:PushMsg(config.words[5526])
                end
                return false
            end
            return true
        end,
    },
    -- 惩凶打图
    [203] = {
        click_func = function(npc_cfg)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():ClearOperate()
            end
            game.DailyTaskCtrl.instance:CsDailyRobberAcceptTask()
        end,
        check_func = function(is_tips)
            local data = game.DailyTaskCtrl.instance:GetCxdtData()
            if data then
                if data.state == 1 then
                    -- 任务进行中
                    if is_tips then
                        game.GameMsgCtrl.instance:PushMsg(config.words[2195])
                    end
                    return false
                end

                if data.state==0 and data.times < data.max_times then
                    return true
                end
            end

            game.GameMsgCtrl.instance:PushMsg(config.words[1965])
            return false
        end,
        visible_func = function()
            local data = game.DailyTaskCtrl.instance:GetCxdtData()
            if data then
                return (data.state<2)
            end
            return false
        end,
    },
    -- 科举考试
    [204] = {
        click_func = function(npc_cfg)
            local open_lv = config.examine_info.open_lv
            if game.RoleCtrl.instance:GetRoleLevel() < open_lv then
                game.GameMsgCtrl.instance:PushMsg(string.format(config.words[1953], open_lv))
            else
                game.ImperialExamineCtrl.instance:OpenView()
            end
        end
    },
    -- 门派竞技
    [205] = {
        click_func = function(npc_cfg)
			game.CareerBattleCtrl.instance:SendCareerBattleEnter()
        end
    },
    [206] = {
        click_func = function(npc_cfg)
            game.CarbonCtrl.instance:OpenHeroTrialView()
        end
    },
    [207] = {
        click_func = function(npc_cfg)
            game.RoleCtrl.instance:SendLevelUp()
        end
    },
    [208] = {
        click_func = function(npc_cfg)
            game.RoleCtrl.instance:SendLevelExchangeBox(1)
        end
    },
    [209] = {
        click_func = function(npc_cfg)
            game.RoleCtrl.instance:SendLevelExchangeBox(2)
        end
    },
    [210] = {
        click_func = function(npc_cfg)
            game.RoleCtrl.instance:SendLevelExchangeBox(3)
        end
    },
    [211] = {
        click_func = function(npc_cfg)
            game.GuildCtrl.instance:SendLevelUpPracticeMaxLv()
        end
    },

    -- 惩凶打图提交任务
    [212] = {
        click_func = function(npc_cfg)
            game.DailyTaskCtrl.instance:CsDailyRobberSubmitTask()
        end,
        check_func = function()
            local data = game.DailyTaskCtrl.instance:GetCxdtData()
            if data then
                return (data.state==2)
            end
            return false
        end,
        visible_func = function()
            local data = game.DailyTaskCtrl.instance:GetCxdtData()
            if data then
                return (data.state==2)
            end
            return false
        end,
    },

    --领取每日任务
    [213] = {
        click_func = function(npc_cfg)
            local task_info = game.DailyTaskCtrl.instance:GetDailyTaskInfo()
            if task_info.task_id ~= 0 then
                game.Scene.instance:GetMainRole():GetOperateMgr():DoHangTask(task_info.task_id)
            else
                game.DailyTaskCtrl.instance:SendDailyTaskGet()
            end
        end,
    },

    --挖掘金矿
    [214] = {
        click_func = function(npc_cfg)
            local lv = game.RoleCtrl.instance:GetRoleLevel()
            local open_lv = config.sys_config["guild_metall_open_lv"].value
            if lv < open_lv then
                game.GameMsgCtrl.instance:PushMsg(string.format(config.words[6005], open_lv))
                return
            end
            game.GuildCtrl.instance:SendGuildMetallTask(38)
        end,
    },

    --挖掘大金矿
    [215] = {
        click_func = function(npc_cfg)
            local lv = game.RoleCtrl.instance:GetRoleLevel()
            local open_lv = config.sys_config["guild_metall_open_lv"].value
            if lv < open_lv then
                game.GameMsgCtrl.instance:PushMsg(string.format(config.words[6005], open_lv))
                return
            end
            game.GuildCtrl.instance:OpenGuildTipsView(4)
        end,
    },

    --宋辽
    [216] = {
        click_func = function(npc_cfg)
            local lv = game.RoleCtrl.instance:GetRoleLevel()
            local cur_index = 1
            local room_name = ""
            for k, v in pairs(config.songliao_war_room) do
                if v.max_lv >= lv and lv >= v.min_lv then
                    cur_index = k
                    room_name = v.name
                    break
                end
            end

            local str = string.format(config.words[4117], lv, room_name)
            local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], str)
            msg_box:SetOkBtn(function()
                game.SongliaoWarCtrl.instance:CsDynastyWarEnter()
                msg_box:DeleteMe()
            end)
            msg_box:SetCancelBtn(function()
            end)
            msg_box:Open()
        end,
    },

    --帮会守卫战
    [217] = {
        click_func = function(npc_cfg)
			game.GuildCtrl.instance:SendGuildDefendEnter()
        end,
    },

     --武学考验
    [218] = {
        click_func = function(task_id)
            local task_cfg = game.TaskCtrl.instance:GetTaskCfg(task_id)
            if #task_cfg.client_action > 0 then
                local client_action = task_cfg.client_action[1]
                game.DailyTaskCtrl.instance:OpenLineGameView(task_id, client_action[4])
            end
        end,
    },

     --旷世之宝
    [219] = {
        click_func = function(task_id)
            local task_cfg = game.TaskCtrl.instance:GetTaskCfg(task_id)
            game.DailyTaskCtrl.instance:OpenDailyTaskItemView(task_cfg)
        end,
        check_func = function(task_id)
            local task_cfg = game.TaskCtrl.instance:GetTaskCfg(task_id)
            if task_cfg == nil then 
                return
            end
            if #task_cfg.client_action > 0 then
                local client_action = task_cfg.client_action[1]
                local cfg = game.TaskCtrl.instance:GetClientActionCfg(client_action[1])
                if cfg then                    
                    local res = cfg.check_func(client_action)
                    if not res then
                        local item_id = client_action[4]
                        local item_cfg = config.goods[item_id]
                        local str_tips = string.format(config.words[2152], item_cfg.name)
                        game.GameMsgCtrl.instance:PushMsg(str_tips)
                    end
                    return res
                end
            end
            return true
        end,
    },

     --珍禽异兽
    [220] = {
        click_func = function(task_id)
            local task_cfg = game.TaskCtrl.instance:GetTaskCfg(task_id)
            game.DailyTaskCtrl.instance:OpenDailyTaskItemView(task_cfg)
        end,
        check_func = function(task_id)
            local task_cfg = game.TaskCtrl.instance:GetTaskCfg(task_id)
            print("config_npc_func",task_cfg)
            if task_cfg == nil then
                return
            end
            if #task_cfg.client_action > 0 then
                local client_action = task_cfg.client_action[1]
                local cfg = game.TaskCtrl.instance:GetClientActionCfg(client_action[1])
                if cfg then                    
                    local res = cfg.check_func(client_action)
                    if not res then
                        local pet_id = client_action[4]
                        local coll_id = client_action[5]
                        local coll_cfg = config.coll[coll_id]
                        local str_tips = string.format(config.words[2152], coll_cfg.name)
                        game.GameMsgCtrl.instance:PushMsg(str_tips)
                    end
                    return res
                end
            end
            return true
        end,
    },

     --拜见名士
    [221] = {
        click_func = function(task_id)
            game.TaskCtrl.instance:SendTaskGetReward(task_id)
        end,
    },

    -- 杂货商店
    [222] = {
        click_func = function(task_id)
            game.ShopCtrl.instance:OpenViewByShopId(27)
        end,
    },
    -- 杂货商店
    [223] = {
        click_func = function(task_id)
            game.ShopCtrl.instance:OpenViewByShopId(28)
        end,
    },
    -- 杂货商店
    [224] = {
        click_func = function(task_id)
            game.ShopCtrl.instance:OpenViewByShopId(29)
        end,
    },
    -- 杂货商店
    [225] = {
        click_func = function(task_id)
            game.ShopCtrl.instance:OpenViewByShopId(30)
        end,
    },
    -- 杂货商店
    [226] = {
        click_func = function(task_id)
            game.ShopCtrl.instance:OpenViewByShopId(31)
        end,
    },
    -- 杂货商店
    [227] = {
        click_func = function(task_id)
            game.ShopCtrl.instance:OpenViewByShopId(32)
        end,
    },
    -- 杂货商店
    [228] = {
        click_func = function(task_id)
            game.ShopCtrl.instance:OpenViewByShopId(33)
        end,
    },
    -- 杂货商店
    [229] = {
        click_func = function(task_id)
            game.ShopCtrl.instance:OpenViewByShopId(34)
        end,
    },
    -- 杂货商店
    [230] = {
        click_func = function(task_id)
            game.ShopCtrl.instance:OpenViewByShopId(35)
        end,
    },

    --科举考试新手任务
    [231] = {
        click_func = function(task_id)
            local num = game.DailyTaskCtrl.instance:GetExamineNewTaskNum()
            if num >= #config.examine_new_bank then
                game.GameMsgCtrl.instance:PushMsg(config.words[5174])
                return
            end
            game.ImperialExamineCtrl.instance:OpenTaskView(task_id)
        end,
    },

    --拼画
    [232] = {
        click_func = function(task_id)
            local task_cfg = game.TaskCtrl.instance:GetTaskCfg(task_id)
            if #task_cfg.client_action > 0 then
                local client_action = task_cfg.client_action[1]
                game.DailyTaskCtrl.instance:OpenPuzzleGameView(task_id, client_action[4])
            end
        end,
    },

    --太湖石兑换商店
    [233] = {
        click_func = function()
            game.ShopCtrl.instance:OpenViewByShopId(38)
        end,
    },

    -- 跑环
    [234] = {
        click_func = function()
            local task_id = game.TaskCtrl.instance:GetCircleTaskId()
            if not task_id then
                local circle_task_info = game.TaskCtrl.instance:GetCircleTaskInfo()
                local round = math.floor(circle_task_info.times / circle_task_info.round_times) + 1
                local cfg = config.circle_task[round]
                if not cfg then
                    return
                end

                local str_cost = ""
                for _,v in ipairs(cfg.cost) do
                    local id = v[1]
                    local num = v[2]
                    local money_cfg = config.money_type[id]
                    if money_cfg then
                        str_cost = string.format("%s%s<img asset=\'ui_common:%s\' />", str_cost, num, money_cfg.icon)
                    end
                end

                local round_times = circle_task_info.round_times
                local round_word = config.words[110+round]
                local start_circle = (round-1)*round_times+1
                local end_circle = round*round_times

                local title = config.words[1660]
                local content = string.format(config.words[6304], str_cost, round_word, start_circle, end_circle)
                local msg_view = game.GameMsgCtrl.instance:CreateMsgBox(title, content)
                msg_view:SetOkBtn(function()
                    game.TaskCtrl.instance:SendCircleAccept()
                end)
                msg_view:SetCancelBtn(function()
                    
                end)
                msg_view:Open()
            else
                local main_role = game.Scene.instance:GetMainRole()
                if main_role then
                    main_role:GetOperateMgr():DoHangTask(task_id)
                end
            end
        end,
        check_func = function(is_tips)
            local info = game.TaskCtrl.instance:GetCircleTaskInfo()
            local is_enable = (info.times/info.round_times < 3)

            if not is_enable and is_tips then
                game.GameMsgCtrl.instance:PushMsg(config.words[6303])
            end
            return is_enable
        end,
    },
    -- 便捷跑环
    [235] = {
        click_func = function()
            game.TaskCtrl.instance:OpenCircleTaskSelectItemView()
        end,
        check_func = function(is_tips)
            local task_id = game.TaskCtrl.instance:GetCircleTaskId()
            local is_enable = (task_id~=nil)

            if not is_enable and is_tips then
                game.GameMsgCtrl.instance:PushMsg(config.words[6302])
            end
            return is_enable
        end,
    },

    --结成契约
    [236] = {
        click_func = function()
            game.VowCtrl.instance:CsDeedInvite()
        end,
    },

    --带徒弟拜师
    [237] = {
        click_func = function()
            game.MentorCtrl.instance:SendMentorBegin()
        end,
    },

    --亲传练功
    [238] = {
        click_func = function()
            game.MentorCtrl.instance:SendMentorBeginPractice()
        end,
    },

    --宋辽称号兑换
    [239] = {
        click_func = function()
            game.SongliaoWarCtrl.instance:OpenTitleView()
        end,
    },

    --宋辽积分商店
    [240] = {
        click_func = function()
            game.ShopCtrl.instance:OpenViewByShopId(18)
        end,
    },

    --钻石组
    [241] = {
        click_func = function(npc_cfg)
            game.CareerBattleCtrl.instance:ShowStatueInfo(npc_cfg.id, 4)
        end,
        name_func = function(npc_cfg)
            return game.CareerBattleCtrl.instance:GetStatueFuncName(npc_cfg.id, 4)
        end,
    },
    --黄金组
    [242] = {
        click_func = function(npc_cfg)
            game.CareerBattleCtrl.instance:ShowStatueInfo(npc_cfg.id, 3)
        end,
        name_func = function(npc_cfg)
            return game.CareerBattleCtrl.instance:GetStatueFuncName(npc_cfg.id, 3)
        end,
    },
    --白银组
    [243] = {
        click_func = function(npc_cfg)
            game.CareerBattleCtrl.instance:ShowStatueInfo(npc_cfg.id, 2)
        end,
        name_func = function(npc_cfg)
            return game.CareerBattleCtrl.instance:GetStatueFuncName(npc_cfg.id, 2)
        end,
    },
    --青铜组
    [244] = {
        click_func = function(npc_cfg)
            game.CareerBattleCtrl.instance:ShowStatueInfo(npc_cfg.id, 1)
        end,
        name_func = function(npc_cfg)
            return game.CareerBattleCtrl.instance:GetStatueFuncName(npc_cfg.id, 1)
        end,
    },

    [301] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(10000)
            end
        end,
    },
    [302] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(10001)
            end
        end,
    },
    [303] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(10002)
            end
        end,
    },
    [304] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(10003)
            end
        end,
    },
    [305] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(10004)
            end
        end,
    },
    [306] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(10006)
            end
        end,
    },
    [307] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(10008)
            end
        end,
    },
    [308] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(10010)
            end
        end,
    },
    [309] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(10011)
            end
        end,
    },
    [310] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(10012)
            end
        end,
    },
    [311] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(10013)
            end
        end,
    },
    [312] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(10009)
            end
        end,
    },
    [313] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(70101)
            end
        end,
    },
    [314] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(70102)
            end
        end,
    },
    [315] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(70103)
            end
        end,
    },
    [316] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(70104)
            end
        end,
    },
    [317] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(70105)
            end
        end,
    },
    [318] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(70001)
            end
        end,
    },
    [319] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(70002)
            end
        end,
    },
    [320] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(70003)
            end
        end,
    },
    [321] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(70004)
            end
        end,
    },
    [322] = {
        click_func = function(task_id)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoChangeScene(70005)
            end
        end,
    },
    
    -- 武林悬赏令
    [401] = {
        click_func = function()
            local task_id = game.WulinRewardCtrl.instance:GetAcceptTask()
            local task_cfg = game.TaskCtrl.instance:GetTaskCfg(task_id)
            local task_cond = task_cfg.finish_cond[1]
            local dun_id = task_cond[3][1]
            local dun_lv = task_cond[3][2]

            game.CarbonCtrl.instance:DungEnterReq(dun_id, dun_lv)
        end,
        check_func = function()
            local task = game.WulinRewardCtrl.instance:GetAcceptTask()
            return (task~=nil)
        end,
    },

    [402] = {
        click_func = function()
            print("恢复满血")
            local proto = {
                content = "full_hp"
            }
            game.GmCtrl.instance:SendProtocal(10601, proto)
        end,
    },
    [403] = {
        click_func = function()
            print("恢复满气")
            local proto = {
                content = "full_mp"
            }
            game.GmCtrl.instance:SendProtocal(10601, proto)
        end,
    },
    
}

local DefaultCheckFunc = function()
    return true
end

local DefaultVisibleFunc = function()
    return true
end

local et = {}
for k,v in pairs(config.npc_func) do
    local cfg = funcs[k] or et
    v.click_func = cfg.click_func
    v.name_func = cfg.name_func
    v.check_func = cfg.check_func or DefaultCheckFunc
    v.visible_func = cfg.visible_func or DefaultVisibleFunc
end