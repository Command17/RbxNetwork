--[[
RbxNetworkClient by baum (@baum1000000)

A simple easy-to-use networking library
]]--

local Signal = require(script.Parent.Parent.Signal)
local Util = require(script.Parent.Util)

-- RemoteEventSignal Class --

local reSignal = {}
reSignal.__index = reSignal

function reSignal.new(RE: RemoteEvent)
    local self = setmetatable({
        _re = RE,
        _signal = Signal.new()
    }, reSignal)

    self._re.OnClientEvent:Connect(function(payload)
        payload = payload or {}
        payload = Util:UnpackTable(payload)

        self._signal:Fire(table.unpack(payload))
    end)

    return self
end

function reSignal:Connect(callback: Signal.callback) -- Connects a function
    return self._signal:Connect(callback)
end

function reSignal:ConnectParallel(callback: Signal.callback) -- Connects a function in Parallel
    return self._signal:ConnectParallel(callback)
end

function reSignal:Fire(...: any) -- Fires the RemoteEvent
    self._re:FireServer(Util:PackTable(table.pack(...)))
end

function reSignal:Once(callback: Signal.callback) -- Disconnects after one fire
    return self._signal:Once(callback)
end

function reSignal:DisconnectAll() -- Disconnects all Listeners
    self._signal:DisconnectAll()
end

function reSignal:Wait() -- Waits until fired
    return self._signal:Wait()
end

reSignal.Destroy = reSignal.DisconnectAll -- RESignal:Destroy() -> RESignal:DisconnectAll()

-- RemoteFunctionSignal Class --

local rfSignal = {}
rfSignal.__index = rfSignal

function rfSignal.new(RF: RemoteFunction)
    local self = setmetatable({
        _rf = RF,
        _callback = nil,
    }, rfSignal)

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

function rfSignal:set(callback: Signal.callback | nil) -- Sets the current callback to a function or nil
    assert(typeof(callback) == "function" or callback == nil, string.format("Invalid argument #1 (function or nil expected got %s)", typeof(callback)))
    
    self._callback = callback
end

function rfSignal:Fire(...: any) -- Fires the RemoteFunction
    return self._rf:InvokeServer(Util:PackTable(table.pack(...)))
end

function rfSignal:DisconnectAll() -- Sets the callback to nil
    self:set(nil)
end

rfSignal.Destroy = rfSignal.DisconnectAll -- RFSignal:Destroy() -> RFSignal:DisconnectAll()

-- Client Class --

local client = {}
client.__index = client

function client.getNetwork(Parent: Instance, Namespace: string) -- returns ClientNetwork
    local self = setmetatable({
        _namespace = Namespace,
        _space = {Main = nil, RE = nil, RF = nil},
    }, client)

    self._space.Main, self._space.RE, self._space.RF = Util:GetSpaceWithName(Parent, Namespace)

    return self
end

function client:GetRE(Name: string) -- returns RemoteEventSignal
    local RE = self._space.RE:FindFirstChild(Name) or self._space.RE:WaitForChild(Name, 3)

    assert(RE ~= nil and RE:IsA("RemoteEvent"), string.format("%s is not a RemoteEvent!", Name))

    return reSignal.new(RE)
end

function client:GetRF(Name: string) -- returns RemoteFunctionSignal
    local RF = self._space.RF:FindFirstChild(Name) or self._space.RF:WaitForChild(Name, 3)

    assert(RF ~= nil and RF:IsA("RemoteFunction"), string.format("%s is not a RemoteFunction!", Name))

    return rfSignal.new(RF)
end

function client:Destroy() end -- Destroy

return client