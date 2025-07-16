-- hikxxlib_beta.lua
-- Discord-style Roblox UI library by hikxx & ChatGPT 😎

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local lib = {}
lib.player = player
lib.char = char
lib.humanoid = humanoid

local theme = {
	BG = Color3.fromRGB(30,31,35),
	Primary = Color3.fromRGB(43,45,49),
	Accent = Color3.fromRGB(88,101,242),
	Text = Color3.new(1,1,1),
	MutedText = Color3.fromRGB(150,150,150),
}

local function create(class, props)
	local inst = Instance.new(class)
	for k,v in pairs(props) do
		inst[k] = v
	end
	return inst
end

local screengui = create("ScreenGui", {
	Name = "hikxx_UI",
	ResetOnSpawn = false,
	Parent = game.CoreGui,
	ZIndexBehavior = Enum.ZIndexBehavior.Global
})

local mainFrame = create("Frame", {
	Size = UDim2.new(0, 700, 0, 450),
	Position = UDim2.new(0.5, -350, 0.5, -225),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = theme.BG,
	BorderSizePixel = 0,
	Parent = screengui
})
create("UICorner", {Parent = mainFrame, CornerRadius = UDim.new(0,10)})

-- Top bar (dragging)
local topBar = create("Frame", {
	Size = UDim2.new(1,0,0,30),
	BackgroundColor3 = theme.Primary,
	Parent = mainFrame,
	BorderSizePixel = 0,
})
create("UICorner", {Parent = topBar, CornerRadius = UDim.new(0,10)})

local title = create("TextLabel", {
	Text = "hikxx UI Library",
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	TextColor3 = theme.Text,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -20, 1, 0),
	Position = UDim2.new(0, 10, 0, 0),
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = topBar,
})

-- Dragging logic
local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
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
topBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Container for content
local contentHolder = create("ScrollingFrame", {
	Position = UDim2.new(0, 10, 0, 40),
	Size = UDim2.new(1, -20, 1, -50),
	BackgroundTransparency = 1,
	ScrollBarThickness = 6,
	CanvasSize = UDim2.new(0,0,0,0),
	Parent = mainFrame,
})
local layout = create("UIListLayout", {
	Parent = contentHolder,
	Padding = UDim.new(0,10),
	SortOrder = Enum.SortOrder.LayoutOrder,
})

-- Update CanvasSize when content changes
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	contentHolder.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)
end)

-- UI Elements API
local api = {}

-- Label
function api:CreateLabel(text)
	local lbl = create("TextLabel", {
		Text = text,
		Size = UDim2.new(1, 0, 0, 25),
		BackgroundTransparency = 1,
		TextColor3 = theme.Text,
		Font = Enum.Font.Gotham,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = contentHolder,
	})
	return lbl
end

-- Button
function api:CreateButton(text, callback)
	local btn = create("TextButton", {
		Text = text,
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = theme.Accent,
		TextColor3 = Color3.new(1,1,1),
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		AutoButtonColor = false,
		Parent = contentHolder,
	})
	create("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = theme.Primary}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = theme.Accent}):Play()
	end)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- Toggle
function api:CreateToggle(text, default, callback)
	local holder = create("Frame", {
		Size = UDim2.new(1,0,0,35),
		BackgroundTransparency = 1,
		Parent = contentHolder,
	})
	local label = create("TextLabel", {
		Text = text,
		Size = UDim2.new(0.8, 0, 1, 0),
		BackgroundTransparency = 1,
		TextColor3 = theme.Text,
		Font = Enum.Font.Gotham,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})
	local toggleBtn = create("TextButton", {
		Size = UDim2.new(0, 40, 0, 25),
		Position = UDim2.new(0.85, 0, 0.1, 0),
		BackgroundColor3 = default and theme.Accent or theme.Primary,
		AutoButtonColor = false,
		Text = "",
		Parent = holder,
	})
	create("UICorner", {Parent = toggleBtn, CornerRadius = UDim.new(0,12)})

	local toggled = default
	toggleBtn.MouseButton1Click:Connect(function()
		toggled = not toggled
		toggleBtn.BackgroundColor3 = toggled and theme.Accent or theme.Primary
		callback(toggled)
	end)
	return holder
end

