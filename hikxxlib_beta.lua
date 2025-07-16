-- hikxxlib_full.lua
-- Discord-style Roblox UI Lib with Toggles, Textboxes, Sliders, Color Picker & Settings Tab
-- By hikxx & ChatGPT 😎

pcall(function()
	if game.CoreGui:FindFirstChild("hikxx_UI") then
		game.CoreGui:FindFirstChild("hikxx_UI"):Destroy()
	end
end)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local lib = {player = player, char = char, humanoid = humanoid}

local function create(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		inst[k] = v
	end
	return inst
end

local theme = {
	BG = Color3.fromRGB(30, 31, 35),
	Primary = Color3.fromRGB(43, 45, 49),
	Accent = Color3.fromRGB(88, 101, 242),
	Text = Color3.new(1, 1, 1),
	MutedText = Color3.fromRGB(150, 150, 150),
	Hover = Color3.fromRGB(60, 63, 68)
}

-- Main GUI Container
local screengui = create("ScreenGui", {
	Name = "hikxx_UI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Global,
	Parent = game.CoreGui
})

local mainHolder = create("Frame", {
	BackgroundColor3 = theme.BG,
	Size = UDim2.new(0, 800, 0, 500),
	Position = UDim2.new(0.5, -400, 0.5, -250),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BorderSizePixel = 0,
	Parent = screengui,
	Name = "MainHolder"
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = mainHolder})
create("UIStroke", {Color = Color3.fromRGB(20, 20, 20), Thickness = 1, Parent = mainHolder})

-- TopBar with title and buttons
local topBar = create("Frame", {
	Size = UDim2.new(1, 0, 0, 30),
	BackgroundColor3 = theme.Primary,
	BorderSizePixel = 0,
	Parent = mainHolder
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = topBar})

local titleLabel = create("TextLabel", {
	Text = "hikxx UI",
	Font = Enum.Font.GothamBold,
	TextColor3 = theme.Text,
	TextSize = 16,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -90, 1, 0),
	Position = UDim2.new(0, 10, 0, 0),
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = topBar
})

local function createTopBtn(color, pos, callback)
	local btn = create("TextButton", {
		Size = UDim2.new(0, 20, 0, 20),
		Position = pos,
		BackgroundColor3 = color,
		Text = "",
		Parent = topBar,
		AutoButtonColor = false
	})
	create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = btn})
	btn.MouseEnter:Connect(function() btn.BackgroundColor3 = theme.Hover end)
	btn.MouseLeave:Connect(function() btn.BackgroundColor3 = color end)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- Close button
createTopBtn(Color3.fromRGB(237, 66, 69), UDim2.new(1, -30, 0.5, -10), function()
	mainHolder:Destroy()
end)
-- Minimize button
local minimizeBtn = createTopBtn(Color3.fromRGB(255, 204, 0), UDim2.new(1, -55, 0.5, -10), function()
	mainHolder.Visible = false
end)
-- Reset size button
createTopBtn(Color3.fromRGB(0, 202, 78), UDim2.new(1, -80, 0.5, -10), function()
	mainHolder.Size = UDim2.new(0, 800, 0, 500)
end)

-- Dragging the main window
local dragging, dragStart, startPos = false
topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainHolder.Position
	end
end)
topBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainHolder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Sidebar for servers (servers = groups of tabs)
local serverList = create("Frame", {
	Size = UDim2.new(0, 60, 1, -30),
	Position = UDim2.new(0, 0, 0, 30),
	BackgroundColor3 = theme.Primary,
	BorderSizePixel = 0,
	Parent = mainHolder
})

-- Tab container to the right of sidebar
local tabHolder = create("Frame", {
	Position = UDim2.new(0, 60, 0, 30),
	Size = UDim2.new(1, -60, 1, -30),
	BackgroundColor3 = theme.BG,
	BorderSizePixel = 0,
	Parent = mainHolder
})

