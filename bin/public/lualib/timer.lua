--[[
 - PLAIN FREAMEWORK ( https://github.com/viticm/plain-simple )
 - $Id timer.lua
 - @link https://github.com/viticm/plain-simple for the canonical source repository
 - @copyright Copyright (c) 2021 viticm( viticm.ti@gmail.com )
 - @license
 - @user viticm( viticm.ti@gmail.com )
 - @date 2021/12/06 15:20
 - @uses The timer class.
--]]
module("timer_t", package.seeall)

local table_insert = table.insert

-- 新建
function new()
  local timer = {}
  setmetatable(timer, {__index = timer_t})
  timer:init()
  return timer
end

-- 初始化
function init(self)
  self.onesecond_eventlist_ = {} -- 一秒钟定时器事件列表
  self.oneminute_eventlist_ = {} -- 一分钟定时器事件列表
  self.fiveminute_eventlist_ = {} -- 五分钟定时器事件列表
  self.check_t = {sec = os.time(), minute = os.time(), fiveminute = os.time()}
end

-- 注册一秒钟定时器事件
function register_onesecond_timer(self, func, param)
  if not func then return end
  local event = {func, param}
  table_insert(self.onesecond_eventlist_, event)
end

-- 注册一分钟定时器事件
function register_onminute_timer(self, func, param)
  if not func then return end
  local event = {func, param}
  table_insert(self.oneminute_eventlist_, event)
end

-- 注册五分钟定时器事件
function register_fiveminute_timer(self, func, param)
  if not func then return end
  local event = {func, param}
  table_insert(self.fiveminute_eventlist_, event)
end

-- 执行一秒钟定时器事件
function on_onesecond_timer(self)
  for _, event in ipairs(self.onesecond_eventlist_) do
    local func = event[1]
    local param = event[2]
    func(param)
  end
end

-- 执行一分钟定时器事件
function on_oneminute_timer(self)
  for _, event in ipairs(self.oneminute_eventlist_) do
    local func = event[1]
    local param = event[2]
    func(param)
  end
end

-- 执行五分钟定时器事件
function on_fiveminute_timer(self)
  for _, event in ipairs(self.fiveminute_eventlist_) do
    local func = event[1]
    local param = event[2]
    func(param)
  end
end

-- 定时器执行（放到心跳中）
function run(self)
  local now = os.time()
  local check_t = self.check_t
  if now - check_t.sec >= 1 then
    check_t.sec = now
    self:on_onesecond_timer()
  end
  if now - check_t.minute >= 60 then
    check_t.minute = now
    self:on_oneminute_timer()
  end
  if now - check_t.fiveminute >= 300 then
    check_t.fiveminute = now
    self:on_fiveminute_timer()
  end
end
