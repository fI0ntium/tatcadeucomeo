local Cat = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild('AuzuRax') then
    CoreGui:FindFirstChild('AuzuRax'):Destroy()
end

GetIcon = function(i)
    if type(i) == 'string' and (i:find('://') or i:find('http')) then
        return i
    end

    if type(i) == 'number' then
        return "rbxassetid://" .. tostring(i)
    end

    if type(i) == 'string' then
        if i ~= "" then
            return "rbxassetid://" .. i
        else
            return ""
        end
    end

    return ""
end

tw = function(info)
    return TweenService:Create(info.v, TweenInfo.new(info.t, Enum.EasingStyle[info.s], Enum.EasingDirection[info.d]),
        info.g)
end

lak = function(a)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y)
        local Tween = TweenService:Create(a, TweenInfo.new(0.3), { Position = pos })
        Tween:Play()
    end

    a.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = a.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    a.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

ResizeFrame = function(frame)
    local resizing = false
    local startSize = nil
    local holdTime = 0
    local holdConnection = nil
    local canResize = false
    local touches = {}
    local initialDistance = nil

    local ResizeHandle = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local UIStroke = Instance.new("UIStroke")
    local ResizeIcon = Instance.new("ImageLabel")
    local ProgressRing = Instance.new("Frame")
    local ProgressInner = Instance.new("Frame")
    local UICornerProgress = Instance.new("UICorner")
    local UICornerInner = Instance.new("UICorner")
    local UIGradientProgress = Instance.new("UIGradient")

    ResizeHandle.Name = "ResizeHandle"
    ResizeHandle.Parent = frame
    ResizeHandle.AnchorPoint = Vector2.new(1, 1)
    ResizeHandle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    ResizeHandle.BackgroundTransparency = 0.3
    ResizeHandle.Position = UDim2.new(1, -5, 1, -5)
    ResizeHandle.Size = UDim2.new(0, 25, 0, 25)
    ResizeHandle.ZIndex = 10

    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = ResizeHandle

    UIStroke.Parent = ResizeHandle
    UIStroke.Color = Color3.fromRGB(100, 100, 130)
    UIStroke.Thickness = 2
    UIStroke.Transparency = 0.7

    ResizeIcon.Parent = ResizeHandle
    ResizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    ResizeIcon.BackgroundTransparency = 1
    ResizeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    ResizeIcon.Size = UDim2.new(0, 14, 0, 14)
    ResizeIcon.Image = "rbxassetid://7734053495"
    ResizeIcon.ImageColor3 = Color3.fromRGB(150, 150, 180)

    ProgressRing.Name = "ProgressRing"
    ProgressRing.Parent = ResizeHandle
    ProgressRing.AnchorPoint = Vector2.new(0.5, 0.5)
    ProgressRing.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ProgressRing.BackgroundTransparency = 1
    ProgressRing.Position = UDim2.new(0.5, 0, 0.5, 0)
    ProgressRing.Size = UDim2.new(0, 25, 0, 25)
    ProgressRing.ZIndex = 9

    UICornerProgress.CornerRadius = UDim.new(1, 0)
    UICornerProgress.Parent = ProgressRing

    UIGradientProgress.Parent = ProgressRing
    UIGradientProgress.Color = ColorSequence.new {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
    }

    ProgressInner.Name = "ProgressInner"
    ProgressInner.Parent = ProgressRing
    ProgressInner.AnchorPoint = Vector2.new(0.5, 0.5)
    ProgressInner.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    ProgressInner.Position = UDim2.new(0.5, 0, 0.5, 0)
    ProgressInner.Size = UDim2.new(0, 19, 0, 19)
    ProgressInner.ZIndex = 10

    UICornerInner.CornerRadius = UDim.new(1, 0)
    UICornerInner.Parent = ProgressInner

    local function getTouchCount()
        local count = 0
        for _ in pairs(touches) do
            count = count + 1
        end
        return count
    end

    local function getDistance(pos1, pos2)
        return (pos1 - pos2).Magnitude
    end

    local function resetResize()
        resizing = false
        canResize = false
        holdTime = 0
        touches = {}
        initialDistance = nil
        if holdConnection then
            holdConnection:Disconnect()
            holdConnection = nil
        end
        tw({ v = UIStroke, t = 0.3, s = "Back", d = "Out", g = { Transparency = 0.7, Color = Color3.fromRGB(100, 100, 130) } })
            :Play()
        tw({ v = ResizeHandle, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0, 25, 0, 25), BackgroundTransparency = 0.3 } })
            :Play()
        tw({ v = ResizeIcon, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0, 14, 0, 14), ImageColor3 = Color3.fromRGB(150, 150, 180) } })
            :Play()
        tw({ v = ProgressRing, t = 0.3, s = "Back", d = "Out", g = { BackgroundTransparency = 1, Size = UDim2.new(0, 25, 0, 25) } })
            :Play()
        tw({ v = ProgressInner, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0, 19, 0, 19) } }):Play()
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touches[input] = input.Position

            if getTouchCount() == 2 and not canResize and not holdConnection then
                holdTime = 0
                local touchList = {}
                for touch, _ in pairs(touches) do
                    table.insert(touchList, touch.Position)
                end
                if #touchList == 2 then
                    initialDistance = getDistance(touchList[1], touchList[2])
                end

                holdConnection = RunService.Heartbeat:Connect(function(dt)
                    if getTouchCount() ~= 2 then
                        resetResize()
                        return
                    end

                    holdTime = holdTime + dt
                    local progress = math.clamp(holdTime / 2, 0, 1)

                    local ringSize = 25 + (progress * 15)
                    local innerSize = 19 + (progress * 9)

                    ProgressRing.Size = UDim2.new(0, ringSize, 0, ringSize)
                    ProgressInner.Size = UDim2.new(0, innerSize, 0, innerSize)
                    ProgressRing.BackgroundTransparency = 1 - progress

                    if progress < 1 then
                        local angle = progress * 360
                        UIGradientProgress.Rotation = angle
                    end

                    if holdTime >= 2 and not canResize then
                        canResize = true
                        resizing = true
                        startSize = frame.Size

                        tw({ v = UIStroke, t = 0.3, s = "Back", d = "Out", g = { Transparency = 0.2, Color = Color3.fromRGB(0, 255, 127) } })
                            :Play()
                        tw({ v = ResizeHandle, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0, 35, 0, 35), BackgroundTransparency = 0.1 } })
                            :Play()
                        tw({ v = ResizeIcon, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0, 20, 0, 20), ImageColor3 = Color3.fromRGB(0, 255, 127) } })
                            :Play()

                        task.wait(0.5)
                        tw({ v = ResizeHandle, t = 0.4, s = "Back", d = "Out", g = { Size = UDim2.new(0, 28, 0, 28) } })
                            :Play()
                        tw({ v = ResizeIcon, t = 0.4, s = "Back", d = "Out", g = { Size = UDim2.new(0, 16, 0, 16) } })
                            :Play()
                    end
                end)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touches[input] = nil
            if getTouchCount() < 2 then
                if canResize then
                    resizing = false
                else
                    resetResize()
                end
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and resizing and canResize then
            local touchList = {}
            for touch, _ in pairs(touches) do
                table.insert(touchList, touch.Position)
            end

            if #touchList == 2 and initialDistance then
                local currentDistance = getDistance(touchList[1], touchList[2])
                local scale = currentDistance / initialDistance

                local newSizeX = math.clamp(startSize.X.Offset * scale, 400, 800)
                local newSizeY = math.clamp(startSize.Y.Offset * scale, 280, 600)

                frame.Size = UDim2.new(0, newSizeX, 0, newSizeY)
            end
        end
    end)
end

click = function(p)
    local Click = Instance.new("TextButton")
    Click.Name = "Click"
    Click.Parent = p
    Click.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Click.BackgroundTransparency = 1.000
    Click.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Click.BorderSizePixel = 0
    Click.Size = UDim2.new(1, 0, 1, 0)
    Click.Font = Enum.Font.SourceSans
    Click.Text = ""
    Click.TextColor3 = Color3.fromRGB(0, 0, 0)
    Click.TextSize = 14.000
    Click.ZIndex = 5
    return Click
end

EffectClick = function(c, p)
    local Mouse = Players.LocalPlayer:GetMouse()
    local relativeX = Mouse.X - c.AbsolutePosition.X
    local relativeY = Mouse.Y - c.AbsolutePosition.Y

    if relativeX < 0 or relativeY < 0 or relativeX > c.AbsoluteSize.X or relativeY > c.AbsoluteSize.Y then
        return
    end

    local ClickButtonCircle = Instance.new("Frame")
    ClickButtonCircle.Parent = p
    ClickButtonCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ClickButtonCircle.BackgroundTransparency = 0.5
    ClickButtonCircle.BorderSizePixel = 0
    ClickButtonCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    ClickButtonCircle.Position = UDim2.new(0, relativeX, 0, relativeY)
    ClickButtonCircle.Size = UDim2.new(0, 0, 0, 0)
    ClickButtonCircle.ZIndex = 10

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = ClickButtonCircle

    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = {
        Size = UDim2.new(0, c.AbsoluteSize.X * 1.5, 0, c.AbsoluteSize.X * 1.5),
        BackgroundTransparency = 1
    }

    local expandTween = TweenService:Create(ClickButtonCircle, tweenInfo, goal)
    expandTween.Completed:Connect(function()
        ClickButtonCircle:Destroy()
    end)
    expandTween:Play()
end

EffectClick2 = function(c, p)
    local Mouse = Players.LocalPlayer:GetMouse()
    local relativeX = Mouse.X - c.AbsolutePosition.X
    local relativeY = Mouse.Y - c.AbsolutePosition.Y

    if relativeX < 0 or relativeY < 0 or relativeX > c.AbsoluteSize.X or relativeY > c.AbsoluteSize.Y then
        return
    end

    local ClickButtonCircle = Instance.new("Frame")
    ClickButtonCircle.Parent = p
    ClickButtonCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ClickButtonCircle.BackgroundTransparency = 0.5
    ClickButtonCircle.BorderSizePixel = 0
    ClickButtonCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    ClickButtonCircle.Position = UDim2.new(0, relativeX, 0, relativeY)
    ClickButtonCircle.Size = UDim2.new(0, 0, 0, 0)
    ClickButtonCircle.ZIndex = 10

    local UIGradient_2 = Instance.new("UIGradient")
    UIGradient_2.Parent = ClickButtonCircle
    UIGradient_2.Color = ColorSequence.new { ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255)) }
    UIGradient_2.Rotation = 48

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = ClickButtonCircle

    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = {
        Size = UDim2.new(0, c.AbsoluteSize.X * 1.5, 0, c.AbsoluteSize.X * 1.5),
        BackgroundTransparency = 1
    }

    local expandTween = TweenService:Create(ClickButtonCircle, tweenInfo, goal)
    expandTween.Completed:Connect(function()
        ClickButtonCircle:Destroy()
    end)
    expandTween:Play()
end

