local SDKMgr = Class()

local _sdk_helper = N3DClient.SdkHelper:GetInstance()
local _empty_param = {}

function SDKMgr:_init()
    self.tag = _sdk_helper:GetSDKTag()
end

function SDKMgr:_delete()
end

function SDKMgr:Start()
    self.has_check_create = false
    self.has_check_login = false
    self.uid = nil
    self.token = nil
end

function SDKMgr:Update()
    _sdk_helper:Update()
end

function SDKMgr:GetSDKTag()
    return self.tag
end

function SDKMgr:Login()
    if self.tag == "" then
        local acc = global.UserDefault:GetString("Account")
        _sdk_helper:PushSDKEvent(game.SDKEventName.LoginSuccess, { account = acc })
    else
        if game.Platform == "android" then
            _sdk_helper:CallSDKFunc("CallSDKLogin", _empty_param)
        elseif game.Platform == "ios" then
            _sdk_helper:CallIOSSDKFunc("CallSDKLogin")
        end
    end
end

function SDKMgr:Logout()
    if self.tag == "" then
        _sdk_helper:PushSDKEvent(game.SDKEventName.LogoutSuccess, {})
    else
        if game.Platform == "android" then
            _sdk_helper:CallSDKFunc("CallSDKLogout", _empty_param)
        elseif game.Platform == "ios" then
            _sdk_helper:CallIOSSDKFunc("CallSDKLogout")
        end
    end
end

function SDKMgr:SendUIDToSDK(uid)
    self.uid = uid
    if self.tag ~= "" then
        if game.Platform == "android" then
            _sdk_helper:CallSDKFunc("CallSetUID", {uid = uid})
        elseif game.Platform == "ios" then
            _sdk_helper:CallSetUID(uid)
        end
    end
end

function SDKMgr:ShowSDKMenu(enable)
    if true then
        return
    end
    if self.tag ~= "" then
        if game.Platform == "android" then
            if enable then
                _sdk_helper:CallSDKFunc("CallSDKShowMenu", _empty_param)
            else
                _sdk_helper:CallSDKFunc("CallSDKHideMenu", _empty_param)
            end
        elseif game.Platform == "ios" then
            if enable then
                if self.uid and self.token then
                    _sdk_helper:CallSDKShowMenu(self.uid, self.token)
                end
            else
                _sdk_helper:CallIOSSDKFunc("CallSDKHideMenu")
            end
        end
    end
end

--验证账号
function SDKMgr:AuthAccount(code)
    self.uid = nil
    self.token = code

    local callback = function(success, data)
        if success then
            local json_data = N3DClient.JsonConverter.ParseJsonToLua(data)
            if json_data and json_data.info == 1 then
                _sdk_helper:PushSDKEvent(game.SDKEventName.LoginSuccess, { account = json_data.data.accname })
                return
            end
        end

        game.AccountInfo.is_login = false
        game.AccountInfo.account = nil

        local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[1007], config.words[1008])
        msg_box._ui_order = game.UIZOrder.UIZOrder_Top
        msg_box:SetOkBtn(function()
            msg_box:Close()
            msg_box:DeleteMe()
            _sdk_helper:PushSDKEvent(game.SDKEventName.AuthFail, {})
        end)
        msg_box:Open()
    end
    game.ServiceMgr:VerifyToken(code, callback)
end

