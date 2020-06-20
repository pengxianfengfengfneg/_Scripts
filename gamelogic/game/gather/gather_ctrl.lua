local GatherCtrl = Class(game.BaseCtrl)

local string_format = string.format
local config_gather_skill = config.gather_skill

function GatherCtrl:_init()
    if GatherCtrl.instance ~= nil then
        error("GatherCtrl Init Twice!")
    end
    GatherCtrl.instance = self

    self.data = require("game/gather/gather_data").New()

    self.quick_gather_flag = 0

    self:RegisterAllEvents() 
    self:RegisterAllProtocals()
end

function GatherCtrl:_delete()
    self.data:DeleteMe()

    
    GatherCtrl.instance = nil
end

function GatherCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginSuccess, handler(self,self.OnLoginSuccess)},
        {game.SceneEvent.CommonlyValueRespon, handler(self,self.CommonlyValueRespon)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function GatherCtrl:RegisterAllProtocals()
    self:RegisterProtocalCallback(20802, "OnGatherInfo")
    self:RegisterProtocalCallback(20804, "OnGatherUpgrade")
    self:RegisterProtocalCallback(20806, "OnGatherColl")

end

function GatherCtrl:OnLoginSuccess()
    self:SendGatherInfo()
    self:SendGatherQuickGather()
end

function GatherCtrl:SendGatherInfo()
    local proto = {

    }
    self:SendProtocal(20801, proto)
end

function GatherCtrl:OnGatherInfo(data)
    --[[
        "vitality__H",
        "skills__T__id@H##level@C##exp@H",
    ]]
    -- PrintTable(data)

    self.data:OnGatherInfo(data)

    self:FireEvent(game.GatherEvent.OnGatherInfo)
end

function GatherCtrl:SendGatherUpgrade(id, num)
    local proto = {
        id = id,
        num = num,
    }
    self:SendProtocal(20803, proto)
end

function GatherCtrl:OnGatherUpgrade(data)
    --[[
        "id__C",
        "level__C",
        "exp__H",
    ]]
    -- PrintTable(data)
    
    self.data:OnGatherUpgrade(data)

    self:FireEvent(game.GatherEvent.OnGatherUpgrade, data)
end

function GatherCtrl:SendGatherColl(unique_id, coll_id)
    local proto = {
        id = unique_id,
        coll = coll_id,
        quick = self.quick_gather_flag or 0,
    }
    self:SendProtocal(20805, proto)
end

function GatherCtrl:OnGatherColl(data)
    --[[
        "vitality__H",
    ]]
    -- PrintTable(data)
   
    self.data:OnGatherColl(data) 

    self:FireEvent(game.GatherEvent.OnGatherColl, data.vitality)
end

function GatherCtrl:SendSetQuickGather(opt)
    self.quick_gather_flag = opt
    game.MainUICtrl.instance:SendSetCommonlyKeyValue(game.CommonlyKey.QuickGahterFlag,opt)
end

function GatherCtrl:SendGatherQuickGather()
    game.MainUICtrl.instance:SendGetCommonlyKeyValue(game.CommonlyKey.QuickGahterFlag)
end

function GatherCtrl:CommonlyValueRespon(data)
    if data.key ~= game.CommonlyKey.QuickGahterFlag then
        return
    end

    self.quick_gather_flag = data.value
end

function GatherCtrl:IsQuickGather()
    return self.quick_gather_flag==1
end

function GatherCtrl:GetGatherSkills()
    return self.data:GetGatherSkills()
end

function GatherCtrl:GetGatherSkillInfo(id)
    return self.data:GetGatherSkillInfo(id)
end

function GatherCtrl:GetGatherVitality()
    return self.data:GetGatherVitality()
end

local WordFormat = config.words[5459]
local BaseMaxVitality = config.sys_config["gather_max_store_vitality"].value
function GatherCtrl:GetVitalityStr()
    return string_format(WordFormat, self:GetGatherVitality(), self:GetMaxVitality())
end

function GatherCtrl:GetMaxVitality()
    local max = BaseMaxVitality
    local research_id = 1008
    local research_effect = game.GuildCtrl.instance:GetResearchEffect(research_id)

    return max+research_effect
end

local TipsConfig = {
    [2] = function(name)
        return string_format(config.words[5455], name)
    end,
    [3] = function()
        return config.words[5458]
    end,
}

--[[
    0 -- 不属于采集技能物品，使用通用采集
    1 -- 属于采集技能物品，可以采集
    2 -- 属于采集技能物品，技能等级不足
    3 -- 属于采集技能物品，活力不足
]]
function GatherCtrl:CheckGatherState(coll_id, is_tips)
    local cfg = nil
    for _,v in pairs(config_gather_skill) do
        for _,cv in pairs(v) do
            if cv.coll == coll_id then
                cfg = cv
                break
            end
        end
    end

    local res_code = 0
    if cfg then
        res_code = 1

        if self:GetGatherVitality() <= 0 then
            res_code = 3
        end

        local info = self:GetGatherSkillInfo(cfg.id)
        if info.level < cfg.level then
            res_code = 2
        end
    end

    if is_tips then
        local tips = TipsConfig[res_code]
        if tips then
            game.GameMsgCtrl.instance:PushMsg(tips(cfg.name))
        end
    end

    return res_code
end

function GatherCtrl:DoHangGather(gather_id, x, y, scene_id, obj_id)
    if self:CheckGatherState(gather_id) ~= 1 then
        return false
    end

    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        main_role:GetOperateMgr():DoHangGather(gather_id, x, y, scene_id, function()
            return self:GetGatherVitality()
        end, nil, obj_id)
    end
    return true
end

game.GatherCtrl = GatherCtrl

return GatherCtrl
