---
sidebar_position: 1
---

# Creating a 'Network'

A Network is basically an object to store the RemoteEvents and RemoteFunctions
So lets create one! It's pretty easy! trust me. just look

```lua
local RbxNetwork = require(path.to.rbxnetwork)
local Server = RbxNetwork.Server

local MyNetwork = Server.getNetwork(game.ReplicatedStorage, "MyNetwork") -- This will create a network in ReplicatedStorage
```

