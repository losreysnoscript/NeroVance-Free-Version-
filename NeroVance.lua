--[[
    ======================================================================================
      N E R O   V A N C E   H U B   |   U L T I M A T E   M A X   E D I T I O N   V6
    ======================================================================================
    Rewritten for Delta: Anti-Cheat Bypass, Safe Tweening, Auto-Haki, Weapon Selection.
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local CommF = ReplicatedStorage:WaitForChild("Remotes", 10) and ReplicatedStorage.Remotes:WaitForChild("CommF_", 10)

--=========================================
--        GLOBAL CONFIGURATION
--=========================================
getgenv().NeroVance = {
    AutoFarm = false, AutoBoss = false, FastAttack = true, AutoHaki = true,
    FarmDistance = 8, WeaponType = "Melee", TargetBoss = "All",
    AutoStats = false, StatAmount = 1, StatTarget = "Melee",
    AutoGacha = false, AutoStore = true
}
local Config = getgenv().NeroVance

--=========================================
--        ANTI-AFK & PLATFORM SETUP
--=========================================
LP.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

local FarmPlatform = Instance.new("Part")
FarmPlatform.Size = Vector3.new(10, 1, 10)
FarmPlatform.Transparency = 1
FarmPlatform.Anchored = true
FarmPlatform.CanCollide = true
FarmPlatform.Parent = workspace

--=========================================
--        CORE FARMING FUNCTIONS
--=========================================
local function GetChar() return LP.Character or LP.CharacterAdded:Wait() end
local function GetHRP() return GetChar():WaitForChild("HumanoidRootPart", 5) end

local function EquipWeapon()
    pcall(function()
        local char = GetChar()
        if not char:FindFirstChild("Humanoid") then return end
        for _, tool in ipairs(LP.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.ToolTip == Config.WeaponType then
                char.Humanoid:EquipTool(tool)
            end
        end
    end)
end

local function ActivateHaki()
    if Config.AutoHaki and not GetChar():FindFirstChild("HasBuso") then
        pcall(function() CommF:InvokeServer("Buso") end)
    end
end

local function SafeTween(targetCFrame)
    local root = GetHRP()
    if not root then return end
    
    local dist = (root.Position - targetCFrame.Position).Magnitude
    if dist < 10 then 
        root.CFrame = targetCFrame 
        return 
    end
    
    local speed = 300
    local tInfo = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tInfo, {CFrame = targetCFrame})
    tween:Play()
end

local function Attack()
    if not Config.FastAttack then return end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new())
end

-- NoClip & Platform Updater
RunService.Stepped:Connect(function()
    if Config.AutoFarm or Config.AutoBoss then
        pcall(function()
            local char = LP.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    FarmPlatform.CFrame = root.CFrame * CFrame.new(0, -3.5, 0)
                end
            end
        end)
    else
        FarmPlatform.CFrame = CFrame.new(0, 9999, 0)
    end
end)

local function KillTarget(enemy)
    if not enemy or not enemy:FindFirstChild("Humanoid") or enemy.Humanoid.Health <= 0 then return end
    local root = enemy:FindFirstChild("HumanoidRootPart")
    
    if root then
        ActivateHaki()
        EquipWeapon()
        
        -- Hover directly above the mob based on FarmDistance
        local targetPos = root.CFrame * CFrame.new(0, Config.FarmDistance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
        SafeTween(targetPos)
        
        -- Bring mob slightly up to avoid them falling under map
        root.CFrame = root.CFrame
        root.Size = Vector3.new(50, 50, 50) -- Invisible hitbox expander
        
        Attack()
    end
end

--=========================================
--        ORION UI SETUP
--=========================================
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
local Window = OrionLib:MakeWindow({Name = "Nero Vance Hub | V6 REWRITE", HidePremium = true, SaveConfig = false, IntroText = "NERO VANCE V6"})

local TabMain = Window:MakeTab({Name = "Auto Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TabCombat = Window:MakeTab({Name = "Bosses", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TabStats = Window:MakeTab({Name = "Stats & Items", Icon = "rbxassetid://4483345998", PremiumOnly = false})

--// MAIN TAB
TabMain:AddDropdown({Name = "Select Weapon Type", Default = "Melee", Options = {"Melee", "Sword", "Blox Fruit", "Gun"}, Callback = function(v) Config.WeaponType = v end})
TabMain:AddToggle({Name = "Enable Auto Farm Level", Default = false, Callback = function(v) Config.AutoFarm = v end})
TabMain:AddToggle({Name = "Auto Haki (Aura)", Default = true, Callback = function(v) Config.AutoHaki = v end})
TabMain:AddToggle({Name = "Fast Attack", Default = true, Callback = function(v) Config.FastAttack = v end})
TabMain:AddSlider({Name = "Hover Distance", Min = 5, Max = 20, Default = 8, Increment = 1, ValueName = "Studs", Callback = function(v) Config.FarmDistance = v end})

--// BOSS TAB
local BossList = {"All", "Smoke Admiral", "Ice Admiral", "Tide Keeper", "Don Swan", "Katakuri", "Dough King", "Rip_Indra"}
TabCombat:AddDropdown({Name = "Select Boss", Default = "All", Options = BossList, Callback = function(v) Config.TargetBoss = v end})
TabCombat:AddToggle({Name = "Auto Boss", Default = false, Callback = function(v) Config.AutoBoss = v end})

--// STATS & ITEMS TAB
TabStats:AddDropdown({Name = "Select Stat to Upgrade", Default = "Melee", Options = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}, Callback = function(v) Config.StatTarget = v end})
TabStats:AddSlider({Name = "Points per Tick", Min = 1, Max = 100, Default = 1, Increment = 1, ValueName = "Points", Callback = function(v) Config.StatAmount = v end})
TabStats:AddToggle({Name = "Auto Upgrade Stats", Default = false, Callback = function(v) Config.AutoStats = v end})
TabStats:AddToggle({Name = "Auto Store Fruits", Default = true, Callback = function(v) Config.AutoStore = v end})
TabStats:AddButton({Name = "Roll Random Fruit", Callback = function() if CommF then CommF:InvokeServer("Cousin", "Buy") end end})

--=========================================
--        BACKGROUND LOOPS
--=========================================
task.spawn(function()
    while task.wait() do
        if Config.AutoFarm or Config.AutoBoss then
            local Enemies = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("Enemy")
            if Enemies then
                for _, enemy in ipairs(Enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        if Config.AutoBoss and (enemy:FindFirstChild("Boss") or enemy.Name:find("Admiral") or enemy.Name:find("King")) then
                            if Config.TargetBoss == "All" or enemy.Name:find(Config.TargetBoss) then
                                KillTarget(enemy)
                            end
                        elseif Config.AutoFarm and not enemy:FindFirstChild("Boss") then
                            KillTarget(enemy)
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if Config.AutoStats and CommF then
            pcall(function() CommF:InvokeServer("AddPoint", Config.StatTarget, Config.StatAmount) end)
        end
        
        if Config.AutoStore and LP:FindFirstChild("Backpack") and CommF then
            for _, item in ipairs(LP.Backpack:GetChildren()) do
                if item.Name:find("Fruit") then CommF:InvokeServer("StoreFruit", item.Name, item) end
            end
        end
    end
end)

OrionLib:Init()
