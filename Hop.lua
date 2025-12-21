local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlaceId = game.PlaceId

local Visited = {}
local Cursor = nil

local function GetServers()
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?limit=100"
    if Cursor then
        url ..= "&cursor=" .. Cursor
    end

    local data = HttpService:JSONDecode(game:HttpGet(url))
    Cursor = data.nextPageCursor
    return data.data
end

local function Hop()
    for _, server in ipairs(GetServers()) do
        if server.playing < server.maxPlayers then
            local id = server.id
            if not Visited[id] then
                Visited[id] = true
                TeleportService:TeleportToPlaceInstance(PlaceId, id, Player)
                return
            end
        end
    end
end

pcall(Hop)
