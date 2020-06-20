local CallPetState = Class()

function CallPetState:_init(obj)
    self.obj = obj
end

function CallPetState:_delete()

end

function CallPetState:StateEnter(grid)
    self.grid = grid

    local duration = 5

    if self.obj:IsMainRole() then
        global.EventMgr:Fire(game.SceneEvent.GatherChange, true, config.words[1494], duration)
        game.PetView.instance:Storage(false)--隐藏仓库UI
        game.PetView.instance:Free(false)
        game.PetView.instance:Battle(false)
        self.obj:SetPauseOperate(true)
    end

    self.obj:SetMountState(0)
    self.obj:PlayStateAnim()
    self.end_time = global.Time.now_time + duration
end

function CallPetState:StateUpdate(now_time, elapse_time)

    if now_time > self.end_time then
        game.PetCtrl.instance:SendFight(self.grid)
        self.obj:DoIdle()
    end
end

function CallPetState:StateQuit()
    if self.obj:IsMainRole() then
        game.PetView.instance:Storage(true)--显示仓库UI
        game.PetView.instance:Free(true)
        game.PetView.instance:Battle(true)
        global.EventMgr:Fire(game.SceneEvent.GatherChange, false)
        self.obj:SetPauseOperate(false)
    end
end

return CallPetState