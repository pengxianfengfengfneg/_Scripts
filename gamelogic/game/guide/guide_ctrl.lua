local pnt = function(...)
    -- print(...)
end
local GuideCtrl = Class(game.BaseCtrl)

local handler = handler
local global_time = global.Time
local event_mgr = global.EventMgr
local config_func = config.func

game.GuideEvent = {
    focus_on_fight_ground = "focus_on_fight_ground",
    focus_off_fight_ground = "focus_off_fight_ground",

    focus_on_main_ground = "focus_on_main_ground",
    focus_off_main_ground = "focus_off_main_ground",

    focus_on_view = "focus_on_view",
    focus_off_view = "focus_off_view",

}
-- require("game/guide/guide_config_new_step")
local config_new_step = config.new_step or {}

local MappingGuide = {}
for guide_id, v in pairs(config_new_step) do
    local open_event = (v[1] or {}).open_event 
    if open_event ~= "nil" then
        if not MappingGuide[open_event] then
            MappingGuide[open_event] = {}
        end
        table.insert(MappingGuide[open_event], guide_id)
    end
end

function GuideCtrl:_init()
    if GuideCtrl.instance ~= nil then
        error("GuideCtrl Init Twice!")
    end
    GuideCtrl.instance = self

    self.guide_data = require("game/guide/guide_data").New(self)
    self.guide_view = require("game/guide/guide_view").New(self)
    self.guide_anger_view = require("game/guide/guide_anger_view").New(self)

    self:RegisterAllEvents()
    self:RegisterAllProtocals()

     self.is_first_login = false
     self.finish_jump_event = false
end

function GuideCtrl:_delete()
    self.guide_data:DeleteMe()

    self.guide_view:DeleteMe()
    self.guide_anger_view:DeleteMe()

    GuideCtrl.instance = nil
end

function GuideCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginSuccess, handler(self, self.SendGetFirstEnter)},
        {game.SceneEvent.CommonlyValueRespon, handler(self, self.OnCommonlyKeyValue)},
        {game.GuideEvent.focus_on_view, handler(self, self.OnFocusOnView)},
        {game.GuideEndEvent.ClickButton, handler(self, self.FinishCurGuideInfo)},
        {game.SceneEvent.FinishFirstJump, handler(self, self.DoFirstGuide)},
    }

    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function GuideCtrl:RegisterAllProtocals()
    self:RegisterProtocalCallback(25142, "OnGetGuideInfo")
end

function GuideCtrl:SendGetGuideInfo()
    -- 请求新手信息
    local proto = {

    }
    self:SendProtocal(25141,proto)
end

function GuideCtrl:OnGetGuideInfo(data)
    self.guide_data:OnGetGuideInfo(data)
end

function GuideCtrl:UpdateGuideNumReq(guide_id, do_num)
    self:SendProtocal(25143, {id = guide_id, num = do_num})
end

function GuideCtrl:OpenGuideView(guide_step_info)

    if not self.guide_view:IsOpen() then 
        self.guide_view:Open(guide_step_info)
    else
        self.guide_view:ExecuteGuide(guide_step_info)
    end
end

function GuideCtrl:CloseGuideView()
    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        main_role:SetPauseOperate(false)
    end

    self.guide_view:Close()
end

function GuideCtrl:HideGuideViewFinger()
    if self.guide_view:IsOpen() then
        self.guide_view:HideFinger()
    end
end

function GuideCtrl:SetGuideViewVisible(val)
    self.guide_view:SetVisible(val)
end

--入口1
function GuideCtrl:OnFocusOnView(param_view)

    local result = self:CheckGuide(game.GuideEvent.focus_on_view,{ view = param_view })

    if not result then
        self:StopCurGuide(param_view)
    end
end

--入口2
function GuideCtrl:CheckGuide(open_event, params)

    --优先查询下一步是否存在
    if self.next_guide then

        local next_guide_step_info = config.new_step[self.next_guide.next_guide_id][self.next_guide.next_step]
pnt("-----------检测next指引-----------",next_guide_step_info.id, next_guide_step_info.step)
        local success = self["Check_" .. open_event](self, next_guide_step_info, params)
pnt("-----------检测next指引结果-----------", success)
        if success then
            self.next_guide = nil
            self:ExecuteGuide(next_guide_step_info)
            return true
        else

            --解决多步指引时，从主界面过渡直接关闭了引导的问题(例如npc_dialog到)
            local view = params.view
            if view then
                local view_name = view:GetViewGuideName()
                if view_name ~= "ui_main/new_main_view" then
                    self.next_guide = nil
                end
            else
                self.next_guide = nil
            end
            -- self:CloseGuideView()
        end

        return false
    end


    --再查询配置表
    local action_guides = MappingGuide[open_event]
    if not action_guides then
        return false
    end

    for k, guide_id in ipairs(action_guides) do

        local guides = config_new_step[guide_id]
