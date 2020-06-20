local OperatePool = Class()

function OperatePool:_init()
    if OperatePool.instance ~= nil then
        error("[OperatePool] init twice")
    end
    OperatePool.instance = self

    self.oper_pool = {}
    self.oper_conf = require("game/operate/operate_config")
end

function OperatePool:_delete()
    for k,v in pairs(self.oper_pool) do
        v:DeleteMe()
    end
    self.oper_pool = nil
    OperatePool.instance = nil
end

function OperatePool:CreateOperate(oper_type, ...)
    local oper_pool = self.oper_pool[oper_type]
    if not oper_pool then
        local oper_cls = require(self.oper_conf[oper_type])
        oper_pool = global.CollectPool.New(
            function()
                local item = oper_cls.New()
                return item
            end, 
            function(item)
                item:DeleteMe()
            end,
            function(item)
                item:Reset()
            end, 0)
        self.oper_pool[oper_type] = oper_pool
    end

    local oper = oper_pool:Create()
    oper:Init(...)
    return oper
end

function OperatePool:FreeOperate(oper)
    local oper_pool = self.oper_pool[oper.oper_type]
    if oper_pool then
        oper_pool:Free(oper)
    else
        error("No Operate Found " .. oper.oper_type)
    end
end

function OperatePool:Debug()
    local use_num, total_num = 0, 0
    for k,v in pairs(self.oper_pool) do
        use_num = use_num + v:GetUsedNum()
        total_num = total_num + v:GetItemNum()
    end
    return use_num, total_num
end

game.OperatePool = OperatePool.New()

return OperatePool
