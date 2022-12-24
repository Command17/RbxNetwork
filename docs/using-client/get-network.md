---
sidebar_position: 1
---

# Getting a Network

Since we have a Network on the Server, we can now get it on the client

```lua
local RbxNetwork = require(path.to.rbxnetwork)
local Client = RbxNetwork.Client

local MyNetwork = Client.getNetwork(game.ReplicatedStorage, "MyNetwork") -- This will get the network in ReplicatedStorage
```