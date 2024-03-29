------------------------------------------------------------------------------
--                               Require                                    --
------------------------------------------------------------------------------

local Type = require('orm.class.type')

------------------------------------------------------------------------------
--                                Constants                                 --
------------------------------------------------------------------------------

-- Backtrace types
ORM_ERROR = 'e'
ORM_WARNING = 'w'
ORM_INFO = 'i'
ORM_DEBUG = 'd'

ORM_All_Tables = {}

------------------------------------------------------------------------------
--                          Helping functions                               --
------------------------------------------------------------------------------

local _pairs = pairs

function pairs(Table)
    if Table.__classname__ == QUERY_LIST then
        return Table()
    else
        return _pairs(Table)
    end
end

function ORM_BACKTRACE(tracetype, message)
    if ORM_BACKTRACE_ON then
        if tracetype == ORM_ERROR then
            -- print("[SQL:Error] " .. message)
            log.slow_error("[SQL:Error] " .. message)
            os.exit()

        elseif tracetype == ORM_WARNING then
            -- print("[SQL:Warning] " .. message)
            log.slow_warning("[SQL:Warning] " .. message)

        elseif tracetype == ORM_INFO then
            -- print("[SQL:Info] " .. message)
            log.slow("[SQL:Info] " .. message)
        end
    end

    if ORM_DEBUG_ON and tracetype == ORM_DEBUG then
        -- print("[SQL:Debug] " .. message)
        log.slow_debug("[SQL:Debug] " .. message)
    end
end

function string.endswith(String, End)
    return End == '' or string.sub(String, -string.len(End)) == End
end

function string.cutend(String, End)
    return End == '' and String or string.sub(String, 0, -#End - 1)
end

function string.divided_into(String, separator)
    local separator_pos = string.find(String, separator)
    return string.sub(String, 0, separator_pos - 1),
           string.sub(String, separator_pos + 1, #String)
end

function table.has_key(array, key)
    if Type.is.table(key) and key.colname then
        key = key.colname
    end

    for array_key, _  in pairs(array) do
        if array_key == key then
            return true
        end
    end
end

function table.has_value(array, value)
    if Type.is.table(value) and value.colname then
        value = value.colname
    end

    for _, array_value  in pairs(array) do
        if array_value == value then
            return true
        end
    end
end

function table.join(array, separator)
    local result = ""
    local counter = 0

    if not separator then
        separator = ","
    end

    for _, value in pairs(array) do
        if counter ~= 0 then
            value = separator .. value
        end

        result = result .. value
        counter = counter + 1
    end

    return result
end
