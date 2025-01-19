local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Universal Gui",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Universal Gui",
   LoadingSubtitle = "By HIKGTTY",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "hikxx key",
      Subtitle = "Universal scripts",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Universal"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})
local Tab1 = Window:CreateTab("Guis", 4483362458) -- Title, Image
local Tab2 = Window:CreateTab("Player", 4483362458) -- Title, Image
local Tab3 = Window:CreateTab("Rayfield", 4483362458) -- Title, Image
local Divider = Tab1:CreateDivider()
local Button1 = Tab3:CreateButton({
   Name = "Close",
   Callback = function()
   Rayfield:Destroy()
   end,
})
local Button2 = Tab1:CreateButton({
   Name = "TSB",
   Callback = function()
   if getgenv().KadeHubLoaded ~= true then
    getgenv().KadeHubLoaded = true
   loadstring(game:HttpGet("https://raw.githubusercontent.com/skibiditoiletfan2007/Work/main/latest.lua"))()
else
    game.StarterGui:SetCore("SendNotification",  { Title = "KadeHub"; Text = "KadeHub is already executed!"; Icon = "rbxassetid://17893547380"; Duration = 15; })
end


   -- The function that takes place when the button is pressed
   end,
})
local Button5 = Tab1:CreateButton({
   Name = "KJ Universal",
   Callback = function()
loadstring(game:HttpGet("https://pastebin.com/raw/5KnPXUEm"))("Alice scripts")
   end,
})

local Slider = Tab2:CreateSlider({
   Name = "Walk Speed (default is 20)",
   Range = {0, 100},
   Increment = 10,
   Suffix = "Speed",
   CurrentValue = 10,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   local Players = game:GetService("Players")
   local Player = Players.LocalPlayer
   local Character = workspace:WaitForChild(Player.Name)
   local Humanoid = Character:FindFirstChild("Humanoid")
   
   repeat wait() until Humanoid
   
   local WalkSpeedValue = Value
   
   local function ChangeWalkSpeed(Value)
	Humanoid.WalkSpeed = Value
	end
	ChangeWalkSpeed(WalkSpeedValue)
   -- The function that takes place when the slider changes
   -- The variable (Value) is a number which correlates to the value the slider is currently at
   end,
})

local Button3 = Tab2:CreateButton({
   Name = "Noclip",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/Ilya123123123gf/scripts/refs/heads/main/Noclip.lua"))()
   end,
})

local Button4 = Tab1:CreateButton({
		Name = "Animations"
		Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Fearlocked/Nullware-Hub-V3/refs/heads/main/NullWare%20Hub%20V3"))()
		end
	})
