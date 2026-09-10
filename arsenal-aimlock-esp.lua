--[[
    ARSENAL AIM LOCK + ESP SCRIPT (SkyZen UI Style - Enhanced)
    ===========================================================
    Premium Cyberpunk GUI with Advanced Features
    Features:
    - Aim Lock with target part selection (Head, Body, Hand)
    - ESP toggle (ON/OFF)
    - Draggable UI
    - Resizable UI (drag from bottom-right corner)
    - Lock/Unlock UI
    - Toggle UI visibility
    - Premium SkyZen UI Design
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
    TargetPart = "Head",
    MaxDistance = 500,
    Smoothness = 0.1,
    AimKey = Enum.KeyCode.E,
    ESPKey = Enum.KeyCode.R,
    UIToggleKey = Enum.KeyCode.F,
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

-- UI Reference
local MainGUI = nil
local UILocked = false
local UIDragging = false
local UIResizing = false
local DragStart = nil
local ResizeStart = nil

-- SkyZen Color Palette
local Colors = {
    Primary = Color3.fromRGB(0, 170, 255),
    Secondary = Color3.fromRGB(80, 215, 255),
    Accent = Color3.fromRGB(138, 43, 226),
    Success = Color3.fromRGB(0, 255, 136),
    Error = Color3.fromRGB(255, 85, 105),
    Background = Color3.fromRGB(10, 15, 30),
    Card = Color3.fromRGB(15, 20, 40),
    Text = Color3.fromRGB(245, 248, 255),
    Muted = Color3.fromRGB(120, 140, 180),
    Border = Color3.fromRGB(0, 170, 255)
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
    
    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Size = Vector3.new(3, 5, 3)
    espBox.Color3 = Colors.Primary
    espBox.Transparency = 0.3
    espBox.AlwaysOnTop = true
    espBox.Parent = humanoidRootPart
    
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

local function clearAllESP()
    for player, _ in pairs(ESPObjects) do
        removeESP(player)
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
-- UI CREATION (Enhanced)
-- ============================================

local function createSkyZenUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "SkyZenArsenal"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui
    
    -- Main Container
    local container = Instance.new("Frame")
    container.Name = "MainContainer"
    container.Size = UDim2.fromOffset(700, 600)
    container.Position = UDim2.fromOffset(100, 100)
    container.BackgroundColor3 = Colors.Background
    container.BorderSizePixel = 0
    container.Parent = gui
    round(container, 15)
    addGlowStroke(container, Colors.Primary, 3, 0.4)
    
    -- ============================================
    -- HEADER
    -- ============================================
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.fromScale(1, 0.08)
    header.BackgroundColor3 = Colors.Background
    header.BorderSizePixel = 0
    header.Parent = container
    round(header, 15)
    
    addGlowStroke(header, Colors.Primary, 2, 0.5)
    
    -- Logo
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.fromOffset(200, 50)
    logo.Position = UDim2.fromOffset(20, 5)
    logo.BackgroundTransparency = 1
    logo.Text = "⚡ SKYZEN"
    logo.TextColor3 = Colors.Primary
    logo.TextSize = 22
    logo.Font = Enum.Font.GothamBlack
    logo.Parent = header
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.fromOffset(200, 20)
    subtitle.Position = UDim2.fromOffset(20, 27)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "ARSENAL SCRIPT HUB"
    subtitle.TextColor3 = Colors.Muted
    subtitle.TextSize = 9
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.Parent = header
    
    -- Status Dot
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.fromOffset(10, 10)
    statusDot.Position = UDim2.new(1, -180, 0.5, -5)
    statusDot.BackgroundColor3 = Colors.Success
    statusDot.BorderSizePixel = 0
    statusDot.Parent = header
    round(statusDot, 999)
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.fromOffset(50, 20)
    statusText.Position = UDim2.new(1, -165, 0.5, -10)
    statusText.BackgroundTransparency = 1
    statusText.Text = "● ONLINE"
    statusText.TextColor3 = Colors.Success
    statusText.TextSize = 10
    statusText.Font = Enum.Font.GothamBold
    statusText.Parent = header
    
    -- Lock Button
    local lockBtn = Instance.new("TextButton")
    lockBtn.Name = "LockButton"
    lockBtn.Size = UDim2.fromOffset(35, 35)
    lockBtn.Position = UDim2.new(1, -80, 0.5, -17.5)
    lockBtn.BackgroundColor3 = Colors.Primary
    lockBtn.BackgroundTransparency = 0.2
    lockBtn.BorderSizePixel = 0
    lockBtn.Text = "🔓"
    lockBtn.TextColor3 = Colors.Text
    lockBtn.TextSize = 16
    lockBtn.Font = Enum.Font.GothamBold
    lockBtn.Parent = header
    round(lockBtn, 6)
    addGlowStroke(lockBtn, Colors.Primary, 1.5, 0.5)
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.fromOffset(35, 35)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
    closeBtn.BackgroundColor3 = Colors.Error
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Colors.Text
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    round(closeBtn, 6)
    addGlowStroke(closeBtn, Colors.Error, 1.5, 0.5)
    
    -- ============================================
    -- CONTENT AREA
    -- ============================================
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, 0, 0.92, 0)
    contentArea.Position = UDim2.fromScale(0, 0.08)
    contentArea.BackgroundColor3 = Colors.Background
    contentArea.BorderSizePixel = 0
    contentArea.Parent = container
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 15)
    contentPadding.PaddingRight = UDim.new(0, 15)
    contentPadding.PaddingTop = UDim.new(0, 15)
    contentPadding.PaddingBottom = UDim.new(0, 15)
    contentPadding.Parent = contentArea
    
    -- Title
    local contentTitle = Instance.new("TextLabel")
    contentTitle.Size = UDim2.fromScale(1, 0.08)
    contentTitle.BackgroundTransparency = 1
    contentTitle.Text = "🎯 AIM LOCK SETTINGS"
    contentTitle.TextColor3 = Colors.Text
    contentTitle.TextSize = 20
    contentTitle.Font = Enum.Font.GothamBlack
    contentTitle.TextXAlignment = Enum.TextXAlignment.Left
    contentTitle.Parent = contentArea
    
    -- ============================================
    -- AIM LOCK CARD
    -- ============================================
    local aimCard = Instance.new("Frame")
    aimCard.Size = UDim2.new(1, 0, 0.4, 0)
    aimCard.Position = UDim2.fromOffset(0, 40)
    aimCard.BackgroundColor3 = Colors.Card
    aimCard.BorderSizePixel = 0
    aimCard.Parent = contentArea
    round(aimCard, 10)
    addGlowStroke(aimCard, Colors.Primary, 2, 0.4)
    
    local aimPadding = Instance.new("UIPadding")
    aimPadding.PaddingLeft = UDim.new(0, 15)
    aimPadding.PaddingRight = UDim.new(0, 15)
    aimPadding.PaddingTop = UDim.new(0, 15)
    aimPadding.PaddingBottom = UDim.new(0, 15)
    aimPadding.Parent = aimCard
    
    -- Aim Status
    local aimStatusLabel = Instance.new("TextLabel")
    aimStatusLabel.Size = UDim2.new(0.5, 0, 0.15, 0)
    aimStatusLabel.BackgroundTransparency = 1
    aimStatusLabel.Text = "Status:"
    aimStatusLabel.TextColor3 = Colors.Muted
    aimStatusLabel.TextSize = 12
    aimStatusLabel.Font = Enum.Font.GothamBold
    aimStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimStatusLabel.Parent = aimCard
    
    local aimStatusValue = Instance.new("TextLabel")
    aimStatusValue.Size = UDim2.new(0.5, 0, 0.15, 0)
    aimStatusValue.Position = UDim2.fromScale(0.5, 0)
    aimStatusValue.BackgroundTransparency = 1
    aimStatusValue.Text = "🔴 OFF"
    aimStatusValue.TextColor3 = Colors.Error
    aimStatusValue.TextSize = 12
    aimStatusValue.Font = Enum.Font.GothamBold
    aimStatusValue.TextXAlignment = Enum.TextXAlignment.Right
    aimStatusValue.Parent = aimCard
    
    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "AimToggle"
    toggleBtn.Size = UDim2.new(1, 0, 0.2, 0)
    toggleBtn.Position = UDim2.fromOffset(0, 25)
    toggleBtn.BackgroundColor3 = Colors.Error
    toggleBtn.BackgroundTransparency = 0.2
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "TURN ON"
    toggleBtn.TextColor3 = Colors.Text
    toggleBtn.TextSize = 13
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = aimCard
    round(toggleBtn, 6)
    addGlowStroke(toggleBtn, Colors.Error, 2, 0.3)
    
    -- Target Part Label
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, 0, 0.12, 0)
    targetLabel.Position = UDim2.fromOffset(0, 55)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Target Part:"
    targetLabel.TextColor3 = Colors.Muted
    targetLabel.TextSize = 11
    targetLabel.Font = Enum.Font.GothamBold
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = aimCard
    
    -- Radio Container
    local radioContainer = Instance.new("Frame")
    radioContainer.Size = UDim2.new(1, 0, 0.3, 0)
    radioContainer.Position = UDim2.fromOffset(0, 70)
    radioContainer.BackgroundTransparency = 1
    radioContainer.Parent = aimCard
    
    local radioLayout = Instance.new("UIListLayout")
    radioLayout.FillDirection = Enum.FillDirection.Horizontal
    radioLayout.Padding = UDim.new(0, 10)
    radioLayout.Parent = radioContainer
    
    local selectedIndex = 1
    
    for i, label in ipairs(TargetPartLabels) do
        local radioBtn = Instance.new("TextButton")
        radioBtn.Name = label
        radioBtn.Size = UDim2.new(0.32, 0, 1, 0)
        radioBtn.BackgroundColor3 = (i == selectedIndex) and Colors.Primary or Colors.Card
        radioBtn.BackgroundTransparency = (i == selectedIndex) and 0.2 or 0.5
        radioBtn.BorderSizePixel = 0
        radioBtn.Text = "● " .. label
        radioBtn.TextColor3 = Colors.Text
        radioBtn.TextSize = 10
        radioBtn.Font = Enum.Font.GothamBold
        radioBtn.Parent = radioContainer
        round(radioBtn, 5)
        addGlowStroke(radioBtn, Colors.Primary, 1, 0.5)
        
        radioBtn.MouseButton1Click:Connect(function()
            for _, child in ipairs(radioContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = (child == radioBtn) and Colors.Primary or Colors.Card
                    child.BackgroundTransparency = (child == radioBtn) and 0.2 or 0.5
                end
            end
            Config.TargetPart = TargetParts[i]
            selectedIndex = i
            print("✓ Target changed to: " .. TargetPartLabels[i])
        end)
    end
    
    -- ============================================
    -- ESP CARD
    -- ============================================
    local espCard = Instance.new("Frame")
    espCard.Name = "ESPCard"
    espCard.Size = UDim2.new(1, 0, 0.4, 0)
    espCard.Position = UDim2.fromOffset(0, 260)
    espCard.BackgroundColor3 = Colors.Card
    espCard.BorderSizePixel = 0
    espCard.Parent = contentArea
    round(espCard, 10)
    addGlowStroke(espCard, Colors.Secondary, 2, 0.4)
    
    local espPadding = Instance.new("UIPadding")
    espPadding.PaddingLeft = UDim.new(0, 15)
    espPadding.PaddingRight = UDim.new(0, 15)
    espPadding.PaddingTop = UDim.new(0, 15)
    espPadding.PaddingBottom = UDim.new(0, 15)
    espPadding.Parent = espCard
    
    -- ESP Status
    local espStatusLabel = Instance.new("TextLabel")
    espStatusLabel.Size = UDim2.new(0.5, 0, 0.15, 0)
    espStatusLabel.BackgroundTransparency = 1
    espStatusLabel.Text = "Status:"
    espStatusLabel.TextColor3 = Colors.Muted
    espStatusLabel.TextSize = 12
    espStatusLabel.Font = Enum.Font.GothamBold
    espStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    espStatusLabel.Parent = espCard
    
    local espStatusValue = Instance.new("TextLabel")
    espStatusValue.Size = UDim2.new(0.5, 0, 0.15, 0)
    espStatusValue.Position = UDim2.fromScale(0.5, 0)
    espStatusValue.BackgroundTransparency = 1
    espStatusValue.Text = "🟢 ON"
    espStatusValue.TextColor3 = Colors.Success
    espStatusValue.TextSize = 12
    espStatusValue.Font = Enum.Font.GothamBold
    espStatusValue.TextXAlignment = Enum.TextXAlignment.Right
    espStatusValue.Parent = espCard
    
    -- ESP Toggle Button
    local espToggleBtn = Instance.new("TextButton")
    espToggleBtn.Name = "ESPToggle"
    espToggleBtn.Size = UDim2.new(1, 0, 0.65, 0)
    espToggleBtn.Position = UDim2.fromOffset(0, 20)
    espToggleBtn.BackgroundColor3 = Colors.Success
    espToggleBtn.BackgroundTransparency = 0.2
    espToggleBtn.BorderSizePixel = 0
    espToggleBtn.Text = "TURN OFF"
    espToggleBtn.TextColor3 = Colors.Text
    espToggleBtn.TextSize = 13
    espToggleBtn.Font = Enum.Font.GothamBold
    espToggleBtn.Parent = espCard
    round(espToggleBtn, 6)
    addGlowStroke(espToggleBtn, Colors.Success, 2, 0.3)
    
    -- ============================================
    -- RESIZE HANDLE
    -- ============================================
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.fromOffset(30, 30)
    resizeHandle.Position = UDim2.new(1, -30, 1, -30)
    resizeHandle.BackgroundColor3 = Colors.Primary
    resizeHandle.BorderSizePixel = 0
    resizeHandle.Parent = container
    round(resizeHandle, 5)
    addGlowStroke(resizeHandle, Colors.Primary, 1.5, 0.5)
    
    local resizeIcon = Instance.new("TextLabel")
    resizeIcon.Size = UDim2.fromScale(1, 1)
    resizeIcon.BackgroundTransparency = 1
    resizeIcon.Text = "⧔"
    resizeIcon.TextColor3 = Colors.Text
    resizeIcon.TextSize = 18
    resizeIcon.Font = Enum.Font.GothamBold
    resizeIcon.Parent = resizeHandle
    
    -- ============================================
    -- BUTTON EVENTS
    -- ============================================
    
    toggleBtn.MouseButton1Click:Connect(function()
        if UILocked then return end
        Config.AimLockEnabled = not Config.AimLockEnabled
        
        if Config.AimLockEnabled then
            toggleBtn.Text = "TURN OFF"
            toggleBtn.BackgroundColor3 = Colors.Success
            aimStatusValue.Text = "🟢 ON"
            aimStatusValue.TextColor3 = Colors.Success
        else
            toggleBtn.Text = "TURN ON"
            toggleBtn.BackgroundColor3 = Colors.Error
            aimStatusValue.Text = "🔴 OFF"
            aimStatusValue.TextColor3 = Colors.Error
        end
        print("Aim Lock: " .. (Config.AimLockEnabled and "ON" or "OFF"))
    end)
    
    espToggleBtn.MouseButton1Click:Connect(function()
        if UILocked then return end
        Config.ESPEnabled = not Config.ESPEnabled
        
        if Config.ESPEnabled then
            espToggleBtn.Text = "TURN OFF"
            espToggleBtn.BackgroundColor3 = Colors.Success
            espStatusValue.Text = "🟢 ON"
            espStatusValue.TextColor3 = Colors.Success
        else
            espToggleBtn.Text = "TURN ON"
            espToggleBtn.BackgroundColor3 = Colors.Error
            espStatusValue.Text = "🔴 OFF"
            espStatusValue.TextColor3 = Colors.Error
            clearAllESP()
        end
        print("ESP: " .. (Config.ESPEnabled and "ON" or "OFF"))
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        MainGUI = nil
        print("✗ UI Ditutup")
    end)
    
    lockBtn.MouseButton1Click:Connect(function()
        UILocked = not UILocked
        lockBtn.Text = UILocked and "🔒" or "🔓"
        lockBtn.BackgroundColor3 = UILocked and Colors.Error or Colors.Primary
        print("UI " .. (UILocked and "LOCKED" or "UNLOCKED"))
    end)
    
    -- ============================================
    -- DRAG FUNCTIONALITY
    -- ============================================
    
    header.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or UILocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            UIDragging = true
            DragStart = UserInputService:GetMouseLocation()
            local containerPos = container.Position
            
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if UIDragging then
                    local currentMouse = UserInputService:GetMouseLocation()
                    local delta = currentMouse - DragStart
                    container.Position = UDim2.fromOffset(
                        containerPos.X.Offset + delta.X,
                        containerPos.Y.Offset + delta.Y
                    )
                else
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    header.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            UIDragging = false
        end
    end)
    
    -- ============================================
    -- RESIZE FUNCTIONALITY
    -- ============================================
    
    resizeHandle.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or UILocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            UIResizing = true
            ResizeStart = UserInputService:GetMouseLocation()
            local containerSize = container.Size
            
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if UIResizing then
                    local currentMouse = UserInputService:GetMouseLocation()
                    local delta = currentMouse - ResizeStart
                    
                    local newWidth = math.max(400, containerSize.X.Offset + delta.X)
                    local newHeight = math.max(300, containerSize.Y.Offset + delta.Y)
                    
                    container.Size = UDim2.fromOffset(newWidth, newHeight)
                else
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    resizeHandle.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            UIResizing = false
        end
    end)
    
    return gui
