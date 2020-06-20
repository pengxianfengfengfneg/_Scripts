local RechargeTemplate = Class(game.UITemplate)

local order_url = "http://tlbb.autopayez.com"
local post_url = "https://tlbb.autopayez.com/payment_code.php"

local PostValue = {};

function RechargeTemplate:_init()
    self.ctrl = game.RechargeCtrl.instance
end

function RechargeTemplate:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
end

function RechargeTemplate:CloseViewCallBack()
   
end

function RechargeTemplate:RegisterAllEvents()
    local events = {
        {game.RechargeEvent.OnConsumeInfo, handler(self, self.OnConsumeInfo)},
        {game.RechargeEvent.OnConsumeFlagChange, handler(self, self.OnConsumeFlagChange)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function RechargeTemplate:Init()
    self._layout_objs.txt_info:SetText(config.words[5704])

    self.list_charge = self:CreateList("list_charge", "game/recharge/item/recharge_item")
    self.list_charge:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo(self.charge_list_data[idx])
        item:AddClickEvent(function()
            self:OnClickItem(item)
        end)
    end)

    self.btn_pay1 = game.RechargeView.instance:BtnPay1()
    self.btn_pay2 = game.RechargeView.instance:BtnPay2()
    self.btn_pay3 = game.RechargeView.instance:BtnPay3()
    self.btn_close = game.RechargeView.instance:BtnClose()
    self.btn_info_close = game.RechargeView.instance:BtnInfoClose()

    self.btn_close:AddClickCallBack(function()
        game.RechargeView.instance:IsPayBg(false)
    end)

    self.btn_info_close:AddClickCallBack(function()
        game.RechargeView.instance:IsPayInfoBg(false)
    end)

    self.btn_pay1:AddClickCallBack(function()
        game.RechargeView.instance:IsPayBg(false)
        game.RechargeView.instance:SetIstouch(true)
        local post = {}
        post["op"] = 1
        post["no"] = self.order_id
        post["game"] = self.ditch_id
        post["zone"] = self.server_id
        post["goodsId"] = self.id
        post["accname"] = self.account
        post["guser"] = self.account     --玩家账号
        post["gold"] = self.gold         --元宝
        post["realpay"] = self.RMB       --充值金额
        post["paytype"] = 1
        print("paytype = 1")
        global.HttpService:SendPostRequest(order_url, post, function(success, data)
            self:ExtractURLString(data)
        end)
    end)

    self.btn_pay2:AddClickCallBack(function()
        game.RechargeView.instance:IsPayBg(false)
        game.RechargeView.instance:SetIstouch(true)
        local post = {}
        post["op"] = 1
        post["no"] = self.order_id
        post["game"] = self.ditch_id
        post["zone"] = self.server_id
        post["goodsId"] = self.id
        post["accname"] = self.account
        post["guser"] = self.account     --玩家账号
        post["gold"] = self.gold         --元宝
        post["realpay"] = self.RMB       --充值金额
        post["paytype"] = 2
        global.HttpService:SendPostRequest(order_url, post, function(success, data)
            self:ExtractURLString(data)
        end)
    end)

    --信用卡
    self.btn_pay3:AddClickCallBack(function()
        game.RechargeView.instance:IsPayBg(false)
        game.RechargeView.instance:SetIstouch(true)
        local post = {}
        post["op"] = 1
        post["no"] = self.order_id
        post["game"] = self.ditch_id
        post["zone"] = self.server_id
        post["goodsId"] = self.id
        post["accname"] = self.account
        post["guser"] = self.account     --玩家账号
        post["gold"] = self.gold         --元宝
        post["realpay"] = self.RMB       --充值金额
        post["paytype"] = 3
        global.HttpService:SendPostRequest(order_url, post, function(success, data)
            global.HttpService:SendSaveFileRequest(data)
            game.RechargeView.instance:SetIstouch(false)
        end)
    end)

end

--获取充值配置
function RechargeTemplate:UpdateChargeList()
    local recharge_cfg = game.PlatformCtrl.instance:GetRechargeConfig()
    self.charge_list_data = {}
    for k, v in ipairs(recharge_cfg) do
        table.insert(self.charge_list_data, v)
    end
    self.list_charge:SetItemNum(#self.charge_list_data)
end

function RechargeTemplate:OnConsumeInfo(data)
    self:UpdateChargeList()
end

--充值
function RechargeTemplate:OnClickItem(item)

    game.RechargeView.instance:IsPayBg(true)

    local url
    self.root_url = "http://43.249.194.231:81/vt/api_order.php"

    self.server_info = game.LoginData.instance:GetGameServerInfo()
    self.role_info = game.SelectRoleView.instance:GetRoleInfo()
    if self.role_info == nil then
        self.role_info = game.LoginCtrl.instance:GetLastLoginRoleInfo()
    end

    self.server_id = self.server_info.server_id
    self.role_id = self.role_info.role_id
    self.account = global.UserDefault:GetString("Account")
    self.ditch_id = N3DClient.GameConfig.GetClientConfig("DitchID")
    self.id = item:GetId()
    self.gold = item:GetGold()
    self.RMB = item:GetRMB()

    local params = {
        ["sid"] = self.server_id,
        ["role_id"] = self.role_id,
        ["accname"] = self.account,
        ["channel"] = self.ditch_id,
        ["product_id"] = self.id,
        ["money"] = self.gold,
        ["time"] = os.time(),
    }

    url = app.ServiceCtrl.instance:CalculateGetUrl(self.root_url, params)

    global.HttpService:SendPostRequest(url,params, function(success, data)
        self:ExtractSubString(data)
    end)
end

function RechargeTemplate:OnConsumeFlagChange(data)
    self:UpdateChargeList()
end


--截取Json格式字符串
function RechargeTemplate:ExtractSubString(str)
    self.order_id = string.sub(str,31,48)
end

--截取html格式字符串
function RechargeTemplate:ExtractURLString(str)
    self.urlvalue = string.sub(str,2630,-1)

    local sss = self:parseText(self.urlvalue);
    while sss ~= "" do
        sss = self:parseText(sss);
    end

    game.RechargeView.instance:SetPayInfoValue(PostValue)
    game.RechargeView.instance:IsPayInfoBg(true)
    game.RechargeView.instance:SetIstouch(false)

    global.HttpService:SendPostRequest(post_url, PostValue, function(success, data)
        print(data)
        PostValue = {}
    end)
end

--设置html格式字符串
function RechargeTemplate:setTagText(name,value)
    PostValue[name] = value
end

--解析html格式字符串
function RechargeTemplate:parseText(str)
    local strIndex = string.sub(str, 1, 1);
    local text = "";
    local name = "";
    local value = "";
    -- 每次循环之后剩下的字符（）
    local sss = ""
    if strIndex == "<" then
        local i1 = string.find(str, "/>");
        if i1 == nil or i1 == "" then
            text = nil;
        else
            text = string.sub(str, 1, i1-1);
            local key_value = string.find(text, "name=");
            if key_value ~= nil then
                key_value =  string.sub(text, key_value);
                name = string.find(key_value ,"value")
                name = string.sub(key_value,1,name-1)
                name = string.sub(name,7,-3)
                value = string.find(key_value ,"value=")
                value =string.sub(key_value,value)
                value = string.sub(value ,8,-3)
                sss = string.sub(str, i1+2);

                self:setTagText(name,value)
            else
                sss = ""
            end
        end
    end

    return sss
end

return RechargeTemplate