-- 1：选择服务器
-- 2：创建角色*
-- 3：进入游戏*
-- 4：等级提升*
-- 5：退出游戏*
-- 6: 进入副本
-- 7：退出副本
-- 8: VIP等级提升
function SDKMgr:SendSDKData(t)
    if not game.AccountInfo.is_login then
        return
    end

    if t == 2 then
        if self.has_check_create then
            return
        end
        self.has_check_create = true
    elseif t == 3 then
        if self.has_check_login then
            return
        end
        self.has_check_login = true
    end

    local role_info = game.LoginCtrl.instance:GetLastLoginRoleInfo()
    if not role_info or (t == 2 and not role_info.is_new) then
        return
    end

    local main_role_vo = game.Scene.instance:GetMainRoleVo()
    if not main_role_vo then
        return
    end

    local param_list = {
        server_id = game.LoginCtrl.instance:GetLoginServerID(),
        server_name = game.LoginCtrl.instance:GetLoginServerTitle(),
        role_id = string.toU64String(main_role_vo.role_id),
        role_name = main_role_vo.name,
        role_lv = main_role_vo.level,
        role_create_time = role_info.reg_time,
        gold = game.BagCtrl.instance:GetGold(),
        vip = game.VipCtrl.instance:GetVipLevel(),
        uid = game.AccountInfo.account,
        t = t,
    }

    if game.Platform == "android" then
        if self.tag ~= "" then
            -- release_print("CallSDKSendData", t)
            if t == 3 then
                _sdk_helper:CallSDKFunc("CallSetRoleInfo", param_list)
            end
            _sdk_helper:CallSDKFunc("CallSDKSendData", param_list)
        end
    elseif game.Platform == "ios" then
        -- release_print("CallSDKSendData", t, server_id, server_name, string.toU64String(role_id), tostring(role_name), tostring(role_lv), gold, role_create_time, role_level_up_time, tostring(vip), tostring(uid))
        -- _sdk_helper:CallSDKSendData(t, server_id, server_name, string.toU64String(role_id), tostring(role_name), tostring(role_lv), gold, role_create_time, role_level_up_time, tostring(vip), tostring(uid))
    end
end

local _unity_input = UnityEngine.Input
local _escape_key_code = UnityEngine.KeyCode.Escape
function SDKMgr:CheckShowExitBox()
    if game.Platform == "android" then
        if _unity_input.GetKeyDown(_escape_key_code) then
            if self.tag == "" then
                N3DClient.GameTool.ShowQuitAlert()
            else
                _sdk_helper:CallSDKFunc("CallSDKExit", _empty_param)
            end
        end
    end
end

-- money rmb价格（元）
-- product_id   int 服务端标识id
-- product_name  商品名
function SDKMgr:RequestPay(product_id, product_name, money)
    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return
    end

    local callback = function(success, data)
        if success then
            local json_data = N3DClient.JsonConverter.ParseJsonToLua(data)
            if json_data and json_data.info == 1 then
                local extensions = json_data.data.order_id
                local param_list = {
                    product_id = tostring(product_id),
                    product_name = product_name,
                    price = money * 100,
                    buy_num = 1,
                    extensions = extensions,
                }

                if game.Platform == "android" then
                    if self.tag ~= "" then
                        -- release_print("CallSDKPay", tostring(product_id), product_name, money, 1, extensions)
                        _sdk_helper:CallSDKFunc("CallSDKPay", param_list)
                    end
                elseif game.Platform == "ios" then
                    if self.tag ~= "" then
                        -- release_print("CallSDKPay", tostring(product_id), product_name, product_desc, money * 100, 10, 1, coin_num, tostring(server_id), server_name, string.toU64String(role_id), role_name, role_lv, tostring(vip_lv), json_data.data.order_id, extensions, accname)
                        -- _sdk_helper:CallSDKPay(tostring(recharge_id), tostring(product_id), product_name, product_desc, money * 100, 10, 1, coin_num, tostring(server_id), server_name, string.toU64String(role_id), role_name, role_lv, tostring(vip_lv), json_data.data.order_id, extensions, accname)
                    end
                end
                return
            end
        end

        game.GameMsgCtrl.instance:PushMsg(config.words[1009], 2)
    end

    local role_id = main_role.vo.role_id
    local accname = game.AccountInfo.account
    local server_id = game.LoginCtrl.instance:GetLoginServerID()
    game.ServiceMgr:RequestOrder(accname, server_id, role_id, money * 100, product_id, callback)
end

game.SDKMgr = SDKMgr.New()