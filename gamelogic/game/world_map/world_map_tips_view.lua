local WorldMapTipsView = Class(game.BaseView)

local config_world_map = config.world_map
local config_world_map_sort = config.world_map_sort

function WorldMapTipsView:_init(ctrl)
    self._package_name = "ui_world_map"
    self._com_name = "world_map_tips_view"

    self._ui_order = game.UIZOrder.UIZOrder_Common_Beyond

    self._view_level = game.UIViewLevel.Fouth
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function WorldMapTipsView:OpenViewCallBack(map_cfg)
	self:Init(map_cfg)
    self:InitBg()
end

function WorldMapTipsView:CloseViewCallBack()
    for _,v in ipairs(self.list_items or {}) do
        v:DeleteMe()
    end
    self.list_items = {}
end

function WorldMapTipsView:Init(map_cfg)
    self.scene_id = map_cfg.id
    self.pass_id = map_cfg.pass
    self.open_lv = map_cfg.lv
    self.is_pass_scene = (map_cfg.is_pass==1)

    local cur_scene_id = game.Scene.instance:GetSceneID()

    local scene_cfg = config.scene[self.scene_id]
    local scene_name = scene_cfg.name


    local txt_name = self._layout_objs["txt_name"]
    txt_name:SetText(scene_name)

    local txt_desc = self._layout_objs["txt_desc"]
    local group_cond = self._layout_objs["group_cond"]
    local txt_cond_lv = self._layout_objs["txt_cond_lv"]
    local txt_cond_pass = self._layout_objs["txt_cond_pass"]
    
    self.is_open = self:CheckOpen()

    txt_desc:SetVisible(self.is_open)
    group_cond:SetVisible(not self.is_open)

    if self.is_pass_scene then
        -- 关卡地图
        if self.pass_id then
            if self.is_open then
                local cur_pass_id = game.PassBossCtrl.instance:GetCurPassId()
                local word_id = (cur_pass_id>self.pass_id and 2400 or 2401)

                txt_desc:SetText(config.words[word_id])
            else
                local pre_pass_id = self.pass_id - 1
                if pre_pass_id > 0 then
                    local pre_pass_cfg = config.task_pass[pre_pass_id]
                    local pre_scene_id = pre_pass_cfg.scene
                    local pre_scene_cfg = config.scene[pre_scene_id]

                    txt_cond_lv:SetText(string.format(config.words[2402], self.open_lv))
                    txt_cond_pass:SetText(string.format(config.words[2403], pre_scene_cfg.name))
                end
            end
        else
            -- 没有开放
            txt_desc:SetText(config.words[2407])
            txt_desc:SetVisible(true)
            group_cond:SetVisible(false)
        end
    else
        -- 非关卡地图
        if self.is_open then
            txt_desc:SetText(config.words[2400])
        else
            txt_cond_lv:SetText(string.format(config.words[2402], self.open_lv))
            txt_cond_pass:SetText("")
        end
    end

    
    local word_id = 2406
    if not self.is_open or (self.scene_id==cur_scene_id) then
        word_id = 2405
    end

    if game.IsZhuanJia then
        txt_desc:SetVisible(false)

        group_cond:SetVisible(true)
        txt_cond_lv:SetText(string.format(config.words[2402], self.open_lv))
        txt_cond_pass:SetText("")
    end

    local btn_enter = self._layout_objs["btn_enter"]
    btn_enter:SetText(config.words[word_id])
    btn_enter:AddClickCallBack(function()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_world_map/world_map_tips_view/btn_enter"})
        self:Close()
        if self.is_open then            
            if self.scene_id == cur_scene_id then
                game.GameMsgCtrl.instance:PushMsg(config.words[2408])
            else
                self.ctrl:CloseView()

                local main_role = game.Scene.instance:GetMainRole()
                if main_role then
                    main_role:GetOperateMgr():DoChangeScene(self.scene_id)
                end
            end
            return
        end
        game.GameMsgCtrl.instance:PushMsg(config.words[2404])
	end)
end

function WorldMapTipsView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1660]):HideBtnBack()
end

function WorldMapTipsView:OnEmptyClick()
    self:Close()
end

function WorldMapTipsView:CheckOpen()
    return self.ctrl:IsMapOpened(self.scene_id)
end

return WorldMapTipsView
