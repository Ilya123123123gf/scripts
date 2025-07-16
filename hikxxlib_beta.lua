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

--// 🎨 Theme (tweak as you want)
local theme = {
	BG = Color3.fromRGB(30,31,35),
	Primary = Color3.fromRGB(43,45,49),
	Accent = Color3.fromRGB(88,101,242),
	Text = Color3.new(1,1,1),
	MutedText = Color3.fromRGB(150,150,150)
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

-- Dragging logic
local dragging, dragStart, startPos = false, nil, nil

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
end

-- Return lib
return lib
