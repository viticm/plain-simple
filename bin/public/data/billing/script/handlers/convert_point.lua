--[[
 - PLAIN FREAMEWORK ( https://github.com/viticm/plain-simple )
 - $Id convert_point.lua
 - @link https://github.com/viticm/plain-simple for the canonical source repository
 - @copyright Copyright (c) 2021 viticm( viticm.ti@gmail.com )
 - @license
 - @user viticm( viticm.ti@gmail.com )
 - @date 2021/12/08 20:20
 - @uses 兑换点数
--]]
local db_data = require 'db_data'
local once_max = 0xffff

-- 转换点数
-- @param table args
-- @return [mixed, mixed]
local function convert_point(args)
  if not args.username then
    return
  end
  local account_model = db_data.account_model
  local account = account_model.get:where({name = args.username}):first()
  if not account then return end
  local point = args.need_point
  if point > once_max then
    point = once_max
  end
  if account.point < point then
    point = account.point
  end
  if point <= 0 then return end
  local left_point = account.point - point
  account.point = left_point
  if not account:save() then
    return false, {left_point = account.point}
  end
  return true, {
    left_point = account.point,
    real_point = point
  }
end

return function(pack)
  local r, d = convert_point(pack)
  d = d or {}
  return {
    result = r and 0 or 1,
    left_point = d.left_point or 0,
    username = pack.username,
    order_id = pack.order_id,
    goods_typenum = pack.goods_typenum,
    goods_type = pack.goods_type,
    goods_num = pack.goods_num,
  }
end
