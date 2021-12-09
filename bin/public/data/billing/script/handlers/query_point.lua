--[[
 - PLAIN FREAMEWORK ( https://github.com/viticm/plain-simple )
 - $Id query_point.lua
 - @link https://github.com/viticm/plain-simple for the canonical source repository
 - @copyright Copyright (c) 2021 viticm( viticm.ti@gmail.com )
 - @license
 - @user viticm( viticm.ti@gmail.com )
 - @date 2021/12/08 20:23
 - @uses 查询点数
--]]
local db_data = require 'db_data'
return function(pack)
  local account_model = db_data.account_model
  local account = account_model.get:where({name = pack.username}):first()
  local point = account and account.point or 0
  billing_tool_t.check_online(pack.username, {ip = pack.ip})
  log.fast_debug(
    'user(%s|%s) query_point at: %s', pack.username, pack.rolename, pack.ip)
  return {
    username = pack.username,
    point = point * 1000,
  }
end
