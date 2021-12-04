local redis = require("redis")
local dumptable = require("dumptable")

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

local db_setting = {
  type = "mysql",
  name = "test",
  host = "127.0.0.1",
  port = 3306,
  username = "leafly",
  password = "mysql",
  new = true,
  
}

ORM_BACKTRACE_ON = true

function test_orm()
  local Table = require("orm.model")
  local fields = require("orm.tools.fields")

  local db = orm_connect(db_setting)
  if not db then return end
  
  -- Create table.
  local User = Table({
    __tablename__ = "user",
    __db__ = db,
    username = fields.CharField({max_length = 100, unique = true}),
    password = fields.CharField({max_length = 50, unique = true}),
    age = fields.IntegerField({max_length = 2, null = true}),
    job = fields.CharField({max_length = 50, null = true}),
    time_create = fields.DateTimeField({null = true})
  })
  
  -- New record.
  --[[
  local user = User({
    username = "Bob Smith",
    password = "SuperSecretPassword",
    time_create = os.time()
  })
  user:save()
  local user = User.get:first()

  print("User " .. user.username .. " has id " .. user.id)

  user.username = "John Smith"
  user:save()
  print("New user name is " .. user.username)

  -- Remove data
  user:delete()
  --]]

  -- Insert test data.
  user = User({username = "First user", password = "secret1", age = 22})
  user:save()

  user = User({username = "Second user", password = "secret_test", job = "Lua developer"})
  user:save()

  user = User({username = "Another user", password = "old_test", age = 44})
  user:save()

  user = User({username = "New user", password = "some_passwd", age = 23, job = "Manager"})
  user:save()

  user = User({username = "Old user", password = "secret_passwd", age = 44})
  user:save()

  local first_user = User.get:first()
  print("First user name is: " .. first_user.username)

  local users = User.get:all()
  print("We get " .. users:count() .. " users")

  -- Limit and Offset
  local users = User.get:limit(2):all()
  print("We get " .. users:count() .. " users")
  print("Second user name is: " .. users[2].username)

  users = User.get:limit(2):offset(2):all()
  print("Second user name is: " .. users[2].username)

  -- Order result
  users = User.get:order_by({desc('age')}):all()
  print("First user id: " .. users[1].id)

  users = User.get:order_by({desc('age'), asc('username')}):all()

  -- Group result
  users = User.get:group_by({'age'}):all()
  print('Find ' .. users:count() ..' users')

  -- Where and Having
  user = User.get:where({username = "First user"}):first()
  print("User id is: " .. user.id)

  users = User.get:group_by({'id'}):having({age = 44}):all()
  print("We get " .. users:count() .. " users with age 44")

  -- Update.
  User.get:where({time_create__null = true})
          :update({time_create = os.time()})

  -- Super SELECT
  user = User.get:where({age__lt = 30,
                         age__lte = 30,
                         age__gt = 10,
                         age__gte = 10
                       })
                       :order_by({asc('id')})
                       :group_by({'age', 'password'})
                       :having({id__in = {1, 3, 5},
                                id__notin = {2, 4, 6},
                                username__null = false
                              })
                        :limit(2)
                        :offset(1)
                        :all()

  -- JOIN TABLES
  local News = Table({
    __tablename__ = "news",
    __db__ = db,
    title = fields.CharField({max_length = 100, unique = false, null = false}),
    text = fields.TextField({null = true}),
    create_user_id = fields.ForeignKey({to = User})
  })
  user = User.get:first()
  local news = News({title = "Some news", create_user_id = user.id})
  news:save()

  news = News({title = "Other title", create_user_id = user.id})
  news:save()

  print("News insert ok!!!")
  local news = News.get:join(User):all()
  print("First news user id is: " .. news[1].user.id)

  local user = User.get:join(News):first()
  print("User " .. user.id .. " has " .. user.news_all:count() .. " news")

  for _, user_news in pairs(user.news_all) do
    print(user_news.title)
  end

end

test_orm()