end

-- ============================================
-- SHOW/HIDE UI FUNCTION
-- ============================================

local function toggleUI()
    if MainGUI then
        MainGUI:Destroy()
        MainGUI = nil
        print("✗ UI Ditutup")
    else
        MainGUI = createSkyZenUI()
        print("✓ UI Dibuka")
    end
end

-- ============================================
-- MAIN LOOP
-- ============================================

MainGUI = createSkyZenUI()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Config.AimKey then
        Config.AimLockEnabled = not Config.AimLockEnabled
        print(Config.AimLockEnabled and "✓ Aim Lock ON" or "✗ Aim Lock OFF")
    elseif input.KeyCode == Config.ESPKey then
        Config.ESPEnabled = not Config.ESPEnabled
        if not Config.ESPEnabled then
            clearAllESP()
        end
        print(Config.ESPEnabled and "✓ ESP ON" or "✗ ESP OFF")
    elseif input.KeyCode == Config.UIToggleKey then
        toggleUI()
    end
end)

RunService.RenderStepped:Connect(function()
    updateESP()
end)

RunService.RenderStepped:Connect(function()
    if Config.AimLockEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        aimLock()
    end
end)

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
print("Press F to toggle UI")
print("🖱️ Drag UI by header")
print("📐 Resize UI from bottom-right corner")
print("🔒 Click lock button to lock/unlock UI")
