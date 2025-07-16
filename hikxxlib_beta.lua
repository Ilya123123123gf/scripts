-- // DiscordUILib.lua
local DiscordUI = {}
DiscordUI.__index = DiscordUI

-- Auto locals
DiscordUI.player = game:GetService("Players").LocalPlayer
DiscordUI.char = DiscordUI.player.Character or DiscordUI.player.CharacterAdded:Wait()
DiscordUI.humanoid = DiscordUI.char:WaitForChild("Humanoid")

-- Services
local Tween = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Http = game:GetService("HttpService")

function DiscordUI:Tween(obj, props, dur, style, dir)
    Tween:Create(obj, TweenInfo.new(dur, style, dir), props):Play()
end

function DiscordUI:CreateWindow(opts)
    local self = setmetatable({}, DiscordUI)
    self.ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    self.ScreenGui.Name = "DiscordUILib"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local Main = Instance.new("Frame", self.ScreenGui)
    Main.Name = "Main"; Main.Size = UDim2.new(0,600,0,400)
    Main.Position = UDim2.new(0.5,-300,0.5,-200)
    Main.BackgroundColor3 = Color3.fromRGB(54,57,63); Main.BorderSizePixel = 0
    Main.ClipsDescendants = true

    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Name="TitleBar"; TitleBar.Size=UDim2.new(1,0,0,36)
    TitleBar.BackgroundColor3=Color3.fromRGB(44,47,51)

    local Title = Instance.new("TextLabel", TitleBar)
    Title.Size=UDim2.new(1,-24,1,0); Title.Position=UDim2.new(0,12,0,0)
    Title.BackgroundTransparency=1; Title.Font=Enum.Font.GothamBold
    Title.TextSize=18; Title.TextColor3=Color3.new(1,1,1)
    Title.Text=opts.Title or "Discord UI Lib"; Title.TextXAlignment=Enum.TextXAlignment.Left

    -- Drag
    do
        local dragging, startPos, dragStart
        TitleBar.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true; dragStart=i.Position; startPos=Main.Position
                i.Changed:Connect(function()
                    if i.UserInputState==Enum.UserInputState.End then dragging=false end
                end)
            end
        end)
        TitleBar.InputChanged:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseMovement then
                UIS.InputChanged:Connect(function(m)
                    if dragging and m.UserInputType==Enum.UserInputType.MouseMovement then
                        local d=m.Position-dragStart
                        Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
                                                startPos.Y.Scale,startPos.Y.Offset+d.Y)
                    end
                end)
            end
        end)
    end

    self.Main=Main
    self.TabButtons=Instance.new("Frame",Main)
    self.TabButtons.Name="Tabs"; self.TabButtons.Size=UDim2.new(0,140,1,-36)
    self.TabButtons.Position=UDim2.new(0,0,0,36)
    self.TabButtons.BackgroundColor3=Color3.fromRGB(47,50,56)

    self.Content=Instance.new("Frame",Main)
    self.Content.Name="Content"; self.Content.Size=UDim2.new(1,-140,1,-36)
    self.Content.Position=UDim2.new(0,140,0,36); self.Content.BackgroundTransparency=1

    self.Tabs={}
    return self
end

