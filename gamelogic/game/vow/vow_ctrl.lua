--[[
    众里寻卿
--]]
local VowCtrl = Class(game.BaseCtrl)

function VowCtrl:_init()
    if VowCtrl.instance ~= nil then
        error("VowCtrl Init Twice!")
    end
    VowCtrl.instance = self

    self.vow_data = require("game/vow/vow_data").New(self)
    self.vow_tree_view = require("game/vow/vow_tree_view").New(self)
    self.vow_activity_view = require("game/vow/vow_activity_view").New(self)
    self.vow_recv_view = require("game/vow/vow_recv_view").New(self)
    self.vow_send_view = require("game/vow/vow_send_view").New(self)
    self.vow_success_view = require("game/vow/vow_success_view").New(self)
  
    self.match_type = false
    self:RegisterAllProtocal()
end

function VowCtrl:_delete()
    self.vow_tree_view:DeleteMe()
    self.vow_activity_view:DeleteMe()
    self.vow_recv_view:DeleteMe()
    self.vow_send_view:DeleteMe()
    self.vow_success_view:DeleteMe()
    self.vow_data:DeleteMe()

    VowCtrl.instance = nil
end

function VowCtrl:RegisterAllProtocal()
    self:RegisterProtocalCallback(54102, "ScVowPanelInfo")
    self:RegisterProtocalCallback(54104, "ScVowMyLike")
    self:RegisterProtocalCallback(54106, "ScVowMyVow")
    self:RegisterProtocalCallback(54108, "ScVowOtherVow")
    self:RegisterProtocalCallback(54111, "ScVow")
    self:RegisterProtocalCallback(54113, "ScVowGet")
    self:RegisterProtocalCallback(54115, "ScVowAgree")
    self:RegisterProtocalCallback(54117, "ScVowCancelLike")
    self:RegisterProtocalCallback(54119, "ScVowRevoke")
    self:RegisterProtocalCallback(54152, "ScDeedInfo")
    self:RegisterProtocalCallback(54154, "ScDeedNotify")
    self:RegisterProtocalCallback(54156, "ScDeedBegin")
    self:RegisterProtocalCallback(54157, "ScDeedComplete")
    self:RegisterProtocalCallback(54159, "ScDeedReward")
end

function VowCtrl:RegisterAllEvents()
    local events = {
        {game.ViewEvent.MainViewReady, function(value)
            if value then
                self:CsVowPanelInfo()
            end
        end},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function VowCtrl:GetData()
    return self.vow_data
end

function VowCtrl:OpenActivityView(tab_index)
    if not self.vow_activity_view:IsOpen() then
        self.vow_activity_view:Open(tab_index)
    end
end

function VowCtrl:OpenTreeView(tab_index)
    if not self.vow_tree_view:IsOpen() then
        self.vow_tree_view:Open(tab_index)
    end
end

--面板信息
function VowCtrl:CsVowPanelInfo()
    self:SendProtocal(54101,{})
end

function VowCtrl:ScVowPanelInfo(data)
    self.vow_data:SetVowInfo(data)
    self:FireEvent(game.VowEvent.UpdatgeVowInfo)
end

--我的点赞
function VowCtrl:CsVowMyLike()
    self:SendProtocal(54103,{})
end

function VowCtrl:ScVowMyLike(data)
    self.vow_data:SetMyLikeVowInfo(data)
    self:FireEvent(game.VowEvent.UpdatgeVowInfo, true)
end

--查看自己许愿
function VowCtrl:CsVowSeeVow()
    self:SendProtocal(54105,{})
end

function VowCtrl:ScVowMyVow(data)
    self:FireEvent(game.VowEvent.GetMyVow, data)
end

--其他他人许愿详细信息
function VowCtrl:CsVowOtherVow(role_id)
    self:SendProtocal(54107,{target_id=role_id})
end

function VowCtrl:ScVowOtherVow(data)
    self:FireEvent(game.VowEvent.GetOtherVow, data)
end

--刷新
function VowCtrl:CsVowRefresh()
    local match_type_num = self.match_type and 1 or 0
    self:SendProtocal(54109,{type=match_type_num})
end

--许愿
function VowCtrl:CsVow(str)
    self:SendProtocal(54110,{context = str})
end

function VowCtrl:ScVow(data)
    game.GameMsgCtrl.instance:PushMsg(config.words[6162])
end

--接取心愿
function VowCtrl:CsVowGet(role_id)
    self:SendProtocal(54112,{target_id= role_id})
end

function VowCtrl:ScVowGet(data)
    
end

--点赞
function VowCtrl:CsVowAgree(role_id)
    self:SendProtocal(54114,{target_id = role_id})
end

function VowCtrl:ScVowAgree(data)
    self.vow_data:AddAgreeData(data)
    self:FireEvent(game.VowEvent.UpdateOtherAgree, data)
end

--取消点赞
function VowCtrl:CsVowCancelLike(role_id)
    self:SendProtocal(54116,{target_id = role_id})
end

function VowCtrl:ScVowCancelLike(data)
    self.vow_data:SubAgreeData(data)
    self:FireEvent(game.VowEvent.UpdateOtherAgree, data)
end

--撤销许愿
function VowCtrl:CsVowRevoke()
    self:SendProtocal(54118,{})
end

function VowCtrl:ScVowRevoke(data)
    game.GameMsgCtrl.instance:PushMsg(config.words[6163])
end

--契约信息
function VowCtrl:CsDeedInfo()
    self:SendProtocal(54151,{})
end

function VowCtrl:ScDeedInfo(data)
    self.vow_data:SetDeedData(data)
end

--邀请契约
function VowCtrl:CsDeedInvite()
    self:SendProtocal(54153,{})
end

function VowCtrl:ScDeedNotify(data)
    local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[6159], 60)
    msg_box:SetOkBtn(function()
        self:CsDeedRes(1)
        msg_box:DeleteMe()
    end)
    msg_box:SetCancelBtn(function()
        self:CsDeedRes(2)
    end,nil,true)
    msg_box:Open()
end

--返回结果
function VowCtrl:CsDeedRes(agree_flag)
    self:SendProtocal(54155,{res=agree_flag})
end

--达成契约(发送给契约双方)
function VowCtrl:ScDeedBegin(data)
    --播放特效
    game.GameMsgCtrl.instance:PushMsg(config.words[6166])
    self.vow_data:UpdateDeedData(data)
    self:OpenVowSuccess()
end

--完成列表变化
function VowCtrl:ScDeedComplete(data)
    self.vow_data:ChangeDeedList(data)
end

--领取奖励
function VowCtrl:CsDeedReward(index)
    self:SendProtocal(54158,{id=index})
end

function VowCtrl:ScDeedReward(data)
    self.vow_data:UpdateDeedReward(data)
    self:FireEvent(game.VowEvent.UpdateGetReward, data)
end

function VowCtrl:OpenView()
    if self.vow_data:InDeedState() then
        self:OpenActivityView()
    else
        self:OpenTreeView()
    end
end

function VowCtrl:OpenVowSendView()
    if not self.vow_send_view:IsOpen() then
        self.vow_send_view:Open()
    end
end

function VowCtrl:OpenVowRecvView(other_vow_data)
    if not self.vow_recv_view:IsOpen() then
        self.vow_recv_view:Open(other_vow_data)
    end
end

function VowCtrl:SetMatchType(val)
    self.match_type = val
end

function VowCtrl:GetMatchType()
    return self.match_type
end

function VowCtrl:OpenVowSuccess()
    if not self.vow_success_view:IsOpen() then
        self.vow_success_view:Open()
    end
end

game.VowCtrl = VowCtrl

return VowCtrl