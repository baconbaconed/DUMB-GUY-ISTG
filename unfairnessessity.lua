--[[
before any judging, this is a actual testing tool i use for testing games, anticheats, anti velocity, stuff like that, its never used as a exploiting tool, EVER, source is given to the game owners if this bypasses anticheats
  

  1. GUI allows selecting target player[or via the friggin keybinds you weirdo]
    2. When enabled, uses sethiddenproperty to set PhysicsRepRootPart [absolutely]
    3. Creates a weld to follow the target with 0 delay [via replication overclocking and heartbeat spamming]
    4. Target's physics become synced with exploiter, this is needed to replicate the physic manipulation effect so it drags the enemy away[yuppp]
    5. All hits register due to physics manipulation[due to the weld]
    6. testy testy timeee, yayy
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local originalParts = {}
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local connections = {}

-- ============================================================================
-- SETTINGS MANAGEMENT
-- ============================================================================

local SETTINGS_FILE = "Gokuware_Settings.json"
local settings = {
    dominance = 25, -- Dominance Meter (0-100)
    dragMagnitude = 50,
    dragEnabled = false,
    selectKey = "H",
    fireKey = "N",
    dashKey = "Q",
    espEnabled = true,
    burstKey = "V",
    burstMultiplier = 2,
    orbitEnabled = false,
    orbitSpeed = 30,
    teleportKey = "X",
    minimized = false,
    windowSize = {x = 300, y = 700}, -- Store custom window size
    springEnabled = false,
    springDamping = 0.5,
    recoilEnabled = false,
    stateLockdown = 0 -- 0: None, 1: Mid, 2: Dominant
}

local function saveSettings()
    if writefile then
        pcall(function()
            local saveData = {}
            for k, v in pairs(settings) do
                if k ~= "minimized" then
                    saveData[k] = v
                end
            end
            writefile(SETTINGS_FILE, HttpService:JSONEncode(saveData))
        end)
    end
end

local function loadSettings()
    if readfile and isfile and isfile(SETTINGS_FILE) then
        pcall(function()
            local loaded = HttpService:JSONDecode(readfile(SETTINGS_FILE))
            for k, v in pairs(loaded) do
                settings[k] = v
            end
        end)
    end
end

loadSettings()

-- ============================================================================
-- GUI CREATION
-- ============================================================================

local function createGui()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PhysicsDesyncGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = settings.minimized and UDim2.new(0, settings.windowSize.x, 0, 35) or UDim2.new(0, settings.windowSize.x, 0, settings.windowSize.y)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = false
    MainFrame.Parent = ScreenGui
    
    -- Resize Handle
    local ResizeHandle = Instance.new("Frame")
    ResizeHandle.Name = "ResizeHandle"
    ResizeHandle.Size = UDim2.new(0, 15, 0, 15)
    ResizeHandle.Position = UDim2.new(1, -15, 1, -15)
    ResizeHandle.BackgroundColor3 = Color3.fromRGB(255, 0, 10)
    ResizeHandle.BorderSizePixel = 0
    ResizeHandle.Parent = MainFrame
    
    local ResizeCorner = Instance.new("UICorner")
    ResizeCorner.CornerRadius = UDim.new(0, 3)
    ResizeCorner.Parent = ResizeHandle
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    TitleBar.BorderSizePixel = 0
    TitleBar.Active = true
    TitleBar.Parent = MainFrame
    
    -- Removed TitleBar input handlers - using custom drag system instead
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -70, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "unfairnessessity"
    Title.TextColor3 = Color3.fromRGB(255, 0, 20) -- Sleek red
    Title.TextSize = 20
    Title.Font = Enum.Font.Ubuntu
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Parent = TitleBar
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Position = UDim2.new(1, -65, 0, 5)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MinimizeButton.Text = settings.minimized and "+" or "-"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 18
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Parent = TitleBar
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 6)
    MinCorner.Parent = MinimizeButton
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    -- Content Frame (now a ScrollingFrame)
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, 0, 1, -35)
    ContentFrame.Position = UDim2.new(0, 0, 0, 35)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Visible = not settings.minimized
    ContentFrame.ScrollBarThickness = 3
    ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 180)
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 1500)
    ContentFrame.Parent = MainFrame
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 10)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Parent = ContentFrame
    
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = UDim.new(0, 10)
    UIPadding.Parent = ContentFrame
    
    -- Search Filter
    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "SearchFrame"
    SearchFrame.Size = UDim2.new(0.9, 0, 0, 30)
    SearchFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SearchFrame.BorderSizePixel = 0
    SearchFrame.LayoutOrder = 0.5
    SearchFrame.Parent = ContentFrame
    
    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchFrame
    
    local SearchInput = Instance.new("TextBox")
    SearchInput.Name = "SearchInput"
    SearchInput.Size = UDim2.new(1, -10, 1, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Text = ""
    SearchInput.PlaceholderText = "Search Player..."
    SearchInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    SearchInput.TextSize = 13
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.Parent = SearchFrame

    -- Player Dropdown
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = "DropdownFrame"
    DropdownFrame.Size = UDim2.new(0.9, 0, 0, 35)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.LayoutOrder = 1
    DropdownFrame.Parent = ContentFrame
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 6)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Name = "DropdownButton"
    DropdownButton.Size = UDim2.new(1, 0, 1, 0)
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Text = "Select Player"
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.TextSize = 14
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.Parent = DropdownFrame
    
    -- Dropdown List
    local DropdownList = Instance.new("ScrollingFrame")
    DropdownList.Name = "DropdownList"
    DropdownList.Size = UDim2.new(0.9, 0, 0, 100)
    DropdownList.Position = UDim2.new(0.05, 0, 0, 45)
    DropdownList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    DropdownList.BorderSizePixel = 0
    DropdownList.Visible = false
    DropdownList.ScrollBarThickness = 2
    DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
    DropdownList.ZIndex = 10
    DropdownList.Parent = ContentFrame
    
    local DropdownListCorner = Instance.new("UICorner")
    DropdownListCorner.CornerRadius = UDim.new(0, 6)
    DropdownListCorner.Parent = DropdownList
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.Name
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.Parent = DropdownList
    
    -- Drag Toggle
    local DragToggleFrame = Instance.new("Frame")
    DragToggleFrame.Name = "DragToggleFrame"
    DragToggleFrame.Size = UDim2.new(0.9, 0, 0, 30)
    DragToggleFrame.BackgroundTransparency = 1
    DragToggleFrame.LayoutOrder = 2
    DragToggleFrame.Parent = ContentFrame
    
    local DragLabel = Instance.new("TextLabel")
    DragLabel.Size = UDim2.new(0.7, 0, 1, 0)
    DragLabel.BackgroundTransparency = 1
    DragLabel.Text = "Drag Effect"
    DragLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    DragLabel.TextSize = 13
    DragLabel.Font = Enum.Font.Gotham
    DragLabel.TextXAlignment = Enum.TextXAlignment.Left
    DragLabel.Parent = DragToggleFrame
    
    local DragToggleButton = Instance.new("TextButton")
    DragToggleButton.Name = "DragToggleButton"
    DragToggleButton.Size = UDim2.new(0, 50, 0, 22)
    DragToggleButton.Position = UDim2.new(1, -50, 0.5, -11)
    DragToggleButton.BackgroundColor3 = settings.dragEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    DragToggleButton.Text = settings.dragEnabled and "ON" or "OFF"
    DragToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DragToggleButton.TextSize = 11
    DragToggleButton.Font = Enum.Font.GothamBold
    DragToggleButton.Parent = DragToggleFrame
    
    local DragToggleCorner = Instance.new("UICorner")
    DragToggleCorner.CornerRadius = UDim.new(0, 6)
    DragToggleCorner.Parent = DragToggleButton
    
    -- Velocity Slider
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "SliderFrame"
    SliderFrame.Size = UDim2.new(0.9, 0, 0, 45)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.LayoutOrder = 3
    SliderFrame.Parent = ContentFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(0.6, 0, 0, 20)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = "Drag Magnitude:"
    SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SliderLabel.TextSize = 11
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderInput = Instance.new("TextBox")
    SliderInput.Name = "SliderInput"
    SliderInput.Size = UDim2.new(0, 45, 0, 18)
    SliderInput.Position = UDim2.new(1, -45, 0, 0)
    SliderInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SliderInput.Text = tostring(settings.dragMagnitude)
    SliderInput.TextColor3 = Color3.fromRGB(0, 255, 180)
    SliderInput.TextSize = 11
    SliderInput.Font = Enum.Font.GothamBold
    SliderInput.ClearTextOnFocus = false
    SliderInput.TextEditable = false
    SliderInput.Parent = SliderFrame
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 4)
    InputCorner.Parent = SliderInput
    
    local SliderBackground = Instance.new("Frame")
    SliderBackground.Name = "SliderBackground"
    SliderBackground.Size = UDim2.new(1, 0, 0, 4)
    SliderBackground.Position = UDim2.new(0, 0, 0, 28)
    SliderBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SliderBackground.BorderSizePixel = 0
    SliderBackground.Parent = SliderFrame
    
    local initialPos = settings.dragMagnitude / 1000
    local SliderBar = Instance.new("Frame")
    SliderBar.Name = "SliderBar"
    SliderBar.Size = UDim2.new(initialPos, 0, 1, 0)
    SliderBar.BackgroundColor3 = Color3.fromRGB(255, 9, 9) -- Aquamarine
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderBackground
    
    local SliderDot = Instance.new("TextButton")
    SliderDot.Name = "SliderDot"
    SliderDot.Size = UDim2.new(0, 14, 0, 14)
    SliderDot.Position = UDim2.new(initialPos, -7, 0.5, -7)
    SliderDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderDot.Text = ""
    SliderDot.Selectable = false
    SliderDot.Parent = SliderBackground
    
    local SliderDotCorner = Instance.new("UICorner")
    SliderDotCorner.CornerRadius = UDim.new(0, 8)
    SliderDotCorner.Parent = SliderDot
    
    -- Dominance Meter
    local DomFrame = Instance.new("Frame")
    DomFrame.Name = "DomFrame"
    DomFrame.Size = UDim2.new(0.9, 0, 0, 60)
    DomFrame.BackgroundTransparency = 1
    DomFrame.LayoutOrder = 3.5
    DomFrame.Parent = ContentFrame
    
    local DomLabel = Instance.new("TextLabel")
    DomLabel.Size = UDim2.new(1, 0, 0, 20)
    DomLabel.BackgroundTransparency = 1
    DomLabel.Text = "Dominance Meter (0-100%):"
    DomLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    DomLabel.TextSize = 11
    DomLabel.Font = Enum.Font.Gotham
    DomLabel.TextXAlignment = Enum.TextXAlignment.Left
    DomLabel.Parent = DomFrame
    
    local DomStageLabel = Instance.new("TextLabel")
    DomStageLabel.Size = UDim2.new(1, 0, 0, 20)
    DomStageLabel.Position = UDim2.new(0, 0, 0, 40)
    DomStageLabel.BackgroundTransparency = 1
    DomStageLabel.Text = "Stage: Annoyance"
    DomStageLabel.TextColor3 = Color3.fromRGB(0, 255, 180)
    DomStageLabel.TextSize = 10
    DomStageLabel.Font = Enum.Font.GothamBold
    DomStageLabel.Parent = DomFrame

    local DomBackground = Instance.new("Frame")
    DomBackground.Size = UDim2.new(1, 0, 0, 6)
    DomBackground.Position = UDim2.new(0, 0, 0, 30)
    DomBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    DomBackground.Parent = DomFrame
    
    local initialDomPos = settings.dominance / 100
    local DomBar = Instance.new("Frame")
    DomBar.Size = UDim2.new(initialDomPos, 0, 1, 0)
    DomBar.BackgroundColor3 = Color3.fromRGB(255, 9, 9)
    DomBar.Parent = DomBackground
    
    local DomDot = Instance.new("TextButton")
    DomDot.Size = UDim2.new(0, 14, 0, 14)
    DomDot.Position = UDim2.new(initialDomPos, -7, 0.5, -7)
    DomDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DomDot.Text = ""
    DomDot.Parent = DomBackground
    
    local DomDotCorner = Instance.new("UICorner")
    DomDotCorner.CornerRadius = UDim.new(0, 8)
    DomDotCorner.Parent = DomDot

    -- Keybinds Frame
    local KeybindsFrame = Instance.new("Frame")
    KeybindsFrame.Name = "KeybindsFrame"
    KeybindsFrame.Size = UDim2.new(0.9, 0, 0, 105)
    KeybindsFrame.BackgroundTransparency = 1
    KeybindsFrame.LayoutOrder = 4
    KeybindsFrame.Parent = ContentFrame
    
    local SelectBindFrame = Instance.new("Frame")
    SelectBindFrame.Size = UDim2.new(1, 0, 0, 30)
    SelectBindFrame.BackgroundTransparency = 1
    SelectBindFrame.Parent = KeybindsFrame
    
    local SelectBindLabel = Instance.new("TextLabel")
    SelectBindLabel.Size = UDim2.new(0.6, 0, 1, 0)
    SelectBindLabel.BackgroundTransparency = 1
    SelectBindLabel.Text = "Select Key:"
    SelectBindLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SelectBindLabel.TextSize = 13
    SelectBindLabel.Font = Enum.Font.Gotham
    SelectBindLabel.TextXAlignment = Enum.TextXAlignment.Left
    SelectBindLabel.Parent = SelectBindFrame
    
    local SelectBindButton = Instance.new("TextButton")
    SelectBindButton.Size = UDim2.new(0, 60, 0, 22)
    SelectBindButton.Position = UDim2.new(1, -60, 0.5, -11)
    SelectBindButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SelectBindButton.Text = settings.selectKey
    SelectBindButton.TextColor3 = Color3.fromRGB(0, 255, 180)
    SelectBindButton.TextSize = 11
    SelectBindButton.Font = Enum.Font.GothamBold
    SelectBindButton.Parent = SelectBindFrame
    
    local SelectBindCorner = Instance.new("UICorner")
    SelectBindCorner.CornerRadius = UDim.new(0, 6)
    SelectBindCorner.Parent = SelectBindButton
    
    local FireBindFrame = Instance.new("Frame")
    FireBindFrame.Size = UDim2.new(1, 0, 0, 30)
    FireBindFrame.Position = UDim2.new(0, 0, 0, 35)
    FireBindFrame.BackgroundTransparency = 1
    FireBindFrame.Parent = KeybindsFrame
    
    local FireBindLabel = Instance.new("TextLabel")
    FireBindLabel.Size = UDim2.new(0.6, 0, 1, 0)
    FireBindLabel.BackgroundTransparency = 1
    FireBindLabel.Text = "Fire Key:"
    FireBindLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    FireBindLabel.TextSize = 13
    FireBindLabel.Font = Enum.Font.Gotham
    FireBindLabel.TextXAlignment = Enum.TextXAlignment.Left
    FireBindLabel.Parent = FireBindFrame
    
    local FireBindButton = Instance.new("TextButton")
    FireBindButton.Size = UDim2.new(0, 60, 0, 22)
    FireBindButton.Position = UDim2.new(1, -60, 0.5, -11)
    FireBindButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    FireBindButton.Text = settings.fireKey
    FireBindButton.TextColor3 = Color3.fromRGB(0, 255, 180)
    FireBindButton.TextSize = 11
    FireBindButton.Font = Enum.Font.GothamBold
    FireBindButton.Parent = FireBindFrame
    
    local FireBindCorner = Instance.new("UICorner")
    FireBindCorner.CornerRadius = UDim.new(0, 6)
    FireBindCorner.Parent = FireBindButton

    local DashBindFrame = Instance.new("Frame")
    DashBindFrame.Size = UDim2.new(1, 0, 0, 30)
    DashBindFrame.Position = UDim2.new(0, 0, 0, 70)
    DashBindFrame.BackgroundTransparency = 1
    DashBindFrame.Parent = KeybindsFrame
    
    local DashBindLabel = Instance.new("TextLabel")
    DashBindLabel.Size = UDim2.new(0.6, 0, 1, 0)
    DashBindLabel.BackgroundTransparency = 1
    DashBindLabel.Text = "Dash Key:"
    DashBindLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    DashBindLabel.TextSize = 13
    DashBindLabel.Font = Enum.Font.Gotham
    DashBindLabel.TextXAlignment = Enum.TextXAlignment.Left
    DashBindLabel.Parent = DashBindFrame
    
    local DashBindButton = Instance.new("TextButton")
    DashBindButton.Size = UDim2.new(0, 60, 0, 22)
    DashBindButton.Position = UDim2.new(1, -60, 0.5, -11)
    DashBindButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DashBindButton.Text = settings.dashKey
    DashBindButton.TextColor3 = Color3.fromRGB(0, 255, 180)
    DashBindButton.TextSize = 11
    DashBindButton.Font = Enum.Font.GothamBold
    DashBindButton.Parent = DashBindFrame
    
    local DashBindCorner = Instance.new("UICorner")
    DashBindCorner.CornerRadius = UDim.new(0, 6)
    DashBindCorner.Parent = DashBindButton

    -- Burst/Orbit/Teleport Frame
    local BurstOrbitFrame = Instance.new("Frame")
    BurstOrbitFrame.Name = "BurstOrbitFrame"
    BurstOrbitFrame.Size = UDim2.new(0.9, 0, 0, 245) -- Increased size from 175
    BurstOrbitFrame.BackgroundTransparency = 1
    BurstOrbitFrame.LayoutOrder = 4.5
    BurstOrbitFrame.Parent = ContentFrame
    
    local BurstBindFrame = Instance.new("Frame")
    BurstBindFrame.Size = UDim2.new(1, 0, 0, 30)
    BurstBindFrame.BackgroundTransparency = 1
    BurstBindFrame.Parent = BurstOrbitFrame
    
    local BurstBindLabel = Instance.new("TextLabel")
    BurstBindLabel.Size = UDim2.new(0.6, 0, 1, 0)
    BurstBindLabel.BackgroundTransparency = 1
    BurstBindLabel.Text = "Burst Key:"
    BurstBindLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    BurstBindLabel.TextSize = 13
    BurstBindLabel.Font = Enum.Font.Gotham
    BurstBindLabel.TextXAlignment = Enum.TextXAlignment.Left
    BurstBindLabel.Parent = BurstBindFrame
    
    local BurstBindButton = Instance.new("TextButton")
    BurstBindButton.Size = UDim2.new(0, 60, 0, 22)
    BurstBindButton.Position = UDim2.new(1, -60, 0.5, -11)
    BurstBindButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    BurstBindButton.Text = settings.burstKey
    BurstBindButton.TextColor3 = Color3.fromRGB(0, 255, 180)
    BurstBindButton.TextSize = 11
    BurstBindButton.Font = Enum.Font.GothamBold
    BurstBindButton.Parent = BurstBindFrame
    
    local BurstBindCorner = Instance.new("UICorner")
    BurstBindCorner.CornerRadius = UDim.new(0, 6)
    BurstBindCorner.Parent = BurstBindButton
    
    local BurstMultiplierFrame = Instance.new("Frame")
    BurstMultiplierFrame.Size = UDim2.new(1, 0, 0, 40)
    BurstMultiplierFrame.Position = UDim2.new(0, 0, 0, 35)
    BurstMultiplierFrame.BackgroundTransparency = 1
    BurstMultiplierFrame.Parent = BurstOrbitFrame
    
    local BurstMultLabel = Instance.new("TextLabel")
    BurstMultLabel.Size = UDim2.new(0.6, 0, 0, 20)
    BurstMultLabel.BackgroundTransparency = 1
    BurstMultLabel.Text = "Burst Mult:"
    BurstMultLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    BurstMultLabel.TextSize = 11
    BurstMultLabel.Font = Enum.Font.Gotham
    BurstMultLabel.TextXAlignment = Enum.TextXAlignment.Left
    BurstMultLabel.Parent = BurstMultiplierFrame
    
    local BurstMultInput = Instance.new("TextBox")
    BurstMultInput.Name = "BurstMultInput"
    BurstMultInput.Size = UDim2.new(0, 45, 0, 18)
    BurstMultInput.Position = UDim2.new(1, -45, 0, 0)
    BurstMultInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    BurstMultInput.Text = tostring(settings.burstMultiplier)
    BurstMultInput.TextColor3 = Color3.fromRGB(0, 255, 180)
    BurstMultInput.TextSize = 11
    BurstMultInput.Font = Enum.Font.GothamBold
    BurstMultInput.ClearTextOnFocus = false
    BurstMultInput.Parent = BurstMultiplierFrame
    
    local BurstInputCorner = Instance.new("UICorner")
    BurstInputCorner.CornerRadius = UDim.new(0, 4)
    BurstInputCorner.Parent = BurstMultInput
    
    local BurstOrbitToggleFrame = Instance.new("Frame")
    BurstOrbitToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    BurstOrbitToggleFrame.Position = UDim2.new(0, 0, 0, 75)
    BurstOrbitToggleFrame.BackgroundTransparency = 1
    BurstOrbitToggleFrame.Parent = BurstOrbitFrame
    
    local OrbitLabel = Instance.new("TextLabel")
    OrbitLabel.Size = UDim2.new(0.6, 0, 1, 0)
    OrbitLabel.BackgroundTransparency = 1
    OrbitLabel.Text = "Orbit Mode"
    OrbitLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    OrbitLabel.TextSize = 13
    OrbitLabel.Font = Enum.Font.Gotham
    OrbitLabel.TextXAlignment = Enum.TextXAlignment.Left
    OrbitLabel.Parent = BurstOrbitToggleFrame
    
    local OrbitToggleButton = Instance.new("TextButton")
    OrbitToggleButton.Name = "OrbitToggleButton"
    OrbitToggleButton.Size = UDim2.new(0, 50, 0, 22)
    OrbitToggleButton.Position = UDim2.new(1, -50, 0.5, -11)
    OrbitToggleButton.BackgroundColor3 = settings.orbitEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    OrbitToggleButton.Text = settings.orbitEnabled and "ON" or "OFF"
    OrbitToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    OrbitToggleButton.TextSize = 11
    OrbitToggleButton.Font = Enum.Font.GothamBold
    OrbitToggleButton.Parent = BurstOrbitToggleFrame
    
    local OrbitToggleCorner = Instance.new("UICorner")
    OrbitToggleCorner.CornerRadius = UDim.new(0, 6)
    OrbitToggleCorner.Parent = OrbitToggleButton
    
    local OrbitSpeedFrame = Instance.new("Frame")
    OrbitSpeedFrame.Size = UDim2.new(1, 0, 0, 30)
    OrbitSpeedFrame.Position = UDim2.new(0, 0, 0, 105)
    OrbitSpeedFrame.BackgroundTransparency = 1
    OrbitSpeedFrame.Parent = BurstOrbitFrame
    
    local OrbitSpeedLabel = Instance.new("TextLabel")
    OrbitSpeedLabel.Size = UDim2.new(0.6, 0, 1, 0)
    OrbitSpeedLabel.BackgroundTransparency = 1
    OrbitSpeedLabel.Text = "Orbit Speed:"
    OrbitSpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    OrbitSpeedLabel.TextSize = 11
    OrbitSpeedLabel.Font = Enum.Font.Gotham
    OrbitSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    OrbitSpeedLabel.Parent = OrbitSpeedFrame
    
    local OrbitSpeedInput = Instance.new("TextBox")
    OrbitSpeedInput.Name = "OrbitSpeedInput"
    OrbitSpeedInput.Size = UDim2.new(0, 45, 0, 18)
    OrbitSpeedInput.Position = UDim2.new(1, -45, 0.5, -9)
    OrbitSpeedInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    OrbitSpeedInput.Text = tostring(settings.orbitSpeed)
    OrbitSpeedInput.TextColor3 = Color3.fromRGB(0, 255, 180)
    OrbitSpeedInput.TextSize = 11
    OrbitSpeedInput.Font = Enum.Font.GothamBold
    OrbitSpeedInput.ClearTextOnFocus = false
    OrbitSpeedInput.Parent = OrbitSpeedFrame
    
    local OrbitSpeedCorner = Instance.new("UICorner")
    OrbitSpeedCorner.CornerRadius = UDim.new(0, 4)
    OrbitSpeedCorner.Parent = OrbitSpeedInput
    
    local TeleportBindFrame = Instance.new("Frame")
    TeleportBindFrame.Size = UDim2.new(1, 0, 0, 30)
    TeleportBindFrame.Position = UDim2.new(0, 0, 0, 140)
    TeleportBindFrame.BackgroundTransparency = 1
    TeleportBindFrame.Parent = BurstOrbitFrame
    
    local TeleportBindLabel = Instance.new("TextLabel")
    TeleportBindLabel.Size = UDim2.new(0.6, 0, 1, 0)
    TeleportBindLabel.BackgroundTransparency = 1
    TeleportBindLabel.Text = "Teleport Key:"
    TeleportBindLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TeleportBindLabel.TextSize = 13
    TeleportBindLabel.Font = Enum.Font.Gotham
    TeleportBindLabel.TextXAlignment = Enum.TextXAlignment.Left
    TeleportBindLabel.Parent = TeleportBindFrame
    
    local TeleportBindButton = Instance.new("TextButton")
    TeleportBindButton.Size = UDim2.new(0, 60, 0, 22)
    TeleportBindButton.Position = UDim2.new(1, -60, 0.5, -11)
    TeleportBindButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TeleportBindButton.Text = settings.teleportKey
    TeleportBindButton.TextColor3 = Color3.fromRGB(0, 255, 180)
    TeleportBindButton.TextSize = 11
    TeleportBindButton.Font = Enum.Font.GothamBold
    TeleportBindButton.Parent = TeleportBindFrame
    
    local TeleportBindCorner = Instance.new("UICorner")
    TeleportBindCorner.CornerRadius = UDim.new(0, 6)
    TeleportBindCorner.Parent = TeleportBindButton

    -- Elasticity & Recoil Toggles
    local SpringToggleFrame = Instance.new("Frame")
    SpringToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    SpringToggleFrame.Position = UDim2.new(0, 0, 0, 175)
    SpringToggleFrame.BackgroundTransparency = 1
    SpringToggleFrame.Parent = BurstOrbitFrame
    
    local SpringLabel = Instance.new("TextLabel")
    SpringLabel.Size = UDim2.new(0.6, 0, 1, 0)
    SpringLabel.BackgroundTransparency = 1
    SpringLabel.Text = "Elasticity (Spring)"
    SpringLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SpringLabel.TextSize = 13
    SpringLabel.Font = Enum.Font.Gotham
    SpringLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpringLabel.Parent = SpringToggleFrame
    
    local SpringToggleButton = Instance.new("TextButton")
    SpringToggleButton.Name = "SpringToggleButton"
    SpringToggleButton.Size = UDim2.new(0, 50, 0, 22)
    SpringToggleButton.Position = UDim2.new(1, -50, 0.5, -11)
    SpringToggleButton.BackgroundColor3 = settings.springEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    SpringToggleButton.Text = settings.springEnabled and "ON" or "OFF"
    SpringToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpringToggleButton.TextSize = 11
    SpringToggleButton.Font = Enum.Font.GothamBold
    SpringToggleButton.Parent = SpringToggleFrame
    
    Instance.new("UICorner", SpringToggleButton).CornerRadius = UDim.new(0, 6)
    
    local RecoilToggleFrame = Instance.new("Frame")
    RecoilToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    RecoilToggleFrame.Position = UDim2.new(0, 0, 0, 210)
    RecoilToggleFrame.BackgroundTransparency = 1
    RecoilToggleFrame.Parent = BurstOrbitFrame
    
    local RecoilLabel = Instance.new("TextLabel")
    RecoilLabel.Size = UDim2.new(0.6, 0, 1, 0)
    RecoilLabel.BackgroundTransparency = 1
    RecoilLabel.Text = "Recoil (Pulse)"
    RecoilLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    RecoilLabel.TextSize = 13
    RecoilLabel.Font = Enum.Font.Gotham
    RecoilLabel.TextXAlignment = Enum.TextXAlignment.Left
    RecoilLabel.Parent = RecoilToggleFrame
    
    local RecoilToggleButton = Instance.new("TextButton")
    RecoilToggleButton.Name = "RecoilToggleButton"
    RecoilToggleButton.Size = UDim2.new(0, 50, 0, 22)
    RecoilToggleButton.Position = UDim2.new(1, -50, 0.5, -11)
    RecoilToggleButton.BackgroundColor3 = settings.recoilEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    RecoilToggleButton.Text = settings.recoilEnabled and "ON" or "OFF"
    RecoilToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RecoilToggleButton.TextSize = 11
    RecoilToggleButton.Font = Enum.Font.GothamBold
    RecoilToggleButton.Parent = RecoilToggleFrame
    
    Instance.new("UICorner", RecoilToggleButton).CornerRadius = UDim.new(0, 6)

    -- ESP Toggle
    local ESPToggleFrame = Instance.new("Frame")
    ESPToggleFrame.Name = "ESPToggleFrame"
    ESPToggleFrame.Size = UDim2.new(0.9, 0, 0, 30)
    ESPToggleFrame.BackgroundTransparency = 1
    ESPToggleFrame.LayoutOrder = 5
    ESPToggleFrame.Parent = ContentFrame
    
    local ESPLabel = Instance.new("TextLabel")
    ESPLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ESPLabel.BackgroundTransparency = 1
    ESPLabel.Text = "Target ESP"
    ESPLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ESPLabel.TextSize = 13
    ESPLabel.Font = Enum.Font.Gotham
    ESPLabel.TextXAlignment = Enum.TextXAlignment.Left
    ESPLabel.Parent = ESPToggleFrame
    
    local ESPToggleButton = Instance.new("TextButton")
    ESPToggleButton.Name = "ESPToggleButton"
    ESPToggleButton.Size = UDim2.new(0, 50, 0, 22)
    ESPToggleButton.Position = UDim2.new(1, -50, 0.5, -11)
    ESPToggleButton.BackgroundColor3 = settings.espEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    ESPToggleButton.Text = settings.espEnabled and "ON" or "OFF"
    ESPToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ESPToggleButton.TextSize = 11
    ESPToggleButton.Font = Enum.Font.GothamBold
    ESPToggleButton.Parent = ESPToggleFrame
    
    local ESPToggleCorner = Instance.new("UICorner")
    ESPToggleCorner.CornerRadius = UDim.new(0, 6)
    ESPToggleCorner.Parent = ESPToggleButton

    -- Buttons Frame
    local ButtonsFrame = Instance.new("Frame")
    ButtonsFrame.Name = "ButtonsFrame"
    ButtonsFrame.Size = UDim2.new(0.9, 0, 0, 35)
    ButtonsFrame.BackgroundTransparency = 1
    ButtonsFrame.LayoutOrder = 6
    ButtonsFrame.Parent = ContentFrame
    
    -- Refresh Button
    local RefreshButton = Instance.new("TextButton")
    RefreshButton.Name = "RefreshButton"
    RefreshButton.Size = UDim2.new(0.48, 0, 1, 0)
    RefreshButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    RefreshButton.Text = "Refresh"
    RefreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RefreshButton.TextSize = 13
    RefreshButton.Font = Enum.Font.GothamBold
    RefreshButton.Parent = ButtonsFrame
    
    local RefreshCorner = Instance.new("UICorner")
    RefreshCorner.CornerRadius = UDim.new(0, 6)
    RefreshCorner.Parent = RefreshButton
    
    -- Enable Button
    local EnableButton = Instance.new("TextButton")
    EnableButton.Name = "EnableButton"
    EnableButton.Size = UDim2.new(0.48, 0, 1, 0)
    EnableButton.Position = UDim2.new(0.52, 0, 0, 0)
    EnableButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    EnableButton.Text = "Enable"
    EnableButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    EnableButton.TextSize = 13
    EnableButton.Font = Enum.Font.GothamBold
    EnableButton.Parent = ButtonsFrame
    
    local EnableCorner = Instance.new("UICorner")
    EnableCorner.CornerRadius = UDim.new(0, 6)
    EnableCorner.Parent = EnableButton
    
    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(0.95, 0, 0, 35)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    StatusLabel.Text = "Status: Idle"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    StatusLabel.TextSize = 11
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.LayoutOrder = 7
    StatusLabel.Parent = ContentFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 6)
    StatusCorner.Parent = StatusLabel
    
    ScreenGui.Parent = PlayerGui
    
    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        TitleBar = TitleBar,
        ContentFrame = ContentFrame,
        DropdownButton = DropdownButton,
        DropdownList = DropdownList,
        RefreshButton = RefreshButton,
        EnableButton = EnableButton,
        StatusLabel = StatusLabel,
        CloseButton = CloseButton,
        MinimizeButton = MinimizeButton,
        DragToggleButton = DragToggleButton,
        SliderDot = SliderDot,
        SliderBar = SliderBar,
        SliderBackground = SliderBackground,
        SliderLabel = SliderLabel,
        SliderInput = SliderInput,
        SelectBindButton = SelectBindButton,
        FireBindButton = FireBindButton,
        DashBindButton = DashBindButton,
        BurstBindButton = BurstBindButton,
        BurstMultInput = BurstMultInput,
        OrbitToggleButton = OrbitToggleButton,
        OrbitSpeedInput = OrbitSpeedInput,
        TeleportBindButton = TeleportBindButton,
        ESPToggleButton = ESPToggleButton,
        SearchInput = SearchInput,
        DomDot = DomDot,
        DomBar = DomBar,
        DomBackground = DomBackground,
        DomStageLabel = DomStageLabel,
        SpringToggleButton = SpringToggleButton,
        RecoilToggleButton = RecoilToggleButton
    }
