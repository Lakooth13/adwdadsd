local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Lakooth13/2x/main/.luaaaa'))()

local Window = Rayfield:CreateWindow({
   Name = "Undefined - v0.1.0",
   LoadingTitle = "                                           Loading",
   LoadingSubtitle = "",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   }
})

-- Tabs

local Tab = Window:CreateTab("Aimbot")
local Tab2 = Window:CreateTab("Visuals")
local Tab3 = Window:CreateTab("Miscellaneous")
local Tab4 = Window:CreateTab("LocalPlayer")
local Tab5 = Window:CreateTab("Settings")

-- Sections

local Section = Tab:CreateSection("Aimbot Configuartion")
local Section = Tab2:CreateSection("Visuals Configuration")
local Section = Tab3:CreateSection("Miscellaneous Scripts")
local Section = Tab4:CreateSection("LocalPlayer Configuration")
local Section = Tab5:CreateSection("Settings")

-- Local UI Elements

-- Aimbot Tab

local teamCheck = false
local smoothing = 1

local RunService = game:GetService("RunService")

local FOVring = Drawing.new("Circle")
FOVring.Visible = false -- Initially invisible until the aimbot is toggled on
FOVring.Thickness = 1.5
FOVring.Radius = 85 -- Default circle size
FOVring.Transparency = 0.9 -- Set transparency to 0.9
FOVring.Color = Color3.fromRGB(255, 255, 255)
FOVring.Position = workspace.CurrentCamera.ViewportSize / 2

local function getClosest(cframe)
   local ray = Ray.new(cframe.Position, cframe.LookVector).Unit
   
   local target = nil
   local mag = math.huge
   
   for i, v in pairs(game.Players:GetPlayers()) do
       if v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart") and v ~= game.Players.LocalPlayer and (v.Team ~= game.Players.LocalPlayer.Team or (not teamCheck)) then
           local magBuf = (v.Character.Head.Position - ray:ClosestPoint(v.Character.Head.Position)).Magnitude
           
           if magBuf < mag then
               mag = magBuf
               target = v
           end
       end
   end
   
   return target
end

local loop -- Declare loop variable outside the scope of the callback function

local ToggleAimbot = Tab:CreateToggle({
   Name = "Aimbot - Circle",
   CurrentValue = false,
   Flag = "ToggleCircle",
   Callback = function(Value)
       if Value then
           FOVring.Visible = true -- Show FOV circle when aimbot is toggled on
           loop = RunService.RenderStepped:Connect(function()
               local UserInputService = game:GetService("UserInputService")
               local pressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
               local localPlay = game.Players.LocalPlayer.Character
               local cam = workspace.CurrentCamera
               local zz = workspace.CurrentCamera.ViewportSize / 2
               
               if pressed then
                   local curTar = getClosest(cam.CFrame)
                   if curTar then
                       local ssHeadPoint = cam:WorldToScreenPoint(curTar.Character.Head.Position)
                       ssHeadPoint = Vector2.new(ssHeadPoint.X, ssHeadPoint.Y)
                       if (ssHeadPoint - zz).Magnitude < FOVring.Radius then
                           workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(cam.CFrame.Position, curTar.Character.Head.Position), smoothing)
                       end
                   end
               end
           end)
       else
           FOVring.Visible = false -- Hide FOV circle when aimbot is toggled off
           if loop then
               loop:Disconnect() -- Disconnect the loop if it exists
           end
       end
   end,
})

local Slider = Tab:CreateSlider({
   Name = "Circle Size",
   Range = {0, 500},
   Increment = 1,
   Suffix = "",
   CurrentValue = 85,
   Flag = "CircleSize",
   Callback = function(Value)
       FOVring.Radius = Value -- Adjust FOV circle size based on the slider value
   end,
})

