local RegisterCom = Class(game.UITemplate)

local _config_mentor_base = config.mentor_base

function RegisterCom:_init(ctrl)
    self.ctrl = game.MentorCtrl.instance
end

function RegisterCom:OpenViewCallBack()
    self._layout_objs["txt_1"]:SetText(string.format(config.words[6409], _config_mentor_base.senior_lv, _config_mentor_base.open_lv))
    self._layout_objs["txt_2"]:SetText(self:GetConditionStr())

    self._layout_objs["btn_prentice"]:AddClickCallBack(function()
        self.ctrl:OpenRegisterView(2)
    end)

    self._layout_objs["btn_mentor"]:AddClickCallBack(function()
        local role_lv = game.RoleCtrl.instance:GetRoleLevel()
        local mentor_lv = config.mentor_base.mentor_lv
        if role_lv >= mentor_lv then
            self.ctrl:OpenRegisterView(1)
        else
            game.GameMsgCtrl.instance:PushMsg(string.format(config.words[6441], mentor_lv))
        end
    end)
end

function RegisterCom:GetConditionStr()
    local cond_list = {}
    for k, v in pairs(config.mentor_lv_gap) do
        table.insert(cond_list, v)
    end
    table.sort(cond_list, function(m, n)
        return m.tudi_lv < n.tudi_lv
    end)
    local str = ""
    local len = #cond_list
    for k, v in ipairs(cond_list) do
        if k ~= 1 then
            local param1 = k==2 and v.tudi_lv or string.format("%d-%d", cond_list[k-1].tudi_lv, cond_list[k].tudi_lv-1)
            local param2 = k==2 and config.words[6411] or ""
            local param3 = cond_list[k-1].mentor_lv
            str = str .. string.format(config.words[6410], param1, param2, param3)
        end
    end
    str = str .. string.format(config.words[6410], cond_list[len].tudi_lv-1, config.words[6412], cond_list[len].mentor_lv)
    return str
end

return RegisterCom