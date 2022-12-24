---
sidebar_position: 3
---

# Creating and using RFSignals

RFSignal stands for RemoteFunction Signal.

Yes. We need to create them.

```lua
local ClientInfoV2 = MyNetwork:GetRF("GetClientInfo")
```

But this time we will ASK the client for ze info

```lua
local Info = ClientInfoV2:Fire(SomePlayer)

print(Info)
```

Now lets go to the client