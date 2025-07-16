--[[
    hikxxlib_rayfield_style.lua
    Discord-ish UI + top tab bar like Rayfield
    Close button + toggle with K key
    Buttons, toggles, sliders, textbox, color picker included

    By hikxx & ChatGPT 😎
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local lib = {}

-- Utils
local function create(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props) do inst[k] = v end
    return inst
end

-- Theme colors
local theme = {
    BG = Color3.fromRGB(30,31,35),
    Primary = Color3.fromRGB(43,45,49),
    Accent = Color3.fromRGB(88,101,242),
    Text = Color3.new(1,1,1),
    MutedText = Color3.fromRGB(150,150,150),
    Danger = Color3.fromRGB(237,66,69),
    Warning = Color3.fromRGB(255,204,0),
    Success = Color3.fromRGB(0,202,78),
}

-- MAIN GUI setup
local screengui = create("ScreenGui", {
    Name = "hikxx_UI",
    ResetOnSpawn = false,
    Parent = game.CoreGui
})

local mainFrame = create("Frame", {
    BackgroundColor3 = theme.BG,
    Size = UDim2.new(0, 800, 0, 500),
    Position = UDim2.new(0.5, -400, 0.5, -250),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BorderSizePixel = 0,
    Parent = screengui,
    Name = "MainFrame"
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = mainFrame})
create("UIStroke", {Color = Color3.fromRGB(20,20,20), Thickness = 1, Parent = mainFrame})

-- TOP BAR (holds title + tabs + close btn)
local topBar = create("Frame", {
    BackgroundColor3 = theme.Primary,
    Size = UDim2.new(1,0,0,40),
    Parent = mainFrame,
    Name = "TopBar"
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = topBar})

local title = create("TextLabel", {
    Text = "hikxx UI",
    Font = Enum.Font.GothamBold,
    TextColor3 = theme.Text,
    TextSize = 18,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 0),
    Size = UDim2.new(0, 150, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = topBar
})

-- TABS BAR container (horizontal)
local tabsBar = create("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 170, 0, 0),
    Size = UDim2.new(1, -210, 1, 0),
    Parent = topBar
})
create("UIListLayout", {
    Parent = tabsBar,
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 4)
})

-- Close button
local closeBtn = create("TextButton", {
    Text = "✕",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = theme.Text,
    BackgroundColor3 = theme.Danger,
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -40, 0, 5),
    Parent = topBar
})
create("UICorner", {CornerRadius = UDim.new(1,0), Parent = closeBtn})

closeBtn.MouseButton1Click:Connect(function()
    screengui.Enabled = false
end)

-- CONTENT area below top bar
local contentHolder = create("Frame", {
    BackgroundColor3 = theme.Primary,
    Position = UDim2.new(0, 0, 0, 40),
    Size = UDim2.new(1, 0, 1, -40),
    Parent = mainFrame
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = contentHolder})

-- For content, each tab has a Frame inside contentHolder, only one visible at a time
local tabs = {} -- {name=string, tabBtn=Instance, contentFrame=Instance}

-- Active tab helper
local function setActiveTab(tabName)
    for _, t in pairs(tabs) do
        if t.name == tabName then
            t.tabBtn.BackgroundColor3 = theme.Accent
            t.tabBtn.TextColor3 = theme.Text
            t.contentFrame.Visible = true
        else
            t.tabBtn.BackgroundColor3 = theme.Primary
            t.tabBtn.TextColor3 = theme.MutedText
            t.contentFrame.Visible = false
        end
    end
end

