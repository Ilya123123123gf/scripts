local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local library = {}
library.__index = library

local function createUICorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function tween(object, properties, time)
	return TweenService:Create(object, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad), properties)
end

function library:CreateWindow(title)
	local self = setmetatable({}, library)
	self.WindowVisible = true
	self.Tabs = {}
	self.TabButtons = {}

	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "hikxxLib"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.Parent = game.CoreGui

	self.MainFrame = Instance.new("Frame")
	self.MainFrame.Size = UDim2.new(0, 700, 0, 500)
	self.MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
	self.MainFrame.BackgroundColor3 = Color3.fromRGB(30, 31, 35)
	self.MainFrame.BorderSizePixel = 0
	self.MainFrame.Parent = self.ScreenGui
	createUICorner(self.MainFrame, 8)

	self.TopBar = Instance.new("Frame")
	self.TopBar.Size = UDim2.new(1, 0, 0, 30)
	self.TopBar.BackgroundColor3 = Color3.fromRGB(43, 45, 49)
	self.TopBar.Parent = self.MainFrame
	createUICorner(self.TopBar, 8)

	self.Title = Instance.new("TextLabel")
	self.Title.BackgroundTransparency = 1
	self.Title.Size = UDim2.new(1, -50, 1, 0)
	self.Title.Position = UDim2.new(0, 10, 0, 0)
	self.Title.Font = Enum.Font.GothamBold
	self.Title.TextSize = 16
	self.Title.TextColor3 = Color3.new(1, 1, 1)
	self.Title.TextXAlignment = Enum.TextXAlignment.Left
	self.Title.Text = title or "hikxxLib"
	self.Title.Parent = self.TopBar

	self.CloseButton = Instance.new("TextButton")
	self.CloseButton.Size = UDim2.new(0, 25, 0, 25)
	self.CloseButton.Position = UDim2.new(1, -35, 0.5, -12)
	self.CloseButton.BackgroundColor3 = Color3.fromRGB(237, 66, 69)
	self.CloseButton.TextColor3 = Color3.new(1, 1, 1)
	self.CloseButton.Text = "X"
	self.CloseButton.Font = Enum.Font.GothamBold
	self.CloseButton.TextSize = 18
	self.CloseButton.Parent = self.TopBar
	createUICorner(self.CloseButton, 4)

	self.TabsHolder = Instance.new("Frame")
	self.TabsHolder.Size = UDim2.new(1, 0, 0, 30)
	self.TabsHolder.Position = UDim2.new(0, 0, 0, 30)
	self.TabsHolder.BackgroundColor3 = Color3.fromRGB(43, 45, 49)
	self.TabsHolder.Parent = self.MainFrame

	self.ContentHolder = Instance.new("Frame")
	self.ContentHolder.Size = UDim2.new(1, 0, 1, -60)
	self.ContentHolder.Position = UDim2.new(0, 0, 0, 60)
	self.ContentHolder.BackgroundColor3 = Color3.fromRGB(30, 31, 35)
	self.ContentHolder.Parent = self.MainFrame
	createUICorner(self.ContentHolder, 6)

	self.CloseButton.MouseButton1Click:Connect(function()
		self.WindowVisible = not self.WindowVisible
		self.MainFrame.Visible = self.WindowVisible
	end)

	local dragging, dragInput, dragStart, startPos

	self.TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = self.MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	self.TopBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			self.MainFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == Enum.KeyCode.K then
			self.WindowVisible = not self.WindowVisible
			self.MainFrame.Visible = self.WindowVisible
		end
	end)

	return self
end

function library:AddTab(name)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 100, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(43, 45, 49)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = name
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Parent = self.TabsHolder
	createUICorner(btn, 4)

	local frame = Instance.new("ScrollingFrame")
	frame.Size = UDim2.new(1, -10, 1, -10)
	frame.Position = UDim2.new(0, 5, 0, 5)
	frame.BackgroundTransparency = 1
	frame.CanvasSize = UDim2.new(0, 0, 1, 0)
	frame.ScrollBarThickness = 6
	frame.Visible = false
	frame.Parent = self.ContentHolder

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = frame

	btn.MouseButton1Click:Connect(function()
		for i, v in pairs(self.Tabs) do
			v.Visible = false
			self.TabButtons[i].BackgroundColor3 = Color3.fromRGB(43, 45, 49)
		end
		frame.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	end)

	table.insert(self.TabButtons, btn)
	table.insert(self.Tabs, frame)

	if #self.Tabs == 1 then
		btn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
		frame.Visible = true
	end

	return frame
end

function library:AddLabel(tab, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 20)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
	label.Parent = tab
	return label
end

function library:AddButton(tab, text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Text = text
	btn.Parent = tab
	createUICorner(btn, 6)
	btn.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)
	return btn
end

function library:AddToggle(tab, text, default, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -10, 0, 30)
	holder.BackgroundTransparency = 1
	holder.Parent = tab

	local label = Instance.new("TextLabel")
	label.Text = text
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0.8, 0, 1, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 40, 0, 20)
	toggleBtn.Position = UDim2.new(0.85, 0, 0.15, 0)
	toggleBtn.BackgroundColor3 = default and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(100, 100, 100)
	toggleBtn.Text = ""
	toggleBtn.Parent = holder
	createUICorner(toggleBtn, 6)

	local toggled = default
	toggleBtn.MouseButton1Click:Connect(function()
		toggled = not toggled
		toggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(100, 100, 100)
		if callback then callback(toggled) end
	end)

	return toggleBtn
end

