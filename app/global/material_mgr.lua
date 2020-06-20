
local MaterialMgr = Class()

local _unity_material = UnityEngine.Material

function MaterialMgr:_init()
	
end

function MaterialMgr:_delete()

end

function MaterialMgr:Start()
	self.shader_desc = global.AssetLoader:GetShaderDesc("shader/default.ab", "shader_desc")
	self.extra_shader_desc = global.AssetLoader:GetShaderDesc("shader/extra.ab", "shader_desc")

	if game.Platform ~= "ios" then
		local ui_gray_shader = self.shader_desc:GetShader("Shader/UI-Gray")
		self.ui_gray_mat = _unity_material(ui_gray_shader)

		local ui_default_shader = self.shader_desc:GetShader("Shader/UI-Default")
		self.ui_default_mat = _unity_material(ui_default_shader)
	else
		local ui_gray_shader = self.shader_desc:GetShader("Shader/UI-GrayETC1")
		self.ui_gray_mat = _unity_material(ui_gray_shader)

		local ui_default_shader = self.shader_desc:GetShader("Shader/UI-DefaultETC1")
		self.ui_default_mat = _unity_material(ui_default_shader)
	end
end

function MaterialMgr:GetShader(name)
	local shader = self.shader_desc:GetShader(name)
	if not shader then
		shader = self.extra_shader_desc:GetShader(name)
	end
	return shader
end

function MaterialMgr:GetMaterial(shader_name)
	local shader = self:GetShader(shader_name)
	if shader then
		return _unity_material(shader)
	end
end

function MaterialMgr:GetUIGrayMat()
	return self.ui_gray_mat
end

function MaterialMgr:GetUIDefaultMat()
	return self.ui_default_mat
end

global.MaterialMgr = global.MaterialMgr or MaterialMgr.New()