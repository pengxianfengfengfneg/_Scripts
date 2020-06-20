local MarryProcessCtrl = Class(game.BaseCtrl)

function MarryProcessCtrl:_init()
    if MarryProcessCtrl.instance ~= nil then
        error("MarryProcessCtrl Init Twice!")
    end
    MarryProcessCtrl.instance = self
    
    self.nao_dong_fang_btn_clicked = false

    self:RegisterAllProtocal()
    self:RegisterAllEvents()
end

function MarryProcessCtrl:_delete()
    MarryProcessCtrl.instance = nil
end

function MarryProcessCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(54452, "ScMarryHallInfo")
    self:RegisterProtocalCallback(54454, "ScMarryHallOpen")
    self:RegisterProtocalCallback(54456, "ScMarryHallEnter")
    self:RegisterProtocalCallback(54458, "ScMarryHallBaitang")
    self:RegisterProtocalCallback(54460, "ScMarryHallSleep")
    self:RegisterProtocalCallback(54462, "ScMarryHallNosiy")
    self:RegisterProtocalCallback(54464, "ScMarryHallTaste")
    self:RegisterProtocalCallback(54466, "ScMarryHallThank")
    self:RegisterProtocalCallback(54468, "ScMarryHallUp")
    self:RegisterProtocalCallback(54470, "ScMarryHallLeave")
    self:RegisterProtocalCallback(54402, "ScMarryParadeBegin")
    self:RegisterProtocalCallback(54403, "ScMarryParadeEnd")
end

