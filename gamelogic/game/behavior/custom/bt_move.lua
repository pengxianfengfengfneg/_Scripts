-- BtMove
-- param: move_pos
local BtMove = Class(bt.BtAction)

function BtMove:_init()
	self._name = "BtMove"
end

function BtMove:OnEnter(now_time, elapse_time, black_board)
	black_board.obj:DoMove(black_board.move_pos.x, black_board.move_pos.y)
end

function BtMove:OnUpdate(now_time, elapse_time, black_board)
	if not black_board.obj:CanDoMove() then
		return false
	end

	local cur_pos = black_board.obj:GetLogicPos()
	if cur_pos.x == black_board.move_pos.x and cur_pos.y == black_board.move_pos.y then
		return true
	elseif black_board.obj:GetCurStateID() ~= game.ObjState.Move then
		return false
	end
end

bt.BtMove = BtMove

-- BtCanMove
local BtCanMove = Class(bt.BtCondition)

function BtCanMove:_init()
	self._name = "BtCanMove"
end

function BtCanMove:Check(now_time, elapse_time, black_board)
	return black_board.obj:CanDoMove()
end

bt.BtCanMove = BtCanMove

-- BtCanTraceObj
-- in: target_obj_id
-- out: findway_pos, findway_id
local BtCanTraceObj = Class(bt.BtCondition)

function BtCanTraceObj:_init()
	self._name = "BtCanTraceObj"
end

function BtCanTraceObj:Check(now_time, elapse_time, black_board)
	local obj = black_board.obj.scene:GetObj(black_board.target_obj_id)
	if not obj then
		return false
	end
	black_board:SetFindWayPos(obj:GetLogicPosXY())
	return true
end

bt.BtCanTraceObj = BtCanTraceObj

-- BtCheckFindWayPath
-- in: findway_pos, findway_id
-- out: findway_path, findway_path_id, findway_path_index, move_pos
local BtCheckFindWayPath = Class(bt.BtCondition)

function BtCheckFindWayPath:_init()
	self._name = "BtCheckFindWayPath"
end

function BtCheckFindWayPath:Check(now_time, elapse_time, black_board)
	if black_board.findway_path_id ~= black_board.findway_id then
		black_board.findway_path_id = black_board.findway_id
		black_board.findway_path_index = 2
		local src_x, src_y = black_board.obj:GetUnitPosXY()
	    local ret, path_list = game.Utils.FindWay(src_x, src_y, game.LogicToUnitPos(black_board.findway_pos.x, black_board.findway_pos.y))
	    if not ret then
	    	return false
	    else
		    black_board.findway_path = path_list
		end
	end

	local pos = black_board.findway_path[black_board.findway_path_index]
	black_board:SetPos("move_pos", game.UnitToLogicPos(pos.x, pos.z))
	black_board.findway_path_index = black_board.findway_path_index + 1
	
	return true
end

bt.BtCheckFindWayPath = BtCheckFindWayPath

-- BtFindWay
-- in: findway_pos, findway_id
-- out: findway_path, findway_path_id, findway_path_index, move_pos
local BtFindWay = {
	New = function()
		local tree = bt.BtDecorateUtil.New(
			bt.BtSequence.New({
				bt.BtCanMove.New(),
				bt.BtCheckFindWayPath.New(),
				bt.BtMove.New(),
			}),
			function(now_time, elapse_time, black_board)
				return black_board.findway_path_index > #black_board.findway_path
			end
		)
		tree:SetName("BtFindWay")
		return tree
	end
}
bt.BtFindWay = BtFindWay

-- BtTraceObj
-- in: target_obj_id
local BtTraceObj = {
	New = function()
		local tree = bt.BtSequence.New({
			bt.BtCanTraceObj.New(),
			bt.BtFindWay.New(),
		})
		return tree
	end
}
bt.BtTraceObj = BtTraceObj

