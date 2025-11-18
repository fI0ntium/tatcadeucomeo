do
	ply = game["Players"]
	plr = ply["LocalPlayer"]
	Root = plr["Character"]["HumanoidRootPart"]
	replicated = game:GetService("ReplicatedStorage")
	Lv = game["Players"]["LocalPlayer"]["Data"]["Level"]["Value"]
	TeleportService = game:GetService("TeleportService")
	TW = game:GetService("TweenService")
	Lighting = game:GetService("Lighting")
	Enemies = workspace["Enemies"]
	vim1 = game:GetService("VirtualInputManager")
	vim2 = game:GetService("VirtualUser")
	TeamSelf = plr["Team"]
	RunSer = game:GetService("RunService")
	Stats = game:GetService("Stats")
	Energy = plr["Character"]["Energy"]["Value"]
	Boss = {}
	BringConnections = {}
	MaterialList = {}
	NPCList = {}
	shouldTween = false
	SoulGuitar = false
	KenTest = true
	debug = false
	Brazier1 = false
	Brazier2 = false
	Brazier3 = false
	Sec = .1
	ClickState = 0
	Num_self = 25
end
local Ec = game["Players"]["LocalPlayer"]
local CombatUtil = require(game.ReplicatedStorage.Modules.CombatUtil)
hookfunction(CombatUtil.GetComboPaddingTime, function(...)
	return 0 
end)
hookfunction(CombatUtil.GetAttackCancelMultiplier, function(...)
	return 0 
end)
hookfunction(CombatUtil.CanAttack, function(...)
	return true 
end)
local function Bc(x)
	if not x then
		return false
	end
	local L = x:FindFirstChild("Humanoid")
	return L and L["Health"] > 0
end
local function Pc(x, L)
	local a = (game:GetService("Workspace"))["Enemies"]:GetChildren()
	local V = (game:GetService("Players")):GetPlayers()
	local H = {}
	local r = (x:GetPivot())["Position"]
	for x, a in ipairs(a) do
		local V = a:FindFirstChild("HumanoidRootPart")
		if V and Bc(a) then
			local x = (V["Position"] - r)["Magnitude"]
			if x <= L then
				table["insert"](H, a)
			end
		end
	end
	for x, a in ipairs(V) do
		if a ~= Ec and a["Character"] then
			local x = a["Character"]:FindFirstChild("HumanoidRootPart")
			if x and Bc(a["Character"]) then
				local V = (x["Position"] - r)["Magnitude"]
				if V <= L then
					table["insert"](H, a["Character"])
				end
			end
		end
	end
	return H