local ColorPicker = Tab:CreateColorPicker({
    Name = "Circle Color",
    Color = Color3.fromRGB(255, 255, 255),
    Flag = "ColorPickerCircle",
    Callback = function(Value)
        FOVring.Color = Value -- Set FOV circle color based on the color picker value
    end
})

local FillCircleToggle = Tab:CreateToggle({
   Name = "Fill Circle",
   CurrentValue = false,
   Flag = "ToggleFillCircle",
   Callback = function(Value)
       FOVring.Filled = Value -- Fill the circle when toggled on, outline only when toggled off
   end,
})

local TeamCheckToggle = Tab:CreateToggle({
   Name = "Team Check",
   CurrentValue = false,
   Flag = "ToggleTeamCheck",
   Callback = function(Value)
       teamCheck = Value -- Set teamCheck based on the toggle value
   end,
})


local Toggle = Tab:CreateToggle({
   Name = "Prediction",
   CurrentValue = false,
   Flag = "TogglePredict", 
   Callback = function(Value)
   
   end,
})


local Slider = Tab:CreateSlider({
   Name = "Prediction Increment",
   Range = {0, 100},
   Increment = 1,
   Suffix = "",
   CurrentValue = 0,
   Flag = "SliderPredict", 
   Callback = function(Value)
   
   end,
})

-- Visuals Tab

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Tracers = {}
local TracerColor = Color3.fromRGB(255, 255, 255)
local TracerEnabled = false
local RenderConnection

local function UpdateTracers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                if not Tracers[player] then
                    local tracer = Drawing.new("Line")
                    tracer.Thickness = 2
                    tracer.Color = TracerColor
                    Tracers[player] = tracer
                end
                local tracer = Tracers[player]
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                tracer.Visible = true
            elseif Tracers[player] then
                Tracers[player].Visible = false
            end
        elseif Tracers[player] then
            Tracers[player].Visible = false
        end
    end
end

local ToggleTracers = Tab2:CreateToggle({
    Name = "Draw Tracers",
    CurrentValue = false,
    Flag = "ToggleTracers",
    Callback = function(Value)
        TracerEnabled = Value
        if TracerEnabled then
            RenderConnection = RunService.RenderStepped:Connect(UpdateTracers)
            Players.PlayerRemoving:Connect(function(player)
                if Tracers[player] then
                    Tracers[player]:Remove()
                    Tracers[player] = nil
                end
            end)
        else
            if RenderConnection then
                RenderConnection:Disconnect()
            end
            for _, tracer in pairs(Tracers) do
                tracer:Remove()
            end
            Tracers = {}
        end
    end,
})

local ColorPickerTracers = Tab2:CreateColorPicker({
    Name = "Tracers Color",
    Color = TracerColor,
    Flag = "ColorPickerTracers",
    Callback = function(Value)
        TracerColor = Value
        for _, tracer in pairs(Tracers) do
            tracer.Color = TracerColor
        end
    end,
})

local Player = game:GetService("Players").LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local ToggleEnabled = false
local BoxColor = Color3.fromRGB(255, 255, 255)

