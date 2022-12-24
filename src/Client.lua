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

    self._re.OnClientEvent:Connect(function(payload)
        payload = payload or {}
        payload = Util:UnpackTable(payload)

        self._signal:Fire(table.unpack(payload))
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
    self._re:FireServer(Util:PackTable(table.pack(...)))
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

    @yields

    @return any
]=]
function RESignal:Wait() -- Waits until fired
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

    self._rf.OnClientInvoke = function(payload)
        payload = payload or {}
        payload = Util:UnpackTable(payload)

        if self._callback then
            return self._callback(table.unpack(payload))
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
function RFSignal:set(callback: Signal.callback | nil)
    assert(typeof(callback) == "function" or callback == nil, string.format("Invalid argument #1 (function or nil expected got %s)", typeof(callback)))
    
    self._callback = callback
end

--[=[
    Fires the RFSignal

    @yields

    @param ... any

    @return any

    ```lua
    local isTrue = RFSignal:Fire("Is roblox cool?")
    ```
]=]
function RFSignal:Fire(...: any)
    return self._rf:InvokeServer(Util:PackTable(table.pack(...)))
end

--[=[
    Sets the callback to nil

    ```lua
    RFSignal:DisconnectAll()
    ```
]=]
function RFSignal:DisconnectAll()
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
RFSignal.Destroy = RFSignal.DisconnectAll

-- Client Class --

--[=[
    @class Client
    @client

    RbxNetworkClient by baum (@baum1000000)
]=]
local Client = {}
Client.__index = Client

--[=[
    Gets a network created by the server

    @param Parent Instance
    @param Namespace string

    @yields

    @return Network Object
]=]
function Client.getNetwork(Parent: Instance, Namespace: string)
    local self = setmetatable({
        _namespace = Namespace,
        _space = {Main = nil, RE = nil, RF = nil},
    }, Client)

    self._space.Main, self._space.RE, self._space.RF = Util:GetSpaceWithName(Parent, Namespace)

    return self
end

--[=[
    Gets a RemoteSignal created by the server

    @param Name string

    @yields

    @return RESignal Object
]=]
function Client:GetRE(Name: string)
    local RE = self._space.RE:FindFirstChild(Name) or self._space.RE:WaitForChild(Name, 3)

    assert(RE ~= nil and RE:IsA("RemoteEvent"), string.format("%s is not a RemoteEvent!", Name))

    return RESignal.new(RE)
end

--[=[
    Gets a RemoteFunction created by the server

    @param Name string

    @yields

    @return RFSignal Object
]=]
function Client:GetRF(Name: string) -- returns RemoteFunctionSignal
    local RF = self._space.RF:FindFirstChild(Name) or self._space.RF:WaitForChild(Name, 3)

    assert(RF ~= nil and RF:IsA("RemoteFunction"), string.format("%s is not a RemoteFunction!", Name))

    return RFSignal.new(RF)
end

--[=[
    Destroy function for any maid
]=]
function Client:Destroy() end

return Client