end

-- ============================================================================
-- EXPLOIT LOGIC
-- ============================================================================

local GUI = createGui()

local selectedPlayer = nil
local selectedNPC = nil
local enabled = false
local preSyncConnection = nil
local postSyncConnection = nil
local visualSyncConnection = nil
local savedCFrame = nil
local collisionMap = {}
local lastCharacter = nil
local burstActive = false
local burstFrameCount = 0
local teleportPending = false
local teleportDirection = Vector3.new(0, 0, 0)
local positionBackups = {}

-- Hardened Position Capture Method
local function capturePosition()
    local character = LocalPlayer.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    
    if root then
        -- IMMEDIATE capture with no waiting - capture BEFORE any movement starts
        local backup = {
            root = root.CFrame,
            time = tick()
        }
        
        -- Floor verification with extended range for high-speed scenarios
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {character}
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        local result = workspace:Raycast(root.Position + Vector3.new(0, 5, 0), Vector3.new(0, -100, 0), rayParams)
        if result and result.Position then
            backup.floor = CFrame.new(result.Position + Vector3.new(0, 3, 0)) * (root.CFrame - root.Position)
        end
        
        positionBackups = backup
        savedCFrame = backup.floor or backup.root
        return backup
    end
end

local function updateSlider(input)
    if not GUI or not GUI.SliderBackground then return end
    local pos = math.clamp((input.Position.X - GUI.SliderBackground.AbsolutePosition.X) / GUI.SliderBackground.AbsoluteSize.X, 0, 1)
    GUI.SliderBar.Size = UDim2.new(pos, 0, 1, 0)
    GUI.SliderDot.Position = UDim2.new(pos, -7, 0.5, -7)
    settings.dragMagnitude = math.floor(pos * 1000)
    GUI.SliderInput.Text = tostring(settings.dragMagnitude)
