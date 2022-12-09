local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local util = {}

local isServer = RunService:IsServer()

local function GetFolder(Parent: Instance, Name: string)
    if isServer then
        local f = Parent:FindFirstChild(Name) or Instance.new("Folder", Parent)

        f.Name = Name

        return f
    else
        local f = Parent:FindFirstChild(Name) or Parent:WaitForChild(Name, 3)

        if f then
            f.Name = Name

            return f
        end
    end
end

function util:GetSpaceWithName(Parent: Instance, Namespace: string) -- returns Main, RE, RF
    local Main = GetFolder(Parent, Namespace)

    assert(Main ~= nil, string.format("Network with namespace '%s' does not exist!", Namespace))

    local RE = GetFolder(Main, "RE")
    local RF = GetFolder(Main, "RF")

    return Main, RE, RF
end

function util:GetAllPlayersExecpt(Player: Player) -- returns table {player}
    local players = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if not player == Player then
            table.insert(players, player)
        end
    end

    return players
end

return util