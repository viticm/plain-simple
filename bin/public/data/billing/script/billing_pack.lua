--[[
 - PLAIN FREAMEWORK ( https://github.com/viticm/plain-simple )
 - $Id billing_pack.lua
 - @link https://github.com/viticm/plain-simple for the canonical source repository
 - @copyright Copyright (c) 2021 viticm( viticm.ti@gmail.com )
 - @license
 - @user viticm( viticm.ti@gmail.com )
 - @date 2021/12/06 13:46
 - @uses The billing net packet class.
--]]
module('billing_pack_t', package.seeall)

-- Local defines.
-------------------------------------------------------------------------------

-- Opear a string for local.
local function op_string(self, data)
  if not data then
    local len = net.read_uint8(self.pointer)
    return net.read_raw(self.pointer, len)
  else
    local len = string.len(data)
    net.write_uint8(self.pointer, len)
    return net.write_raw(self.pointer, data)
  end
end

local local_ops = {
  ['string'] = op_string,
}

local def_datas = {
  ['int8'] = 0,
  ['uint8'] = 0,
  ['int16'] = 0,
  ['uint16'] = 0,
  ['int32'] = 0,
  ['uint32'] = 0,
  ['int64'] = 0,
  ['uint64'] = 0,
  ['float'] = .0,
  ['double'] = .0,
  ['string'] = "",
  ['bytes'] = "",
  ['raw'] = "",
}

-- 读取某个类型的数据
-- @param string origin 协议名
-- @param string tp 数据类型
-- @return mixed
local function read_one(self, origin, tp)
  if not self.pointer or not tp then return end
  local r
  if '*' == string.sub(tp, 1, 1) then
    r = {}
    local count = net.read_uint16(self.pointer)
    local rtp = string.sub(tp, 2)
    for i = 1, count do
      table.insert(r, read_one(self, rtp))
    end
  elseif kConfig.billing_pack_defines[tp] and origin ~= tp then
    r = self:read_proto(self, tp)
  elseif local_ops[tp] then
    r = local_ops[tp](self)
  else
    local name = 'read_' .. tp
    local func = net[name]
    assert(func)
    r = func(self.pointer)
  end
  return r
end

-- 写入某个类型的数据
-- @param string origin 协议名
-- @param string tp 数据类型
-- @param mixed data 数据
-- @return mixed
local function write_one(self, origin, tp, data)
  if not self.pointer or not tp then return end
  local r
  if '*' == string.sub(tp, 1, 1) then
    r = {}
    data = data or {}
    net.write_uint16(self.pointer, #data)
    local rtp = string.sub(tp, 2)
    for _, value in ipairs(data) do
      write_one(self, "", rtp, value)
    end
  elseif kConfig.billing_pack_defines[tp] and
    not kConfig.billing_pack_defines[tp].request then
    self:write_proto(self, tp, origin)
  elseif local_ops[tp] then
    data = data or def_datas[tp]
    local_ops[tp](self, data)
  else
    data = data or def_datas[tp]
    local name = 'write_' .. tp
    local func = net[name]
    assert(func)
    func(self.pointer, data)
  end
  return r
end

-- API.
-------------------------------------------------------------------------------

function new(conf)
  local t = {
    pointer = conf.pointer,
    id = conf.id,
    manager_name = conf.manager_name,
    name_or_id = conf.name_or_id,
    data = conf.data or {}, -- The packet table data.
    response = conf.response, -- If the response packet.
  }
  local obj = setmetatable(t, { __index = billing_pack_t })
  if not obj.pointer then
    if conf.alloc then
      obj.pointer = net.packet_alloc(conf.id)
      assert(obj.pointer)
    end
  else
    obj:parse()
  end
  return obj
end

function read(self, tp)
  local name = 'read_' .. tp
  local func = net[name]
  assert(func)
  return func(self.pointer)
end

function write(self, tp, value)
  local name = 'write_' .. tp
  local func = net[name]
  assert(func)
  return func(self.pointer, value)
end

-- Parse packet as a table(request).
function parse(self)
  local pd = kConfig.billing_pack_defines
  local name = self.id and pd._id_hash[self.id]
  if name then
    log.error('billing_pack_t.parse cant parse(%d) not found', self.id or -1)
    return
  end
  local proto = pd[name].request
  assert(proto)
  self.data = self:read_proto(name, proto)
end

-- 解析协议
-- @param string name 协议名
-- @param table struct 协议结构表
-- @return mixed
function read_proto(self, name, struct)
  local r = {}
  for _, one in ipairs(struct) do
    local key, tp = table.unpack(one)
    r[key] = read_one(self, name, tp)
  end
  return r
end

-- 写入协议数据
-- @param string name 协议名
-- @param mixed parent 父名
-- @return mixed
function write_proto(self, name, parent)
  local struct = kConfig.billing_pack_defines[name]
  if not parent then
    struct = self.response and struct.response or struct.request
  end
  assert(struct)
  for _, one in ipairs(struct) do
    local name1, tp = table.unpack(one)
    local key = (parent or "") .. name1
    local data = self.data[key]
    write_one(self, key, tp, data)
  end
end

-- 发送数据
function send(self)
  local name = kConfig.billing_pack_defines._id_hash[self.id]
  assert(name)
  self:write_proto(self, name)
  return net.send(self.manager_name, self.name_or_id, self.pointer)
end