end

local function updateDominance(input)
    if not GUI or not GUI.DomBackground then return end
    local pos = math.clamp((input.Position.X - GUI.DomBackground.AbsolutePosition.X) / GUI.DomBackground.AbsoluteSize.X, 0, 1)
    GUI.DomBar.Size = UDim2.new(pos, 0, 1, 0)
    GUI.DomDot.Position = UDim2.new(pos, -7, 0.5, -7)
    settings.dominance = math.floor(pos * 100)
    
    local stage = "Annoyance"
    local color = Color3.fromRGB(0, 255, 180)
    
    if settings.dominance > 75 then
        stage = "just unfair, is it a necessity?"
        color = Color3.fromRGB(255, 0, 0)
    elseif settings.dominance > 50 then
        stage = "Torpedo"
        color = Color3.fromRGB(255, 165, 0)
    elseif settings.dominance > 25 then
        stage = "Abduction"
        color = Color3.fromRGB(255, 255, 0)
    end
    
    GUI.DomStageLabel.Text = "Stage: " .. stage
    GUI.DomStageLabel.TextColor3 = color
    saveSettings()
end

-- Helper to reset character physics and state
local function resetCharacter()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    -- Unbind high-priority visual sync
    if visualSyncConnection then
        visualSyncConnection:Disconnect()
        visualSyncConnection = nil
    end
    pcall(function()
        RunService:UnbindFromRenderStep("PhysicsSync")
    end)
    
    if rootPart and character then
        -- 1. Reset physics desync property BEFORE zeroing velocity
        pcall(function()
            sethiddenproperty(rootPart, "PhysicsRepRootPart", nil)
        end)
        
        -- 2. Teleport back if we have a saved position
        local targetRestore = savedCFrame or (positionBackups and (positionBackups.floor or positionBackups.root or positionBackups.torso))
        