-- Slider
function api:CreateSlider(text, min, max, default, callback)
	local holder = create("Frame", {
		Size = UDim2.new(1,0,0,50),
		BackgroundTransparency = 1,
		Parent = contentHolder,
	})
	local label = create("TextLabel", {
		Text = text .. ": " .. tostring(default),
		Size = UDim2.new(1,0,0,20),
		BackgroundTransparency = 1,
		TextColor3 = theme.Text,
		Font = Enum.Font.Gotham,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})
	local sliderBar = create("Frame", {
		Size = UDim2.new(1, 0, 0, 15),
		Position = UDim2.new(0, 0, 0, 30),
		BackgroundColor3 = theme.Primary,
		Parent = holder,
	})
	create("UICorner", {Parent = sliderBar, CornerRadius = UDim.new(0,8)})
	local sliderFill = create("Frame", {
		Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = theme.Accent,
		Parent = sliderBar,
	})
	create("UICorner", {Parent = sliderFill, CornerRadius = UDim.new(0,8)})

	local dragging = false
	sliderBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)
	sliderBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	sliderBar.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local relativeX = math.clamp(input.Position.X - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
			local value = min + (relativeX / sliderBar.AbsoluteSize.X) * (max - min)
			sliderFill.Size = UDim2.new(relativeX / sliderBar.AbsoluteSize.X, 0, 1, 0)
			label.Text = string.format("%s: %.2f", text, value)
			callback(value)
		end
	end)

	return holder
end

-- Textbox
function api:CreateTextbox(text, placeholder, callback)
	local holder = create("Frame", {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		Parent = contentHolder,
	})
	local label = create("TextLabel", {
		Text = text,
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		TextColor3 = theme.Text,
		Font = Enum.Font.Gotham,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})
	local textbox = create("TextBox", {
		Size = UDim2.new(1, 0, 0, 25),
		Position = UDim2.new(0, 0, 0, 25),
		BackgroundColor3 = theme.Primary,
		TextColor3 = theme.Text,
		Font = Enum.Font.Gotham,
		TextSize = 16,
		Text = "",
		PlaceholderText = placeholder or "",
		ClearTextOnFocus = false,
		Parent = holder,
	})
	create("UICorner", {Parent = textbox, CornerRadius = UDim.new(0,6)})

	textbox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			callback(textbox.Text)
		end
	end)

	return holder
end

-- Color Picker (simple RGB slider)
function api:CreateColorPicker(text, defaultColor, callback)
	local holder = create("Frame", {
		Size = UDim2.new(1, 0, 0, 140),
		BackgroundTransparency = 1,
		Parent = contentHolder,
	})
	local label = create("TextLabel", {
		Text = text,
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		TextColor3 = theme.Text,
		Font = Enum.Font.Gotham,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})

	local colorPreview = create("Frame", {
		Size = UDim2.new(1, 0, 0, 25),
		Position = UDim2.new(0,0,0,25),
		BackgroundColor3 = defaultColor or Color3.new(1,0,0),
		Parent = holder,
	})
	create("UICorner", {Parent = colorPreview, CornerRadius = UDim.new(0,6)})

	local rSlider = api:CreateSlider("Red", 0, 1, defaultColor and defaultColor.R or 1, function(v)
		local c = colorPreview.BackgroundColor3
		colorPreview.BackgroundColor3 = Color3.new(v, c.G, c.B)
		callback(colorPreview.BackgroundColor3)
	end)
	rSlider.Parent = holder
	rSlider.Position = UDim2.new(0, 0, 0, 55)

	local gSlider = api:CreateSlider("Green", 0, 1, defaultColor and defaultColor.G or 0, function(v)
		local c = colorPreview.BackgroundColor3
		colorPreview.BackgroundColor3 = Color3.new(c.R, v, c.B)
		callback(colorPreview.BackgroundColor3)
	end)
	gSlider.Parent = holder
	gSlider.Position = UDim2.new(0, 0, 0, 90)

	local bSlider = api:CreateSlider("Blue", 0, 1, defaultColor and defaultColor.B or 0, function(v)
		local c = colorPreview.BackgroundColor3
		colorPreview.BackgroundColor3 = Color3.new(c.R, c.G, v)
		callback(colorPreview.BackgroundColor3)
	end)
	bSlider.Parent = holder
	bSlider.Position = UDim2.new(0, 0, 0, 125)

	return holder
end

lib.api = api

-- Toggle UI visibility with RightCtrl (customize here)
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightControl then
		screengui.Enabled = not screengui.Enabled
	end
end)

return lib
