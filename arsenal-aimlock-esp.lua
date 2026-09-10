--[[
    ARSENAL AIM LOCK + ESP SCRIPT (SkyZen UI Style - Mobile Optimized)
    ==================================================================
    Premium Cyberpunk GUI with Floating Controls
    Features:
    - Aim Lock with target part selection (Head, Body, Hand)
    - ESP toggle (ON/OFF)
    - Draggable UI
    - Resizable UI (drag from bottom-right corner)
    - Floating Toggle Button (outside UI)
    - Floating Lock Button (outside UI)
    - Mobile optimized default size
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
local FloatingButtonsGUI = nil
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
-- FLOATING BUTTONS CREATION
-- ============================================

local function createFloatingButtons()
    local gui = Instance.new("ScreenGui")
    gui.Name = "FloatingButtons"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui
    
    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.fromOffset(60, 60)
    toggleBtn.Position = UDim2.fromOffset(20, 20)
    toggleBtn.BackgroundColor3 = Colors.Primary
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "⊞"
    toggleBtn.TextColor3 = Colors.Text
    toggleBtn.TextSize = 28
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = gui
    round(toggleBtn, 12)
    addGlowStroke(toggleBtn, Colors.Primary, 2, 0.4)
    
    -- Lock Button
    local lockBtn = Instance.new("TextButton")
    lockBtn.Name = "LockButton"
    lockBtn.Size = UDim2.fromOffset(60, 60)
    lockBtn.Position = UDim2.fromOffset(20, 90)
    lockBtn.BackgroundColor3 = Colors.Primary
    lockBtn.BorderSizePixel = 0
    lockBtn.Text = "🔓"
    lockBtn.TextColor3 = Colors.Text
    lockBtn.TextSize = 24
    lockBtn.Font = Enum.Font.GothamBold
    lockBtn.Parent = gui
    round(lockBtn, 12)
    addGlowStroke(lockBtn, Colors.Primary, 2, 0.4)
    
    -- Draggable for floating buttons
    local buttonsDragging = false
    local buttonsStartPos = nil
    
    toggleBtn.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            buttonsDragging = true
            buttonsStartPos = UserInputService:GetMouseLocation()
            local startTogglePos = toggleBtn.Position
            local startLockPos = lockBtn.Position
            
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if buttonsDragging then
                    local currentMouse = UserInputService:GetMouseLocation()
                    local delta = currentMouse - buttonsStartPos
                    toggleBtn.Position = UDim2.fromOffset(
                        startTogglePos.X.Offset + delta.X,
                        startTogglePos.Y.Offset + delta.Y
                    )
                    lockBtn.Position = UDim2.fromOffset(
                        startLockPos.X.Offset + delta.X,
                        startLockPos.Y.Offset + delta.Y
                    )
                else
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            buttonsDragging = false
        end
    end)
    
    return gui, toggleBtn, lockBtn
end

-- ============================================
-- MAIN UI CREATION (Mobile Optimized)
-- ============================================

local function createSkyZenUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "SkyZenArsenal"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui
    
    -- Main Container (Mobile optimized size: 500x550)
    local container = Instance.new("Frame")
    container.Name = "MainContainer"
    container.Size = UDim2.fromOffset(500, 550)
    container.Position = UDim2.fromOffset(200, 75)
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
    logo.Size = UDim2.fromOffset(150, 40)
    logo.Position = UDim2.fromOffset(15, 5)
    logo.BackgroundTransparency = 1
    logo.Text = "⚡ SKYZEN"
    logo.TextColor3 = Colors.Primary
    logo.TextSize = 18
    logo.Font = Enum.Font.GothamBlack
    logo.Parent = header
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.fromOffset(150, 15)
    subtitle.Position = UDim2.fromOffset(15, 24)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "ARSENAL HUB"
    subtitle.TextColor3 = Colors.Muted
    subtitle.TextSize = 8
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.Parent = header
    
    -- Status
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.fromOffset(8, 8)
    statusDot.Position = UDim2.new(1, -110, 0.5, -4)
    statusDot.BackgroundColor3 = Colors.Success
    statusDot.BorderSizePixel = 0
    statusDot.Parent = header
    round(statusDot, 999)
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.fromOffset(40, 16)
    statusText.Position = UDim2.new(1, -100, 0.5, -8)
    statusText.BackgroundTransparency = 1
    statusText.Text = "● ON"
    statusText.TextColor3 = Colors.Success
    statusText.TextSize = 9
    statusText.Font = Enum.Font.GothamBold
    statusText.Parent = header
    
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
    contentPadding.PaddingLeft = UDim.new(0, 12)
    contentPadding.PaddingRight = UDim.new(0, 12)
    contentPadding.PaddingTop = UDim.new(0, 12)
    contentPadding.PaddingBottom = UDim.new(0, 12)
    contentPadding.Parent = contentArea
    
    -- Title
    local contentTitle = Instance.new("TextLabel")
    contentTitle.Size = UDim2.fromScale(1, 0.08)
    contentTitle.BackgroundTransparency = 1
    contentTitle.Text = "🎯 AIM LOCK"
    contentTitle.TextColor3 = Colors.Text
    contentTitle.TextSize = 16
    contentTitle.Font = Enum.Font.GothamBlack
    contentTitle.TextXAlignment = Enum.TextXAlignment.Left
    contentTitle.Parent = contentArea
    
    -- ============================================
    -- AIM LOCK CARD
    -- ============================================
    local aimCard = Instance.new("Frame")
    aimCard.Size = UDim2.new(1, 0, 0.38, 0)
    aimCard.Position = UDim2.fromOffset(0, 32)
    aimCard.BackgroundColor3 = Colors.Card
    aimCard.BorderSizePixel = 0
    aimCard.Parent = contentArea
    round(aimCard, 10)
    addGlowStroke(aimCard, Colors.Primary, 2, 0.4)
    
    local aimPadding = Instance.new("UIPadding")
    aimPadding.PaddingLeft = UDim.new(0, 12)
    aimPadding.PaddingRight = UDim.new(0, 12)
    aimPadding.PaddingTop = UDim.new(0, 12)
    aimPadding.PaddingBottom = UDim.new(0, 12)
    aimPadding.Parent = aimCard
    
    -- Aim Status
    local aimStatusLabel = Instance.new("TextLabel")
    aimStatusLabel.Size = UDim2.new(0.5, 0, 0.15, 0)
    aimStatusLabel.BackgroundTransparency = 1
    aimStatusLabel.Text = "Status:"
    aimStatusLabel.TextColor3 = Colors.Muted
    aimStatusLabel.TextSize = 11
    aimStatusLabel.Font = Enum.Font.GothamBold
    aimStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimStatusLabel.Parent = aimCard
    
    local aimStatusValue = Instance.new("TextLabel")
    aimStatusValue.Size = UDim2.new(0.5, 0, 0.15, 0)
    aimStatusValue.Position = UDim2.fromScale(0.5, 0)
    aimStatusValue.BackgroundTransparency = 1
    aimStatusValue.Text = "🔴 OFF"
    aimStatusValue.TextColor3 = Colors.Error
    aimStatusValue.TextSize = 11
    aimStatusValue.Font = Enum.Font.GothamBold
    aimStatusValue.TextXAlignment = Enum.TextXAlignment.Right
    aimStatusValue.Parent = aimCard
    
    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "AimToggle"
    toggleBtn.Size = UDim2.new(1, 0, 0.22, 0)
    toggleBtn.Position = UDim2.fromOffset(0, 20)
    toggleBtn.BackgroundColor3 = Colors.Error
    toggleBtn.BackgroundTransparency = 0.2
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "TURN ON"
    toggleBtn.TextColor3 = Colors.Text
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = aimCard
    round(toggleBtn, 6)
    addGlowStroke(toggleBtn, Colors.Error, 2, 0.3)
    
    -- Target Part Label
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, 0, 0.12, 0)
    targetLabel.Position = UDim2.fromOffset(0, 52)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Target:"
    targetLabel.TextColor3 = Colors.Muted
    targetLabel.TextSize = 10
    targetLabel.Font = Enum.Font.GothamBold
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = aimCard
    
    -- Radio Container
    local radioContainer = Instance.new("Frame")
    radioContainer.Size = UDim2.new(1, 0, 0.35, 0)
    radioContainer.Position = UDim2.fromOffset(0, 65)
    radioContainer.BackgroundTransparency = 1
    radioContainer.Parent = aimCard
    
    local radioLayout = Instance.new("UIListLayout")
    radioLayout.FillDirection = Enum.FillDirection.Horizontal
    radioLayout.Padding = UDim.new(0, 8)
    radioLayout.Parent = radioContainer
    
    local selectedIndex = 1
    
    for i, label in ipairs(TargetPartLabels) do
        local radioBtn = Instance.new("TextButton")
        radioBtn.Name = label
        radioBtn.Size = UDim2.new(0.31, 0, 1, 0)
        radioBtn.BackgroundColor3 = (i == selectedIndex) and Colors.Primary or Colors.Card
        radioBtn.BackgroundTransparency = (i == selectedIndex) and 0.2 or 0.5
        radioBtn.BorderSizePixel = 0
        radioBtn.Text = "● " .. label
        radioBtn.TextColor3 = Colors.Text
        radioBtn.TextSize = 9
        radioBtn.Font = Enum.Font.GothamBold
        radioBtn.Parent = radioContainer
        round(radioBtn, 5)
        addGlowStroke(radioBtn, Colors.Primary, 1, 0.5)
        
        radioBtn.MouseButton1Click:Connect(function()
            if UILocked then return end
            for _, child in ipairs(radioContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = (child == radioBtn) and Colors.Primary or Colors.Card
                    child.BackgroundTransparency = (child == radioBtn) and 0.2 or 0.5
                end
            end
            Config.TargetPart = TargetParts[i]
            selectedIndex = i
            print("✓ Target: " .. TargetPartLabels[i])
        end)
    end
    
    -- ============================================
    -- ESP CARD
    -- ============================================
    local espCard = Instance.new("Frame")
    espCard.Name = "ESPCard"
    espCard.Size = UDim2.new(1, 0, 0.38, 0)
    espCard.Position = UDim2.fromOffset(0, 280)
    espCard.BackgroundColor3 = Colors.Card
    espCard.BorderSizePixel = 0
    espCard.Parent = contentArea
    round(espCard, 10)
    addGlowStroke(espCard, Colors.Secondary, 2, 0.4)
    
    local espPadding = Instance.new("UIPadding")
    espPadding.PaddingLeft = UDim.new(0, 12)
    espPadding.PaddingRight = UDim.new(0, 12)
    espPadding.PaddingTop = UDim.new(0, 12)
    espPadding.PaddingBottom = UDim.new(0, 12)
    espPadding.Parent = espCard
    
    -- ESP Title
    local espTitle = Instance.new("TextLabel")
    espTitle.Size = UDim2.new(1, 0, 0.1, 0)
    espTitle.BackgroundTransparency = 1
    espTitle.Text = "👁️ ESP"
    espTitle.TextColor3 = Colors.Secondary
    espTitle.TextSize = 14
    espTitle.Font = Enum.Font.GothamBlack
    espTitle.TextXAlignment = Enum.TextXAlignment.Left
    espTitle.Parent = espCard
    
    -- ESP Status
    local espStatusLabel = Instance.new("TextLabel")
    espStatusLabel.Size = UDim2.new(0.5, 0, 0.15, 0)
    espStatusLabel.Position = UDim2.fromOffset(0, 20)
    espStatusLabel.BackgroundTransparency = 1
    espStatusLabel.Text = "Status:"
    espStatusLabel.TextColor3 = Colors.Muted
    espStatusLabel.TextSize = 11
    espStatusLabel.Font = Enum.Font.GothamBold
    espStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    espStatusLabel.Parent = espCard
    
    local espStatusValue = Instance.new("TextLabel")
    espStatusValue.Size = UDim2.new(0.5, 0, 0.15, 0)
    espStatusValue.Position = UDim2.fromScale(0.5, 0.12)
    espStatusValue.BackgroundTransparency = 1
    espStatusValue.Text = "🟢 ON"
    espStatusValue.TextColor3 = Colors.Success
    espStatusValue.TextSize = 11
    espStatusValue.Font = Enum.Font.GothamBold
    espStatusValue.TextXAlignment = Enum.TextXAlignment.Right
    espStatusValue.Parent = espCard
    
    -- ESP Toggle Button
    local espToggleBtn = Instance.new("TextButton")
    espToggleBtn.Name = "ESPToggle"
    espToggleBtn.Size = UDim2.new(1, 0, 0.55, 0)
    espToggleBtn.Position = UDim2.fromOffset(0, 40)
    espToggleBtn.BackgroundColor3 = Colors.Success
    espToggleBtn.BackgroundTransparency = 0.2
    espToggleBtn.BorderSizePixel = 0
    espToggleBtn.Text = "TURN OFF"
    espToggleBtn.TextColor3 = Colors.Text
    espToggleBtn.TextSize = 12
    espToggleBtn.Font = Enum.Font.GothamBold
    espToggleBtn.Parent = espCard
    round(espToggleBtn, 6)
    addGlowStroke(espToggleBtn, Colors.Success, 2, 0.3)
    
    -- ============================================
    -- RESIZE HANDLE
    -- ============================================
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.fromOffset(25, 25)
    resizeHandle.Position = UDim2.new(1, -25, 1, -25)
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
    resizeIcon.TextSize = 14
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
                    
                    local newWidth = math.max(350, containerSize.X.Offset + delta.X)
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
-- TOGGLE UI FUNCTION
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

-- Create Floating Buttons
FloatingButtonsGUI, local floatingToggle, local floatingLock = createFloatingButtons()

-- Create Main UI
MainGUI = createSkyZenUI()

-- Floating Toggle Button Event
floatingToggle.MouseButton1Click:Connect(function()
    toggleUI()
end)

-- Floating Lock Button Event
floatingLock.MouseButton1Click:Connect(function()
    UILocked = not UILocked
    floatingLock.Text = UILocked and "🔒" or "🔓"
    floatingLock.BackgroundColor3 = UILocked and Colors.Error or Colors.Primary
    print("UI " .. (UILocked and "LOCKED ✓" or "UNLOCKED ✓"))
end)

-- Keyboard Shortcuts
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

-- ESP Loop
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
print("📍 Floating Buttons: Top-Left Corner")
print("⊞ = Toggle UI")
print("🔓 = Lock/Unlock UI")
print("🖱️ Drag UI by header")
print("📐 Resize from bottom-right")
print("Keyboard: E=Aim, R=ESP, F=Toggle")
