local PetData = Class(game.BaseData)

function PetData:_init()
end

function PetData:_delete()
end

function PetData:SetPetInfo(info)
    self.pet_info = info
end

function PetData:GetPetInfo()
    return self.pet_info
end

function PetData:PetChange(data)
    if self.pet_info then
        for _, val in pairs(data.pets) do
            local flag = true
            for _, v in pairs(self.pet_info) do
                if v.pet.grid == val.pet.grid then
                    v.pet = val.pet
                    flag = false
                    self:FireEvent(game.PetEvent.PetChange, val.pet)
                    break
                end
            end
            if flag then
                table.insert(self.pet_info, val)
                local pet_cfg = config.pet[val.pet.cid]
                if (val.pet.star > 0 or pet_cfg.quality == 2) and data.type == 1 and val.pet.cid ~= 1001 and val.pet.cid ~= 1002 then
                    game.PetCtrl.instance:OpenPetGetView(val.pet)
                end
                self:FireEvent(game.PetEvent.PetAdd, val.pet)
            end
        end
    end
end

function PetData:SetStorage(data)
    self.storage_info = data
end

function PetData:GetStorage()
    return self.storage_info
end

function PetData:StorageChange(data)
    if self.storage_info then
        for _, val in pairs(data) do
            local flag = true
            for _, v in pairs(self.storage_info.dpet_list) do
                if v.dpet.grid == val.dpet.grid then
                    v.dpet = val.dpet
                    flag = false
                    break
                end
            end
            if flag then
                table.insert(self.storage_info.dpet_list, val)
            end
        end
    end
end

function PetData:DeleteBagPet(grids)
    for _, val in ipairs(grids) do
        for i, v in ipairs(self.pet_info) do
            if v.pet.grid == val.grid then
                table.remove(self.pet_info, i)
                break
            end
        end
    end
end

function PetData:DeleteStoragePet(grids)
    for _, val in ipairs(grids) do
        for i, v in ipairs(self.storage_info.dpet_list) do
            if v.dpet.grid == val.grid then
                table.remove(self.storage_info.dpet_list, i)
                break
            end
        end
    end
end

function PetData:SetHatchInfo(data)
    self.hatch_info = data
    self.hatch_id = data.hatch_id
end

function PetData:GetHatchInfo()
    return self.hatch_info
end

function PetData:GetHatchID()
    return self.hatch_id
end

function PetData:SetHatchPanel(data)
    self.hatch_id = data.hatch_id
end

function PetData:GetPetInfoById(id)
    for _, v in pairs(self.pet_info) do
        if v.pet.grid == id then
            return v.pet
        end
    end
end

function PetData:SetAttachInfo(info)
    self.attach_info = info
end

function PetData:GetAttachInfo()
    return self.attach_info
end

function PetData:AttachInfoChange(attach)
    if self.attach_info then
        local flag = true
        for _, v in pairs(self.attach_info) do
            if v.attach.attach_id == attach.attach_id then
                flag = false
                v.attach = attach
            end
        end
        if flag then
            table.insert(self.attach_info, {attach = attach})
        end
    end
end

function PetData:GetAttach(id)
    if self.attach_info then
        for _, v in pairs(self.attach_info) do
            if v.attach.attach_id == id then
                return v.attach
            end
        end
    end
end

function PetData:SetLucky(lucky)
    self.lucky = lucky
end

function PetData:GetLucky()
    return self.lucky or 0
end

function PetData:GetGridByPetId(pet_id)
    for _, v in pairs(self.pet_info) do
        if v.pet.cid == pet_id then
            return v.pet.grid
        end
    end
end

function PetData:GetPetNum(pet_id)
    local count = 0
    for _, v in pairs(self.pet_info) do
        if v.pet.cid == pet_id then
            count = count + 1
        end
    end
    return count
end

return PetData
