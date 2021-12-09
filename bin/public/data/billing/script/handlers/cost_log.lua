--[[
 - PLAIN FREAMEWORK ( https://github.com/viticm/plain-simple )
 - $Id cost_log.lua
 - @link https://github.com/viticm/plain-simple for the canonical source repository
 - @copyright Copyright (c) 2021 viticm( viticm.ti@gmail.com )
 - @license
 - @user viticm( viticm.ti@gmail.com )
 - @date 2021/12/08 20:21
 - @uses 元宝消耗记录
--]]
return function(pack)
  billing_tool_t.check_online(pack.username, {ip = pack.ip})
  local rolename = util_t.gbk_toutf8(pack.rolename)
  log.fast_debug('user(%s|%s|%d) cost yuanbao(%d) at: %s',
    pack.username, rolename, pack.rolelevel, pack.yuanbao, pack.ip)
  return {
    key = pack.key,
    result = 1,
  }
end
