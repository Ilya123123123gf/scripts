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
	Size = UDim2.new(1, -60, 1, 0),
	Position = UDim2.new(0, 10, 0, 0),
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = topBar,
})

local closeBtn = create("TextButton", {
	Text = "X",
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	TextColor3 = Color3.new(1, 1, 1),
	BackgroundColor3 = theme.Accent,
	Size = UDim2.new(0, 30, 1, 0),
	Position = UDim2.new(1, -35, 0, 0),
	AutoButtonColor = false,
	Parent = topBar,
})
create("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0,6)})

closeBtn.MouseEnter:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200,50,50)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.Accent}):Play()
end)
closeBtn.MouseButton1Click:Connect(function()
	screengui.Enabled = not screengui.Enabled
end)

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

local tabBar = create("Frame", {
	Size = UDim2.new(1, 0, 0, 30),
	Position = UDim2.new(0, 0, 0, 30),
	BackgroundColor3 = theme.Primary,
	Parent = mainFrame,
	BorderSizePixel = 0,
})
create("UICorner", {Parent = tabBar, CornerRadius = UDim.new(0, 6)})

local tabLayout = create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = tabBar,
	Padding = UDim.new(0, 5),
})

local contentArea = create("Frame", {
	Size = UDim2.new(1, -20, 1, -70),
	Position = UDim2.new(0, 10, 0, 60),
	BackgroundTransparency = 1,
	Parent = mainFrame,
})

local tabs = {}
local currentTab = nil

function lib:AddTab(name)
	local tabButton = create("TextButton", {
		Text = name,
		Size = UDim2.new(0, 100, 1, 0),
		BackgroundColor3 = theme.Primary,
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		AutoButtonColor = false,
		Parent = tabBar,
	})
	create("UICorner", {Parent = tabButton, CornerRadius = UDim.new(0, 6)})

	local tabContent = create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0,0,0,0),
		ScrollBarThickness = 6,
		BackgroundTransparency = 1,
		Visible = false,
		Parent = contentArea,
	})
	local contentLayout = create("UIListLayout", {
		Parent = tabContent,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
	end)

	tabButton.MouseButton1Click:Connect(function()
		for _, t in pairs(tabs) do
			t.content.Visible = false
			t.button.BackgroundColor3 = theme.Primary
		end
		tabContent.Visible = true
		tabButton.BackgroundColor3 = theme.Accent
		currentTab = tabContent
	end)

	table.insert(tabs, {button = tabButton, content = tabContent})
	if #tabs == 1 then
		tabButton.BackgroundColor3 = theme.Accent
		tabContent.Visible = true
		currentTab = tabContent
	end

	return tabContent
end

local api = {}

function api:CreateLabel(text)
	local lbl = create("TextLabel", {
		Text = text,
		Size = UDim2.new(1, 0, 0, 25),
		BackgroundTransparency = 1,
		TextColor3 = theme.Text,
		Font = Enum.Font.Gotham,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = currentTab,
	})
	return lbl
end

function api:CreateButton(text, callback)
	local btn = create("TextButton", {
		Text = text,
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = theme.Accent,
		TextColor3 = Color3.new(1,1,1),
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		AutoButtonColor = false,
		Parent = currentTab,
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

function api:CreateToggle(text, default, callback)
	local holder = create("Frame", {
		Size = UDim2.new(1,0,0,35),
		BackgroundTransparency = 1,
		Parent = currentTab,
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
		Size = UDim2.new(0, 40, 0, 20),
		Position = UDim2.new(0.85, 0, 0.25, 0),
		BackgroundColor3 = default and theme.Accent or theme.Primary,
		AutoButtonColor = false,
		Parent = holder,
	})
	create("UICorner", {Parent = toggleBtn, CornerRadius = UDim.new(0,6)})

	local toggled = default or false

	toggleBtn.MouseButton1Click:Connect(function()
		toggled = not toggled
		toggleBtn.BackgroundColor3 = toggled and theme.Accent or theme.Primary
		if callback then
			callback(toggled)
		end
	end)

	return holder
end

function api:CreateSlider(text, min, max, default, callback)
	local holder = create("Frame", {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		Parent = currentTab,
	})
	local label = create("TextLabel", {
		Text = text .. " : " .. default,
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		TextColor3 = theme.Text,
		Font = Enum.Font.Gotham,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})

	local sliderBg = create("Frame", {
		Size = UDim2.new(1, 0, 0, 10),
		Position = UDim2.new(0, 0, 0, 30),
		BackgroundColor3 = theme.Primary,
		Parent = holder,
	})
	create("UICorner", {Parent = sliderBg, CornerRadius = UDim.new(0, 5)})

	local sliderFill = create("Frame", {
		Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = theme.Accent,
		Parent = sliderBg,
	})
	create("UICorner", {Parent = sliderFill, CornerRadius = UDim.new(0, 5)})

	local dragging = false
	sliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			local function move(input2)
				local pos = math.clamp(input2.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
				local value = (pos / sliderBg.AbsoluteSize.X) * (max - min) + min
				sliderFill.Size = UDim2.new(pos / sliderBg.AbsoluteSize.X, 0, 1, 0)
				label.Text = text .. " : " .. math.floor(value)
				if callback then callback(value) end
			end
			move(input)
			local conn
			conn = UserInputService.InputChanged:Connect(function(input3)
				if input3 == input2 or input3.UserInputType == Enum.UserInputType.MouseMovement then
					move(input3)
				end
			end)
			UserInputService.InputEnded:Connect(function(input4)
				if input4.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
					conn:Disconnect()
				end
			end)
		end
	end)

	return holder
end

function api:CreateTextbox(placeholder, callback)
	local tb = create("TextBox", {
		Size = UDim2.new(1, 0, 0, 30),
		PlaceholderText = placeholder,
		ClearTextOnFocus = false,
		BackgroundColor3 = theme.Primary,
		TextColor3 = theme.Text,
		Font = Enum.Font.Gotham,
		TextSize = 16,
		Parent = currentTab,
	})
	create("UICorner", {Parent = tb, CornerRadius = UDim.new(0, 6)})

	tb.FocusLost:Connect(function(enterPressed)
		if enterPressed and callback then
			callback(tb.Text)
		end
	end)
	return tb
end

-- Expose API for current tab
function lib:CurrentTabAPI()
	return api
end

-- Keybind to toggle UI visibility: K
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
		screengui.Enabled = not screengui.Enabled
	end
end)

return lib