-- Server creation
function lib:CreateServer(name, icon)
	local serverBtn = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 60),
		Text = icon,
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 28,
		BackgroundColor3 = theme.Primary,
		Parent = serverList,
		AutoButtonColor = false
	})
	create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = serverBtn})

	local serverFrame = create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = tabHolder
	})
	create("UIListLayout", {Parent = serverFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})

	serverBtn.MouseEnter:Connect(function() serverBtn.BackgroundColor3 = theme.Hover end)
	serverBtn.MouseLeave:Connect(function() serverBtn.BackgroundColor3 = theme.Primary end)

	serverBtn.MouseButton1Click:Connect(function()
		-- Hide all other serverFrames
		for _, f in pairs(tabHolder:GetChildren()) do
			if f:IsA("Frame") then
				f.Visible = false
			end
		end
		serverFrame.Visible = true
	end)

	local serverObj = {}

	function serverObj:CreateTab(tabname)
		local tabBtn = create("TextButton", {
			Size = UDim2.new(1, -20, 0, 30),
			Text = "# " .. tabname,
			TextColor3 = theme.Text,
			Font = Enum.Font.Gotham,
			TextSize = 16,
			BackgroundColor3 = theme.Primary,
			Parent = serverFrame,
			AutoButtonColor = false
		})
		create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = tabBtn})

		local content = create("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = false,
			ScrollBarThickness = 6,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Parent = tabHolder
		})
		local layout = create("UIListLayout", {
			Parent = content,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		tabBtn.MouseEnter:Connect(function() tabBtn.BackgroundColor3 = theme.Hover end)
		tabBtn.MouseLeave:Connect(function() tabBtn.BackgroundColor3 = theme.Primary end)

		tabBtn.MouseButton1Click:Connect(function()
			for _, f in pairs(tabHolder:GetChildren()) do
				if f:IsA("ScrollingFrame") then
					f.Visible = false
				end
			end
			content.Visible = true
		end)

		-- Update canvas size dynamically
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
		end)

		local tabApi = {}

		-- Label
		function tabApi:CreateLabel(text)
			local label = create("TextLabel", {
				Text = text,
				Size = UDim2.new(1, -20, 0, 20),
				BackgroundTransparency = 1,
				TextColor3 = theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = content
			})
			return label
		end

		-- Button
		function tabApi:CreateButton(name, callback)
			local btn = create("TextButton", {
				Text = name,
				Size = UDim2.new(1, -20, 0, 30),
				BackgroundColor3 = theme.Accent,
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				Parent = content,
				AutoButtonColor = false
			})
			create("UICorner", {Parent = btn})
			btn.MouseEnter:Connect(function() btn.BackgroundColor3 = theme.Hover end)
			btn.MouseLeave:Connect(function() btn.BackgroundColor3 = theme.Accent end)
			btn.MouseButton1Click:Connect(callback)
			return btn
		end

		-- Toggle (boolean switch)
		function tabApi:CreateToggle(name, default, callback)
			local frame = create("Frame", {
				Size = UDim2.new(1, -20, 0, 30),
				BackgroundTransparency = 1,
				Parent = content
			})
			local label = create("TextLabel", {
				Text = name,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -40, 1, 0),
				Parent = frame
			})
			local toggleBtn = create("TextButton", {
				Size = UDim2.new(0, 30, 0, 20),
				Position = UDim2.new(1, -30, 0.5, -10),
				BackgroundColor3 = default and theme.Accent or theme.Primary,
				BorderSizePixel = 0,
				Parent = frame,
				AutoButtonColor = false,
				Text = "",
			})
			create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = toggleBtn})

			local toggled = default or false
			local function setState(state)
				toggled = state
				toggleBtn.BackgroundColor3 = toggled and theme.Accent or theme.Primary
				if callback then
					callback(toggled)
				end
			end

			toggleBtn.MouseButton1Click:Connect(function()
				setState(not toggled)
			end)
			setState(toggled)

			return frame, function()
				return toggled
			end
		end

		-- Textbox (single-line input)
		function tabApi:CreateTextbox(name, default, callback)
			local frame = create("Frame", {
				Size = UDim2.new(1, -20, 0, 30),
				BackgroundTransparency = 1,
				Parent = content
			})
			local label = create("TextLabel", {
				Text = name,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.4, 0, 1, 0),
				Parent = frame
			})
			local textbox = create("TextBox", {
				Text = default or "",
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextColor3 = theme.Text,
				ClearTextOnFocus = false,
				BackgroundColor3 = theme.Primary,
				Size = UDim2.new(0.55, 0, 0.75, 0),
				Position = UDim2.new(0.42, 0, 0.12, 0),
				BorderSizePixel = 0,
				Parent = frame
			})
			create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = textbox})

			textbox.FocusLost:Connect(function(enterPressed)
				if enterPressed and callback then
					callback(textbox.Text)
				end
			end)

			return frame, textbox
		end

		-- Slider (number range input)
		function tabApi:CreateSlider(name, min, max, default, callback)
			local frame = create("Frame", {
				Size = UDim2.new(1, -20, 0, 40),
				BackgroundTransparency = 1,
				Parent = content
			})
			local label = create("TextLabel", {
				Text = name,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.6, 0, 0.4, 0),
				Position = UDim2.new(0, 0, 0, 0),
				Parent = frame
			})
			local valueLabel = create("TextLabel", {
				Text = tostring(default),
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Right,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.3, 0, 0.4, 0),
				Position = UDim2.new(0.7, 0, 0, 0),
				Parent = frame
			})

			local sliderBack = create("Frame", {
				Size = UDim2.new(1, -20, 0, 12),
				Position = UDim2.new(0, 10, 0, 25),
				BackgroundColor3 = theme.Primary,
				BorderSizePixel = 0,
				Parent = frame
			})
			create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = sliderBack})

			local sliderFill = create("Frame", {
				Size = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = theme.Accent,
				Parent = sliderBack
			})
			create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = sliderFill})

			local minVal, maxVal = min or 0, max or 100
			local currentVal = math.clamp(default or minVal, minVal, maxVal)

			local function updateSlider(posX)
				local relativePos = math.clamp(posX - sliderBack.AbsolutePosition.X, 0, sliderBack.AbsoluteSize.X)
				local percent = relativePos / sliderBack.AbsoluteSize.X
				currentVal = minVal + (maxVal - minVal) * percent
				currentVal = math.floor(currentVal * 100) / 100
				sliderFill.Size = UDim2.new(percent, 0, 1, 0)
				valueLabel.Text = tostring(currentVal)
				if callback then
					callback(currentVal)
				end
			end

			sliderBack.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					updateSlider(input.Position.X)
					local moveConn
					moveConn = UserInputService.InputChanged:Connect(function(moveInput)
						if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
							updateSlider(moveInput.Position.X)
						end
					end)
					UserInputService.InputEnded:Wait()
					moveConn:Disconnect()
				end
			end)

			sliderBack.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
					updateSlider(input.Position.X)
				end
			end)

			-- Init fill size
			delay(0, function()
				local percent = (currentVal - minVal) / (maxVal - minVal)
				sliderFill.Size = UDim2.new(percent, 0, 1, 0)
				valueLabel.Text = tostring(currentVal)
			end)

			return frame, function()
				return currentVal
			end
		end

		-- Color picker (simple RGB picker)
		function tabApi:CreateColorPicker(name, defaultColor, callback)
			local frame = create("Frame", {
				Size = UDim2.new(1, -20, 0, 60),
				BackgroundTransparency = 1,
				Parent = content
			})
			local label = create("TextLabel", {
				Text = name,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 20),
				Parent = frame
			})

			local colorPreview = create("Frame", {
				Size = UDim2.new(0, 40, 0, 20),
				Position = UDim2.new(0, 10, 0, 30),
				BackgroundColor3 = defaultColor or theme.Accent,
				BorderSizePixel = 0,
				Parent = frame
			})
			create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = colorPreview})

			local pickerOpen = false

			local pickerFrame = create("Frame", {
				Size = UDim2.new(0, 220, 0, 150),
				BackgroundColor3 = theme.Primary,
				Position = UDim2.new(0, 50, 0, 30),
				Visible = false,
				Parent = frame
			})
			create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = pickerFrame})
			create("UIStroke", {Color = Color3.fromRGB(20, 20, 20), Thickness = 1, Parent = pickerFrame})

			local function updatePreviewColor(c)
				colorPreview.BackgroundColor3 = c
				if callback then callback(c) end
			end

			local color = defaultColor or Color3.new(1, 1, 1)
			updatePreviewColor(color)

			-- We'll make a simple hue/saturation/value picker using three sliders:

			local hueSlider, satSlider, valSlider
			local function RGBtoHSV(c)
				local r, g, b = c.R, c.G, c.B
				local maxc = math.max(r, g, b)
				local minc = math.min(r, g, b)
				local v = maxc
				local s = 0
				local h = 0

				local delta = maxc - minc
				if maxc ~= 0 then
					s = delta / maxc
				else
					s = 0
					h = -1
					return h, s, v
				end

				if r == maxc then
					h = (g - b) / delta
				elseif g == maxc then
					h = 2 + (b - r) / delta
				else
					h = 4 + (r - g) / delta
				end

				h = h * 60
				if h < 0 then h = h + 360 end
				return h, s, v
			end

			local function HSVtoRGB(h, s, v)
				local c = v * s
				local x = c * (1 - math.abs(((h / 60) % 2) - 1))
				local m = v - c
				local r, g, b = 0, 0, 0

				if h < 60 then r, g, b = c, x, 0
				elseif h < 120 then r, g, b = x, c, 0
				elseif h < 180 then r, g, b = 0, c, x
				elseif h < 240 then r, g, b = 0, x, c
				elseif h < 300 then r, g, b = x, 0, c
				else r, g, b = c, 0, x
				end

				return Color3.new(r + m, g + m, b + m)
			end

			local h, s, v = RGBtoHSV(color)

			-- Hue slider
			local hueLabel = create("TextLabel", {
				Text = "Hue",
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.3, 0, 0, 18),
				Position = UDim2.new(0, 10, 0, 0),
				Parent = pickerFrame
			})
			hueSlider, _ = tabApi:CreateSlider("Hue", 0, 360, h, function(newH)
				h = newH
				color = HSVtoRGB(h, s, v)
				updatePreviewColor(color)
			end)
			hueSlider.Parent = pickerFrame
			hueSlider.Position = UDim2.new(0, 10, 0, 18)

			-- Saturation slider
			local satLabel = create("TextLabel", {
				Text = "Sat",
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.3, 0, 0, 18),
				Position = UDim2.new(0, 10, 0, 50),
				Parent = pickerFrame
			})
			satSlider, _ = tabApi:CreateSlider("Saturation", 0, 1, s, function(newS)
				s = newS
				color = HSVtoRGB(h, s, v)
				updatePreviewColor(color)
			end)
			satSlider.Parent = pickerFrame
			satSlider.Position = UDim2.new(0, 10, 0, 68)

			-- Value slider
			local valLabel = create("TextLabel", {
				Text = "Value",
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.3, 0, 0, 18),
				Position = UDim2.new(0, 10, 0, 90),
				Parent = pickerFrame
			})
			valSlider, _ = tabApi:CreateSlider("Value", 0, 1, v, function(newV)
				v = newV
				color = HSVtoRGB(h, s, v)
				updatePreviewColor(color)
			end)
			valSlider.Parent = pickerFrame
			valSlider.Position = UDim2.new(0, 10, 0, 108)

			-- Toggle picker visibility on click
			colorPreview.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					pickerOpen = not pickerOpen
					pickerFrame.Visible = pickerOpen
				end
			end)

			return frame, function()
				return color
			end
		end

		return tabApi
	end

	return serverObj
