--[[
 - PLAIN FREAMEWORK ( https://github.com/viticm/plain-simple )
 - $Id billing_tool.lua
 - @link https://github.com/viticm/plain-simple for the canonical source repository
 - @copyright Copyright (c) 2021 viticm( viticm.ti@gmail.com )
 - @license
 - @user viticm( viticm.ti@gmail.com )
 - @date 2021/12/09 13:41
 - @uses 工具函数
--]]
module('billing_tool_t', package.seeall)

local d = require 'billing_data'
local db_data = require 'db_data'

function check_online(name, args)
  local online_data = d.onlines[name] or {}
  local login_data = d.logins[name]
  -- Record mac count.
  if login_data then
    online_data.mac = login_data.mac
    online_data.ip = login_data.ip
    d.mac_count[login_data.mac] = (d.mac_count[login_data.mac] or 0) + 1
    d.logins[name] = nil
  end
  -- Update online data.
  for k, v in pairs(args) do
    online_data[k] = v
  end
  d.onlines[name] = online_data
end

function set_online(name, flag)
  local account_model = db_data.account_model
  local account = account_model.get:where({name = name}):first()
  if account then
    account.is_online = flag
    account:save()
  end
end
