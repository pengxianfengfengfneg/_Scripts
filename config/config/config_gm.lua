config.gm = {
    [1] = {
        name = "物品",

        {
            type = 1,
            cheat = "give_drop_1002",
            desc = "新手大禮包",
            param = 0,
        },
        {
            type = 1,
            cheat = "add_money_%s_%s",
            desc = "增加金錢(type,num)",
            param = 2,
        },
        {
            type = 1,
            cheat = "reset_money_%s",
            desc = "重置金錢(type)",
            param = 1,
        },
        {
            type = 1,
            cheat = "add_item_%s_%s",
            desc = "增加物品(id,num)",
            param = 2,
        },
        {
            type = 1,
            cheat = "add_limit_item_%s_%s",
            desc = "增加限時物品(id,num)",
            param = 2,
        },
        {
            type = 1,
            cheat = "give_drop_%s",
            desc = "獲取掉落包",
            param = 1,
        },
        {
            type = 1,
            cheat = "clear_bag",
            desc = "清除背包過期物品",
            param = 0,
        },
        {
            type = 1,
            cheat = "clean_bag",
            desc = "整理背包",
            param = 0,
        },
        {
            type = 1,
            cheat = "add_exp_%s",
            desc = "增加經驗",
            param = 1,
        },
        {
            type = 1,
            cheat = "recharge_%s",
            desc = "充值[1-18]",
            param = 1,
        },
        {
            type = 1,
            cheat = "add_guild_funds_%s",
            desc = "增加幫派資金",
            param = 1,
        },
        {
            type = 1,
            cheat = "reduce_guild_funds_%s",
            desc = "減少幫派資金",
            param = 1,
        },
        {
            type = 1,
            cheat = "add_bind_item_%s_%s",
            desc = "增加綁定物品",
            param = 2,
        },
        {
            type = 1,
            cheat = "max_pra",
            desc = "幫派修煉拉滿",
            param = 0,
        },
        {
            type = 1,
            cheat = "grant_title_%s",
            desc = "獲得稱號",
            param = 1,
        },
        {
            type = 1,
            cheat = "set_lv_%s",
            desc = "設置等級",
            param = 1,
        },
        {
            type = 1,
            func = function(param1, param2)
                local scene = game.Scene.instance
                local scene_cfg = scene:GetSceneConfig()

                local list = {}
                local UnitToLogicPos = game.UnitToLogicPos
                for _,v in pairs(scene_cfg.gather_list or {}) do
                    local x,y = UnitToLogicPos(v.x, v.y)
                    if not scene:IsWalkable(x,y) then
                        table.insert(list, string.format("采集物-%s", v.gather_id))
                    end
                end

                for _,v in pairs(scene_cfg.npc_list or {}) do
                    local x,y = UnitToLogicPos(v.x, v.y)
                    if not scene:IsWalkable(x,y) then
                        table.insert(list, string.format("NPC-%s", v.npc_id))
                    end
                end

                for _,v in pairs(scene_cfg.door_list or {}) do
                    local x,y = UnitToLogicPos(v.pos_x, v.pos_y)
                    if not scene:IsWalkable(x,y) then
                        table.insert(list, string.format("傳送門-%s", v.scene_id))
                    end
                end

                for k,v in pairs(scene_cfg.jump_list or {}) do
                    local from = v.from
                    local to = v.to

                    local x,y = UnitToLogicPos(from.x, from.z)
                    if not scene:IsWalkable(x,y) then
                        table.insert(list, string.format("跳點from-%s", k))
                    end

                    local x,y = UnitToLogicPos(to.x, to.z)
                    if not scene:IsWalkable(x,y) then
                        table.insert(list, string.format("跳點to-%s", k))
                    end
                end

                for _,v in pairs(scene_cfg.monster_list or {}) do
                    for _,cv in pairs(v) do
                        if not scene:IsWalkable(cv.x, cv.y) then
                            table.insert(list, string.format("怪物-%s", cv.monster_id))
                        end
                    end
                end

                if #list > 0 then
                    local str_list = table.concat(list, "|")
                    local msg_view = game.GameMsgCtrl.instance:CreateMsgBox("位置錯誤", str_list)
                    msg_view:Open()
                else
                    game.GameMsgCtrl.instance:PushMsg("檢測正常")
                end
            end,
            desc = "檢測場景obj位置",
            param = 0,
        },
    },

    [2] = {
        name = "功能",
        {
            type = 1,
            cheat = "reset_territory",
            desc = "重置領地戰數據",
            param = 0,
        },
        {
            type = 1,
            cheat = "active_func_%s",
            desc = "開放XX功能",
            param = 1,
        },
        {
            type = 1,
            cheat = "active_all_func",
            desc = "開放所有功能",
            param = 0,
        },
        {
            type = 1,
            desc = "跳轉場景",
            param = 1,
            func = function(param1, param2)
                --game.Scene.instance:SendChangeSceneReq(tonumber(param1))
                local main_role = game.Scene.instance:GetMainRole()
                main_role:GetOperateMgr():DoChangeScene(tonumber(param1))
                game.GmCtrl.instance:CloseView()
            end
        },
        {
            type = 1,
            cheat = "finish_task",
            desc = "完成當前任務",
            param = 0,
        },
        {
            type = 1,
            cheat = "finish_till_%s",
            desc = "完成到指定任務",
            param = 1,
        },
        {
            type = 1,
            cheat = "accept_task_%s",
            desc = "接受指定任務",
            param = 1,
        },
        {
            type = 1,
            desc = "是否自動掛機(0/1)",
            param = 1,
            func = function(param1)
                local main_role = game.Scene.instance:GetMainRole()
                local scene_logic = game.Scene.instance:GetSceneLogic()
                local oper_type = scene_logic:GetHangOperate()
                if tonumber(param1) == 0 then
                    oper_type = nil
                end
                main_role:GetOperateMgr():ClearOperate()
                main_role:GetOperateMgr():SetDefaultOper(oper_type)
            end
        },
        {
            type = 1,
            cheat = "mail",
            desc = "無附件郵件",
            param = 0,
        },
        {
            type = 1,
            cheat = "attach_mail",
            desc = "帶附件郵件",
            param = 0,
        },
        {
            type = 1,
            desc = "進入副本",
            param = 1,
            func = function(param1)
                game.CarbonCtrl.instance:DungEnterReq(tonumber(param1), 1)
            end,
        },
        {
            type = 1,
            cheat = "reset_dung_%s",
            desc = "重置副本ID",
            param = 1,
        },
        {
            type = 1,
            cheat = "reset_all_dung",
            desc = "重置All副本",
            param = 0,
        },
        {
            type = 1,
            cheat = "set_vip_lv_%s",
            desc = "設置Vip等級",
            param = 1,
        },
        {
            type = 1,
            cheat = "refresh_rank_%d",
            desc = "刷新排行榜",
            param = 1,
        },
        {
            type = 1,
            cheat = "empty_bag_%s",
            desc = "清空背包(id)",
            param = 1,
        },
        {
            type = 1,
            cheat = "start_activity_%s",
            desc = "開啟活動",
            param = 1,
        },
        {
            type = 1,
            cheat = "stop_activity_%s",
            desc = "關閉活動",
            param = 1,
        },
        {
            type = 1,
            cheat = "optime_%s",
            desc = "修改開服天數(重啟失效)",
            param = 1,
        },
        {
            type = 1,
            cheat = "optime2_%s",
            desc = "修改開服天數",
            param = 1,
        },
        {
            type = 1,
            cheat = "mgtime_%s_%s",
            desc = "修改合服次數,天數",
            param = 2,
        },
        {
            type = 1,
            cheat = "jousts_%s",
            desc = "演武堂階段",
            param = 1,
        },
        {
            type = 1,
            cheat = "close_guild_activity",
            desc = "關閉所有幫派活動",
            param = 0,
        },
        {
            type = 1,
            cheat = "finish_all_achieve",
            desc = "完成所有成就",
            param = 0,
        },
        {
            type = 1,
            cheat = "finish_achieve_%s",
            desc = "完成指定成就",
            param = 1,
        },
        {
            type = 1,
            cheat = "finish_achieve_type_%s",
            desc = "完成指定類型成就",
            param = 1,
        },
        {
            type = 1,
            cheat = "reset_circle",
            desc = "重置跑環任務",
            param = 0,
        },
        {
            type = 1,
            cheat = "active_artifact",
            desc = "激活神器",
            param = 0,
        },
        {
            type = 1,
            cheat = "reset_activity_enter_times_%s",
            desc = "重置進入活動次數",
            param = 1,
        },
    },

    [3] = {
        name = "屬性",
        {
            type = 1,
            cheat = "full_hp",
            desc = "滿血",
            param = 0,
        },
        {
            type = 1,
            cheat = "empty_hp",
            desc = "空血",
            param = 0,
        },
        {
            type = 1,
            cheat = "full_mp",
            desc = "滿藍",
            param = 0,
        },
        {
            type = 1,
            cheat = "empty_mp",
            desc = "空藍",
            param = 0,
        },
        {
            type = 1,
            cheat = "powerful",
            desc = "爆發（20倍）",
            param = 0,
        },
        {
            type = 1,
            cheat = "weakness",
            desc = "虛弱（1/20倍）",
            param = 0,
        },
        {
            type = 1,
            cheat = "oripower",
            desc = "恢復戰力",
            param = 0,
        },
        {
            type = 1,
            cheat = "alter_attr_%s_%s",
            desc = "修改屬性",
            param = 2,
        },
    },

    [4] = {
        name = "戰鬥",
        {
            type = 1,
            cheat = "summon_%s_%s",
            desc = "召喚怪物",
            param = 2,
        },
        {
            type = 1,
            cheat = "reload_mons",
            desc = "重載怪物",
            param = 0,
        },
        {
            type = 1,
            cheat = "add_effect_%s_%s",
            desc = "增加buff",
            param = 2,
        },
        {
            type = 1,
            cheat = "del_effect_%s",
            desc = "刪除buff",
            param = 1,
        },
        {
            type = 1,
            cheat = "add_peffect_%s_%s",
            desc = "增加寵物buff",
            param = 2,
        },
        {
            type = 1,
            cheat = "del_peffect_%s_%s",
            desc = "刪除寵物buff",
            param = 2,
        },
        {
            type = 1,
            cheat = "presure_test_%s",
            desc = "壓測",
            param = 1,
        },
    },

    [5] = {
        name = "其他",
        {
            type = 1,
            desc = "資源監控",
            param = 0,
            func = function()
                game.MonitorCtrl.instance:ToggleView()
            end
        },
        {
            type = 1,
            desc = "GC",
            param = 0,
            func = function()
                collectgarbage("collect")
                N3DClient.GameTool.RunGC()
            end
        },
        {
            type = 1,
            desc = "Free Res",
            param = 0,
            func = function()
                global.AssetLoader:UnLoadUnuseBundle()
            end
        },
        {
            type = 1,
            desc = "系統信息",
            param = 0,
            func = function()
                local cpu = UnityEngine.SystemInfo.processorType
                local cpu_freq = UnityEngine.SystemInfo.processorFrequency
                local cpu_num = UnityEngine.SystemInfo.processorCount
                local gpu = UnityEngine.SystemInfo.graphicsDeviceName
                local gpu_mem = UnityEngine.SystemInfo.graphicsMemorySize
                local mem_size = UnityEngine.SystemInfo.systemMemorySize
                game.GameMsgCtrl.instance:PushMsg("CPU:" .. cpu)
                game.GameMsgCtrl.instance:PushMsg(string.format("CPU Info: %d x[%d]", cpu_freq, cpu_num))
                game.GameMsgCtrl.instance:PushMsg("GPU:" .. gpu)
                game.GameMsgCtrl.instance:PushMsg(string.format("GPU Info: %d", gpu_mem))
                game.GameMsgCtrl.instance:PushMsg("Memory:" .. mem_size)
            end
        },
        {
            type = 1,
            desc = "顯示背包格子",
            param = 0,
            func = function()
                game.BagCtrl.instance:SetShowBagCell()
            end
        },
        {
            type = 1,
            desc = "LightMap調試",
            param = 1,
            func = function(param)
                if param == "1" then
                    UnityEngine.Shader.EnableKeyword("_G_LIGHTMAP_ON")
                else
                    UnityEngine.Shader.DisableKeyword("_G_LIGHTMAP_ON")
                end
            end
        },
        {
            type = 1,
            desc = "Fog調試",
            param = 1,
            func = function(param)
                if param == "1" then
                    UnityEngine.Shader.EnableKeyword("FOG_LINEAR")
                else
                    UnityEngine.Shader.DisableKeyword("FOG_LINEAR")
                end
            end
        },
        {
            type = 1,
            desc = "效果",
            param = 1,
            func = function(param)
                local scene_camera = game.RenderUnit:GetSceneCamera()
                if param == "0" then
                    scene_camera:StopImageEffect()
                elseif param == "1" then
                    scene_camera:StartImageEffect(game.MaterialEffect.EffectCommon,0,1,false)
                end
            end
        },
        {
            type = 1,
            desc = "調試特效",
            param = 0,
            func = function()
                game.EffectMgr.instance:Debug()
            end
        },
        {
            type = 1,
            desc = "檢查行走區",
            param = 2,
            func = function(param1, param2)
                local ret = game.Scene.instance:IsWalkable(tonumber(param1), tonumber(param2))
                local main_role = game.Scene.instance:GetMainRole()
                if ret then
                    print("NoBlock", param1, param2, main_role.logic_pos.x, main_role.logic_pos.y)
                else
                    print("Block", param1, param2, main_role.logic_pos.x, main_role.logic_pos.y)
                end
            end
        },
        {
            type = 1,
            desc = "展示行走區",
            param = 0,
            func = function()
                game.Scene.instance:ShowBlockBox()
            end
        },
    },
}