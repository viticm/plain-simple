--[[
 - PLAIN FREAMEWORK ( https://github.com/viticm/plain-simple )
 - $Id db.lua
 - @link https://github.com/viticm/plain-simple for the canonical source repository
 - @copyright Copyright (c) 2021 viticm( viticm.ti@gmail.com )
 - @license
 - @user viticm( viticm.ti@gmail.com )
 - @date 2021/12/08 09:24
 - @uses The billing server database module.
--]]
module('db_t', package.seeall)

local data = require 'db_data'
local setting = require 'db_setting'
local model = require 'orm.model'
local Field = require 'orm.class.fields'
local Type = require 'orm.class.type'
local fields = require 'orm.tools.fields'

-- For mysql.
fields.TinyintField = Field:register({
  __type__ = "tinyint",
  validator = Type.is.int,
  to_type = Type.to.number
})

fields.SmallintField = Field:register({
  __type__ = "smallint",
  validator = Type.is.int,
  to_type = Type.to.number
})

function init()
  if not data.conn then
    data.conn = orm_connect(setting)
    assert(data.conn)

    -- Ping.
    local function ping(d)
      log.slow_warning('the connect ping======================')
      if not d.conn or not d.conn.connect then return end
      if not d.conn.connect:ping() then
        local r = d.conn:reconnect()
        log.slow_warning('ping sql connect error, reconnect: %d', r and 1 or 0)
      end
    end
    g_system_timer:register_fiveminute_timer(ping, data)

    -- 账号
    data.account_model = model({
      __tablename__ = 'account',
      __db__ = data.conn,
      id = fields.PrimaryField({unique = true}),
      name = fields.CharField({max_length = 32, unique = true}),
      password = fields.CharField({max_length = 32}),
      question = fields.CharField({max_length = 64, null = true}),
      answer = fields.CharField({max_length = 64, null = true}),
      email = fields.CharField({max_length = 64, null = true}),
      qq = fields.CharField({max_length = 16, null = true}),
      tel = fields.CharField({max_length = 16, null = true}),
      id_type = fields.TinyintField({max_length = 1, default = 1}),
      id_card = fields.CharField({max_length = 32, null = true}),
      point = fields.IntegerField({default = 0}),
      is_online = fields.BooleandField(),
      is_lock = fields.BooleandField(),
    })

    -- 充值
    data.pay_model = model({
      __tablename__ = 'pay',
      __db__ = data.conn,
      trade_no = fields.CharField({max_length = 20, primary_key = true}),
      channel = fields.CharField({max_length = 10, null = true}),
      server_id = fields.SmallintField({max_length = 2}),
      account_id = fields.IntegerField(),
      fee = fields.IntegerField(),
      status = fields.TinyintField({max_length = 1}),
      create_time = fields.DateTimeField(),
      pay_time = fields.DateTimeField({null = true}),
    })

    -- 服务器
    data.server_model = model({
      __tablename__ = 'server',
      __db__ = data.conn,
      id = fields.PrimaryField(),
      name = fields.CharField({max_length = 32}),
      host = fields.CharField({max_length = 60}),
    })
  end
end

function get_account(name)

end
