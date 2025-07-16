-- hikxxlib_beta.lua
-- Discord-style Roblox UI Lib with real Discord-like categories
-- By hikxx & ChatGPT 😎

--// 📦 Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--// 👤 Locals
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

--// 🌐 Lib table
local lib = { player = player, char = char, humanoid = humanoid }

--// 💠 UI Utility
local function create(instance, props)
	local obj = Instance.new(instance)
	for k,v in pairs(props or {}) do obj[k] = v end
	return obj
end
local lib = {}

--// 🎨 Theme (tweak as you want)
local theme = {
	BG = Color3.fromRGB(30,31,35),
	Primary = Color3.fromRGB(43,45,49),
	Accent = Color3.fromRGB(88,101,242),
	Text = Color3.new(1,1,1),
	MutedText = Color3.fromRGB(150,150,150)
    BG = Color3.fromRGB(30, 31, 35),
    Primary = Color3.fromRGB(43, 45, 49),
    Accent = Color3.fromRGB(88, 101, 242),
    Text = Color3.new(1, 1, 1),
    MutedText = Color3.fromRGB(150, 150, 150)
}

--// 🧱 Main UI Holder
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
create("UIStroke", {Color = Color3.fromRGB(20,20,20), Thickness = 1, Parent = mainHolder})

--// 🪟 Window Bar (Discord style)
local topBar = create("Frame", {
	Size = UDim2.new(1,0,0,30),
	BackgroundColor3 = theme.Primary,
	BorderSizePixel = 0,
	Parent = mainHolder
})
create("UICorner", {CornerRadius = UDim.new(0,8), Parent = topBar})

local title = create("TextLabel", {
	Text = "hikxx UI",
	Font = Enum.Font.GothamBold,
	TextColor3 = theme.Text,
	TextSize = 16,
	BackgroundTransparency = 1,
	Size = UDim2.new(1,-90,1,0),
	Position = UDim2.new(0,10,0,0),
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = topBar
})

-- Close button
local closeBtn = create("TextButton", {
	Size = UDim2.new(0,20,0,20),
	Position = UDim2.new(1,-30,0.5,-10),
	BackgroundColor3 = Color3.fromRGB(237,66,69),
	Text = "",
	Parent = topBar
})
create("UICorner", {CornerRadius = UDim.new(1,0), Parent = closeBtn})
closeBtn.MouseButton1Click:Connect(function()
	mainHolder:Destroy()
end)
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

-- Dragging logic
local dragging, dragStart, startPos = false, nil, nil
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainHolder.Position
	end
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

topBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainHolder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

--// 🖥 Left sidebar: Servers
local serverList = create("Frame", {
	Size = UDim2.new(0, 60, 1, -30),
	Position = UDim2.new(0, 0, 0, 30),
	BackgroundColor3 = theme.Primary,
	BorderSizePixel = 0,
	Parent = mainHolder
})

--// 🗂 Tab & category holder (right side)
local tabHolder = create("Frame", {
	Position = UDim2.new(0, 60, 0, 30),
	Size = UDim2.new(1, -60, 1, -30),
	BackgroundColor3 = theme.BG,
	BorderSizePixel = 0,
	Parent = mainHolder
})

-- Manage visibility for server tabs
local function hideAllFrames()
	for _, f in pairs(tabHolder:GetChildren()) do
		if f:IsA("Frame") then
			f.Visible = false
		end
	end
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

