--[[
 - PLAIN FREAMEWORK ( https://github.com/viticm/plain-simple )
 - $Id enter_game.lua
 - @link https://github.com/viticm/plain-simple for the canonical source repository
 - @copyright Copyright (c) 2021 viticm( viticm.ti@gmail.com )
 - @license
 - @user viticm( viticm.ti@gmail.com )
 - @date 2021/12/08 20:21
 - @uses 进入游戏
--]]

return function(pack)
  local rolename = util_t.gbk_toutf8(pack.rolename)
  log.fast_debug('user(%s|%s) enter game', pack.username, rolename)
  billing_tool_t.check_online(pack.username, {rolename = rolename})
  return {
    username = pack.username,
    result = 1,
  }
end
