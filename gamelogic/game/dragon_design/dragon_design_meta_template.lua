--龙元
local DragonDesignMetaTemplate = Class(game.UITemplate)

function DragonDesignMetaTemplate:_init(parent)
	self.parent = parent
	self.ctrl = game.DragonDesignCtrl.instance
	self.dragon_design_data = self.ctrl:GetData()
end

function DragonDesignMetaTemplate:_delete()
end

function DragonDesignMetaTemplate:OpenViewCallBack()
	for i = 1, 3 do
		self._layout_objs["bg"..i]:SetTouchDisabled(false)
		self._layout_objs["bg"..i]:AddClickCallBack(function()
			self.ctrl:OpenDragonMetaView(i)
	    end)
	end
end

return DragonDesignMetaTemplate