--// 🌍 API
function lib:CreateServer(name, icon)
	-- Server icon/button
	local serverBtn = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 60),
		Text = "",
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 28,
		BackgroundColor3 = theme.Primary,
		Parent = serverList,
		AutoButtonColor = false
	})
	create("UICorner", {CornerRadius = UDim.new(1,0), Parent = serverBtn})

	-- Icon or first letter inside circle
	local iconLbl = create("TextLabel", {
		Text = icon or name:sub(1,1):upper(),
		Font = Enum.Font.GothamBold,
		TextColor3 = theme.Text,
		TextSize = 28,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,1,0),
		Parent = serverBtn
	})

	local serverFrame = create("Frame", {
		Size = UDim2.new(1,0,1,0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = tabHolder
	})

	serverBtn.MouseButton1Click:Connect(function()
		hideAllFrames()
		serverFrame.Visible = true
	end)

	local serverObj = {
		categories = {}
	}

	function serverObj:CreateCategory(catName)
		-- Category frame holds category label and tabs list
		local categoryFrame = create("Frame", {
			Size = UDim2.new(1,0,0,30),
			BackgroundTransparency = 1,
			Parent = serverFrame,
			LayoutOrder = #serverFrame:GetChildren()
		})

		local catLabel = create("TextButton", {
			Text = catName,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextColor3 = theme.MutedText,
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,30),
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false,
			Parent = categoryFrame
		})

		-- Category open/close state
		local expanded = true
		local tabsHolder = create("Frame", {
			Position = UDim2.new(0, 0, 0, 30),
			Size = UDim2.new(1, 0, 0, 0),
			ClipsDescendants = true,
			BackgroundTransparency = 1,
			Parent = categoryFrame
		})

		local layout = Instance.new("UIListLayout", tabsHolder)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 2)

		catLabel.MouseButton1Click:Connect(function()
			expanded = not expanded
			if expanded then
				-- Show tabs
				tabsHolder:TweenSize(UDim2.new(1,0,0,layout.AbsoluteContentSize.Y), "Out", "Quad", 0.25, true)
				catLabel.TextColor3 = theme.MutedText
			else
				-- Hide tabs
				tabsHolder:TweenSize(UDim2.new(1,0,0,0), "Out", "Quad", 0.25, true)
				catLabel.TextColor3 = theme.Text
			end
		end)

		-- Expand initially
		tabsHolder.Size = UDim2.new(1,0,0,0)
		task.wait(0.05)
		tabsHolder.Size = UDim2.new(1,0,0,layout.AbsoluteContentSize.Y)

		local category = {}

		function category:CreateTab(tabName)
			local tabBtn = create("TextButton", {
				Text = "# " .. tabName,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextColor3 = theme.Text,
				BackgroundColor3 = theme.Primary,
				Size = UDim2.new(1, -10, 0, 28),
				AutoButtonColor = false,
				LayoutOrder = #tabsHolder:GetChildren() + 1,
				Parent = tabsHolder
			})
			create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = tabBtn})

			local contentFrame = create("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Visible = false,
				Parent = tabHolder
			})

			tabBtn.MouseButton1Click:Connect(function()
				hideAllFrames()
				contentFrame.Visible = true
			end)

			local tabApi = {}
			local layout = Instance.new("UIListLayout", contentFrame)
			layout.Padding = UDim.new(0, 5)

			-- Simple vertical layout for content

			function tabApi.CreateLabel(text)
				create("TextLabel", {
					Text = text,
					Font = Enum.Font.Gotham,
					TextSize = 14,
					TextColor3 = theme.Text,
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -20, 0, 20),
					Parent = contentFrame,
					Position = UDim2.new(0, 10, 0, 0)
				})
			end

			function tabApi.CreateButton(name, callback)
				local btn = create("TextButton", {
					Text = name,
					Font = Enum.Font.GothamBold,
					TextSize = 14,
					TextColor3 = Color3.new(1,1,1),
					BackgroundColor3 = theme.Accent,
					Size = UDim2.new(1, -20, 0, 30),
					Parent = contentFrame,
					AutoButtonColor = false
				})
				create("UICorner", {Parent = btn})
				btn.MouseButton1Click:Connect(callback)
			end

			return tabApi
		end

		categoryFrame.Parent = serverFrame
		return category
	end

	return serverObj
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

-- Return lib
return lib
