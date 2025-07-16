local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Удаляем старый UI если есть
pcall(function()
	local old = game.CoreGui:FindFirstChild("hikxx_UI")
	if old then old:Destroy() end
end)

-- Создаём базовый ScreenGui
local screengui = Instance.new("ScreenGui")
screengui.Name = "hikxx_UI"
screengui.ResetOnSpawn = false
screengui.Parent = game.CoreGui

-- Главный фрейм
local mainHolder = Instance.new("Frame")
mainHolder.Size = UDim2.new(0, 800, 0, 500)
mainHolder.Position = UDim2.new(0.5, -400, 0.5, -250)
mainHolder.AnchorPoint = Vector2.new(0.5, 0.5)
mainHolder.BackgroundColor3 = Color3.fromRGB(30,31,35)
mainHolder.BorderSizePixel = 0
mainHolder.Parent = screengui
mainHolder.Visible = true

-- Радиус углов и бордер
local function addUICorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end
addUICorner(mainHolder, 8)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(20,20,20)
stroke.Thickness = 1
stroke.Parent = mainHolder

-- Верхняя панель (топбар)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1,0,0,30)
topBar.BackgroundColor3 = Color3.fromRGB(43,45,49)
topBar.Parent = mainHolder
addUICorner(topBar, 8)

-- Название
local title = Instance.new("TextLabel")
title.Text = "hikxx UI"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 16
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Close Button с иксом
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -35, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(237,66,69)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = topBar
addUICorner(closeBtn, 4)

closeBtn.MouseButton1Click:Connect(function()
	mainHolder.Visible = false
end)

-- Open Button (внизу экрана для возврата UI)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 80, 0, 30)
openBtn.Position = UDim2.new(0, 10, 1, -40)
openBtn.BackgroundColor3 = Color3.fromRGB(43,45,49)
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Text = "Open UI (K)"
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 14
openBtn.Parent = screengui
openBtn.Visible = false
addUICorner(openBtn, 6)

openBtn.MouseButton1Click:Connect(function()
	mainHolder.Visible = true
	openBtn.Visible = false
end)

-- Драг по топбару
local dragging, dragStartPos, startPos
topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStartPos = input.Position
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
		local delta = input.Position - dragStartPos
		mainHolder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Табахолдер сверху под топбаром
local tabsHolder = Instance.new("Frame")
tabsHolder.Size = UDim2.new(1, 0, 0, 30)
tabsHolder.Position = UDim2.new(0, 0, 0, 30)
tabsHolder.BackgroundColor3 = Color3.fromRGB(43,45,49)
tabsHolder.BorderSizePixel = 0
tabsHolder.Parent = mainHolder

-- Контент
local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, 0, 1, -60)
contentHolder.Position = UDim2.new(0, 0, 0, 60)
contentHolder.BackgroundColor3 = Color3.fromRGB(30,31,35)
contentHolder.Parent = mainHolder
addUICorner(contentHolder, 6)

-- Таблицы и контенты
local tabs = {}
local contents = {}

local function createTab(name)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 100, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(43,45,49)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Text = name
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Parent = tabsHolder
	addUICorner(btn, 4)
	table.insert(tabs, btn)

	local frame = Instance.new("ScrollingFrame")
	frame.Size = UDim2.new(1, -10, 1, -10)
	frame.Position = UDim2.new(0, 5, 0, 5)
	frame.BackgroundTransparency = 1
	frame.CanvasSize = UDim2.new(0, 0, 1, 0)
	frame.ScrollBarThickness = 6
	frame.Visible = false
	frame.Parent = contentHolder

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = frame

	table.insert(contents, frame)

	btn.MouseButton1Click:Connect(function()
		for i, f in pairs(contents) do
			f.Visible = false
			tabs[i].BackgroundColor3 = Color3.fromRGB(43,45,49)
		end
		frame.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(88,101,242)
	end)

	return frame
end

-- Создаём пример табов
local tab1 = createTab("Main")
local tab2 = createTab("Settings")
local tab3 = createTab("Colors")

tabs[1].BackgroundColor3 = Color3.fromRGB(88,101,242)
contents[1].Visible = true

-- Функции для добавления элементов в табы
local function addLabel(frame, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 20)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
	label.Parent = frame
end

local function addButton(frame, text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(88,101,242)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Text = text
	btn.Parent = frame
	addUICorner(btn, 6)
	btn.MouseButton1Click:Connect(callback)
end

local function addToggle(frame, text, default, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -10, 0, 30)
	holder.BackgroundTransparency = 1
	holder.Parent = frame

	local label = Instance.new("TextLabel")
	label.Text = text
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextColor3 = Color3.new(1,1,1)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0.8, 0, 1, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 40, 0, 20)
	toggleBtn.Position = UDim2.new(0.85, 0, 0.15, 0)
	toggleBtn.BackgroundColor3 = default and Color3.fromRGB(88,101,242) or Color3.fromRGB(100,100,100)
	toggleBtn.Text = ""
	toggleBtn.Parent = holder
	addUICorner(toggleBtn, 6)

	local toggled = default
	toggleBtn.MouseButton1Click:Connect(function()
		toggled = not toggled
		toggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(88,101,242) or Color3.fromRGB(100,100,100)
		if callback then callback(toggled) end
	end)
end

-- Цветопикер, упрощённый для примера (можно расширить)
local function createColorPicker(parent, callback)
	local picker = Instance.new("Frame")
	picker.Size = UDim2.new(0, 200, 0, 150)
	picker.BackgroundColor3 = Color3.fromRGB(50,50,50)
	picker.Parent = parent
	addUICorner(picker, 8)

	local colorDisplay = Instance.new("Frame")
	colorDisplay.Size = UDim2.new(0, 50, 0, 50)
	colorDisplay.Position = UDim2.new(0.5, -25, 0, 10)
	colorDisplay.BackgroundColor3 = Color3.new(1, 0, 0)
	colorDisplay.Parent = picker
	addUICorner(colorDisplay, 6)

	local hueSlider = Instance.new("Frame")
	hueSlider.Size = UDim2.new(0, 150, 0, 20)
	hueSlider.Position = UDim2.new(0.5, -75, 0, 70)
	hueSlider.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	hueSlider.Parent = picker
	addUICorner(hueSlider, 6)

	local hueGradient = Instance.new("UIGradient")
	hueGradient.Parent = hueSlider
	hueGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.34, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.51, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.68, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.85, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
	}

	local hue = 0
	local sat, val = 1, 1

	local function updateColor()
		local color = Color3.fromHSV(hue, sat, val)
		colorDisplay.BackgroundColor3 = color
		if callback then
			callback(color)
		end
	end

	local draggingHue = false
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
	UserInputService.InputChanged:Connect(function(input)
		if draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
			local pos = input.Position.X - hueSlider.AbsolutePosition.X
			hue = math.clamp(pos / hueSlider.AbsoluteSize.X, 0, 1)
			updateColor()
		end
	end)

	updateColor()
	return picker
end

-- Пример наполнения табов
addLabel(tab1, "Привет, это твой UI.")
addButton(tab1, "Нажми меня", function() print("Кнопка нажата!") end)
addToggle(tab1, "Тоггл пример", false, function(state) print("Тоггл изменён:", state) end)

createColorPicker(tab3, function(color)
	print("Цвет выбран:", color)
end)

-- Горячая клавиша K для показа/скрытия UI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.K then
		if mainHolder.Visible then
			mainHolder.Visible = false
			openBtn.Visible = true
		else
			mainHolder.Visible = true
			openBtn.Visible = false
		end
	end
end)
