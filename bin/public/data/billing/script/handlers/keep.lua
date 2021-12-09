--[[
 - PLAIN FREAMEWORK ( https://github.com/viticm/plain-simple )
 - $Id keep.lua
 - @link https://github.com/viticm/plain-simple for the canonical source repository
 - @copyright Copyright (c) 2021 viticm( viticm.ti@gmail.com )
 - @license
 - @user viticm( viticm.ti@gmail.com )
 - @date 2021/12/08 20:22
 - @uses 保持连接
--]]
return function(pack)
  log.fast_debug('keep user(%s) level(%d)', pack.username, pack.level)
  billing_tool_t.check_online(pack.username)
  return {
    username = pack.username,
    result = 1,
  }
end