pnt("-----------检测config指引-----------",guides[1].id, guides[1].step)
        local success = self["Check_" .. open_event](self,guides[1], params)
pnt("-----------检测config指引结果-----------", success)
        if success then
            self:ExecuteGuide(guides[1])
            return true
        end
    end

    -- self:CloseGuideView()

    return false
end

--引导入口3
function GuideCtrl:Check_focus_on_view(guide_step_info, params)
    return self:CheckGuideConditions(guide_step_info, params)
end

function GuideCtrl:Check_open_func(guide_step_info, params)
    return self:CheckGuideConditions(guide_step_info, params)
end

function GuideCtrl:CheckGuideNums(guide_id)

    local config = config_new_step[guide_id]
    if not config then return false end
    local do_times = config[1].do_times or 1    
    return do_times > self.guide_data:GetGuideFinishTimes(guide_id)
end

--引导条件检测
function GuideCtrl:CheckGuideConditions(guide_step_info, params)

    --和当前正在引导相同 则退出
    if self.cur_guide_step_info and self.cur_guide_step_info.id == guide_step_info.id then
        return false
    end

    --新手跳跃动画播放完毕才可以执行引导
    if guide_step_info.active_cond.finish_jump_event and not self.finish_jump_event then
        return false
    end

    --次数 (指引id的第一步才需要检测次数, 非第一次就不用了)
    if guide_step_info.step == 1 and not self:CheckGuideNums(guide_step_info.id, guide_step_info.step) then
        return false
    end

    local active_params = guide_step_info.active_cond
    if not active_params or table.nums(active_params)<=0 then 
        return true 
    end

    if active_params.pre_id and not self.guide_data:IsGuideDone(active_params.pre_id) then
        -- 是否限定前置教学ID
        return false
    end

    local cur_scene = game.Scene.instance
    if not cur_scene then
        return false
    end

    local role_lv = cur_scene:GetMainRoleLevel()

    if active_params.less_lv and role_lv > active_params.less_lv then
        -- 是否小于指定等级
        return false
    end

    if active_params.cur_lv and role_lv ~= active_params.cur_lv then
        -- 是否小于指定等级
        return false
    end

    if active_params.last_lv and role_lv <= active_params.last_lv then
        -- 是否小于指定等级
        return false
    end

    -- 是否打开指定view
    if active_params.on_view then
        if not self:IsOnView(active_params.on_view[1], active_params.on_view[2]) then
            return false
        end
    end

    if active_params.func_id and active_params.func_id~=params.func_id then
        -- 是否对应功能开放id
        return false
    end

    --不可接受任务
    if active_params.lv_task then

        local task_ctrl = game.TaskCtrl.instance
        local cur_task_info = task_ctrl:GetTaskInfoById(active_params.lv_task)
        if not cur_task_info then
            return false
        elseif cur_task_info.stat ~= 0 then
            return false
        end
    end

    --当前可接收任务
    if active_params.task_id then

        local task_ctrl = game.TaskCtrl.instance
        local cur_task_info = task_ctrl:GetTaskInfoById(active_params.task_id)
        -- pnt("-------------------cur_task_id ~= active_params.task_id------", active_params.task_id, cur_task_info) if cur_task_info then PrintTable(cur_task_info) end
        if not cur_task_info then
            return false
        elseif cur_task_info.stat ~= 1 then
            return false
        end
    end

    --当前已接收任务
    if active_params.task_ing then

        local task_ctrl = game.TaskCtrl.instance
        local cur_task_info = task_ctrl:GetTaskInfoById(active_params.task_ing)
        -- pnt("-------------------cur_task_id ~= active_params.task_id------", active_params.task_ing, cur_task_info) if cur_task_info then PrintTable(cur_task_info) end
        if not cur_task_info then
            return false
        elseif cur_task_info.stat ~= 2 then
            return false
        end
    end

    --完成任务但没有提交任务
    if active_params.task_end then

        local task_ctrl = game.TaskCtrl.instance
        local cur_task_info = task_ctrl:GetTaskInfoById(active_params.task_end)
        -- pnt("-------------------cur_task_id ~= active_params.taks_end------", active_params.taks_end, cur_task_info) if cur_task_info then PrintTable(cur_task_info) end
        if not cur_task_info then
            return false
        elseif cur_task_info.stat ~= 3 then
            return false
        end
    end

    --主线任务完成
    if active_params.task_finish then
        local task_ctrl = game.TaskCtrl.instance
        local is_finish = task_ctrl:IsTaskCompleted(active_params.task_finish)
        if not is_finish then
            return false
        end
    end

    if active_params.cur_scene_id then
        
        local scene_ctrl = game.Scene.instance
        if scene_ctrl then
            local scene_id = scene_ctrl:GetSceneID()
            if scene_id ~= active_params.cur_scene_id then
                return false
            end
        else
            return false
        end
    end

    if active_params.open_func_id then

        if not game.OpenFuncCtrl.instance:IsFuncOpened(active_params.open_func_id) then
            return false
        end
    end

    --当前点击支线任务id
    if active_params.cur_click_task_id then
        if self.cur_click_task_id ~= active_params.cur_click_task_id then
            return false
        end
    end

    return true
