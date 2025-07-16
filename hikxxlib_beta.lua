-- hikxxlib_beta.lua
-- Discord-style Roblox UI Lib (loadstring compatible)
-- By hikxx & ChatGPT 😎

--// 💾 Auto-clean if GUI already exists
pcall(function()
	game.CoreGui:FindFirstChild("hikxx_UI"):Destroy()
end)

--// 📦 Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

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
	Primary = Color3.fromRGB(54, 57, 63),
	Accent = Color3.fromRGB(88, 101, 242),
	Text = Color3.new(1, 1, 1)
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
	Size = UDim2.new(0, 600, 0, 400),
	Position = UDim2.new(0.5, -300, 0.5, -200),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BorderSizePixel = 0,
	Parent = screengui
})

create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = mainHolder})
create("UIStroke", {Color = theme.Accent, Thickness = 2, Parent = mainHolder})

--// 🌀 Server list on left
local serverList = create("Frame", {
	Size = UDim2.new(0, 60, 1, 0),
	BackgroundColor3 = theme.Primary,
	BorderSizePixel = 0,
	Parent = mainHolder
})

--// ⛓️ Tabs inside server
local tabHolder = create("Frame", {
	Position = UDim2.new(0, 60, 0, 0),
	Size = UDim2.new(1, -60, 1, 0),
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

	local tabLayout = create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = serverFrame
	})

	serverBtn.MouseButton1Click:Connect(function()
		for _, f in pairs(tabHolder:GetChildren()) do
			if f:IsA("Frame") then f.Visible = false end
		end
		serverFrame.Visible = true
	end)

	local serverObj = {}
	function serverObj:CreateTab(tabname)
		local tabBtn = create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 30),
			Text = tabname,
			TextColor3 = theme.Text,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			BackgroundColor3 = theme.Primary,
			Parent = serverFrame
		})
		
		local content = create("Frame", {
			Size = UDim2.new(1, 0, 1, -30),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundTransparency = 1,
			Visible = true,
			Parent = serverFrame
		})

		local tabApi = {}

		function tabApi:CreateLabel(text)
			create("TextLabel", {
				Text = text,
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				TextColor3 = theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				Parent = content
			})
		end

		function tabApi:CreateButton(name, callback)
			local btn = create("TextButton", {
				Text = name,
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = theme.Accent,
				TextColor3 = Color3.new(1,1,1),
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				Parent = content
			})
			create("UICorner", {Parent = btn})
			btn.MouseButton1Click:Connect(callback)
		end

		function tabApi:CreateColorpicker(name, default, callback)
			-- placeholder: implement full picker later
			tabApi:CreateButton(name.." (Colorpicker stub)", function()
				callback(default or Color3.new(1, 0, 0))
			end)
		end

		-- Add more elements: Toggle, Slider, Textbox, etc

		return tabApi
	end

	return serverObj
end

return lib