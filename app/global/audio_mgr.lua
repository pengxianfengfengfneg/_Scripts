local AudioMgr = Class()

local _audio = N3DClient.AudioManager:GetInstance()
local _asset_loader = global.AssetLoader
local _default_cache_time = 120
local _default_over_time = 1

function AudioMgr:_init()
    self.now_time = 0
    self.free_time = 0
    self.sound_cache = {}
    self.sound_key_list = {}
    self.sound_res_path = {}
    self.music_res_path = {}
    self.count = 0
end

function AudioMgr:_delete()
    self:EnableMusic(true)
    self:EnableSound(true)
    
    self:StopAllSound()
    self:StopMusic()

    for _, v in pairs(self.sound_cache) do
        self:UnLoadCache(v)
    end
    self.sound_cache = nil
    self.sound_key_list = nil
    self.sound_res_path = nil
    self.music_res_path = nil
    self.count = 0

    if self.music_handler then
        _asset_loader:UnLoad(self.music_handler)
        self.music_handler = nil
    end
end

function AudioMgr:Update(now_time)
    self.now_time = now_time
    if now_time > self.free_time then
        self.free_time = now_time + 5
        for _, v in pairs(self.sound_cache) do
            if now_time > v.cache_time and v.is_load then
                self:UnLoadCache(v)
                v.is_load = false
            end
        end
    end
end

function AudioMgr:GetSoundPath(sound_name)
    if not self.sound_res_path[sound_name] then
        self.sound_res_path[sound_name] = string.format("audio/sound/%s.ab", sound_name)
    end
    return self.sound_res_path[sound_name]
end

function AudioMgr:PlaySound(sound_name, cache_time, over_time, loop)
    self.count = self.count + 1
    loop = loop and true or false
    local path = self:GetSoundPath(sound_name)
    local sound_item = self.sound_cache[path]
    cache_time = (cache_time or _default_cache_time) + self.now_time
    if sound_item and sound_item.is_load then
        sound_item.cache_time = cache_time
        local sound_key = _audio:PlaySound(path, sound_name, loop)
        self.sound_key_list[self.count] = sound_key
    else
        sound_item = {}
        sound_item.cache_time = cache_time
        sound_item.over_time = (over_time or _default_over_time) + self.now_time
        sound_item.asset_handler = _asset_loader:LoadAsset(path, sound_name, function()
            self:OnLoadFinish(path, sound_name, sound_item, loop, self.count)
        end)
    end
    return self.count
end

function AudioMgr:OnLoadFinish(path, sound_name, item, loop, count)
    if self.now_time < item.over_time then
        item.is_load = true
        self.sound_cache[path] = item
        local sound_key = _audio:PlaySound(path, sound_name, loop)
        self.sound_key_list[count] = sound_key
    end
end

function AudioMgr:StopAllSound()
    _audio:StopSound()
end

function AudioMgr:StopSound(key)
    if self.sound_key_list[key] then
        _audio:StopSound(self.sound_key_list[key])
    end
end

function AudioMgr:GetMusicPath(music_name)
    if not self.music_res_path[music_name] then
        self.music_res_path[music_name] = string.format("audio/music/%s.ab", music_name)
    end
    return self.music_res_path[music_name]
end

function AudioMgr:PlayMusic(music_name)
    local path = self:GetMusicPath(music_name)
    if self.music_handler then
        self:StopMusic()
        _asset_loader:UnLoad(self.music_handler)
    end
    self.music_handler = _asset_loader:LoadAsset(path, music_name, function()
        _audio:PlayMusic(path, music_name)
    end)
end

function AudioMgr:ResumeMusic()
    _audio:PlayMusic()
end

function AudioMgr:PauseMusic()
    _audio:PauseMusic()
end

function AudioMgr:StopMusic()
    _audio:StopMusic()
end

function AudioMgr:UnLoadCache(item)
    if item.asset_handler then
        _asset_loader:UnLoad(item.asset_handler)
        item.asset_handler = nil
    end
end

function AudioMgr:SetSoundVolume(val)
    _audio.soundVolume = val
end

function AudioMgr:GetSoundVolume()
    return _audio.soundVolume
end

function AudioMgr:SetMusicVolume(val)
    _audio.musicVolume = val
end

function AudioMgr:GetMusicVolume()
    return _audio.musicVolume
end

function AudioMgr:EnableMusic(val)
    _audio:EnableMusic(val)
end

function AudioMgr:EnableSound(val)
    _audio:EnableSound(val)
end

function AudioMgr:PlayVoice(sound_name, cache_time, over_time)
    local path = self:GetSoundPath(sound_name)
    local sound_item = self.sound_cache[path]
    cache_time = (cache_time or _default_cache_time) + self.now_time
    if sound_item and sound_item.is_load then
        sound_item.cache_time = cache_time
        local sound_key = _audio:PlayVoice(path, sound_name)
        self.sound_key_list[path] = sound_key
    else
        sound_item = {}
        sound_item.cache_time = cache_time
        sound_item.over_time = (over_time or _default_over_time) + self.now_time
        sound_item.asset_handler = _asset_loader:LoadAsset(path, sound_name, function()
            self:OnLoadVoiceFinish(path, sound_name, sound_item)
        end)
    end
end

function AudioMgr:OnLoadVoiceFinish(path, sound_name, item)
    if self.now_time < item.over_time then
        item.is_load = true
        self.sound_cache[path] = item
        local sound_key = _audio:PlayVoice(path, sound_name)
        self.sound_key_list[path] = sound_key
    end
end

global.AudioMgr = AudioMgr.New()