if targetRestore then
    -- SAFETY CHECK: Ensure the position isn't at origin or impossibly far
    if targetRestore.Position.Magnitude > 0.1 then
        local flatCFrame = CFrame.new(targetRestore.Position) * CFrame.Angles(0, select(2, targetRestore:ToEulerAnglesYXZ()), 0)
        -- REMOVED distance check - always teleport back regardless of distance
        rootPart.CFrame = flatCFrame
    end
    savedCFrame = nil
    positionBackups = {}
end

        
        -- Snap to ground if possible so the player doesn't float after disabling
        pcall(function()
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {character}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            local rayOrigin = rootPart.Position + Vector3.new(0, 2, 0)
            local rayDirection = Vector3.new(0, -10, 0)
            local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
            if result and result.Position then
                local targetPos = result.Position + Vector3.new(0, rootPart.Size.Y / 2 + 0.05, 0)
                rootPart.CFrame = CFrame.new(targetPos, targetPos + rootPart.CFrame.LookVector)
            end
        end)
        
        -- 3. ABSOLUTE physics kill (Brief Anchoring)
        rootPart.Anchored = true
        
        -- Reset humanoid properties immediately
        if humanoid then
            humanoid.PlatformStand = false
            humanoid.Sit = false
            humanoid.Jump = false
            humanoid.AutoRotate = true
        end
        
        -- Start a background task to scrub all momentum for several frames
        task.spawn(function()
            -- GEOMETRY UN-STUCK: Briefly disable collisions to escape curbs/walls
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
                -- RESET MOTOR6D TRANSFORMS: This is the fix for tilted limbs
                if part:IsA("Motor6D") then
                    part.Transform = CFrame.new()
                end
            end
            
            for i = 1, 10 do -- Increased duration for stability
                if not character or not rootPart.Parent then break end
                
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        -- Restore original collision state
                        if collisionMap[part] ~= nil then
                            part.CanCollide = collisionMap[part]
                        end
                        
                        part.CanTouch = true
                        part.CanQuery = true
                        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        
                        -- Reset orientation of the root every frame to keep it upright
                        if part == rootPart then
                            part.CFrame = CFrame.new(part.Position) * CFrame.Angles(0, select(2, part.CFrame:ToEulerAnglesYXZ()), 0)
                        end
                    end
                    if part:IsA("Motor6D") then
                        part.Transform = CFrame.new()
                    end
                end
                
                -- Unanchor after a few frames but keep zeroing velocity
                if i == 10 then
                    rootPart.Anchored = false
                end
                
                task.wait()
            end
            
            -- Final cleanup: ensure root is not anchored and velocity is zeroed
            if rootPart and rootPart.Parent then
                rootPart.Anchored = false
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Landed)
                    humanoid.PlatformStand = false
                end
            end
        end)
    else
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