end

-- Create your servers and tabs here

-- Example: Main server & tabs
local mainServer = lib:CreateServer("Main", "🏠")
mainServer:CreateTab("General")
local toggleTab = mainServer:CreateTab("Toggles")
local colorTab = mainServer:CreateTab("Colors")

-- Settings server with permanent keybind tab
local settingsServer = lib:CreateServer("Settings", "⚙️")
local settingsTab = settingsServer:CreateTab("Keybinds")

-- Show main server and tab by default
local firstServerBtn = serverList:FindFirstChildWhichIsA("TextButton")
if firstServerBtn then
	firstServerBtn.MouseButton1Click:Wait()
end
local firstTab = tabHolder:FindFirstChildWhichIsA("ScrollingFrame")
if firstTab then
	firstTab.Visible = true
end

-- Toggles example usage
toggleTab:CreateToggle("Enable Cool Mode", false, function(val)
	print("Cool Mode toggled:", val)
end)

-- Color picker example usage
colorTab:CreateColorPicker("Pick your color", Color3.fromRGB(88, 101, 242), function(c)
	print("Color picked:", c)
end)

-- Textbox example usage
local txt, txtbox = mainServer:CreateTab("Input"):CreateTextbox("Your name", "hikxx", function(text)
	print("Text input:", text)
end)

return lib
