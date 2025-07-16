-- hikxxlib_beta.lua
-- Discord-style Roblox UI Lib (loadstring compatible)
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

--// 🎨 Theme (you can tweak it)
local theme = {
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
create("UIStroke", {Color = Color3.fromRGB(20, 20, 20), Thickness = 1, Parent = mainHolder})

--// 🪟 Window Bar (Discord-style)
local topBar = create("Frame", {
	Size = UDim2.new(1, 0, 0, 30),
	BackgroundColor3 = theme.Primary,
	BorderSizePixel = 0,
	Parent = mainHolder
})

create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = topBar})

local title = create("TextLabel", {
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

--// 🟥 Close 🟨 Min 🟩 Full
local function createTopBtn(color, pos, callback)
	local btn = create("TextButton", {
		Size = UDim2.new(0, 20, 0, 20),
		Position = pos,
		BackgroundColor3 = color,
		Text = "",
		Parent = topBar
	})
	create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = btn})
	btn.MouseButton1Click:Connect(callback)
end

createTopBtn(Color3.fromRGB(237, 66, 69), UDim2.new(1, -30, 0.5, -10), function() lib:Close() end)
createTopBtn(Color3.fromRGB(255, 204, 0), UDim2.new(1, -55, 0.5, -10), function() mainHolder.Visible = false end)
createTopBtn(Color3.fromRGB(0, 202, 78), UDim2.new(1, -80, 0.5, -10), function()
	mainHolder.Size = UDim2.new(0, 800, 0, 500)
	mainHolder.Visible = true
end)

--// 🖱️ Dragging
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

--// 🔘 Server list
local serverList = create("Frame", {
	Size = UDim2.new(0, 60, 1, -30),
	Position = UDim2.new(0, 0, 0, 30),
	BackgroundColor3 = theme.Primary,
	BorderSizePixel = 0,
	Parent = mainHolder
})

--// 📁 Tabs inside server
local tabHolder = create("Frame", {
	Position = UDim2.new(0, 60, 0, 30),
	Size = UDim2.new(1, -60, 1, -30),
	BackgroundColor3 = theme.BG,
	BorderSizePixel = 0,
	Parent = mainHolder
})

--// 🌍 API
function lib:CreateServer(name, icon)
	local serverBtn = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 60),
		Text = icon or name:sub(1,1),
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		BackgroundColor3 = theme.Primary,
		Parent = serverList
	})
	create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = serverBtn})

	local serverFrame = create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = tabHolder
	})

	serverBtn.MouseButton1Click:Connect(function()
		for _, f in pairs(tabHolder:GetChildren()) do
			if f:IsA("Frame") then f.Visible = false end
		end
		serverFrame.Visible = true
	end)

	local serverObj = {}

	function serverObj:CreateCategory(catName)
		local catLabel = create("TextLabel", {
			Text = catName,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextColor3 = theme.MutedText,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -10, 0, 25),
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, 5, 0, #serverFrame:GetChildren() * 30),
			Parent = serverFrame
		})

		local category = {}
		function category:CreateTab(tabname)
			local tabBtn = create("TextButton", {
				Size = UDim2.new(1, -20, 0, 28),
				Position = UDim2.new(0, 10, 0, #serverFrame:GetChildren() * 30),
				Text = "# " .. tabname,
				TextColor3 = theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				BackgroundColor3 = theme.Primary,
				Parent = serverFrame
			})
			create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = tabBtn})

			local content = create("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Visible = false,
				Parent = tabHolder
			})

			tabBtn.MouseButton1Click:Connect(function()
				for _, f in pairs(tabHolder:GetChildren()) do
					if f:IsA("Frame") then f.Visible = false end
				end
				content.Visible = true
			end)

			local tabApi = {}
			function tabApi.CreateLabel(text)
				create("TextLabel", {
					Text = text,
					Size = UDim2.new(1, -20, 0, 20),
					Position = UDim2.new(0, 10, 0, 0),
					BackgroundTransparency = 1,
					TextColor3 = theme.Text,
					Font = Enum.Font.Gotham,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = content
				})
			end

			function tabApi.CreateButton(name, callback)
				local btn = create("TextButton", {
					Text = name,
					Size = UDim2.new(1, -20, 0, 30),
					Position = UDim2.new(0, 10, 0, 30),
					BackgroundColor3 = theme.Accent,
					TextColor3 = Color3.new(1,1,1),
					Font = Enum.Font.GothamBold,
					TextSize = 14,
					Parent = content
				})
				create("UICorner", {Parent = btn})
				btn.MouseButton1Click:Connect(callback)
			end

			return tabApi
		end

		return category
	end

	return serverObj
end

-- Clean method to remove nil values from lib table
function lib:Clean()
	for k, v in pairs(self) do
		if v == nil then
			self[k] = nil
		end
	end
end

-- Close method to destroy the UI
function lib:Close()
	local gui = game.CoreGui:FindFirstChild("hikxx_UI")
	if gui then
		gui:Destroy()
	end
end

return lib
