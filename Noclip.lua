local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local starterGui = game:GetService("StarterGui")

local noClip = false
local dragging = false
local dragStart = nil
local startPos = nil
local guiVisible = true
local screenGui, gearButton, menuGui, noClipButton, speedButton, speedGui
local speedInputBox, applySpeedButton, resetSpeedButton, clickTPButton
local clickTPEnabled = false

-- Function to create a Roblox-style notification
local function createNotification(message)
    starterGui:SetCore("SendNotification", {
        Title = "No-Clip";
        Text = message;
        Duration = 2; -- Duration of the notification
    })
end

-- Function to apply No-Clip to the character
local function applyNoClip(character)
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = not noClip
        end
    end
    if character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CanCollide = not noClip
    end
end

-- Function to enable/disable No-Clip mode
local function setNoClip(enabled)
    noClip = enabled
    applyNoClip(player.Character)
    if noClipButton then
        noClipButton.Text = "No-Clip: " .. (noClip and "Enabled" or "Disabled")
        noClipButton.BackgroundColor3 = noClip and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end
    print("No-Clip " .. (noClip and "Enabled" or "Disabled"))
end

-- Function to toggle No-Clip mode
function toggleNoClip()
    setNoClip(not noClip)
end

-- Function to start dragging
local function startDragging(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Target.Parent == menuGui then
        dragging = true
        dragStart = input.Position
        startPos = menuGui.Position
    end
end

-- Function to stop dragging
local function stopDragging()
    dragging = false
end

-- Function to update dragging position
local function updateDragging(input)
    if dragging then
        local delta = input.Position - dragStart
        menuGui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end

-- GUI Setup
local function createGui()
    if screenGui then screenGui:Destroy() end
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NoClipGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    -- Gear Button Setup
    gearButton = Instance.new("ImageButton")
    gearButton.Size = UDim2.new(0, 30, 0, 30)
    gearButton.Position = UDim2.new(0, 10, 0, 10)
    gearButton.Image = "rbxassetid://6031091005"
    gearButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    gearButton.BorderSizePixel = 2
    gearButton.BorderColor3 = Color3.fromRGB(255, 255, 0)
    gearButton.Parent = screenGui
    gearButton.MouseButton1Click:Connect(function()
        menuGui.Visible = not menuGui.Visible
        if speedGui then
            speedGui.Visible = false -- Close Speed GUI when the gear button is clicked
        end
    end)

    -- Menu GUI Setup
    menuGui = Instance.new("Frame")
    menuGui.Size = UDim2.new(0, 200, 0, 150)
    menuGui.Position = UDim2.new(0, 50, 0, 10)
    menuGui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    menuGui.BackgroundTransparency = 0.5
    menuGui.Visible = false
    menuGui.Parent = screenGui

    -- No-Clip Button Setup
    noClipButton = Instance.new("TextButton")
    noClipButton.Size = UDim2.new(1, 0, 0, 50)
    noClipButton.Position = UDim2.new(0, 0, 0, 0)
    noClipButton.Text = "No-Clip: Disabled"
    noClipButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    noClipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    noClipButton.BorderSizePixel = 2
    noClipButton.BorderColor3 = Color3.fromRGB(255, 255, 0)
    noClipButton.TextScaled = true
    noClipButton.Font = Enum.Font.SourceSansBold
    noClipButton.Parent = menuGui
    noClipButton.MouseButton1Click:Connect(toggleNoClip)

    -- Speed Button Setup
    speedButton = Instance.new("TextButton")
    speedButton.Size = UDim2.new(1, 0, 0, 50)
    speedButton.Position = UDim2.new(0, 0, 0, 60)
    speedButton.Text = "Speed"
    speedButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedButton.BorderSizePixel = 2
    speedButton.BorderColor3 = Color3.fromRGB(255, 255, 0)
    speedButton.TextScaled = true
    speedButton.Font = Enum.Font.SourceSansBold
    speedButton.Parent = menuGui
    speedButton.MouseButton1Click:Connect(function()
        speedGui.Visible = not speedGui.Visible
    end)

    -- Speed GUI Setup
    speedGui = Instance.new("Frame")
    speedGui.Size = UDim2.new(0, 200, 0, 150)
    speedGui.Position = UDim2.new(0, 50, 0, 170)
    speedGui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    speedGui.BackgroundTransparency = 0.5
    speedGui.Visible = false
    speedGui.Parent = screenGui

    -- Speed Input Box
    speedInputBox = Instance.new("TextBox")
    speedInputBox.Size = UDim2.new(1, 0, 0, 40)
    speedInputBox.Position = UDim2.new(0, 0, 0, 10)
    speedInputBox.PlaceholderText = "Enter Speed"
    speedInputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    speedInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedInputBox.BorderSizePixel = 2
    speedInputBox.BorderColor3 = Color3.fromRGB(255, 255, 0)
    speedInputBox.TextScaled = true
    speedInputBox.Font = Enum.Font.SourceSansBold
    speedInputBox.Parent = speedGui

    -- Apply Speed Button
    applySpeedButton = Instance.new("TextButton")
    applySpeedButton.Size = UDim2.new(1, 0, 0, 40)
    applySpeedButton.Position = UDim2.new(0, 0, 0, 60)
    applySpeedButton.Text = "Apply Speed"
    applySpeedButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    applySpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    applySpeedButton.BorderSizePixel = 2
    applySpeedButton.BorderColor3 = Color3.fromRGB(255, 255, 0)
    applySpeedButton.TextScaled = true
    applySpeedButton.Font = Enum.Font.SourceSansBold
    applySpeedButton.Parent = speedGui
    applySpeedButton.MouseButton1Click:Connect(function()
        local speedValue = tonumber(speedInputBox.Text)
        if speedValue then
            player.Character.Humanoid.WalkSpeed = speedValue
        end
    end)

    -- Reset Speed Button
    resetSpeedButton = Instance.new("TextButton")
    resetSpeedButton.Size = UDim2.new(1, 0, 0, 40)
    resetSpeedButton.Position = UDim2.new(0, 0, 0, 110)
    resetSpeedButton.Text = "Reset Speed"
    resetSpeedButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    resetSpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetSpeedButton.BorderSizePixel = 2
    resetSpeedButton.BorderColor3 = Color3.fromRGB(255, 255, 0)
    resetSpeedButton.TextScaled = true
    resetSpeedButton.Font = Enum.Font.SourceSansBold
    resetSpeedButton.Parent = speedGui
    resetSpeedButton.MouseButton1Click:Connect(function()
        player.Character.Humanoid.WalkSpeed = 16 -- Default speed value
    end)

    -- Click TP Button Setup
    clickTPButton = Instance.new("TextButton")
    clickTPButton.Size = UDim2.new(1, 0, 0, 50)
    clickTPButton.Position = UDim2.new(0, 0, 0, 120)
    clickTPButton.Text = "Click TP: Disabled"
    clickTPButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    clickTPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    clickTPButton.BorderSizePixel = 2
    clickTPButton.BorderColor3 = Color3.fromRGB(255, 255, 0)
    clickTPButton.TextScaled = true
    clickTPButton.Font = Enum.Font.SourceSansBold
    clickTPButton.Parent = menuGui
    clickTPButton.MouseButton1Click:Connect(function()
        clickTPEnabled = not clickTPEnabled
        clickTPButton.Text = "Click TP: " .. (clickTPEnabled and "Enabled" or "Disabled")
        createNotification("Click TP " .. (clickTPEnabled and "Enabled" or "Disabled"))
    end)
end

-- Function to handle input for toggling GUI visibility
local function onInputBegan(input)
    if input.KeyCode == Enum.KeyCode.U then
        guiVisible = not guiVisible
        if guiVisible then
            createGui()
        else
            if screenGui then screenGui:Destroy() end
        end
    end
end

-- Function to handle Click TP
local function onClickTP(input)
    if clickTPEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePosition = userInputService:GetMouseLocation()
        local targetPosition = workspace.CurrentCamera:ScreenToWorldPoint(Vector3.new(mousePosition.X, mousePosition.Y, 0))
        player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
    end
end

-- Connect input events
userInputService.InputBegan:Connect(onInputBegan)
userInputService.InputBegan:Connect(startDragging)
userInputService.InputEnded:Connect(stopDragging)
userInputService.InputChanged:Connect(updateDragging)
userInputService.InputBegan:Connect(onClickTP) -- Connect Click TP

-- Show notification for running the script
createNotification("GUI script loaded")
createGui() -- Initial creation of GUI

-- Monitor player character for No-Clip application
player.CharacterAdded:Connect(function(character)
    character.DescendantAdded:Connect(function(descendant)
        if noClip and descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
            descendant.CanCollide = false
        end
    end)
    applyNoClip(character)
end)
