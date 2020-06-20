
local GameMsgCtrl = Class(game.BaseCtrl)

local _msg_color = {
    [1] = cc.White,
    [2] = cc.Red,
}

function GameMsgCtrl:_init()
	if GameMsgCtrl.instance ~= nil then
		error("GameMsgCtrl Init Twice!")
	end
	GameMsgCtrl.instance = self

    self.msg_tips_view = require("game/gamemsg/msg_tips_view").New()
    self.waiting_view = require("game/gamemsg/msg_waiting_view").New()
    self.info_desc_view = require("game/gamemsg/info_desc_view").New()
    self.error_log_view = require("game/gamemsg/error_log_view").New(self)
    self.msg_tips_view2 = require("game/gamemsg/msg_tips_view2").New()

    self.error_code_callback_map = {}
    self:RegisterAllProtocal()

    self.error_stack = {}
end

function GameMsgCtrl:_delete()
    self.msg_tips_view:DeleteMe()
    self.msg_tips_view = nil
    self.waiting_view:DeleteMe()
    self.waiting_view = nil
    self.info_desc_view:DeleteMe()
    self.error_log_view:DeleteMe()
    self.msg_tips_view2:DeleteMe()

    self.error_stack = nil

	GameMsgCtrl.instance = nil
end

function GameMsgCtrl:RegisterAllProtocal()
	self:RegisterProtocalCallback(10501, "OnGeneralRetCode")
    self:RegisterProtocalCallback(10502, "OnGeneralRetCodeE")
end

function GameMsgCtrl:OpenWaitingView(count_down)
    self.waiting_view:Open(count_down)
end

function GameMsgCtrl:CloseWaitingView()
    self.waiting_view:Close()
end

function GameMsgCtrl:OpenMsgView()
    self.msg_tips_view:Open()
end

function GameMsgCtrl:OnReceiveMsg(data_list)
    if self.error_code_callback_map[data_list.ret_num] then
        self.error_code_callback_map[data_list.ret_num]()
    end
    self:PushCenterMsgCode(data_list.ret_num, data_list.param_list)
end

function GameMsgCtrl:RegisterErrorCodeCallback(error_code, callback_func)
    self.error_code_callback_map[error_code] = callback_func
end

function GameMsgCtrl:UnRegisterErrorCodeCallback(error_code)
    self.error_code_callback_map[error_code] = nil
end

function GameMsgCtrl:CreateMsgBox(title, content, timeout)
	local msg_box = require("game/gamemsg/msg_box_view").New()
	msg_box:SetTitle(title)
	msg_box:SetContent(content)
    msg_box:SetTimeOut(timeout)
	return msg_box
end

function GameMsgCtrl:CreateMsgBoxSec(title, content)
    local msg_box = require("game/gamemsg/msg_box_viewSec").New()
    msg_box:SetTitle(title)
    msg_box:SetContent(content)
    return msg_box
end

function GameMsgCtrl:CreateMsgTips(content, title)
    self.msg_tips_view2:SetContent(content)
    self.msg_tips_view2:SetTitle(title)
    return self.msg_tips_view2
end

function GameMsgCtrl:PushMsg(msg)
    self.msg_tips_view:PushMsg(msg, _msg_color[1])
end

function GameMsgCtrl:PushMsgCode(code)
    local msg = config.ret_code[code]
    self.msg_tips_view:PushMsg(msg, _msg_color[1])
end

local arg_list = {}
function GameMsgCtrl:PushMsgCodeE(code, args)
    local msg = config.ret_code[code]
    for k, v in ipairs(args or game.EmptyTable) do
        arg_list[k] = v.arg
    end
    if args then
        arg_list[#args + 1] = nil
    end
    self.msg_tips_view:PushMsg(string.format(msg, table.unpack(arg_list)), _msg_color[1])
end

-- proto
function GameMsgCtrl:OnGeneralRetCode(data_list)
    if self.error_code_callback_map[data_list.code] then
        self.error_code_callback_map[data_list.code]()
    end
    self:PushMsgCode(data_list.code)
end

function GameMsgCtrl:OnGeneralRetCodeE(data_list)
    if self.error_code_callback_map[data_list.code] then
        self.error_code_callback_map[data_list.code](data_list.args)
    end
    self:PushMsgCodeE(data_list.code, data_list.args)
end

function GameMsgCtrl:OpenInfoDescView(id, param)
    self.info_desc_view:Open(id, param)
end

function GameMsgCtrl:AddErrorLog(log)
    if #self.error_stack > 10 or self.error_log_view == nil then
        return
    end
    table.insert(self.error_stack, log)
    if self.error_log_view:IsOpen() then
        self.error_log_view:UpdateContent()
    else
        self.error_log_view:Open()
    end
end

function GameMsgCtrl:RemoveErrorLog()
    self.error_stack = {}
end

game.GameMsgCtrl = GameMsgCtrl

return GameMsgCtrl
