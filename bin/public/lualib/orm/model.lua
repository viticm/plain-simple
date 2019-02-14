--[[
 - PLAIN FRAMEWORK ( https://github.com/viticm/plain )
 - $Id model.lua
 - @link https://github.com/viticm/plain for the canonical source repository
 - @copyright Copyright (c) 2014- viticm( viticm.ti@gmail.com )
 - @license
 - @user viticm<viticm.ti@gmail.com>
 - @date 2019/02/13 11:26
 - @uses Modify the orm: you can create many diffrent db to use it, and change
         some global values name, Fix the execute bug and can use in lua >=5.1.
--]]


------------------------------------------------------------------------------
--                               Require                                    --
------------------------------------------------------------------------------

require('orm.class.global')
require("orm.tools.func")

local Table = require('orm.class.table')

------------------------------------------------------------------------------
--                                Constants                                 --
------------------------------------------------------------------------------
-- Global
ID = "id"
AGGREGATOR = "aggregator"
QUERY_LIST = "query_list"

-- databases types
SQLITE = "sqlite3"
ORACLE = "oracle"
MYSQL = "mysql"
POSTGRESQL = "postgresql"

--[[
------------------------------------------------------------------------------
--                              Model settings                              --
------------------------------------------------------------------------------


if not DB then
    print("[SQL:Startup] Can't find global database settings variable 'DB'. Creating empty one.")
    DB = {}
end

DB = {
    -- ORM settings
    new = (DB.new == true),
    DEBUG = (DB.DEBUG == true),
    backtrace = (DB.backtrace == true),
    -- database settings
    type = DB.type or "sqlite3",
    -- if you use sqlite set database path value
    -- if not set a database name
    name = DB.name or "database.db",
    -- not sqlite db settings
    host = DB.host or nil,
    port = DB.port or nil,
    username = DB.username or nil,
    password = DB.password or nil
}

local sql, _connect, err

-- Get database by settings
if DB.type == SQLITE then
    local luasql = require("luasql.sqlite3")
    sql = luasql.sqlite3()
    _connect, err = sql:connect(DB.name)

elseif DB.type == MYSQL then
    local luasql = require("luasql.mysql")
    sql = luasql.mysql()
    print(DB.name, DB.username, DB.password, DB.host, DB.port)
    _connect, err = sql:connect(DB.name, DB.username, DB.password, DB.host, DB.port)

elseif DB.type == POSTGRESQL then
    local luasql = require("luasql.postgres")
    sql = luasql.postgres()
    print(DB.name, DB.username, DB.password, DB.host, DB.port)
    _connect, err = sql:connect(DB.name, DB.username, DB.password, DB.host, DB.port)

else
    ORM_BACKTRACE(ORM_ERROR, "Database type not suported '" .. tostring(DB.type) .. "'")
end

if not _connect then
    ORM_BACKTRACE(ORM_ERROR, "Connect problem! error: " .. (err or ""))
end

-- if DB.new then
--     ORM_BACKTRACE(ORM_INFO, "Remove old database")

--     if DB.type == SQLITE then
--         os.remove(DB.name)
--     else
--         _connect:execute('DROP DATABASE `' .. DB.name .. '`')
--     end
-- end

------------------------------------------------------------------------------
--                               Database                                   --
------------------------------------------------------------------------------

-- Database settings
db = {
    -- Database connect instance
    connect = _connect,

    -- Execute SQL query
    execute = function (self, query)
        ORM_BACKTRACE(ORM_DEBUG, query)

        local result, err = self.connect:execute(query)

        if result then
            return result
        else
            print("db:execute error: ", err)
            ORM_BACKTRACE(ORM_WARNING, "Wrong SQL query")
        end
    end,

    -- Return insert query id
    insert = function (self, query)
        local _cursor = self:execute(query)
        return 1
    end,

    -- get parced data
    rows = function (self, query, own_table)
        local _cursor = self:execute(query)
        local data = {}
        local current_row = {}
        local current_table
        local row

        if _cursor then
            row = _cursor:fetch({}, "a")

            while row do
                for colname, value in pairs(row) do
                    current_table, colname = string.divided_into(colname, "_")

                    if current_table == own_table.__tablename__ then
                        current_row[colname] = value
                    else
                        if not current_row[current_table] then
                            current_row[current_table] = {}
                        end

                        current_row[current_table][colname] = value
                    end
                end

                table.insert(data, current_row)

                current_row = {}
                row = _cursor:fetch({}, "a")
            end

        end

        return data
    end
}
--]]

------------------------------------------------------------------------------
--                               Function                                   --
------------------------------------------------------------------------------

-- Create a connection to db.
function orm_connect(settings)
  settings = settings or {}
  settings = {
      -- ORM settings
      new = (settings.new == true),
      DEBUG = (settings.DEBUG == true),
      backtrace = (settings.backtrace == true),
      -- database settings
      type = settings.type or "sqlite3",
      -- if you use sqlite set database path value
      -- if not set a database name
      name = settings.name or "database.db",
      -- not sqlite db settings
      host = settings.host or nil,
      port = settings.port or nil,
      username = settings.username or nil,
      password = settings.password or nil
  }

  local sql, _connect, err

  -- Get database by settings
  if settings.type == SQLITE then
      local luasql = require("luasql.sqlite3")
      sql = luasql.sqlite3()
      _connect, err = sql:connect(settings.name)

  elseif settings.type == MYSQL then
      local luasql = require("luasql.mysql")
      sql = luasql.mysql()
      print(settings.name, settings.username, settings.password, settings.host, settings.port)
      _connect, err = sql:connect(settings.name, settings.username, settings.password, settings.host, settings.port)

  elseif settings.type == POSTGRESQL then
      local luasql = require("luasql.postgres")
      sql = luasql.postgres()
      print(settings.name, settings.username, settings.password, settings.host, settings.port)
      _connect, err = sql:connect(settings.name, settings.username, settings.password, settings.host, settings.port)

  else
      ORM_BACKTRACE(ORM_ERROR, "Database type not suported '" .. tostring(settings.type) .. "'")
      return
  end

  if not _connect then
      ORM_BACKTRACE(ORM_ERROR, "Connect problem! error: " .. (err or "unkown"))
      return
  end

  local db = {
      -- Database connect instance
      connect = _connect,

      -- Database settings.
      settings = settings,

      -- Execute SQL query
      execute = function (self, query)
          ORM_BACKTRACE(ORM_DEBUG, query)

          local result, err = self.connect:execute(query)

          if result then
              return result
          else
              ORM_BACKTRACE(ORM_WARNING, "Wrong SQL query! error: ".. (err or "unkown"))
          end
      end,

      -- Return insert query id
      insert = function (self, query)
          local _cursor = self:execute(query)
          local r = _cursor
          if self.settings.type == MYSQL then
            r = self.connect:getlastautoid()
          end
          return r
      end,

      -- get parced data
      rows = function (self, query, own_table)
          local _cursor = self:execute(query)
          local data = {}
          local current_row = {}
          local current_table
          local row

          if _cursor then
              row = _cursor:fetch({}, "a")

              while row do
                  for colname, value in pairs(row) do
                      current_table, colname = string.divided_into(colname, "_")

                      if current_table == own_table.__tablename__ then
                          current_row[colname] = value
                      else
                          if not current_row[current_table] then
                              current_row[current_table] = {}
                          end

                          current_row[current_table][colname] = value
                      end
                  end

                  table.insert(data, current_row)

                  current_row = {}
                  row = _cursor:fetch({}, "a")
              end

          end

          return data
      end
  }
  return db
end

return Table