-- Slider Logic
local isDraggingSlider = false
local sliderConn = nil

table.insert(connections, GUI.SliderDot.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSlider = true
        if sliderConn then sliderConn:Disconnect() end
        sliderConn = UserInputService.InputChanged:Connect(function(input, gpe)
            if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)
        table.insert(connections, sliderConn)
    end
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSlider = false
        isDraggingWindow = false
        isResizingGUI = false
        if sliderConn then
            sliderConn:Disconnect()
            sliderConn = nil
        end
    end
end))

    -- Custom Drag System - continues even when mouse leaves GUI
local isDraggingWindow = false
local dragStartPosition = nil
local dragStartMouse = nil
local isResizingGUI = false
local resizeStartSize = nil
local resizeStartMouse = nil

-- Start drag when TitleBar is clicked
table.insert(connections, GUI.TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingWindow = true
        dragStartPosition = GUI.MainFrame.Position
        dragStartMouse = UserInputService:GetMouseLocation()
    end
end))

-- Start resize when ResizeHandle is clicked
table.insert(connections, GUI.MainFrame.ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isResizingGUI = true
        resizeStartSize = GUI.MainFrame.Size
        resizeStartMouse = UserInputService:GetMouseLocation()
    end
end))

-- Dominance Slider Connection
local isDraggingDom = false
table.insert(connections, GUI.DomDot.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDraggingDom = true
    end
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingDom = false
        isDraggingSlider = false
        isDraggingWindow = false
        isResizingGUI = false
        if sliderConn then
            sliderConn:Disconnect()
            sliderConn = nil
        end
    end
end))

table.insert(connections, UserInputService.InputChanged:Connect(function(input, gpe)
    if isDraggingWindow and input.UserInputType == Enum.UserInputType.MouseMovement then
        local currentMouse = UserInputService:GetMouseLocation()
        local deltaX = currentMouse.X - dragStartMouse.X
        local deltaY = currentMouse.Y - dragStartMouse.Y
        GUI.MainFrame.Position = UDim2.new(
            dragStartPosition.X.Scale, dragStartPosition.X.Offset + deltaX,
            dragStartPosition.Y.Scale, dragStartPosition.Y.Offset + deltaY
        )
    elseif isResizingGUI and input.UserInputType == Enum.UserInputType.MouseMovement then
        local currentMouse = UserInputService:GetMouseLocation()
        local deltaX = currentMouse.X - resizeStartMouse.X
        local deltaY = currentMouse.Y - resizeStartMouse.Y
        local newWidth = math.max(300, resizeStartSize.X.Offset + deltaX)
        local newHeight = math.max(200, resizeStartSize.Y.Offset + deltaY)
        GUI.MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        settings.windowSize = {x = newWidth, y = newHeight}
        saveSettings()
    elseif isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    elseif isDraggingDom and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateDominance(input)
    end
end))

