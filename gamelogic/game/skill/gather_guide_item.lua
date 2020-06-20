local GatherGuideItem = Class(game.UITemplate)

function GatherGuideItem:_init()
    
end

function GatherGuideItem:OpenViewCallBack()
    self:Init()
end

function GatherGuideItem:CloseViewCallBack()
    if self.goods_item then
        self.goods_item:DeleteMe()
        self.goods_item = nil
    end
end

function GatherGuideItem:Init()
    local item_obj = self._layout_objs["n1"]
    self.goods_item = game_help.GetGoodsItem(item_obj)

    self.txt_coll_name = self._layout_objs["n2"]
    self.txt_gather_need = self._layout_objs["n3"]
    self.txt_gather_gain = self._layout_objs["n5"]

    self.btn_gather = self._layout_objs["n6"]
    self.btn_gather:AddClickCallBack(function()
        self:GoToGather()
    end)
end

function GatherGuideItem:UpdateData(cfg, info)
    self.gather_skill_id = cfg.id
    self.gather_skill_name = cfg.name
    self.gather_target_pos = cfg.target_pos
    self.gather_id = cfg.coll

    local coll_cfg = config.gather[cfg.coll]
    self.txt_coll_name:SetText(coll_cfg.name)

    self.txt_gather_need:SetText(string.format(config.words[5453], cfg.name, cfg.level))

    local drop_cfg = config.drop[cfg.reward]
    local drop_item_id = drop_cfg.client_goods_list[1][1]
    local drop_item_cfg = config.goods[drop_item_id]

    self.txt_gather_gain:SetText(string.format(config.words[5454], drop_item_cfg.name))

    self.goods_item:SetItemInfo({id=drop_item_id, num=0})
    self.goods_item:SetItemImage(cfg.icon)

    self.is_gather_open = info.level>=cfg.level
    self.btn_gather:SetGray(not self.is_gather_open)
end

function GatherGuideItem:GoToGather()
    if not self.is_gather_open then
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[5455], self.gather_skill_name))
        return
    end

    local main_role = game.Scene.instance:GetMainRole()
    -- main_role:GetOperateMgr():DoGoToScenePos(self.gather_target_pos.id, self.gather_target_pos.x*0.5, self.gather_target_pos.y*0.5, function()
    --     local main_role = game.Scene.instance:GetMainRole()
    --     main_role:GetOperateMgr():DoHangGather()
    -- end)

    main_role:GetOperateMgr():DoHangGather(self.gather_id, self.gather_target_pos.x*0.5, self.gather_target_pos.y*0.5, self.gather_target_pos.id, 
        function()
            return game.GatherCtrl.instance:GetGatherVitality()
        end, 
        function()
            game.GameMsgCtrl.instance:PushMsg(config.words[5460])
        end)

    game.SkillCtrl.instance:CloseView()
end

return GatherGuideItem