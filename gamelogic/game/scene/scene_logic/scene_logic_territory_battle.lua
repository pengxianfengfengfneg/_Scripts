
local SceneLogicTerritoryBattle = Class(require("game/scene/scene_logic/scene_logic_base"))

function SceneLogicTerritoryBattle:_init(scene)
    self.scene = scene
end

function SceneLogicTerritoryBattle:_delete()
    
end

function SceneLogicTerritoryBattle:OnStartScene()
    self.main_role = self.scene.main_role

    game.MainUICtrl.instance:SwitchToFighting()
    game.GuildCtrl.instance:CloseView()
    game.FieldBattleCtrl.instance:ClosePrepareView()
    game.FieldBattleCtrl.instance:OpenSideInfoView()
end

function SceneLogicTerritoryBattle:StopScene()
    if game.FieldBattleCtrl.instance then
        game.FieldBattleCtrl.instance:CloseSideInfoView()
        game.FieldBattleCtrl.instance:CloseFightInfoView()
        game.FieldBattleCtrl.instance:ClosePkInfoView()
    end    
end

function SceneLogicTerritoryBattle:CreateGather(vo)
    local gather_obj = SceneLogicTerritoryBattle.super.CreateGather(self, vo)

    local battle_info = game.FieldBattleCtrl.instance:GetBattleInfo()
    if battle_info.flag then
        local camp = battle_info.flag

        if camp > 0 then
            local guild_name = ""
            local guild_id = nil
            for _,v in ipairs(battle_info.camps) do
                if camp == v.camp then
                    guild_name = v.name
                    guild_id = v.guild
                    break
                end
            end

            local my_guild_id = game.GuildCtrl.instance:GetGuildId()
            local color_idx = (my_guild_id==guild_id and 3 or 2)
            gather_obj:SetHudText(game.HudItem.Tips, guild_name, color_idx)
        end
    end

    return gather_obj
end

function SceneLogicTerritoryBattle:CanDoGather(gather_obj)
    local my_camp = self.main_role:GetRealm()
    local obj_camp = gather_obj:GetRealm()

    return (my_camp~=obj_camp)
end

function SceneLogicTerritoryBattle:IsShowLogicExit()
    return true
end

function SceneLogicTerritoryBattle:DoSceneLogicExit()
    game.FieldBattleCtrl.instance:SendTerritoryLeave()
end

function SceneLogicTerritoryBattle:IsShowLogicDetail()
    return true
end

function SceneLogicTerritoryBattle:DoSceneLogicDetail()
    game.FieldBattleCtrl.instance:OpenFightInfoView()
end

return SceneLogicTerritoryBattle
