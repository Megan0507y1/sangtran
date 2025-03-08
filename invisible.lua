local dwCamera = workspace.CurrentCamera
local dwRunService = game:GetService("RunService")
local dwUIS = game:GetService("UserInputService")
local dwEntities = game:GetService("Players")
local dwLocalPlayer = dwEntities.LocalPlayer
local dwMouse = dwLocalPlayer:GetMouse()
local Players = game:GetService("Players")

local settings = {
    Aimbot = true,
    Aiming = false,
    Aimbot_AimPart = "Head",  -- Targeting Head
    Aimbot_TeamCheck = false,
    Aimbot_Draw_FOV = true,
    Aimbot_FOV_Radius = 200,
    Aimbot_FOV_Color = Color3.fromRGB(255, 255, 255),
    Aimbot_visiblecheck = false,
    Aimbot_Key = Enum.UserInputType.MouseButton2,
    Aimbot_Onscreen = true,
    Aimbot_Speed = 10
}

-- FOV Circle
local fovcircle = Drawing.new("Circle")
fovcircle.Visible = settings.Aimbot_Draw_FOV
fovcircle.Radius = settings.Aimbot_FOV_Radius
fovcircle.Color = settings.Aimbot_FOV_Color
fovcircle.Thickness = 1
fovcircle.Filled = false
fovcircle.Transparency = 0
fovcircle.Position = Vector2.new(dwCamera.ViewportSize.X / 2, dwCamera.ViewportSize.Y / 2)

-- Function to check if target is visible
local function inlos(p, ...)
    return #dwCamera:GetPartsObscuringTarget({p}, {dwCamera, dwLocalPlayer.Character, ...}) == 0
end

-- Aimbot Targeting Logic
dwRunService.RenderStepped:Connect(function()
    local dist = math.huge
    local closest_char = nil

    if settings.Aimbot and settings.Aiming then
        for _, v in pairs(dwEntities:GetPlayers()) do
            if v ~= dwLocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                
                if settings.Aimbot_TeamCheck == false or v.Team ~= dwLocalPlayer.Team then
                    local char = v.Character
                    local char_part_pos, is_onscreen = dwCamera:WorldToViewportPoint(char[settings.Aimbot_AimPart].Position)
                    
                    if is_onscreen and (settings.Aimbot_Onscreen or not settings.Aimbot_Onscreen) then
                        local mag = (Vector2.new(dwMouse.X, dwMouse.Y) - Vector2.new(char_part_pos.X, char_part_pos.Y)).Magnitude
                        if mag < dist and mag < settings.Aimbot_FOV_Radius then
                            dist = mag
                            closest_char = char
                        end
                    end
                end
            end
        end

        if closest_char and closest_char:FindFirstChild("HumanoidRootPart") and closest_char:FindFirstChild("Humanoid") and closest_char.Humanoid.Health > 0 then
            local targetPos = closest_char[settings.Aimbot_AimPart].Position
            
            if inlos(targetPos, closest_char) and settings.Aimbot_visiblecheck or not settings.Aimbot_visiblecheck then
                dwCamera.CFrame = dwCamera.CFrame:Lerp(CFrame.new(dwCamera.CFrame.Position, targetPos), settings.Aimbot_Speed * 0.02)
            end
        end
    end
end)

-- Input events for right-click (MouseButton2)
dwUIS.InputBegan:Connect(function(inputObject, gameProcessed)
    if inputObject.UserInputType == settings.Aimbot_Key then
        settings.Aiming = true
    end
end)

dwUIS.InputEnded:Connect(function(inputObject, gameProcessed)
    if inputObject.UserInputType == settings.Aimbot_Key then
        settings.Aiming = false
    end
end)

-- FOV Circle Update
dwRunService.RenderStepped:Connect(function()
    fovcircle.Position = Vector2.new(dwCamera.ViewportSize.X / 2, dwCamera.ViewportSize.Y / 2)
    fovcircle.Radius = settings.Aimbot_FOV_Radius
end)

-- ESP Function
local function applyHighlight(player, fillColor, outlineColor)
    player.CharacterAdded:Connect(function(character)
        if not character:FindFirstChild("ESP_Highlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.Parent = character
            highlight.FillColor = fillColor or Color3.fromRGB(255, 255, 0)
            highlight.OutlineColor = outlineColor or Color3.fromRGB(255, 0, 0)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end)
    
    if player.Character then
        local character = player.Character
        if not character:FindFirstChild("ESP_Highlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.Parent = character
            highlight.FillColor = fillColor or Color3.fromRGB(255, 255, 0)
            highlight.OutlineColor = outlineColor or Color3.fromRGB(255, 0, 0)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
end

local function applyESPToAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        applyHighlight(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    applyHighlight(player)
    player.CharacterAdded:Connect(function()
        applyHighlight(player)
    end)
end)

applyESPToAllPlayers()