local function DrawESP(plr)
    local Box = Drawing.new("Quad")
    Box.Visible = false
    Box.Thickness = 1
    Box.Transparency = 0.5
    Box.Filled = false

    local function Update()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character.PrimaryPart then
                local pos, vis = Camera:WorldToViewportPoint(plr.Character.PrimaryPart.Position)
                if vis and ToggleEnabled then 
                    local points = {}
                    local c = 0
                    for _,v in pairs(plr.Character:GetChildren()) do
                        if v:IsA("BasePart") then
                            c = c + 1
                            local p, vis = Camera:WorldToViewportPoint(v.Position)
                            points[c] = {p, vis}
                        end
                    end

                    local TopY = math.huge
                    local DownY = -math.huge
                    local LeftX = math.huge
                    local RightX = -math.huge

                    local Left
                    local Right
                    local Top
                    local Bottom

                    for _,v in pairs(points) do
                        if v[2] then
                            local p = v[1]
                            if p.Y < TopY then
                                Top = p
                                TopY = p.Y
                            end
                            if p.Y > DownY then
                                Bottom = p
                                DownY = p.Y
                            end
                            if p.X > RightX then
                                Right = p
                                RightX = p.X
                            end
                            if p.X < LeftX then
                                Left = p
                                LeftX = p.X
                            end
                        end
                    end

                    if Left and Right and Top and Bottom then
                        Box.PointA = Vector2.new(Right.X, Top.Y)
                        Box.PointB = Vector2.new(Left.X, Top.Y)
                        Box.PointC = Vector2.new(Left.X, Bottom.Y)
                        Box.PointD = Vector2.new(Right.X, Bottom.Y)

                        Box.Color = BoxColor
                        Box.Visible = true
                    else 
                        Box.Visible = false
                    end
                else 
                    Box.Visible = false
                end
            else
                Box.Visible = false
                if not game.Players:FindFirstChild(plr.Name) then
                    connection:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(Update)()
end

for _,v in pairs(game:GetService("Players"):GetPlayers()) do
    if v ~= Player then 
        DrawESP(v)
    end
end

game:GetService("Players").PlayerAdded:Connect(function(v)
    DrawESP(v)
end)

local Toggle = Tab2:CreateToggle({
   Name = "Enable ESP",
   CurrentValue = false,
   Flag = "ToggleESP", 
   Callback = function(Value)
       ToggleEnabled = Value
   end,
})

local ColorPicker = Tab2:CreateColorPicker({
    Name = "Box Color",
    Color = Color3.fromRGB(255,255,255),
    Flag = "ColorPickerBOXCOLOR",
    Callback = function(Value)
        BoxColor = Value
    end
})


-- Miscellaneous Tab

local Button = Tab3:CreateButton({
   Name = "Execute Dex",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/RobloxFeather/dex/main/dex.lua"))()
   end,
})

local Button = Tab3:CreateButton({
   Name = "Execute Infinite Yeild",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
   end,
})

-- LocalPlayer Tab

local Slider = Tab4:CreateSlider({
   Name = "Speed Changer",
   Range = {0, 500},
   Increment = 1,
   Suffix = "",
   CurrentValue = 16,
   Flag = "SliderSpeed", 
   Callback = function(Value)
      -- Update the WalkSpeed of the player's humanoid
      local player = game.Players.LocalPlayer
      if player and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
         player.Character.Humanoid.WalkSpeed = Value
      end
   end,
})


local Slider = Tab4:CreateSlider({
   Name = "Field Of View Changer",
   Range = {0, 120},
   Increment = 1,
   Suffix = "",
   CurrentValue = 70,
   Flag = "SliderFOV", 
   Callback = function(Value)
      -- Update the Field of View of the camera
      game.Workspace.CurrentCamera.FieldOfView = Value
   end,
})

local ToggleInfJump = Tab4:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "ToggleInfJump",
    Callback = function(Value)
        if Value then
            _G.infinjump = true
            local plr = game:GetService('Players').LocalPlayer
            local m = plr:GetMouse()
            m.KeyDown:Connect(function(k)
                if _G.infinjump then
                    if k:byte() == 32 then
                        local humanoid = game:GetService('Players').LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
                        if humanoid then
                            humanoid:ChangeState('Jumping')
                            wait()
                            humanoid:ChangeState('Seated')
                        end
                    end
                end
            end)
        else
            _G.infinjump = false
        end
    end,
})

-- Settings Tab

local Paragraph = Tab5:CreateParagraph({Title = "", Content = "Credits to Rayfeild UI for creating this UI Library. Personally i made the exploits, (justdevfr.) and help from (nuke00723) for helping choose the name and much more. "})

local Button = Tab5:CreateButton({
   Name = "Destroy Interface",
   Callback = function()
       Rayfield:Destroy()
   end,
})
