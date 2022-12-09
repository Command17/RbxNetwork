--[[
RBXNetworkServer by baum (@baum1000000)

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

    self._re.OnServerEvent:Connect(function(Player: Player, payload)
        payload = payload or {}

        self._signal:Fire(Player, table.unpack(payload))
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
    self._re:FireAllClients({...})
end

function reSignal:FireFor(Player: Player, ...: any) -- Fires the RemoteEvent for one player
    self._re:FireClient(Player, {...})
end

function reSignal:FireExept(Player: Player, ...: any) -- Fires the RemoteEvent for all players exept one
    local players = Util:GetAllPlayersExecpt(Player)

    for _, player in ipairs(players) do
        self:FireFor(player)
    end
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

    self._rf.OnServerInvoke = function(Player: Player, payload)
        payload = payload or {}

        if self._callback then
            return self._callback(Player, table.unpack(payload))
        end

        return nil
    end

    return self
end

function rfSignal:set(callback: Signal.callback | nil) -- Sets the current callback to a function or nil
    assert(typeof(callback) == "function" or callback == nil, string.format("Invalid argument #1 (function or nil expected got %s)", typeof(callback)))
    
    self._callback = callback
end

function rfSignal:Fire(Player: Player, ...: any) -- Fires the RemoteFunction
    return self._rf:InvokeClient(Player, {...})
end

function rfSignal:DisconnectAll() -- Sets the callback to nil
    self:set(nil)
end

rfSignal.Destroy = rfSignal.DisconnectAll -- RFSignal:Destroy() -> RFSignal:DisconnectAll()

-- Client Class --

local server = {}
server.__index = server

function server.getNetwork(Parent: Instance, Namespace: string) -- returns ClientNetwork
    local self = setmetatable({
        _namespace = Namespace,
        _space = {Main = nil, RE = nil, RF = nil},
    }, server)

    self._space.Main, self._space.RE, self._space.RF = Util:GetSpaceWithName(Parent, Namespace)

    return self
end

function server:GetRE(Name: string) -- returns RemoteEventSignal
    local RE = self._space.RE:FindFirstChild(Name) or Instance.new("RemoteEvent", self._space.RE)

    assert(RE:IsA("RemoteEvent"), string.format("%s is not a RemoteEvent!", Name))

    RE.Name = Name

    return reSignal.new(RE)
end

function server:GetRF(Name: string) -- returns RemoteFunctionSignal
    local RF = self._space.RF:FindFirstChild(Name) or Instance.new("RemoteFunction", self._space.RF)

    assert(RF:IsA("RemoteFunction"), string.format("%s is not a RemoteFunction!", Name))

    RF.Name = Name

    return rfSignal.new(RF)
end

function server:Destroy() end -- Destroy

return server