local AuzuRax = Instance.new("ScreenGui")
AuzuRax.Name = "AuzuRax"
AuzuRax.Parent = not RunService:IsStudio() and CoreGui or Players.LocalPlayer.PlayerGui
AuzuRax.ZIndexBehavior = Enum.ZIndexBehavior.Global
function Cat:Window(meta)
    local Title = meta.Title or "Title"
    local Desc = meta.Desc or "Desc"
    local IconTile = meta.IconTile or nil
    local SizeUi = meta.SizeUi or "520,340"
    local Theme = meta.Theme or nil

    local sizeValues = {}
    for value in string.gmatch(SizeUi, "[^,]+") do
        table.insert(sizeValues, tonumber(value))
    end
    local uiWidth = sizeValues[1] or 520
    local uiHeight = sizeValues[2] or 340

    local Background_1 = Instance.new("Frame")
    local DropShadow_1 = Instance.new("ImageLabel")
    local UICorner_1 = Instance.new("UICorner")
    local UIStroke_main = Instance.new("UIStroke")
    local Header_1 = Instance.new("Frame")
    local Title_1 = Instance.new("TextLabel")
    local UIListLayout_1 = Instance.new("UIListLayout")
    local UIPadding_1 = Instance.new("UIPadding")
    local Line_1 = Instance.new("Frame")
    local UIGradient_1 = Instance.new("UIGradient")
    local Desc_1 = Instance.new("TextLabel")
    local Effect_1 = Instance.new("ImageLabel")

    Background_1.Name = "Background"
    Background_1.Parent = AuzuRax
    Background_1.AnchorPoint = Vector2.new(0.5, 0.5)
    Background_1.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    Background_1.BackgroundTransparency = 0.1
    Background_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Background_1.BorderSizePixel = 0
    Background_1.Position = UDim2.new(0.5, 0, 0.5, 0)
    Background_1.Size = UDim2.new(0, 0, 0, 0)
    lak(Background_1)
    ResizeFrame(Background_1)
    tw({ v = Background_1, t = 1, s = "Bounce", d = "Out", g = { Size = UDim2.new(0, uiWidth, 0, uiHeight) } }):Play()

    UIStroke_main.Parent = Background_1
    UIStroke_main.Color = Color3.fromRGB(80, 80, 100)
    UIStroke_main.Thickness = 2.5
    UIStroke_main.Transparency = 0.6

    DropShadow_1.Name = "DropShadow"
    DropShadow_1.Parent = Background_1
    DropShadow_1.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow_1.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    DropShadow_1.BackgroundTransparency = 1
    DropShadow_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow_1.BorderSizePixel = 0
    DropShadow_1.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow_1.Size = UDim2.new(1, 160, 1, 160)
    DropShadow_1.ZIndex = 0
    DropShadow_1.Image = "rbxassetid://8992230677"
    DropShadow_1.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow_1.ImageTransparency = 0.15
    DropShadow_1.ScaleType = Enum.ScaleType.Slice
    DropShadow_1.SliceCenter = Rect.new(99, 99, 99, 99)

    Effect_1.Name = "Effect"
    Effect_1.Parent = Background_1
    Effect_1.AnchorPoint = Vector2.new(0.5, 0.5)
    Effect_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Effect_1.BackgroundTransparency = 1
    Effect_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Effect_1.BorderSizePixel = 0
    Effect_1.Position = UDim2.new(0.5, 0, 0.5, 0)
    Effect_1.Size = UDim2.new(1, 0, 1, 0)
    Effect_1.Image = "rbxassetid://132687652275989"
    Effect_1.ImageColor3 = Color3.fromRGB(0, 255, 127)
    Effect_1.ImageTransparency = 0.05
    Effect_1.ScaleType = Enum.ScaleType.Crop
    Effect_1.ZIndex = 1

    if Theme then
        local ThemeImage = Instance.new("ImageLabel")
        ThemeImage.Name = "ThemeImage"
        ThemeImage.Parent = Background_1
        ThemeImage.AnchorPoint = Vector2.new(0.5, 0.5)
        ThemeImage.BackgroundTransparency = 1
        ThemeImage.Position = UDim2.new(0.5, 0, 0.5, 0)
        ThemeImage.Size = UDim2.new(1, 0, 1, 0)
        ThemeImage.Image = GetIcon(Theme)
        ThemeImage.ImageTransparency = 0.7
        ThemeImage.ScaleType = Enum.ScaleType.Crop
        ThemeImage.ZIndex = 1

        local ThemeCorner = Instance.new("UICorner")
        ThemeCorner.CornerRadius = UDim.new(0, 20)
        ThemeCorner.Parent = ThemeImage

        UIStroke_main.Color = Color3.fromRGB(120, 120, 150)
        UIStroke_main.Transparency = 0.3
        UIStroke_main.Thickness = 3
    end

    UICorner_1.Parent = Background_1
    UICorner_1.CornerRadius = UDim.new(0, 20)

    Header_1.Name = "Header"
    Header_1.Parent = Background_1
    Header_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Header_1.BackgroundTransparency = 1
    Header_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Header_1.BorderSizePixel = 0
    Header_1.Size = UDim2.new(1, 0, 0, 65)

    if IconTile then
        local IconTileFrame = Instance.new("Frame")
        local IconTileImage = Instance.new("ImageLabel")
        local TitleWithIcon = Instance.new("TextLabel")

        IconTileFrame.Name = "IconTileFrame"
        IconTileFrame.Parent = Header_1
        IconTileFrame.BackgroundTransparency = 1
        IconTileFrame.Size = UDim2.new(0, 450, 0, 22)

        IconTileImage.Name = "IconTileImage"
        IconTileImage.Parent = IconTileFrame
        IconTileImage.AnchorPoint = Vector2.new(0, 0.5)
        IconTileImage.BackgroundTransparency = 1
        IconTileImage.Position = UDim2.new(0, 0, 0.5, 0)
        IconTileImage.Size = UDim2.new(0, 22, 0, 22)
        IconTileImage.Image = GetIcon(IconTile)
        IconTileImage.ScaleType = Enum.ScaleType.Fit

        TitleWithIcon.Name = "TitleWithIcon"
        TitleWithIcon.Parent = IconTileFrame
        TitleWithIcon.BackgroundTransparency = 1
        TitleWithIcon.Position = UDim2.new(0, 28, 0, 0)
        TitleWithIcon.Size = UDim2.new(1, -28, 1, 0)
        TitleWithIcon.Font = Enum.Font.GothamBold
        TitleWithIcon.Text = Title
        TitleWithIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleWithIcon.TextSize = 26
        TitleWithIcon.TextWrapped = true
        TitleWithIcon.TextXAlignment = Enum.TextXAlignment.Left

        Title_1 = TitleWithIcon
    else
        Title_1.Name = "Title"
        Title_1.Parent = Header_1
        Title_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Title_1.BackgroundTransparency = 1
        Title_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Title_1.BorderSizePixel = 0
        Title_1.Position = UDim2.new(0, 0, 0.116666667, 0)
        Title_1.Size = UDim2.new(0, 450, 0, 22)
        Title_1.Font = Enum.Font.GothamBold
        Title_1.Text = Title
        Title_1.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title_1.TextSize = 26
        Title_1.TextWrapped = true
        Title_1.TextXAlignment = Enum.TextXAlignment.Left
    end

    UIListLayout_1.Parent = Header_1
    UIListLayout_1.Padding = UDim.new(0, 7)
    UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

    UIPadding_1.Parent = Header_1
    UIPadding_1.PaddingLeft = UDim.new(0, 20)
    UIPadding_1.PaddingTop = UDim.new(0, 5)

    Line_1.Name = "Line"
    Line_1.Parent = Header_1
    Line_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Line_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Line_1.BorderSizePixel = 0
    Line_1.Size = UDim2.new(0, 80, 0, 3.5)

    UIGradient_1.Parent = Line_1
    UIGradient_1.Color = ColorSequence.new { ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255)) }

    Desc_1.Name = "Desc"
    Desc_1.Parent = Header_1
    Desc_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Desc_1.BackgroundTransparency = 1
    Desc_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Desc_1.BorderSizePixel = 0
    Desc_1.Position = UDim2.new(0.0179999992, 0, 0, 0)
    Desc_1.Size = UDim2.new(0, 220, 0, 6)
    Desc_1.Font = Enum.Font.GothamBold
    Desc_1.Text = Desc
    Desc_1.TextColor3 = Color3.fromRGB(255, 255, 255)
    Desc_1.TextSize = 15
    Desc_1.TextTransparency = 0.35
    Desc_1.TextXAlignment = Enum.TextXAlignment.Left
    local CloseUI = Instance.new("TextButton")
    local UICorner_1z = Instance.new("UICorner")
    local UIStroke_close = Instance.new("UIStroke")
    local CloseText = Instance.new("TextLabel")

    CloseUI.Name = "CloseUI"
    CloseUI.Parent = AuzuRax
    CloseUI.AnchorPoint = Vector2.new(0, 1)
    CloseUI.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    CloseUI.BorderSizePixel = 0
    CloseUI.Position = UDim2.new(0.06, 0, 0.21, 0)
    CloseUI.Size = UDim2.new(0, 55, 0, 55)
    CloseUI.BackgroundTransparency = 0.15
    CloseUI.Text = ""
    CloseUI.AutoButtonColor = false
    lak(CloseUI)

    UICorner_1z.Parent = CloseUI
    UICorner_1z.CornerRadius = UDim.new(0, 14)

    UIStroke_close.Parent = CloseUI
    UIStroke_close.Color = Color3.fromRGB(100, 100, 130)
    UIStroke_close.Thickness = 2.5
    UIStroke_close.Transparency = 0.6

    CloseText.Name = "CloseText"
    CloseText.Parent = CloseUI
    CloseText.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseText.BackgroundTransparency = 1
    CloseText.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseText.Size = UDim2.new(1, 0, 1, 0)
    CloseText.Font = Enum.Font.GothamBlack
    CloseText.Text = "Close"
    CloseText.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseText.TextSize = 16
    CloseText.TextTransparency = 0
    CloseText.ZIndex = 3

    local function tweenText(new)
        pcall(function()
            tw({ v = CloseText, t = 0.15, s = "Quad", d = "Out", g = { TextTransparency = 1 } }):Play()
        end)
        task.wait(0.15)
        CloseText.Text = new
        pcall(function()
            tw({ v = CloseText, t = 0.15, s = "Quad", d = "Out", g = { TextTransparency = 0 } }):Play()
        end)
    end

    local function closeopenui()
        local was = Background_1.Visible
        local newText = was and "Open" or "Close"
        tweenText(newText)
        Background_1.Visible = not was
    end

    CloseUI.MouseButton1Click:Connect(function()
        closeopenui()
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.F2 then
            closeopenui()
        end
    end)
    local Tab_1 = Instance.new("ScrollingFrame")
    local TabGrid = Instance.new("UIGridLayout")

    Tab_1.Name = "Tab"
    Tab_1.Parent = Background_1
    Tab_1.AnchorPoint = Vector2.new(0.5, 0.5)
    Tab_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Tab_1.BackgroundTransparency = 1
    Tab_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Tab_1.BorderSizePixel = 0
    Tab_1.Position = UDim2.new(0.5, 0, 0.58, 0)
    Tab_1.Size = UDim2.new(0.96, 0, 0.73, 0)
    Tab_1.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 130)
    Tab_1.ScrollBarThickness = 4
    Tab_1.ScrollBarImageTransparency = 0.5

    TabGrid.Parent = Tab_1
    TabGrid.CellPadding = UDim2.new(0, 12, 0, 12)
    TabGrid.CellSize = UDim2.new(0.23, 0, 0, 110)
    TabGrid.SortOrder = Enum.SortOrder.LayoutOrder

    Background_1:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local width = Background_1.AbsoluteSize.X
        if width <= 450 then
            TabGrid.CellSize = UDim2.new(0.31, 0, 0, 110)
        else
            TabGrid.CellSize = UDim2.new(0.23, 0, 0, 110)
        end
    end)

    TabGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Tab_1.CanvasSize = UDim2.new(0, 0, 0, TabGrid.AbsoluteContentSize.Y + 15)
    end)

    local Return = Instance.new("Frame")
    local UICorner_ret = Instance.new("UICorner")
    local UIGradient_ret = Instance.new("UIGradient")
    local UIStroke_ret = Instance.new("UIStroke")
    local ImageLabel_ret = Instance.new("ImageLabel")
    local TextLabel_ret = Instance.new("TextLabel")

    Return.Name = "Return"
    Return.Parent = Background_1
    Return.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Return.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Return.BorderSizePixel = 0
    Return.Position = UDim2.new(0.77, 0, 0.055, 0)
    Return.Size = UDim2.new(0, 100, 0, 30)
    Return.ClipsDescendants = true
    Return.Visible = false

    UICorner_ret.Parent = Return
    UICorner_ret.CornerRadius = UDim.new(0, 10)

    UIGradient_ret.Parent = Return
    UIGradient_ret.Color = ColorSequence.new { ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 89, 89)), ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 0, 0)) }

    UIStroke_ret.Parent = Return
    UIStroke_ret.Color = Color3.fromRGB(255, 85, 127)
    UIStroke_ret.Thickness = 2.5

    ImageLabel_ret.Parent = Return
    ImageLabel_ret.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel_ret.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_ret.BackgroundTransparency = 1
    ImageLabel_ret.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_ret.BorderSizePixel = 0
    ImageLabel_ret.Position = UDim2.new(0.5, 0, 0.5, 0)
    ImageLabel_ret.Size = UDim2.new(1, 50, 1, 0)
    ImageLabel_ret.Image = "rbxassetid://87782680483863"
    ImageLabel_ret.ImageTransparency = 0.75
    ImageLabel_ret.ScaleType = Enum.ScaleType.Crop

    TextLabel_ret.Parent = Return
    TextLabel_ret.AnchorPoint = Vector2.new(0.5, 0.5)
    TextLabel_ret.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel_ret.BackgroundTransparency = 1
    TextLabel_ret.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel_ret.BorderSizePixel = 0
    TextLabel_ret.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextLabel_ret.Size = UDim2.new(1, 0, 1, 0)
    TextLabel_ret.Font = Enum.Font.GothamBold
    TextLabel_ret.Text = "Back"
    TextLabel_ret.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel_ret.TextSize = 14

    local ClickReturn = click(Return)
    ClickReturn.MouseButton1Click:Connect(function()
        Header_1.Position = UDim2.new(0, -38, 0, 0)
        tw({ v = Header_1, t = 0.35, s = "Back", d = "Out", g = { Position = UDim2.new(0, 0, 0, 0) } }):Play()
        tw({ v = Title_1, t = 0.5, s = "Back", d = "Out", g = { TextTransparency = 1 } }):Play()
        tw({ v = Desc_1, t = 0.5, s = "Back", d = "Out", g = { TextTransparency = 1 } }):Play()
        tw({ v = Line_1, t = 0.5, s = "Back", d = "Out", g = { BackgroundTransparency = 1 } }):Play()
        Desc_1.Text = Desc
        Title_1.Text = Title
        delay(0.22, function()
            tw({ v = Title_1, t = 0.5, s = "Back", d = "Out", g = { TextTransparency = 0 } }):Play()
            tw({ v = Desc_1, t = 0.5, s = "Back", d = "Out", g = { TextTransparency = 0.35 } }):Play()
            tw({ v = Line_1, t = 0.5, s = "Back", d = "Out", g = { BackgroundTransparency = 0 } }):Play()
        end)
        for _, v in pairs(Background_1:GetChildren()) do
            if v.Name == "Pages" then
                v.Visible = false
            end
        end
        Tab_1.Visible = true
        tw({ v = Tab_1, t = 0.35, s = "Back", d = "Out", g = { Size = UDim2.new(0.96, 0, 0.73, 0) } }):Play()
        tw({ v = Return, t = 0.35, s = "Back", d = "Out", g = { Position = UDim2.new(0.95, 0, 0.055, 0) } }):Play()
        tw({ v = Return, t = 0.35, s = "Back", d = "Out", g = { BackgroundTransparency = 1 } }):Play()
        UIStroke_ret.Enabled = false
        tw({ v = ImageLabel_ret, t = 0.35, s = "Back", d = "Out", g = { ImageTransparency = 1 } }):Play()
        tw({ v = TextLabel_ret, t = 0.35, s = "Back", d = "Out", g = { TextTransparency = 1 } }):Play()
        task.wait(0.12)
        Return.Visible = false
    end)

    Cat.Tabs = {}

    function Cat.Tabs:Add(meta)
        local Title = meta.Title
        local Desc = meta.Desc or nil
        local Banner = meta.Banner
        local Icon = meta.Icon or nil
        local Columns = meta.Columns or 1

        local TabCard = Instance.new("Frame")
        local UICorner = Instance.new("UICorner")
        local UIStroke = Instance.new("UIStroke")
        local BannerImg = Instance.new("ImageLabel")
        local UICornerBanner = Instance.new("UICorner")
        local Overlay = Instance.new("Frame")
        local UICornerOverlay = Instance.new("UICorner")
        local UIGradientOverlay = Instance.new("UIGradient")
        local TitleLabel = Instance.new("TextLabel")
        local IconLabel = Instance.new("ImageLabel")
        local HubNameLabel = Instance.new("TextLabel")
        local BadgeFrame = Instance.new("Frame")
        local BadgeCorner = Instance.new("UICorner")
        local BadgeLabel = Instance.new("TextLabel")
        local BadgeGradient = Instance.new("UIGradient")
        local ClickTab = click(TabCard)

        local elementCount = 0

        TabCard.Name = "TabCard"
        TabCard.Parent = Tab_1
        TabCard.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        TabCard.BackgroundTransparency = 0.2
        TabCard.BorderSizePixel = 0
        TabCard.ClipsDescendants = true

        UICorner.Parent = TabCard
        UICorner.CornerRadius = UDim.new(0, 16)

        UIStroke.Parent = TabCard
        UIStroke.Color = Color3.fromRGB(120, 120, 150)
        UIStroke.Thickness = 2
        UIStroke.Transparency = 0.75

        BannerImg.Name = "Banner"
        BannerImg.Parent = TabCard
        BannerImg.AnchorPoint = Vector2.new(0.5, 0.5)
        BannerImg.BackgroundTransparency = 1
        BannerImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        BannerImg.Size = UDim2.new(1, 0, 1, 0)
        BannerImg.Image = GetIcon(Banner)
        BannerImg.ScaleType = Enum.ScaleType.Crop
        BannerImg.ZIndex = 2
        BannerImg.ImageTransparency = 1

        task.spawn(function()
            task.wait(0.1)
            tw({ v = BannerImg, t = 0.6, s = "Quad", d = "Out", g = { ImageTransparency = 0 } }):Play()
        end)

        UICornerBanner.Parent = BannerImg
        UICornerBanner.CornerRadius = UDim.new(0, 16)

        Overlay.Name = "Overlay"
        Overlay.Parent = TabCard
        Overlay.AnchorPoint = Vector2.new(0.5, 0.5)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 0.2
        Overlay.Position = UDim2.new(0.5, 0, 0.5, 0)
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.ZIndex = 3

        UICornerOverlay.Parent = Overlay
        UICornerOverlay.CornerRadius = UDim.new(0, 16)

        UIGradientOverlay.Parent = Overlay
        UIGradientOverlay.Color = ColorSequence.new {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
        }
        UIGradientOverlay.Rotation = 50
        UIGradientOverlay.Transparency = NumberSequence.new {
            NumberSequenceKeypoint.new(0, 0.7),
            NumberSequenceKeypoint.new(1, 0.9)
        }

        BadgeFrame.Name = "BadgeFrame"
        BadgeFrame.Parent = TabCard
        BadgeFrame.AnchorPoint = Vector2.new(1, 0)
        BadgeFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        BadgeFrame.Position = UDim2.new(1, -8, 0, 8)
        BadgeFrame.Size = UDim2.new(0, 32, 0, 18)
        BadgeFrame.ZIndex = 6

        BadgeCorner.CornerRadius = UDim.new(1, 0)
        BadgeCorner.Parent = BadgeFrame

        BadgeGradient.Parent = BadgeFrame
        BadgeGradient.Color = ColorSequence.new {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 200, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 255))
        }
        BadgeGradient.Rotation = 45

        BadgeLabel.Name = "BadgeLabel"
        BadgeLabel.Parent = BadgeFrame
        BadgeLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        BadgeLabel.BackgroundTransparency = 1
        BadgeLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
        BadgeLabel.Size = UDim2.new(1, -4, 1, -4)
        BadgeLabel.Font = Enum.Font.GothamBold
        BadgeLabel.Text = "0"
        BadgeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        BadgeLabel.TextSize = 12
        BadgeLabel.TextStrokeTransparency = 0.5
        BadgeLabel.ZIndex = 7

        if Icon and Icon ~= "" then
            IconLabel.Name = "Icon"
            IconLabel.Parent = TabCard
            IconLabel.AnchorPoint = Vector2.new(0, 0.5)
            IconLabel.BackgroundTransparency = 1
            IconLabel.Position = UDim2.new(0, 8, 0.5, 0)
            IconLabel.Size = UDim2.new(0, 32, 0, 32)
            IconLabel.Image = GetIcon(Icon)
            IconLabel.ScaleType = Enum.ScaleType.Fit
            IconLabel.ZIndex = 5

            HubNameLabel.Name = "HubName"
            HubNameLabel.Parent = TabCard
            HubNameLabel.AnchorPoint = Vector2.new(0, 0.5)
            HubNameLabel.BackgroundTransparency = 1
            HubNameLabel.Position = UDim2.new(0, 45, 0.5, -15)
            HubNameLabel.Size = UDim2.new(0.65, 0, 0, 18)
            HubNameLabel.Font = Enum.Font.GothamBold
            HubNameLabel.Text = Title
            HubNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            HubNameLabel.TextSize = 11
            HubNameLabel.TextStrokeTransparency = 0.3
            HubNameLabel.TextXAlignment = Enum.TextXAlignment.Left
            HubNameLabel.TextScaled = true
            HubNameLabel.TextWrapped = true
            HubNameLabel.ZIndex = 5

            local HubSizeConstraint = Instance.new("UITextSizeConstraint")
            HubSizeConstraint.Parent = HubNameLabel
            HubSizeConstraint.MaxTextSize = 11
            HubSizeConstraint.MinTextSize = 8

            TitleLabel.Position = UDim2.new(0, 45, 0.5, 5)
            TitleLabel.Size = UDim2.new(0.65, 0, 0, 18)
            TitleLabel.TextSize = 10
            TitleLabel.TextTransparency = 0.4
        else
            TitleLabel.Position = UDim2.new(0.5, 0, 0.92, 0)
            TitleLabel.Size = UDim2.new(0.85, 0, 0, 24)
            TitleLabel.TextSize = 14
            TitleLabel.TextTransparency = 0
        end

        TitleLabel.Name = "Title"
        TitleLabel.Parent = TabCard
        TitleLabel.AnchorPoint = Vector2.new(Icon and 0 or 0.5, Icon and 0.5 or 1)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.Text = Icon and Desc or Title
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextStrokeTransparency = Icon and 0.5 or 0.3
        TitleLabel.TextScaled = true
        TitleLabel.TextWrapped = true
        TitleLabel.TextXAlignment = Icon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
        TitleLabel.ZIndex = 5

        local TextSizeConstraint = Instance.new("UITextSizeConstraint")
        TextSizeConstraint.Parent = TitleLabel
        TextSizeConstraint.MaxTextSize = Icon and 10 or 14
        TextSizeConstraint.MinTextSize = Icon and 7 or 10

        local Pages_1 = Instance.new("Frame")

        Pages_1.Name = "Pages"
        Pages_1.Parent = Background_1
        Pages_1.AnchorPoint = Vector2.new(0.5, 0.5)
        Pages_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Pages_1.BackgroundTransparency = 1
        Pages_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Pages_1.BorderSizePixel = 0
        Pages_1.Position = UDim2.new(0.5, 0, 0.58, 0)
        Pages_1.Size = UDim2.new(0.97, 0, 0.73, 0)
        Pages_1.Visible = false

        local SearchFrame = Instance.new("Frame")
        local SearchCorner = Instance.new("UICorner")
        local SearchStroke = Instance.new("UIStroke")
        local SearchGlow = Instance.new("ImageLabel")
        local SearchImage = Instance.new("ImageLabel")
        local SearchBoxFrame = Instance.new("Frame")
        local SearchBox = Instance.new("TextBox")
        local SearchUnderline = Instance.new("Frame")
        local SearchUnderlineActive = Instance.new("Frame")
        local SearchUnderlineCorner = Instance.new("UICorner")
        local SearchUnderlineActiveCorner = Instance.new("UICorner")
        local SearchGradient = Instance.new("UIGradient")

        SearchFrame.Name = "SearchFrame"
        SearchFrame.Parent = Pages_1
        SearchFrame.AnchorPoint = Vector2.new(0.5, 0)
        SearchFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
        SearchFrame.BackgroundTransparency = 0.25
        SearchFrame.BorderSizePixel = 0
        SearchFrame.ClipsDescendants = false
        SearchFrame.Position = UDim2.new(0.5, 0, 0, 0)
        SearchFrame.Size = UDim2.new(1, 0, 0, 38)

        SearchCorner.CornerRadius = UDim.new(0, 14)
        SearchCorner.Parent = SearchFrame

        SearchStroke.Parent = SearchFrame
        SearchStroke.Color = Color3.fromRGB(110, 110, 140)
        SearchStroke.Thickness = 2
        SearchStroke.Transparency = 0.7

        SearchGlow.Name = "SearchGlow"
        SearchGlow.Parent = SearchFrame
        SearchGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        SearchGlow.BackgroundTransparency = 1
        SearchGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
        SearchGlow.Size = UDim2.new(1, 70, 1, 70)
        SearchGlow.Image = "rbxassetid://8992230677"
        SearchGlow.ImageColor3 = Color3.fromRGB(0, 170, 255)
        SearchGlow.ImageTransparency = 0.9
        SearchGlow.ScaleType = Enum.ScaleType.Slice
        SearchGlow.SliceCenter = Rect.new(99, 99, 99, 99)
        SearchGlow.ZIndex = 0

        SearchImage.Name = "SearchImage"
        SearchImage.Parent = SearchFrame
        SearchImage.AnchorPoint = Vector2.new(0, 0.5)
        SearchImage.BackgroundTransparency = 1
        SearchImage.Position = UDim2.new(0, 14, 0.5, 0)
        SearchImage.Size = UDim2.new(0, 20, 0, 20)
        SearchImage.Image = "rbxassetid://18557078698"
        SearchImage.ImageColor3 = Color3.fromRGB(110, 210, 255)

        SearchBoxFrame.Name = "SearchBoxFrame"
        SearchBoxFrame.Parent = SearchFrame
        SearchBoxFrame.BackgroundTransparency = 1
        SearchBoxFrame.BorderSizePixel = 0
        SearchBoxFrame.ClipsDescendants = true
        SearchBoxFrame.Position = UDim2.new(0, 42, 0, 0)
        SearchBoxFrame.Size = UDim2.new(1, -52, 1, -6)

        SearchBox.Name = "SearchBox"
        SearchBox.Parent = SearchBoxFrame
        SearchBox.BackgroundTransparency = 1
        SearchBox.BorderSizePixel = 0
        SearchBox.Position = UDim2.new(0, 0, 0, 0)
        SearchBox.Size = UDim2.new(1, 0, 1, 0)
        SearchBox.Font = Enum.Font.GothamBold
        SearchBox.PlaceholderColor3 = Color3.fromRGB(145, 145, 170)
        SearchBox.PlaceholderText = "Search elements..."
        SearchBox.Text = ""
        SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        SearchBox.TextSize = 13
        SearchBox.TextXAlignment = Enum.TextXAlignment.Left

        SearchUnderline.Name = "SearchUnderline"
        SearchUnderline.Parent = SearchFrame
        SearchUnderline.AnchorPoint = Vector2.new(0.5, 1)
        SearchUnderline.BackgroundColor3 = Color3.fromRGB(85, 85, 110)
        SearchUnderline.BackgroundTransparency = 0.75
        SearchUnderline.BorderSizePixel = 0
        SearchUnderline.Position = UDim2.new(0.5, 0, 1, -4)
        SearchUnderline.Size = UDim2.new(1, -24, 0, 3)

        SearchUnderlineCorner.CornerRadius = UDim.new(1, 0)
        SearchUnderlineCorner.Parent = SearchUnderline

        SearchUnderlineActive.Name = "SearchUnderlineActive"
        SearchUnderlineActive.Parent = SearchUnderline
        SearchUnderlineActive.AnchorPoint = Vector2.new(0, 0.5)
        SearchUnderlineActive.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
        SearchUnderlineActive.BackgroundTransparency = 0.999
        SearchUnderlineActive.BorderSizePixel = 0
        SearchUnderlineActive.Position = UDim2.new(0, 0, 0.5, 0)
        SearchUnderlineActive.Size = UDim2.new(1, 0, 1, 0)

        SearchUnderlineActiveCorner.CornerRadius = UDim.new(1, 0)
        SearchUnderlineActiveCorner.Parent = SearchUnderlineActive

        SearchGradient.Parent = SearchUnderlineActive
        SearchGradient.Color = ColorSequence.new {
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
        }

        SearchBox.Focused:Connect(function()
            tw({ v = SearchUnderlineActive, t = 0.4, s = "Quad", d = "Out", g = { BackgroundTransparency = 0 } }):Play()
            tw({ v = SearchStroke, t = 0.4, s = "Quad", d = "Out", g = { Transparency = 0.25 } }):Play()
            tw({ v = SearchGlow, t = 0.4, s = "Quad", d = "Out", g = { ImageTransparency = 0.82 } }):Play()
            tw({ v = SearchImage, t = 0.4, s = "Quad", d = "Out", g = { ImageColor3 = Color3.fromRGB(0, 255, 127) } })
                :Play()
            tw({ v = SearchFrame, t = 0.4, s = "Quad", d = "Out", g = { BackgroundTransparency = 0.15 } }):Play()
        end)

        SearchBox.FocusLost:Connect(function()
            tw({ v = SearchUnderlineActive, t = 0.4, s = "Quad", d = "Out", g = { BackgroundTransparency = 0.999 } })
                :Play()
            tw({ v = SearchStroke, t = 0.4, s = "Quad", d = "Out", g = { Transparency = 0.7 } }):Play()
            tw({ v = SearchGlow, t = 0.4, s = "Quad", d = "Out", g = { ImageTransparency = 0.9 } }):Play()
            tw({ v = SearchImage, t = 0.4, s = "Quad", d = "Out", g = { ImageColor3 = Color3.fromRGB(110, 210, 255) } })
                :Play()
            tw({ v = SearchFrame, t = 0.4, s = "Quad", d = "Out", g = { BackgroundTransparency = 0.25 } }):Play()
        end)

        local ContentFrame = Instance.new("Frame")
        local UIListLayout_Content = Instance.new("UIListLayout")

        ContentFrame.Name = "ContentFrame"
        ContentFrame.Parent = Pages_1
        ContentFrame.AnchorPoint = Vector2.new(0.5, 0)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.BorderSizePixel = 0
        ContentFrame.Position = UDim2.new(0.5, 0, 0, 50)
        ContentFrame.Size = UDim2.new(1, 0, 1, -50)

        UIListLayout_Content.Parent = ContentFrame
        UIListLayout_Content.Padding = UDim.new(0, 10)
        UIListLayout_Content.FillDirection = Enum.FillDirection.Horizontal
        UIListLayout_Content.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_Content.VerticalAlignment = Enum.VerticalAlignment.Top
        UIListLayout_Content.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local columnsFrames = {}

        if Columns == 1 then
            local SingleColumn = Instance.new("ScrollingFrame")
            local UIListLayout_Single = Instance.new("UIListLayout")

            SingleColumn.Name = "SingleColumn"
            SingleColumn.Parent = ContentFrame
            SingleColumn.Active = true
            SingleColumn.BackgroundTransparency = 1
            SingleColumn.BorderSizePixel = 0
            SingleColumn.Size = UDim2.new(0, 500, 1, 0)
            SingleColumn.ClipsDescendants = true
            SingleColumn.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 140)
            SingleColumn.ScrollBarImageTransparency = 0.5
            SingleColumn.ScrollBarThickness = 4

            UIListLayout_Single.Parent = SingleColumn
            UIListLayout_Single.Padding = UDim.new(0, 8)
            UIListLayout_Single.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout_Single.HorizontalAlignment = Enum.HorizontalAlignment.Center

            UIListLayout_Single:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SingleColumn.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_Single.AbsoluteContentSize.Y + 20)
            end)

            columnsFrames[1] = SingleColumn
        else
            local Left_1 = Instance.new("ScrollingFrame")
            local UIListLayout_3 = Instance.new("UIListLayout")

            Left_1.Name = "Left"
            Left_1.Parent = ContentFrame
            Left_1.Active = true
            Left_1.BackgroundTransparency = 1
            Left_1.BorderSizePixel = 0
            Left_1.Size = UDim2.new(0, 240, 1, 0)
            Left_1.ClipsDescendants = true
            Left_1.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 140)
            Left_1.ScrollBarImageTransparency = 0.5
            Left_1.ScrollBarThickness = 4

            UIListLayout_3.Parent = Left_1
            UIListLayout_3.Padding = UDim.new(0, 8)
            UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder

            local Right_1 = Instance.new("ScrollingFrame")
            local UIListLayout_6 = Instance.new("UIListLayout")

            Right_1.Name = "Right"
            Right_1.Parent = ContentFrame
            Right_1.Active = true
            Right_1.BackgroundTransparency = 1
            Right_1.BorderSizePixel = 0
            Right_1.Size = UDim2.new(0, 240, 1, 0)
            Right_1.ClipsDescendants = true
            Right_1.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 140)
            Right_1.ScrollBarImageTransparency = 0.5
            Right_1.ScrollBarThickness = 4

            UIListLayout_6.Parent = Right_1
            UIListLayout_6.Padding = UDim.new(0, 8)
            UIListLayout_6.SortOrder = Enum.SortOrder.LayoutOrder

            UIListLayout_3:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Left_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_3.AbsoluteContentSize.Y + 20)
            end)

            UIListLayout_6:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Right_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_6.AbsoluteContentSize.Y + 20)
            end)

            columnsFrames[1] = Left_1
            columnsFrames[2] = Right_1
        end

        local allElements = {}

        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local searchText = string.lower(SearchBox.Text)

            for _, element in pairs(allElements) do
                if element.Frame and element.SearchName then
                    local elementName = string.lower(element.SearchName)

                    if searchText == "" or string.find(elementName, searchText, 1, true) then
                        element.Frame.Visible = true
                        if element.HighlightFrame then
                            tw({ v = element.HighlightFrame, t = 0.3, s = "Quad", d = "Out", g = { BackgroundTransparency = 0.7 } })
                                :Play()
                            task.delay(0.5, function()
                                tw({ v = element.HighlightFrame, t = 0.3, s = "Quad", d = "Out", g = { BackgroundTransparency = 1 } })
                                    :Play()
                            end)
                        end
                    else
                        element.Frame.Visible = false
                    end
                end
            end
        end)

        local originalPosition = UDim2.new(0.5, 0, 0.5, 0)

        ClickTab.MouseEnter:Connect(function()
            tw({ v = TabCard, t = 0.3, s = "Quad", d = "Out", g = { BackgroundTransparency = 0.05, Position = UDim2.new(0.5, 0, 0.48, 0) } })
                :Play()
            tw({ v = UIStroke, t = 0.3, s = "Quad", d = "Out", g = { Transparency = 0.35 } }):Play()
            tw({ v = TitleLabel, t = 0.3, s = "Quad", d = "Out", g = { TextStrokeTransparency = 0.1 } }):Play()
            tw({ v = BannerImg, t = 0.3, s = "Quad", d = "Out", g = { Size = UDim2.new(1.05, 0, 1.05, 0) } }):Play()
        end)

        ClickTab.MouseLeave:Connect(function()
            tw({ v = TabCard, t = 0.3, s = "Quad", d = "Out", g = { BackgroundTransparency = 0.2, Position = originalPosition } })
                :Play()
            tw({ v = UIStroke, t = 0.3, s = "Quad", d = "Out", g = { Transparency = 0.75 } }):Play()
            tw({ v = TitleLabel, t = 0.3, s = "Quad", d = "Out", g = { TextStrokeTransparency = 0.3 } }):Play()
            tw({ v = BannerImg, t = 0.3, s = "Quad", d = "Out", g = { Size = UDim2.new(1, 0, 1, 0) } }):Play()
        end)

        ClickTab.MouseButton1Click:Connect(function()
            Header_1.Position = UDim2.new(0, -38, 0, 0)
            tw({ v = Header_1, t = 0.4, s = "Back", d = "Out", g = { Position = UDim2.new(0, 0, 0, 0) } }):Play()
            tw({ v = Title_1, t = 0.5, s = "Back", d = "Out", g = { TextTransparency = 1 } }):Play()
            tw({ v = Desc_1, t = 0.5, s = "Back", d = "Out", g = { TextTransparency = 1 } }):Play()
            tw({ v = Line_1, t = 0.5, s = "Back", d = "Out", g = { BackgroundTransparency = 1 } }):Play()
            Desc_1.Text = Desc
            Title_1.Text = Title
            delay(0.25, function()
                tw({ v = Title_1, t = 0.5, s = "Back", d = "Out", g = { TextTransparency = 0 } }):Play()
                tw({ v = Desc_1, t = 0.5, s = "Back", d = "Out", g = { TextTransparency = 0.35 } }):Play()
                tw({ v = Line_1, t = 0.5, s = "Back", d = "Out", g = { BackgroundTransparency = 0 } }):Play()
            end)
            Return.Visible = true
            UIStroke_ret.Enabled = true
            Return.Position = UDim2.new(0.95, 0, 0.055, 0)
            tw({ v = Return, t = 0.4, s = "Back", d = "Out", g = { Position = UDim2.new(0.77, 0, 0.055, 0) } }):Play()
            tw({ v = Return, t = 0.4, s = "Back", d = "Out", g = { BackgroundTransparency = 0 } }):Play()
            tw({ v = UIStroke_ret, t = 0.4, s = "Back", d = "Out", g = { Transparency = 0 } }):Play()
            tw({ v = ImageLabel_ret, t = 0.4, s = "Back", d = "Out", g = { ImageTransparency = 0.75 } }):Play()
            tw({ v = TextLabel_ret, t = 0.4, s = "Back", d = "Out", g = { TextTransparency = 0 } }):Play()

            tw({ v = Tab_1, t = 0.4, s = "Bounce", d = "Out", g = { Size = UDim2.new(0.96, 0, 0, 0) } }):Play()
            Tab_1.Visible = false
            Pages_1.Size = UDim2.new(0.97, 0, 0, 0)
            tw({ v = Pages_1, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0.97, 0, 0.73, 0) } }):Play()
            Pages_1.Visible = true

            EffectClick2(ClickTab, TabCard)
        end)

        local function GetSide(side)
            if Columns == 1 then
                return columnsFrames[1]
            end

            if not side then
                return columnsFrames[1]
            end
            local sideLower = string.lower(tostring(side))
            if sideLower == "b" or sideLower == "right" or side == 2 then
                return columnsFrames[2]
            elseif sideLower == "a" or sideLower == "left" or side == 1 then
                return columnsFrames[1]
            else
                return columnsFrames[1]
            end
        end

        Cat.Elements = {}

        function Cat.Elements:Toggle(meta)
            local Title = meta.Title
            local Desc = meta.Desc or ""
            local Icon = meta.Icon or nil
            local Side = meta.Side or "l"
            local Value = meta.Value or false
            local Callback = meta.Callback or function() end
            local ShowStatusText = meta.ShowStatusText ~= false
            local StatusTextType = meta.StatusTextType or "TrueFalse"

            elementCount = elementCount + 1
            BadgeLabel.Text = tostring(elementCount)

            local targetWidth = math.max(32, #tostring(elementCount) * 10 + 12)
            tw({ v = BadgeFrame, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0, targetWidth, 0, 18) } }):Play()

            if Icon and Icon ~= "" then
                local ToggleImage = Instance.new("Frame")
                local Title_1 = Instance.new("TextLabel")
                local UICorner_1 = Instance.new("UICorner")
                local ImageLabel_1 = Instance.new("ImageLabel")
                local UIGradient_1 = Instance.new("UIGradient")
                local icon_1 = Instance.new("ImageLabel")
                local Desc_1 = Instance.new("TextLabel")
                local Check_1 = Instance.new("Frame")
                local ColorFrame_1 = Instance.new("Frame")
                local UIGradient_2 = Instance.new("UIGradient")
                local UICorner_2 = Instance.new("UICorner")
                local ImageLabel_2 = Instance.new("ImageLabel")
                local UICorner_3 = Instance.new("UICorner")
                local UIStroke_toggle = Instance.new("UIStroke")
                local HighlightFrame = Instance.new("Frame")
                local HighlightCorner = Instance.new("UICorner")

                local StatusText = Instance.new("TextLabel")

                local ClickToggle = click(ToggleImage)

                ToggleImage.Name = "ToggleImage"
                ToggleImage.Parent = GetSide(Side)
                ToggleImage.AnchorPoint = Vector2.new(0.5, 0.5)
                ToggleImage.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                ToggleImage.BackgroundTransparency = 0.2
                ToggleImage.BorderSizePixel = 0
                ToggleImage.Size = UDim2.new(0.97, 0, 0, 55)
                ToggleImage.ClipsDescendants = true

                HighlightFrame.Name = "HighlightFrame"
                HighlightFrame.Parent = ToggleImage
                HighlightFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HighlightFrame.BackgroundTransparency = 1
                HighlightFrame.Size = UDim2.new(1, 0, 1, 0)
                HighlightFrame.ZIndex = 2

                HighlightCorner.CornerRadius = UDim.new(0, 12)
                HighlightCorner.Parent = HighlightFrame

                Title_1.Name = "Title"
                Title_1.Parent = ToggleImage
                Title_1.AnchorPoint = Vector2.new(0, 0.5)
                Title_1.BackgroundTransparency = 1
                Title_1.Position = UDim2.new(0, 55, 0.35, 0)
                Title_1.Size = UDim2.new(0.45, 0, 0, 18)
                Title_1.Font = Enum.Font.GothamBold
                Title_1.RichText = true
                Title_1.Text = Title
                Title_1.TextColor3 = Color3.fromRGB(255, 255, 255)
                Title_1.TextSize = 14
                Title_1.TextTransparency = 0
                Title_1.TextXAlignment = Enum.TextXAlignment.Left
                Title_1.TextScaled = true
                Title_1.TextWrapped = true

                local TitleConstraint = Instance.new("UITextSizeConstraint")
                TitleConstraint.Parent = Title_1
                TitleConstraint.MaxTextSize = 14
                TitleConstraint.MinTextSize = 10

                UICorner_1.Parent = ToggleImage
                UICorner_1.CornerRadius = UDim.new(0, 12)

                ImageLabel_1.Parent = ToggleImage
                ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
                ImageLabel_1.BackgroundTransparency = 1
                ImageLabel_1.Position = UDim2.new(0.5, 0, 0.5, 0)
                ImageLabel_1.Size = UDim2.new(1, 50, 1, 0)
                ImageLabel_1.Image = "rbxassetid://72380279434385"
                ImageLabel_1.ImageTransparency = 0.9
                ImageLabel_1.ScaleType = Enum.ScaleType.Crop

                UIGradient_1.Parent = ImageLabel_1
                UIGradient_1.Color = ColorSequence.new {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
                }

                icon_1.Name = "icon"
                icon_1.Parent = ToggleImage
                icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
                icon_1.BackgroundTransparency = 1
                icon_1.Position = UDim2.new(0, 27, 0.5, 0)
                icon_1.Size = UDim2.new(0, 38, 0, 38)
                icon_1.Image = GetIcon(Icon)
                icon_1.ImageTransparency = Value and 0 or 0.4
                icon_1.ScaleType = Enum.ScaleType.Fit

                Desc_1.Name = "Desc"
                Desc_1.Parent = ToggleImage
                Desc_1.AnchorPoint = Vector2.new(0, 0.5)
                Desc_1.BackgroundTransparency = 1
                Desc_1.Position = UDim2.new(0, 55, 0.68, 0)
                Desc_1.Size = UDim2.new(0.45, 0, 0, 15)
                Desc_1.Font = Enum.Font.Gotham
                Desc_1.RichText = true
                Desc_1.Text = Desc
                Desc_1.TextColor3 = Color3.fromRGB(200, 200, 200)
                Desc_1.TextSize = 11
                Desc_1.TextTransparency = 0.3
                Desc_1.TextXAlignment = Enum.TextXAlignment.Left
                Desc_1.TextScaled = true
                Desc_1.TextWrapped = true

                local DescConstraint = Instance.new("UITextSizeConstraint")
                DescConstraint.Parent = Desc_1
                DescConstraint.MaxTextSize = 11
                DescConstraint.MinTextSize = 8

                StatusText.Name = "StatusText"
                StatusText.Parent = ToggleImage
                StatusText.AnchorPoint = Vector2.new(1, 0.5)
                StatusText.BackgroundTransparency = 1
                StatusText.Position = UDim2.new(0.95, -38, 0.5, 0)
                StatusText.Size = UDim2.new(0, 60, 0, 20)
                StatusText.Font = Enum.Font.GothamBold
                StatusText.Text = ShowStatusText and
                (StatusTextType == "idk" and (Value and "True" or "False") or tostring(Value)) or ""
                StatusText.TextColor3 = Value and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 100, 100)
                StatusText.TextSize = 12
                StatusText.TextTransparency = 0
                StatusText.TextXAlignment = Enum.TextXAlignment.Right
                StatusText.Visible = ShowStatusText

                Check_1.Name = "Check"
                Check_1.Parent = ToggleImage
                Check_1.AnchorPoint = Vector2.new(1, 0.5)
                Check_1.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                Check_1.BorderSizePixel = 0
                Check_1.Position = UDim2.new(0.95, 0, 0.5, 0)
                Check_1.Size = UDim2.new(0, 25, 0, 25)
                Check_1.ClipsDescendants = true

                ColorFrame_1.Name = "ColorFrame"
                ColorFrame_1.Parent = Check_1
                ColorFrame_1.AnchorPoint = Vector2.new(0.5, 0.5)
                ColorFrame_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ColorFrame_1.BorderSizePixel = 0
                ColorFrame_1.Position = UDim2.new(0.5, 0, 0.5, 0)
                ColorFrame_1.Size = UDim2.new(1, 0, 1, 0)
                ColorFrame_1.BackgroundTransparency = Value and 0 or 1

                UIGradient_2.Parent = ColorFrame_1
                UIGradient_2.Color = ColorSequence.new {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
                }
                UIGradient_2.Rotation = 48

                UICorner_2.Parent = ColorFrame_1
                UICorner_2.CornerRadius = UDim.new(0, 5)

                ImageLabel_2.Parent = ColorFrame_1
                ImageLabel_2.AnchorPoint = Vector2.new(0.5, 0.5)
                ImageLabel_2.BackgroundTransparency = 1
                ImageLabel_2.Position = UDim2.new(0.5, 0, 0.5, 0)
                ImageLabel_2.Size = Value and UDim2.new(0, 13, 0, 13) or UDim2.new(0, 0, 0, 0)
                ImageLabel_2.Image = "rbxassetid://86682186031062"
                ImageLabel_2.ScaleType = Enum.ScaleType.Crop

                UICorner_3.Parent = Check_1
                UICorner_3.CornerRadius = UDim.new(0, 5)

                local function Toggle(val)
                    Value = val
                    if Value then
                        Callback(Value)


                        tw({ v = ColorFrame_1, t = 0.25, s = "Quad", d = "Out", g = { BackgroundTransparency = 0 } })
                            :Play()
                        tw({ v = ImageLabel_2, t = 0.15, s = "Back", d = "Out", g = { Size = UDim2.new(0, 18, 0, 18) } })
                            :Play()
                        tw({ v = icon_1, t = 0.2, s = "Quad", d = "Out", g = { ImageTransparency = 0 } }):Play()

                        delay(0.08, function()
                            tw({ v = ImageLabel_2, t = 0.2, s = "Back", d = "Out", g = { Size = UDim2.new(0, 13, 0, 13) } })
                                :Play()
                        end)

                        if ShowStatusText then
                            StatusText.Text = StatusTextType == "OnOff" and "ON" or "true"
                            tw({
                                v = StatusText,
                                t = 0.2,
                                s = "Quad",
                                d = "Out",
                                g = {
                                    TextColor3 = Color3.fromRGB(0, 255, 127)
                                }
                            }):Play()
                        end
                    else
                        Callback(Value)

                        tw({ v = ColorFrame_1, t = 0.25, s = "Quad", d = "Out", g = { BackgroundTransparency = 1 } })
                            :Play()
                        tw({ v = ImageLabel_2, t = 0.2, s = "Quad", d = "Out", g = { Size = UDim2.new(0, 0, 0, 0) } })
                            :Play()
                        tw({ v = icon_1, t = 0.2, s = "Quad", d = "Out", g = { ImageTransparency = 0.4 } }):Play()

                        if ShowStatusText then
                            StatusText.Text = StatusTextType == "OnOff" and "OFF" or "false"
                            tw({
                                v = StatusText,
                                t = 0.2,
                                s = "Quad",
                                d = "Out",
                                g = {
                                    TextColor3 = Color3.fromRGB(255, 100, 100)
                                }
                            }):Play()
                        end
                    end
                end

                ClickToggle.MouseButton1Click:Connect(function()
                    EffectClick2(ClickToggle, ToggleImage)
                    Toggle(not Value)
                end)

                table.insert(allElements, { Frame = ToggleImage, SearchName = Title, HighlightFrame = HighlightFrame })

                local Index = {}

                function Index:SetValue(v)
                    Toggle(v)
                end

                function Index:GetValue()
                    return Value
                end

                function Index:SetTitle(v)
                    Title_1.Text = v
                    for _, element in pairs(allElements) do
                        if element.Frame == ToggleImage then
                            element.SearchName = v
                            break
                        end
                    end
                end

                function Index:SetDesc(v)
                    Desc_1.Text = v
                end

                function Index:SetIcon(v)
                    icon_1.Image = GetIcon(v)
                end

                function Index:Visible(v)
                    ToggleImage.Visible = v
                end

                function Index:SetStatusTextType(type)
                    StatusTextType = type
                    if ShowStatusText then
                        StatusText.Text = type == "OnOff" and (Value and "ON" or "OFF") or tostring(Value)
                    end
                end

                function Index:ShowStatus(show)
                    ShowStatusText = show
                    StatusText.Visible = show
                end

                return Index
            else
                local Togglez = Instance.new("Frame")
                local Title_1 = Instance.new("TextLabel")
                local UICorner_1 = Instance.new("UICorner")
                local ImageLabel_1 = Instance.new("ImageLabel")
                local UIGradient_1 = Instance.new("UIGradient")
                local Check_1 = Instance.new("Frame")
                local ColorFrame_1 = Instance.new("Frame")
                local UIGradient_2 = Instance.new("UIGradient")
                local UICorner_2 = Instance.new("UICorner")
                local ImageLabel_2 = Instance.new("ImageLabel")
                local UICorner_3 = Instance.new("UICorner")
                local Desc_1 = Instance.new("TextLabel")
                local UIStroke_toggle = Instance.new("UIStroke")
                local HighlightFrame = Instance.new("Frame")
                local HighlightCorner = Instance.new("UICorner")

                local StatusText = Instance.new("TextLabel")

                local ClickToggle = click(Togglez)

                Togglez.Name = "Toggle"
                Togglez.Parent = GetSide(Side)
                Togglez.AnchorPoint = Vector2.new(0.5, 0.5)
                Togglez.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                Togglez.BackgroundTransparency = 0.2
                Togglez.BorderSizePixel = 0
                Togglez.Size = UDim2.new(0.97, 0, 0, 55)
                Togglez.ClipsDescendants = true

                HighlightFrame.Name = "HighlightFrame"
                HighlightFrame.Parent = Togglez
                HighlightFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HighlightFrame.BackgroundTransparency = 1
                HighlightFrame.Size = UDim2.new(1, 0, 1, 0)
                HighlightFrame.ZIndex = 2

                HighlightCorner.CornerRadius = UDim.new(0, 12)
                HighlightCorner.Parent = HighlightFrame

                Title_1.Name = "Title"
                Title_1.Parent = Togglez
                Title_1.AnchorPoint = Vector2.new(0, 0.5)
                Title_1.BackgroundTransparency = 1
                Title_1.Position = UDim2.new(0.03, 0, 0.35, 0)
                Title_1.Size = UDim2.new(0.62, 0, 0, 18)
                Title_1.Font = Enum.Font.GothamBold
                Title_1.RichText = true
                Title_1.Text = Title
                Title_1.TextColor3 = Color3.fromRGB(255, 255, 255)
                Title_1.TextSize = 14
                Title_1.TextTransparency = 0
                Title_1.TextXAlignment = Enum.TextXAlignment.Left
                Title_1.TextScaled = true
                Title_1.TextWrapped = true

                local TitleConstraint = Instance.new("UITextSizeConstraint")
                TitleConstraint.Parent = Title_1
                TitleConstraint.MaxTextSize = 14
                TitleConstraint.MinTextSize = 10

                UICorner_1.Parent = Togglez
                UICorner_1.CornerRadius = UDim.new(0, 12)

                ImageLabel_1.Parent = Togglez
                ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
                ImageLabel_1.BackgroundTransparency = 1
                ImageLabel_1.Position = UDim2.new(0.5, 0, 0.5, 0)
                ImageLabel_1.Size = UDim2.new(1, 50, 1, 0)
                ImageLabel_1.Image = "rbxassetid://72380279434385"
                ImageLabel_1.ImageTransparency = 0.9
                ImageLabel_1.ScaleType = Enum.ScaleType.Crop

                UIGradient_1.Parent = ImageLabel_1
                UIGradient_1.Color = ColorSequence.new {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
                }

                StatusText.Name = "StatusText"
                StatusText.Parent = Togglez
                StatusText.AnchorPoint = Vector2.new(1, 0.5)
                StatusText.BackgroundTransparency = 1
                StatusText.Position = UDim2.new(0.95, -38, 0.5, 0)
                StatusText.Size = UDim2.new(0, 60, 0, 20)
                StatusText.Font = Enum.Font.GothamBold
                StatusText.Text = ShowStatusText and
                (StatusTextType == "Idk" and (Value and "True" or "False") or tostring(Value)) or ""
                StatusText.TextColor3 = Value and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 100, 100)
                StatusText.TextSize = 12
                StatusText.TextTransparency = 0
                StatusText.TextXAlignment = Enum.TextXAlignment.Right
                StatusText.Visible = ShowStatusText

                Check_1.Name = "Check"
                Check_1.Parent = Togglez
                Check_1.AnchorPoint = Vector2.new(1, 0.5)
                Check_1.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                Check_1.BorderSizePixel = 0
                Check_1.Position = UDim2.new(0.95, 0, 0.5, 0)
                Check_1.Size = UDim2.new(0, 25, 0, 25)
                Check_1.ClipsDescendants = true

                ColorFrame_1.Name = "ColorFrame"
                ColorFrame_1.Parent = Check_1
                ColorFrame_1.AnchorPoint = Vector2.new(0.5, 0.5)
                ColorFrame_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ColorFrame_1.BorderSizePixel = 0
                ColorFrame_1.Position = UDim2.new(0.5, 0, 0.5, 0)
                ColorFrame_1.Size = UDim2.new(1, 0, 1, 0)
                ColorFrame_1.BackgroundTransparency = Value and 0 or 1

                UIGradient_2.Parent = ColorFrame_1
                UIGradient_2.Color = ColorSequence.new {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
                }
                UIGradient_2.Rotation = 48

                UICorner_2.Parent = ColorFrame_1
                UICorner_2.CornerRadius = UDim.new(0, 5)

                ImageLabel_2.Parent = ColorFrame_1
                ImageLabel_2.AnchorPoint = Vector2.new(0.5, 0.5)
                ImageLabel_2.BackgroundTransparency = 1
                ImageLabel_2.Position = UDim2.new(0.5, 0, 0.5, 0)
                ImageLabel_2.Size = Value and UDim2.new(0, 13, 0, 13) or UDim2.new(0, 0, 0, 0)
                ImageLabel_2.Image = "rbxassetid://86682186031062"
                ImageLabel_2.ScaleType = Enum.ScaleType.Crop

                UICorner_3.Parent = Check_1
                UICorner_3.CornerRadius = UDim.new(0, 5)

                Desc_1.Name = "Desc"
                Desc_1.Parent = Togglez
                Desc_1.AnchorPoint = Vector2.new(0, 0.5)
                Desc_1.BackgroundTransparency = 1
                Desc_1.Position = UDim2.new(0.03, 0, 0.68, 0)
                Desc_1.Size = UDim2.new(0.62, 0, 0, 15)
                Desc_1.Font = Enum.Font.Gotham
                Desc_1.RichText = true
                Desc_1.Text = Desc
                Desc_1.TextColor3 = Color3.fromRGB(200, 200, 200)
                Desc_1.TextSize = 11
                Desc_1.TextTransparency = 0.3
                Desc_1.TextXAlignment = Enum.TextXAlignment.Left
                Desc_1.TextScaled = true
                Desc_1.TextWrapped = true

                local DescConstraint = Instance.new("UITextSizeConstraint")
                DescConstraint.Parent = Desc_1
                DescConstraint.MaxTextSize = 11
                DescConstraint.MinTextSize = 8

                local function Toggle(val)
                    Value = val
                    if Value then
                        Callback(Value)

                        tw({ v = ColorFrame_1, t = 0.25, s = "Quad", d = "Out", g = { BackgroundTransparency = 0 } })
                            :Play()
                        tw({ v = ImageLabel_2, t = 0.15, s = "Back", d = "Out", g = { Size = UDim2.new(0, 18, 0, 18) } })
                            :Play()

                        delay(0.08, function()
                            tw({ v = ImageLabel_2, t = 0.2, s = "Back", d = "Out", g = { Size = UDim2.new(0, 13, 0, 13) } })
                                :Play()
                        end)

                        if ShowStatusText then
                            StatusText.Text = StatusTextType == "OnOff" and "ON" or "true"
                            tw({
                                v = StatusText,
                                t = 0.2,
                                s = "Quad",
                                d = "Out",
                                g = {
                                    TextColor3 = Color3.fromRGB(0, 255, 127)
                                }
                            }):Play()
                        end
                    else
                        Callback(Value)

                        tw({ v = ColorFrame_1, t = 0.25, s = "Quad", d = "Out", g = { BackgroundTransparency = 1 } })
                            :Play()
                        tw({ v = ImageLabel_2, t = 0.2, s = "Quad", d = "Out", g = { Size = UDim2.new(0, 0, 0, 0) } })
                            :Play()

                        if ShowStatusText then
                            StatusText.Text = StatusTextType == "OnOff" and "OFF" or "false"
                            tw({
                                v = StatusText,
                                t = 0.2,
                                s = "Quad",
                                d = "Out",
                                g = {
                                    TextColor3 = Color3.fromRGB(255, 100, 100)
                                }
                            }):Play()
                        end
                    end
                end

                ClickToggle.MouseButton1Click:Connect(function()
                    EffectClick2(ClickToggle, Togglez)
                    Toggle(not Value)
                end)

                table.insert(allElements, { Frame = Togglez, SearchName = Title, HighlightFrame = HighlightFrame })

                local Index = {}

                function Index:SetValue(v)
                    Toggle(v)
                end

                function Index:GetValue()
                    return Value
                end

                function Index:SetTitle(v)
                    Title_1.Text = v
                    for _, element in pairs(allElements) do
                        if element.Frame == Togglez then
                            element.SearchName = v
                            break
                        end
                    end
                end

                function Index:SetDesc(v)
                    Desc_1.Text = v
                end

                function Index:Visible(v)
                    Togglez.Visible = v
                end

                function Index:SetStatusTextType(type)
                    StatusTextType = type
                    if ShowStatusText then
                        StatusText.Text = type == "OnOff" and (Value and "ON" or "OFF") or tostring(Value)
                    end
                end

                function Index:ShowStatus(show)
                    ShowStatusText = show
                    StatusText.Visible = show
                end

                return Index
            end
        end

        function Cat.Elements:Discord(meta)
            local Link = meta.Link or "discord.gg/example"
            local Side = meta.Side or "l"

            elementCount = elementCount + 1
            BadgeLabel.Text = tostring(elementCount)

            local targetWidth = math.max(32, #tostring(elementCount) * 10 + 12)
            tw({ v = BadgeFrame, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0, targetWidth, 0, 18) } }):Play()

            local Discord = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local UIStroke = Instance.new("UIStroke")
            local ImageBg = Instance.new("ImageLabel")
            local DiscordGradient = Instance.new("UIGradient")
            local DiscordIcon = Instance.new("ImageLabel")
            local TitleLabel = Instance.new("TextLabel")
            local LinkLabel = Instance.new("TextLabel")
            local CopyIcon = Instance.new("ImageLabel")
            local HighlightFrame = Instance.new("Frame")
            local HighlightCorner = Instance.new("UICorner")
            local ClickDiscord = click(Discord)

            Discord.Name = "Discord"
            Discord.Parent = GetSide(Side)
            Discord.AnchorPoint = Vector2.new(0.5, 0.5)
            Discord.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Discord.BorderSizePixel = 0
            Discord.Size = UDim2.new(0.97, 0, 0, 65)
            Discord.ClipsDescendants = true

            UICorner.Parent = Discord
            UICorner.CornerRadius = UDim.new(0, 12)

            UIStroke.Parent = Discord
            UIStroke.Color = Color3.fromRGB(142, 130, 255)
            UIStroke.Thickness = 2
            UIStroke.Transparency = 0.6

            HighlightFrame.Name = "HighlightFrame"
            HighlightFrame.Parent = Discord
            HighlightFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HighlightFrame.BackgroundTransparency = 1
            HighlightFrame.Size = UDim2.new(1, 0, 1, 0)
            HighlightFrame.ZIndex = 2

            HighlightCorner.CornerRadius = UDim.new(0, 12)
            HighlightCorner.Parent = HighlightFrame

            DiscordGradient.Parent = Discord
            DiscordGradient.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(114, 137, 218))
            }
            DiscordGradient.Rotation = 45

            ImageBg.Parent = Discord
            ImageBg.AnchorPoint = Vector2.new(0.5, 0.5)
            ImageBg.BackgroundTransparency = 1
            ImageBg.Position = UDim2.new(0.5, 0, 0.5, 0)
            ImageBg.Size = UDim2.new(1, 50, 1, 0)
            ImageBg.Image = "rbxassetid://72380279434385"
            ImageBg.ImageTransparency = 0.85
            ImageBg.ScaleType = Enum.ScaleType.Crop

            DiscordIcon.Name = "Icon"
            DiscordIcon.Parent = Discord
            DiscordIcon.AnchorPoint = Vector2.new(0, 0.5)
            DiscordIcon.BackgroundTransparency = 1
            DiscordIcon.Position = UDim2.new(0, 12, 0.5, 0)
            DiscordIcon.Size = UDim2.new(0, 40, 0, 40)
            DiscordIcon.Image = "rbxassetid://94937742565147"
            DiscordIcon.ScaleType = Enum.ScaleType.Fit

            TitleLabel.Name = "Title"
            TitleLabel.Parent = Discord
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Position = UDim2.new(0, 60, 0, 12)
            TitleLabel.Size = UDim2.new(0.65, 0, 0, 18)
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.Text = "Discord Server"
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.TextSize = 15
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.TextScaled = true
            TitleLabel.TextWrapped = true

            local TitleConstraint = Instance.new("UITextSizeConstraint")
            TitleConstraint.Parent = TitleLabel
            TitleConstraint.MaxTextSize = 15
            TitleConstraint.MinTextSize = 11

            LinkLabel.Name = "Link"
            LinkLabel.Parent = Discord
            LinkLabel.BackgroundTransparency = 1
            LinkLabel.Position = UDim2.new(0, 60, 0, 35)
            LinkLabel.Size = UDim2.new(0.6, 0, 0, 16)
            LinkLabel.Font = Enum.Font.GothamBold
            LinkLabel.Text = Link
            LinkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            LinkLabel.TextSize = 12
            LinkLabel.TextTransparency = 0.3
            LinkLabel.TextXAlignment = Enum.TextXAlignment.Left
            LinkLabel.TextScaled = true
            LinkLabel.TextWrapped = true

            local LinkConstraint = Instance.new("UITextSizeConstraint")
            LinkConstraint.Parent = LinkLabel
            LinkConstraint.MaxTextSize = 12
            LinkConstraint.MinTextSize = 8

            CopyIcon.Name = "CopyIcon"
            CopyIcon.Parent = Discord
            CopyIcon.AnchorPoint = Vector2.new(1, 0.5)
            CopyIcon.BackgroundTransparency = 1
            CopyIcon.Position = UDim2.new(0.96, 0, 0.5, 0)
            CopyIcon.Size = UDim2.new(0, 24, 0, 24)
            CopyIcon.Image = "rbxassetid://7734053495"
            CopyIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            CopyIcon.ScaleType = Enum.ScaleType.Fit

            ClickDiscord.MouseEnter:Connect(function()
                tw({ v = Discord, t = 0.2, s = "Quad", d = "Out", g = { Size = UDim2.new(0.97, 0, 0, 70) } }):Play()
                tw({ v = UIStroke, t = 0.2, s = "Quad", d = "Out", g = { Transparency = 0.3 } }):Play()
                tw({ v = CopyIcon, t = 0.2, s = "Back", d = "Out", g = { Size = UDim2.new(0, 28, 0, 28) } }):Play()
            end)

            ClickDiscord.MouseLeave:Connect(function()
                tw({ v = Discord, t = 0.2, s = "Quad", d = "Out", g = { Size = UDim2.new(0.97, 0, 0, 65) } }):Play()
                tw({ v = UIStroke, t = 0.2, s = "Quad", d = "Out", g = { Transparency = 0.6 } }):Play()
                tw({ v = CopyIcon, t = 0.2, s = "Back", d = "Out", g = { Size = UDim2.new(0, 24, 0, 24) } }):Play()
            end)

            ClickDiscord.MouseButton1Click:Connect(function()
                pcall(setclipboard, Link)

                EffectClick2(ClickDiscord, Discord)

                tw({ v = DiscordIcon, t = 0.15, s = "Back", d = "Out", g = { Rotation = -15 } }):Play()
                task.wait(0.1)
                tw({ v = DiscordIcon, t = 0.15, s = "Bounce", d = "Out", g = { Rotation = 15 } }):Play()
                task.wait(0.1)
                tw({ v = DiscordIcon, t = 0.15, s = "Back", d = "Out", g = { Rotation = 0 } }):Play()

                tw({ v = CopyIcon, t = 0.2, s = "Bounce", d = "Out", g = { Size = UDim2.new(0, 32, 0, 32) } }):Play()
                task.wait(0.1)
                tw({ v = CopyIcon, t = 0.2, s = "Bounce", d = "Out", g = { Size = UDim2.new(0, 24, 0, 24) } }):Play()

                local SuccessLabel = Instance.new("TextLabel")
                SuccessLabel.Parent = Discord
                SuccessLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                SuccessLabel.BackgroundTransparency = 1
                SuccessLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                SuccessLabel.Size = UDim2.new(0, 0, 0, 20)
                SuccessLabel.Font = Enum.Font.GothamBold
                SuccessLabel.Text = ""
                SuccessLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
                SuccessLabel.TextSize = 14
                SuccessLabel.TextTransparency = 1
                SuccessLabel.ZIndex = 10

                tw({ v = SuccessLabel, t = 0.2, s = "Back", d = "Out", g = { TextTransparency = 0, Size = UDim2.new(0, 80, 0, 20) } })
                    :Play()
                task.wait(1.5)
                tw({ v = SuccessLabel, t = 0.3, s = "Quad", d = "Out", g = { TextTransparency = 1 } }):Play()
                task.wait(0.3)
                SuccessLabel:Destroy()
            end)

            table.insert(allElements, { Frame = Discord, SearchName = "Discord", HighlightFrame = HighlightFrame })

            local Index = {}

            function Index:SetLink(v)
                Link = v
                LinkLabel.Text = v
            end

            function Index:Visible(v)
                Discord.Visible = v
            end

            return Index
        end

        function Cat.Elements:ThumnailsImage(meta)
            local Banner = meta.Banner or ""
            local Title = meta.Title or ""
            local SizeY = meta.SizeY
            local Side = meta.Side or "l"
            local ShowTitle = meta.ShowTitle ~= false
            local AutoSize = SizeY == nil

            elementCount = elementCount + 1
            BadgeLabel.Text = tostring(elementCount)

            local targetWidth = math.max(32, #tostring(elementCount) * 10 + 12)
            tw({ v = BadgeFrame, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0, targetWidth, 0, 18) } }):Play()

            local defaultHeight = 120
            local finalHeight = SizeY or defaultHeight

            local ImageFrame = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local ImageLabel = Instance.new("ImageLabel")
            local ImageCorner = Instance.new("UICorner")
            local LoadingFrame = Instance.new("Frame")
            local LoadingCorner = Instance.new("UICorner")
            local LoadingBar = Instance.new("Frame")
            local BarCorner = Instance.new("UICorner")
            local BarGradient = Instance.new("UIGradient")
            local HighlightFrame = Instance.new("Frame")
            local HighlightCorner = Instance.new("UICorner")
            local ClickDetector = Instance.new("TextButton")
            local TitleLabel, TitleBackground, TitleCorner, TitleGradient

            ImageFrame.Name = "ImageFrame"
            ImageFrame.Parent = GetSide(Side)
            ImageFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            ImageFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            ImageFrame.BackgroundTransparency = 0.2
            ImageFrame.BorderSizePixel = 0
            ImageFrame.Size = UDim2.new(0.97, 0, 0, finalHeight)
            ImageFrame.ClipsDescendants = true

            UICorner.Parent = ImageFrame
            UICorner.CornerRadius = UDim.new(0, 12)

            HighlightFrame.Name = "HighlightFrame"
            HighlightFrame.Parent = ImageFrame
            HighlightFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HighlightFrame.BackgroundTransparency = 1
            HighlightFrame.Size = UDim2.new(1, 0, 1, 0)
            HighlightFrame.ZIndex = 2

            HighlightCorner.CornerRadius = UDim.new(0, 12)
            HighlightCorner.Parent = HighlightFrame

            ImageLabel.Name = "Image"
            ImageLabel.Parent = ImageFrame
            ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            ImageLabel.BackgroundTransparency = 1
            ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
            ImageLabel.Size = UDim2.new(1, 0, 1, 0)
            ImageLabel.Image = GetIcon(Banner)
            ImageLabel.ScaleType = Enum.ScaleType.Fit
            ImageLabel.ImageTransparency = 1

            ImageCorner.Parent = ImageLabel
            ImageCorner.CornerRadius = UDim.new(0, 12)

            ClickDetector.Name = "ClickDetector"
            ClickDetector.Parent = ImageFrame
            ClickDetector.BackgroundTransparency = 1
            ClickDetector.Size = UDim2.new(1, 0, 1, 0)
            ClickDetector.Text = ""
            ClickDetector.ZIndex = 3
            ClickDetector.AutoButtonColor = false

            if ShowTitle and Title ~= "" then
                TitleBackground = Instance.new("Frame")
                TitleBackground.Name = "TitleBackground"
                TitleBackground.Parent = ImageFrame
                TitleBackground.AnchorPoint = Vector2.new(0.5, 1)
                TitleBackground.Position = UDim2.new(0.5, 0, 1, 0)
                TitleBackground.Size = UDim2.new(1, 0, 0, 35)
                TitleBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                TitleBackground.BackgroundTransparency = 0.2
                TitleBackground.BorderSizePixel = 0
                TitleBackground.ZIndex = 2

                TitleCorner = Instance.new("UICorner")
                TitleCorner.Parent = TitleBackground
                TitleCorner.CornerRadius = UDim.new(0, 12)

                TitleGradient = Instance.new("UIGradient")
                TitleGradient.Parent = TitleBackground
                TitleGradient.Color = ColorSequence.new {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
                }
                TitleGradient.Rotation = 90
                TitleGradient.Transparency = NumberSequence.new {
                    NumberSequenceKeypoint.new(0, 0.3),
                    NumberSequenceKeypoint.new(1, 0)
                }

                TitleLabel = Instance.new("TextLabel")
                TitleLabel.Name = "Title"
                TitleLabel.Parent = TitleBackground
                TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
                TitleLabel.Size = UDim2.new(0.9, 0, 0.7, 0)
                TitleLabel.Font = Enum.Font.GothamBold
                TitleLabel.RichText = true
                TitleLabel.Text = Title
                TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                TitleLabel.TextSize = 13
                TitleLabel.TextTransparency = 0
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                TitleLabel.TextScaled = true
                TitleLabel.TextWrapped = true
                TitleLabel.ZIndex = 3

                local TitleConstraint = Instance.new("UITextSizeConstraint")
                TitleConstraint.Parent = TitleLabel
                TitleConstraint.MaxTextSize = 13
                TitleConstraint.MinTextSize = 9
            end

            LoadingFrame.Name = "Loading"
            LoadingFrame.Parent = ImageFrame
            LoadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            LoadingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            LoadingFrame.BackgroundTransparency = 0.3
            LoadingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            LoadingFrame.Size = UDim2.new(0.7, 0, 0, 4)

            LoadingCorner.Parent = LoadingFrame
            LoadingCorner.CornerRadius = UDim.new(1, 0)

            LoadingBar.Name = "Bar"
            LoadingBar.Parent = LoadingFrame
            LoadingBar.AnchorPoint = Vector2.new(0, 0.5)
            LoadingBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            LoadingBar.Position = UDim2.new(0, 0, 0.5, 0)
            LoadingBar.Size = UDim2.new(0, 0, 1, 0)

            BarCorner.Parent = LoadingBar
            BarCorner.CornerRadius = UDim.new(1, 0)

            BarGradient.Parent = LoadingBar
            BarGradient.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
            }

            local function CreateFullscreCatiewer()
                local ScreenGui = Instance.new("ScreenGui")
                local Overlay = Instance.new("Frame")
                local OverlayButton = Instance.new("TextButton")
                local FullImage = Instance.new("ImageLabel")
                local FullImageCorner = Instance.new("UICorner")
                local InfoLabel = Instance.new("TextLabel")
                local ImageSizeLabel = Instance.new("TextLabel")

                ScreenGui.Name = "FullscreenImageViewer"
                ScreenGui.Parent = game:GetService("CoreGui")
                ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                ScreenGui.DisplayOrder = 999999

                Overlay.Name = "Overlay"
                Overlay.Parent = ScreenGui
                Overlay.BackgroundTransparency = 1
                Overlay.Size = UDim2.new(1, 0, 1, 0)

                OverlayButton.Name = "OverlayButton"
                OverlayButton.Parent = Overlay
                OverlayButton.BackgroundTransparency = 1
                OverlayButton.Size = UDim2.new(1, 0, 1, 0)
                OverlayButton.Text = ""
                OverlayButton.AutoButtonColor = false

                FullImage.Name = "FullImage"
                FullImage.Parent = Overlay
                FullImage.AnchorPoint = Vector2.new(0.5, 0.5)
                FullImage.BackgroundTransparency = 1
                FullImage.Position = UDim2.new(0.5, 0, 0.5, 0)
                FullImage.Size = UDim2.new(0, 0, 0, 0)
                FullImage.Image = ImageLabel.Image
                FullImage.ScaleType = Enum.ScaleType.Fit
                FullImage.ImageTransparency = 1
                FullImage.ZIndex = 2

                FullImageCorner.Parent = FullImage
                FullImageCorner.CornerRadius = UDim.new(0, 20)

                InfoLabel.Name = "InfoLabel"
                InfoLabel.Parent = Overlay
                InfoLabel.AnchorPoint = Vector2.new(0.5, 1)
                InfoLabel.BackgroundTransparency = 1
                InfoLabel.Position = UDim2.new(0.5, 0, 1, -20)
                InfoLabel.Size = UDim2.new(0, 250, 0, 30)
                InfoLabel.Font = Enum.Font.GothamBold
                InfoLabel.Text = "Click to close"
                InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                InfoLabel.TextSize = 16
                InfoLabel.TextTransparency = 1
                InfoLabel.ZIndex = 3

                ImageSizeLabel.Name = "ImageSizeLabel"
                ImageSizeLabel.Parent = Overlay
                ImageSizeLabel.AnchorPoint = Vector2.new(0.5, 0)
                ImageSizeLabel.BackgroundTransparency = 1
                ImageSizeLabel.Position = UDim2.new(0.5, 0, 0, 20)
                ImageSizeLabel.Size = UDim2.new(0, 250, 0, 30)
                ImageSizeLabel.Font = Enum.Font.GothamBold
                ImageSizeLabel.Text = ""
                ImageSizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                ImageSizeLabel.TextSize = 15
                ImageSizeLabel.TextTransparency = 1
                ImageSizeLabel.ZIndex = 3

                local ContentProvider = game:GetService("ContentProvider")

                task.spawn(function()
                    pcall(function()
                        ContentProvider:PreloadAsync({ ImageLabel.Image })
                    end)
                end)

                local viewportWidth = Overlay.AbsoluteSize.X
                local viewportHeight = Overlay.AbsoluteSize.Y

                local maxWidth = viewportWidth * 0.9
                local maxHeight = viewportHeight * 0.85

                tw({
                    v = FullImage,
                    t = 0.4,
                    s = "Back",
                    d = "Out",
                    g = {
                        Size = UDim2.new(0, maxWidth, 0, maxHeight),
                        ImageTransparency = 0
                    }
                }):Play()
                tw({ v = InfoLabel, t = 0.3, s = "Quad", d = "Out", g = { TextTransparency = 0.2 } }):Play()

                task.wait(0.1)
                local actualWidth = FullImage.AbsoluteSize.X
                local actualHeight = FullImage.AbsoluteSize.Y
                if actualWidth > 0 and actualHeight > 0 then
                    ImageSizeLabel.Text = string.format("%d × %d", math.floor(actualWidth), math.floor(actualHeight))
                    tw({ v = ImageSizeLabel, t = 0.3, s = "Quad", d = "Out", g = { TextTransparency = 0.4 } }):Play()
                end

                local function CloseViewer()
                    tw({
                        v = FullImage,
                        t = 0.3,
                        s = "Back",
                        d = "In",
                        g = {
                            ImageTransparency = 1,
                            Size = UDim2.new(0, 0, 0, 0)
                        }
                    }):Play()
                    tw({ v = InfoLabel, t = 0.2, s = "Quad", d = "Out", g = { TextTransparency = 1 } }):Play()
                    tw({ v = ImageSizeLabel, t = 0.2, s = "Quad", d = "Out", g = { TextTransparency = 1 } }):Play()

                    task.wait(0.3)
                    ScreenGui:Destroy()
                end

                OverlayButton.MouseButton1Click:Connect(CloseViewer)

                local UserInputService = game:GetService("UserInputService")
                local escConnection
                escConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if input.KeyCode == Enum.KeyCode.Escape and not gameProcessed then
                        CloseViewer()
                        if escConnection then
                            escConnection:Disconnect()
                        end
                    end
                end)
            end

            if AutoSize then
                task.spawn(function()
                    task.wait(0.1)
                    local parentSize = GetSide(Side).AbsoluteSize
                    local containerWidth = parentSize.X * 0.97

                    local estimatedHeight = containerWidth * 0.6
                    finalHeight = math.clamp(estimatedHeight, 100, 300)

                    ImageFrame.Size = UDim2.new(0.97, 0, 0, finalHeight)
                end)
            end

            task.spawn(function()
                for i = 0, 100, 4 do
                    tw({ v = LoadingBar, t = 0.08, s = "Linear", d = "Out", g = { Size = UDim2.new(i / 100, 0, 1, 0) } })
                        :Play()
                    task.wait(0.04)
                end

                tw({ v = ImageLabel, t = 0.5, s = "Quad", d = "Out", g = { ImageTransparency = 0 } }):Play()
                tw({ v = LoadingFrame, t = 0.3, s = "Quad", d = "Out", g = { BackgroundTransparency = 1 } }):Play()
                tw({ v = LoadingBar, t = 0.3, s = "Quad", d = "Out", g = { BackgroundTransparency = 1 } }):Play()

                task.wait(0.3)
                LoadingFrame:Destroy()
            end)

            ClickDetector.MouseEnter:Connect(function()
                tw({
                    v = ImageFrame,
                    t = 0.2,
                    s = "Quad",
                    d = "Out",
                    g = {
                        BackgroundTransparency = 0.1
                    }
                }):Play()
                tw({
                    v = ImageLabel,
                    t = 0.2,
                    s = "Quad",
                    d = "Out",
                    g = {
                        Size = UDim2.new(1.03, 0, 1.03, 0)
                    }
                }):Play()
            end)

            ClickDetector.MouseLeave:Connect(function()
                tw({
                    v = ImageFrame,
                    t = 0.2,
                    s = "Quad",
                    d = "Out",
                    g = {
                        BackgroundTransparency = 0.2
                    }
                }):Play()
                tw({
                    v = ImageLabel,
                    t = 0.2,
                    s = "Quad",
                    d = "Out",
                    g = {
                        Size = UDim2.new(1, 0, 1, 0)
                    }
                }):Play()
            end)

            ClickDetector.MouseButton1Click:Connect(function()
                local ripple = Instance.new("Frame")
                local rippleCorner = Instance.new("UICorner")

                ripple.Name = "Ripple"
                ripple.Parent = ImageFrame
                ripple.AnchorPoint = Vector2.new(0.5, 0.5)
                ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
                ripple.Size = UDim2.new(0, 0, 0, 0)
                ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ripple.BackgroundTransparency = 0.5
                ripple.ZIndex = 5

                rippleCorner.Parent = ripple
                rippleCorner.CornerRadius = UDim.new(1, 0)

                tw({
                    v = ripple,
                    t = 0.6,
                    s = "Quad",
                    d = "Out",
                    g = {
                        Size = UDim2.new(2.5, 0, 2.5, 0),
                        BackgroundTransparency = 1
                    }
                }):Play()

                task.wait(0.6)
                ripple:Destroy()

                CreateFullscreCatiewer()
            end)

            table.insert(allElements,
                { Frame = ImageFrame, SearchName = Title ~= "" and Title or "Image", HighlightFrame = HighlightFrame })

            local Index = {}

            function Index:SetImage(v)
                ImageLabel.ImageTransparency = 1
                ImageLabel.Image = GetIcon(v)
                tw({ v = ImageLabel, t = 0.5, s = "Quad", d = "Out", g = { ImageTransparency = 0 } }):Play()
            end

            function Index:SetHeight(v)
                finalHeight = v
                tw({ v = ImageFrame, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0.97, 0, 0, v) } }):Play()
            end

            function Index:SetTitle(v)
                if TitleLabel then
                    TitleLabel.Text = v
                    for _, element in pairs(allElements) do
                        if element.Frame == ImageFrame then
                            element.SearchName = v
                            break
                        end
                    end
                end
            end

            function Index:Visible(v)
                ImageFrame.Visible = v
            end

            return Index
        end

        function Cat.Elements:Keybind(meta)
            local Title = meta.Title or "Keybind"
            local Desc = meta.Desc or ""
            local Key = meta.Key or Enum.KeyCode.Q
            local Value = meta.Value or false
            local Side = meta.Side or "l"
            local Callback = meta.Callback or function() end
            local Mode = meta.Mode or "Toggle"

            elementCount = elementCount + 1
            BadgeLabel.Text = tostring(elementCount)

            local targetWidth = math.max(32, #tostring(elementCount) * 10 + 12)
            tw({ v = BadgeFrame, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0, targetWidth, 0, 18) } }):Play()

            local Keybind = Instance.new("Frame")
            local UICorner_1 = Instance.new("UICorner")
            local ImageLabel_1 = Instance.new("ImageLabel")
            local UIGradient_1 = Instance.new("UIGradient")
            local TitleLabel = Instance.new("TextLabel")
            local DescLabel = Instance.new("TextLabel")
            local StatusText = Instance.new("TextLabel")
            local KeyDisplay = Instance.new("Frame")
            local KeyCorner = Instance.new("UICorner")
            local KeyGradient = Instance.new("UIGradient")
            local KeyText = Instance.new("TextLabel")
            local KeyIcon = Instance.new("ImageLabel")
            local ModeButton = Instance.new("TextButton")
            local ModeCorner = Instance.new("UICorner")
            local ModeText = Instance.new("TextLabel")
            local HighlightFrame = Instance.new("Frame")
            local HighlightCorner = Instance.new("UICorner")
            local ClickChange = click(Keybind)

            Keybind.Name = "Keybind"
            Keybind.Parent = GetSide(Side)
            Keybind.AnchorPoint = Vector2.new(0.5, 0.5)
            Keybind.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            Keybind.BackgroundTransparency = 0.2
            Keybind.BorderSizePixel = 0
            Keybind.Size = UDim2.new(0.97, 0, 0, Desc ~= "" and 70 or 55)
            Keybind.ClipsDescendants = true

            UICorner_1.Parent = Keybind
            UICorner_1.CornerRadius = UDim.new(0, 12)

            HighlightFrame.Name = "HighlightFrame"
            HighlightFrame.Parent = Keybind
            HighlightFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HighlightFrame.BackgroundTransparency = 1
            HighlightFrame.Size = UDim2.new(1, 0, 1, 0)
            HighlightFrame.ZIndex = 2

            HighlightCorner.CornerRadius = UDim.new(0, 12)
            HighlightCorner.Parent = HighlightFrame

            ImageLabel_1.Parent = Keybind
            ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
            ImageLabel_1.BackgroundTransparency = 1
            ImageLabel_1.Position = UDim2.new(0.5, 0, 0.5, 0)
            ImageLabel_1.Size = UDim2.new(1, 50, 1, 0)
            ImageLabel_1.Image = "rbxassetid://72380279434385"
            ImageLabel_1.ImageTransparency = 0.9
            ImageLabel_1.ScaleType = Enum.ScaleType.Crop

            UIGradient_1.Parent = ImageLabel_1
            UIGradient_1.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
            }

            TitleLabel.Name = "Title"
            TitleLabel.Parent = Keybind
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Position = UDim2.new(0.04, 0, 0, 10)
            TitleLabel.Size = UDim2.new(0.5, 0, 0, 18)
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.Text = Title
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.TextSize = 14
            TitleLabel.TextTransparency = 0
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.TextScaled = true
            TitleLabel.TextWrapped = true

            local TitleConstraint = Instance.new("UITextSizeConstraint")
            TitleConstraint.Parent = TitleLabel
            TitleConstraint.MaxTextSize = 14
            TitleConstraint.MinTextSize = 10

            StatusText.Name = "StatusText"
            StatusText.Parent = Keybind
            StatusText.AnchorPoint = Vector2.new(0, 0.5)
            StatusText.BackgroundTransparency = 1
            StatusText.Position = UDim2.new(0.04, 0, 0, 32)
            StatusText.Size = UDim2.new(0.5, 0, 0, 14)
            StatusText.Font = Enum.Font.GothamBold
            StatusText.Text = Value and "On" or "Off"
            StatusText.TextColor3 = Value and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 100, 100)
            StatusText.TextSize = 11
            StatusText.TextTransparency = 0
            StatusText.TextXAlignment = Enum.TextXAlignment.Left

            if Desc ~= "" then
                DescLabel.Name = "Desc"
                DescLabel.Parent = Keybind
                DescLabel.BackgroundTransparency = 1
                DescLabel.Position = UDim2.new(0.04, 0, 1, -20)
                DescLabel.Size = UDim2.new(0.92, 0, 0, 14)
                DescLabel.Font = Enum.Font.Gotham
                DescLabel.Text = Desc
                DescLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                DescLabel.TextSize = 12
                DescLabel.TextTransparency = 0.3
                DescLabel.TextXAlignment = Enum.TextXAlignment.Left
                DescLabel.TextScaled = true
                DescLabel.TextWrapped = true

                local DescConstraint = Instance.new("UITextSizeConstraint")
                DescConstraint.Parent = DescLabel
                DescConstraint.MaxTextSize = 12
                DescConstraint.MinTextSize = 9
            end

            ModeButton.Name = "ModeButton"
            ModeButton.Parent = Keybind
            ModeButton.AnchorPoint = Vector2.new(1, 0)
            ModeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            ModeButton.BackgroundTransparency = 0.3
            ModeButton.Position = UDim2.new(0.96, 0, 0, 8)
            ModeButton.Size = UDim2.new(0, 70, 0, 20)
            ModeButton.Text = ""
            ModeButton.AutoButtonColor = false

            ModeCorner.Parent = ModeButton
            ModeCorner.CornerRadius = UDim.new(0, 6)

            ModeText.Name = "ModeText"
            ModeText.Parent = ModeButton
            ModeText.AnchorPoint = Vector2.new(0.5, 0.5)
            ModeText.BackgroundTransparency = 1
            ModeText.Position = UDim2.new(0.5, 0, 0.5, 0)
            ModeText.Size = UDim2.new(0.9, 0, 0.8, 0)
            ModeText.Font = Enum.Font.GothamBold
            ModeText.Text = Mode
            ModeText.TextColor3 = Color3.fromRGB(200, 200, 220)
            ModeText.TextSize = 10
            ModeText.TextScaled = true

            local ModeConstraint = Instance.new("UITextSizeConstraint")
            ModeConstraint.Parent = ModeText
            ModeConstraint.MaxTextSize = 10
            ModeConstraint.MinTextSize = 7

            KeyDisplay.Name = "KeyDisplay"
            KeyDisplay.Parent = Keybind
            KeyDisplay.AnchorPoint = Vector2.new(1, 0)
            KeyDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            KeyDisplay.BackgroundTransparency = 0.85
            KeyDisplay.Position = UDim2.new(0.96, 0, 0, 32)
            KeyDisplay.Size = UDim2.new(0, 55, 0, 28)

            KeyCorner.Parent = KeyDisplay
            KeyCorner.CornerRadius = UDim.new(0, 8)

            KeyGradient.Parent = KeyDisplay
            KeyGradient.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
            }
            KeyGradient.Rotation = 45

            KeyIcon.Name = "KeyIcon"
            KeyIcon.Parent = KeyDisplay
            KeyIcon.AnchorPoint = Vector2.new(0, 0.5)
            KeyIcon.BackgroundTransparency = 1
            KeyIcon.Position = UDim2.new(0.08, 0, 0.5, 0)
            KeyIcon.Size = UDim2.new(0, 14, 0, 14)
            KeyIcon.Image = "rbxassetid://10723407389"
            KeyIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            KeyIcon.ImageTransparency = 0

            KeyText.Name = "KeyText"
            KeyText.Parent = KeyDisplay
            KeyText.AnchorPoint = Vector2.new(0.5, 0.5)
            KeyText.BackgroundTransparency = 1
            KeyText.Position = UDim2.new(0.6, 0, 0.5, 0)
            KeyText.Size = UDim2.new(0.65, 0, 0.7, 0)
            KeyText.Font = Enum.Font.GothamBold
            KeyText.Text = tostring(Key):gsub("Enum.KeyCode.", "")
            KeyText.TextColor3 = Color3.fromRGB(255, 255, 255)
            KeyText.TextSize = 13
            KeyText.TextScaled = true

            local KeyConstraint = Instance.new("UITextSizeConstraint")
            KeyConstraint.Parent = KeyText
            KeyConstraint.MaxTextSize = 13
            KeyConstraint.MinTextSize = 8

            local function adjustKeyDisplaySize()
                local textSize = game:GetService("TextService"):GetTextSize(
                    KeyText.Text,
                    13,
                    KeyText.Font,
                    Vector2.new(1000, 1000)
                )
                KeyDisplay.Size = UDim2.new(0, math.max(textSize.X + 28, 45), 0, 28)
            end

            adjustKeyDisplaySize()

            local listening = false

            local function changeKey()
                if listening then return end
                listening = true

                KeyText.Text = "..."
                KeyIcon.ImageTransparency = 0.5
                adjustKeyDisplaySize()

                tw({
                    v = KeyDisplay,
                    t = 0.2,
                    s = "Back",
                    d = "Out",
                    g = {
                        BackgroundTransparency = 0.7,
                        Size = UDim2.new(0, KeyDisplay.Size.X.Offset + 5, 0, 31)
                    }
                }):Play()

                local inputConnection
                inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        Key = input.KeyCode
                        KeyText.Text = tostring(Key):gsub("Enum.KeyCode.", "")
                        KeyIcon.ImageTransparency = 0
                        adjustKeyDisplaySize()

                        tw({
                            v = KeyDisplay,
                            t = 0.2,
                            s = "Back",
                            d = "Out",
                            g = {
                                BackgroundTransparency = 0.85,
                                Size = UDim2.new(0, KeyDisplay.Size.X.Offset, 0, 28)
                            }
                        }):Play()

                        inputConnection:Disconnect()
                        listening = false
                        pcall(Callback, Key, Value, Mode)
                    end
                end)
            end

            local function updateStatus(active)
                Value = active
                StatusText.Text = Value and "On" or "Off"

                tw({
                    v = StatusText,
                    t = 0.2,
                    s = "Quad",
                    d = "Out",
                    g = {
                        TextColor3 = Value and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 100, 100)
                    }
                }):Play()

                if Value then
                    tw({
                        v = KeyDisplay,
                        t = 0.15,
                        s = "Back",
                        d = "Out",
                        g = {
                            BackgroundTransparency = 0.75
                        }
                    }):Play()
                    tw({
                        v = KeyIcon,
                        t = 0.15,
                        s = "Back",
                        d = "Out",
                        g = {
                            Size = UDim2.new(0, 16, 0, 16)
                        }
                    }):Play()
                    task.wait(0.08)
                    tw({
                        v = KeyIcon,
                        t = 0.15,
                        s = "Back",
                        d = "Out",
                        g = {
                            Size = UDim2.new(0, 14, 0, 14)
                        }
                    }):Play()
                else
                    tw({
                        v = KeyDisplay,
                        t = 0.2,
                        s = "Quad",
                        d = "Out",
                        g = {
                            BackgroundTransparency = 0.85
                        }
                    }):Play()
                end
            end

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == Key and not listening then
                    if Mode == "Toggle" then
                        updateStatus(not Value)
                        pcall(Callback, Key, Value, Mode)
                    elseif Mode == "Hold" then
                        updateStatus(true)
                        pcall(Callback, Key, true, Mode)
                    end
                end
            end)

            if Mode == "Hold" then
                UserInputService.InputEnded:Connect(function(input, gameProcessed)
                    if input.KeyCode == Key and not listening then
                        updateStatus(false)
                        pcall(Callback, Key, false, Mode)
                    end
                end)
            end

            ModeButton.MouseButton1Click:Connect(function()
                Mode = Mode == "Toggle" and "Hold" or "Toggle"
                ModeText.Text = Mode

                tw({
                    v = ModeButton,
                    t = 0.2,
                    s = "Back",
                    d = "Out",
                    g = {
                        BackgroundTransparency = 0.1
                    }
                }):Play()
                task.wait(0.1)
                tw({
                    v = ModeButton,
                    t = 0.2,
                    s = "Back",
                    d = "Out",
                    g = {
                        BackgroundTransparency = 0.3
                    }
                }):Play()

                pcall(Callback, Key, Value, Mode)
            end)

            ModeButton.MouseEnter:Connect(function()
                tw({
                    v = ModeButton,
                    t = 0.15,
                    s = "Quad",
                    d = "Out",
                    g = {
                        BackgroundTransparency = 0.2
                    }
                }):Play()
            end)

            ModeButton.MouseLeave:Connect(function()
                tw({
                    v = ModeButton,
                    t = 0.15,
                    s = "Quad",
                    d = "Out",
                    g = {
                        BackgroundTransparency = 0.3
                    }
                }):Play()
            end)

            ClickChange.MouseButton1Click:Connect(function()
                EffectClick2(ClickChange, Keybind)
                changeKey()
            end)

            local Index = {}

            function Index:SetKey(k)
                Key = k
                KeyText.Text = tostring(Key):gsub("Enum.KeyCode.", "")
                adjustKeyDisplaySize()
            end

            function Index:GetKey()
                return Key
            end

            function Index:SetValue(v)
                updateStatus(v)
            end

            function Index:GetValue()
                return Value
            end

            function Index:SetMode(m)
                Mode = m
                ModeText.Text = Mode
            end

            function Index:GetMode()
                return Mode
            end

            function Index:SetTitle(v)
                TitleLabel.Text = v
            end

            function Index:SetDesc(v)
                if DescLabel then
                    DescLabel.Text = v
                end
            end

            function Index:Visible(v)
                Keybind.Visible = v
            end

            return Index
        end

        function Cat.Elements:Textbox(meta)
            local Title = meta.Title or "My Textbox"
            local Desc = meta.Desc or "Description"
            local Value = meta.Value or ""
            local PlaceHolder = meta.PlaceHolder or "Enter text here..."
            local ClearOnFocus = meta.ClearOnFocus or true
            local Side = meta.Side or "l"
            local Callback = meta.Callback or function() end

            elementCount = elementCount + 1
            BadgeLabel.Text = tostring(elementCount)

            local targetWidth = math.max(32, #tostring(elementCount) * 10 + 12)
            tw({ v = BadgeFrame, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0, targetWidth, 0, 18) } }):Play()

            local Textbox = Instance.new("Frame")
            local UICorner_1 = Instance.new("UICorner")
            local UIStroke_1 = Instance.new("UIStroke")
            local ImageLabel_1 = Instance.new("ImageLabel")
            local UIGradient_1 = Instance.new("UIGradient")
            local TitleLabel = Instance.new("TextLabel")
            local DescLabel = Instance.new("TextLabel")
            local InputFrame = Instance.new("Frame")
            local InputCorner = Instance.new("UICorner")
            local InputStroke = Instance.new("UIStroke")
            local InputGradient = Instance.new("UIGradient")
            local Edit_1 = Instance.new("TextBox")
            local FocusGlow = Instance.new("ImageLabel")
            local HighlightFrame = Instance.new("Frame")
            local HighlightCorner = Instance.new("UICorner")

            Textbox.Name = "Textbox"
            Textbox.Parent = GetSide(Side)
            Textbox.AnchorPoint = Vector2.new(0.5, 0.5)
            Textbox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            Textbox.BackgroundTransparency = 0.35
            Textbox.BorderSizePixel = 0
            Textbox.Size = UDim2.new(0.97, 0, 0, Desc ~= "" and 85 or 60)
            Textbox.ClipsDescendants = true

            UICorner_1.Parent = Textbox
            UICorner_1.CornerRadius = UDim.new(0, 12)

            UIStroke_1.Parent = Textbox
            UIStroke_1.Color = Color3.fromRGB(110, 110, 140)
            UIStroke_1.Thickness = 2
            UIStroke_1.Transparency = 0.75

            HighlightFrame.Name = "HighlightFrame"
            HighlightFrame.Parent = Textbox
            HighlightFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HighlightFrame.BackgroundTransparency = 1
            HighlightFrame.Size = UDim2.new(1, 0, 1, 0)
            HighlightFrame.ZIndex = 2

            HighlightCorner.CornerRadius = UDim.new(0, 12)
            HighlightCorner.Parent = HighlightFrame

            ImageLabel_1.Parent = Textbox
            ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
            ImageLabel_1.BackgroundTransparency = 1
            ImageLabel_1.Position = UDim2.new(0.5, 0, 0.5, 0)
            ImageLabel_1.Size = UDim2.new(1, 50, 1, 0)
            ImageLabel_1.Image = "rbxassetid://72380279434385"
            ImageLabel_1.ImageTransparency = 0.85
            ImageLabel_1.ScaleType = Enum.ScaleType.Crop

            UIGradient_1.Parent = ImageLabel_1
            UIGradient_1.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
            }

            TitleLabel.Name = "Title"
            TitleLabel.Parent = Textbox
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Position = UDim2.new(0.04, 0, 0, 8)
            TitleLabel.Size = UDim2.new(0.92, 0, 0, 18)
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.Text = Title
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.TextSize = 14
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.TextScaled = true
            TitleLabel.TextWrapped = true

            local TitleConstraint = Instance.new("UITextSizeConstraint")
            TitleConstraint.Parent = TitleLabel
            TitleConstraint.MaxTextSize = 14
            TitleConstraint.MinTextSize = 10

            if Desc ~= "" then
                DescLabel.Name = "Desc"
                DescLabel.Parent = Textbox
                DescLabel.BackgroundTransparency = 1
                DescLabel.Position = UDim2.new(0.04, 0, 0, 28)
                DescLabel.Size = UDim2.new(0.92, 0, 0, 14)
                DescLabel.Font = Enum.Font.Gotham
                DescLabel.Text = Desc
                DescLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
                DescLabel.TextSize = 11
                DescLabel.TextTransparency = 0.4
                DescLabel.TextXAlignment = Enum.TextXAlignment.Left
                DescLabel.TextScaled = true
                DescLabel.TextWrapped = true

                local DescConstraint = Instance.new("UITextSizeConstraint")
                DescConstraint.Parent = DescLabel
                DescConstraint.MaxTextSize = 11
                DescConstraint.MinTextSize = 8
            end

            InputFrame.Name = "InputFrame"
            InputFrame.Parent = Textbox
            InputFrame.AnchorPoint = Vector2.new(0.5, 1)
            InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            InputFrame.BackgroundTransparency = 0.92
            InputFrame.Position = UDim2.new(0.5, 0, 1, -8)
            InputFrame.Size = UDim2.new(0.92, 0, 0, 32)

            InputCorner.Parent = InputFrame
            InputCorner.CornerRadius = UDim.new(0, 8)

            InputStroke.Parent = InputFrame
            InputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            InputStroke.Color = Color3.fromRGB(255, 255, 255)
            InputStroke.Thickness = 1.5
            InputStroke.Transparency = 0.7

            InputGradient.Parent = InputStroke
            InputGradient.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
            }

            FocusGlow.Name = "FocusGlow"
            FocusGlow.Parent = InputFrame
            FocusGlow.AnchorPoint = Vector2.new(0.5, 0.5)
            FocusGlow.BackgroundTransparency = 1
            FocusGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
            FocusGlow.Size = UDim2.new(1, 40, 1, 40)
            FocusGlow.Image = "rbxassetid://8992230677"
            FocusGlow.ImageColor3 = Color3.fromRGB(0, 170, 255)
            FocusGlow.ImageTransparency = 1
            FocusGlow.ScaleType = Enum.ScaleType.Slice
            FocusGlow.SliceCenter = Rect.new(99, 99, 99, 99)
            FocusGlow.ZIndex = 0

            Edit_1.Name = "Edit"
            Edit_1.Parent = InputFrame
            Edit_1.Active = true
            Edit_1.AnchorPoint = Vector2.new(0.5, 0.5)
            Edit_1.BackgroundTransparency = 1
            Edit_1.Position = UDim2.new(0.5, 0, 0.5, 0)
            Edit_1.Size = UDim2.new(0.92, 0, 0.8, 0)
            Edit_1.Font = Enum.Font.GothamBold
            Edit_1.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
            Edit_1.PlaceholderText = PlaceHolder
            Edit_1.Text = Value
            Edit_1.TextColor3 = Color3.fromRGB(255, 255, 255)
            Edit_1.TextSize = 13
            Edit_1.ClearTextOnFocus = ClearOnFocus
            Edit_1.TextScaled = true
            Edit_1.TextWrapped = true

            local EditConstraint = Instance.new("UITextSizeConstraint")
            EditConstraint.Parent = Edit_1
            EditConstraint.MaxTextSize = 13
            EditConstraint.MinTextSize = 9

            Edit_1.Focused:Connect(function()
                tw({ v = InputStroke, t = 0.3, s = "Quad", d = "Out", g = { Transparency = 0.2 } }):Play()
                tw({ v = InputFrame, t = 0.3, s = "Quad", d = "Out", g = { BackgroundTransparency = 0.85 } }):Play()
                tw({ v = FocusGlow, t = 0.3, s = "Quad", d = "Out", g = { ImageTransparency = 0.85 } }):Play()
                tw({ v = UIStroke_1, t = 0.3, s = "Quad", d = "Out", g = { Transparency = 0.4 } }):Play()
            end)

            Edit_1.FocusLost:Connect(function(enterPressed)
                tw({ v = InputStroke, t = 0.3, s = "Quad", d = "Out", g = { Transparency = 0.7 } }):Play()
                tw({ v = InputFrame, t = 0.3, s = "Quad", d = "Out", g = { BackgroundTransparency = 0.92 } }):Play()
                tw({ v = FocusGlow, t = 0.3, s = "Quad", d = "Out", g = { ImageTransparency = 1 } }):Play()
                tw({ v = UIStroke_1, t = 0.3, s = "Quad", d = "Out", g = { Transparency = 0.75 } }):Play()

                if enterPressed and #Edit_1.Text > 0 then
                    Value = Edit_1.Text
                    pcall(Callback, Value)
                end
            end)

            table.insert(allElements, { Frame = Textbox, SearchName = Title, HighlightFrame = HighlightFrame })

            local Index = {}

            function Index:SetValue(v)
                Value = v
                Edit_1.Text = v
            end

            function Index:GetValue()
                return Edit_1.Text
            end

            function Index:SetTitle(v)
                TitleLabel.Text = v
                for _, element in pairs(allElements) do
                    if element.Frame == Textbox then
                        element.SearchName = v
                        break
                    end
                end
            end

            function Index:SetDesc(v)
                if DescLabel then
                    DescLabel.Text = v
                end
            end

            function Index:Visible(v)
                Textbox.Visible = v
            end

            return Index
        end

        function Cat.Elements:Slider(meta)
            local Title = meta.Title or "Slider"
            local Desc = meta.Desc or ""
            local Min = meta.Min or 0
            local Max = meta.Max or 100
            local Rounding = meta.Rounding or 0
            local Value = meta.Value or Min
            local Side = meta.Side or "l"
            local Callback = meta.Callback or function() end

            elementCount = elementCount + 1
            BadgeLabel.Text = tostring(elementCount)

            local targetWidth = math.max(32, #tostring(elementCount) * 10 + 12)
            tw({ v = BadgeFrame, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0, targetWidth, 0, 18) } }):Play()

            local Slider = Instance.new("Frame")
            local UICorner_1 = Instance.new("UICorner")
            local UIStroke_1 = Instance.new("UIStroke")
            local ImageLabel_1 = Instance.new("ImageLabel")
            local UIGradient_1 = Instance.new("UIGradient")
            local TitleLabel = Instance.new("TextLabel")
            local DescLabel = Instance.new("TextLabel")
            local ValueDisplay = Instance.new("Frame")
            local ValueCorner = Instance.new("UICorner")
            local ValueGradient = Instance.new("UIGradient")
            local ValueText = Instance.new("TextLabel")
            local SliderBar = Instance.new("Frame")
            local BarCorner = Instance.new("UICorner")
            local BarFill = Instance.new("Frame")
            local FillCorner = Instance.new("UICorner")
            local FillGradient = Instance.new("UIGradient")
            local SliderCircle = Instance.new("Frame")
            local CircleCorner = Instance.new("UICorner")
            local CircleGradient = Instance.new("UIGradient")
            local HighlightFrame = Instance.new("Frame")
            local HighlightCorner = Instance.new("UICorner")
            local Slide = click(SliderBar)

            Slider.Name = "Slider"
            Slider.Parent = GetSide(Side)
            Slider.AnchorPoint = Vector2.new(0.5, 0.5)
            Slider.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            Slider.BackgroundTransparency = 0.35
            Slider.BorderSizePixel = 0
            Slider.Size = UDim2.new(0.97, 0, 0, Desc ~= "" and 75 or 65)
            Slider.ClipsDescendants = true

            UICorner_1.Parent = Slider
            UICorner_1.CornerRadius = UDim.new(0, 12)

            UIStroke_1.Parent = Slider
            UIStroke_1.Color = Color3.fromRGB(110, 110, 140)
            UIStroke_1.Thickness = 2
            UIStroke_1.Transparency = 0.75

            HighlightFrame.Name = "HighlightFrame"
            HighlightFrame.Parent = Slider
            HighlightFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HighlightFrame.BackgroundTransparency = 1
            HighlightFrame.Size = UDim2.new(1, 0, 1, 0)
            HighlightFrame.ZIndex = 2

            HighlightCorner.CornerRadius = UDim.new(0, 12)
            HighlightCorner.Parent = HighlightFrame

            ImageLabel_1.Parent = Slider
            ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
            ImageLabel_1.BackgroundTransparency = 1
            ImageLabel_1.Position = UDim2.new(0.5, 0, 0.5, 0)
            ImageLabel_1.Size = UDim2.new(1, 50, 1, 0)
            ImageLabel_1.Image = "rbxassetid://72380279434385"
            ImageLabel_1.ImageTransparency = 0.85
            ImageLabel_1.ScaleType = Enum.ScaleType.Crop

            UIGradient_1.Parent = ImageLabel_1
            UIGradient_1.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
            }

            TitleLabel.Name = "Title"
            TitleLabel.Parent = Slider
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Position = UDim2.new(0.04, 0, 0, 8)
            TitleLabel.Size = UDim2.new(0.65, 0, 0, 18)
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.Text = Title
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.TextSize = 14
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.TextScaled = true
            TitleLabel.TextWrapped = true

            local TitleConstraint = Instance.new("UITextSizeConstraint")
            TitleConstraint.Parent = TitleLabel
            TitleConstraint.MaxTextSize = 14
            TitleConstraint.MinTextSize = 10

            ValueDisplay.Name = "ValueDisplay"
            ValueDisplay.Parent = Slider
            ValueDisplay.AnchorPoint = Vector2.new(1, 0)
            ValueDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ValueDisplay.BackgroundTransparency = 0.9
            ValueDisplay.Position = UDim2.new(0.96, 0, 0, 8)
            ValueDisplay.Size = UDim2.new(0, 50, 0, 22)

            ValueCorner.Parent = ValueDisplay
            ValueCorner.CornerRadius = UDim.new(0, 6)

            ValueGradient.Parent = ValueDisplay
            ValueGradient.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
            }

            ValueText.Name = "ValueText"
            ValueText.Parent = ValueDisplay
            ValueText.AnchorPoint = Vector2.new(0.5, 0.5)
            ValueText.BackgroundTransparency = 1
            ValueText.Position = UDim2.new(0.5, 0, 0.5, 0)
            ValueText.Size = UDim2.new(0.9, 0, 0.8, 0)
            ValueText.Font = Enum.Font.GothamBold
            ValueText.Text = tostring(Value)
            ValueText.TextColor3 = Color3.fromRGB(255, 255, 255)
            ValueText.TextSize = 12
            ValueText.TextScaled = true

            local ValueConstraint = Instance.new("UITextSizeConstraint")
            ValueConstraint.Parent = ValueText
            ValueConstraint.MaxTextSize = 12
            ValueConstraint.MinTextSize = 8

            if Desc ~= "" then
                DescLabel.Name = "Desc"
                DescLabel.Parent = Slider
                DescLabel.BackgroundTransparency = 1
                DescLabel.Position = UDim2.new(0.04, 0, 0, 28)
                DescLabel.Size = UDim2.new(0.92, 0, 0, 14)
                DescLabel.Font = Enum.Font.Gotham
                DescLabel.Text = Desc
                DescLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
                DescLabel.TextSize = 11
                DescLabel.TextTransparency = 0.4
                DescLabel.TextXAlignment = Enum.TextXAlignment.Left
                DescLabel.TextScaled = true
                DescLabel.TextWrapped = true

                local DescConstraint = Instance.new("UITextSizeConstraint")
                DescConstraint.Parent = DescLabel
                DescConstraint.MaxTextSize = 11
                DescConstraint.MinTextSize = 8
            end

            SliderBar.Name = "SliderBar"
            SliderBar.Parent = Slider
            SliderBar.AnchorPoint = Vector2.new(0.5, 1)
            SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            SliderBar.Position = UDim2.new(0.5, 0, 1, -10)
            SliderBar.Size = UDim2.new(0.92, 0, 0, 8)

            BarCorner.Parent = SliderBar
            BarCorner.CornerRadius = UDim.new(1, 0)

            BarFill.Name = "BarFill"
            BarFill.Parent = SliderBar
            BarFill.AnchorPoint = Vector2.new(0, 0.5)
            BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            BarFill.Position = UDim2.new(0, 0, 0.5, 0)
            BarFill.Size = UDim2.new(0.5, 0, 1, 0)

            FillCorner.Parent = BarFill
            FillCorner.CornerRadius = UDim.new(1, 0)

            FillGradient.Parent = BarFill
            FillGradient.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
            }

            SliderCircle.Name = "SliderCircle"
            SliderCircle.Parent = SliderBar
            SliderCircle.AnchorPoint = Vector2.new(0.5, 0.5)
            SliderCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
            SliderCircle.Size = UDim2.new(0, 18, 0, 18)

            CircleCorner.Parent = SliderCircle
            CircleCorner.CornerRadius = UDim.new(1, 0)

            CircleGradient.Parent = SliderCircle
            CircleGradient.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
            }

            local function roundToDecimal(value, decimals)
                local factor = 10 ^ decimals
                return math.floor(value * factor + 0.5) / factor
            end

            local function updateSlider(value, animate)
                value = math.clamp(value, Min, Max)
                value = roundToDecimal(value, Rounding)
                Value = value

                local percent = (value - Min) / (Max - Min)

                if animate then
                    tw({ v = BarFill, t = 0.15, s = "Quad", d = "Out", g = { Size = UDim2.new(percent, 0, 1, 0) } })
                        :Play()
                    tw({ v = SliderCircle, t = 0.15, s = "Quad", d = "Out", g = { Position = UDim2.new(percent, 0, 0.5, 0) } })
                        :Play()
                else
                    BarFill.Size = UDim2.new(percent, 0, 1, 0)
                    SliderCircle.Position = UDim2.new(percent, 0, 0.5, 0)
                end

                ValueText.Text = tostring(roundToDecimal(value, Rounding))

                local textSize = game:GetService("TextService"):GetTextSize(
                    ValueText.Text,
                    ValueText.TextSize,
                    ValueText.Font,
                    Vector2.new(1000, 1000)
                )
                ValueDisplay.Size = UDim2.new(0, math.max(textSize.X + 16, 40), 0, 22)

                pcall(Callback, value)
            end

            updateSlider(Value, false)

            local function move(input)
                local relativeX = math.clamp(
                (input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                local value = relativeX * (Max - Min) + Min
                updateSlider(value, true)
            end

            local dragging = false

            Slide.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    move(input)
                    tw({ v = SliderCircle, t = 0.2, s = "Back", d = "Out", g = { Size = UDim2.new(0, 22, 0, 22) } })
                        :Play()
                    tw({ v = UIStroke_1, t = 0.2, s = "Quad", d = "Out", g = { Transparency = 0.4 } }):Play()
                end
            end)

            Slide.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    tw({ v = SliderCircle, t = 0.2, s = "Back", d = "Out", g = { Size = UDim2.new(0, 18, 0, 18) } })
                        :Play()
                    tw({ v = UIStroke_1, t = 0.2, s = "Quad", d = "Out", g = { Transparency = 0.75 } }):Play()
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    move(input)
                end
            end)

            table.insert(allElements, { Frame = Slider, SearchName = Title, HighlightFrame = HighlightFrame })

            local Index = {}

            function Index:SetValue(v)
                updateSlider(v, true)
            end

            function Index:GetValue()
                return Value
            end

            function Index:SetTitle(v)
                TitleLabel.Text = v
                for _, element in pairs(allElements) do
                    if element.Frame == Slider then
                        element.SearchName = v
                        break
                    end
                end
            end

            function Index:SetDesc(v)
                if DescLabel then
                    DescLabel.Text = v
                end
            end

            function Index:SetMin(v)
                Min = v
                updateSlider(Value, true)
            end

            function Index:SetMax(v)
                Max = v
                updateSlider(Value, true)
            end

            function Index:Visible(v)
                Slider.Visible = v
            end

            return Index
        end

        function Cat.Elements:Label(meta)
            local Title = meta.Title or "Label"
            local Side = meta.Side or "l"

            elementCount = elementCount + 1
            BadgeLabel.Text = tostring(elementCount)

            local targetWidth = math.max(32, #tostring(elementCount) * 10 + 12)
            tw({ v = BadgeFrame, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0, targetWidth, 0, 18) } }):Play()

            local Label = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local UIStroke = Instance.new("UIStroke")
            local ImageBg = Instance.new("ImageLabel")
            local UIGradient_bg = Instance.new("UIGradient")
            local TextLabel = Instance.new("TextLabel")
            local HighlightFrame = Instance.new("Frame")
            local HighlightCorner = Instance.new("UICorner")

            Label.Name = "Label"
            Label.Parent = GetSide(Side)
            Label.AnchorPoint = Vector2.new(0.5, 0.5)
            Label.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            Label.BackgroundTransparency = 0.35
            Label.BorderSizePixel = 0
            Label.Size = UDim2.new(0.97, 0, 0, 35)
            Label.ClipsDescendants = true

            UICorner.Parent = Label
            UICorner.CornerRadius = UDim.new(0, 10)

            UIStroke.Parent = Label
            UIStroke.Color = Color3.fromRGB(110, 110, 140)
            UIStroke.Thickness = 2
            UIStroke.Transparency = 0.75

            HighlightFrame.Name = "HighlightFrame"
            HighlightFrame.Parent = Label
            HighlightFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HighlightFrame.BackgroundTransparency = 1
            HighlightFrame.Size = UDim2.new(1, 0, 1, 0)
            HighlightFrame.ZIndex = 2

            HighlightCorner.CornerRadius = UDim.new(0, 10)
            HighlightCorner.Parent = HighlightFrame

            ImageBg.Parent = Label
            ImageBg.AnchorPoint = Vector2.new(0.5, 0.5)
            ImageBg.BackgroundTransparency = 1
            ImageBg.Position = UDim2.new(0.5, 0, 0.5, 0)
            ImageBg.Size = UDim2.new(1, 50, 1, 0)
            ImageBg.Image = "rbxassetid://72380279434385"
            ImageBg.ImageTransparency = 0.85
            ImageBg.ScaleType = Enum.ScaleType.Crop

            UIGradient_bg.Parent = ImageBg
            UIGradient_bg.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
            }

            TextLabel.Parent = Label
            TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
            TextLabel.Size = UDim2.new(0.95, 0, 0.8, 0)
            TextLabel.Font = Enum.Font.GothamBold
            TextLabel.RichText = true
            TextLabel.Text = Title
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.TextSize = 14
            TextLabel.TextScaled = true
            TextLabel.TextWrapped = true

            local TextConstraint = Instance.new("UITextSizeConstraint")
            TextConstraint.Parent = TextLabel
            TextConstraint.MaxTextSize = 14
            TextConstraint.MinTextSize = 10

            table.insert(allElements, { Frame = Label, SearchName = Title, HighlightFrame = HighlightFrame })

            local Index = {}

            function Index:SetText(v)
                TextLabel.Text = v
                for _, element in pairs(allElements) do
                    if element.Frame == Label then
                        element.SearchName = v
                        break
                    end
                end
            end

            function Index:Visible(v)
                Label.Visible = v
            end

            return Index
        end

        function Cat.Elements:Paragraph(meta)
            local Title = meta.Title or "Paragraph"
            local Desc = meta.Desc or "Description"
            local Side = meta.Side or "l"

            elementCount = elementCount + 1
            BadgeLabel.Text = tostring(elementCount)

            local targetWidth = math.max(32, #tostring(elementCount) * 10 + 12)
            tw({ v = BadgeFrame, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0, targetWidth, 0, 18) } }):Play()

            local Paragraph = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local UIStroke = Instance.new("UIStroke")
            local ImageBg = Instance.new("ImageLabel")
            local UIGradient_bg = Instance.new("UIGradient")
            local Container = Instance.new("Frame")
            local UIListLayout = Instance.new("UIListLayout")
            local UIPadding = Instance.new("UIPadding")
            local TitleLabel = Instance.new("TextLabel")
            local DescLabel = Instance.new("TextLabel")
            local HighlightFrame = Instance.new("Frame")
            local HighlightCorner = Instance.new("UICorner")

            Paragraph.Name = "Paragraph"
            Paragraph.Parent = GetSide(Side)
            Paragraph.AnchorPoint = Vector2.new(0.5, 0.5)
            Paragraph.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            Paragraph.BackgroundTransparency = 0.35
            Paragraph.BorderSizePixel = 0
            Paragraph.Size = UDim2.new(0.97, 0, 0, 70)
            Paragraph.ClipsDescendants = true

            UICorner.Parent = Paragraph
            UICorner.CornerRadius = UDim.new(0, 12)

            UIStroke.Parent = Paragraph
            UIStroke.Color = Color3.fromRGB(110, 110, 140)
            UIStroke.Thickness = 2
            UIStroke.Transparency = 0.75

            HighlightFrame.Name = "HighlightFrame"
            HighlightFrame.Parent = Paragraph
            HighlightFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HighlightFrame.BackgroundTransparency = 1
            HighlightFrame.Size = UDim2.new(1, 0, 1, 0)
            HighlightFrame.ZIndex = 2

            HighlightCorner.CornerRadius = UDim.new(0, 12)
            HighlightCorner.Parent = HighlightFrame

            ImageBg.Parent = Paragraph
            ImageBg.AnchorPoint = Vector2.new(0.5, 0.5)
            ImageBg.BackgroundTransparency = 1
            ImageBg.Position = UDim2.new(0.5, 0, 0.5, 0)
            ImageBg.Size = UDim2.new(1, 50, 1, 0)
            ImageBg.Image = "rbxassetid://72380279434385"
            ImageBg.ImageTransparency = 0.85
            ImageBg.ScaleType = Enum.ScaleType.Crop

            UIGradient_bg.Parent = ImageBg
            UIGradient_bg.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
            }

            Container.Name = "Container"
            Container.Parent = Paragraph
            Container.AnchorPoint = Vector2.new(0.5, 0.5)
            Container.BackgroundTransparency = 1
            Container.Position = UDim2.new(0.5, 0, 0.5, 0)
            Container.Size = UDim2.new(1, 0, 1, 0)

            UIListLayout.Parent = Container
            UIListLayout.Padding = UDim.new(0, 3)
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            UIPadding.Parent = Container
            UIPadding.PaddingLeft = UDim.new(0, 12)
            UIPadding.PaddingRight = UDim.new(0, 12)

            TitleLabel.Name = "Title"
            TitleLabel.Parent = Container
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Size = UDim2.new(1, 0, 0, 18)
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.RichText = true
            TitleLabel.Text = Title
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.TextSize = 14
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.TextScaled = true
            TitleLabel.TextWrapped = true

            local TitleConstraint = Instance.new("UITextSizeConstraint")
            TitleConstraint.Parent = TitleLabel
            TitleConstraint.MaxTextSize = 14
            TitleConstraint.MinTextSize = 10

            DescLabel.Name = "Desc"
            DescLabel.Parent = Container
            DescLabel.BackgroundTransparency = 1
            DescLabel.Size = UDim2.new(1, 0, 0, 0)
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.RichText = true
            DescLabel.Text = Desc
            DescLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            DescLabel.TextSize = 12
            DescLabel.TextTransparency = 0.3
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.TextYAlignment = Enum.TextYAlignment.Top
            DescLabel.TextWrapped = true
            DescLabel.TextScaled = false

            local DescConstraint = Instance.new("UITextSizeConstraint")
            DescConstraint.Parent = DescLabel
            DescConstraint.MaxTextSize = 12
            DescConstraint.MinTextSize = 8

            local function updateSize()
                task.wait(0.05)
                local textBounds = game:GetService("TextService"):GetTextSize(
                    Desc,
                    DescLabel.TextSize,
                    DescLabel.Font,
                    Vector2.new(DescLabel.AbsoluteSize.X, 10000)
                )
                local descHeight = math.max(textBounds.Y, 15)
                DescLabel.Size = UDim2.new(1, 0, 0, descHeight)
                Paragraph.Size = UDim2.new(0.97, 0, 0, descHeight + 35)
            end

            updateSize()

            table.insert(allElements, { Frame = Paragraph, SearchName = Title, HighlightFrame = HighlightFrame })

            local Index = {}

            function Index:SetTitle(v)
                TitleLabel.Text = v
                for _, element in pairs(allElements) do
                    if element.Frame == Paragraph then
                        element.SearchName = v
                        break
                    end
                end
            end

            function Index:SetDesc(v)
                Desc = v
                DescLabel.Text = v
                updateSize()
            end

            function Index:Visible(v)
                Paragraph.Visible = v
            end

            return Index
        end

        function Cat.Elements:Button(meta)
            local Title = meta.Title
            local Desc = meta.Desc or nil
            local Side = meta.Side or "l"
            local Callback = meta.Callback
            local Icon = meta.Icon or nil

            elementCount = elementCount + 1
            BadgeLabel.Text = tostring(elementCount)

            local targetWidth = math.max(32, #tostring(elementCount) * 10 + 12)
            tw({ v = BadgeFrame, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0, targetWidth, 0, 18) } }):Play()

            if not Icon and not Desc then
                local Button = Instance.new("Frame")
                local UIGradient_1 = Instance.new("UIGradient")
                local Title_1 = Instance.new("TextLabel")
                local UICorner_1 = Instance.new("UICorner")
                local ImageLabel_1 = Instance.new("ImageLabel")
                local UIStroke_btn = Instance.new("UIStroke")
                local HighlightFrame = Instance.new("Frame")
                local HighlightCorner = Instance.new("UICorner")
                local Clickbutton = click(Button)

                Button.Name = "Button"
                Button.Parent = GetSide(Side)
                Button.AnchorPoint = Vector2.new(0.5, 0.5)
                Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Button.BorderSizePixel = 0
                Button.Size = UDim2.new(0.97, 0, 0, 35)
                Button.ClipsDescendants = true

                UIGradient_1.Parent = Button
                UIGradient_1.Color = ColorSequence.new {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
                }

                UIStroke_btn.Parent = Button
                UIStroke_btn.Color = Color3.fromRGB(255, 255, 255)
                UIStroke_btn.Thickness = 2
                UIStroke_btn.Transparency = 0.65

                HighlightFrame.Name = "HighlightFrame"
                HighlightFrame.Parent = Button
                HighlightFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HighlightFrame.BackgroundTransparency = 1
                HighlightFrame.Size = UDim2.new(1, 0, 1, 0)
                HighlightFrame.ZIndex = 2

                HighlightCorner.CornerRadius = UDim.new(0, 10)
                HighlightCorner.Parent = HighlightFrame

                Title_1.Name = "Title"
                Title_1.Parent = Button
                Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
                Title_1.BackgroundTransparency = 1
                Title_1.Position = UDim2.new(0.5, 0, 0.5, 0)
                Title_1.Size = UDim2.new(0.95, 0, 0.8, 0)
                Title_1.Font = Enum.Font.GothamBold
                Title_1.Text = Title
                Title_1.TextColor3 = Color3.fromRGB(255, 255, 255)
                Title_1.TextSize = 14
                Title_1.TextScaled = true
                Title_1.TextWrapped = true

                local TitleConstraint = Instance.new("UITextSizeConstraint")
                TitleConstraint.Parent = Title_1
                TitleConstraint.MaxTextSize = 14
                TitleConstraint.MinTextSize = 10

                UICorner_1.Parent = Button
                UICorner_1.CornerRadius = UDim.new(0, 10)

                ImageLabel_1.Parent = Button
                ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
                ImageLabel_1.BackgroundTransparency = 1
                ImageLabel_1.Position = UDim2.new(0.5, 0, 0.5, 0)
                ImageLabel_1.Size = UDim2.new(1, 50, 1, 0)
                ImageLabel_1.Image = "rbxassetid://72380279434385"
                ImageLabel_1.ImageTransparency = 0.7
                ImageLabel_1.ScaleType = Enum.ScaleType.Crop

                Clickbutton.MouseButton1Click:Connect(function()
                    Callback()
                    tw({ v = Button, t = 0.2, s = "Bounce", d = "Out", g = { Size = UDim2.new(0.9, 0, 0, 35) } }):Play()
                    delay(0.08, function()
                        tw({ v = Button, t = 0.2, s = "Bounce", d = "Out", g = { Size = UDim2.new(0.97, 0, 0, 35) } })
                            :Play()
                    end)
                    EffectClick(Clickbutton, Button)
                end)

                table.insert(allElements, { Frame = Button, SearchName = Title, HighlightFrame = HighlightFrame })

                local Index = {}

                function Index:Fire()
                    Callback()
                end

                function Index:UpdateTitle(v)
                    Title_1.Text = v
                    for _, element in pairs(allElements) do
                        if element.Frame == Button then
                            element.SearchName = v
                            break
                        end
                    end
                end

                function Index:Visible(v)
                    Button.Visible = v
                end

                return Index
            else
                local ButtonImage = Instance.new("Frame")
                local Title_1 = Instance.new("TextLabel")
                local UICorner_1 = Instance.new("UICorner")
                local ImageLabel_1 = Instance.new("ImageLabel")
                local UIGradient_1 = Instance.new("UIGradient")
                local icon_1 = Instance.new("ImageLabel")
                local Desc_1 = Instance.new("TextLabel")
                local next_1 = Instance.new("ImageLabel")
                local UIStroke_btn2 = Instance.new("UIStroke")
                local HighlightFrame = Instance.new("Frame")
                local HighlightCorner = Instance.new("UICorner")
                local ClickButton = click(ButtonImage)

                ButtonImage.Name = "ButtonImage"
                ButtonImage.Parent = GetSide(Side)
                ButtonImage.AnchorPoint = Vector2.new(0.5, 0.5)
                ButtonImage.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                ButtonImage.BackgroundTransparency = 0.35
                ButtonImage.BorderSizePixel = 0
                ButtonImage.Size = UDim2.new(0.97, 0, 0, 55)
                ButtonImage.ClipsDescendants = true

                UIStroke_btn2.Parent = ButtonImage
                UIStroke_btn2.Color = Color3.fromRGB(110, 110, 140)
                UIStroke_btn2.Thickness = 2
                UIStroke_btn2.Transparency = 0.75

                HighlightFrame.Name = "HighlightFrame"
                HighlightFrame.Parent = ButtonImage
                HighlightFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HighlightFrame.BackgroundTransparency = 1
                HighlightFrame.Size = UDim2.new(1, 0, 1, 0)
                HighlightFrame.ZIndex = 2

                HighlightCorner.CornerRadius = UDim.new(0, 12)
                HighlightCorner.Parent = HighlightFrame

                Title_1.Name = "Title"
                Title_1.Parent = ButtonImage
                Title_1.AnchorPoint = Vector2.new(0, 0.5)
                Title_1.BackgroundTransparency = 1
                Title_1.Position = UDim2.new(0, 55, 0.35, 0)
                Title_1.Size = UDim2.new(0.65, 0, 0, 18)
                Title_1.Font = Enum.Font.GothamBold
                Title_1.RichText = true
                Title_1.Text = Title
                Title_1.TextColor3 = Color3.fromRGB(255, 255, 255)
                Title_1.TextSize = 14
                Title_1.TextXAlignment = Enum.TextXAlignment.Left
                Title_1.TextScaled = true
                Title_1.TextWrapped = true

                local TitleSizeConstraint = Instance.new("UITextSizeConstraint")
                TitleSizeConstraint.Parent = Title_1
                TitleSizeConstraint.MaxTextSize = 14
                TitleSizeConstraint.MinTextSize = 10

                UICorner_1.Parent = ButtonImage
                UICorner_1.CornerRadius = UDim.new(0, 12)

                ImageLabel_1.Parent = ButtonImage
                ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
                ImageLabel_1.BackgroundTransparency = 1
                ImageLabel_1.Position = UDim2.new(0.5, 0, 0.5, 0)
                ImageLabel_1.Size = UDim2.new(1, 50, 1, 0)
                ImageLabel_1.Image = "rbxassetid://72380279434385"
                ImageLabel_1.ImageTransparency = 0.85
                ImageLabel_1.ScaleType = Enum.ScaleType.Crop

                UIGradient_1.Parent = ImageLabel_1
                UIGradient_1.Color = ColorSequence.new {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
                }

                icon_1.Name = "icon"
                icon_1.Parent = ButtonImage
                icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
                icon_1.BackgroundTransparency = 1
                icon_1.Position = UDim2.new(0, 27, 0.5, 0)
                icon_1.Size = UDim2.new(0, 38, 0, 38)
                icon_1.Image = GetIcon(Icon)
                icon_1.ScaleType = Enum.ScaleType.Fit

                Desc_1.Name = "Desc"
                Desc_1.Parent = ButtonImage
                Desc_1.AnchorPoint = Vector2.new(0, 0.5)
                Desc_1.BackgroundTransparency = 1
                Desc_1.Position = UDim2.new(0, 55, 0.68, 0)
                Desc_1.Size = UDim2.new(0.65, 0, 0, 15)
                Desc_1.Font = Enum.Font.GothamBold
                Desc_1.RichText = true
                Desc_1.Text = Desc
                Desc_1.TextColor3 = Color3.fromRGB(255, 255, 255)
                Desc_1.TextSize = 11
                Desc_1.TextTransparency = 0.4
                Desc_1.TextXAlignment = Enum.TextXAlignment.Left
                Desc_1.TextScaled = true
                Desc_1.TextWrapped = true

                local DescSizeConstraint = Instance.new("UITextSizeConstraint")
                DescSizeConstraint.Parent = Desc_1
                DescSizeConstraint.MaxTextSize = 11
                DescSizeConstraint.MinTextSize = 8

                next_1.Name = "next"
                next_1.Parent = ButtonImage
                next_1.AnchorPoint = Vector2.new(0.5, 0.5)
                next_1.BackgroundTransparency = 1
                next_1.Position = UDim2.new(1, -16, 0.5, 0)
                next_1.Size = UDim2.new(0, 20, 0, 20)
                next_1.Image = "rbxassetid://108028847031522"
                next_1.ScaleType = Enum.ScaleType.Fit

                ClickButton.MouseButton1Click:Connect(function()
                    Callback()
                    tw({ v = next_1, t = 0.2, s = "Bounce", d = "Out", g = { Position = UDim2.new(1, -12, 0.5, 0) } })
                        :Play()
                    delay(0.08, function()
                        tw({ v = next_1, t = 0.2, s = "Bounce", d = "Out", g = { Position = UDim2.new(1, -16, 0.5, 0) } })
                            :Play()
                    end)
                    EffectClick2(ClickButton, ButtonImage)
                end)

                table.insert(allElements, { Frame = ButtonImage, SearchName = Title, HighlightFrame = HighlightFrame })

                local Index = {}

                function Index:Fire()
                    Callback()
                end

                function Index:Title(v)
                    Title_1.Text = v
                    for _, element in pairs(allElements) do
                        if element.Frame == ButtonImage then
                            element.SearchName = v
                            break
                        end
                    end
                end

                function Index:Desc(v)
                    Desc_1.Text = v
                end

                function Index:Icon(v)
                    icon_1.Image = GetIcon(v)
                end

                function Index:Visible(v)
                    ButtonImage.Visible = v
                end

                return Index
            end
        end

        function Cat.Elements:Dropdown(meta)
            local Title = meta.Title or "Dropdown"
            local Desc = meta.Desc or ""
            local List = meta.List or {}
            local Value = meta.Value or ""
            local Multi = meta.Multi or false
            local Side = meta.Side or "l"
            local Callback = meta.Callback or function() end

            elementCount = elementCount + 1
            BadgeLabel.Text = tostring(elementCount)

            local targetWidth = math.max(32, #tostring(elementCount) * 10 + 12)
            tw({ v = BadgeFrame, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0, targetWidth, 0, 18) } }):Play()

            local Dropdownz = Instance.new("Frame")
            local UICorner_1 = Instance.new("UICorner")
            local UIStroke_1 = Instance.new("UIStroke")
            local ImageLabel_1 = Instance.new("ImageLabel")
            local UIGradient_1 = Instance.new("UIGradient")
            local TitleLabel = Instance.new("TextLabel")
            local DescLabel = Instance.new("TextLabel")
            local ValueDisplay = Instance.new("TextLabel")
            local ValueGradient = Instance.new("UIGradient")
            local ArrowIcon = Instance.new("ImageLabel")
            local ArrowGradient = Instance.new("UIGradient")
            local HighlightFrame = Instance.new("Frame")
            local HighlightCorner = Instance.new("UICorner")
            local ClickDropdown = Instance.new("TextButton")

            Dropdownz.Name = "Dropdown"
            Dropdownz.Parent = GetSide(Side)
            Dropdownz.AnchorPoint = Vector2.new(0.5, 0.5)
            Dropdownz.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            Dropdownz.BackgroundTransparency = 0.35
            Dropdownz.BorderSizePixel = 0
            Dropdownz.Size = UDim2.new(0.97, 0, 0, Desc ~= "" and 65 or 50)
            Dropdownz.ClipsDescendants = true

            UICorner_1.Parent = Dropdownz
            UICorner_1.CornerRadius = UDim.new(0, 12)

            UIStroke_1.Parent = Dropdownz
            UIStroke_1.Color = Color3.fromRGB(110, 110, 140)
            UIStroke_1.Thickness = 2
            UIStroke_1.Transparency = 0.75

            HighlightFrame.Name = "HighlightFrame"
            HighlightFrame.Parent = Dropdownz
            HighlightFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HighlightFrame.BackgroundTransparency = 1
            HighlightFrame.Size = UDim2.new(1, 0, 1, 0)
            HighlightFrame.ZIndex = 2

            HighlightCorner.CornerRadius = UDim.new(0, 12)
            HighlightCorner.Parent = HighlightFrame

            ImageLabel_1.Parent = Dropdownz
            ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
            ImageLabel_1.BackgroundTransparency = 1
            ImageLabel_1.Position = UDim2.new(0.5, 0, 0.5, 0)
            ImageLabel_1.Size = UDim2.new(1, 50, 1, 0)
            ImageLabel_1.Image = "rbxassetid://72380279434385"
            ImageLabel_1.ImageTransparency = 0.85
            ImageLabel_1.ScaleType = Enum.ScaleType.Crop

            UIGradient_1.Parent = ImageLabel_1
            UIGradient_1.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
            }

            TitleLabel.Name = "Title"
            TitleLabel.Parent = Dropdownz
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Position = UDim2.new(0.04, 0, 0, 6)
            TitleLabel.Size = UDim2.new(0.75, 0, 0, 16)
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.Text = Title
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.TextSize = 14
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.TextScaled = true
            TitleLabel.TextWrapped = true

            local TitleConstraint = Instance.new("UITextSizeConstraint")
            TitleConstraint.Parent = TitleLabel
            TitleConstraint.MaxTextSize = 14
            TitleConstraint.MinTextSize = 10

            ValueDisplay.Name = "ValueDisplay"
            ValueDisplay.Parent = Dropdownz
            ValueDisplay.BackgroundTransparency = 1
            ValueDisplay.Position = UDim2.new(0.04, 0, 0, Desc ~= "" and 28 or 24)
            ValueDisplay.Size = UDim2.new(0.85, 0, 0, 16)
            ValueDisplay.Font = Enum.Font.GothamBold
            ValueDisplay.Text = type(Value) == "table" and "Multiple Selected" or
            (Value ~= "" and tostring(Value) or "Select...")
            ValueDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
            ValueDisplay.TextSize = 12
            ValueDisplay.TextXAlignment = Enum.TextXAlignment.Left
            ValueDisplay.TextScaled = true
            ValueDisplay.TextWrapped = true

            local ValueConstraint = Instance.new("UITextSizeConstraint")
            ValueConstraint.Parent = ValueDisplay
            ValueConstraint.MaxTextSize = 12
            ValueConstraint.MinTextSize = 8

            ValueGradient.Parent = ValueDisplay
            ValueGradient.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
            }
            ValueGradient.Rotation = 90

            if Desc ~= "" then
                DescLabel.Name = "Desc"
                DescLabel.Parent = Dropdownz
                DescLabel.BackgroundTransparency = 1
                DescLabel.Position = UDim2.new(0.04, 0, 0, 22)
                DescLabel.Size = UDim2.new(0.75, 0, 0, 12)
                DescLabel.Font = Enum.Font.Gotham
                DescLabel.Text = Desc
                DescLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
                DescLabel.TextSize = 10
                DescLabel.TextTransparency = 0.4
                DescLabel.TextXAlignment = Enum.TextXAlignment.Left
                DescLabel.TextScaled = true
                DescLabel.TextWrapped = true

                local DescConstraint = Instance.new("UITextSizeConstraint")
                DescConstraint.Parent = DescLabel
                DescConstraint.MaxTextSize = 10
                DescConstraint.MinTextSize = 7
            end

            ArrowIcon.Name = "ArrowIcon"
            ArrowIcon.Parent = Dropdownz
            ArrowIcon.AnchorPoint = Vector2.new(1, 0.5)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Position = UDim2.new(0.96, 0, 0.5, 0)
            ArrowIcon.Size = UDim2.new(0, 24, 0, 24)
            ArrowIcon.Image = "rbxassetid://129573215183311"
            ArrowIcon.ScaleType = Enum.ScaleType.Fit

            ArrowGradient.Parent = ArrowIcon
            ArrowGradient.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
            }

            local DropdownMenu = Instance.new("Frame")
            local MenuCorner = Instance.new("UICorner")
            local MenuStroke = Instance.new("UIStroke")
            local MenuEffect = Instance.new("ImageLabel")
            local MenuHeader = Instance.new("Frame")
            local MenuTitle = Instance.new("TextLabel")
            local MenuLine = Instance.new("Frame")
            local LineGradient = Instance.new("UIGradient")
            local SearchBox = Instance.new("TextBox")
            local SearchCorner = Instance.new("UICorner")
            local SearchStroke = Instance.new("UIStroke")
            local SearchGradient = Instance.new("UIGradient")
            local MenuScroll = Instance.new("ScrollingFrame")
            local MenuList = Instance.new("UIListLayout")

            DropdownMenu.Name = "DropdownMenu"
            DropdownMenu.Parent = Background_1
            DropdownMenu.AnchorPoint = Vector2.new(1, 0.5)
            DropdownMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
            DropdownMenu.BackgroundTransparency = 0.05
            DropdownMenu.Position = UDim2.new(1, 0, 0.5, 0)
            DropdownMenu.Size = UDim2.new(0, 0, 1, 0)
            DropdownMenu.ClipsDescendants = true
            DropdownMenu.Visible = false
            DropdownMenu.ZIndex = 100

            MenuCorner.Parent = DropdownMenu
            MenuCorner.CornerRadius = UDim.new(0, 16)

            MenuStroke.Parent = DropdownMenu
            MenuStroke.Color = Color3.fromRGB(110, 110, 140)
            MenuStroke.Thickness = 2
            MenuStroke.Transparency = 0.6

            MenuEffect.Name = "Effect"
            MenuEffect.Parent = DropdownMenu
            MenuEffect.AnchorPoint = Vector2.new(0.5, 0.5)
            MenuEffect.BackgroundTransparency = 1
            MenuEffect.Position = UDim2.new(0.5, 0, 0.5, 0)
            MenuEffect.Size = UDim2.new(1, 0, 1, 0)
            MenuEffect.Image = "rbxassetid://132687652275989"
            MenuEffect.ImageColor3 = Color3.fromRGB(0, 255, 127)
            MenuEffect.ImageTransparency = 0.5
            MenuEffect.ScaleType = Enum.ScaleType.Crop
            MenuEffect.ZIndex = 100

            MenuHeader.Name = "Header"
            MenuHeader.Parent = DropdownMenu
            MenuHeader.BackgroundTransparency = 1
            MenuHeader.Size = UDim2.new(1, 0, 0, 70)
            MenuHeader.ZIndex = 101

            MenuTitle.Name = "Title"
            MenuTitle.Parent = MenuHeader
            MenuTitle.BackgroundTransparency = 1
            MenuTitle.Position = UDim2.new(0, 16, 0, 12)
            MenuTitle.Size = UDim2.new(1, -32, 0, 24)
            MenuTitle.Font = Enum.Font.GothamBold
            MenuTitle.Text = Title
            MenuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            MenuTitle.TextSize = 18
            MenuTitle.TextXAlignment = Enum.TextXAlignment.Left
            MenuTitle.ZIndex = 101

            MenuLine.Name = "Line"
            MenuLine.Parent = MenuHeader
            MenuLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            MenuLine.BorderSizePixel = 0
            MenuLine.Position = UDim2.new(0, 16, 0, 42)
            MenuLine.Size = UDim2.new(0, 60, 0, 2)
            MenuLine.ZIndex = 101

            LineGradient.Parent = MenuLine
            LineGradient.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
            }

            SearchBox.Name = "SearchBox"
            SearchBox.Parent = MenuHeader
            SearchBox.AnchorPoint = Vector2.new(0.5, 1)
            SearchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SearchBox.BackgroundTransparency = 0.92
            SearchBox.Position = UDim2.new(0.5, 0, 1, -4)
            SearchBox.Size = UDim2.new(0, 0, 0, 28)
            SearchBox.Font = Enum.Font.GothamBold
            SearchBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
            SearchBox.PlaceholderText = "Search..."
            SearchBox.Text = ""
            SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            SearchBox.TextSize = 12
            SearchBox.ClearTextOnFocus = false
            SearchBox.ZIndex = 102

            SearchCorner.Parent = SearchBox
            SearchCorner.CornerRadius = UDim.new(0, 8)

            SearchStroke.Parent = SearchBox
            SearchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            SearchStroke.Color = Color3.fromRGB(255, 255, 255)
            SearchStroke.Thickness = 1.5
            SearchStroke.Transparency = 0.7

            SearchGradient.Parent = SearchStroke
            SearchGradient.Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
            }

            MenuScroll.Name = "MenuScroll"
            MenuScroll.Parent = DropdownMenu
            MenuScroll.Active = true
            MenuScroll.BackgroundTransparency = 1
            MenuScroll.BorderSizePixel = 0
            MenuScroll.Position = UDim2.new(0, 8, 0, 78)
            MenuScroll.Size = UDim2.new(1, -16, 1, -86)
            MenuScroll.ClipsDescendants = true
            MenuScroll.ScrollBarThickness = 4
            MenuScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
            MenuScroll.ScrollBarImageTransparency = 0.7
            MenuScroll.ZIndex = 101

            MenuList.Parent = MenuScroll
            MenuList.Padding = UDim.new(0, 4)
            MenuList.SortOrder = Enum.SortOrder.LayoutOrder

            MenuList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                MenuScroll.CanvasSize = UDim2.new(0, 0, 0, MenuList.AbsoluteContentSize.Y + 8)
            end)

            local isAnimating = false
            local isOpen = false
            local selectedValues = {}

            if type(Value) == "table" then
                for _, v in pairs(Value) do
                    selectedValues[v] = true
                end
            elseif Value ~= "" then
                selectedValues[Value] = true
            end

            local function updateDisplay()
                if Multi then
                    local selected = {}
                    for k, v in pairs(selectedValues) do
                        if v then table.insert(selected, k) end
                    end
                    if #selected > 0 then
                        ValueDisplay.Text = #selected .. " Selected"
                    else
                        ValueDisplay.Text = "Select..."
                    end
                else
                    local found = false
                    for k, v in pairs(selectedValues) do
                        if v then
                            ValueDisplay.Text = k
                            found = true
                            break
                        end
                    end
                    if not found then
                        ValueDisplay.Text = "Select..."
                    end
                end
            end

            local function closeMenu()
                if isAnimating or not isOpen then return end
                isAnimating = true
                isOpen = false

                tw({ v = DropdownMenu, t = 0.25, s = "Quad", d = "Out", g = { Size = UDim2.new(0, 0, 1, 0) } }):Play()
                tw({ v = SearchBox, t = 0.2, s = "Quad", d = "Out", g = { Size = UDim2.new(0, 0, 0, 28) } }):Play()
                tw({ v = ArrowIcon, t = 0.25, s = "Quad", d = "Out", g = { Rotation = 0 } }):Play()
                tw({ v = UIStroke_1, t = 0.25, s = "Quad", d = "Out", g = { Transparency = 0.75 } }):Play()

                task.spawn(function()
                    task.wait(0.25)
                    if not isOpen then
                        DropdownMenu.Visible = false
                    end
                    isAnimating = false
                end)
            end

            local function openMenu()
                if isAnimating or isOpen then return end
                isAnimating = true
                isOpen = true

                DropdownMenu.Visible = true
                SearchBox.Text = ""

                tw({ v = DropdownMenu, t = 0.3, s = "Back", d = "Out", g = { Size = UDim2.new(0, 240, 1, 0) } }):Play()
                tw({ v = SearchBox, t = 0.25, s = "Back", d = "Out", g = { Size = UDim2.new(0.9, 0, 0, 28) } }):Play()
                tw({ v = ArrowIcon, t = 0.3, s = "Back", d = "Out", g = { Rotation = 180 } }):Play()
                tw({ v = UIStroke_1, t = 0.3, s = "Quad", d = "Out", g = { Transparency = 0.4 } }):Play()

                task.spawn(function()
                    task.wait(0.3)
                    isAnimating = false
                end)
            end

            ClickDropdown.Name = "ClickDropdown"
            ClickDropdown.Parent = Dropdownz
            ClickDropdown.BackgroundTransparency = 1
            ClickDropdown.Size = UDim2.new(1, 0, 1, 0)
            ClickDropdown.Position = UDim2.new(0, 0, 0, 0)
            ClickDropdown.BorderSizePixel = 0
            ClickDropdown.AutoButtonColor = false
            ClickDropdown.ZIndex = 10
            ClickDropdown.Text = ""

            ClickDropdown.MouseButton1Click:Connect(function()
                if isAnimating then return end

                if isOpen then
                    closeMenu()
                else
                    openMenu()
                end

                EffectClick2(ClickDropdown, Dropdownz)
            end)

            local clickConnection
            local function setupClickOutside()
                if clickConnection then
                    clickConnection:Disconnect()
                    clickConnection = nil
                end

                clickConnection = UserInputService.InputBegan:Connect(function(input)
                    if not isOpen or isAnimating then return end

                    if input.UserInputType == Enum.UserInputType.MouseButton1 or
                        input.UserInputType == Enum.UserInputType.Touch then
                        local mousePos = UserInputService:GetMouseLocation()
                        local menuPos = DropdownMenu.AbsolutePosition
                        local menuSize = DropdownMenu.AbsoluteSize
                        local dropdownPos = Dropdownz.AbsolutePosition
                        local dropdownSize = Dropdownz.AbsoluteSize

                        local clickInMenu = mousePos.X >= menuPos.X and mousePos.X <= menuPos.X + menuSize.X and
                            mousePos.Y >= menuPos.Y and mousePos.Y <= menuPos.Y + menuSize.Y

                        local clickInDropdown = mousePos.X >= dropdownPos.X and
                            mousePos.X <= dropdownPos.X + dropdownSize.X and
                            mousePos.Y >= dropdownPos.Y and mousePos.Y <= dropdownPos.Y + dropdownSize.Y

                        if not clickInMenu and not clickInDropdown then
                            closeMenu()
                        end
                    end
                end)
            end

            SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                local searchText = string.lower(SearchBox.Text)
                for _, item in pairs(MenuScroll:GetChildren()) do
                    if item:IsA("Frame") and item.Name == "Item" then
                        local itemTitle = item:FindFirstChild("ItemTitle")
                        if itemTitle then
                            local itemText = string.lower(itemTitle.Text)
                            item.Visible = searchText == "" or string.find(itemText, searchText, 1, true) ~= nil
                        end
                    end
                end
            end)

            SearchBox.Focused:Connect(function()
                tw({ v = SearchStroke, t = 0.3, s = "Quad", d = "Out", g = { Transparency = 0.3 } }):Play()
            end)

            SearchBox.FocusLost:Connect(function()
                tw({ v = SearchStroke, t = 0.3, s = "Quad", d = "Out", g = { Transparency = 0.7 } }):Play()
            end)

            local function addItem(itemName)
                local Item = Instance.new("Frame")
                local ItemCorner = Instance.new("UICorner")
                local ItemTitle = Instance.new("TextLabel")
                local ItemIndicator = Instance.new("Frame")
                local IndicatorCorner = Instance.new("UICorner")
                local IndicatorGradient = Instance.new("UIGradient")

                Item.Name = "Item"
                Item.Parent = MenuScroll
                Item.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                Item.BackgroundTransparency = 0.4
                Item.Size = UDim2.new(1, 0, 0, 32)
                Item.ZIndex = 102

                ItemCorner.Parent = Item
                ItemCorner.CornerRadius = UDim.new(0, 8)

                ItemTitle.Name = "ItemTitle"
                ItemTitle.Parent = Item
                ItemTitle.BackgroundTransparency = 1
                ItemTitle.Position = UDim2.new(0, 12, 0, 0)
                ItemTitle.Size = UDim2.new(1, -44, 1, 0)
                ItemTitle.Font = Enum.Font.GothamBold
                ItemTitle.Text = itemName
                ItemTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                ItemTitle.TextSize = 13
                ItemTitle.TextTransparency = selectedValues[itemName] and 0 or 0.5
                ItemTitle.TextXAlignment = Enum.TextXAlignment.Left
                ItemTitle.TextScaled = true
                ItemTitle.TextWrapped = true
                ItemTitle.ZIndex = 103

                local ItemConstraint = Instance.new("UITextSizeConstraint")
                ItemConstraint.Parent = ItemTitle
                ItemConstraint.MaxTextSize = 13
                ItemConstraint.MinTextSize = 9

                ItemIndicator.Name = "Indicator"
                ItemIndicator.Parent = Item
                ItemIndicator.AnchorPoint = Vector2.new(0, 0.5)
                ItemIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ItemIndicator.Position = UDim2.new(0, 0, 0.5, 0)
                ItemIndicator.Size = UDim2.new(0, selectedValues[itemName] and 4 or 0, 0, 32)
                ItemIndicator.BackgroundTransparency = selectedValues[itemName] and 0 or 1
                ItemIndicator.ZIndex = 102

                IndicatorCorner.Parent = ItemIndicator
                IndicatorCorner.CornerRadius = UDim.new(1, 0)

                IndicatorGradient.Parent = ItemIndicator
                IndicatorGradient.Color = ColorSequence.new {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 170, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))
                }
                IndicatorGradient.Rotation = 90

                local ItemClick = Instance.new("TextButton")
                ItemClick.Name = "Click"
                ItemClick.Parent = Item
                ItemClick.BackgroundTransparency = 1
                ItemClick.BorderSizePixel = 0
                ItemClick.Size = UDim2.new(1, 0, 1, 0)
                ItemClick.Position = UDim2.new(0, 0, 0, 0)
                ItemClick.ZIndex = 120
                ItemClick.AutoButtonColor = false
                ItemClick.Font = Enum.Font.SourceSans
                ItemClick.Text = ""

                ItemClick.MouseEnter:Connect(function()
                    tw({ v = Item, t = 0.2, s = "Quad", d = "Out", g = { BackgroundTransparency = 0.2 } }):Play()
                end)

                ItemClick.MouseLeave:Connect(function()
                    tw({ v = Item, t = 0.2, s = "Quad", d = "Out", g = { BackgroundTransparency = 0.4 } }):Play()
                end)

                ItemClick.MouseButton1Click:Connect(function()
                    EffectClick2(ItemClick, Item)

                    if Multi then
                        selectedValues[itemName] = not selectedValues[itemName]

                        if selectedValues[itemName] then
                            tw({ v = ItemTitle, t = 0.2, s = "Quad", d = "Out", g = { TextTransparency = 0 } }):Play()
                            tw({ v = ItemIndicator, t = 0.2, s = "Back", d = "Out", g = { Size = UDim2.new(0, 4, 0, 32), BackgroundTransparency = 0 } })
                                :Play()
                        else
                            tw({ v = ItemTitle, t = 0.2, s = "Quad", d = "Out", g = { TextTransparency = 0.5 } }):Play()
                            tw({ v = ItemIndicator, t = 0.2, s = "Back", d = "Out", g = { Size = UDim2.new(0, 0, 0, 32), BackgroundTransparency = 1 } })
                                :Play()
                        end

                        local selected = {}
                        for k, v in pairs(selectedValues) do
                            if v then table.insert(selected, k) end
                        end
                        updateDisplay()
                        task.spawn(function()
                            pcall(Callback, selected)
                        end)
                    else
                        for k in pairs(selectedValues) do
                            selectedValues[k] = false
                        end
                        selectedValues[itemName] = true

                        for _, otherItem in pairs(MenuScroll:GetChildren()) do
                            if otherItem:IsA("Frame") and otherItem.Name == "Item" then
                                local otherTitle = otherItem:FindFirstChild("ItemTitle")
                                local otherIndicator = otherItem:FindFirstChild("Indicator")
                                if otherTitle and otherIndicator then
                                    tw({ v = otherTitle, t = 0.2, s = "Quad", d = "Out", g = { TextTransparency = 0.5 } })
                                        :Play()
                                    tw({ v = otherIndicator, t = 0.2, s = "Back", d = "Out", g = { Size = UDim2.new(0, 0, 0, 32), BackgroundTransparency = 1 } })
                                        :Play()
                                end
                            end
                        end

                        tw({ v = ItemTitle, t = 0.2, s = "Quad", d = "Out", g = { TextTransparency = 0 } }):Play()
                        tw({ v = ItemIndicator, t = 0.2, s = "Back", d = "Out", g = { Size = UDim2.new(0, 4, 0, 32), BackgroundTransparency = 0 } })
                            :Play()

                        updateDisplay()
                        task.spawn(function()
                            pcall(Callback, itemName)
                        end)

                        task.wait(0.15)
                        closeMenu()
                    end
                end)
            end

            for _, item in pairs(List) do
                addItem(item)
            end

            updateDisplay()
            setupClickOutside()

            table.insert(allElements, { Frame = Dropdownz, SearchName = Title, HighlightFrame = HighlightFrame })

            Dropdownz.Destroying:Connect(function()
                if clickConnection then
                    clickConnection:Disconnect()
                    clickConnection = nil
                end
                if DropdownMenu then
                    DropdownMenu:Destroy()
                end
            end)

            local Index = {}

            function Index:Add(item)
                if not table.find(List, item) then
                    table.insert(List, item)
                    addItem(item)
                end
            end

            function Index:Remove(item)
                for i, v in pairs(List) do
                    if v == item then
                        table.remove(List, i)
                        break
                    end
                end

                for _, child in pairs(MenuScroll:GetChildren()) do
                    if child:IsA("Frame") and child.Name == "Item" then
                        local itemTitle = child:FindFirstChild("ItemTitle")
                        if itemTitle and itemTitle.Text == item then
                            child:Destroy()
                            break
                        end
                    end
                end

                selectedValues[item] = nil
                updateDisplay()
            end

            function Index:Clear()
                for _, child in pairs(MenuScroll:GetChildren()) do
                    if child:IsA("Frame") and child.Name == "Item" then
                        child:Destroy()
                    end
                end
                List = {}
                selectedValues = {}
                updateDisplay()
            end

            function Index:SetValue(v)
                selectedValues = {}
                if type(v) == "table" then
                    for _, val in pairs(v) do
                        selectedValues[val] = true
                    end
                elseif type(v) == "string" and v ~= "" then
                    selectedValues[v] = true
                end

                for _, item in pairs(MenuScroll:GetChildren()) do
                    if item:IsA("Frame") and item.Name == "Item" then
                        local itemTitle = item:FindFirstChild("ItemTitle")
                        local itemIndicator = item:FindFirstChild("Indicator")
                        if itemTitle and itemIndicator then
                            local itemName = itemTitle.Text
                            if selectedValues[itemName] then
                                tw({ v = itemTitle, t = 0.2, s = "Quad", d = "Out", g = { TextTransparency = 0 } }):Play()
                                tw({ v = itemIndicator, t = 0.2, s = "Back", d = "Out", g = { Size = UDim2.new(0, 4, 0, 32), BackgroundTransparency = 0 } })
                                    :Play()
                            else
                                tw({ v = itemTitle, t = 0.2, s = "Quad", d = "Out", g = { TextTransparency = 0.5 } })
                                    :Play()
                                tw({ v = itemIndicator, t = 0.2, s = "Back", d = "Out", g = { Size = UDim2.new(0, 0, 0, 32), BackgroundTransparency = 1 } })
                                    :Play()
                            end
                        end
                    end
                end

                updateDisplay()
            end

            function Index:GetValue()
                if Multi then
                    local selected = {}
                    for k, v in pairs(selectedValues) do
                        if v then table.insert(selected, k) end
                    end
                    return selected
                else
                    for k, v in pairs(selectedValues) do
                        if v then return k end
                    end
                    return nil
                end
            end

            function Index:SetTitle(v)
                TitleLabel.Text = v
                MenuTitle.Text = v
                for _, element in pairs(allElements) do
                    if element.Frame == Dropdownz then
                        element.SearchName = v
                        break
                    end
                end
            end

            function Index:SetDesc(v)
                if DescLabel then
                    DescLabel.Text = v
                end
            end

            function Index:Visible(v)
                Dropdownz.Visible = v
                if not v and isOpen then
                    closeMenu()
                end
            end

            function Index:SetList(newList)
                for _, child in pairs(MenuScroll:GetChildren()) do
                    if child:IsA("Frame") and child.Name == "Item" then
                        child:Destroy()
                    end
                end

                List = newList or {}

                for _, item in pairs(List) do
                    addItem(item)
                end

                updateDisplay()
            end

            function Index:Refresh()
                for _, item in pairs(MenuScroll:GetChildren()) do
                    if item:IsA("Frame") and item.Name == "Item" then
                        local itemTitle = item:FindFirstChild("ItemTitle")
                        local itemIndicator = item:FindFirstChild("Indicator")
                        if itemTitle and itemIndicator then
                            local itemName = itemTitle.Text
                            if selectedValues[itemName] then
                                itemTitle.TextTransparency = 0
                                itemIndicator.Size = UDim2.new(0, 4, 0, 32)
                                itemIndicator.BackgroundTransparency = 0
                            else
                                itemTitle.TextTransparency = 0.5
                                itemIndicator.Size = UDim2.new(0, 0, 0, 32)
                                itemIndicator.BackgroundTransparency = 1
                            end
                        end
                    end
                end
                updateDisplay()
            end

            return Index
        end

        return Cat.Elements
    end

    return Cat.Tabs
end

return Cat