function MarryProcessCtrl:RegisterAllEvents()
    local events = {
        {game.MarryEvent.UpdateHallBTClick, function(value)
            self:SetClickNDFBtn(false)
        end},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

--礼堂信息
function MarryProcessCtrl:CsMarryHallInfo()
    self:SendProtocal(54451,{})
end

function MarryProcessCtrl:ScMarryHallInfo(data)
    -- print("---------ScMarryHallInfo---------") PrintTable(data)
    self.marry_hall_list = data.open_list

    local is_exist, husband_id = self:HasMyHall()
    if is_exist then
        --夫妻双方自动进入自己的礼堂
        self:CsMarryHallEnter(husband_id)
    else
        --其他人进入选择礼堂界面
        game.MarryCtrl.instance:OpenChurch()
    end
end

--开启礼堂
function MarryProcessCtrl:CsMarryHallOpen()
    self:SendProtocal(54453,{})
end

function MarryProcessCtrl:ScMarryHallOpen(data)
    -- print("---------ScMarryHallOpen---------") PrintTable(data)
end

--进入礼堂
function MarryProcessCtrl:CsMarryHallEnter(hus_id)
    self:SendProtocal(54455,{husband_id = hus_id})
    -- print("---------CsMarryHallEnter---------",hus_id)
end

function MarryProcessCtrl:ScMarryHallEnter(data)
    -- print("---------ScMarryHallEnter---------") PrintTable(data)
    self.enter_hall_info = data
end

--拜堂
function MarryProcessCtrl:CsMarryHallBaitang()
    -- print("---------54457---------")
    self:SendProtocal(54457,{})
end

function MarryProcessCtrl:ScMarryHallBaitang(data)
    
end

--洞房
function MarryProcessCtrl:CsMarryHallSleep()
    -- print("---------CsMarryHallSleep---------")
    self:SendProtocal(54459,{})
end

function MarryProcessCtrl:ScMarryHallSleep(data)
    -- print("---------ScMarryHallSleep---------") PrintTable(data)
    self:DoSleep(data.role_id)
end

--闹洞房
function MarryProcessCtrl:CsMarryHallNosiy()
    self:SendProtocal(54461,{})
end

function MarryProcessCtrl:ScMarryHallNosiy(data)
-- print("---------ScMarryHallNosiy---------") PrintTable(data)
end

--品尝美食
function MarryProcessCtrl:CsMarryHallTaste()
    self:SendProtocal(54463,{})
end

function MarryProcessCtrl:ScMarryHallTaste(data)

    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        local max_num = #config.marry_hall_drink
        local index = math.random(max_num)
        local str = config.marry_hall_drink[index].drink_str
        main_role:SetSpeakBubble(str, 5)
    end
end

--答谢
function MarryProcessCtrl:CsMarryHallThank(thank_type)
    self:SendProtocal(54465,{type = thank_type})
end

function MarryProcessCtrl:ScMarryHallThank(data)
    game.GameMsgCtrl.instance:PushMsg(config.words[6170])
end

function MarryProcessCtrl:GetMarryHallList()
    return self.marry_hall_list or {}
end

function MarryProcessCtrl:DoSleep(role_id)

    local role
    local my_role_id = game.Scene.instance:GetMainRoleID()
    if my_role_id == role_id then
        role = game.Scene.instance:GetMainRole()
    end

    if not role then
        local role_list = game.Scene.instance:GetObjByType(game.ObjType.Role, function(obj)
                return obj.uniq_id == role_id
            end)
        role = role_list[1]
    end

    if role then
        local gender = role:GetGender()
        if gender == game.Gender.Male then
            role:SetLogicPos(148, 219)
        else
            role:SetLogicPos(146, 219)
        end
        role:SetHeight(0.8)
        role:SetDir(0, 1)
        role:DoDie()
    end

    if role and role_id == my_role_id then
        self.is_on_sleep = true
    end
end

function MarryProcessCtrl:IsOnSleep()
    return self.is_on_sleep
end

function MarryProcessCtrl:CheckCanDonwn()
    local is_marry_hall_scene = game.Scene.instance:IsMarryHallScene()
    if not is_marry_hall_scene then
        return
    end

    if not self.is_on_sleep then
        return
    end

    self:DoDown()
end

--下床
function MarryProcessCtrl:DoDown()

    if self.is_on_sleep then
        self.is_on_sleep = false
        self:CsMarryHallUp()

        local main_role = game.Scene.instance:GetMainRole()
        main_role:DoIdle()
        main_role:SetLogicPos(142, 210)
        main_role:SetHeight(0)
    end
end

function MarryProcessCtrl:HasMyHall()

    local is_exist = false
    local husband_id
    local my_role_id = game.Scene.instance:GetMainRoleID()

    for k,v in pairs(self.marry_hall_list) do
        if v.husband_id == my_role_id or v.wife_id == my_role_id then
            is_exist = true
            husband_id = v.husband_id
            break
        end
    end

    return is_exist, husband_id
end

function MarryProcessCtrl:IsInMyHall()

    local is_my_hall = false
    local my_role_id = game.Scene.instance:GetMainRoleID()
    local enter_hall_info = self.enter_hall_info or {}

    if enter_hall_info.husband_id == my_role_id or enter_hall_info.wife_id == my_role_id then
        is_my_hall = true
    end

    return is_my_hall
end

function MarryProcessCtrl:SetClickNDFBtn(val)
    self.nao_dong_fang_btn_clicked = val
end

function MarryProcessCtrl:GetClickNDFBtn()
    return self.nao_dong_fang_btn_clicked
end

--下床协议
function MarryProcessCtrl:CsMarryHallUp()
    self:SendProtocal(54467,{})
end

function MarryProcessCtrl:ScMarryHallUp()

end

--退出礼堂
function MarryProcessCtrl:CsMarryHallLeave()
    self:SendProtocal(54469,{})
end

function MarryProcessCtrl:ScMarryHallLeave()

end

--开始巡游
function MarryProcessCtrl:CsMarryParadeBegin()
    self:SendProtocal(54401,{})
end

function MarryProcessCtrl:ScMarryParadeBegin(data)

    local main_role = game.Scene.instance:GetMainRole()
    local my_role_id = game.Scene.instance:GetMainRoleID()
    if my_role_id == data.husband_id or my_role_id == data.wife_id then
        main_role:SetClientObj(false)
    end

    local hus_id = data.husband_id
    local husband
    if hus_id == my_role_id then
        husband = main_role
    else
        local role_list = game.Scene.instance:GetObjByType(game.ObjType.Role, function(obj)
                return obj.uniq_id == hus_id
            end)
        husband = role_list[1]
    end

    if husband then
        husband:SetCruiseMount(13)
    end
end

--结束巡游
function MarryProcessCtrl:ScMarryParadeEnd(data)

    local my_role_id = game.Scene.instance:GetMainRoleID()
    local main_role = game.Scene.instance:GetMainRole()
    main_role:SetClientObj(true)

    --置空巡游白马ID
    local hus_id = data.husband_id
    local husband
    if hus_id == my_role_id then
        husband = main_role
    else
        local role_list = game.Scene.instance:GetObjByType(game.ObjType.Role, function(obj)
                return obj.uniq_id == hus_id
            end)
        husband = role_list[1]
    end

    if husband then
        husband:SetCruiseMount(nil)
        husband:DoIdle()
        husband:SetMountState(0,true)
        husband:GetOperateMgr():SetPause(false)
    end

    ------------------------
    local wife_id = data.wife_id
    local wife
    if wife_id == my_role_id then
        wife = main_role
    else
        local role_list = game.Scene.instance:GetObjByType(game.ObjType.Role, function(obj)
                return obj.uniq_id == wife_id
            end)
        wife = role_list[1]
    end

    if wife then
        wife:GetOperateMgr():SetPause(false)
        wife:SetHeight(0)
        -- wife:DoIdle()
    end
end

game.MarryProcessCtrl = MarryProcessCtrl

return MarryProcessCtrl