--[[
 - PLAIN FREAMEWORK ( https://github.com/viticm/plain-simple )
 - $Id billing_pack_proto.lua
 - @link https://github.com/viticm/plain-simple for the canonical source repository
 - @copyright Copyright (c) 2021 viticm( viticm.ti@gmail.com )
 - @license
 - @user viticm( viticm.ti@gmail.com )
 - @date 2021/12/06 15:33
 - @uses The billing net packet defines.
--]]
module("billing_pack_proto_t", package.seeall)

local dumptable = require 'dumptable'
local data = require 'billing_data'
local handlers = data.handlers

function get_defines()
  local files = {}
  file.find_path(ROOTPATH .. '/billing_pack_protos/', '%.lua', files, true)
  local r = {_id_hash = {}}
  print('files================', dumptable(files))
  for _, filename in ipairs(files) do
    local func = loadfile(filename)
    if func then
      local name = file.strip_extension(file.strip_path(filename))
      local t = func()
      assert(t)
      r[name] = t
      if t.id then
        r._id_hash[t.id] = name
      end
      r._indexs = {}
      for index, key in ipairs(t) do
        if r._indexs[key] then
          assert(false,
            string.format('billing_pack_proto repeat(%s, %d)', key, index))
        end
        r._indexs[key] = index
      end
    end
  end
  print('r====================', dumptable(r))
  return r
end

function handler(npack, conn)
  print('billing_pack_proto_t.handler', npack, conn)
  local id = net.read_id(npack)
  local index = net.get_exstr(npack)
  print('index ============', index)
  local name = kConfig.billing_pack_defines._id_hash[id]
  if not handlers[name] then
    log.fast_warning(
      'billing_pack_proto_t cant found handler from: (%d|%s)', id, name or '?')
    return
  end
  local pack = billing_pack_t.new({
    id = id,
    pointer = npack,
    index = index,
  })
  assert(pack.data)
  print('billing_pack_proto_t.handler', util_t.dump(pack.data))
  local proto = kConfig.billing_pack_defines[name]
  local response = proto.response
  local r = handlers[name](pack.data)
  if response then
    r = r or {}
    local rpack = billing_pack_t.new({
      id = id,
      alloc = true,
      response = true,
      data = r,
      manager_name = 'listener',
      name_or_id = conn,
      listener_name = 'billing',
      index = index,
    })
    rpack:send()
  end
end

function reg_handler(name, func)
  handlers[name] = func
end

function load_handlers()
  local files = {}
  file.find_path(ROOTPATH .. '/handlers/', '%.lua', files, true)
  print('files================', dumptable(files))
  for _, filename in ipairs(files) do
    local func = loadfile(filename)
    if func then
      local name = file.strip_extension(file.strip_path(filename))
      local f = func()
      assert(f, string.format('%s is nil handler', name))
      handlers[name] = f
    end
  end
end
