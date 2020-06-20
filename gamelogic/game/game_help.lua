game_help = game_help or {}

local _model_type = game.ModelType
local config_title = config.title or {}
local config_career_init = config.career_init
local config_goods = config.goods
local config_goods_get_way = config.goods_get_way

local _model_id_config = {
	[_model_type.Mount] = function()
		return 0
	end,
	[_model_type.Weapon] = function()
		return 0
	end,
	[_model_type.Wing] = function()
		return 0
	end,
	[_model_type.Body] = function(vo)
		return vo.career * 100000 + 10101, true
	end,
	[_model_type.Hair] = function(vo)
		return vo.career * 10000 + 1001, true
	end,
	[_model_type.Weapon] = function(vo)
		return vo.career * 1000 + 1, true
	end,
}

function game_help.GetModelID(model_type, vo)
	if _model_id_config[model_type] then
		local id, visible = _model_id_config[model_type](vo)
		if id then
			return id, visible
		end
	end
	return 0, false
end

function game_help.GetItemColorRes(color, big)
	return string.format("item%s%s",big and "" or "x", color)
end

function game_help.GetGoodsItem(obj, is_tips)
	local item = require("game/bag/item/goods_item").New()
    item:SetVirtual(obj)
    item:Open()

    if is_tips then
	    item:SetShowTipsEnable(is_tips)
	end

    return item
end

function game_help.GetTileName(title_id)
	local cfg = config_title[title_id] or {}
	return cfg.name or ""
end

function game_help.GetCareerName(career)
	local cfg = config_career_init[career] or {}
	return cfg.name or ""
end

function game_help.GetCareerAtkName(career)
	local cfg = config_career_init[career] or {}
	return cfg.atk_type_name or ""
end

function game_help.JumpToGetway(goods_id, idx)
	local goods_cfg = config_goods[goods_id]
	if goods_cfg then
		local get_way = goods_cfg.acquire[idx or 1]
		if get_way then
			local cfg = config_goods_get_way[get_way]
			if cfg and cfg.click_func then
				cfg.click_func()
			end
		end
	end
end

local GImage = FairyGUI.GImage
function game_help.SetRedPoint(node, is_red, ox, oy)
	if game.__DEBUG__ then
		if not node.asCom then
			error("the node is not a fairygui component")
			return
		end
	end

	local img_red = node:GetChild("img_red")
	if not img_red then
		img_red = GImage()
		img_red.name = "img_red"
		img_red:SetSprite("ui_main", "hd")

		ox = ox or 0
		oy = oy or 0

		local size = node:GetSize()
		img_red:SetPivot(1,0,true)
		img_red:SetPosition(size[1]+ox, 0 + oy)

		node:AddChild(img_red)
	end
	img_red:SetVisible(is_red)
end

return game_help