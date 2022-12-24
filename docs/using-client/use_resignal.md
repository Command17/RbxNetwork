---
sidebar_position: 2
---

# Using RESignals

NOW we can give the server our info. But first we need to get it. I will be combining this part

```lua
local ThatCoolRE = MyNetwork:GetRE("ClientInfo")

ThatCoolRE:Fire({sans = 0.5}) -- Our Info we send is in that table :D
```

Neow we can do RFSignals!