end

function GuideCtrl:IsOnView(view_name, view_index)

    local top_view = game.ViewMgr:GetTopView()
    pnt("-------------------IsOnView------", top_view:GetViewGuideName(), view_name, top_view:GetGuideIndex(), view_index)
    if top_view:GetViewGuideName() ~= view_name then
        return false
    end

    if view_index and top_view:GetGuideIndex() ~= view_index then
        return false
    end

    return true
end

--执行引导按钮显示  guide_step_infos : 整个步骤的信息
function GuideCtrl:ExecuteGuide(guide_step_info)
--print("---------执行一个引导----------",guide_step_info.id)

    if guide_step_info.delay > 0 then
        self:DeleteDelayTimer()
        local elapse_time = 0
        self.delay_timer = global.TimerMgr:CreateTimer(0.5,
        function()
            elapse_time = elapse_time + 0.5
            if elapse_time >= guide_step_info.delay then
                self.cur_guide_step_info = guide_step_info
                self:OpenGuideView(guide_step_info)
                self:DeleteDelayTimer()
            end
        end)
    else
        self.cur_guide_step_info = guide_step_info
        self:OpenGuideView(guide_step_info)
    end
end

function GuideCtrl:DeleteDelayTimer()
    if self.delay_timer then
        global.TimerMgr:DelTimer(self.delay_timer)
        self.delay_timer = nil
    end
end

--结束该指引入口
function GuideCtrl:FinishCurGuideInfo(params)

    if self.cur_guide_step_info then

        local can_finish = self:FinishConditionCheck(params)
-- print("-------------结束当前指引-------------------",self.cur_guide_step_info.id, self.cur_guide_step_info.step, can_finish, self.next_guide)
        if can_finish then

            self:DeleteDelayTimer()

            --还有下一步指引，关闭手指, 不关界面
            if self.next_guide then

                self:HideGuideViewFinger()
            else
            --没有下一步直接关闭界面
                self.guide_data:UpdateGuideNum(self.cur_guide_step_info)
                self:CloseGuideView()
            end

            self.cur_guide_step_info = nil
            self.cur_click_task_id = nil
        end
    end
end

--结束指引 条件判断
function GuideCtrl:FinishConditionCheck(params)
    if not self.cur_guide_step_info then
        return true
    end

    if not next(self.cur_guide_step_info.next_cond) then
        return true
    end

    local next_cond = self.cur_guide_step_info.next_cond

    local net_id = next_cond.net_id
    if net_id and params.net_id and params.net_id == net_id then
        self:ExistNextCond(self.cur_guide_step_info.id, self.cur_guide_step_info.step)
        return true
    end

    local on_view = next_cond.on_view
    if on_view and params.on_view == on_view[1] then
        self:ExistNextCond(self.cur_guide_step_info.id, self.cur_guide_step_info.step)
        return true
    end

    local click_btn_name = next_cond.click_btn_name
    if click_btn_name and params.click_btn_name == click_btn_name then
        self:ExistNextCond(self.cur_guide_step_info.id, self.cur_guide_step_info.step)
        return true
    end

    return false
end

function GuideCtrl:ExistNextCond(cur_guide_id, cur_step)

    local exist = false

    if config.new_step[cur_guide_id] and config.new_step[cur_guide_id][cur_step+1] then
        exist = true
    end

    if exist then
        self.next_guide = {next_guide_id = cur_guide_id, next_step = cur_step+1}
    end
end

function GuideCtrl:OpenFirstEnterTips()
    if not self.first_enter_tips then
        self.first_enter_tips = require("game/guide/first_enter_tips").New()
    end
    self.first_enter_tips:Open()
end

