--[[
    ARSENAL AIM LOCK + ESP SCRIPT (SkyZen UI Style - Simplified)
    ============================================================
    Premium Cyberpunk GUI with Aim Lock Settings & ESP Toggle
    Features:
    - Aim Lock with target part selection (Head, Body, Hand)
    - ESP toggle (ON/OFF)
    - Premium SkyZen UI Design
    - Keybind support
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
    TargetPart = "Head", -- Head, Torso (Body), RightHand (Hand)
    MaxDistance = 500,
    Smoothness = 0.1,
    AimKey = Enum.KeyCode.E,
    ESPKey = Enum.KeyCode.R,
}

-- Target Part Mapping
local TargetParts = {
    "Head",
    "Torso",
    "RightHand"
}

local TargetPartLabels = {
    "Head",
    "Body",
    "Hand"
}

-- ESP Storage
local ESPObjects = {}

-- SkyZen Color Palette
local Colors = {
    Primary = Color3.fromRGB(0, 170, 255),      -- Cyan
    Secondary = Color3.fromRGB(80, 215, 255),   -- Light Cyan
    Accent = Color3.fromRGB(138, 43, 226),      -- Purple
    Success = Color3.fromRGB(0, 255, 136),      -- Green
    Error = Color3.fromRGB(255, 85, 105),       -- Red
    Background = Color3.fromRGB(10, 15, 30),    -- Dark Blue
    Card = Color3.fromRGB(15, 20, 40),          -- Card Background
    Text = Color3.fromRGB(245, 248, 255),       -- White
    Muted = Color3.fromRGB(120, 140, 180),      -- Muted Blue
    Border = Color3.fromRGB(0, 170, 255)        -- Neon Border
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function round(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
    return corner
end

local function addGlowStroke(object, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Colors.Primary
    stroke.Thickness = thickness or 2
    stroke.Transparency = transparency or 0.3
    stroke.Parent = object
    return stroke
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
    espLabel.MaxDistance = Config.MaxDistance
    espLabel.Parent = humanoidRootPart
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.BackgroundTransparency = 0.2
    textLabel.BackgroundColor3 = Colors.Background
    textLabel.Text = "👤 " .. player.Name
    textLabel.TextColor3 = Colors.Success
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = espLabel
    round(textLabel, 6)
    addGlowStroke(textLabel, Colors.Success, 1.5, 0.4)
    
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
-- UI CREATION (SkyZen Style - Simplified)
-- ============================================

local function createSkyZenUI()
    -- Main Screen GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "SkyZenArsenal"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui
    
    -- ============================================
    -- HEADER
    -- ============================================
    local header = Instance.new("Frame")
    header.Size = UDim2.fromScale(1, 0.08)
    header.BackgroundColor3 = Colors.Background
    header.BorderSizePixel = 0
    header.Parent = gui
    
    addGlowStroke(header, Colors.Primary, 2, 0.5)
    
    -- Logo
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.fromOffset(200, 50)
    logo.Position = UDim2.fromOffset(20, 5)
    logo.BackgroundTransparency = 1
    logo.Text = "⚡ SKYZEN"
    logo.TextColor3 = Colors.Primary
    logo.TextSize = 24
    logo.Font = Enum.Font.GothamBlack
    logo.Parent = header
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.fromOffset(200, 20)
    subtitle.Position = UDim2.fromOffset(20, 28)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "ARSENAL SCRIPT HUB"
    subtitle.TextColor3 = Colors.Muted
    subtitle.TextSize = 9
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.Parent = header
    
    -- Status
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.fromOffset(12, 12)
    statusDot.Position = UDim2.fromScale(0.95, 0.5)
    statusDot.AnchorPoint = Vector2.new(1, 0.5)
    statusDot.BackgroundColor3 = Colors.Success
    statusDot.BorderSizePixel = 0
    statusDot.Parent = header
    round(statusDot, 999)
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.fromOffset(60, 20)
    statusText.Position = UDim2.fromScale(0.93, 0.5)
    statusText.AnchorPoint = Vector2.new(1, 0.5)
    statusText.BackgroundTransparency = 1
    statusText.Text = "● ONLINE"
    statusText.TextColor3 = Colors.Success
    statusText.TextSize = 11
    statusText.Font = Enum.Font.GothamBold
    statusText.Parent = header
    
    -- ============================================
    -- SIDEBAR
    -- ============================================
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0.2, 0, 0.92, 0)
    sidebar.Position = UDim2.fromScale(0, 0.08)
    sidebar.BackgroundColor3 = Colors.Background
    sidebar.BorderSizePixel = 0
    sidebar.Parent = gui
    
    addGlowStroke(sidebar, Colors.Primary, 1, 0.6)
    
    local sidebarTitle = Instance.new("TextLabel")
    sidebarTitle.Size = UDim2.fromScale(1, 0.08)
    sidebarTitle.BackgroundTransparency = 1
    sidebarTitle.Text = "MENU"
    sidebarTitle.TextColor3 = Colors.Primary
    sidebarTitle.TextSize = 14
    sidebarTitle.Font = Enum.Font.GothamBold
    sidebarTitle.Parent = sidebar
    
    local menuItems = {"🎯 AIM LOCK", "👁️ ESP"}
    
    for i, item in ipairs(menuItems) do
        local btn = Instance.new("TextButton")
        btn.Name = item
        btn.Size = UDim2.new(0.9, 0, 0.08, 0)
        btn.Position = UDim2.new(0.05, 0, 0.08 + (i-1) * 0.1, 0)
        btn.BackgroundColor3 = Colors.Primary
        btn.BackgroundTransparency = 0.2
        btn.BorderSizePixel = 0
        btn.Text = item
        btn.TextColor3 = Colors.Text
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.Parent = sidebar
        round(btn, 8)
        addGlowStroke(btn, Colors.Primary, 1, 0.4)
    end
    
    -- ============================================
    -- MAIN CONTENT - AIM LOCK SECTION
    -- ============================================
    local mainContent = Instance.new("Frame")
    mainContent.Size = UDim2.new(0.8, 0, 0.92, 0)
    mainContent.Position = UDim2.fromScale(0.2, 0.08)
    mainContent.BackgroundColor3 = Colors.Background
    mainContent.BorderSizePixel = 0
    mainContent.Parent = gui
    
    -- Title
    local contentTitle = Instance.new("TextLabel")
    contentTitle.Size = UDim2.new(1, -40, 0, 40)
    contentTitle.Position = UDim2.fromOffset(20, 20)
    contentTitle.BackgroundTransparency = 1
    contentTitle.Text = "🎯 AIM LOCK SETTINGS"
    contentTitle.TextColor3 = Colors.Text
    contentTitle.TextSize = 22
    contentTitle.Font = Enum.Font.GothamBlack
    contentTitle.TextXAlignment = Enum.TextXAlignment.Left
    contentTitle.Parent = mainContent
    
    -- ============================================
    -- AIM LOCK CARD
    -- ============================================
    local aimCard = Instance.new("Frame")
    aimCard.Size = UDim2.new(0.9, 0, 0.35, 0)
    aimCard.Position = UDim2.fromOffset(20, 70)
    aimCard.BackgroundColor3 = Colors.Card
    aimCard.BorderSizePixel = 0
    aimCard.Parent = mainContent
    round(aimCard, 12)
    addGlowStroke(aimCard, Colors.Primary, 2, 0.4)
    
    -- Card Padding
    local aimPadding = Instance.new("UIPadding")
    aimPadding.PaddingLeft = UDim.new(0, 20)
    aimPadding.PaddingRight = UDim.new(0, 20)
    aimPadding.PaddingTop = UDim.new(0, 20)
    aimPadding.PaddingBottom = UDim.new(0, 20)
    aimPadding.Parent = aimCard
    
    -- Aim Lock Status
    local aimStatusLabel = Instance.new("TextLabel")
    aimStatusLabel.Size = UDim2.new(0.5, 0, 0.2, 0)
    aimStatusLabel.BackgroundTransparency = 1
    aimStatusLabel.Text = "Status:"
    aimStatusLabel.TextColor3 = Colors.Muted
    aimStatusLabel.TextSize = 14
    aimStatusLabel.Font = Enum.Font.GothamBold
    aimStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimStatusLabel.Parent = aimCard
    
    local aimStatusValue = Instance.new("TextLabel")
    aimStatusValue.Size = UDim2.new(0.5, 0, 0.2, 0)
    aimStatusValue.Position = UDim2.fromScale(0.5, 0)
    aimStatusValue.BackgroundTransparency = 1
    aimStatusValue.Text = "🔴 OFF"
    aimStatusValue.TextColor3 = Colors.Error
    aimStatusValue.TextSize = 14
    aimStatusValue.Font = Enum.Font.GothamBold
    aimStatusValue.TextXAlignment = Enum.TextXAlignment.Right
    aimStatusValue.Parent = aimCard
    
    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 0.25, 0)
    toggleBtn.Position = UDim2.fromOffset(0, 40)
    toggleBtn.BackgroundColor3 = Colors.Error
    toggleBtn.BackgroundTransparency = 0.2
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "TURN ON"
    toggleBtn.TextColor3 = Colors.Text
    toggleBtn.TextSize = 14
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = aimCard
    round(toggleBtn, 8)
    addGlowStroke(toggleBtn, Colors.Error, 2, 0.3)
    
    -- Target Part Selection
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, 0, 0.15, 0)
    targetLabel.Position = UDim2.fromOffset(0, 75)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Target Part:"
    targetLabel.TextColor3 = Colors.Muted
    targetLabel.TextSize = 12
    targetLabel.Font = Enum.Font.GothamBold
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = aimCard
    
    -- Radio Buttons Container
    local radioContainer = Instance.new("Frame")
    radioContainer.Size = UDim2.new(1, 0, 0.35, 0)
    radioContainer.Position = UDim2.fromOffset(0, 95)
    radioContainer.BackgroundTransparency = 1
    radioContainer.Parent = aimCard
    
    local radioLayout = Instance.new("UIListLayout")
    radioLayout.FillDirection = Enum.FillDirection.Horizontal
    radioLayout.Padding = UDim.new(0, 15)
    radioLayout.Parent = radioContainer
    
    -- Radio Button Selection Index
    local selectedIndex = 1
    
    for i, label in ipairs(TargetPartLabels) do
        local radioBtn = Instance.new("TextButton")
        radioBtn.Name = label
        radioBtn.Size = UDim2.new(0.3, 0, 0.8, 0)
        radioBtn.BackgroundColor3 = (i == selectedIndex) and Colors.Primary or Colors.Card
        radioBtn.BackgroundTransparency = (i == selectedIndex) and 0.2 or 0.5
        radioBtn.BorderSizePixel = 0
        radioBtn.Text = "● " .. label
        radioBtn.TextColor3 = Colors.Text
        radioBtn.TextSize = 11
        radioBtn.Font = Enum.Font.GothamBold
        radioBtn.Parent = radioContainer
        round(radioBtn, 6)
        addGlowStroke(radioBtn, Colors.Primary, 1, 0.5)
        
        radioBtn.MouseButton1Click:Connect(function()
            -- Update all buttons
            for _, child in ipairs(radioContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = (child == radioBtn) and Colors.Primary or Colors.Card
                    child.BackgroundTransparency = (child == radioBtn) and 0.2 or 0.5
                end
            end
            
            -- Update config
            Config.TargetPart = TargetParts[i]
            selectedIndex = i
        end)
    end
    
    -- ============================================
    -- ESP CARD
    -- ============================================
    local espCard = Instance.new("Frame")
    espCard.Size = UDim2.new(0.9, 0, 0.35, 0)
    espCard.Position = UDim2.fromOffset(20, 420)
    espCard.BackgroundColor3 = Colors.Card
    espCard.BorderSizePixel = 0
    espCard.Parent = mainContent
    round(espCard, 12)
    addGlowStroke(espCard, Colors.Secondary, 2, 0.4)
    
    -- ESP Padding
    local espPadding = Instance.new("UIPadding")
    espPadding.PaddingLeft = UDim.new(0, 20)
    espPadding.PaddingRight = UDim.new(0, 20)
    espPadding.PaddingTop = UDim.new(0, 20)
    espPadding.PaddingBottom = UDim.new(0, 20)
    espPadding.Parent = espCard
    
    -- ESP Status
    local espStatusLabel = Instance.new("TextLabel")
    espStatusLabel.Size = UDim2.new(0.5, 0, 0.2, 0)
    espStatusLabel.BackgroundTransparency = 1
    espStatusLabel.Text = "Status:"
    espStatusLabel.TextColor3 = Colors.Muted
    espStatusLabel.TextSize = 14
    espStatusLabel.Font = Enum.Font.GothamBold
    espStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    espStatusLabel.Parent = espCard
    
    local espStatusValue = Instance.new("TextLabel")
    espStatusValue.Size = UDim2.new(0.5, 0, 0.2, 0)
    espStatusValue.Position = UDim2.fromScale(0.5, 0)
    espStatusValue.BackgroundTransparency = 1
    espStatusValue.Text = "🟢 ON"
    espStatusValue.TextColor3 = Colors.Success
    espStatusValue.TextSize = 14
    espStatusValue.Font = Enum.Font.GothamBold
    espStatusValue.TextXAlignment = Enum.TextXAlignment.Right
    espStatusValue.Parent = espCard
    
    -- ESP Toggle Button
    local espToggleBtn = Instance.new("TextButton")
    espToggleBtn.Size = UDim2.new(1, 0, 0.5, 0)
    espToggleBtn.Position = UDim2.fromOffset(0, 35)
    espToggleBtn.BackgroundColor3 = Colors.Success
    espToggleBtn.BackgroundTransparency = 0.2
    espToggleBtn.BorderSizePixel = 0
    espToggleBtn.Text = "TURN OFF"
    espToggleBtn.TextColor3 = Colors.Text
    espToggleBtn.TextSize = 14
    espToggleBtn.Font = Enum.Font.GothamBold
    espToggleBtn.Parent = espCard
    round(espToggleBtn, 8)
    addGlowStroke(espToggleBtn, Colors.Success, 2, 0.3)
    
    -- ============================================
    -- BUTTON EVENTS
    -- ============================================
    
    toggleBtn.MouseButton1Click:Connect(function()
        Config.AimLockEnabled = not Config.AimLockEnabled
        
        if Config.AimLockEnabled then
            toggleBtn.Text = "TURN OFF"
            toggleBtn.BackgroundColor3 = Colors.Success
            aimStatusValue.Text = "🟢 ON"
            aimStatusValue.TextColor3 = Colors.Success
            addGlowStroke(toggleBtn, Colors.Success, 2, 0.3)
        else
            toggleBtn.Text = "TURN ON"
            toggleBtn.BackgroundColor3 = Colors.Error
            aimStatusValue.Text = "🔴 OFF"
            aimStatusValue.TextColor3 = Colors.Error
            addGlowStroke(toggleBtn, Colors.Error, 2, 0.3)
        end
    end)
    
    espToggleBtn.MouseButton1Click:Connect(function()
        Config.ESPEnabled = not Config.ESPEnabled
        
        if Config.ESPEnabled then
            espToggleBtn.Text = "TURN OFF"
            espToggleBtn.BackgroundColor3 = Colors.Success
            espStatusValue.Text = "🟢 ON"
            espStatusValue.TextColor3 = Colors.Success
            addGlowStroke(espToggleBtn, Colors.Success, 2, 0.3)
        else
            espToggleBtn.Text = "TURN ON"
            espToggleBtn.BackgroundColor3 = Colors.Error
            espStatusValue.Text = "🔴 OFF"
            espStatusValue.TextColor3 = Colors.Error
            addGlowStroke(espToggleBtn, Colors.Error, 2, 0.3)
            
            -- Remove all ESP when disabled
            for player, _ in pairs(ESPObjects) do
                removeESP(player)
            end
        end
    end)
    
    return gui
end

-- ============================================
-- MAIN LOOP
-- ============================================

createSkyZenUI()

-- Keybind Events
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Config.AimKey then
        Config.AimLockEnabled = not Config.AimLockEnabled
        print(Config.AimLockEnabled and "✓ Aim Lock ON" or "✗ Aim Lock OFF")
    elseif input.KeyCode == Config.ESPKey then
        Config.ESPEnabled = not Config.ESPEnabled
        if not Config.ESPEnabled then
            for player, _ in pairs(ESPObjects) do
                removeESP(player)
            end
        end
        print(Config.ESPEnabled and "✓ ESP ON" or "✗ ESP OFF")
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

-- Player Events
Players.PlayerAdded:Connect(function(player)
    if Config.ESPEnabled then
        task.wait(0.5)
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

print("✅ SkyZen Arsenal Loaded!")
print("Press E to toggle Aim Lock")
print("Press R to toggle ESP")
print("Use GUI to select target part (Head, Body, Hand)")
