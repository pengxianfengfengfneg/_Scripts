local Utils = {}

local _string_find = string.find
local math_floor = math.floor
local math_ceil = math.ceil
local math_modf = math.modf
local math_min = math.min
local string_len = string.len
local string_gsub = string.gsub
local string_sub = string.sub
local string_format = string.format
local string_utf8len = string.utf8len
local tonumber = tonumber
local tostring = tostring
local type = type
local os_time = os.time
local os_date = os.date
local table_insert = table.insert
local table_sort = table.sort
local _ui_mgr = N3DClient.UIManager:GetInstance()

-- 检查非法字符
function Utils.CheckMaskWords(str)
    for i,v in ipairs(game.NameFilterList) do
        if _string_find(str, v) then
            return true
        end
    end

    local words = config.mask_word or {}
    for i, v in ipairs(words) do
        if _string_find(str, v) then
            return true
        end
    end
    return false
end

-- 检查非法聊天字符
function Utils.CheckMaskChatWords(str)
    local words = config.mask_word or {}
    for i, v in ipairs(words) do
        if _string_find(str, v) then
            return true
        end
    end
    return false
end

local MaskWord = {
    "*",
    "**",
    "***",
    "****",
    "*****",
    "******",
}
function Utils.TranslateMaskWords(str)
    for i, v in ipairs(config.mask_word or {}) do
        str = string_gsub(str, v, function(str_match)
            local len = (string_utf8len(str_match))
            return MaskWord[len] or MaskWord[6]
        end)
    end
    return str
end

--获取当天的开始时间戳
function Utils.NowDaytimeStart(now_time)
    if now_time <= 86400 then
        return 0
    end
    local tab = os_date("*t", now_time)
    tab.hour = 0
    tab.min = 0
    tab.sec = 0
    local result = os_time(tab)
    return result
end

