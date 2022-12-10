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
        if player ~= Player then
            table.insert(players, player)
        end
    end

    return players
end

function util:PackValue(value: any) -- packs a value
    if typeof(value) == "boolean" then
        return value and "1/1" or "b/0"
    elseif typeof(value) == "string" then
        local result = ""

        for i, letter in ipairs(string.split(value, "")) do
            local byte = string.byte(letter)

            if i ~= string.len(value) then
                result ..= byte .. "."
            else
                result ..= byte
            end
        end

        return "2/" .. result
    else
        return value
    end
end

function util:UnpackValue(value: any) -- unpacks a value
    if typeof(value) == "string" then
        if string.sub(value, 1, 2) == "1/" then
            local v = string.sub(3, 3)

            return if v == "1" then true else false
        elseif string.sub(value, 1, 2) == "2/" then
            local v = string.sub(value, 3, string.len(value))

            local result = ""

            for _, byte in pairs(string.split(v, ".")) do
                print(byte)

                local char = string.char(tonumber(byte))

                
                result ..= char
            end

            return result
        else
            return value
        end
    else
        return value
    end
end

function util:PackTable(t: {any})
    local result = {}

    for i, v in pairs(t) do
        if typeof(v) == "table" then
            result[i] = self:PackTable(v)
        else
            local packedValue = self:PackValue(v)

            result[i] = packedValue
        end
    end

    return result
end

function util:UnpackTable(t: {any})
    local result = {}

    for i, v in pairs(t) do
        if typeof(v) == "table" then
            result[i] = self:UnpackTable(v)
        else
            local unpackedValue = self:UnpackValue(v)

            result[i] = unpackedValue
        end
    end

    return result
end

return util