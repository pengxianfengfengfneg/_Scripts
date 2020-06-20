local GetSceneForDun = config_help.ConfigHelpDungeon.GetSceneForDun

local SpecialTaskConfig = {
	[0] = {
        check_func = function()
            return true
        end,
    },
    [1029] = {
    	check_func = function(task_info, task_cfg)
            local is_finish = (task_info.stat==game.TaskState.Finished)
            if is_finish then
                local task_cond = task_cfg.finish_cond[1]
                local dun_id = task_cond[3][1]

                local cur_scene_id = game.Scene.instance:GetSceneID()
                local dun_scene_id = GetSceneForDun(dun_id)
                return (cur_scene_id~=dun_scene_id)
            end
            return false
        end,
        oper_func = function()
            return {95}
        end,
    },
    [10004] = {
        check_func = function(task_info, task_cfg)
            local is_finish = (task_info.stat==game.TaskState.Finished)
            if is_finish then
                local task_cond = task_cfg.finish_cond[1]
                local dun_id = task_cond[3][1]

                local cur_scene_id = game.Scene.instance:GetSceneID()
                local dun_scene_id = GetSceneForDun(dun_id)
                return (cur_scene_id~=dun_scene_id)
            end
            return false
        end,
        oper_func = function()
            return {95}
        end,
    },
    [20106] = {
        check_func = function(task_info, task_cfg)
            local is_finish = (task_info.stat==game.TaskState.Finished)
            if is_finish then
                local task_cond = task_cfg.finish_cond[1]
                local dun_id = task_cond[3][1]

                local cur_scene_id = game.Scene.instance:GetSceneID()
                local dun_scene_id = GetSceneForDun(dun_id)
                return (cur_scene_id~=dun_scene_id)
            end
            return false
        end,
        oper_func = function()
            return {11}
        end,
    },
    [20802] = {
        check_func = function(task_info, task_cfg)
            local is_finish = (task_info.stat==game.TaskState.Finished)
            if is_finish then
                local task_cond = task_cfg.finish_cond[1]
                local dun_id = task_cond[3][1]

                local cur_scene_id = game.Scene.instance:GetSceneID()
                local dun_scene_id = GetSceneForDun(dun_id)
                return (cur_scene_id~=dun_scene_id)
            end
            return false
        end,
        oper_func = function()
            return {11}
        end,
    },
}

return SpecialTaskConfig