function Utils.GetTimeStr(sec)
    return string_format("%d:%d", sec // 60, sec % 60)
end

local gametool = N3DClient.GameTool
function Utils.FindWay(unit_src_x, unit_src_y, unit_dst_x, unit_dst_y)
    local ret, path = gametool.CalculatePath(unit_src_x, unit_src_y, unit_dst_x, unit_dst_y)
    return ret, path
end

function Utils.SamplePos(x, y)
    return gametool.SamplePosition(x, y, 1.0)
end

function Utils.RaycastPath(sx, sy, dx, dy)
    return gametool.RaycastPath(sx, sy, dx, dy)
end

local _attr_calc_cfg = config.combat_power_battle
-- attr_list = {{key, value}, ... }
function Utils.CalculateCombatPower(attr_list)
    local power = 0
    for i, attr in pairs(attr_list) do
        power = power + attr[2] * _attr_calc_cfg[attr[1]].value
    end
    return math_ceil(power)
end

local _attr_calc_cfg_battle = config.combat_power_battle
local _attr_calc_cfg_base = config.combat_power_base
function Utils.CalculateCombatPower2(attr_list)

    local power = 0

    for i, attr in pairs(attr_list) do

        local use_cfg = _attr_calc_cfg_battle
        local attr_type = attr.key

        if not attr_type then
            attr_type = attr[1]
        end

        local attr_value = attr.value
        if not attr_value then
            attr_value = attr[2]
        end

        if attr_type > 100 then
            attr_type = attr_type - 100
            use_cfg = _attr_calc_cfg_base
        end

        local factor = use_cfg[attr_type].value
        power = power + attr_value * factor
    end
    return math_ceil(power)
end

--[[
    id value 类型
]]
function Utils.CalculateCombatPower3(attr_list)

    local power = 0

    for i, attr in pairs(attr_list) do

        local use_cfg = _attr_calc_cfg_battle
        local attr_type = attr.id
        local attr_value = attr.value

        if attr_type > 100 then
            attr_type = attr_type - 100
            use_cfg = _attr_calc_cfg_base
        end

        local factor = use_cfg[attr_type].value
        power = power + attr_value * factor
    end
    return math_ceil(power)
end

function Utils.Sort(data, func)
    local sort_list = {}
    for k, v in pairs(data) do
        table_insert(sort_list, {k=k, v=v})
    end
    table_sort(sort_list, func)
    for k, v in ipairs(sort_list) do
        sort_list[k] = v.v
    end
    return sort_list
end

function Utils.SortByKey(data, func)
    return Utils.Sort(data, function(m, n)
        if func then
            return func(m.k, n.k)
        else
            return m.k < n.k
        end
    end)
end

function Utils.SortByField(data, field, func)
    return Utils.Sort(data, function(m, n)
        if func then
            return func(m.v[field], n.v[field])
        else
            return m.v[field] < n.v[field]
        end
    end)
end

local WordDay = config.words[107]
local WordHour = config.words[108]
local WordMin = config.words[103]
local WordSec = config.words[104]

function Utils.SecToTime(second)
    local hour = math_floor(second / 3600)
    local minutes = math_floor((second - hour * 3600) / 60)
    local seconds = (second - hour * 3600) % 60
    return string_format("%d%s%d%s", minutes, WordMin, seconds, WordSec)
end

function Utils.SecToTime2(second)
    local hour = math_floor(second / 3600)
    local minutes = math_floor((second - hour * 3600) / 60)
    local seconds = (second - hour * 3600) % 60
    if hour == 0 then
        return string_format("%02d:%02d", minutes, seconds)
    else
        return string_format("%02d:%02d:%02d", hour, minutes, seconds)
    end
end

local DaySec = 1*24*60*60
local HourSec = 60*60
local MinSec = 60
local TimeFormatCn = game.TimeFormatCn
local CnTime = {
    day = 0,
    hour = 0,
    min = 0,
    sec = 0,
}
local TimeFormatCnFunc = {
    [TimeFormatCn.DayHourMinSec] = function(tb)
        return string_format("%d%s%d%s%d%s%d%s", tb.day, WordDay, tb.hour, WordHour, tb.min, WordMin, tb.sec, WordSec)
    end,
    [TimeFormatCn.DayHourMin] = function(tb)
        return string_format("%d%s%d%s%d%s", tb.day, WordDay, tb.hour, WordHour, tb.min, WordMin)
    end,
    [TimeFormatCn.DayHour] = function(tb)
        return string_format("%d%s%d%s", tb.day, WordDay, tb.hour, WordHour)
    end,
    [TimeFormatCn.Day] = function(tb)
        return string_format("%d%s", tb.day, WordDay)
    end,
    [TimeFormatCn.HourMinSec] = function(tb)
        return string_format("%d%s%d%s%d%s", tb.hour, WordHour, tb.min, WordMin, tb.sec, WordSec)
    end,
    [TimeFormatCn.HourMin] = function(tb)
        return string_format("%d%s%d%s", tb.hour, WordHour, tb.min, WordMin)
    end,
    [TimeFormatCn.Hour] = function(tb)
        return string_format("%d%s", tb.hour, WordHour)
    end,
    [TimeFormatCn.MinSec] = function(tb)
        return string_format("%d%s%d%s", tb.min, WordMin, tb.sec, WordSec)
    end,
    [TimeFormatCn.Min] = function(tb)
        return string_format("%d%s", tb.min, WordMin)
    end,
    [TimeFormatCn.Sec] = function(tb)
        return string_format("%d%s", WordSec)
    end,
}
function Utils.SecToTimeCn(second, time_format)
    CnTime.day = math_floor(second / DaySec)
    CnTime.hour = math_floor(second%DaySec/HourSec)
    CnTime.min = math_floor(second%HourSec/MinSec)
    CnTime.sec = second % 60

    local func = TimeFormatCnFunc[time_format] or TimeFormatCnFunc[TimeFormatCn.MinSec]
    return func(CnTime)
end

local TimeFormatEn = game.TimeFormatEn
local EnTime = {
    day = 0,
    hour = 0,
    min = 0,
    sec = 0,
}
local TimeFormatEnFunc = {
    [TimeFormatEn.HourMinSec] = function(tb)
        return string_format("%02d:%02d:%02d", tb.hour, tb.min, tb.sec)
    end,
    [TimeFormatEn.HourMin] = function(tb)
        return string_format("%02d:%02d", tb.hour, tb.min)
    end,
    [TimeFormatEn.MinSec] = function(tb)
        return string_format("%02d:%02d", tb.min, tb.sec)
    end,
    [TimeFormatEn.Sec] = function(tb)
        return string_format("%02d", tb.sec)
    end,
}
function Utils.SecToTimeEn(second, time_format)
    EnTime.hour = math_floor(second%DaySec/HourSec)
    EnTime.min = math_floor(second%HourSec/MinSec)
    EnTime.sec = second % 60

    local func = TimeFormatEnFunc[time_format] or TimeFormatEnFunc[TimeFormatEn.MinSec]
    return func(EnTime)
end

function Utils.SetTip(component, val, pos)
    local dot = component:GetChild("666666")
    if dot == nil then
        if val == false then
            return
        end
        dot = _ui_mgr:CreateObject("ui_main", "hd")
        dot.name = "666666"
        component:AddChild(dot)
        if pos == nil then
            pos = cc.vec2(0, 0)
        end
        dot:SetPosition(pos.x, pos.y)
    else
        dot:SetVisible(val)
        if pos then
            dot:SetPosition(pos.x, pos.y)
        end
    end
end

--10月10日 12:20
function Utils.ConvertToStyle1(stamp)

    local tab = os_date("*t", stamp)
    return string_format(config.words[4203], tab.month, tab.day, tab.hour, tab.min)
end

--[[ 
    @max_int_len: 整数最大长度，超出时转化为下一单位，可缺省
    @max_dec_len: 小数最大长度，可缺省
    @limit_len: 数字最大容纳长度，超出时忽略小数部分，可缺省
 ]]
 local units_list = {"", config.words[4734], config.words[4735], config.words[4736], config.words[4737]}
function Utils.NumberFormat(val, max_int_len, max_dec_len, limit_len)
    local base_value = 10^(max_int_len or 4)
    local max_dec_len = max_dec_len or 2
    local limit_len = limit_len or 5

    local factor = 10^4
    local base_divisor = 1

    local number_list = {}
    for i=1, #units_list do
        table_insert(number_list, {base_value - 1, base_divisor})
        base_value = base_value * factor
        base_divisor = base_divisor * factor
    end

    local format_func = function(val)
        local integer, decimal = math_modf(val)
        local int_len = string_len(integer)
        if int_len >= limit_len then
            return integer
        else
            local dec_len = math_min(limit_len - int_len, max_dec_len)
            decimal = string_format("%."..dec_len.."f", decimal)
            local result = integer + decimal
            integer, decimal = math_modf(result)
            if decimal > 0 then
                return result
            else
                return integer
            end
        end
    end

    for idx, t in ipairs(number_list) do
        if val <= t[1] then
            return format_func(val / t[2]) .. units_list[idx]
        end
    end
    
    local max_idx = #number_list
    return format_func(val / number_list[max_idx][2]) .. units_list[max_idx]
end

function Utils.getTableLength(tab)

    if type(tab) == "table" then

        local length = 0
        for k, v in pairs(tab) do
            length = length + 1
        end
        return length
    else
        return 0
    end
end

function Utils.ColorWrapper(words, color_string, ubb)
    ubb = ubb or false
    if ubb then
        return string_format("[color=#%s]%s[/color]", color_string, words)
    else
        return string_format("<font color='%s'>%s</font>", color_string, words)
    end
end

function Utils.GetColorName(color)

    if color == 1 then
        return config.words[1243]
    elseif color == 2 then
        return config.words[1244]
    elseif color == 3 then
        return config.words[1245]
    elseif color == 4 then
        return config.words[1246]
    elseif color == 5 then
        return config.words[1247]
    elseif color == 6 then
        return config.words[1248]
    else
        return ""
    end
end

---阿拉伯数字转中文大写
local hzUnit = {"", "十", "百", "千", "万", "十", "百", "千", "亿","十", "百", "千", "万", "十", "百", "千"}
local hzNum = {"零", "一", "二", "三", "四", "五", "六", "七", "八", "九"}
function Utils.GetNumStr(szNum)
    local szChMoney = ""
    local iLen = 0
    local iNum = 0
    local iAddZero = 0
    
    if szNum == 0 then
        return hzNum[1]
    end

    if nil == tonumber(szNum) then
        return tostring(szNum)
    end

    iLen =string_len(szNum)
    if iLen > 10 or iLen == 0 or tonumber(szNum) < 0 then
        return tostring(szNum)
    end

    for i = 1, iLen  do
        iNum = string_sub(szNum,i,i)
        if iNum == 0 and i ~= iLen then
            iAddZero = iAddZero + 1
        else
            if iAddZero > 0 then
            szChMoney = szChMoney..hzNum[1]
        end
            szChMoney = szChMoney..hzNum[iNum + 1] --//转换为相应的数字
            iAddZero = 0
        end
        if (iAddZero < 4) and (0 == (iLen - i) % 4 or 0 ~= tonumber(iNum)) then
            szChMoney = szChMoney..hzUnit[iLen-i+1]
        end
    end
    local function removeZero(num)
        --去掉末尾多余的 零
        num = tostring(num)
        local szLen = string_len(num)
        local zero_num = 0
        for i = szLen, 1, -3 do
            szNum = string_sub(num,i-2,i)
            if szNum == hzNum[1] then
                zero_num = zero_num + 1
            else
                break
            end
        end
        num = string_sub(num, 1,szLen - zero_num * 3)
        szNum = string_sub(num, 1,6)
        --- 开头的 "一十" 转成 "十" , 贴近人的读法
        if szNum == hzNum[2]..hzUnit[2] then
            num = string_sub(num, 4, string_len(num))
        end
        return num
    end
    return removeZero(szChMoney)
end

local WdayWords = {
    config.words[111],
    config.words[112],
    config.words[113],
    config.words[114],
    config.words[115],
    config.words[116],
    config.words[123],
}
local WeekWords = {
    [1] = config.words[121],
    [2] = config.words[122],
}
function Utils.GetWeekCn(wday, week_format)
    local week_word = WeekWords[week_format or 1]
    local wday_word = WdayWords[(wday-1)%7+1]
    return week_word .. wday_word
end

function Utils:getStartStamp(start_time)

    local start_stamp = 0
    local start_hour = start_time[1]
    local start_min = start_time[2]
    local cur_time = global.Time:GetServerTime()
    local cur_tab = os.date("*t", cur_time)
    local cur_hour = cur_tab.hour
    local cur_min = cur_tab.min
    local cur_sec = cur_tab.sec
    start_stamp = cur_time + (start_hour - cur_hour)*3600 + (start_min - cur_min)*60 - cur_sec

    return start_stamp
end

local Wan = 10^4
local Yi = 10^8
local WanWord = config.words[4734]
local YiWord = config.words[4735]
function Utils.FormatLargeNum(num)
    if num < Wan then
        return num
    else
        if num < Yi then
            return math_floor(num / Wan) .. WanWord
        else
            local t = math_floor(num / Wan)
            return math_floor(t / Wan) .. YiWord .. math_floor(t % Wan) .. WanWord
        end
    end
end

-- 解析字符串：name[type]
function Utils.ParseTypeName(str)
    local param = string.match(str, "%[%d+%]")
    local type = tonumber(string.sub(param, string.find(param,"%d+")))
    local name = string.match(str, "[^%[]+")
    return type, name
end

function Utils.GetMoneyTypeById(item_id)
    for k, v in pairs(config.money_type) do
        if v.goods == item_id then
            return v.id
        end
    end
end

function Utils.GetGenderName(gender)
    if gender == 1 then
        return config.words[144]
    else
        return config.words[145]
    end
end

function Utils.IsChinese(word)
    local ret = {}    
    local f = '[\65-\90\97-\122\194-\244][\128-\191]*'  
    local _len = 0  
    for v in string.gmatch(word, f) do
        if #v == 3 and v~= nil then
            _len = _len + #v
        end   
    end
    if _len ~= string.len(word) then
        return false
    end
    return true
end

--截取中英混合的UTF8字符串，endIndex可缺省
function Utils.SubStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = Utils.SubStringGetTotalIndex(str) + startIndex + 1;
    end
 
    if endIndex ~= nil and endIndex < 0 then
        endIndex = Utils.SubStringGetTotalIndex(str) + endIndex + 1;
    end
 
    if endIndex == nil then 
        return string.sub(str, Utils.SubStringGetTrueIndex(str, startIndex));
    else
        return string.sub(str, Utils.SubStringGetTrueIndex(str, startIndex), Utils.SubStringGetTrueIndex(str, endIndex + 1) - 1);
    end
end
 
--获取中英混合UTF8字符串的真实字符数量
function Utils.SubStringGetTotalIndex(str)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = Utils.SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(lastCount == 0);
    return curIndex - 1;
end
 
function Utils.SubStringGetTrueIndex(str, index)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = Utils.SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(curIndex >= index);
    return i - lastCount;
end
 
--返回当前字符实际占用的字符数
function Utils.SubStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<=223 then
        byteCount = 2
    elseif curByte>=224 and curByte<=239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount;
end

game.Utils = Utils

return Utils
