local OperateHangGuildTaskPet = Class(require("game/operate/operate_sequence"))

function OperateHangGuildTaskPet:_init()
    self.oper_type = game.OperateType.HangGuildTaskPet
end

function OperateHangGuildTaskPet:Init(obj, task_type, task_id)
    OperateHangGuildTaskPet.super.Init(self, obj)

    self.task_type = task_type
    self.task_id = task_id

    return true
end

function OperateHangGuildTaskPet:Start()
    local task_cfg = config.guild_task[self.task_type][self.task_id]

    local pet_id = task_cfg.obj_id
    local pet_num = task_cfg.obj_num

    local active_item_id = config.pet[pet_id].active_item
    local monster_id = config.catch_pet[active_item_id].mon_id
    local gather_id = config.catch_pet[active_item_id].coll_id

    local pet_list = game.PetCtrl.instance:GetBaby(pet_id)

    if #pet_list == 0 then
        self:InsertToOperateSequence(game.OperateType.HangCatchPet, self.obj, gather_id, monster_id)
    end

    local npc_id = game.DailyTaskCtrl.instance:GetGuildTaskNpcId()
    self:InsertToOperateSequence(game.OperateType.GoToNpc, self.obj, npc_id, function()
        game.DailyTaskCtrl.instance:OpenTaskItemSelectView(task_cfg)
    end)  
    
    return true
end

return OperateHangGuildTaskPet
