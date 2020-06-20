--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

local string_len = string.len
local string_byte = string.byte
local string_sub = string.sub
local string_gsub = string.gsub

function handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

function math.newrandomseed()
    local ok, socket = pcall(function()
        return require("socket")
    end)

    if ok then
        math.randomseed(socket.gettime() * 1000)
    else
        math.randomseed(os.time())
    end
    math.random()
    math.random()
    math.random()
    math.random()
end

function math.round(value)
    value = checknumber(value)
    return math.floor(value + 0.5)
end

local pi_div_180 = math.pi / 180
function math.angle2radian(angle)
    return angle * pi_div_180
end

function math.radian2angle(radian)
    return radian * 180 / math.pi
end

function math.clamp(val, min, max)
    if val < min then
        return min
    elseif val > max then
        return max
    else
        return val
    end
end

function io.exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

function io.readfile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

function io.writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

function io.pathinfo(path)
    local pos = string_len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string_byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 then -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string_sub(path, 1, pos)
    local filename = string_sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string_sub(filename, 1, extpos - 1)
    local extname = string_sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

function io.filesize(path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end

function table.nums(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function table.keys(hashtable)
    local keys = {}
    for k, v in pairs(hashtable) do
        keys[#keys + 1] = k
    end
    return keys
end

function table.values(hashtable)
    local values = {}
    for k, v in pairs(hashtable) do
        values[#values + 1] = v
    end
    return values
end

function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

function table.insertto(dest, src, begin)
    begin = checkint(begin)
    if begin <= 0 then
        begin = #dest + 1
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
end

function table.indexof(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then return i end
    end
    return false
end

function table.keyof(hashtable, value)
    for k, v in pairs(hashtable) do
        if v == value then return k end
    end
    return nil
end

function table.removebyvalue(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then break end
        end
        i = i + 1
    end
    return c
end

function table.map(t, fn)
    for k, v in pairs(t) do
        t[k] = fn(v, k)
    end
end

function table.walk(t, fn)
    for k,v in pairs(t) do
        fn(v, k)
    end
end

function table.filter(t, fn)
    for k, v in pairs(t) do
        if not fn(v, k) then t[k] = nil end
    end
end

function table.unique(t, bArray)
    local check = {}
    local n = {}
    local idx = 1
    for k, v in pairs(t) do
        if not check[v] then
            if bArray then
                n[idx] = v
                idx = idx + 1
            else
                n[k] = v
            end
            check[v] = true
        end
    end
    return n
end

function table.clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

-- Binary search for array
-- func returns
-- -1 for smaller than middle element
--  0 for equal middle element
--  1 for larger than middle element
-- returns nil for no matching element
function table.binarysearch(a, func)
    local l = 1
    local r = #a
    local m = math.ceil((l+r)*0.5)
    local c
    -- local ct = 0
    while l ~= m do
        c = func(a[m])
        -- ct = ct + 1
        if c == 0 then
            -- print("二分查找匹配了"..ct.."次")
            return a[m]
        elseif c == 1 then
            l = m+1
        else
            r = m-1
        end
        m = math.ceil((l+r)*0.5)
    end

    if l == m then
        c = func(a[m])
        -- ct = ct + 1
        if c == 0 then
            -- print("二分查找匹配了"..ct.."次")
            return a[m]
        end
    end
end

string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

function string.htmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string_gsub(input, k, v)
    end
    return input
end

function string.restorehtmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string_gsub(input, v, k)
    end
    return input
end

function string.nl2br(input)
    return string_gsub(input, "\n", "<br />")
end

function string.text2html(input)
    input = string_gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string_gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)
    return input
end

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string_sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string_sub(input, pos))
    return arr
end

function string.ltrim(input)
    return string_gsub(input, "^[ \t\n\r]+", "")
end

function string.rtrim(input)
    return string_gsub(input, "[ \t\n\r]+$", "")
end

function string.trim(input)
    input = string_gsub(input, "^[ \t\n\r]+", "")
    return string_gsub(input, "[ \t\n\r]+$", "")
end

function string.ucfirst(input)
    return string.upper(string_sub(input, 1, 1)) .. string_sub(input, 2)
end

local function urlencodechar(char)
    return "%" .. string.format("%02X", string_byte(char))
end
function string.urlencode(input)
    -- convert line endings
    input = string_gsub(tostring(input), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    input = string_gsub(input, "([^%w%.%- ])", urlencodechar)
    -- convert spaces to "+" symbols
    return string_gsub(input, " ", "+")
end

function string.urldecode(input)
    input = string_gsub (input, "+", " ")
    input = string_gsub (input, "%%(%x%x)", function(h) return string.char(checknumber(h,16)) end)
    input = string_gsub (input, "\r\n", "\n")
    return input
end

local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
function string.utf8len(input)
    local len  = string_len(input)
    local left = len
    local cnt  = 0
    
    while left ~= 0 do
        local tmp = string_byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function string.utf8lens(input)
    local len  = string_len(input)
    local left = len
    local lens = {}
    while left ~= 0 do
        local tmp = string_byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        lens[#lens+1] = len - left
    end
    return lens
end

function string.formatnumberthousands(num)
    local formatted = tostring(checknumber(num))
    local k
    while true do
        formatted, k = string_gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- 返回64位无符号整数字符串
local gametool = N3DClient.GameTool
function string.toU64String(val)
    if val >= 0 then
        return tostring(val)
    else
        return gametool.ToU64String(val)
    end
end

function string.first(input)
    local len  = string_len(input)
    if len <= 0 then
        return input
    end

    local left = len
    local start_idx = 0
    local end_idx = 0

    while left ~= 0 do
        local tmp = string_byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        end_idx = len - left
        break
    end

    return string_sub(input, start_idx, end_idx)
end

function string.last(input)
    local len  = string_len(input)
    if len <= 0 then
        return input
    end

    local left = len
    local start_idx = 0
    local end_idx = 0

    while left ~= 0 do
        local tmp = string_byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end

        start_idx = end_idx
        end_idx = len - left
    end

    return string_sub(input, start_idx+1, end_idx)
end

function string.lastPos(input)
    local len  = string_len(input)
    if len <= 0 then
        return input
    end

    local left = len
    local start_idx = 0
    local end_idx = 0

    while left ~= 0 do
        local tmp = string_byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end

        start_idx = end_idx
        end_idx = len - left
    end

    return start_idx+1, end_idx
end