-- New Toggle Listeners
table.insert(connections, GUI.SpringToggleButton.MouseButton1Click:Connect(function()
    settings.springEnabled = not settings.springEnabled
    GUI.SpringToggleButton.BackgroundColor3 = settings.springEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    GUI.SpringToggleButton.Text = settings.springEnabled and "ON" or "OFF"
    saveSettings()
end))

table.insert(connections, GUI.RecoilToggleButton.MouseButton1Click:Connect(function()
    settings.recoilEnabled = not settings.recoilEnabled
    GUI.RecoilToggleButton.BackgroundColor3 = settings.recoilEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    GUI.RecoilToggleButton.Text = settings.recoilEnabled and "ON" or "OFF"
    saveSettings()
end))

-- Keybind Customization Logic
local function bindKey(button, settingKey)
    button.Text = "..."
    if GUI and GUI.StatusLabel then GUI.StatusLabel.Text = "Status: Press any key to bind..." end
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            settings[settingKey] = input.KeyCode.Name
            button.Text = input.KeyCode.Name
            if GUI and GUI.StatusLabel then GUI.StatusLabel.Text = "Status: Bound " .. settingKey .. " to " .. input.KeyCode.Name end
            saveSettings()
            connection:Disconnect()
        end
    end)
    table.insert(connections, connection)
end

table.insert(connections, GUI.SelectBindButton.MouseButton1Click:Connect(function() bindKey(GUI.SelectBindButton, "selectKey") end))
table.insert(connections, GUI.FireBindButton.MouseButton1Click:Connect(function() bindKey(GUI.FireBindButton, "fireKey") end))
table.insert(connections, GUI.DashBindButton.MouseButton1Click:Connect(function() bindKey(GUI.DashBindButton, "dashKey") end))
table.insert(connections, GUI.BurstBindButton.MouseButton1Click:Connect(function() bindKey(GUI.BurstBindButton, "burstKey") end))
table.insert(connections, GUI.TeleportBindButton.MouseButton1Click:Connect(function() bindKey(GUI.TeleportBindButton, "teleportKey") end))

-- Burst Multiplier Input
table.insert(connections, GUI.BurstMultInput.FocusLost:Connect(function(enterPressed)
    local val = tonumber(GUI.BurstMultInput.Text)
    if val then
        settings.burstMultiplier = math.clamp(math.floor(val), 1, 10)
        saveSettings()
    end
    GUI.BurstMultInput.Text = tostring(settings.burstMultiplier)
end))

-- Orbit Speed Input
table.insert(connections, GUI.OrbitSpeedInput.FocusLost:Connect(function(enterPressed)
    local val = tonumber(GUI.OrbitSpeedInput.Text)
    if val then
        settings.orbitSpeed = math.clamp(math.floor(val), 0, 500)
        saveSettings()
    end
    GUI.OrbitSpeedInput.Text = tostring(settings.orbitSpeed)
end))

-- Orbit Toggle Logic
table.insert(connections, GUI.OrbitToggleButton.MouseButton1Click:Connect(function()
    settings.orbitEnabled = not settings.orbitEnabled
    if settings.orbitEnabled then
        GUI.OrbitToggleButton.Text = "ON"
        GUI.OrbitToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        GUI.OrbitToggleButton.Text = "OFF"
        GUI.OrbitToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    saveSettings()
end))

-- ESP Toggle Logic
table.insert(connections, GUI.ESPToggleButton.MouseButton1Click:Connect(function()
    settings.espEnabled = not settings.espEnabled
    if settings.espEnabled then
        GUI.ESPToggleButton.Text = "ON"
        GUI.ESPToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        GUI.ESPToggleButton.Text = "OFF"
        GUI.ESPToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    saveSettings()
end))

-- Drag Toggle Logic
table.insert(connections, GUI.DragToggleButton.MouseButton1Click:Connect(function()
    settings.dragEnabled = not settings.dragEnabled
    if settings.dragEnabled then
        GUI.DragToggleButton.Text = "ON"
        GUI.DragToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        GUI.DragToggleButton.Text = "OFF"
        GUI.DragToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    saveSettings()
end))

-- Minimize Logic
table.insert(connections, GUI.MinimizeButton.MouseButton1Click:Connect(function()
    settings.minimized = not settings.minimized
    if settings.minimized then
        GUI.ContentFrame.Visible = false
        GUI.MainFrame.Size = UDim2.new(0, settings.windowSize.x, 0, 35)
        GUI.MinimizeButton.Text = "+"
    else
        GUI.ContentFrame.Visible = true
        GUI.MainFrame.Size = UDim2.new(0, settings.windowSize.x, 0, settings.windowSize.y)
        GUI.MinimizeButton.Text = "-"
    end
    saveSettings()
end))

-- Update player list (now including NPCs)
local function updatePlayerList()
    -- Clear existing
    if not GUI or not GUI.DropdownList then return end
    for _, child in pairs(GUI.DropdownList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local filter = GUI.SearchInput.Text:lower()
    
    -- Add NPCs first
    local npcCount = 0
    local localChar = LocalPlayer.Character
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc.Name ~= "Workspace" then
            local isLocalPlayer = false
            if localChar and npc == localChar then
                isLocalPlayer = true
            end
            -- Check if it's owned by a player
            local isPlayerOwned = false
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and npc == player.Character then
                    isPlayerOwned = true
                    break
                end
            end
            if not isLocalPlayer and not isPlayerOwned then
                if filter == "" or npc.Name:lower():find(filter) then
                    local npcButton = Instance.new("TextButton")
                    npcButton.Size = UDim2.new(1, -10, 0, 30)
                    npcButton.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
                    npcButton.Text = "[NPC] " .. npc.Name
                    npcButton.TextColor3 = Color3.fromRGB(255, 200, 200)
                    npcButton.TextSize = 13
                    npcButton.Font = Enum.Font.Gotham
                    npcButton.BorderSizePixel = 0
                    npcButton.ZIndex = 11
                    npcButton.Parent = GUI.DropdownList
                    
                    local BtnCorner = Instance.new("UICorner")
                    BtnCorner.CornerRadius = UDim.new(0, 4)
                    BtnCorner.Parent = npcButton
                    
                    table.insert(connections, npcButton.MouseButton1Click:Connect(function()
                        selectedNPC = npc
                        selectedPlayer = nil
                        lastCharacter = nil
                        if GUI and GUI.DropdownButton then GUI.DropdownButton.Text = "[NPC] " .. npc.Name end
                        if GUI and GUI.DropdownList then GUI.DropdownList.Visible = false end
                        if GUI and GUI.StatusLabel then GUI.StatusLabel.Text = "Status: Selected NPC " .. npc.Name end
                    end))
                    
                    npcCount = npcCount + 1
                end
            end
        end
    end
    
    -- Add players
    local count = npcCount
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if filter == "" or player.Name:lower():find(filter) or player.DisplayName:lower():find(filter) then
                local PlayerButton = Instance.new("TextButton")
                PlayerButton.Size = UDim2.new(1, -10, 0, 30)
                PlayerButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                PlayerButton.Text = player.DisplayName .. " | " .. player.Name
                PlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                PlayerButton.TextSize = 13
                PlayerButton.Font = Enum.Font.Gotham
                PlayerButton.BorderSizePixel = 0
                PlayerButton.ZIndex = 11
                PlayerButton.Parent = GUI.DropdownList
                
                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 4)
                BtnCorner.Parent = PlayerButton
                
                table.insert(connections, PlayerButton.MouseButton1Click:Connect(function()
                    selectedPlayer = player
                    selectedNPC = nil
                    lastCharacter = nil
                    if GUI and GUI.DropdownButton then GUI.DropdownButton.Text = player.Name end
                    if GUI and GUI.DropdownList then GUI.DropdownList.Visible = false end
                    if GUI and GUI.StatusLabel then GUI.StatusLabel.Text = "Status: Selected " .. player.Name end
                end))
                
                count = count + 1
            end
        end
    end
    
    GUI.DropdownList.CanvasSize = UDim2.new(0, 0, 0, count * 32)
