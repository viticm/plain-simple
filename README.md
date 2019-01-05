# Plain framework simple project #

## A project with plain framework, tech you quick start. ##

It's a light game project implement with lua script, now it has the login and enter.
If you want other code language use plain framework, just read few minutes tutorial.

**This project have three application:**

| Application             | Description                                                     |
| ----------------------- | --------------------------------------------------------------- |
| `gateway`               | The gateway server like watchdog between other server and client|
| `logic`                 | The logic server, handle player action in game world            |
| `client`                | The game client                                                 |

**This project connection model:**

`=>`means connect to, `<-`means be connected.

| `client` => `gateway` <= `logic` | `client` <- `gateway` -> `logic` |

## The applications environment config. ##

### client ###

The client need use lua script and a connection to gateway server.

```ini
;The env config will set in framework globals, just like: section.key=value
;cn: 环境变量的配置会设置到框架的全局变量中，格式为：段名.字段名=值

;The application settings.
[app]
name=client

;The default setings.
[default]

engine.frame=100;

-------------------------------------------------------------------------------
* Because the client need lua script, then need set the script is open and set
the type is 0, and set the script path.
-------------------------------------------------------------------------------

script.open=1;                                ;If enable the script.
script.type=0;                                ;0 is lua, other can use plugin register.
script.heartbeat=heartbeat;
script.rootpath=public/data/client/script

;The plugins.
;The plugin parameters mean-> plugin name : local | global(default local) : ... (
;Other parameters for plugin with pf_plugin_open)
[plugins]

count=1;                       The plugin count.

0=pf_plugin_lua:global:0;      The lua script plugin(The last value is the script env type).
                               ;Load global symbols for all lua c so use the api.

;The client connection for net.
[client]

-------------------------------------------------------------------------------
* Because client need connect to server, and the connection name must empty 
before logic server routing set, so set usercount is 3 for self connect to 
gateway.
-------------------------------------------------------------------------------

usercount=3;            The client connect by user count.
```

### gateway ###

The gateway server use lua script and service for logic server and client.

```ini
;The env config will set in framework globals, just like: section.key=value
;cn: 环境变量的配置会设置到框架的全局变量中，格式为：段名.字段名=值

;The application settings.
[app]
name=gateway

;The default setings.
[default]

engine.frame=100;

-------------------------------------------------------------------------------
* The default net is service for client, set the port is 2333 and max 2048.
-------------------------------------------------------------------------------

net.open=1;                                   ;If enable the net.
net.service=1;                                ;If default net is service.
net.port=2333;                                ;The default net listen port.
net.connmax=2048;                             ;The net max connections.

-------------------------------------------------------------------------------
* Because the gateway need lua script, then need set the script is open and set
the type is 0, and set the script path.
-------------------------------------------------------------------------------

script.open=1;                                ;If enable the script.
script.type=0;                                ;0 is lua, other can use plugin register.
;script.heartbeat=heartbeat;
script.rootpath=public/data/gateway/script


;The plugins.
;The plugin parameters mean-> plugin name : local | global(default local) : ... (
;Other parameters for plugin with pf_plugin_open)
[plugins]

count=1;                       The plugin count.

0=pf_plugin_lua:global:0;      The lua script plugin(The last value is the script env type).
                               ;Load global symbols for all lua c so use the api.
;The server service for net.
[server]

count=1;                The server count.

-------------------------------------------------------------------------------
* The extra service for logic server, set the name is server_service and 20 max,
the listen port is 2555.
-------------------------------------------------------------------------------

name0=server_service;   The server 1 name.
ip0=0.0.0.0;            Listen ip.
port0=2555;             Listen port.
connmax0=20;            Allow the client connections count.
encrypt0=ac;            The encrypt string not empty then connect this server need handshake.
scriptfunc0="";         The network handle script function.
```

### logic ###

The logic server use lua script and service for player game world.

```ini
;The env config will set in framework globals, just like: section.key=value
;cn: 环境变量的配置会设置到框架的全局变量中，格式为：段名.字段名=值

;The application settings.
[app]
name=logic

;The default setings.
[default]

engine.frame=100;

-------------------------------------------------------------------------------
* Because the logic need lua script, then need set the script is open and set
the type is 0, and set the script path.
-------------------------------------------------------------------------------

script.open=1;                                ;If enable the script.
script.type=0;                                ;0 is lua, other can use plugin register.
;script.heartbeat=heartbeat;
script.rootpath=public/data/logic/script


;The plugins.
;The plugin parameters mean-> plugin name : local | global(default local) : ... (
;Other parameters for plugin with pf_plugin_open)
[plugins]

count=1;                       The plugin count.

0=pf_plugin_lua:global:0;      The lua script plugin(The last value is the script env type).
                               ;Load global symbols for all lua c so use the api.

;The client connection for net.
[client]

-------------------------------------------------------------------------------
* The one connection setting is to connect gateway, the connection name is 
logic1 to gateway and self, the connect port is 2555 and ip is 127.0.0.1 .
-------------------------------------------------------------------------------

count=1;                The client count.
usercount=0;            The client connect by user count.

name0=logic1;           The client 1 name/this name will use in gateway.
ip0=127.0.0.1;          The connect ip.
port0=2555;             The connect port.
encrypt0=ac;            The encrypt string not empty then connect the server will handshake.
startup0=1;             Start or heartbeat the application if connect.
scriptfunc0="";         The network handle script function.
```

