local world_map_func_config = {}

local GroupMap = {
    QinHuang = 1,
}

local QinHuangConfig = {
    click_func = function(info)
        local scene_id = info.id
        local group_id = info.group_id

        local title = config.words[1660]
        local content = string.format(config.words[2412], config.scene[scene_id].name)

        local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(content, title)
        tips_view:SetBtn1(nil, function()
            local is_open, msg = game.WorldMapCtrl.instance:IsMapOpened(scene_id, group_id)
            if is_open then
                game.WorldMapCtrl.instance:EnterMap(scene_id)
            else
                game.GameMsgCtrl.instance:PushMsg(msg)
            end
        end)
        tips_view:SetBtn2(config.words[101])
        tips_view:Open()
    end
}

for _, v in ipairs(config.world_map_group) do
    for _, cv in pairs(v) do
        if cv.group_id == GroupMap.QinHuang then
            world_map_func_config[cv.id] = QinHuangConfig
        end
    end
end

return world_map_func_config