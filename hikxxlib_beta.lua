--// UI LIBRARY WITH KEY SYSTEM
local Settings = getgenv().libSettings or {}
local guiName = Settings.guiName or "MyUI"
local toggleKey = Settings.toggleKey or Enum.KeyCode.RightControl
local requireKey = Settings.keyRequired or false
local correctKey = Settings.key or "default"
local allowRetry = Settings.allowRetry ~= false

local savedKey = getgenv().SavedKey
if requireKey and savedKey ~= correctKey then
    local function promptKey()
        local input = nil
        repeat
            input = tostring(rconsoleinput("Enter Key to access GUI: "))
        until not requireKey or input == correctKey or not allowRetry
        if input == correctKey then
            getgenv().SavedKey = input
        else
            error("Invalid key. Access denied.")
        end
    end
    promptKey()
end

local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")

local gui = Instance.new("ScreenGui")
gui.Name = guiName
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 500, 0, 350)
main.Position = UDim2.new(0.5, -250, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BorderSizePixel = 0
main.Visible = true
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Parent = gui

local uicorner = Instance.new("UICorner", main)
uicorner.CornerRadius = UDim.new(0, 8)

local titleBar = Instance.new("TextLabel")
titleBar.Text = guiName
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 18
titleBar.BackgroundTransparency = 1
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.Parent = main

local tabsHolder = Instance.new("Frame")
tabsHolder.Size = UDim2.new(0, 120, 1, -30)
tabsHolder.Position = UDim2.new(0, 0, 0, 30)
tabsHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
tabsHolder.BorderSizePixel = 0
tabsHolder.Parent = main

local UICorner = Instance.new("UICorner", tabsHolder)
UICorner.CornerRadius = UDim.new(0, 6)

local tabList = Instance.new("UIListLayout", tabsHolder)
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Padding = UDim.new(0, 4)

local pages = Instance.new("Frame")
pages.Position = UDim2.new(0, 130, 0, 30)
pages.Size = UDim2.new(1, -130, 1, -30)
pages.BackgroundTransparency = 1
pages.Name = "Pages"
pages.Parent = main

local function createTab(tabName)
    local button = Instance.new("TextButton")
    button.Text = tabName
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Position = UDim2.new(0, 5, 0, 0)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Parent = tabsHolder

    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 5)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 5
    page.Visible = false
    page.Parent = pages
    page.Name = tabName

    local list = Instance.new("UIListLayout", page)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 6)

    local function showPage()
        for _, v in ipairs(pages:GetChildren()) do
            if v:IsA("ScrollingFrame") then
                v.Visible = false
            end
        end
        page.Visible = true
    end

    button.MouseButton1Click:Connect(showPage)
    return page
end

local function createButton(tab, text, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.AutoButtonColor = true
    btn.Parent = tab

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
end

local function createToggle(tab, text, default, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(80, 80, 80)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.AutoButtonColor = true
    btn.Parent = tab

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 5)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(80, 80, 80)
        pcall(callback, state)
    end)
end

local function createTextbox(tab, placeholder, callback)
    local box = Instance.new("TextBox")
    box.PlaceholderText = placeholder
    box.Size = UDim2.new(1, -10, 0, 30)
    box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.ClearTextOnFocus = false
    box.Parent = tab

    local corner = Instance.new("UICorner", box)
    corner.CornerRadius = UDim.new(0, 5)

    box.FocusLost:Connect(function(enter)
        if enter then
            pcall(callback, box.Text)
        end
    end)
end

local function createSlider(tab, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = tab

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = name .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.Parent = frame

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, 0, 0, 20)
    slider.Position = UDim2.new(0, 0, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    slider.Text = ""
    slider.AutoButtonColor = false
    slider.Parent = frame

    local corner = Instance.new("UICorner", slider)
    corner.CornerRadius = UDim.new(0, 5)

    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    uis.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local value = math.floor((min + (max - min) * pos) + 0.5)
            label.Text = name .. ": " .. tostring(value)
            pcall(callback, value)
        end
    end)
end

local function createColorPicker(tab, name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.BackgroundColor3 = default
    frame.Parent = tab

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.Parent = frame

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 5)

    frame.MouseButton1Click:Connect(function()
        -- no color wheel rn, so just random color picker example:
        local color = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
        frame.BackgroundColor3 = color
        pcall(callback, color)
    end)
end

-- Make draggable
local dragToggle, dragInput, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)
main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
uis.InputChanged:Connect(function(input)
    if input == dragInput and dragToggle then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Toggle UI
uis.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == toggleKey then
        main.Visible = not main.Visible
    end
end)

-- Create default Settings tab
local settingsTab = createTab("⚙️ Settings")
createTextbox(settingsTab, "Paste your code here", function(txt) print("textbox:", txt) end)
createSlider(settingsTab, "Volume", 0, 100, 50, function(val) print("slider:", val) end)
createColorPicker(settingsTab, "Accent", Color3.fromRGB(255,0,0), function(col) print("color:", col) end)

-- EXPORT
_G.HikLib = {
    CreateTab = createTab,
    Button = createButton,
    Toggle = createToggle,
    Textbox = createTextbox,
    Slider = createSlider,
    Picker = createColorPicker
}