function DiscordUI:CreateTab(name)
    local btn=Instance.new("TextButton",self.TabButtons)
    btn.Size=UDim2.new(1,0,0,40); btn.BackgroundTransparency=1
    btn.Font=Enum.Font.Gotham; btn.Text=name; btn.TextColor3=Color3.fromRGB(200,200,200)
    btn.TextSize=16; btn.TextXAlignment=Enum.TextXAlignment.Left
    btn.Padding=Instance.new("UIPadding",btn); btn.Padding.PaddingLeft=UDim.new(0,12)

    local page=Instance.new("ScrollingFrame",self.Content)
    page.Size=self.Content.Size; page.BackgroundTransparency=1
    page.ScrollBarThickness=6; page.Visible=false
    local layout=Instance.new("UIListLayout",page)
    layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Padding=UDim.new(0,6)

    self.Tabs[name]=page

    btn.MouseButton1Click:Connect(function()
        for t,p in pairs(self.Tabs) do p.Visible=(t==name) end
        for _,b in ipairs(self.TabButtons:GetChildren()) do
            if b:IsA("TextButton") then
                b.TextColor3 = (b==btn) and Color3.new(1,1,1) or Color3.fromRGB(200,200,200)
            end
        end
    end)

    return {
        CreateButton = function(_,o) self:_addButton(page,o) end,
        CreateToggle = function(_,o) self:_addToggle(page,o) end,
        CreateSlider = function(_,o) self:_addSlider(page,o) end,
        CreateTextbox = function(_,o) self:_addTextbox(page,o) end,
        CreateColorpicker = function(_,o) self:_addColorpicker(page,o) end,
        CreateLabel = function(_,o) self:_addLabel(page,o) end
    }
end

function DiscordUI:_addButton(p,o)
    local b=Instance.new("TextButton",p)
    b.Size=UDim2.new(1,-12,0,34); b.Position=UDim2.new(0,6,0,0)
    b.BackgroundColor3=Color3.fromRGB(88,101,242); b.Font=Enum.Font.GothamBold
    b.Text=o.Name; b.TextSize=16; b.TextColor3=Color3.new(1,1,1)
    b.AutoButtonColor=false
    b.MouseEnter:Connect(function() self:Tween(b,{BackgroundTransparency=0.7},0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out) end)
    b.MouseLeave:Connect(function() self:Tween(b,{BackgroundTransparency=0},0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out) end)
    b.MouseButton1Click:Connect(o.Callback)
end

function DiscordUI:_addToggle(p,o)
    local f=Instance.new("Frame",p); f.Size=UDim2.new(1,-12,0,30); f.BackgroundTransparency=1
    local l=Instance.new("TextLabel",f); l.Size=UDim2.new(0.8,0,1,0); l.Text=o.Name
    l.Font=Enum.Font.Gotham; l.TextSize=16; l.TextColor3=Color3.new(1,1,1)
    l.BackgroundTransparency=1; l.TextXAlignment=Enum.TextXAlignment.Left
    local box=Instance.new("Frame",f); box.Size=UDim2.new(0,20,0,20)
    box.Position=UDim2.new(1,-26,0.5,-10); box.BackgroundColor3=Color3.fromRGB(80,81,82)
    box.BorderSizePixel=0; box.Rounded=true
    local state=o.Default or false
    local mark=Instance.new("Frame",box)
    mark.Size=UDim2.new(state and 1 or 0,0,1,0); mark.BackgroundColor3=Color3.fromRGB(114,137,218); mark.BorderSizePixel=0
    f.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            state=not state
            self:Tween(mark,{Size=state and UDim2.new(1,0,1,0) or UDim2.new(0,0,1,0)},0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
            o.Callback(state)
        end
    end)
end

function DiscordUI:_addSlider(p,o)
    local f=Instance.new("Frame",p); f.Size=UDim2.new(1,-12,0,50); f.BackgroundTransparency=1
    local l=Instance.new("TextLabel",f); l.Size=UDim2.new(1,0,0,20)
    l.Font=Enum.Font.Gotham; l.TextSize=16; l.TextColor3=Color3.new(1,1,1)
    l.BackgroundTransparency=1; l.Text=string.format("%s: %d",o.Name,o.Default or o.Min)
    local bg=Instance.new("Frame",f); bg.Size=UDim2.new(1,-12,0,8); bg.Position=UDim2.new(0,6,0,30)
    bg.BackgroundColor3=Color3.fromRGB(64,67,75); bg.BorderSizePixel=0; bg.Rounded=true
    local bar=Instance.new("Frame",bg)
    bar.Size=UDim2.new((o.Default-o.Min)/(o.Max-o.Min),0,1,0)
    bar.BackgroundColor3=Color3.fromRGB(114,137,218); bar.BorderSizePixel=0; bar.Rounded=true
    local dragging=false
    bg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
    bg.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local x=math.clamp((i.Position.X-bg.AbsolutePosition.X)/bg.AbsoluteSize.X,0,1)
            bar.Size=UDim2.new(x,0,1,0)
            local v=math.floor(o.Min+x*(o.Max-o.Min))
            l.Text=string.format("%s: %d",o.Name,v); o.Callback(v)
        end
    end)
