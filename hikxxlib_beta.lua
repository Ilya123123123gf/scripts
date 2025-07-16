local Players = game:GetService("Players")
local player = Players.LocalPlayer

local lib = {}

local theme = {
    BG = Color3.fromRGB(30, 31, 35),
    Primary = Color3.fromRGB(43, 45, 49),
    Accent = Color3.fromRGB(88, 101, 242),
    Text = Color3.new(1, 1, 1),
    MutedText = Color3.fromRGB(150, 150, 150)
}

local screengui = Instance.new("ScreenGui")
screengui.Name = "hikxx_UI"
screengui.ResetOnSpawn = false
screengui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = theme.BG
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Parent = screengui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 150, 1, 0)
leftPanel.BackgroundColor3 = theme.Primary
leftPanel.Parent = mainFrame

Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 8)

local serverList = Instance.new("ScrollingFrame")
serverList.Size = UDim2.new(1, 0, 0.3, 0)
serverList.BackgroundTransparency = 1
serverList.ScrollBarThickness = 4
serverList.Parent = leftPanel

local serverLayout = Instance.new("UIListLayout")
serverLayout.Parent = serverList
serverLayout.SortOrder = Enum.SortOrder.LayoutOrder
serverLayout.Padding = UDim.new(0, 5)

local categoryList = Instance.new("ScrollingFrame")
categoryList.Size = UDim2.new(1, 0, 0.7, 0)
categoryList.Position = UDim2.new(0, 0, 0.3, 0)
categoryList.BackgroundTransparency = 1
categoryList.ScrollBarThickness = 4
categoryList.Parent = leftPanel

local categoryLayout = Instance.new("UIListLayout")
categoryLayout.Parent = categoryList
categoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
categoryLayout.Padding = UDim.new(0, 3)

local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(1, -150, 1, 0)
rightPanel.Position = UDim2.new(0, 150, 0, 0)
rightPanel.BackgroundColor3 = theme.Primary
rightPanel.Parent = mainFrame

Instance.new("UICorner", rightPanel).CornerRadius = UDim.new(0, 8)

local rightContent = Instance.new("Frame")
rightContent.Size = UDim2.new(1, -20, 1, -20)
rightContent.Position = UDim2.new(0, 10, 0, 10)
rightContent.BackgroundTransparency = 1
rightContent.Parent = rightPanel

local rightLayout = Instance.new("UIListLayout")
rightLayout.Parent = rightContent
rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
rightLayout.Padding = UDim.new(0, 8)

local servers = {}
local categories = {}
local buttonsForCategory = {}

local function clearFrame(frame)
    for _, child in ipairs(frame:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

local selectedCategory = nil

local function selectCategory(catName)
    selectedCategory = catName
    clearFrame(rightContent)

    local buttons = buttonsForCategory[catName] or {}
    for _, btnData in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = theme.Accent
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.Text = btnData.name
        btn.Parent = rightContent
        btn.AutoButtonColor = true

        btn.MouseButton1Click:Connect(function()
            btnData.callback()
        end)

        Instance.new("UICorner", btn)
    end
end

function lib:CreateServer(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = theme.BG
    btn.Text = icon or name:sub(1,1)
    btn.TextColor3 = theme.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.Parent = serverList
    btn.AutoButtonColor = true

    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        clearFrame(categoryList)
        categories[name] = categories[name] or {}

        for _, catName in ipairs(categories[name]) do
            local catBtn = Instance.new("TextButton")
            catBtn.Size = UDim2.new(1, 0, 0, 30)
            catBtn.BackgroundColor3 = theme.BG
            catBtn.TextColor3 = theme.Text
            catBtn.Font = Enum.Font.Gotham
            catBtn.TextSize = 16
            catBtn.Text = catName
            catBtn.Parent = categoryList
            catBtn.AutoButtonColor = true

            Instance.new("UICorner", catBtn)

            catBtn.MouseButton1Click:Connect(function()
                selectCategory(catName)
            end)
        end
    end)

    servers[name] = btn

    return {
        AddCategory = function(catName)
            categories[name] = categories[name] or {}
            table.insert(categories[name], catName)
            buttonsForCategory[catName] = {}
        end,

        AddButtonToCategory = function(catName, btnName, callback)
            buttonsForCategory[catName] = buttonsForCategory[catName] or {}
            table.insert(buttonsForCategory[catName], {name = btnName, callback = callback})
        end
    }
end

return lib