--打开不影响指引界面
local not_stop_guide_view_list = {
    ["ui_open_func/open_func_view"] = true,
    ["ui_game_msg/msg_view"] = true,
    ["ui_game_msg/msg_tips_view"] = true,
    ["ui_game_msg/msg_box_view"] = true,
    ["ui_game_msg/waiting_view"] = true,
    ["ui_role/role_update_power_view"] = true,
    ["ui_guide/ui_first_enter_tips"] = true,
    ["ui_main/rumor_view"] = true,
    ["ui_activity/activity_open_tips"] = true,
    ["ui_main/quick_use_view"] = true,
    ["ui_main/drop_item_view"] = true,
    ["ui_open_func/open_func_view"] = true,
    ["ui_hero/hero_active_view"] = true,
    ["ui_chat/chat_horn_view"] = true,
    ["ui_guild/guild_seat_view"] = true,
}

--手动打开其他界面 终止当前整个指引
function GuideCtrl:StopCurGuide(open_view)

    self:DeleteDelayTimer()

    if self.cur_guide_step_info then

        local active_cond = self.cur_guide_step_info.active_cond
        local on_view = active_cond.on_view

        if on_view then

            if not_stop_guide_view_list[open_view:GetViewGuideName()] then
                return
            end
            if open_view:GetViewGuideName() ~= on_view[1] then
                --完成当前指引
                self:CloseGuideView()
                self.guide_data:UpdateGuideNum(self.cur_guide_step_info)
                self.cur_guide_step_info = nil
                self.cur_click_task_id = nil
                return
            end

            if on_view[2] then
                if open_view:GetGuideIndex() ~= on_view[2] then
                    self:CloseGuideView()
                    self.cur_guide_step_info = nil
                    self.cur_click_task_id = nil
                end
            end
        end
    end
end

function GuideCtrl:GetData()
    return self.guide_data
end

function GuideCtrl:SendGetFirstEnter()
    local proto = {
        key = game.CommonlyKey.FirstEnter
    }
    self:SendProtocal(10505, proto)
end

function GuideCtrl:SendSetFirstEnter()
    local proto = {
        key = game.CommonlyKey.FirstEnter,
        value = 1,
    }
    self:SendProtocal(10507, proto)
end

function GuideCtrl:OnCommonlyKeyValue(data)

    local id = data.key
    if id == game.CommonlyKey.FirstEnter then

        if data.value == 0 then
            self.is_first_login = true
            self:SendSetFirstEnter()
        else
            self.is_first_login = false
        end
    end
end

function GuideCtrl:GetFirstEnterFlag()
    return self.is_first_login
end

function GuideCtrl:OpenGuideAngerView()
    self.guide_anger_view:Open()
end

function GuideCtrl:CloseGuideAngerView()
    self.guide_anger_view:Close()
end

function GuideCtrl:DoFirstGuide()
    self.finish_jump_event = true
    game.ViewMgr:FireGuideEvent()
end

function GuideCtrl:IsOpenView()
    return self.guide_view:IsOpen() or self.guide_anger_view:IsOpen()
end

function GuideCtrl:GetGuideView()
    return self.guide_view
end

function GuideCtrl:SetCurClickTaskId(task_id)
    self.cur_click_task_id = task_id
end

function GuideCtrl:CheckTabHideGuide(bot_func_page)

    if self.cur_guide_step_info then

        if self.cur_guide_step_info["open_view"][1] == "MainUICtrl" then

            if bot_func_page == 1 then
                self:ShowGuideView()
            else
                self:HideGuideView()
            end
        end

        if self.cur_guide_step_info["active_cond"]["on_view"][1] == "ui_foundry/foundry_view2" then
            local params2 = self.cur_guide_step_info["active_cond"]["on_view"][2]
            if params2 then
                if bot_func_page == params2 then
                    self:ShowGuideView()
                else
                    self:HideGuideView()
                end
            end 
        end

        if self.cur_guide_step_info["active_cond"]["on_view"][1] == "ui_activity/activity_hall_view" then
            local params2 = self.cur_guide_step_info["active_cond"]["on_view"][2]
            if params2 then
                if bot_func_page == params2 then
                    self:ShowGuideView()
                else
                    self:HideGuideView()
                end
            end 
        end
    end
end

function GuideCtrl:ShowGuideView()
    local guide_view = self:GetGuideView()
    if guide_view and guide_view:IsOpen() then
        guide_view:ShowLayout()
    end
end

function GuideCtrl:HideGuideView()
    local guide_view = self:GetGuideView()
    if guide_view and guide_view:IsOpen() then
        guide_view:HideLayout()
    end
end

game.GuideCtrl = GuideCtrl

return GuideCtrl