end

function DiscordUI:_addTextbox(p,o)
    local tb=Instance.new("TextBox",p)
    tb.Size=UDim2.new(1,-12,0,32); tb.Position=UDim2.new(0,6,0,0)
    tb.BackgroundColor3=Color3.fromRGB(64,67,75); tb.TextColor3=Color3.new(1,1,1)
    tb.Text=o.Placeholder or ""; tb.Font=Enum.Font.Gotham; tb.TextSize=16
    tb.ClearTextOnFocus=false
    tb.FocusLost:Connect(function(enter) if enter then o.Callback(tb.Text) end end)
end

function DiscordUI:_addColorpicker(p,o)
    local f=Instance.new("Frame",p); f.Size=UDim2.new(1,-12,0,50); f.BackgroundTransparency=1
    local l=Instance.new("TextLabel",f); l.Size=UDim2.new(0.6,0,0,20)
    l.Font=Enum.Font.Gotham; l.TextSize=16; l.TextColor3=Color3.fromRGB(255,255,255)
    l.BackgroundTransparency=1; l.Text=o.Name
    local box=Instance.new("Frame",f); box.Size=UDim2.new(0,30,0,30)
    box.Position=UDim2.new(1,-36,0,10); box.BackgroundColor3=o.Default
    box.BorderSizePixel=0; box.Rounded=true

    local cp = Instance.new("Frame",f)
    cp.Size=UDim2.new(1,0,0,150); cp.Position=UDim2.new(0,0,1,4)
    cp.BackgroundColor3=Color3.fromRGB(54,57,63); cp.Visible=false; cp.BorderSizePixel=0

    -- basic hue grid & palette
    local grid = Instance.new("ImageLabel",cp)
    grid.Size=UDim2.new(1,-10,0.6,0); grid.Position=UDim2.new(0,5,0,5)
    grid.Image="rbxassetid://4155801252"; grid.ScaleType=Enum.ScaleType.Stretch

    local slider = Instance.new("Frame",cp); slider.Size=UDim2.new(1,-10,0,20)
    slider.Position=UDim2.new(0,5,0.62,0); slider.BackgroundColor3=Color3.fromRGB(114,137,218)
    slider.Rounded=true

    local rotating=false
    box.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then cp.Visible = not cp.Visible end
    end)

    -- Picking functions
    local function updateBox(c)
        box.BackgroundColor3=c; o.Callback(c)
    end

    grid.InputBegan:Connect(function(i)
        rotating = true
    end)
    grid.InputChanged:Connect(function(i)
        if rotating and i.UserInputType==Enum.UserInputType.MouseMovement then
            local rel = (i.Position - grid.AbsolutePosition)
            local x = math.clamp(rel.X/grid.AbsoluteSize.X,0,1)
            local y = math.clamp(rel.Y/grid.AbsoluteSize.Y,0,1)
            local c = Color3.new(x,1-y,0) -- basic
            updateBox(c)
        end
    end)
    grid.InputEnded:Connect(function(i) rotating=false end)
end

function DiscordUI:_addLabel(p,o)
    local l=Instance.new("TextLabel",p)
    l.Size=UDim2.new(1,-12,0,24); l.Position=UDim2.new(0,6,0,0)
    l.Text=o.Text or ""; l.Font=Enum.Font.Gotham; l.TextSize=16
    l.TextColor3=Color3.new(1,1,1); l.BackgroundTransparency=1
    l.TextXAlignment=Enum.TextXAlignment.Left
end

function DiscordUI:Load()
    for _,p in pairs(self.Tabs) do
        p.Visible=false
    end
    for name,p in pairs(self.Tabs) do
        p.Visible=true
        break
    end
    return self
end

return DiscordUI
