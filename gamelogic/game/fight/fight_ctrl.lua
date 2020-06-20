
local FightCtrl = Class(game.BaseCtrl)


function FightCtrl:_init()
	if FightCtrl.instance ~= nil then
		error("FightCtrl Init Twice!")
	end
	FightCtrl.instance = self
	
	self.scene_view = require("game/fight/scene_view").New(self)
	self.fight_view = require("game/fight/fight_view").New(self)
	self.revive_view = require("game/fight/revive_view").New(self)
    self.bubble_view = require("game/fight/bubble_view").New(self)

    global.Runner:AddUpdateObj(self, 2)
end

function FightCtrl:_delete()
    global.Runner:RemoveUpdateObj(self)

	self.scene_view:DeleteMe()
	self.fight_view:DeleteMe()
	self.revive_view:DeleteMe()
    self.bubble_view:DeleteMe()

	FightCtrl.instance = nil
end


-- scene view
function FightCtrl:OpenSceneView()
    self.scene_view:Open()
end

function FightCtrl:CloseSceneView()
    self.scene_view:Close()
end

function FightCtrl:SetSceneViewVisible(visible)
    if visible then
        self.scene_view:ShowLayout()
    else
        self.scene_view:HideLayout()
    end
end

function FightCtrl:RegisterHud(obj, offset)
    if not self.scene_view:IsOpen() then
        return
    end
    return self.scene_view:RegisterHud(obj, offset)
end

function FightCtrl:UnRegisterHud(id)
    if not self.scene_view:IsOpen() then
        return
    end
    self.scene_view:UnRegisterHud(id)
end

function FightCtrl:SetHudVisible(id, enable)
    if not self.scene_view:IsOpen() then
        return
    end
    self.scene_view:SetHudVisible(id, enable)
end

function FightCtrl:SetOwner(id, obj, offset)
    if not self.scene_view:IsOpen() then
        return
    end
    self.scene_view:SetOwner(id, obj, offset)
end

function FightCtrl:SetHudText(id, name, val, color_idx)
    if not self.scene_view:IsOpen() then
        return
    end
    self.scene_view:SetHudText(id, name, val, color_idx)
end

function FightCtrl:SetHudTextColor(id, name, color_idx)
    if not self.scene_view:IsOpen() then
        return
    end
    self.scene_view:SetHudTextColor(id, name, color_idx)
end

function FightCtrl:SetHudImg(id, name, sp_name, scale, is_flip_x)
    if not self.scene_view:IsOpen() then
        return
    end
    self.scene_view:SetHudImg(id, name, sp_name, scale, is_flip_x)
end

function FightCtrl:SetHudItemVisible(id, name, val)
    if not self.scene_view:IsOpen() then
        return
    end
    self.scene_view:SetHudItemVisible(id, name, val)
end

function FightCtrl:SetSpeakBubble(id, txt, time, bubble_id)
    if not self.scene_view:IsOpen() then
        return
    end
    self.scene_view:SetSpeakBubble(id, txt, time, bubble_id)
end

-- fight view
function FightCtrl:OpenFightView()
    self.fight_view:Open()
end

function FightCtrl:CloseFightView()
    self.fight_view:Close()
end

function FightCtrl:PlayBlood(obj, num, harm_type)
	if not self.fight_view:IsOpen() then
		return
	end
	self.fight_view:PlayBlood(obj, num, harm_type)
end

function FightCtrl:PlayMp(obj, num)
	if not self.fight_view:IsOpen() then
		return
	end
	self.fight_view:PlayMp(obj, num)
end

function FightCtrl:PlaySkill(obj, id, lv)
	if not self.fight_view:IsOpen() then
		return
	end
	self.fight_view:PlaySkill(obj, id, lv)
end

function FightCtrl:PlayPetSkill(obj, id, lv, icon)
    if not self.fight_view:IsOpen() then
        return
    end
    self.fight_view:PlayPetSkill(obj, id, lv, icon)
end

-- revive
function FightCtrl:OpenReviveView(scene_id, data_list)
	self.revive_view:Open(scene_id, data_list)
end

function FightCtrl:CloseReviveView()
	self.revive_view:Close()
end

function FightCtrl:SendReviveReq(type)
	self:SendProtocal(90307, {type = type})
end

-- bubble view
function FightCtrl:OpenBubbleView()
    self.bubble_view:Open()
end

function FightCtrl:CloseBubbleView()
    self.bubble_view:Close()
end

function FightCtrl:SetBubbleViewVisible(visible)
    if visible then
        self.bubble_view:ShowLayout()
    else
        self.bubble_view:HideLayout()
    end
end

function FightCtrl:RegisterBubble(obj, offset)
    if not self.bubble_view:IsOpen() then
        return
    end
    return self.bubble_view:RegisterBubble(obj, offset)
end

function FightCtrl:UnRegisterBubble(id)
    if not self.bubble_view:IsOpen() then
        return
    end
    self.bubble_view:UnRegisterBubble(id)
end

function FightCtrl:ShowBubble(id, content)
    if not self.bubble_view:IsOpen() then
        return
    end
    self.bubble_view:ShowBubble(id, content)
end

function FightCtrl:Update(now_time, elapse_time)
    if self.scene_view:IsOpen() then
        self.scene_view:Update(now_time, elapse_time)
    end
end

game.FightCtrl = FightCtrl

return FightCtrl
