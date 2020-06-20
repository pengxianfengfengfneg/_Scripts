
local MonitorView = Class(game.BaseView)

local monitor_config_list = {
	{
		tick_func = function()
			local fps = game.MonitorCtrl.instance:GetFps()
			return string.format(" Fps: %.2f", fps)
		end
	},
	{
		tick_func = function()
			local all_mem = UnityEngine.Profiling.Profiler.GetTotalAllocatedMemoryLong() / 1024.0 / 1024.0
			local reserved_mem = UnityEngine.Profiling.Profiler.GetTotalReservedMemoryLong() / 1024.0 / 1024.0
			-- local unused_mem = UnityEngine.Profiling.Profiler.GetTotalUnusedReservedMemoryLong() / 1024.0 / 1024.0
			return string.format(" App: %.2f / %.2f", all_mem, reserved_mem)
		end
	},
	{
		tick_func = function()
			local mem = UnityEngine.Profiling.Profiler.GetMonoHeapSizeLong() / 1024.0 / 1024.0
			local used_mem = UnityEngine.Profiling.Profiler.GetMonoUsedSizeLong() / 1024.0 / 1024.0
			return string.format(" Mono: %.2f / %.2f", used_mem, mem)
		end
	},
	{
		tick_func = function()
			local lua_mem = collectgarbage("count") / 1024.0
			return string.format(" LuaMem: %.2f", lua_mem)
		end
	},
	{
		tick_func = function()
			return string.format(" AssetBundle: %d(%d)", global.AssetLoader:GetBundleNum(), global.AssetLoader:GetAssetNum())
		end
	},
	{
		tick_func = function()
			return string.format(" Template: %d", game.UITemplate:GetTemplateNum())
		end
	},

	{
		tick_func = function()
			return string.format(" Event: %d", global.EventMgr:GetEventNum())
		end
	},
	{
		tick_func = function()
			return string.format(" Timer: %d", global.TimerMgr:GetTimerNum())
		end
	},
	{
		tick_func = function()
			return string.format(" AssetTask: %d(%d)", global.AssetLoader:GetRunTaskNum(), global.AssetLoader:GetWaitTaskNum())
		end
	},
	{
		tick_func = function()
			return string.format(" Flyer: %d / %d", game.Scene.instance.flyer_mgr:Debug())
		end
	},
	{
		tick_func = function()
			return string.format(" GameObjPool: %d/%d", game.GamePool.GameObjectPool:GetItemNum() - game.GamePool.GameObjectPool:GetFreeNum(), game.GamePool.GameObjectPool:GetItemNum())
		end
	},
	{
		tick_func = function()
			return string.format(" RolePool: %d/%d", game.GamePool.RolePool:GetItemNum() - game.GamePool.RolePool:GetFreeNum(), game.GamePool.RolePool:GetItemNum())
		end
	},
	{
		tick_func = function()
			return string.format(" MonsterPool: %d/%d", game.GamePool.MonsterPool:GetItemNum() - game.GamePool.MonsterPool:GetFreeNum(), game.GamePool.MonsterPool:GetItemNum())
		end
	},
	{
		tick_func = function()
			return string.format(" DrawObjPool: %d/%d", game.GamePool.DrawObjPool:GetItemNum() - game.GamePool.DrawObjPool:GetFreeNum(), game.GamePool.DrawObjPool:GetItemNum())
		end
	},
	{
		tick_func = function()
			return string.format(" ModelBasePool: %d/%d", game.GamePool.ModelBasePool:GetItemNum() - game.GamePool.ModelBasePool:GetFreeNum(), game.GamePool.ModelBasePool:GetItemNum())
		end
	},
	{
		tick_func = function()
			if game.EffectMgr.instance then
				return string.format(" EffectBasePool: %d/%d", game.EffectMgr.instance.effect_base_pool:GetItemNum() - game.EffectMgr.instance.effect_base_pool:GetFreeNum(), game.EffectMgr.instance.effect_base_pool:GetItemNum())
			else
				return ""
			end
		end
	},
	{
		tick_func = function()
			return string.format(" Cache: %d/%d", game.CacheMgr:GetObjCount(), game.CacheMgr:GetCacheCount())
		end
	},
	{
		tick_func = function()
			if game.OperatePool then
				local use_num, total_num = game.OperatePool:Debug()
				return string.format(" Operate: %d/%d", use_num, total_num)
			else
				return string.format(" Operate: 0/0")
			end
		end
	},
	{
		tick_func = function()
			local name = ""
			local main_role = game.Scene.instance:GetMainRole()
			if main_role and main_role.oper_mgr then
				local cur_op = main_role.oper_mgr:GetCurOperate()
				if cur_op and cur_op.oper_type then
					for k, v in pairs(game.OperateType) do
						if cur_op.oper_type == v then
							name = k
							break
						end
					end
				end
			end
			return string.format(" CurOper: %s", name)
		end
	},
}

function MonitorView:_init(ctrl)
    self._package_name = "ui_monitor"
    self._com_name = "monitor_view"
    -- self._swallow_touch = false
	self._ui_order = game.UIZOrder.UIZOrder_Over
    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone
    self.ctrl = ctrl
end

function MonitorView:_delete()

end

function MonitorView:OpenViewCallBack()
	self.monitor_item_list = {}

	self.ui_list = game.UIList.New(self._layout_objs["n1"])
    self.ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/monitor/monitor_item").New()
        item:SetVirtual(obj)
        item:Open()
        return item
    end)
    self.ui_list:SetRefreshItemFunc(function(item, idx)
        item:SetRefreshFunc(monitor_config_list[idx].tick_func)
    end)
    self.ui_list:SetVirtual(true)
    self.ui_list:SetItemNum(#monitor_config_list)

    local refresh_func = function(item)
    	item:Refresh()
    end
    self.monitor_timer = global.TimerMgr:CreateTimer(0.5,
    	function()
    		self.ui_list:Foreach(refresh_func)
    	end)

    global.Runner:AddUpdateObj(self, 1)

    self.ctrl:StartFps()
end

function MonitorView:Update(now_time, elapse_time)
	self.ctrl:UpdateFps()
end

function MonitorView:CloseViewCallBack()
    global.Runner:RemoveUpdateObj(self)

    if self.monitor_timer then
    	global.TimerMgr:DelTimer(self.monitor_timer)
    	self.monitor_timer = nil
    end

    self.ui_list:DeleteMe()
    self.ui_list = nil
end

return MonitorView
