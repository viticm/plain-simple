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

| `client`=>`gateway`<=logic | `client`<-`gateway`->`logic` |