end
function AttackNoCoolDown()
	local x = (game:GetService("Players"))["LocalPlayer"]
	local L = x["Character"]
	if not L then
		return
	end
	local a = nil
	for x, L in ipairs(L:GetChildren()) do
		if L:IsA("Tool") then
			a = L
			break
		end
	end
	if not a then
		return
	end
	local V = Pc(L, 100)
	if #V == 0 then
		return
	end
	local H = game:GetService("ReplicatedStorage")
	local r = H:FindFirstChild("Modules")
	if not r then
		return
	end
	local R = ((H:WaitForChild("Modules")):WaitForChild("Net")):WaitForChild("RE/RegisterAttack")
	local y = ((H:WaitForChild("Modules")):WaitForChild("Net")):WaitForChild("RE/RegisterHit")
	if not R or not y then
		return
	end
	local l, M = {}, nil
	for x, L in ipairs(V) do
		if not L:GetAttribute("IsBoat") then
			local x = {
				"RightLowerArm",
				"RightUpperArm",
				"LeftLowerArm";
				"LeftUpperArm",
				"RightHand",
				"LeftHand"
			}
			local a = L:FindFirstChild(x[math["random"](#x)]) or L["PrimaryPart"]
			if a then
				table["insert"](l, {
					L,
					a
				})
				M = a
			end
		end
	end
	if not M then
		return
	end
	R:FireServer(0)
	local n = x:FindFirstChild("PlayerScripts")
	if not n then
		return
	end
	local b = n:FindFirstChildOfClass("LocalScript")
	while not b do
		n["ChildAdded"]:Wait()
		b = n:FindFirstChildOfClass("LocalScript")
	end
	local Z
	if getsenv then
		local x, L = pcall(getsenv, b)
		if x and L then
			Z = L["_G"]["SendHitsToServer"]
		end
	end
	local q, I = pcall(function()
		return (require(r["Flags"]))["COMBAT_REMOTE_THREAD"] or false
	end)
	if q and (I and Z) then
		Z(M, l)
	elseif q and not I then
		y:FireServer(M, l)
	end
end
CameraShakerR = require(game["ReplicatedStorage"]["Util"]["CameraShaker"])
CameraShakerR:Stop()
get_Monster = function()
	for x, L in pairs(workspace["Enemies"]:GetChildren()) do
		local a = L:FindFirstChild("UpperTorso") or L:FindFirstChild("Head")
		if L:FindFirstChild("HumanoidRootPart", true) and a then
			if (L["Head"]["Position"] - plr["Character"]["HumanoidRootPart"]["Position"])["Magnitude"] <= 50 then
				return true, a["Position"]
			end
		end
	end
	for x, L in pairs(workspace["SeaBeasts"]:GetChildren()) do
		if L:FindFirstChild("HumanoidRootPart") and (L:FindFirstChild("Health") and L["Health"]["Value"] > 0) then
			return true, L["HumanoidRootPart"]["Position"]
		end
	end
	for x, L in pairs(workspace["Enemies"]:GetChildren()) do
		if L:FindFirstChild("Health") and (L["Health"]["Value"] > 0 and L:FindFirstChild("VehicleSeat")) then
			return true, L["Engine"]["Position"]
		end
	end
end
Actived = function()
	local x = game["Players"]["LocalPlayer"]["Character"]:FindFirstChildOfClass("Tool")
	for x, L in next, getconnections(x["Activated"]) do
		if typeof(L["Function"]) == "function" then
			getupvalues(L["Function"])
		end
	end
end
task["spawn"](function()
	RunSer["Heartbeat"]:Connect(function()
		pcall(function()
			if not _G["Seriality"] then
				return
			end
			AttackNoCoolDown()
			local x = game["Players"]["LocalPlayer"]["Character"]:FindFirstChildOfClass("Tool")
			local L = x["ToolTip"]
			local a, V = get_Monster()
			if L == "Blox Fruit" then
				if a then
					local L = x:FindFirstChild("LeftClickRemote")
					if L then
						Actived()
						L:FireServer(Vector3["new"](.01, -500, .01), 1, true)
						L:FireServer(false)
					end
				end
			end
		end)
	end)
end)

_G["Seriality"] = true
local FastAttack = {}
local folders = {
    workspace.Enemies,
    workspace.Characters
}
local Modules = game.ReplicatedStorage:WaitForChild("Modules")
local RE_Attack = Modules.Net:WaitForChild("RE/RegisterAttack")
local RunHitDetection
local HIT_FUNCTION
task.defer(function()
    local success, Env = pcall(getsenv, game:GetService("ReplicatedStorage").Modules.CombatUtil)
    if success and Env then
        print("OK")
        HIT_FUNCTION = Env._G.SendHitsToServer
    end
    local success2, module = pcall(require, Modules:WaitForChild("CombatUtil"))
    if success2 and module then
        RunHitDetection = module.RunHitDetection
    end
end)
function FastAttack:IsAlive(v)
    return v and not v:FindFirstChild("VehicleSeat") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart")
end
function FastAttack:GetDistance(x,xx)
    return ((typeof(x) == "Vector3" and CFrame.new(x) or x).Position - (xx == nil and game.Players.LocalPlayer.Character.PrimaryPart or (typeof(xx) == "Vector3" and Vector3.new(xx) or xx)).Position).Magnitude
end
function FastAttack:GetHits()
    local Hits = {}
    for i,v in next, workspace.Enemies:GetChildren() do
        if self:IsAlive(v) and self:GetDistance(v.HumanoidRootPart.Position) <= 60 then
            table.insert(Hits, v)
        end
    end
    return Hits
end
function FastAttack:GetRandomHitbox(v)
    local HitBox =  {
        "RightLowerArm", 
        "RightUpperArm", 
        "LeftLowerArm", 
        "LeftUpperArm", 
        "RightHand", 
        "LeftHand",
        "HumanoidRootPart",
        "Head"
    }
    return v:FindFirstChild(HitBox[math.random(1, #HitBox)]) or v.HumanoidRootPart
end
function FastAttack:SuperFastAttack()
    local BladeHits = self:GetHits()
    local realenemy
    if #BladeHits == 0 then return end
    local Args = {[1] = nil, [2] = {}}
    for _,v in next, BladeHits do
        if not Args[1] then
            Args[1] = self:GetRandomHitbox(v)
        end
        Args[2][#Args[2] + 1] = {
            [1] = v,
            [2] = self:GetRandomHitbox(v)
        }
        realenemy = v
    end
    if not Args[2] then Args[2] = {realenemy} end
    Args[2][#Args[2] + 1] = realenemy
    RE_Attack:FireServer(0)
    if HIT_FUNCTION then
        HIT_FUNCTION(unpack(Args))
    end
end
function FastAttack:RunHitboxFastAttack()
    local Tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not Tool then return end
    local success, hitResult, overlapParams, group1, group2 = pcall(function()
        return RunHitDetection(game.Players.LocalPlayer.Character, Tool)
    end)
    
    if not success or not hitResult or type(hitResult) ~= "table" then return end
    if #hitResult == 0 then return end

    local Args = {[1] = nil, [2] = {}}
    for _, target in ipairs(hitResult) do
        if self:IsAlive(target) then
            local hitPart = self:GetRandomHitbox(target)
            if not Args[1] then Args[1] = hitPart end
            table.insert(Args[2], {target, hitPart})
        end
    end

    if #Args[2] > 0 then
        RE_Attack:FireServer(0)
        if HIT_FUNCTION then
            HIT_FUNCTION(unpack(Args))
        end
    end
end

while task.wait(0.005) do
    pcall(function()
        FastAttack:SuperFastAttack()
		FastAttack:RunHitboxFastAttack()
    end)
end
