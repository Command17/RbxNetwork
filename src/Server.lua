local Signal = require(script.Parent.Parent.Signal)
local Util = require(script.Parent.Util)

-- RemoteEventSignal Class --

--[=[
    @class RESignal

    RemoteSignal Class
]=]
local RESignal = {}
RESignal.__index = RESignal

--[=[
    Creates a new RESignal

    not usable

    @param RE RemoteEvent

    @return RESignal Object
]=]
function RESignal.new(RE: RemoteEvent)
    local self = setmetatable({
        _re = RE,
        _signal = Signal.new()
    }, RESignal)

    self._re.OnServerEvent:Connect(function(Player: Player, payload)
        payload = payload or {}
        payload = Util:UnpackTable(payload)

        self._signal:Fire(Player, table.unpack(payload))
    end)

    return self
end

--[=[
    Connects to the RESignal

    @param callback (...any) -> any

    @return RbxSignal Connection

    ```lua
    local Connection = RESignal:Connect(function(...: any)
        print("Got args from server!")
        print(...)
    end)
    ```
]=]
function RESignal:Connect(callback: Signal.callback)
    return self._signal:Connect(callback)
end

--[=[
    Connects to the RESignal in parallel

    @param callback (...any) -> any

    @return RbxSignal Connection

    ```lua
    local Connection = RESignal:ConnectParallel(function(...: any)
        print("Got args from server!")
        print(...)
    end)
    ```
]=]
function RESignal:ConnectParallel(callback: Signal.callback)
    return self._signal:ConnectParallel(callback)
end

--[=[
    Fire the RESignal

    @param ... any

    ```lua
    RESignal:Fire("Hello World!", 2022, {Date = "24/12/2022", Type = "DD/MM/YYYY"})
    ```
]=]
function RESignal:Fire(...: any)
    self._re:FireAllClients(Util:PackTable(table.pack(...)))
end

--[=[
    Fire the RESignal only for one player

    @param Player Player
    @param ... any

    ```lua
    RESignal:FireFor(plr, "Hello World!", 2022, {Date = "24/12/2022", Type = "DD/MM/YYYY"})
    ```
]=]
function RESignal:FireFor(Player: Player, ...: any)
    self._re:FireClient(Player, Util:PackTable(table.pack(...)))
end

--[=[
    Fire the RESignal for all players exept one

    @param Player Player
    @param ... any

    ```lua
    RESignal:FireExept(baum1000000, "Hello World!", 2022, {Date = "24/12/2022", Type = "DD/MM/YYYY"})
    ```
]=]
function RESignal:FireExept(Player: Player, ...: any)
    local players = Util:GetAllPlayersExecpt(Player)

    for _, player in ipairs(players) do
        self:FireFor(player, ...)
    end
end

--[=[
    Connects to the RESignal once

    @param callback (...any) -> any

    @return RbxSignal Connection

    ```lua
    RESignal:Once(function(...: any)
        print("Got args from server!")
        print(...)
    end)
    ```
]=]
function RESignal:Once(callback: Signal.callback)
    return self._signal:Once(callback)
end

--[=[
    Disconnects all listeners

    ```lua
    RESignal:DisconnectAll()
    ```
]=]
function RESignal:DisconnectAll()
    self._signal:DisconnectAll()
end

--[=[
    Waits until the RESignal is fired on the server

    @return any
]=]
function RESignal:Wait()
    return self._signal:Wait()
end

--[=[
    @within RESignal
    @function Destroy

    Disconnects all listeners

    ```lua
    RESignal:Destroy()
    ```
]=]
RESignal.Destroy = RESignal.DisconnectAll

-- RemoteFunctionSignal Class --

--[=[
    @class RFSignal

    RemoteFunction Signal Class
]=]
local RFSignal = {}
RFSignal.__index = RFSignal

--[=[
    Creates a new RFSignal

    not usable

    @param RF RemoteFunction

    @return RFSignal Object
]=]
function RFSignal.new(RF: RemoteFunction)
    local self = setmetatable({
        _rf = RF,
        _callback = nil,
    }, RFSignal)

    self._rf.OnServerInvoke = function(Player: Player, payload)
        payload = payload or {}
        payload = Util:UnpackTable(payload)

        if self._callback then
            return self._callback(Player, table.unpack(payload))
        end

        return nil
    end

    return self
end

--[=[
    Sets the current callback to a function or nil
    
    @param callback (...any) -> ...any | nil

    ```lua
    RFSignal:set(function(...:any)
        print("Yay args!")

        return "Yes"
    end)

    -- Disconnecting

    RFSignal:set(nil)
    ```
]=]
function RFSignal:set(callback: Signal.callback | nil) -- Sets the current callback to a function or nil
    assert(typeof(callback) == "function" or callback == nil, string.format("Invalid argument #1 (function or nil expected got %s)", typeof(callback)))
    
    self._callback = callback
end

--[=[
    Fires the RFSignal

    @yields

    @param Player Player
    @param ... any

    @return any

    ```lua
    local isTrue = RFSignal:Fire("Is roblox cool?")
    ```
]=]
function RFSignal:Fire(Player: Player, ...: any) -- Fires the RemoteFunction
    return self._rf:InvokeClient(Player, Util:PackTable(table.pack(...)))
end

--[=[
    Sets the callback to nil

    ```lua
    RFSignal:DisconnectAll()
    ```
]=]
function RFSignal:DisconnectAll() -- Sets the callback to nil
    self:set(nil)
end

--[=[
    @within RESignal
    @function Destroy

    Sets the callback to nil

    ```lua
    RFSignal:Destroy()
    ```
]=]
RFSignal.Destroy = RFSignal.DisconnectAll -- RFSignal:Destroy() -> RFSignal:DisconnectAll()

-- Server Class --

--[=[
    @class Server
    @server

    RbxNetworkServer by baum (@baum1000000)
]=]
local Server = {}
Server.__index = Server

--[=[
    Gets or creates a network

    @param Parent Instance
    @param Namespace string

    @return Network Object
]=]
function Server.getNetwork(Parent: Instance, Namespace: string) -- returns ClientNetwork
    local self = setmetatable({
        _namespace = Namespace,
        _space = {Main = nil, RE = nil, RF = nil},
    }, Server)

    self._space.Main, self._space.RE, self._space.RF = Util:GetSpaceWithName(Parent, Namespace)

    return self
end

--[=[
    Gets or creates a RemoteSignal

    @param Name string

    @return RESignal Object
]=]
function Server:GetRE(Name: string) -- returns RemoteEventSignal
    local RE = self._space.RE:FindFirstChild(Name) or Instance.new("RemoteEvent", self._space.RE)

    assert(RE:IsA("RemoteEvent"), string.format("%s is not a RemoteEvent!", Name))

    RE.Name = Name

    return RESignal.new(RE)
end

--[=[
    Gets or creates a RemoteFunction

    @param Name string

    @return RFSignal Object
]=]
function Server:GetRF(Name: string) -- returns RemoteFunctionSignal
    local RF = self._space.RF:FindFirstChild(Name) or Instance.new("RemoteFunction", self._space.RF)

    assert(RF:IsA("RemoteFunction"), string.format("%s is not a RemoteFunction!", Name))

    RF.Name = Name

    return RFSignal.new(RF)
end

--[=[
    Destroy function for any maid
]=]
function Server:Destroy() end -- Destroy

return Server