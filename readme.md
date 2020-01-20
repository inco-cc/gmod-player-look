# gmod-player-look

This is a simple clientside script that mimics the way NPC's look around, but for players.

You can use this as is (automatically loaded by the client from `lua/autorun/client`), or you can include it in your own projects by putting this in a shared file (assuming `player_look.lua` is in the same directory):

```lua
  AddCSLuaFile "player_look.lua"
  include "player_look.lua
```

Note you have to add it to be downloaded by clients from the server with `AddCSLuaFile` if you're implementing it in your own project.

## Links

[Workshop Addon](https://steamcommunity.com/sharedfiles/filedetails/?id=1974573989)