end

-- Refresh NPCs periodically when dropdown is open
task.spawn(function()
    while true do
        task.wait(2)
        if GUI and GUI.DropdownList and GUI.DropdownList.Visible then
            pcall(updatePlayerList)
        end
    end
end)

-- Search Input Listener
table.insert(connections, GUI.SearchInput:GetPropertyChangedSignal("Text"):Connect(updatePlayerList))

-- Enable/Disable Toggle Function
local function toggleExploit()
    if not selectedPlayer and not selectedNPC then
        if GUI and GUI.StatusLabel then GUI.StatusLabel.Text = "Status: No player or NPC selected!" end
        return
    end
    
    enabled = not enabled
    
    if enabled then
        if GUI and GUI.EnableButton then
            GUI.EnableButton.Text = "Disable"
            GUI.EnableButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        local targetName = selectedPlayer and selectedPlayer.Name or (selectedNPC and selectedNPC.Name or "Unknown")
        if GUI and GUI.StatusLabel then GUI.StatusLabel.Text = "Status: ACTIVE on " .. targetName end
        if GUI and GUI.SliderInput then
            GUI.SliderInput.Selectable = false -- Prevent keyboard hijacking during exploitation
            GUI.SliderInput.TextEditable = false -- Extra layer: prevent any editing
        end
        pcall(function() 
            local focusBox = UserInputService:GetFocusedTextBox()
            if focusBox then focusBox:ReleaseFocus() end
        end)
        
        -- Save position before starting

            capturePosition()

        
        -- Start the exploit
        local function startExploit()
            local character = LocalPlayer.Character
            local targetCharacter = selectedPlayer and selectedPlayer.Character or selectedNPC
            
            if not character or not targetCharacter then
                if GUI and GUI.StatusLabel then GUI.StatusLabel.Text = "Status: Waiting for characters..." end
                return
            end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
            
            if not rootPart or not targetRoot then
                if GUI and GUI.StatusLabel then GUI.StatusLabel.Text = "Status: Waiting for root parts..." end
                return
            end
            
            -- Prepare local character for absolute sync
            if humanoid then
                humanoid.PlatformStand = true
            end
            
            -- Store original collision states
 -- Store original collision states AND track original parts
            collisionMap = {}
            originalParts = {} -- Reset the list
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    collisionMap[part] = part.CanCollide
                    originalParts[part] = true -- Mark this part as "original"
                    part.CanCollide = false
                end
            end
            
            -- Monitor for new objects being added (trashcans, guitars, etc)
            local childAddedConn
            childAddedConn = character.DescendantAdded:Connect(function(descendant)
                if not enabled then 
                    childAddedConn:Disconnect()
                    return 
                end
                
                -- If a new weld connects to a non-original part, destroy it
                if descendant:IsA("Weld") or descendant:IsA("WeldConstraint") or descendant:IsA("Motor6D") then
                    task.wait(0.05) -- Let it settle
                    local part0 = descendant.Part0
                    local part1 = descendant.Part1
                    
                    -- If either part isn't original, break the weld
                    if (part0 and not originalParts[part0]) or (part1 and not originalParts[part1]) then
                        descendant:Destroy()
                    end
                end
            end)
            table.insert(connections, childAddedConn)
            
            -- Reset connections
            if preSyncConnection then preSyncConnection:Disconnect() end
            if postSyncConnection then postSyncConnection:Disconnect() end
            if visualSyncConnection then visualSyncConnection:Disconnect() end
            
                    -- 1. OVERCLOCKED REPLICATION (Ping Independence & Auto-Rotation)
                    task.spawn(function()
                        while enabled and (selectedPlayer or selectedNPC) and (selectedPlayer and selectedPlayer.Character or selectedNPC) do
                            local myChar = LocalPlayer.Character
                            local theirChar = selectedPlayer and selectedPlayer.Character or selectedNPC
                            if myChar and theirChar then
                                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                                local theirRoot = theirChar:FindFirstChild("HumanoidRootPart")
                                local theirHumanoid = theirChar:FindFirstChildOfClass("Humanoid")
                                
                                if myRoot and theirRoot then
                                    -- FULL CFRAME SYNC (Position + Rotation)
                                    -- This ensures your hitboxes perfectly overlap the target's
                                    myRoot.CFrame = theirRoot.CFrame
                                    
                                    -- Property Overclocking
                                    pcall(function()
                                        sethiddenproperty(myRoot, "PhysicsRepRootPart", theirRoot)
                                    end)
                                    
                                    -- State Lock
                                    if settings.dominance > 25 and theirHumanoid then
                                        theirHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
                                        theirHumanoid.PlatformStand = true
                                        if settings.dominance > 75 then
                                            local states = {Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.Dead, Enum.HumanoidStateType.Ragdoll}
                                            theirHumanoid:ChangeState(states[math.random(1, #states)])
                                        end
                                    end
                                end
                            end
                            -- Maximum possible frequency
                            task.wait() 
                        end
                    end)
            
            -- 2. PHYSICS SETUP (PRE-SIMULATION: Optimal for Replication)
            preSyncConnection = RunService.PreSimulation:Connect(function()
                        if not enabled then return end
                        local myChar = LocalPlayer.Character
                        local theirChar = selectedPlayer and selectedPlayer.Character or selectedNPC
                        if not myChar or not theirChar then return end
                        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                        local theirRoot = theirChar:FindFirstChild("HumanoidRootPart")
                        local humanoid = myChar:FindFirstChildOfClass("Humanoid")
                        
                        if myRoot and theirRoot then
                            -- ADAPTIVE VELOCITY ZEROING: Wipe target physics slate clean
                            if settings.dominance > 25 then
                                theirRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                theirRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                            end

                            -- Crucial for Network Ownership hijacking
                            pcall(function()
                                sethiddenproperty(myRoot, "PhysicsRepRootPart", theirRoot)
                            end)
                            
                            -- Force internal physics state
                            if humanoid then
                                humanoid.PlatformStand = true
                            end
                            
                            -- Apply movement (PreSimulation ensures this replicates to server)
                            local dragVelocity = Vector3.new(0, 0, 0)
                            local hasMovement = false
                            
                            -- Handle teleport as instant velocity impulse (single frame only)
                            if teleportPending then
                                dragVelocity = teleportDirection * 300 
                                hasMovement = true
                                teleportPending = false
                            elseif settings.orbitEnabled and settings.orbitSpeed > 0 then
                                -- WHIRLWIND (Orbit)
                                local orbitSpeed = settings.orbitSpeed * (settings.dominance / 50)
                                local time = tick() * orbitSpeed
                                local radius = 10
                                local offset = Vector3.new(math.sin(time) * radius, 0, math.cos(time) * radius)
                                local targetPoint = myRoot.Position + offset
                                local dragDirection = (targetPoint - myRoot.Position).Unit
                                dragVelocity = dragDirection * (settings.dragMagnitude * 2)
                                hasMovement = true
                            elseif settings.dragEnabled and settings.dragMagnitude > 0 then
                                -- Normal drag mode: pull toward mouse
                                local mousePos = UserInputService:GetMouseLocation()
                                local mouseRay = workspace.CurrentCamera:ViewportPointToRay(mousePos.X, mousePos.Y)
                                local distance = (theirRoot.Position - myRoot.Position).Magnitude
                                local targetPoint = mouseRay.Origin + mouseRay.Direction * distance
                                
                        local dragMagnitude = settings.dominance * 30 -- Increased from 20 to 30 (max 3000)
                        
                        -- Recoil Pulse
                        if settings.recoilEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                            dragMagnitude = -4000 -- Increased from -2000
                        end
                        
                        -- Jitter/Deviation (Desync Deviation)
                        local jitter = 0
                        if settings.dominance > 50 then
                            jitter = math.sin(tick() * 30) * (dragMagnitude * 0.2) -- Faster jitter
                        end
                        
                        local dragDirection = (targetPoint - myRoot.Position).Unit
                        dragVelocity = dragDirection * (dragMagnitude + jitter)
                        hasMovement = true
                    end
                    
                    -- Apply burst multiplier if active (works on any movement type)
                    if burstActive then
                        if hasMovement then
                            dragVelocity = dragVelocity * (settings.burstMultiplier * 1.5) -- Buffed burst
                        end
                        burstFrameCount = burstFrameCount + 1
                        if burstFrameCount >= 10 then  -- 10 frames of burst
                            burstActive = false
                            burstFrameCount = 0
                        end
                    end
                    
                    -- ANCHOR WEIGHT (Momentum Transfer)
                    if settings.dominance > 75 then
                        dragVelocity = dragVelocity + (myRoot.AssemblyLinearVelocity * 1.2) -- Buffed momentum
                    end

                    if hasMovement then
                        myRoot.AssemblyLinearVelocity = dragVelocity
                    else
                        myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
                    myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    
-- Collision & Auto-Rotation Sync
for _, part in pairs(myChar:GetDescendants()) do
    if part:IsA("BasePart") and originalParts[part] then
        -- EXCLUDE tools and accessories from physics manipulation
        local isToolPart = part:FindFirstAncestorOfClass("Tool") or part:FindFirstAncestorOfClass("Accessory")
        
        if not isToolPart then
            part.CanCollide = false
            part.Massless = true 
        end
        
        if part == myRoot then
            -- AUTO-ROTATE: Match target's rotation exactly instead of locking upright
            -- This ensures hitboxes align perfectly for combat
            myRoot.CFrame = CFrame.new(myRoot.Position) * theirRoot.CFrame.Rotation
        end
    end
end
                        end
                    end)
            
            -- 3. SNAP-BACK
            postSyncConnection = RunService.PostSimulation:Connect(function()
                if not enabled then return end
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local theirChar = selectedPlayer and selectedPlayer.Character or selectedNPC
                local theirRoot = theirChar and theirChar:FindFirstChild("HumanoidRootPart")
                if myRoot and theirRoot then
                    myRoot.CFrame = theirRoot.CFrame
                end
            end)
            
            if GUI and GUI.StatusLabel then GUI.StatusLabel.Text = "Status: EXPLOIT ACTIVE!" end
        end
        
        startExploit()
        
        table.insert(connections, LocalPlayer.CharacterAdded:Connect(function()
    savedCFrame = nil -- Clear saved position on respawn
    if enabled then
        task.wait(0.1)
        startExploit()
    end
end))
        
        table.insert(connections, selectedPlayer.CharacterAdded:Connect(function()
            if enabled then
                task.wait(0.1)
                startExploit()
            end
        end))
        
    else
        -- Immediately reset physics desync property
        pcall(function()
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                sethiddenproperty(rootPart, "PhysicsRepRootPart", nil)
            end
        end)
        
        if GUI and GUI.EnableButton then
            GUI.EnableButton.Text = "Enable"
            GUI.EnableButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        end
        if GUI and GUI.StatusLabel then GUI.StatusLabel.Text = "Status: Disabled" end
        if GUI and GUI.SliderInput then
            GUI.SliderInput.Selectable = true -- Re-enable slider input when disabled
            GUI.SliderInput.TextEditable = true -- Re-enable editing when disabled
        end
        if preSyncConnection then preSyncConnection:Disconnect(); preSyncConnection = nil end
        if postSyncConnection then postSyncConnection:Disconnect(); postSyncConnection = nil end
        if visualSyncConnection then visualSyncConnection:Disconnect(); visualSyncConnection = nil end
        resetCharacter()
    end
end

-- Keybinds & Mouse Logic
local targetHighlight = Instance.new("Highlight")
targetHighlight.FillColor = Color3.fromRGB(0, 255, 180)
targetHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
targetHighlight.FillTransparency = 0.5
targetHighlight.OutlineTransparency = 0
targetHighlight.Enabled = false
targetHighlight.Parent = game:GetService("CoreGui")

local function updateESP()
    if settings.espEnabled and (selectedPlayer or selectedNPC) then
        if selectedPlayer and selectedPlayer.Character then
            targetHighlight.Adornee = selectedPlayer.Character
            lastCharacter = selectedPlayer.Character
            targetHighlight.Enabled = true
        elseif selectedNPC then
            targetHighlight.Adornee = selectedNPC
            lastCharacter = selectedNPC
            targetHighlight.Enabled = true
        elseif lastCharacter then
            targetHighlight.Adornee = lastCharacter
            targetHighlight.Enabled = true
        else
            targetHighlight.Enabled = false
        end
    else
        targetHighlight.Enabled = false
        lastCharacter = nil
    end
end

table.insert(connections, RunService.RenderStepped:Connect(updateESP))

local function getClosestPlayerToMouse()
    local closestTarget = nil
    local shortestDistance = math.huge
    
    -- Check players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if distance < shortestDistance then
                    closestTarget = {type = "player", target = player}
                    shortestDistance = distance
                end
            end
        end
    end
    
    -- Check NPCs
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
            if LocalPlayer.Character and npc ~= LocalPlayer.Character then
                local root = npc:FindFirstChild("HumanoidRootPart")
                if root then
                    local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local distance = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if distance < shortestDistance then
                            closestTarget = {type = "npc", target = npc}
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

-- Consolidated Keybind Handler
table.insert(connections, UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    if input.KeyCode.Name == settings.selectKey then
        local target = getClosestPlayerToMouse()
        if target then
            if target.type == "player" then
                selectedPlayer = target.target
                selectedNPC = nil
            else
                selectedNPC = target.target
                selectedPlayer = nil
            end
            lastCharacter = nil
            if GUI and GUI.DropdownButton then GUI.DropdownButton.Text = (target.type == "npc" and "[NPC] " or "") .. target.target.Name end
            if GUI and GUI.StatusLabel then GUI.StatusLabel.Text = "Quick Selected: " .. target.target.Name end
        end
    elseif input.KeyCode.Name == settings.fireKey then
        toggleExploit()
    elseif input.KeyCode.Name == settings.dashKey then
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local mousePos = UserInputService:GetMouseLocation()
            local mouseRay = workspace.CurrentCamera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local dashDir = mouseRay.Direction.Unit
            rootPart.AssemblyLinearVelocity = dashDir * 500 -- Instant Transmission speed
            if GUI and GUI.StatusLabel then GUI.StatusLabel.Text = "Quick Dash Executed!" end
        end
    elseif input.KeyCode.Name == settings.burstKey then
        if enabled and (selectedPlayer or selectedNPC) and (selectedPlayer and selectedPlayer.Character or selectedNPC) then
            burstActive = true
            burstFrameCount = 0
            if GUI and GUI.StatusLabel then GUI.StatusLabel.Text = "Status: BURST!" end
        end
    elseif input.KeyCode.Name == settings.teleportKey then
        if enabled and (selectedPlayer or selectedNPC) and (selectedPlayer and selectedPlayer.Character or selectedNPC) then
            local myChar = LocalPlayer.Character
            local theirChar = selectedPlayer and selectedPlayer.Character or selectedNPC
            if myChar and theirChar then
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                local theirRoot = theirChar:FindFirstChild("HumanoidRootPart")
                if myRoot and theirRoot then
                    local mousePos = UserInputService:GetMouseLocation()
                    local mouseRay = workspace.CurrentCamera:ViewportPointToRay(mousePos.X, mousePos.Y)
                    local distance = (theirRoot.Position - myRoot.Position).Magnitude
                    local teleportPoint = mouseRay.Origin + mouseRay.Direction * distance
                    teleportDirection = (teleportPoint - myRoot.Position).Unit
                    teleportPending = true
                    if GUI and GUI.StatusLabel then GUI.StatusLabel.Text = "Status: TELEPORT QUEUED!" end
                end
            end
        end
    end
end))

-- Toggle dropdown
table.insert(connections, GUI.DropdownButton.MouseButton1Click:Connect(function()
    GUI.DropdownList.Visible = not GUI.DropdownList.Visible
end))

-- Refresh button
table.insert(connections, GUI.RefreshButton.MouseButton1Click:Connect(function()
    updatePlayerList()
    if GUI and GUI.StatusLabel then GUI.StatusLabel.Text = "Status: Refreshed player list" end
end))

-- Cleanup function
local function cleanup()
    if enabled then toggleExploit() end
    
    for _, conn in pairs(connections) do
        if conn and conn.Disconnect then
            conn:Disconnect()
        end
    end
    connections = {}

    if GUI and GUI.ScreenGui then
        pcall(function() GUI.ScreenGui:Destroy() end)
    end
end

-- Close button now calls cleanup
table.insert(connections, GUI.CloseButton.MouseButton1Click:Connect(function()
    if enabled then toggleExploit() end
    cleanup()
    if targetHighlight then targetHighlight:Destroy() end
end))

-- Enable/Disable button
table.insert(connections, GUI.EnableButton.MouseButton1Click:Connect(toggleExploit))

updatePlayerList()
table.insert(connections, Players.PlayerAdded:Connect(updatePlayerList))
table.insert(connections, Players.PlayerRemoving:Connect(updatePlayerList))

print("unfairnessessity loaded. YOINK THOSE MFS.")
    
