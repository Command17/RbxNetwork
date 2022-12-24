---
sidebar_position: 3
---

# Using RFSignals

Sans will now be given if the Server asks us

```lua
local CoolRF = MyNetwork:GetRF("GetClientInfo")

CoolRF:set(function() -- RF:set() will set the callback to a func or nil
    return {sans = 0.5}
end)
```

And we're done!