-- CreateTab function
function lib:CreateTab(name)
    -- Tab button on top bar
    local tabBtn = create("TextButton", {
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BackgroundColor3 = theme.Primary,
        TextColor3 = theme.MutedText,
        Size = UDim2.new(0, 100, 1, 0),
        Parent = tabsBar,
        AutoButtonColor = false,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = tabBtn})

    -- Content frame (scrolling)
    local contentFrame = create("ScrollingFrame", {
        BackgroundColor3 = theme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        Parent = contentHolder,
        Visible = false,
    })
    create("UIListLayout", {
        Parent = contentFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
    })

    -- Tab button click switches tabs
    tabBtn.MouseButton1Click:Connect(function()
        setActiveTab(name)
    end)

    -- Save tab
    local tabData = {
        name = name,
        tabBtn = tabBtn,
        contentFrame = contentFrame,
    }
    table.insert(tabs, tabData)

    -- Return API for this tab
    local api = {}

    function api:CreateLabel(text)
        create("TextLabel", {
            Text = text,
            Size = UDim2.new(1, -20, 0, 20),
            BackgroundTransparency = 1,
            TextColor3 = theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = contentFrame,
        })
    end

    function api:CreateButton(text, callback)
        local btn = create("TextButton", {
            Text = text,
            Size = UDim2.new(1, -20, 0, 30),
            BackgroundColor3 = theme.Accent,
            TextColor3 = theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            Parent = contentFrame,
        })
        create("UICorner", {Parent = btn})
        btn.MouseButton1Click:Connect(callback)
    end

    function api:CreateToggle(text, default, callback)
        local toggled = default or false

        local frame = create("Frame", {
            Size = UDim2.new(1, -20, 0, 30),
            BackgroundTransparency = 1,
            Parent = contentFrame
        })

        local label = create("TextLabel", {
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.8, 0, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })

        local toggleBtn = create("TextButton", {
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -45, 0, 5),
            BackgroundColor3 = toggled and theme.Accent or theme.Primary,
            AutoButtonColor = false,
            Parent = frame,
            Text = "",
        })
        create("UICorner", {Parent = toggleBtn})

        toggleBtn.MouseButton1Click:Connect(function()
            toggled = not toggled
            toggleBtn.BackgroundColor3 = toggled and theme.Accent or theme.Primary
            callback(toggled)
        end)

        -- Initial callback trigger
        if callback then callback(toggled) end
    end

    function api:CreateSlider(text, min, max, default, callback)
        local dragging = false
        local value = default or min

        local frame = create("Frame", {
            Size = UDim2.new(1, -20, 0, 40),
            BackgroundTransparency = 1,
            Parent = contentFrame
        })

        local label = create("TextLabel", {
            Text = text .. ": " .. tostring(value),
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = theme.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = frame
        })

        local sliderBar = create("Frame", {
            BackgroundColor3 = theme.Primary,
            Size = UDim2.new(1, 0, 0, 10),
            Position = UDim2.new(0, 0, 0, 25),
            Parent = frame
        })
        create("UICorner", {Parent = sliderBar})

        local sliderFill = create("Frame", {
            BackgroundColor3 = theme.Accent,
            Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
            Parent = sliderBar
        })
        create("UICorner", {Parent = sliderFill})

        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        sliderBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                if callback then callback(value) end
            end
        end)
        sliderBar.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relativeX = math.clamp(input.Position.X - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
                value = min + (relativeX / sliderBar.AbsoluteSize.X) * (max - min)
                sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                label.Text = text .. ": " .. string.format("%.2f", value)
                if callback then callback(value) end
            end
        end)
    end

    function api:CreateTextbox(text, placeholder, callback)
        local frame = create("Frame", {
            Size = UDim2.new(1, -20, 0, 40),
            BackgroundTransparency = 1,
            Parent = contentFrame
        })

        local label = create("TextLabel", {
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })

        local textbox = create("TextBox", {
            Text = "",
            PlaceholderText = placeholder or "",
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = theme.Text,
            BackgroundColor3 = theme.Primary,
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 20),
            ClearTextOnFocus = false,
            Parent = frame
        })
        create("UICorner", {Parent = textbox})

        textbox.FocusLost:Connect(function(enterPressed)
            if enterPressed and callback then
                callback(textbox.Text)
            end
        end)
    end

    -- Simple color picker (just 6 preset colors)
    function api:CreateColorPicker(text, defaultColor, callback)
        local colors = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(255, 0, 255),
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(0, 0, 0),
        }
        local frame = create("Frame", {
            Size = UDim2.new(1, -20, 0, 60),
            BackgroundTransparency = 1,
            Parent = contentFrame
        })

        local label = create("TextLabel", {
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = theme.Text,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })

        local colorsHolder = create("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, 25),
            BackgroundTransparency = 1,
            Parent = frame
        })
        local layout = create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            Parent = colorsHolder
        })

        for i, col in ipairs(colors) do
            local colorBtn = create("TextButton", {
                BackgroundColor3 = col,
                Size = UDim2.new(0, 30, 0, 30),
                AutoButtonColor = false,
                Parent = colorsHolder,
                Text = "",
            })
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = colorBtn})

            colorBtn.MouseButton1Click:Connect(function()
                if callback then callback(col) end
            end)
        end
    end

    return api
end

-- Auto activate first tab on creation
local firstTabCreated = false
function lib:AutoActivateFirstTab()
    if not firstTabCreated and #tabs > 0 then
        setActiveTab(tabs[1].name)
        firstTabCreated = true
    end
end

-- Toggle GUI visibility with K key
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.K then
        screengui.Enabled = not screengui.Enabled
    end
end)

-- Return the main API
lib.screengui = screengui
lib.theme = theme

return lib
