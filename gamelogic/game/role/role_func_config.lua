local RoleFuncConfig = {
    
    ["fashion"] = {
        click_func = function()
            game.FashionCtrl.instance:OpenView()
        end,
        check_open_func = function()
            return true
        end,
        check_red_func = function()
            return game.FashionCtrl.instance:CheckRedPoint()
        end,
        check_events = {
            game.FashionEvent.ActiveFashion,
            game.FashionEvent.DyeingFashion,
            game.BagEvent.BagItemChange,
        },
    },

    ["suit"] = {
        click_func = function()
            game.SurfaceSuitCtrl.instance:OpenView()
        end,
        check_open_func = function()
            return true
        end,
        check_red_func = function()

            return false
        end,
        check_events = {

        },
    },

    ["god"] = {
        click_func = function()
            game.GodEquipCtrl.instance:OpenView()
        end,
        check_open_func = function()
            return true
        end,
        check_red_func = function()

            return game.GodEquipCtrl.instance:CheckRedPoint()
        end,
        check_events = {
            game.RoleEvent.GodEquipUpgrade,
            game.RoleEvent.GodEquipWash,

        },
    },
}

return RoleFuncConfig