---
sidebar_position: 2
---

# Creating and using a RESignal

RESignal stands for RemoteEvent Signals.

First of all, we need to create one. Lets do it

```lua
local ClientInfo = MyNetwork:GetRE("ClientInfo")
```

Becouse we have a RESignal now... We connect it!

```lua
ClientInfo:Connect(function(Player, info)
    print("Got info from: " .. Player.Name)
    print(info)
end)
```

This will print the info that we will send.. but we will do that later

Now we will do RFSignals