function library:AddSlider(tab, text, min, max, default, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -10, 0, 40)
	holder.BackgroundTransparency = 1
	holder.Parent = tab

	local label = Instance.new("TextLabel")
	label.Text = text .. ": " .. tostring(default)
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 20)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder

	local sliderBar = Instance.new("Frame")
	sliderBar.Size = UDim2.new(1, 0, 0, 10)
	sliderBar.Position = UDim2.new(0, 0, 0, 25)
	sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	sliderBar.Parent = holder
	createUICorner(sliderBar, 6)

	local sliderFill = Instance.new("Frame")
	sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	sliderFill.Parent = sliderBar
	createUICorner(sliderFill, 6)

	local dragging = false
	sliderBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			local function updateSlider(posX)
				local relativeX = math.clamp(posX - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
				local percent = relativeX / sliderBar.AbsoluteSize.X
				local value = min + (max - min) * percent
				value = math.clamp(value, min, max)
				sliderFill.Size = UDim2.new(percent, 0, 1, 0)
				label.Text = text .. ": " .. math.floor(value * 100) / 100
				if callback then callback(value) end
			end
			updateSlider(input.Position.X)
			local moveConn
			moveConn = UserInputService.InputChanged:Connect(function(input2)
				if dragging and input2.UserInputType == Enum.UserInputType.MouseMovement then
					updateSlider(input2.Position.X)
				else
					moveConn:Disconnect()
				end
			end)
			UserInputService.InputEnded:Connect(function(input2)
				if input2.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
					moveConn:Disconnect()
				end
			end)
		end
	end)

	return sliderBar
end

function library:AddTextBox(tab, placeholder, callback)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -10, 0, 30)
	box.PlaceholderText = placeholder or ""
	box.ClearTextOnFocus = false
	box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	box.Parent = tab
	createUICorner(box, 6)
	box.FocusLost:Connect(function(enter)
		if enter and callback then
			callback(box.Text)
		end
	end)
	return box
end

function library:AddColorPicker(tab, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -10, 0, 60)
	holder.BackgroundTransparency = 1
	holder.Parent = tab

	local colorPreview = Instance.new("Frame")
	colorPreview.Size = UDim2.new(0, 40, 0, 40)
	colorPreview.BackgroundColor3 = Color3.new(1, 0, 0)
	colorPreview.Position = UDim2.new(0, 0, 0.5, -20)
	colorPreview.Parent = holder
	createUICorner(colorPreview, 6)

	local picker = Instance.new("Frame")
	picker.Size = UDim2.new(1, -50, 1, 0)
	picker.Position = UDim2.new(0, 50, 0, 0)
	picker.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	picker.Parent = holder
	createUICorner(picker, 6)

	local hueSlider = Instance.new("Frame")
	hueSlider.Size = UDim2.new(1, 0, 0, 12)
	hueSlider.Position = UDim2.new(0, 0, 0, 40)
	hueSlider.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	hueSlider.Parent = picker
	createUICorner(hueSlider, 6)

	local hueGradient = Instance.new("UIGradient")
	hueGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.34, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.51, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.68, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.85, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
	}
	hueGradient.Parent = hueSlider

	local satValSquare = Instance.new("Frame")
	satValSquare.Size = UDim2.new(1, 0, 0, 38)
	satValSquare.Position = UDim2.new(0, 0, 0, 0)
	satValSquare.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
	satValSquare.Parent = picker
	createUICorner(satValSquare, 6)

	local satValGradient = Instance.new("UIGradient")
	satValGradient.Parent = satValSquare
	satValGradient.Rotation = 90

	local valGradient = Instance.new("Frame")
	valGradient.Size = UDim2.new(1, 0, 1, 0)
	valGradient.BackgroundColor3 = Color3.new(0, 0, 0)
	valGradient.BackgroundTransparency = 0.4
	valGradient.Parent = satValSquare
	createUICorner(valGradient, 6)

	local hue = 0
	local sat = 1
	local val = 1
	local draggingHue = false
	local draggingSatVal = false

	local function updateColor()
		local color = Color3.fromHSV(hue, sat, val)
		colorPreview.BackgroundColor3 = color
		if callback then callback(color) end
		satValSquare.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
	end

	hueSlider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingHue = true
			local pos = input.Position.X - hueSlider.AbsolutePosition.X
			hue = math.clamp(pos / hueSlider.AbsoluteSize.X, 0, 1)
			updateColor()
		end
	end)

	hueSlider.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingHue = false
		end
	end)

	satValSquare.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSatVal = true
			local posX = input.Position.X - satValSquare.AbsolutePosition.X
			local posY = input.Position.Y - satValSquare.AbsolutePosition.Y
			sat = math.clamp(posX / satValSquare.AbsoluteSize.X, 0, 1)
			val = 1 - math.clamp(posY / satValSquare.AbsoluteSize.Y, 0, 1)
			updateColor()
		end
	end)

	satValSquare.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSatVal = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
			local pos = input.Position.X - hueSlider.AbsolutePosition.X
			hue = math.clamp(pos / hueSlider.AbsoluteSize.X, 0, 1)
			updateColor()
		elseif draggingSatVal and input.UserInputType == Enum.UserInputType.MouseMovement then
			local posX = input.Position.X - satValSquare.AbsolutePosition.X
			local posY = input.Position.Y - satValSquare.AbsolutePosition.Y
			sat = math.clamp(posX / satValSquare.AbsoluteSize.X, 0, 1)
			val = 1 - math.clamp(posY / satValSquare.AbsoluteSize.Y, 0, 1)
			updateColor()
		end
	end)

	updateColor()

	return holder
end

return library
