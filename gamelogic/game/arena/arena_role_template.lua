local ArenaRoleTemplate = Class(game.UITemplate)

function ArenaRoleTemplate:_init()
	self._package_name = "ui_arena"
    self._com_name = "arena_role_template"
end

function ArenaRoleTemplate:OpenViewCallBack()

    local main_role = game.Scene.instance:GetMainRole()

    local model_list = {
        [game.ModelType.Body]    = 110101,
        -- [game.ModelType.Wing]    = 101,
        [game.ModelType.Hair]    = 11001,
        [game.ModelType.Weapon]    = 1001,
    }

    for k,v in pairs(model_list) do
        local id = main_role:GetModelID(k)
        model_list[k] = (id>0 and id or v)
    end

	self.model = require("game/character/model_template").New()
    self.model:CreateModel(self._layout_objs["n2"], game.BodyType.Role, model_list)
    self.model:PlayAnim(game.ObjAnimName.Idle)
    self.model:SetPosition(0,-1.4,3.2)
    self.model:SetRotation(0,180,0)
    self.model:SetScale(1.2)

    self._layout_objs["n2"]:SetTouchEnable(false)

    self._layout_root:SetVisible(false)
end

function ArenaRoleTemplate:CloseViewCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function ArenaRoleTemplate:UpdateInfo(role_info)

    self.role_info = role_info

    self._layout_objs["rank_num"]:SetText(tostring(role_info.rank))

    self._layout_objs["role_name"]:SetText(role_info.name)

    self._layout_objs["n7"]:SetText(tostring(role_info.fight))

    local fashion_id, color = game.FashionCtrl.instance:ParseFashionValue(role_info.fashion)


    local career = role_info.career
    local model_id = career * 100000 + 10101
    local hair_id = career * 10000 + 1001
    local weapon_id = career * 1000 + 1

    self.model:SetModel(game.ModelType.Body, model_id)
    self.model:SetModel(game.ModelType.Hair, hair_id)
    self.model:SetModel(game.ModelType.Weapon, weapon_id)

    self.model:PlayAnim(game.ObjAnimName.Idle)
    self._layout_root:SetVisible(true)
end

function ArenaRoleTemplate:OnClick()
    if self.role_info then
        game.ArenaCtrl.instance:ArenaBattleReq(self.role_info.rank, self.role_info.role_id)
    else
        game.GameMsgCtrl.instance:PushMsg(config.words[2506])
    end
end

return ArenaRoleTemplate