--[[
 - PLAIN FREAMEWORK ( https://github.com/viticm/plain-simple )
 - $Id login.lua
 - @link https://github.com/viticm/plain-simple for the canonical source repository
 - @copyright Copyright (c) 2021 viticm( viticm.ti@gmail.com )
 - @license
 - @user viticm( viticm.ti@gmail.com )
 - @date 2021/12/08 20:22
 - @uses 登陆
--]]
local d = require 'billing_data'
local db_data = require 'db_data'

local e_error = require 'enum.error'

local auto_reg = true           -- 是否自动注册
local client_max = 0            -- 客户端最大用户数量
local mac_client_max = 0        -- 电脑最大可以登陆用户数

-- 登陆
-- @param string name 账号名
-- @param string password 密码
-- @param string mac MAC地址
-- @param string ip IP地址
-- @return number
local function login(name, password, mac, ip)
  local account_model = db_data.account_model
  local account = account_model.get:where({name = name}):first()
  if not account then
    if not auto_reg then
      return e_error.account_notexists
    else
      return e_error.show_reg_window
    end
  end
  local is_online = tonumber(account.is_online)
  print('is_online=====================', is_online)
  if is_online == 1 then
    return e_error.user_online
  end
  if account.password ~= password then
    return e_error.password_error
  end
  if client_max > 0 then
    if util_t.count(d.onlines) >= client_max then
      return e_error.other
    end
  end
  if mac_client_max > 0 then
    if (d.mac_count[mac] or 0) >= mac_client_max then
      return e_error.other
    end
  end
  log.fast_debug('login user(%s) from ip(%s) success', name, ip)
  account.is_online = 1
  account:save()
  d.logins[name] = {ip = ip, mac = mac}
  return e_error.succ
end

return function(pack)
  local e = login(pack.username, pack.password, pack.macmd5, pack.ip)
  return {result = e, username = pack.username}
end
