local GoodsUseUtils = {}
local cfg_goods = config.goods
local cfg_use = config.goods_effect
local cfg_use_jump = config.goods_use_jump
local cfg_goods_get_way = config.goods_get_way

local goods_use_map = {
    [16] = {
        [18] = function(info)
            if info.id == config.sys_config.rename_item_id.value then
                game.RoleCtrl.instance:OpenRoleRenameView()
            elseif info.id == config.sys_config.guild_rename_item.value then
                game.GuildCtrl.instance:OpenGuildRenameView()
            end
        end,
        [30] = function(info)
            game.Scene.instance:GetMainRole():GetOperateMgr():DoUseTreasureMap(info.id)
            game.BagCtrl.instance:CloseView()
        end,
        [41] = function(info)
            game.BagCtrl.instance:SendUseGoods(info.pos, 1, 0)
        end,
    },
    [31] = {
        [1] = function(info)
            if cfg_use[info.id].effect_type == 8 and cfg_use[info.id].effect[2] > 0 and game.FashionCtrl.instance:IsFashionActived(cfg_use[info.id].effect[1]) then
                local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(config.words[2010])
                tips_view:SetBtn1(nil, function()
                    game.BagCtrl.instance:SendUseGoods(info.pos, 1)
                end)
                tips_view:SetBtn2(config.words[101])
                tips_view:Open()
            else
                game.BagCtrl.instance:SendUseGoods(info.pos, 1)
            end
        end,
    },
    [32] = {
        [1] = function(info)
            if config.goods_effect[info.id].effect_type == 4 then
                game.MainUICtrl.instance:OpenChoseMountView()
            else
                game.BagCtrl.instance:SendUseGoods(info.pos, 1)
            end
        end,
    },
    [40] = {
        [1] = function(info)
            local item_id = info.id
            local cfg = config.firework[item_id]
            if cfg then
                if cfg.type == 1 then
                    -- 直接使用
                    local target_id = 0
                    game.FireworkCtrl.instance:SendFireworkUse(info.id, target_id)
                    game.BagCtrl.instance:CloseView()
                else
                    -- 对目标使用，打开界面
                    game.FireworkCtrl.instance:OpenTipsView(item_id)
                end
            end
        end,
    },
}

function GoodsUseUtils.Use(info, ...)
    local cfg = cfg_goods[info.id]
    if goods_use_map[cfg.type] and goods_use_map[cfg.type][cfg.subtype] then
        goods_use_map[cfg.type][cfg.subtype](info, ...)
    elseif cfg_use[info.id] ~= nil then
        if cfg_use[info.id].client_type == 2 then
            game.MainUICtrl.instance:OpenChosePetView(info)
        elseif cfg_use[info.id].client_type == 3 then
            game.BagCtrl.instance:OpenChoseGiftView(info)
        else
            if info.num > 1 and cfg_use[info.id].use_num > 1 then
                game.BagCtrl.instance:OpenBatchUseView(info)
            else
                game.BagCtrl.instance:SendUseGoods(info.pos, 1, 0)
            end
        end
    elseif cfg_use_jump[info.id] ~= nil and cfg_goods_get_way[cfg_use_jump[info.id]] then
        cfg_goods_get_way[cfg_use_jump[info.id]].click_func(info.id)
    end
end

function GoodsUseUtils.CanUse(id)
    local cfg = cfg_goods[id]
    if goods_use_map[cfg.type] and goods_use_map[cfg.type][cfg.subtype] then
        return true
    else
        return cfg_use[id] ~= nil or cfg_use_jump[id] ~= nil
    end
end

game.GoodsUseUtils = GoodsUseUtils