local Gather = Class(require("game/character/character"))

local _event_mgr = global.EventMgr
local handler = handler

local _model_type = game.ModelType
local _config_gather = config.gather
local _monster_size = game.MonsterSizeCfg

function Gather:_init()
    self.obj_type = game.ObjType.Gather
    self.update_cd = 60
end

function Gather:_delete()

end

function Gather:Reset()
    self:UnRegisterAllEvents()
    self:ClearGatherEffect()

    self.model_height = nil

    Gather.super.Reset(self)
end

function Gather:Init(scene, vo)
    Gather.super.Init(self, scene, vo)

    self.vo = vo
    self.uniq_id = vo.id
    self.gather_id = vo.coll_cid
    self:SetLogicPos(vo.x, vo.y)

    self.gather_cfg = _config_gather[vo.coll_cid]

    if self.gather_cfg.model_id ~= 0 then
        self:CreateDrawObj()
        self:ShowShadow(true)        
    end

    self.is_show_name = (self.gather_cfg.show_name==0)
    self:SetHudText(game.HudItem.Name, self.gather_cfg.name, 3)
    self:SetHudItemVisible(game.HudItem.Name, self.is_show_name)

    self:RegisterAllEvents()
end

function Gather:RegisterAllEvents()
    if game.TaskCtrl.instance:IsTaskGather(self:GetGatherId()) then
        self.ev_list = {
            _event_mgr:Bind(game.TaskEvent.OnUpdateTaskInfo, handler(self, self.OnUpdateTaskInfo)),
            _event_mgr:Bind(game.TaskEvent.OnAcceptTask, handler(self, self.OnAcceptTask)),
        }

        self:UpdateTaskShow()
    end
end

function Gather:UnRegisterAllEvents()
    if self.ev_list then
        for i,v in ipairs(self.ev_list) do
            _event_mgr:UnBind(v)
        end
        self.ev_list = nil
    end
end

-- 外观形象相关
function Gather:CreateDrawObj()
    self.draw_obj = game.GamePool.DrawObjPool:Create()
    self.draw_obj:Init(game.BodyType.Gather)
    self.draw_obj:SetParent(self.root_obj.tran)

    self.draw_obj:SetModelID(_model_type.Body, self.gather_cfg.model_id)

    self.draw_obj:PlayLayerAnim(_model_type.Body, game.ObjAnimName.Idle)

    self:SetClickCallBack(handler(self,self.OnGatherClick), 1)
end

function Gather:OnGatherClick()
    if self.scene:CanDoGather(self) then
        local main_role = self.scene:GetMainRole()
        if main_role then
            if self.vo.owner_id ~= 0 and self.vo.owner_id ~= main_role.vo.role_id then
                game.GameMsgCtrl.instance:PushMsg(config.words[5461])
                return
            end
            local ux,uy = self:GetUnitPosXY()
            local res = game.GatherCtrl.instance:DoHangGather(self:GetGatherId(), ux, uy, self.scene:GetSceneID(), self.obj_id)
            if not res then
                main_role:GetOperateMgr():DoGoToGather(self.obj_id)
            end
        end
    end
end

function Gather:GetDuration(is_quick, offset)
    local dur = (is_quick and self.gather_cfg.quick_dur or self.gather_cfg.duration)
    offset = offset or 0.2
    return dur * 0.001 + offset
end

function Gather:GetName()
    return self.gather_cfg.name
end

function Gather:SetState(stat)
    self.vo.stat = stat
end

function Gather:GetState()
    -- (1:初始 6:被采集 7:被占有)
    return self.vo.stat
end

function Gather:GetGatherId()
    return self.gather_id
end

function Gather:CanBeAttack()
    return false
end

function Gather:OnUpdateTaskInfo()
   self:UpdateTaskShow() 
end

function Gather:OnAcceptTask()
    self:UpdateTaskShow() 
end

function Gather:UpdateTaskShow()
    local res = game.TaskCtrl.instance:CanDoTaskGather(self:GetGatherId())
    if res then
        self:SetClickCallBack(handler(self,self.OnGatherClick), 1)
        self:SetHudItemVisible(game.HudItem.Name, self.is_show_name)

        self:ShowGatherEffect()
    else
        self:SetClickCallBack(nil, 1)
        self:SetHudItemVisible(game.HudItem.Name, false)

        self:ClearGatherEffect()
    end
end

function Gather:ShowGatherEffect()
    if not self.target_effect and self.gather_cfg.effect ~= "" then
        self.target_effect = game.EffectMgr.instance:CreateEffect(string.format("effect/scene/%s.ab", self.gather_cfg.effect), 10)
        self.target_effect:SetLoop(true)
        self.target_effect:SetParent(self:GetRoot())
    end
end

function Gather:ClearGatherEffect()
    if self.target_effect then
        game.EffectMgr.instance:StopEffect(self.target_effect)
        self.target_effect = nil
    end
end

function Gather:GetModelHeight()
    if self.model_height == nil then
        local cfg = _config_gather[self.gather_id]
        local model_id = cfg.model_id
        if cfg.model_height == 0 then
            if _monster_size[model_id] then
                self.model_height = _monster_size[model_id][2] + 0.3
            else
                self.model_height = 2
            end
        else
            self.model_height = cfg.model_height
        end
    end

    return self.model_height
end

return Gather
