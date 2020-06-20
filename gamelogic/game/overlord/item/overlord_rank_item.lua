local OverlordRankItem = Class(game.UITemplate)

function OverlordRankItem:SetRoleInfo(info)
    self.info = info
    self._layout_objs.rank:SetText(info.rank)
    self._layout_objs.name:SetText(info.name)
    local score_text = math.floor(tonumber(info.score) / 10000)
    if score_text > 0 then
        score_text = string.format(config.words[2336], score_text)
    else
        score_text = info.score
    end
    self._layout_objs.score:SetText(score_text)
    self._layout_objs.guild:SetText(info.guild)
    self._layout_objs.career:SetText(config.career_init[info.career].name)
end

function OverlordRankItem:SetGuildInfo(info)
    self.info = info
    self._layout_objs.rank:SetText(info.rank)
    self._layout_objs.name:SetText(info.name)
    local score_text = math.floor(tonumber(info.score) / 10000)
    if score_text > 0 then
        score_text = string.format(config.words[2336], score_text)
    else
        score_text = info.score
    end
    self._layout_objs.score:SetText(score_text)
    self._layout_objs.guild:SetText(info.chief)
    self._layout_objs.career:SetText(info.num)
end

function OverlordRankItem:SetBg(val)
    self._layout_objs.bg:SetVisible(val)
end

return OverlordRankItem