## How to implement ##

**The process:**

- Client try login to gateway server, after login try enter the logic.
The message will routing directly to logic when enter logic success.

- Gateway need check client login request, check login status when client enter logic.

- Logic need check and load user data when gateway request enter, request gateway routing when enter success.
The message will send client after routing success(need use routing interface).

### Implement codes ###

In this project network use google protocolbuf with lua script, some lua interface
implement with plugin and other in lua script.

**Protocol define:**

```lua
-- The script packet id must begin 20001.
return {

  test = {id = 0x4e21, proto = "test.pb_test"},

  c2w_login = {id = 0x4e30, proto = "login.c2w_login"}, -- client request login gateway
  c2w_enter = {id = 0x4e31, proto = "login.c2w_enter"}, -- client request enter logic world
  w2l_enter = {id = 0x4e32, proto = "login.w2l_enter"}, -- gateway request enter logic world
  l2w_enter = {id = 0x4e33, proto = "login.l2w_enter"}, -- logic response gateway enter result
  l2c_enter = {id = 0x4e34, proto = "login.l2c_enter"}, -- logic response client enter result
  c2l_test = {id = 0x4e35, proto = "login.c2l_test"},
  c2l_test1 = {id = 0x4e36, proto = "login.c2l_test1"},
  l2c_test2 = {id = 0x4e37, proto = "login.l2c_test2"},

}
```

**Client implement:**

Client first create a connection to gateway, then request login and enter.

File: `bin/public/data/client/script/main.lua`

```lua
  connid = net.connect("", "127.0.0.1", 2333, true)
  local msg = {
    a = 111,
    b = "test",
    c = {1, 3, 5},
  }
  local r1 = net.pb_send("connector", connid, op.test, msg) -- This is a test msg.
  local r2 = net.pb_send("connector", connid, op.c2w_login, {username = "test"})
  local r3 = net.pb_send("connector", connid, op.c2w_enter, {username = "test", server = "logic1"})
```

**Gateway implement:**

Gateway need register the packet handler for client login and enter.

File: `bin/public/data/gateway/script/handlers/login.lua`

```lua
local op = require "pb_define"
local dumptable = require("dumptable")

local loginlist = loginlist or {}

-- User login.
net.reg_pbhandler(op.c2w_login, function(data, conn, original)
  print(dumptable(data))
  loginlist[data.username] = 1
end)

-- User enter.
net.reg_pbhandler(op.c2w_enter, function(data, conn, original) 
  print(dumptable(data))
  local username = data.username
  local server = data.server
  local connid = conn
  if not loginlist[username] then
    assert(false, "c2w_enter user not login: "..username)
    return
  end
  if type(connid) ~= "number" then
    assert(false, "c2w_enter connection error")
    return
  end
  local msg = {username = username, connid = connid}
  print("w2l_enter...........")
  print(dumptable(msg))
  local r = net.pb_send("listener", server, op.w2l_enter, msg, "server_service")
  if not r then
    assert(false, "c2w_enter can't reach the server: "..server)
  end
end)

-- Enter result.
net.reg_pbhandler(op.l2w_enter, function(data, conn, original) 
  print(dumptable(data))
  if data.result ~= 0 then
    net.disconnect(data.servicename, data.connid)
  end
end)
```
**Logic implement:**

Logic need register the gateway enter and the routing response handlers.

File: `bin/public/data/logic/script/handlers/login.lua`

```lua
local op = require "pb_define"
local dumptable = require("dumptable")

local userlist = userlist or {}

-- The routing reached.
net.reg_routing("logic1", function(aim_name, service) 
  print("routing reached", aim_name, service)
  local info = userlist[aim_name]
  if info then
    info.routing = {aim_name = aim_name, service = service}
    if 1 == info.login then
      local msg = {rolelist = {"aaa", "bbb", "ccc"}}
      print(net.pb_send("connector", "logic1", op.l2c_enter, msg, nil, info.routing))
    elseif 2 == info.login then -- Relogin.

    end
  end
end)

-- Enter.
net.reg_pbhandler(op.w2l_enter, function(data, conn, original) 
  print(dumptable(data))
  local username = data.username
  local connid = data.connid
  local servicename = data.servicename
  math.randomseed(os.time())
  local result = 0 -- math.random(0, 1)
  local rmsg = {result = result, connid = connid, servicename = servicename}
  net.pb_send("connector", conn, op.l2w_enter, rmsg)
  if 0 == result then
    userlist[username] = {login = 1} -- First login.
    net.routing_request("connector", conn, nil, servicename, username, connid)
  end
end)

net.reg_pbhandler(op.c2l_test, function(data, conn, original) 
  print(dumptable(data))
  print("info: ", conn, original)
end)

net.reg_pbhandler(op.c2l_test1, function(data, conn, original) 
  print(dumptable(data))
  print("info1: ", conn, original)
  local info = original and userlist[original]
  if info and info.routing then
    local msg = {a = 2333, b = 3.1415926, c = "l2c_test1"}
    print(net.pb_send("connector", "logic1", op.l2c_test2, msg, nil, info.routing))
  end
end)
```
