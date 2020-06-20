local AiMgr = Class()

local AiClassConfig = game.AiClassConfig

function AiMgr:_init()
    self.now_time = 0
    self.free_time = 0
    self.ai_cache = {}
end

function AiMgr:_delete()
    
end

function AiMgr:AddObjAi(obj, ai_type, ...)
    local ai_class = AiClassConfig[ai_type]

    local unique_id = obj:GetUniqueId()
    if not self.ai_cache[unique_id] then
        local pack = table.pack(...)
        table.insert(pack, 1, ai_type)
        self.ai_cache[unique_id] = pack
    end
end

function AiMgr:GetObjAiInfo(obj)
    return self.ai_cache[obj:GetUniqueId()]
end

function AiMgr:FreeObjAi(obj)
    self.ai_cache[obj:GetUniqueId()] = nil
end

function AiMgr:CreateAi(obj)
    local ai_info = self.ai_cache[obj:GetUniqueId()]
    if not ai_info then
        return
    end

    local ai_type = ai_info[1]
    local ai = AiClassConfig[ai_type].New(self, obj, table.unpack(ai_info))

    return ai
end

function AiMgr:AddAndCreateAi(obj, ai_type, ...)
    self:AddObjAi(obj, ai_type, ...)

    return self:CreateAi(obj)
end

game.AiMgr = AiMgr.New()