--[[
    ARSENAL AIM LOCK + ESP SCRIPT
    ==============================
    Features:
    - Aim Lock to head
    - ESP (see through walls)
    - Customizable UI
    - Keybind toggle
    - Distance limit
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configuration
local Config = {
    AimLockEnabled = false,
    ESPEnabled = true,
    TargetPart = "Head", -- Head, Torso
    MaxDistance = 500,
    Smoothness = 0.1,
    AimKey = Enum.KeyCode.E,
    ESPKey = Enum.KeyCode.R,
    ShowUI = true
}

-- ESP Storage
local ESPObjects = {}

-- Color Configuration
local Colors = {
    Primary = Color3.fromRGB(0, 170, 255),
    Secondary = Color3.fromRGB(80, 215, 255),
    Success = Color3.fromRGB(90, 255, 155),
    Error = Color3.fromRGB(255, 85, 105),
    Background = Color3.fromRGB(7, 9, 14),
    Text = Color3.fromRGB(245, 248, 255),
    Muted = Color3.fromRGB(145, 155, 175)
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function round(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
end

local function createLabel(text, size, parent, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Colors.Text
    label.TextSize = size or 14
    label.Font = Enum.Font.GothamMedium
    label.Parent = parent
    return label
end

local function createButton(text, size, position, parent, callback)
    local button = Instance.new("TextButton")
    button.Name = text
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = Colors.Primary
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Colors.Text
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    round(button, 8)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Primary
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

-- ============================================
-- ESP FUNCTIONS
-- ============================================

local function createESP(player)
    if player == LocalPlayer or ESPObjects[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- ESP Box
    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Size = Vector3.new(3, 5, 3)
    espBox.Color3 = Colors.Primary
    espBox.Transparency = 0.3
    espBox.AlwaysOnTop = true
    espBox.Parent = humanoidRootPart
    
    -- ESP Label
    local espLabel = Instance.new("BillboardGui")
    espLabel.Size = UDim2.new(4, 0, 2, 0)
    espLabel.MaxDistance = 500
    espLabel.Parent = humanoidRootPart
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.BackgroundTransparency = 0.3
    textLabel.BackgroundColor3 = Colors.Background
    textLabel.Text = player.Name
    textLabel.TextColor3 = Colors.Success
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = espLabel
    round(textLabel, 4)
    
    ESPObjects[player] = {
        Box = espBox,
        Label = espLabel,
        Adornment = textLabel
    }
end

local function removeESP(player)
    if ESPObjects[player] then
        if ESPObjects[player].Box then
            ESPObjects[player].Box:Destroy()
        end
        if ESPObjects[player].Label then
            ESPObjects[player].Label:Destroy()
        end
        ESPObjects[player] = nil
    end
end

local function updateESP()
    if not Config.ESPEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                if not ESPObjects[player] then
                    createESP(player)
                end
            else
                removeESP(player)
            end
        end
    end
end

-- ============================================
-- AIM LOCK FUNCTIONS
-- ============================================

local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = Config.MaxDistance
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local targetPart = character:FindFirstChild(Config.TargetPart)
                
                if humanoid and humanoid.Health > 0 and targetPart then
                    local distance = (targetPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function aimLock()
    if not Config.AimLockEnabled then return end
    
    local target = getClosestPlayer()
    if target then
        local character = target.Character
        if character then
            local targetPart = character:FindFirstChild(Config.TargetPart)
            if targetPart then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Smoothness)
            end
        end
    end
end

-- ============================================
-- UI CREATION
-- ============================================

local function createMainUI()
    -- Main Screen GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "ArsenalAimLockGUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui
    
    -- Background
    local background = Instance.new("Frame")
    background.Size = UDim2.fromOffset(320, 400)
    background.Position = UDim2.fromOffset(20, 20)
    background.BackgroundColor3 = Colors.Background
    background.BorderSizePixel = 0
    background.Parent = gui
    round(background, 12)
    
    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Primary
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = background
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.fromOffset(320, 40)
    title.Position = UDim2.fromOffset(0, 0)
    title.BackgroundTransparency = 0.5
    title.BackgroundColor3 = Colors.Primary
    title.Text = "⚡ ARSENAL HACK"
    title.TextColor3 = Colors.Text
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.BorderSizePixel = 0
    title.Parent = background
    round(title, 12)
    
    -- Content Frame
    local content = Instance.new("Frame")
    content.Size = UDim2.fromOffset(300, 340)
    content.Position = UDim2.fromOffset(10, 50)
    content.BackgroundTransparency = 1
    content.Parent = background
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = content
    
    -- ============================================
    -- AIM LOCK SECTION
    -- ============================================
    
    local aimSection = Instance.new("Frame")
    aimSection.Size = UDim2.fromOffset(280, 100)
    aimSection.BackgroundColor3 = Colors.Background
    aimSection.BorderSizePixel = 0
    aimSection.Parent = content
    round(aimSection, 8)
    
    local aimStroke = Instance.new("UIStroke")
    aimStroke.Color = Colors.Secondary
    aimStroke.Thickness = 1
    aimStroke.Transparency = 0.7
    aimStroke.Parent = aimSection
    
    createLabel("🎯 AIM LOCK", 14, aimSection, Colors.Secondary)
    
    local aimToggle = createButton("OFF", UDim2.fromOffset(130, 35), UDim2.fromOffset(10, 30), aimSection, function()
        Config.AimLockEnabled = not Config.AimLockEnabled
        aimToggle.Text = Config.AimLockEnabled and "ON" or "OFF"
        aimToggle.BackgroundColor3 = Config.AimLockEnabled and Colors.Success or Colors.Error
    end)
    
    local distanceLabel = createLabel("Distance: 500", 11, aimSection, Colors.Muted)
    distanceLabel.Position = UDim2.fromOffset(150, 30)
    distanceLabel.Size = UDim2.fromOffset(120, 35)
    
    -- ============================================
    -- ESP SECTION
    -- ============================================
    
    local espSection = Instance.new("Frame")
    espSection.Size = UDim2.fromOffset(280, 100)
    espSection.Position = UDim2.fromOffset(0, 110)
    espSection.BackgroundColor3 = Colors.Background
    espSection.BorderSizePixel = 0
    espSection.Parent = content
    round(espSection, 8)
    
    local espStroke = Instance.new("UIStroke")
    espStroke.Color = Colors.Secondary
    espStroke.Thickness = 1
    espStroke.Transparency = 0.7
    espStroke.Parent = espSection
    
    createLabel("👁️ ESP", 14, espSection, Colors.Secondary)
    
    local espToggle = createButton("ON", UDim2.fromOffset(130, 35), UDim2.fromOffset(10, 30), espSection, function()
        Config.ESPEnabled = not Config.ESPEnabled
        espToggle.Text = Config.ESPEnabled and "ON" or "OFF"
        espToggle.BackgroundColor3 = Config.ESPEnabled and Colors.Success or Colors.Error
        
        if not Config.ESPEnabled then
            for player, _ in pairs(ESPObjects) do
                removeESP(player)
            end
        end
    end)
    
    local targetLabel = createLabel("Target: Head", 11, espSection, Colors.Muted)
    targetLabel.Position = UDim2.fromOffset(150, 30)
    targetLabel.Size = UDim2.fromOffset(120, 35)
    
    -- ============================================
    -- INFO SECTION
    -- ============================================
    
    local infoSection = Instance.new("Frame")
    infoSection.Size = UDim2.fromOffset(280, 100)
    infoSection.Position = UDim2.fromOffset(0, 220)
    infoSection.BackgroundColor3 = Colors.Background
    infoSection.BorderSizePixel = 0
    infoSection.Parent = content
    round(infoSection, 8)
    
    local infoStroke = Instance.new("UIStroke")
    infoStroke.Color = Colors.Secondary
    infoStroke.Thickness = 1
    infoStroke.Transparency = 0.7
    infoStroke.Parent = infoSection
    
    createLabel("ℹ️ INFO", 14, infoSection, Colors.Secondary)
    
    local info1 = createLabel("E - Toggle Aim Lock", 10, infoSection, Colors.Muted)
    info1.Position = UDim2.fromOffset(10, 30)
    info1.Size = UDim2.fromOffset(260, 20)
    
    local info2 = createLabel("R - Toggle ESP", 10, infoSection, Colors.Muted)
    info2.Position = UDim2.fromOffset(10, 50)
    info2.Size = UDim2.fromOffset(260, 20)
    
    local info3 = createLabel("Made with ❤️", 10, infoSection, Colors.Primary)
    info3.Position = UDim2.fromOffset(10, 70)
    info3.Size = UDim2.fromOffset(260, 20)
    info3.Font = Enum.Font.GothamBold
    
    return gui
end

-- ============================================
-- MAIN LOOP
-- ============================================

-- Create UI
createMainUI()

-- Keybind Events
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Config.AimKey then
        Config.AimLockEnabled = not Config.AimLockEnabled
    elseif input.KeyCode == Config.ESPKey then
        Config.ESPEnabled = not Config.ESPEnabled
        if not Config.ESPEnabled then
            for player, _ in pairs(ESPObjects) do
                removeESP(player)
            end
        end
    end
end)

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
    updateESP()
end)

-- Aim Lock Loop
RunService.RenderStepped:Connect(function()
    if Config.AimLockEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        aimLock()
    end
end)

-- Player Added Event
Players.PlayerAdded:Connect(function(player)
    if Config.ESPEnabled then
        task.wait(0.5)
        createESP(player)
    end
end)

-- Player Removed Event
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

print("✅ Arsenal Aim Lock + ESP Loaded! Press E to toggle Aim Lock, R to toggle ESP")
