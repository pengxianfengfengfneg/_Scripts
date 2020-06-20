local GamePool = Class()

local _gameobj = UnityEngine.GameObject

function GamePool:_init()
end

function GamePool:_delete()
    self:ClearGamePool()
end

function GamePool:CreateGamePool()
    self.GameObjectPool = global.CollectPool.New(
        function()
            local obj = _gameobj()
            return {obj = obj, tran = obj.transform}
        end, 
        function(item)
            _gameobj.Destroy(item.obj)
        end,
        function(item)
            game.RenderUnit:AddToUnUsedLayer(item.tran)
            item.obj:Reset()
        end, 0)

    self.ObjRootPool = global.CollectPool.New(
        function()
            local obj = _gameobj()
            local info = {obj = obj, tran = obj.transform}
            info.tran:SetLayer(game.LayerName.ObjCollider)
            return info
        end, 
        function(item)
            _gameobj.Destroy(item.obj)
        end,
        function(item)
            game.RenderUnit:AddToUnUsedLayer(item.tran)
            item.obj:Reset()
        end, 0)

    local model_base_cls = require("game/character/model/model_base")
    self.ModelBasePool = global.CollectPool.New(
        function()
            local item = model_base_cls.New()
            return item
        end, 
        function(item)
            item:DeleteMe()
        end,
        function(item)
            item:Reset()
        end, 30)

    local draw_obj_cls = require("game/character/model/draw_obj")
    self.DrawObjPool = global.CollectPool.New(
        function()
            local item = draw_obj_cls.New()
            return item
        end, 
        function(item)
            item:DeleteMe()
        end,
        function(item)
            item:Reset()
        end, 30)

    local camera_obj_cls = require("game/character/model/camera_obj")
    self.CameraObjPool = global.CollectPool.New(
        function()
            local item = camera_obj_cls.New()
            return item
        end, 
        function(item)
            item:DeleteMe()
        end,
        function(item)
            item:Reset()
        end, 5)

    local role_cls = require("game/character/role")
    self.RolePool = global.CollectPool.New(
        function()
            return role_cls.New()
        end,
        function(role)
            role:DeleteMe()
        end,
        function(role)
            role:Reset()
        end, 10)

    local monster_cls = require("game/character/monster")
    self.MonsterPool = global.CollectPool.New(
        function()
            return monster_cls.New()
        end,
        function(monster)
            monster:DeleteMe()
        end,
        function(monster)
            monster:Reset()
        end, 10)

    local pet_cls = require("game/character/pet")
    self.PetPool = global.CollectPool.New(
        function()
            return pet_cls.New()
        end,
        function(pet)
            pet:DeleteMe()
        end,
        function(pet)
            pet:Reset()
        end, 10)

    local gather_cls = require("game/character/gather")
    self.GatherPool = global.CollectPool.New(
        function()
            return gather_cls.New()
        end,
        function(obj)
            obj:DeleteMe()
        end,
        function(obj)
            obj:Reset()
        end, 10)

    local carry_cls = require("game/character/carry")
    self.CarryPool = global.CollectPool.New(
        function()
            return carry_cls.New()
        end,
        function(obj)
            obj:DeleteMe()
        end,
        function(obj)
            obj:Reset()
        end, 10)

    local flyitem_cls = require("game/character/fly_item")
    self.FlyItemPool = global.CollectPool.New(
        function()
            return flyitem_cls.New()
        end,
        function(obj)
            obj:DeleteMe()
        end,
        function(obj)
            obj:Reset()
        end, 10)

    local ui_effect_cls = require("game/common/mvc/ui_effect")
    self.UIEffectPool = global.CollectPool.New(
            function()
                return ui_effect_cls.New()
            end,
            function(effect)
                effect:DeleteMe()
            end,
            function(effect)
                effect:Reset()
            end, 10)

    local weapon_soul_cls = require("game/character/weapon_soul")
    self.WeaponSoulPool = global.CollectPool.New(
        function()
            return weapon_soul_cls.New()
        end,
        function(weapon_soul)
            weapon_soul:DeleteMe()
        end,
        function(weapon_soul)
            weapon_soul:Reset()
        end, 10)

    self.prefab_pool = {}

    local follow_obj_cls = require("game/character/follow_obj")
    self.FollowObjPool = global.CollectPool.New(
        function()
            return follow_obj_cls.New()
        end,
        function(follow_obj)
            follow_obj:DeleteMe()
        end,
        function(follow_obj)
            follow_obj:Reset()
        end, 10)

    self.prefab_pool = {}
end

function GamePool:ClearGamePool()
    if self.MonsterPool then
        self.MonsterPool:DeleteMe()
        self.MonsterPool = nil
    end
    
    if self.PetPool then
        self.PetPool:DeleteMe()
        self.PetPool = nil
    end

    if self.RolePool then
        self.RolePool:DeleteMe()
        self.RolePool = nil
    end

    if self.GatherPool then
        self.GatherPool:DeleteMe()
        self.GatherPool = nil
    end

    if self.CarryPool then
        self.CarryPool:DeleteMe()
        self.CarryPool = nil
    end

    if self.FlyItemPool then
        self.FlyItemPool:DeleteMe()
        self.FlyItemPool = nil
    end

    if self.UIEffectPool then
        self.UIEffectPool:DeleteMe()
        self.UIEffectPool = nil
    end

    if self.DrawObjPool then
        self.DrawObjPool:DeleteMe()
        self.DrawObjPool = nil
    end

    if self.ModelBasePool then
        self.ModelBasePool:DeleteMe()
        self.ModelBasePool = nil
    end

    if self.GameObjectPool then
        self.GameObjectPool:DeleteMe()
        self.GameObjectPool = nil
    end

    if self.ObjRootPool then
        self.ObjRootPool:DeleteMe()
        self.ObjRootPool = nil
    end
   
    if self.WeaponSoulPool then
        self.WeaponSoulPool:DeleteMe()
        self.WeaponSoulPool = nil
    end

    if self.FollowObjPool then
        self.FollowObjPool:DeleteMe()
        self.FollowObjPool = nil
    end

    if self.prefab_pool then
        for k,v in pairs(self.prefab_pool) do
            for k1,v1 in pairs(v) do
                v1:DeleteMe()
            end
        end
        self.prefab_pool = nil
    end
end

function GamePool:GetPrefabPool(bundleName, assetName)
    if not self.prefab_pool[bundleName] then
        self.prefab_pool[bundleName] = {}
    end

    if not self.prefab_pool[bundleName][assetName] then
        self.prefab_pool[bundleName][assetName] = global.CollectPool.New(
            function()
                return global.AssetLoader:CreateGameObject(bundleName, assetName)
            end,
            function(item)
                _gameobj.Destroy(item)
            end,
            function(item)
                game.RenderUnit:AddToUnUsedLayer(item)
                item:Reset()
            end, 0)
    end

    return self.prefab_pool[bundleName][assetName]
end

game.GamePool = GamePool.New()