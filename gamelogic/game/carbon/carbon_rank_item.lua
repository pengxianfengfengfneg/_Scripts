local CarbonRankItem = Class(game.UITemplate)

function CarbonRankItem:_init(rank_type)
	self._package_name = "ui_carbon"
    self._com_name = "carbon_rank_item"
    self.rank_type = rank_type
    self.rank_data = game.RankCtrl.instance:GetRankData()
end

function CarbonRankItem:OpenViewCallBack()

end

function CarbonRankItem:CloseViewCallBack()

end

function CarbonRankItem:RefreshItem(idx)

    if self.rank_type then
        local type_list = self.rank_data:GetRankDataByType(self.rank_type)
        local item_data = type_list[idx]
        self._layout_objs.bg:SetVisible(idx % 2 == 1)
        if item_data then
            self.item_data = item_data
            self.item = item_data.item
            local rank = item_data.item.rank
            self._layout_objs["n6"]:SetText(tostring(rank))
            self._layout_objs["n7"]:SetText(tostring(item_data.item.columns[1].column))
            self._layout_objs["n8"]:SetText(tostring(item_data.item.columns[2].column))
            if self.rank_type == 1022 then
                local lv = math.ceil(item_data.item.columns[3].column / 6)
                local sub_lv = math.floor(item_data.item.columns[3].column % 6)
                if sub_lv == 0 then
                    sub_lv = 6
                end
                self._layout_objs["n13"]:SetText(lv .. "-" .. sub_lv)
            else
                self._layout_objs["n13"]:SetText(tostring(item_data.item.columns[3].column)..config.words[1414])
            end
        end
    end
end

return CarbonRankItem