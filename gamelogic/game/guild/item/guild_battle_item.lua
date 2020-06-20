local GuildBattleItem = Class(game.UITemplate)

local PkConfig = game.FieldBattlePkConfig

local FieldOccupyState = {
	None = 0,
	Fight = 1,
	Occupy = 2,
}

function GuildBattleItem:_init(field_id, parent)
    self.field_id = field_id
    self.parent = parent
end

function GuildBattleItem:OpenViewCallBack()
    self:Init()
end

function GuildBattleItem:CloseViewCallBack()

end

function GuildBattleItem:Init()
    self.icon = self._layout_objs["icon"]
    self.txt_guild = self._layout_objs["txt_guild"]
    self.img_state = self._layout_objs["img_state"]

    self.occupy_state = FieldOccupyState.None
   
   	self:GetRoot():AddClickCallBack(function()
		local info = game.FieldBattleCtrl.instance:GetTerritoryInfoForId(self.field_id)
        if not info then
            game.GameMsgCtrl.instance:PushMsg(config.words[5262])
            return
        end

		if info.guild > 0 then
			game.GameMsgCtrl.instance:PushMsg(string.format(config.words[5254], info.name))
			return
		end

		if self.occupy_state == FieldOccupyState.None then
			game.GameMsgCtrl.instance:PushMsg(string.format(config.words[5270], self.field_name))
			return
		end

	  game.GuildCtrl.instance:OpenFieldBattlePkView(self.field_id, self.parent:GetNextDeltaTime())
	end)

	local cfg = config.territory[self.field_id]
    if cfg then
    	self.field_name = cfg.name
    	self.icon:SetSprite("ui_guild", cfg.icon or "")
    	self:GetRoot():SetText(cfg.name)
    end

    self.my_guild_id = game.GuildCtrl.instance:GetGuildId()
end

function GuildBattleItem:UpdateData(data)
	if data.id ~= self.field_id then
		return
	end

    self.guild_id = data.guild
    self.guild_name = data.name

    local guild_name = data.name
    if guild_name == "" then
    	guild_name = config.words[5260]
    end

    local res_state = "b003"
    if self.guild_id > 0 then
    	-- 已占领
    	res_state = "b003"

    	local is_self_guild = (self.my_guild_id == self.guild_id)
    	self.img_state:SetVisible(true and is_self_guild)

    	self.occupy_state = FieldOccupyState.Occupy
    else
	    local pk_cfg = PkConfig[self.field_id]
	    local blue_info = game.FieldBattleCtrl.instance:GetTerritoryInfoForId(pk_cfg[1])
	    local red_info = game.FieldBattleCtrl.instance:GetTerritoryInfoForId(pk_cfg[2])

	   
	    if blue_info.guild<=0 and red_info.guild<=0 then
	    	-- 未开始争夺
	    	self.img_state:SetVisible(false)

	    	self.occupy_state = FieldOccupyState.None
	    else
	    	-- 争夺中
	    	res_state = "b002"
	    	local is_self_join = (blue_info.guild==self.my_guild_id or red_info.guild==self.my_guild_id)
	    	self.img_state:SetVisible(true and is_self_join)

	    	self.occupy_state = FieldOccupyState.Fight
	    end
	end
	self.img_state:SetSprite("ui_guild", res_state)
    
    self.txt_guild:SetText(guild_name)
end

function GuildBattleItem:GetGuildId()
	return self.guild_id
end

return GuildBattleItem