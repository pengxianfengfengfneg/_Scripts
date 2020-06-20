local GuildDefendChoseView = Class(game.BaseView)

function GuildDefendChoseView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_defend_chose_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First
end

function GuildDefendChoseView:OpenViewCallBack(tripod_info)
    self.tripod_info = tripod_info
    self:Init()
    self:InitNpcModel()
end

function GuildDefendChoseView:CloseViewCallBack()
	self:ClearModel()
end

function GuildDefendChoseView:Init()
    self.txt_name = self._layout_objs.txt_name

    self._layout_objs.btn_tripod_1:AddClickCallBack(function()
        self:ChoseTripod(1)
    end)

    self._layout_objs.btn_tripod_2:AddClickCallBack(function()
        self:ChoseTripod(2)
    end)

    self._layout_objs.btn_tripod_3:AddClickCallBack(function()
        self:ChoseTripod(3)
    end)

    self._layout_objs.btn_close:AddClickCallBack(function()
        self:Close()
    end)
end

function GuildDefendChoseView:ChoseTripod(id)
    local tripod = self.tripod_info[id]
    local unit_x, unit_y = game.LogicToUnitPos(tripod.x, tripod.y)
    local dist = 2
    local main_role = game.Scene.instance:GetMainRole()

    main_role:GetOperateMgr():DoGoToScenePos(main_role.scene:GetSceneID(), unit_x, unit_y, function()
        main_role:GetOperateMgr():DoSceneHang()
    end, dist)

    self:Close()
end

function GuildDefendChoseView:InitNpcModel()
    if not self.npc_model then
        self.npc_model = require("game/character/model_template").New()
        self.npc_model:CreateDrawObj(self._layout_objs.wrapper, game.BodyType.ModelSp)
        
        self.npc_model:SetModelChangeCallBack(function()
            self.npc_model:SetRotation(0, 180, 0)

            self.npc_model:SetScale(self.npc_talk_zoom or 1)
        end)

        local npc_id = 2008
        local npc_cfg = config.npc[npc_id]

        self.npc_model:SetPosition(-0.16, -1.43, 2.03)
    
        if npc_cfg.spine_id > 0 then
            self.npc_model:SetModel(game.ModelType.Body, npc_cfg.spine_id)
            self.npc_model:PlayAnim(game.ObjAnimName.Show1)
        else
            self.npc_model:SetBodyType(game.BodyType.Monster)
            self.npc_model:SetModel(game.ModelType.Body, npc_cfg.model_id)
            self.npc_model:PlayAnim(game.ObjAnimName.Idle)
        end
        self.txt_name:SetText(npc_cfg.name)
    end
end

function GuildDefendChoseView:ClearModel()
	if self.npc_model then
		self.npc_model:DeleteMe()
		self.npc_model = nil
	end
end

return GuildDefendChoseView
