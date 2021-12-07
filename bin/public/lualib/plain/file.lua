--[[
 - PLAIN FRAMEWORK ( https://github.com/viticm/plain )
 - $Id file.lua
 - @link https://github.com/viticm/plain for the canonical source repository
 - @copyright Copyright (c) 2014- viticm( viticm.ti@gmail.com )
 - @license
 - @user viticm<viticm.ti@gmail.com>
 - @date 2018/12/22 11:02
 - @uses The plain framework file module.
--]]

SETTING_PATH = ROOTPATH.."/../setting"
PUBLIC_PATH = BASEPATH.."/public"
local lfs = require 'lfs'

-- 获得配置文件
function get_settingfile(filename)
  return SETTING_PATH.."/"..filename
end

-- 重写文件操作
local old_file = {}

old_file.opentab = file.opentab
function file.opentab(filename)
  local result = old_file.opentab(get_settingfile(filename))
  return result
end

old_file.openini = file.openini
function file.openini(filename)
  local result = old_file.openini(get_settingfile(filename))
  return result
end

-- 查找目录
-- @param string path 路径
-- @param string find 查找的内容
-- @param table r 查找结果
-- @param mixed dir 是否查找下级目录
function file.find_path(path, find, r, dir)
  for filename in lfs.dir(path) do
    if filename ~= '.' and filename ~= '..' then
      local filepath = path .. '' .. filename
      if string.find(filepath, find) ~= nil then
        table.insert(r, filepath)
      end

      local fileattr = lfs.attributes(filepath)
      -- assert(type(fileattr)=='table')
      if 'directory' == fileattr.mode and dir then
        file.find_path(filepath, find, r , dir)
        --[[
      else
        for name, value in pairs(fileattr) do
          print(name, value)
        end
        --]]
      end
    end
  end
end

-- 去除扩展名
-- @param string str 文件名
-- @return string
function file.strip_extension(str)
  local idx = str:match(".+()%.%w+$")
  if idx then
      return str:sub(1, idx - 1)
  else
      return str
  end
end

-- 去除目录
-- @param string 文件名
-- @return string
function file.strip_path(filename)
  return string.match(filename, ".+/([^/]*%.%w+)$")
end
