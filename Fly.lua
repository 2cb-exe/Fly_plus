local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local camera = Workspace.CurrentCamera

local flying = false
local flySpeed = 64
local ghostCFrame = root.CFrame
local originCFrame = root.CFrame
local keysDown = {}
local rootJoint = nil
local jointPart0 = nil
local initialRotation = CFrame.new()

local cameraProxy = Instance.new("Part")
cameraProxy.Name = "FlyCameraProxy"
cameraProxy.Transparency = 1
cameraProxy.CanCollide = false
cameraProxy.Anchored = true
cameraProxy.CastShadow = false
cameraProxy.Size = Vector3.new(0.01, 0.01, 0.01)
cameraProxy.Parent = Workspace

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyPlusPlus"
screenGui.ResetOnSpawn = false
screenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 100)
mainFrame.Position = UDim2.new(0, 20, 0.5, -50)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2.5
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Color = Color3.fromRGB(255, 255, 255)
mainStroke.Parent = mainFrame

local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 183, 197)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 105, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(219, 112, 147))
})
mainGradient.Parent = mainStroke

task.spawn(function()
    while true do
        mainGradient.Rotation = mainGradient.Rotation + 2
        task.wait(0.01)
    end
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 30)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Fly++"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = 14
title.Parent = mainFrame

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.Position = UDim2.new(1, -18, 0, 11)
statusDot.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
statusDot.BorderSizePixel = 0
statusDot.Parent = mainFrame

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = statusDot

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundTransparency = 1
header.Parent = mainFrame

local dragToggle, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = false
    end
end)

local speedDisplay = Instance.new("TextLabel")
speedDisplay.Size = UDim2.new(1, 0, 0, 20)
speedDisplay.Position = UDim2.new(0, 0, 0, 45)
speedDisplay.BackgroundTransparency = 1
speedDisplay.Text = "FLY SPEED: " .. flySpeed
speedDisplay.TextColor3 = Color3.fromRGB(255, 183, 197)
speedDisplay.Font = Enum.Font.GothamBold
speedDisplay.TextSize = 10
speedDisplay.Parent = mainFrame

local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(1, -30, 0, 4)
sliderFrame.Position = UDim2.new(0, 15, 0, 75)
sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
sliderFrame.Parent = mainFrame

local sCorner = Instance.new("UICorner")
sCorner.CornerRadius = UDim.new(1, 0)
sCorner.Parent = sliderFrame

local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(0, 0, 1, 0)
sliderBar.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
sliderBar.BorderSizePixel = 0
sliderBar.Parent = sliderFrame

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(1, 0)
sbCorner.Parent = sliderBar

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 12, 0, 12)
sliderKnob.Position = UDim2.new(0, -6, 0.5, -6)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderFrame

local skCorner = Instance.new("UICorner")
skCorner.CornerRadius = UDim.new(1, 0)
skCorner.Parent = sliderKnob

local dragging = false
local minSpeed = 50
local maxSpeed = 500

local function updateSlider(input)
    local pos = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
    sliderBar.Size = UDim2.new(pos, 0, 1, 0)
    sliderKnob.Position = UDim2.new(pos, -6, 0.5, -6)
    flySpeed = math.floor(minSpeed + (pos * (maxSpeed - minSpeed)))
    speedDisplay.Text = "FLY SPEED: " .. flySpeed
end

sliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        updateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local initialPos = (flySpeed - minSpeed) / (maxSpeed - minSpeed)
sliderBar.Size = UDim2.new(initialPos, 0, 1, 0)
sliderKnob.Position = UDim2.new(initialPos, -6, 0.5, -6)

local function getMoveDirection()
    local dir = Vector3.new(0,0,0)
    if keysDown[Enum.KeyCode.W] then dir = dir + camera.CFrame.LookVector end
    if keysDown[Enum.KeyCode.S] then dir = dir - camera.CFrame.LookVector end
    if keysDown[Enum.KeyCode.D] then dir = dir + camera.CFrame.RightVector end
    if keysDown[Enum.KeyCode.A] then dir = dir - camera.CFrame.RightVector end
    if keysDown[Enum.KeyCode.Space] then dir = dir + Vector3.new(0, 1, 0) end
    if keysDown[Enum.KeyCode.LeftShift] then dir = dir - Vector3.new(0, 1, 0) end
    return dir.Unit
end

local function setNoClip(state)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

local function toggleFly()
    flying = not flying
    if flying then
        originCFrame = root.CFrame
        ghostCFrame = root.CFrame
        initialRotation = root.CFrame - root.CFrame.Position
        rootJoint = root:FindFirstChild("RootJoint") or root:FindFirstChild("Root")
        if rootJoint then
            jointPart0 = rootJoint.Part0
            rootJoint.Part0 = nil
        end
        root.Anchored = true
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        statusDot.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
        setNoClip(true)
        camera.CameraSubject = cameraProxy
    else
        statusDot.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        root.Anchored = false
        root.CFrame = ghostCFrame
        if rootJoint then
            rootJoint.Part0 = jointPart0
        end
        root.Velocity = Vector3.new(0,0,0)
        root.RotVelocity = Vector3.new(0,0,0)
        setNoClip(false)
        task.spawn(function()
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            task.wait(0.1)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end)
        camera.CameraSubject = humanoid
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    keysDown[input.KeyCode] = true
    if input.KeyCode == Enum.KeyCode.X then
        toggleFly()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    keysDown[input.KeyCode] = false
end)

RunService.Heartbeat:Connect(function(dt)
    if not flying then return end
    local moveDir = getMoveDirection()
    if moveDir.Magnitude > 0 then
        ghostCFrame = ghostCFrame + (moveDir * flySpeed * dt)
    end
    local isInteracting = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or 
                          UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    if isInteracting then
        root.CFrame = ghostCFrame
    else
        root.CFrame = originCFrame
    end
    cameraProxy.CFrame = CFrame.new(ghostCFrame.Position + Vector3.new(0, 2.2, 0))
    root.Velocity = Vector3.new(0, 0.1, 0) 
end)

RunService.RenderStepped:Connect(function()
    if flying then
        local isShiftLock = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
        local currentRotation = initialRotation
        if isShiftLock then
            local _, lookY, _ = camera.CFrame:ToEulerAnglesYXZ()
            currentRotation = CFrame.Angles(0, lookY, 0)
        end
        local body = character:FindFirstChild("Torso") or character:FindFirstChild("LowerTorso")
        if body then
            body.CFrame = CFrame.new(ghostCFrame.Position) * currentRotation
            local isFirstPerson = (camera.Focus.Position - camera.CFrame.Position).Magnitude < 1
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.LocalTransparencyModifier = isFirstPerson and 1 or 0
                end
            end
        end
        setNoClip(true)
    end
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    root = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    if flying then toggleFly() end 
end)
