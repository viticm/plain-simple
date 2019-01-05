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
- Gateway need check client login request, check login status when client enter logic.
- Logic need check and load user data when gateway request enter, request gateway routing when enter success.
The message will send client after routing success(need use routing interface).
