local PetTemplate = Class(game.UITemplate)

function PetTemplate:_init()
    self._package_name = "ui_main"
    self._com_name = "pet_head_component"
end

function PetTemplate:OpenViewCallBack()
    self:BindEvent(game.SceneEvent.MainRolePetHpChange, function(hp)
        self:SetHp(hp)
    end)

    self:BindEvent(game.PetEvent.ExpChange, function(data)
        local obj = game.Scene.instance:GetObj(self.obj_id)
        if obj and obj:IsMainRolePet() then
            if self.level ~= data.level then
                self.level = data.level
                self:SetName(data.level .. config.words[1217])
                obj:ShowLvupEffect()
            end
            local exp_cfg = config.pet_level[data.level]
            self:SetExp(data.exp / exp_cfg.exp)
        end
    end)
    
    self:BindEvent(game.SceneEvent.MainRolePetDie, function(obj_id, is_die)
        if self.obj_id == obj_id then
            if not is_die then
                self:Refresh()
            else
                self:SetGray(true)
                self:SetCount(true, 30)
            end
        end
    end)

    self:GetRoot():AddClickCallBack(function()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_main/new_main_view/pet_head_component/btn_pet"})
        game.PetCtrl.instance:OpenView()
    end)

    self.count_num = 0
end

function PetTemplate:CloseViewCallBack()
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

function PetTemplate:BindObjID(obj_id)
    if obj_id and self.obj_id == obj_id then
        return
    end
    self.obj_id = obj_id
    self:Refresh()
end

function PetTemplate:Refresh()
    local obj = game.Scene.instance:GetObj(self.obj_id)
    if obj then
        if obj:IsMainRolePet() then
            local pet_info = game.PetCtrl.instance:GetPetInfo()
            for _, v in pairs(pet_info) do
                if v.pet.stat == 5 then
                    self.level = obj.vo.level
                    local exp_cfg = config.pet_level[v.pet.level]
                    self:SetExp(v.pet.exp / exp_cfg.exp)
                    break
                end
            end
        end
        self._layout_objs.hp:SetVisible(obj:IsMainRolePet())
        self._layout_objs.exp:SetVisible(obj:IsMainRolePet())
        self._layout_objs.other_hp:SetVisible(not obj:IsMainRolePet())
        self:SetName(obj:GetName())
        self:SetHp(obj:GetHpPercent())
        if obj:GetObjType() == game.ObjType.Pet then
            self:SetName(obj:GetLevel() .. config.words[1217])
        end
        self:ShowHead(obj:GetIconID())
        self:SetGray(false)
        self:SetCount(false)
    else
        self:Reset()
    end
end

function PetTemplate:SetName(name)
    self._layout_objs["name"]:SetText(name)
end

function PetTemplate:SetHp(hp)
    local obj = game.Scene.instance:GetObj(self.obj_id)
    if obj and obj:IsMainRolePet() then
        self._layout_objs["other_hp"]:SetVisible(false)
        self._layout_objs["hp"]:SetVisible(true)
        self._layout_objs["hp"]:SetFillAmount((hp + 1) / 2)
    else
        self._layout_objs["other_hp"]:SetVisible(true)
        self._layout_objs["hp"]:SetVisible(false)
        self._layout_objs["other_hp"]:SetFillAmount(hp)
    end
end

function PetTemplate:SetExp(exp)
    self._layout_objs["exp"]:SetFillAmount((exp + 1) / 2)
end

function PetTemplate:ShowHead(res)
    if res then
        self._layout_objs["head"]:SetSprite("ui_headicon", res)
    end
end

function PetTemplate:SetGray(val)
    self._layout_objs["hp"]:SetGray(val)
    self._layout_objs["exp"]:SetGray(val)
    self._layout_objs["n10"]:SetVisible(val)
    self._layout_objs["head"]:SetVisible(not val)
end

function PetTemplate:SetCount(enable, num)
    if enable then
        self.count_num = num
        if not self.tween then
            local seq = DOTween.Sequence()
            seq:AppendInterval(1)
            seq:AppendCallback(function()
                if self.count_num > 0 then
                    self.count_num = self.count_num - 1
                    if self.count_num == 0 then
                        self._layout_objs["time"]:SetText("")
                    else
                        self._layout_objs["time"]:SetText(self.count_num)
                    end
                end
            end)
            seq:SetAutoKill(false)
            seq:SetLoops(-1)
            self.tween = seq
        end
        self.tween:Restart(true, -1)
    else
        if self.tween then
            self.tween:Pause()
        end
        self._layout_objs["time"]:SetText("")
    end
end

function PetTemplate:Reset()
    self:SetGray(false)
    self:SetCount(false)
    self:SetName("")
    self:SetHp(0)
    self:SetExp(0)
    self._layout_objs["head"]:SetSprite("ui_main", "hb_06")
end

return PetTemplate
