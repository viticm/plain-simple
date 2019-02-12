local redis = require("redis")

function mytest()
  log.fast("mytest function is done: %d", os.time())
end

mytest = {}
mytest.mytest = function()
  log.fast_debug("test function...");
end

g_testtimes_max = 1
g_testtimes = g_testtimes or 0
function testall()
  if g_testtimes_max <= g_testtimes then return end
  print("testall >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
  dcache_tests()
  g_testtimes = g_testtimes + 1
end

function testpb()
  local pb = require "pb"
  local protoc = require "protoc"

  assert(protoc:load [[
     message Phone {
        optional string name        = 1;
        optional int64  phonenumber = 2;
     }
     message Person {
        optional string name     = 1;
        optional int32  age      = 2;
        optional string address  = 3;
        repeated Phone  contacts = 4;
     } ]])

  local data = {
     name = "ilse",
     age  = 18,
     contacts = {
        { name = "alice", phonenumber = 12312341234 },
        { name = "bob",   phonenumber = 45645674567 }
     }
  }

  local bytes = assert(pb.encode("Person", data))
  print(pb.tohex(bytes))

  local data2 = assert(pb.decode("Person", bytes))
  print(require "serpent".block(data2))

end

function test_redis()
  local conn = redis.connect({host = "localhost"})
  print("test_redis", conn)
end

test_redis()

DB = {
  type = "mysql",
  name = "test",
  host = "127.0.0.1",
  port = 3306,
  username = "root",
  password = "mysql",
  new = true,
}

function test_orm()
  local Table = require("orm.model")
  local fields = require("orm.tools.fields")
  
  -- Create table.
  local User = Table({
    __tablename__ = "user",
    username = fields.CharField({max_length = 100, unique = true}),
    password = fields.CharField({max_length = 50, unique = true}),
    age = fields.IntegerField({max_length = 2, null = true}),
    job = fields.CharField({max_length = 50, null = true}),
    time_create = fields.DateTimeField({null = true})
  })
  --Table:create_table(User)
  
  -- New record.
  local user = User({
    username = "Bob Smith",
    password = "SuperSecretPassword",
    time_create = os.time()
  })
  user:save()

  print("User " .. user.username .. " has id " .. user.id)

  user.username = "John Smith"
  user:save()
  print("New user name is " .. user.username)

  -- Update.
  User.get:where({time_create__null = true})
          :update({time_create = os.time()})

end

test_orm()
