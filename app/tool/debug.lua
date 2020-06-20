local function getRepeatStr(src_str, repeat_times)
    local result = ""
    for index = 1, repeat_times do
        result = result .. src_str
    end
    return result
end

local visited_table_list = {}
local function GetTableInfoRecursive(tbl, layer)
    if layer == 0 then
        visited_table_list = {}
    end
    visited_table_list[tbl] = true
    local result = getRepeatStr("\t", layer) .. "{\n"
    for key, value in pairs(tbl) do
        result = result .. getRepeatStr("\t", layer+1)
        if type(value) == "string" then
            result = result .. string.format("%s = \"%s\"\n", tostring(key), tostring(value))
        else 
            result = result .. string.format("%s = %s\n", tostring(key), tostring(value))
        end

        if type(value) == "table" and not visited_table_list[value] then
            result = result .. GetTableInfoRecursive(value, layer+1)
        end
    end
    result = result .. getRepeatStr("\t", layer) .. "}\n"

    return result
end

function PrintTable(tbl, not_print)
    local debugInfo = debug.getinfo(2)

    if type(tbl) ~= "table" then
        print(string.format("[PrintTable] arg1 %s is not a table", tostring(tbl)))
        return
    end

    local str = string.format( "\n from %s \n function %s \n line %d \n",debugInfo.source,debugInfo.name,debugInfo.currentline)
    print(str)

    local str = GetTableInfoRecursive(tbl, 0)
    if not not_print then
        print("\n" .. str)
    end
    return str
end
