local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer
_G.FastAttack = true
function IsEntityAlive(entity)
    if not entity then return false end
    local humanoid = entity:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

function GetEnemiesInRange(character, range)
    local targets = {}
    local playerPos = character:GetPivot().Position

    for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
        local rootPart = enemy:FindFirstChild("HumanoidRootPart")
        if rootPart and IsEntityAlive(enemy) then
            if (rootPart.Position - playerPos).Magnitude <= range then
                table.insert(targets, enemy)
            end
        end
    end

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= plr and otherPlayer.Character then
            local rootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart and IsEntityAlive(otherPlayer.Character) then
                if (rootPart.Position - playerPos).Magnitude <= range then
                    table.insert(targets, otherPlayer.Character)
                end
            end
        end
    end
    return targets
end

function Attack()
    local character = plr.Character
    if not character then return end

    local equippedWeapon
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Tool") then
            equippedWeapon = item
            break
        end
    end
    if not equippedWeapon then return end

    local enemiesInRange = GetEnemiesInRange(character, 100)
    if #enemiesInRange == 0 then return end

    local modules = ReplicatedStorage:FindFirstChild("Modules")
    if not modules then return end

    local attackEvent = modules.Net:FindFirstChild("RE/RegisterAttack")
    local hitEvent = modules.Net:FindFirstChild("RE/RegisterHit")
    if not attackEvent or not hitEvent then return end

    local targets, mainTarget = {}, nil
    for _, enemy in ipairs(enemiesInRange) do
        if not enemy:GetAttribute("IsBoat") then
            local HitboxLimbs = { "RightLowerArm", "RightUpperArm", "LeftLowerArm", "LeftUpperArm", "RightHand",
                "LeftHand" }
            local head = enemy:FindFirstChild(HitboxLimbs[math.random(#HitboxLimbs)]) or enemy.PrimaryPart
            if head then
                table.insert(targets, { enemy, head })
                mainTarget = head
            end
        end
    end
    if not mainTarget then return end

    attackEvent:FireServer(0)

    local playerScripts = plr:FindFirstChild("PlayerScripts")
    if not playerScripts then return end

    local localScript = playerScripts:FindFirstChildOfClass("LocalScript")
    while not localScript do
        playerScripts.ChildAdded:Wait()
        localScript = playerScripts:FindFirstChildOfClass("LocalScript")
    end

    local hitFunction
    if getsenv then
        local success, scriptEnv = pcall(getsenv, localScript)
        if success and scriptEnv then
            hitFunction = scriptEnv._G.SendHitsToServer
        end
    end

    local successFlags, combatRemoteThread = pcall(function()
        return require(modules.Flags).COMBAT_REMOTE_THREAD or false
    end)

    if successFlags and combatRemoteThread and hitFunction then
        hitFunction(mainTarget, targets)
    elseif successFlags and not combatRemoteThread then
        hitEvent:FireServer(mainTarget, targets)
    end
end

local CameraShakerR = require(ReplicatedStorage.Util.CameraShaker)
CameraShakerR:Stop()

function get_Monster()
    for _, b in pairs(workspace.Enemies:GetChildren()) do
        local c = b:FindFirstChild("UpperTorso") or b:FindFirstChild("Head")
        if b:FindFirstChild("HumanoidRootPart", true) and c then
            if (b.Head.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 50 then
                return true, c.Position
            end
        end
    end
    for _, d in pairs(workspace.SeaBeasts:GetChildren()) do
        if d:FindFirstChild("HumanoidRootPart") and d:FindFirstChild("Health") and d.Health.Value > 0 then
            return true, d.HumanoidRootPart.Position
        end
    end
    for _, d in pairs(workspace.Enemies:GetChildren()) do
        if d:FindFirstChild("Health") and d.Health.Value > 0 and d:FindFirstChild("VehicleSeat") then
            return true, d.Engine.Position
        end
    end
    return false, nil
end

RunService.Heartbeat:Connect(function()
    pcall(function()
        if not _G.FastAttack then return end
        if not plr.Character then return end

        if type(Attack) == "function" then
            Attack()
        end

        local pretool = plr.Character:FindFirstChildOfClass("Tool")
        if not pretool then return end

        local tooltip = pretool:FindFirstChild("ToolTip") and pretool.ToolTip.Value or tostring(pretool.ToolTip or "")
        local ok, mob = pcall(get_Monster)
        local mobOk = ok and mob ~= nil

        if tooltip == "Blox Fruit" and mobOk then
            local left = pretool:FindFirstChild("LeftClickRemote")
            if left and left:IsA("RemoteEvent") then
                left:FireServer(Vector3.new(0, -500, 0), 1, true)
                task.wait(0.03)
                left:FireServer(false)
            end
        end
    end)
end)
