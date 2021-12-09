--[[
 - PLAIN FREAMEWORK ( https://github.com/viticm/plain-simple )
 - $Id logout.lua
 - @link https://github.com/viticm/plain-simple for the canonical source repository
 - @copyright Copyright (c) 2021 viticm( viticm.ti@gmail.com )
 - @license
 - @user viticm( viticm.ti@gmail.com )
 - @date 2021/12/08 20:43
 - @uses 登出
--]]

local data = require 'billing_data'

return function(pack)
  local info = data.onlines[pack.username]
  if info and info.mac and data.mac_count[info.mac] then
    local count = data.mac_count[info.mac] or 0
    if count - 1 >= 0 then
      data.mac_count[info.mac] = count - 1
    end
  end
  data.onlines[pack.username] = nil
  billing_tool_t.set_online(pack.username, 0)
  log.fast_debug('logout user(%s)', pack.username)
  return {
    username = pack.username,
    result = 1,
  }
end
