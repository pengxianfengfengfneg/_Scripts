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

-- BtGoToAttackTarget
-- in: target_obj_id
local BtGoToAttackTarget = {
	New = function()
		local tree = bt.BtSequence.New({
			bt.BtHasNextSkill.New(),
			bt.BtPrioritySelector.New({
				bt.BtSequence.New({
					bt.BtInSkillRange.New(),
					bt.BtCanAttackTarget.New(),
					bt.BtCanAttack.New(),
					bt.BtAttack.New(),
				}),
				bt.BtSequence.New({
					bt.BtDecorateNot.New(bt.BtInSkillRange.New()),
					bt.BtTraceObj.New(),
				}),	
			}),
		})
		tree:SetName("BtGoToAttackTarget")
		return tree
	end
}
bt.BtGoToAttackTarget = BtGoToAttackTarget


-- BtHangNormal
local BtHangNormal = {
	New = function()
		local tree = bt.BtNoPrioritySelector.New({
			bt.BtSequence.New({
				bt.BtDecorateNot.New(bt.BtHasEnemy.New()),
				bt.BtSearchEnemy.New(),
			}),	
			bt.BtSequence.New({
				bt.BtHasEnemy.New(),
				bt.BtGoToAttackTarget.New(),
			}),	
		})
		tree:SetName("BtHangNormal")
		return tree
	end
}
bt.BtHangNormal = BtHangNormal