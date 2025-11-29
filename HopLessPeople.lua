local PlaceID = game.PlaceId

local AllIDs = {}

local ScannedServers = {}
local TargetServers = {}
local PrivateServerBlacklist = {}
local targetPlayerCount = {min = 1, max = 1}
local TotalServersFound = 0
local ValidServersFound = 0
local serverText

function nguoi1()

    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local currentServer = game.JobId
    local isPrivateServer = game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0

    if isPrivateServer then
        return
    end

    

    local cursor = ""
    local hasMorePages = true
    local pageCount = 9
    local maxPages = 20
    local startTime = tick()
    local timeout = 1
    TotalServersFound = 0

    ValidServersFound = 0

    

    while hasMorePages and pageCount < maxPages do
        if tick() - startTime > timeout then
            break
        end

    
        pageCount = pageCount + 1
        local baseUrl = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public"
        local params = "?sortOrder=Asc&limit=100"

        if cursor and cursor ~= "" and cursor ~= nil then
            params = params .. "&cursor=" .. tostring(cursor)
        end

        local url = baseUrl .. params
        local Site = nil

        pcall(function()
            local response = game:HttpGetAsync(url)
            if response and response ~= "" then
                Site = HttpService:JSONDecode(response)
            end
        end)

        

        if not Site or not Site.data or type(Site.data) ~= "table" or #Site.data == 0 then
            break
        end

        

        for _, server in ipairs(Site.data) do
            if server and type(server) == "table" and server.id then
                local ID = tostring(server.id)
                TotalServersFound = TotalServersFound + 1

                local isPrivate = false
                if server.privateServerId and server.privateServerId ~= "" then
                    isPrivate = true
                end

                if server.id and table.find(PrivateServerBlacklist, tostring(server.id)) then
                    isPrivate = true
                end

                if not isPrivate and not table.find(ScannedServers, ID) then
                    table.insert(ScannedServers, ID)
                    local playing = tonumber(server.playing)
                    local maxPlayers = tonumber(server.maxPlayers)

                    if playing and maxPlayers and playing >= 0 and maxPlayers > 0 then
                        if playing >= targetPlayerCount.min 
                            and playing <= targetPlayerCount.max 
                            and playing < maxPlayers then

                            ValidServersFound = ValidServersFound + 1
                            table.insert(TargetServers, {
                                id = ID,
                                players = playing,
                                maxPlayers = maxPlayers,
                                ping = tonumber(server.ping) or 999,
                                fps = tonumber(server.fps) or 60
                            })

                        end
                    end
                end
            end
        end

        if Site.nextPageCursor and Site.nextPageCursor ~= "" and Site.nextPageCursor ~= nil then
            cursor = tostring(Site.nextPageCursor)
            hasMorePages = true
            task.wait(0.1)
        else
            hasMorePages = false
            break
        end
    end

    

    if #TargetServers > 0 then
        table.sort(TargetServers, function(a, b)
            if a.players ~= b.players then
                return a.players < b.players
            end

            if a.ping ~= b.ping then
                return a.ping < b.ping
            end

            return a.fps > b.fps

        end)
    end

    

    if #AllIDs > 150 then
        local temp = {}
        for i = math.max(1, #AllIDs - 75), #AllIDs do
            if AllIDs[i] then
                table.insert(temp, AllIDs[i])
            end
        end
        AllIDs = temp
    end

    

    if #PrivateServerBlacklist > 300 then
        local temp = {}
        for i = math.max(1, #PrivateServerBlacklist - 150), #PrivateServerBlacklist do
            if PrivateServerBlacklist[i] then
                table.insert(temp, PrivateServerBlacklist[i])
            end
        end
        PrivateServerBlacklist = temp
    end

    

    if #ScannedServers > 500 then
        ScannedServers = {}
    end

    local failCount = 0
    local maxFailCount = 15
    TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
        failCount = failCount + 1
        task.wait(0.1)

        

        if #TargetServers > 0 then
            local removed = table.remove(TargetServers, 1)
            if removed and removed.id then
                table.insert(PrivateServerBlacklist, removed.id)
            end
        end

        

        if failCount >= maxFailCount then
            failCount = 0
        end
    end)

    

    if LocalPlayer and LocalPlayer.Parent and #TargetServers > 0 then
        local maxAttempts = math.min(#TargetServers, 20)

        for i = 1, maxAttempts do
            local server = TargetServers[i]

            if server and type(server) == "table" and server.id then
                local serverID = server.id

                if serverID and serverID ~= "" and type(serverID) == "string" 
                    and serverID ~= currentServer 
                    and not table.find(AllIDs, serverID) 
                    and not table.find(PrivateServerBlacklist, serverID) then
                    table.insert(AllIDs, serverID)

                    local teleportOptions = Instance.new("TeleportOptions")
                    teleportOptions.ShouldReserveServer = false

                    pcall(function()
                        TeleportService:TeleportAsync(PlaceID, {LocalPlayer}, teleportOptions)
                    end)

                    task.wait(0.1)

                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(PlaceID, server.id, LocalPlayer)
                    end)

                    task.wait(0.1)
                end
            end
        end
    end
end

nguoi1()
