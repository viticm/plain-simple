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

;Because the client need lua script, then need set the script is open and set
;the type is 0, and set the script path.

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

;Because client need connect to server, and the connection name must empty before logic server routing
;set, so set usercount is 3 for self connect to gateway.
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

net.open=1;                                   ;If enable the net.
net.service=1;                                ;If default net is service.
net.port=2333;                                ;The default net listen port.
net.connmax=2048;                             ;The net max connections.

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

name0=server_service;   The server 1 name.
ip0=0.0.0.0;            Listen ip.
port0=2555;             Listen port.
connmax0=20;            Allow the client connections count.
encrypt0=ac;            The encrypt string not empty then connect this server need handshake.
scriptfunc0="";         The network handle script function.
```
