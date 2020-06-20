
local VoiceMgr = Class()

local _voice_engine = N3DClient.VoiceManager:GetInstance()
local _event_mgr = global.EventMgr
local _time = global.Time
local _next_update_time = 0
local _update_interval = 1

local _play_type = {share_file = 1, local_file = 2}

VoiceMgr.VoiceMode =
{
	RealTime = 0, -- realtime mode for TeamRoom or NationalRoom
    Messages = 1,     -- voice message mode
    Translation = 2,  -- speach to text mode
    RSTT = 3, -- real-time speach to text mode
    HIGHQUALITY =4, --high quality realtime voice, will cost more network traffic
}

function VoiceMgr:_init()
	self.record_id = 0
	self.is_recording = nil
	self.start_play_time = nil
	self.playing_info = {}
	self.share_id_to_record_id = {}
	self.upload_complete_callback_dic = {}
	self.speech_to_text_complete_callback_dic = {}
	self.download_complete_callback_dic = {}
	self.download_complete_file_dic = {}
	self.download_file_time_cache_dic = {}
	self.local_file_time_cache_dic = {}

	if _voice_engine then
		_voice_engine:SetUploadRecordFileCompleteCallback(function (is_success, record_id, share_id)
			local callback = self.upload_complete_callback_dic[record_id]
			if callback then
				callback(is_success, record_id, share_id)
				self.upload_complete_callback_dic[record_id] = nil
			end

			if is_success then
				self.share_id_to_record_id[share_id] = record_id
				_voice_engine:SpeechToText(share_id)
			else
				local speech_to_text_callback = self.speech_to_text_complete_callback_dic[record_id]
				if speech_to_text_callback then
					speech_to_text_callback(is_success, record_id, share_id, "")
					self.speech_to_text_complete_callback_dic[record_id] = nil
				end
			end
		end)

		_voice_engine:SetSpeechToTextCompleteCallback(function (is_success, share_id, result)
			local record_id = self.share_id_to_record_id[share_id]
			local callback = self.speech_to_text_complete_callback_dic[record_id]
			if callback then
				callback(is_success, record_id, share_id, result)
				self.speech_to_text_complete_callback_dic[record_id] = nil
			end
		end)

		_voice_engine:SetDownloadRecordFileCompleteCallback(function (is_success, share_id)
			local callback = self.download_complete_callback_dic[share_id]
			if callback then
				callback(is_success, share_id)
				self.download_complete_callback_dic[share_id] = nil
			end

			if is_success then
				self.download_complete_file_dic[share_id] = is_success
			end
		end)
	end

	--self.voice_effect_change_event_id = _event_mgr:Bind(game.VoiceEvent.VoiceEffectChange, function (voice_effect_type)
	--	self:SetVoiceEffect(voice_effect_type)
	--end)

	global.Runner:AddUpdateObj(self, 2)
end

function VoiceMgr:_delete()
	global.Runner:RemoveUpdateObj(self)
end

function VoiceMgr:Update(now_time, elapse_time)
	if now_time > _next_update_time then
		_next_update_time = now_time + _update_interval
		if self:IsPlaying() then
			local cur_play_end_time = self:GetCurPlayingEndTime()
			if cur_play_end_time and now_time > cur_play_end_time then
				self:_StopPlay()
			end
		end
	end
end

function VoiceMgr:InitEngine(app_id, app_key, mode)
	if self.is_init then
		return true
	end

	if not _voice_engine then
		return true
	end

	local volume = 0xff00 + 0xf
	if game.PlatformCtrl.instance:IsAndroidPlatform() then
		volume = 200
	elseif game.PlatformCtrl.instance:IsIosPlatform() then
		volume = 200
	end
	_voice_engine:SetSpeakerVolume(volume)

	app_id = app_id or "1810638352"
	app_key = app_key or "334877bb9826cdb32d378b3232c1a95d"
	mode = mode or VoiceMgr.VoiceMode.Translation
	_voice_engine:InitEngine(app_id, app_key, mode)
	self.is_init = true

	return false
end

function VoiceMgr:IsEngineReady()
	if self.is_engine_ready then
		return true
	end

	if not _voice_engine or not _voice_engine.IsEngineReady then
		return false, 2019
	end

	if not _voice_engine:IsEngineReady() then
		self:InitEngine()
		return false, 2020
	end

	self.is_engine_ready = true
	return true
end

function VoiceMgr:TestMic()
	if not _voice_engine then
		return false, 2020
	end

	if not _voice_engine:TestMic() then
		return false, 2021
	end

	return true
end

function VoiceMgr:StartRecord()
	if not _voice_engine then
		return
	end
	if not self.is_recording then
		self.is_recording = true
		self.record_time = 0
		self.record_id = self.record_id + 1
		_voice_engine:StartRecord(self.record_id)
		_event_mgr:Fire(game.VoiceEvent.OnStartRecord, self.record_id)
		return self.record_id
	end
end

function VoiceMgr:StopRecord()
	if not _voice_engine then
		return
	end
	if self.is_recording then
		self.is_recording = false
		_voice_engine:StopRecord()
		_event_mgr:Fire(game.VoiceEvent.OnStopRecord, self.record_id)
	end
end

