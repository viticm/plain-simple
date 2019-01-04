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

script.open=1;                                ;If enable the script.
script.type=0;                                ;0 is lua, other can use plugin register.
script.heartbeat=heartbeat;
script.rootpath=public/data/client/script

count=1;                       The plugin count.

0=pf_plugin_lua:global:0;      The lua script plugin(The last value is the script env type).
                               ;Load global symbols for all lua c so use the api.

;The client connection for net.
[client]

count=0;                The client count.
usercount=3;            The client connect by user count.

name0=client1;          The client 1 name.
ip0=127.0.0.1;          The connect ip.
port0=2333;             The connect port.
;encrypt0=ac;            The encrypt string not empty then connect the server will handshake.
startup0=0;             Start or heartbeat the application if connect.
scriptfunc0="";         The network handle script function.
```
