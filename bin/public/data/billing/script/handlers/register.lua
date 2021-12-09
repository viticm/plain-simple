--[[
 - PLAIN FREAMEWORK ( https://github.com/viticm/plain-simple )
 - $Id register.lua
 - @link https://github.com/viticm/plain-simple for the canonical source repository
 - @copyright Copyright (c) 2021 viticm( viticm.ti@gmail.com )
 - @license
 - @user viticm( viticm.ti@gmail.com )
 - @date 2021/12/08 20:23
 - @uses 注册
--]]
local db_data = require 'db_data'
local e_code = {
  succ = 1,
  unknown = 4,
}

-- 注册
-- @param table args 参数
-- @return number
local function reg(args)
  local account_model = db_data.account_model
  local account = account_model.get:where({name = args.username}):first()
  if account then
      return e_code.unknown
  end
  if not args.username or string.len(args.username) > 32 then
    log.fast_debug('register username(%s) check error', args.username or '')
    return e_code.unknown
  end
	if not args.email or not util_t.is_email(args.email) then
    log.fast_debug('register email(%s) check error', args.email or '')
    return e_code.unknown
  end
  account = account_model({
    name = args.username,
    password = args.password,
    is_online = 0,
    is_lock = 0,
    point = 0,
    email = args.email,
    id_type = 0,
  })
  log.fast_debug(
    'register username(%s) from %s success', args.username, args.ip)
  local r = account:save()
  print('r=======================', r)
  if not r or 0 == r then
    return e_code.unknown
  end
  return e_code.succ
end

return function(pack)
  local e = reg(pack)
  return {
    username = pack.username,
    result = e,
  }
end