function VoiceMgr:UploadRecord(record_id, upload_complete_callback, speech_to_text_complete_callback)
	if not _voice_engine then
		return
	end
	_voice_engine:UploadFile(record_id)
	if upload_complete_callback then
		self.upload_complete_callback_dic[record_id] = upload_complete_callback
	end
	if speech_to_text_complete_callback then
		self.speech_to_text_complete_callback_dic[record_id] = speech_to_text_complete_callback
	end
end

function VoiceMgr:StopAndUploadRecord(upload_complete_callback, speech_to_text_complete_callback)
	if self.is_recording then
		self:StopRecord()
		self:UploadRecord(self.record_id, upload_complete_callback, speech_to_text_complete_callback)
	end
end

function VoiceMgr:PlayRecordFile(share_id, download_complete_callback)
	if not _voice_engine then
		return
	end
	if self:IsPlaying() then
		self:StopPlayRecordFile()
	end

	local on_download_file_func = function(_is_success, _share_id)
		if download_complete_callback then
			download_complete_callback(_is_success, _share_id)
		end
		if _is_success and share_id == _share_id then
			self:_StartPlay(_play_type.share_file, share_id)
			_voice_engine:PlayRecordFile(share_id)
		end
	end

	if self.download_complete_file_dic[share_id] then
		on_download_file_func(true, share_id)
	else
		self.download_complete_callback_dic[share_id] = on_download_file_func
		_voice_engine:DownloadFile(share_id)
	end
end

function VoiceMgr:PlayLocalRecordFile(record_id)
	if not _voice_engine then
		return
	end
	if self:IsPlaying() then
		self:StopPlayRecordFile()
	end

	self:_StartPlay(_play_type.local_file, record_id)
	_voice_engine:PlayLocalRecordFile(record_id)
end

function VoiceMgr:StopPlayRecordFile()
	if not _voice_engine then
		return
	end
	self:_StopPlay()
	_voice_engine:StopPlayRecordFile()
end

function VoiceMgr:GetMicLevel(is_fate_out)
	if not _voice_engine then
		return 0
	end
	return _voice_engine:GetMicLevel(is_fate_out)
end

function VoiceMgr:GetDownLoadRecordTime(share_id)
	if not _voice_engine then
		return 0
	end
	if not self.download_file_time_cache_dic[share_id] then
		self.download_file_time_cache_dic[share_id] = _voice_engine:GetDownloadFileTime(share_id)
	end
	return self.download_file_time_cache_dic[share_id]
end

function VoiceMgr:GetLocalRecordTime(record_id)
	if not _voice_engine then
		return 0
	end
	if not self.local_file_time_cache_dic[record_id] then
		self.local_file_time_cache_dic[record_id] = _voice_engine:GetRecFileTime(record_id)
	end
	return self.local_file_time_cache_dic[record_id]
end

function VoiceMgr:GetPlayingState()
	local record_id, share_id
	local is_playing = self:IsPlaying()
	if is_playing then
		record_id = self.playing_info.play_type == _play_type.local_file and self.playing_info.id
		share_id = self.playing_info.play_type == _play_type.share_file and self.playing_info.id
	end
	return is_playing, record_id, share_id
end

function VoiceMgr:IsPlaying()
	return self.playing_info.is_playing and true or false
end

function VoiceMgr:GetCurPlayingStartTime()
	return self.playing_info.play_start_time
end

function VoiceMgr:GetCurPlayingEndTime()
	if not self:IsPlaying() then
		return nil
	end
	if self.playing_info.play_type == _play_type.share_file then
		return self:GetDownLoadFilePlayEndTime(self.playing_info.id)
	elseif self.playing_info.play_type == _play_type.local_file then
		return self:GetLocalFilePlayEndTime(self.playing_info.id)
	end
	return nil
end

function VoiceMgr:GetDownLoadFilePlayEndTime(share_id)
	local play_start_time = self:GetCurPlayingStartTime()
	if not play_start_time then
		return nil
	end
	return play_start_time + self:GetDownLoadRecordTime(share_id)
end

function VoiceMgr:GetLocalFilePlayEndTime(record_id)
	local play_start_time = self:GetCurPlayingStartTime()
	if not play_start_time then
		return nil
	end
	return play_start_time + self:GetLocalRecordTime(record_id)
end

function VoiceMgr:SetVoiceEffect(effect_type)
	if not _voice_engine then
		return
	end
	--_voice_engine:SetVoiceEffect(7)
end

function VoiceMgr:_StartPlay(play_type, id)
	self.playing_info.is_playing = true
	self.playing_info.play_type = play_type
	self.playing_info.id = id
	self.playing_info.play_start_time = _time.now_time

	local record_id = play_type == _play_type.local_file and id
	local share_id = play_type == _play_type.share_file and id
	_event_mgr:Fire(game.VoiceEvent.OnStartPlay, record_id, share_id)
end

function VoiceMgr:_StopPlay()
	self.playing_info.is_playing = false

	local record_id = self.playing_info.play_type == _play_type.local_file and self.playing_info.id
	local share_id = self.playing_info.play_type == _play_type.share_file and self.playing_info.id
	_event_mgr:Fire(game.VoiceEvent.OnStopPlay, record_id, share_id)
end

function VoiceMgr:PauseBGMPlay()
	_voice_engine:PauseBGMPlay()
end

function VoiceMgr:ResumeBGMPlay()
	_voice_engine:ResumeBGMPlay()
end

game.VoiceMgr = VoiceMgr.New()

