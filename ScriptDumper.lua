-- ╔══════════════════════════════════════════╗
-- ║   NOVA DUMPER v3.0 - Script Extractor   ║
-- ║   Enhanced UI + Full Feature Set        ║
-- ╚══════════════════════════════════════════╝

local VERSION = "v3.0"
local TOOL_NAME = "NOVA DUMPER"

-- ══════════════════ SERVICES ══════════════════
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local HttpService         = game:GetService("HttpService")
local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local CoreGui             = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ══════════════════ CONFIG ══════════════════
local Config = {
    -- SCRIPTS
    LocalScript          = true,
    ModuleScript         = true,
    ScriptClientRun      = true,

    -- REMOTES
    RemoteEvent          = true,
    RemoteFunction       = true,
    Bindables            = false,

    -- SERVICES
    ReplicatedFirst      = true,
    StarterGui           = true,
    StarterPack          = true,
    StarterPlayer        = true,
    Lighting             = true,

    -- REPORTS
    ScriptIndex          = true,
    HierarchyTree        = true,
    GameInfo             = true,

    -- PERFORMANCE
    ChunkYield           = true,

    -- ADVANCED
    OutputFormat         = "Lua",    -- "Lua" | "JSON"
    DecompileTimeout     = false,
    TimeoutDuration      = 60,
    MaxFileSize          = 0,        -- 0 = OFF
    IncludeDisabledScripts = false,
    DumpProperties       = false,
    DetectObfuscation    = true,
    AutoCopySummary      = false,

    -- REPORTS ADVANCED
    JSONExport           = true,
    DependencyGraph      = true,
    SizeBreakdown        = true,
}

-- ══════════════════ THEME ══════════════════
local Theme = {
    BG           = Color3.fromRGB(13, 13, 20),
    BG2          = Color3.fromRGB(20, 20, 32),
    BG3          = Color3.fromRGB(28, 28, 42),
    Panel        = Color3.fromRGB(22, 22, 36),
    Accent       = Color3.fromRGB(99, 102, 241),    -- indigo-500
    AccentHover  = Color3.fromRGB(129, 132, 255),
    AccentDark   = Color3.fromRGB(67, 56, 202),
    Success      = Color3.fromRGB(34, 197, 94),
    Warning      = Color3.fromRGB(251, 191, 36),
    Danger       = Color3.fromRGB(239, 68, 68),
    Text         = Color3.fromRGB(240, 240, 255),
    TextSub      = Color3.fromRGB(140, 140, 170),
    TextMuted    = Color3.fromRGB(80, 80, 110),
    Border       = Color3.fromRGB(40, 40, 65),
    ToggleOff    = Color3.fromRGB(45, 45, 68),
    ToggleOn     = Color3.fromRGB(99, 102, 241),
    HeaderGrad1  = Color3.fromRGB(99, 102, 241),
    HeaderGrad2  = Color3.fromRGB(139, 92, 246),
}

-- ══════════════════ UTILITIES ══════════════════
local function Create(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function TweenColor(obj, prop, targetColor, duration)
    TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[prop] = targetColor}):Play()
end

local function TweenSize(obj, targetSize, duration)
    TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end

local function RoundCorner(parent, radius)
    return Create("UICorner", {CornerRadius = UDim.new(0, radius), Parent = parent})
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {Color = color or Theme.Border, Thickness = thickness or 1, Parent = parent})
end

local function AddPadding(parent, top, bottom, left, right)
    return Create("UIPadding", {
        PaddingTop    = UDim.new(0, top    or 8),
        PaddingBottom = UDim.new(0, bottom or 8),
        PaddingLeft   = UDim.new(0, left   or 12),
        PaddingRight  = UDim.new(0, right  or 12),
        Parent = parent
    })
end

-- ══════════════════ MAIN GUI ══════════════════
-- Remove old GUI if exists
pcall(function()
    if CoreGui:FindFirstChild("NovaDumperGui") then
        CoreGui:FindFirstChild("NovaDumperGui"):Destroy()
    end
end)

local ScreenGui = Create("ScreenGui", {
    Name            = "NovaDumperGui",
    ResetOnSpawn    = false,
    ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
    Parent          = (pcall(function() return CoreGui end) and CoreGui) or PlayerGui
})

-- ──────────── MAIN FRAME ────────────
local MainFrame = Create("Frame", {
    Name            = "MainFrame",
    Size            = UDim2.new(0, 340, 0, 560),
    Position        = UDim2.new(0.5, -170, 0.5, -280),
    BackgroundColor3 = Theme.BG,
    BorderSizePixel = 0,
    Parent          = ScreenGui,
    ClipsDescendants = true,
})
RoundCorner(MainFrame, 14)
AddStroke(MainFrame, Theme.Border, 1)

-- Drop Shadow
local Shadow = Create("ImageLabel", {
    Name            = "Shadow",
    AnchorPoint     = Vector2.new(0.5, 0.5),
    Position        = UDim2.new(0.5, 0, 0.5, 8),
    Size            = UDim2.new(1, 30, 1, 30),
    BackgroundTransparency = 1,
    Image           = "rbxassetid://6015897843",
    ImageColor3     = Color3.fromRGB(0,0,0),
    ImageTransparency = 0.5,
    ScaleType       = Enum.ScaleType.Slice,
    SliceCenter     = Rect.new(49, 49, 450, 450),
    ZIndex          = -1,
    Parent          = MainFrame,
})

-- ──────────── HEADER ────────────
local Header = Create("Frame", {
    Name            = "Header",
    Size            = UDim2.new(1, 0, 0, 64),
    BackgroundColor3 = Theme.BG2,
    BorderSizePixel = 0,
    Parent          = MainFrame,
})
RoundCorner(Header, 14)

-- Header gradient accent bar
local HeaderAccent = Create("Frame", {
    Name            = "Accent",
    Size            = UDim2.new(1, 0, 0, 3),
    Position        = UDim2.new(0, 0, 1, -3),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Parent          = Header,
})
Create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.HeaderGrad1),
        ColorSequenceKeypoint.new(1, Theme.HeaderGrad2),
    }),
    Parent = HeaderAccent,
})

-- Logo / Title
local LogoFrame = Create("Frame", {
    Name            = "LogoFrame",
    Size            = UDim2.new(0, 120, 0, 38),
    Position        = UDim2.new(0, 14, 0.5, -19),
    BackgroundTransparency = 1,
    Parent          = Header,
})

local TitleLabel = Create("TextLabel", {
    Name            = "Title",
    Size            = UDim2.new(1, 0, 0, 22),
    Position        = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Font            = Enum.Font.GothamBold,
    Text            = TOOL_NAME,
    TextColor3      = Theme.Text,
    TextSize        = 18,
    TextXAlignment  = Enum.TextXAlignment.Left,
    Parent          = LogoFrame,
})

local VersionLabel = Create("TextLabel", {
    Name            = "Version",
    Size            = UDim2.new(1, 0, 0, 14),
    Position        = UDim2.new(0, 0, 0, 22),
    BackgroundTransparency = 1,
    Font            = Enum.Font.Gotham,
    Text            = VERSION .. "  •  Enhanced Edition",
    TextColor3      = Theme.Accent,
    TextSize        = 10,
    TextXAlignment  = Enum.TextXAlignment.Left,
    Parent          = LogoFrame,
})

-- Game Name + ID
local GameInfoFrame = Create("Frame", {
    Size            = UDim2.new(0, 175, 0, 38),
    Position        = UDim2.new(1, -195, 0.5, -19),
    BackgroundTransparency = 1,
    Parent          = Header,
})

local GameNameLabel = Create("TextLabel", {
    Size            = UDim2.new(1, 0, 0, 20),
    Position        = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Font            = Enum.Font.GothamSemibold,
    Text            = game.Name ~= "" and game.Name or "Unknown Game",
    TextColor3      = Theme.Text,
    TextSize        = 12,
    TextXAlignment  = Enum.TextXAlignment.Right,
    TextTruncate    = Enum.TextTruncate.AtEnd,
    Parent          = GameInfoFrame,
})

local GameIdLabel = Create("TextLabel", {
    Size            = UDim2.new(1, 0, 0, 16),
    Position        = UDim2.new(0, 0, 0, 20),
    BackgroundTransparency = 1,
    Font            = Enum.Font.Gotham,
    Text            = "#" .. tostring(game.PlaceId),
    TextColor3      = Theme.TextMuted,
    TextSize        = 10,
    TextXAlignment  = Enum.TextXAlignment.Right,
    Parent          = GameInfoFrame,
})

-- Close Button
local CloseBtn = Create("TextButton", {
    Name            = "CloseBtn",
    Size            = UDim2.new(0, 28, 0, 28),
    Position        = UDim2.new(1, -38, 0.5, -14),
    BackgroundColor3 = Color3.fromRGB(40, 40, 60),
    BorderSizePixel = 0,
    Font            = Enum.Font.GothamBold,
    Text            = "✕",
    TextColor3      = Theme.TextSub,
    TextSize        = 13,
    Parent          = Header,
    ZIndex          = 10,
})
RoundCorner(CloseBtn, 8)

CloseBtn.MouseEnter:Connect(function()
    TweenColor(CloseBtn, "BackgroundColor3", Theme.Danger, 0.15)
    TweenColor(CloseBtn, "TextColor3", Color3.fromRGB(255,255,255), 0.15)
end)
CloseBtn.MouseLeave:Connect(function()
    TweenColor(CloseBtn, "BackgroundColor3", Color3.fromRGB(40,40,60), 0.15)
    TweenColor(CloseBtn, "TextColor3", Theme.TextSub, 0.15)
end)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ──────────── SCROLL AREA ────────────
local ScrollContainer = Create("ScrollingFrame", {
    Name                = "ScrollContainer",
    Size                = UDim2.new(1, 0, 1, -118),
    Position            = UDim2.new(0, 0, 0, 64),
    BackgroundTransparency = 1,
    BorderSizePixel     = 0,
    ScrollBarThickness  = 3,
    ScrollBarImageColor3 = Theme.Accent,
    ScrollingDirection  = Enum.ScrollingDirection.Y,
    CanvasSize          = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent              = MainFrame,
})
AddPadding(ScrollContainer, 10, 10, 14, 14)

local ContentList = Create("UIListLayout", {
    SortOrder           = Enum.SortOrder.LayoutOrder,
    Padding             = UDim.new(0, 6),
    Parent              = ScrollContainer,
})

-- ──────────── BOTTOM BAR ────────────
local BottomBar = Create("Frame", {
    Name            = "BottomBar",
    Size            = UDim2.new(1, 0, 0, 54),
    Position        = UDim2.new(0, 0, 1, -54),
    BackgroundColor3 = Theme.BG2,
    BorderSizePixel = 0,
    Parent          = MainFrame,
})

Create("Frame", {
    Size            = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Theme.Border,
    BorderSizePixel = 0,
    Parent          = BottomBar,
})

local StatusLabel = Create("TextLabel", {
    Name            = "Status",
    Size            = UDim2.new(0.5, 0, 1, 0),
    Position        = UDim2.new(0, 14, 0, 0),
    BackgroundTransparency = 1,
    Font            = Enum.Font.Gotham,
    Text            = "● ready",
    TextColor3      = Theme.Success,
    TextSize        = 11,
    TextXAlignment  = Enum.TextXAlignment.Left,
    Parent          = BottomBar,
})

local DumpBtn = Create("TextButton", {
    Name            = "DumpBtn",
    Size            = UDim2.new(0, 130, 0, 36),
    Position        = UDim2.new(1, -144, 0.5, -18),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Font            = Enum.Font.GothamBold,
    Text            = "  ▶  START DUMP",
    TextColor3      = Color3.fromRGB(255, 255, 255),
    TextSize        = 12,
    Parent          = BottomBar,
})
RoundCorner(DumpBtn, 10)
Create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.HeaderGrad2),
    }),
    Rotation = 90,
    Parent = DumpBtn,
})

DumpBtn.MouseEnter:Connect(function()
    TweenColor(DumpBtn, "BackgroundColor3", Theme.AccentHover, 0.15)
end)
DumpBtn.MouseLeave:Connect(function()
    TweenColor(DumpBtn, "BackgroundColor3", Theme.Accent, 0.15)
end)

-- ══════════════════ UI COMPONENTS ══════════════════

-- Section Header
local function CreateSection(title, icon)
    local row = Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        LayoutOrder     = 0,
        Parent          = ScrollContainer,
    })

    local accent = Create("Frame", {
        Size            = UDim2.new(0, 3, 0.6, 0),
        Position        = UDim2.new(0, 0, 0.2, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent          = row,
    })
    RoundCorner(accent, 2)

    Create("TextLabel", {
        Size            = UDim2.new(1, -10, 1, 0),
        Position        = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Font            = Enum.Font.GothamBold,
        Text            = (icon and (icon .. "  ") or "") .. string.upper(title),
        TextColor3      = Theme.TextMuted,
        TextSize        = 10,
        TextXAlignment  = Enum.TextXAlignment.Left,
        LetterSpacing   = 2,
        Parent          = row,
    })

    return row
end

-- Toggle Row
local function CreateToggle(label, configKey, description)
    local isOn = Config[configKey]

    local row = Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Parent          = ScrollContainer,
    })
    RoundCorner(row, 8)
    AddStroke(row, Theme.Border, 1)

    local labelFrame = Create("Frame", {
        Size            = UDim2.new(1, -68, 1, 0),
        Position        = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Parent          = row,
    })

    Create("TextLabel", {
        Size            = UDim2.new(1, 0, description and 0.55 or 1, 0),
        BackgroundTransparency = 1,
        Font            = Enum.Font.GothamSemibold,
        Text            = label,
        TextColor3      = Theme.Text,
        TextSize        = 13,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = labelFrame,
    })

    if description then
        Create("TextLabel", {
            Size            = UDim2.new(1, 0, 0.45, 0),
            Position        = UDim2.new(0, 0, 0.55, 0),
            BackgroundTransparency = 1,
            Font            = Enum.Font.Gotham,
            Text            = description,
            TextColor3      = Theme.TextMuted,
            TextSize        = 10,
            TextXAlignment  = Enum.TextXAlignment.Left,
            Parent          = labelFrame,
        })
    end

    -- Toggle Track
    local track = Create("Frame", {
        Size            = UDim2.new(0, 44, 0, 24),
        Position        = UDim2.new(1, -54, 0.5, -12),
        BackgroundColor3 = isOn and Theme.ToggleOn or Theme.ToggleOff,
        BorderSizePixel = 0,
        Parent          = row,
    })
    RoundCorner(track, 12)

    -- Toggle Knob
    local knob = Create("Frame", {
        Size            = UDim2.new(0, 18, 0, 18),
        Position        = isOn and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent          = track,
    })
    RoundCorner(knob, 9)

    -- Glow when ON
    local glow = Create("ImageLabel", {
        AnchorPoint     = Vector2.new(0.5, 0.5),
        Position        = UDim2.new(0.5, 0, 0.5, 0),
        Size            = UDim2.new(2, 0, 2, 0),
        BackgroundTransparency = 1,
        Image           = "rbxassetid://6015897843",
        ImageColor3     = Theme.Accent,
        ImageTransparency = isOn and 0.7 or 1,
        ScaleType       = Enum.ScaleType.Slice,
        SliceCenter     = Rect.new(49, 49, 450, 450),
        ZIndex          = -1,
        Parent          = track,
    })

    -- Click logic
    local clickArea = Create("TextButton", {
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text            = "",
        Parent          = row,
        ZIndex          = 5,
    })

    local function updateToggle(state)
        Config[configKey] = state
        isOn = state

        local targetPos = state and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        local targetColor = state and Theme.ToggleOn or Theme.ToggleOff
        local targetGlow = state and 0.7 or 1

        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = targetPos
        }):Play()
        TweenColor(track, "BackgroundColor3", targetColor, 0.18)
        TweenService:Create(glow, TweenInfo.new(0.18), {ImageTransparency = targetGlow}):Play()
    end

    -- Hover highlight
    clickArea.MouseEnter:Connect(function()
        TweenColor(row, "BackgroundColor3", Color3.fromRGB(30, 30, 46), 0.1)
    end)
    clickArea.MouseLeave:Connect(function()
        TweenColor(row, "BackgroundColor3", Theme.Panel, 0.1)
    end)

    clickArea.MouseButton1Click:Connect(function()
        updateToggle(not isOn)
    end)

    return row, updateToggle
end

-- Stepper Row (for numeric values)
local function CreateStepper(label, configKey, unit, values)
    local currentIdx = 1
    if type(values) == "table" then
        for i, v in ipairs(values) do
            if v == Config[configKey] then currentIdx = i break end
        end
    end

    local row = Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Parent          = ScrollContainer,
    })
    RoundCorner(row, 8)
    AddStroke(row, Theme.Border, 1)

    Create("TextLabel", {
        Size            = UDim2.new(0.5, 0, 1, 0),
        Position        = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Font            = Enum.Font.GothamSemibold,
        Text            = label,
        TextColor3      = Theme.Text,
        TextSize        = 13,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = row,
    })

    local controlFrame = Create("Frame", {
        Size            = UDim2.new(0, 120, 0, 30),
        Position        = UDim2.new(1, -130, 0.5, -15),
        BackgroundColor3 = Theme.BG3,
        BorderSizePixel = 0,
        Parent          = row,
    })
    RoundCorner(controlFrame, 8)
    AddStroke(controlFrame, Theme.Border, 1)

    local minusBtn = Create("TextButton", {
        Size            = UDim2.new(0, 30, 1, 0),
        BackgroundTransparency = 1,
        Font            = Enum.Font.GothamBold,
        Text            = "−",
        TextColor3      = Theme.TextSub,
        TextSize        = 16,
        Parent          = controlFrame,
    })

    local valueLabel = Create("TextLabel", {
        Size            = UDim2.new(1, -60, 1, 0),
        Position        = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Font            = Enum.Font.GothamBold,
        Text            = tostring(values[currentIdx]) .. (unit or ""),
        TextColor3      = Theme.Accent,
        TextSize        = 13,
        Parent          = controlFrame,
    })

    local plusBtn = Create("TextButton", {
        Size            = UDim2.new(0, 30, 1, 0),
        Position        = UDim2.new(1, -30, 0, 0),
        BackgroundTransparency = 1,
        Font            = Enum.Font.GothamBold,
        Text            = "+",
        TextColor3      = Theme.TextSub,
        TextSize        = 16,
        Parent          = controlFrame,
    })

    local function update()
        local v = values[currentIdx]
        Config[configKey] = v
        valueLabel.Text = (v == 0 and "OFF" or tostring(v) .. (unit or ""))
        valueLabel.TextColor3 = (v == 0) and Theme.TextMuted or Theme.Accent
    end

    minusBtn.MouseButton1Click:Connect(function()
        currentIdx = math.max(1, currentIdx - 1)
        update()
    end)
    plusBtn.MouseButton1Click:Connect(function()
        currentIdx = math.min(#values, currentIdx + 1)
        update()
    end)

    return row
end

-- Dropdown Row
local function CreateDropdown(label, configKey, options)
    local currentOpt = Config[configKey]
    local open = false

    local row = Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex          = 10,
        Parent          = ScrollContainer,
    })
    RoundCorner(row, 8)
    AddStroke(row, Theme.Border, 1)

    Create("TextLabel", {
        Size            = UDim2.new(0.5, 0, 1, 0),
        Position        = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Font            = Enum.Font.GothamSemibold,
        Text            = label,
        TextColor3      = Theme.Text,
        TextSize        = 13,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 10,
        Parent          = row,
    })

    local dropBtn = Create("TextButton", {
        Size            = UDim2.new(0, 90, 0, 28),
        Position        = UDim2.new(1, -100, 0.5, -14),
        BackgroundColor3 = Theme.BG3,
        BorderSizePixel = 0,
        Font            = Enum.Font.GothamSemibold,
        Text            = currentOpt .. "  ▾",
        TextColor3      = Theme.Accent,
        TextSize        = 12,
        ZIndex          = 10,
        Parent          = row,
    })
    RoundCorner(dropBtn, 7)
    AddStroke(dropBtn, Theme.Border, 1)

    local dropList = Create("Frame", {
        Size            = UDim2.new(0, 90, 0, #options * 34),
        Position        = UDim2.new(1, -100, 1, 4),
        BackgroundColor3 = Theme.BG2,
        BorderSizePixel = 0,
        Visible         = false,
        ZIndex          = 20,
        Parent          = row,
    })
    RoundCorner(dropList, 8)
    AddStroke(dropList, Theme.Border, 1)

    Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = dropList})

    for i, opt in ipairs(options) do
        local optBtn = Create("TextButton", {
            Size            = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            Font            = Enum.Font.GothamSemibold,
            Text            = opt,
            TextColor3      = opt == currentOpt and Theme.Accent or Theme.TextSub,
            TextSize        = 12,
            ZIndex          = 20,
            LayoutOrder     = i,
            Parent          = dropList,
        })
        optBtn.MouseEnter:Connect(function()
            if opt ~= currentOpt then
                TweenColor(optBtn, "TextColor3", Theme.Text, 0.1)
            end
        end)
        optBtn.MouseLeave:Connect(function()
            if opt ~= currentOpt then
                TweenColor(optBtn, "TextColor3", Theme.TextSub, 0.1)
            end
        end)
        optBtn.MouseButton1Click:Connect(function()
            currentOpt = opt
            Config[configKey] = opt
            dropBtn.Text = opt .. "  ▾"
            dropList.Visible = false
            open = false
            for _, child in ipairs(dropList:GetChildren()) do
                if child:IsA("TextButton") then
                    child.TextColor3 = (child.Text == opt) and Theme.Accent or Theme.TextSub
                end
            end
        end)
    end

    dropBtn.MouseButton1Click:Connect(function()
        open = not open
        dropList.Visible = open
        dropBtn.Text = currentOpt .. (open and "  ▴" or "  ▾")
    end)

    return row
end

-- Info Banner
local function CreateInfoBanner()
    local banner = Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Color3.fromRGB(20, 25, 45),
        BorderSizePixel = 0,
        Parent          = ScrollContainer,
    })
    RoundCorner(banner, 8)
    AddStroke(banner, Color3.fromRGB(50, 60, 100), 1)

    Create("TextLabel", {
        Size            = UDim2.new(1, 0, 0.5, 0),
        Position        = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Font            = Enum.Font.GothamBold,
        Text            = "⚡  " .. game.Name,
        TextColor3      = Theme.Text,
        TextSize        = 13,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = banner,
    })

    Create("TextLabel", {
        Size            = UDim2.new(1, -14, 0.5, 0),
        Position        = UDim2.new(0, 14, 0.5, 0),
        BackgroundTransparency = 1,
        Font            = Enum.Font.Gotham,
        Text            = "PlaceId: " .. tostring(game.PlaceId) .. "   •   Players: " .. #Players:GetPlayers(),
        TextColor3      = Theme.TextMuted,
        TextSize        = 10,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = banner,
    })

    return banner
end

-- ══════════════════ BUILD UI ══════════════════

CreateInfoBanner()

-- SCRIPTS
CreateSection("Scripts", "📜")
CreateToggle("LocalScript",         "LocalScript",     "Client-side Lua scripts")
CreateToggle("ModuleScript",        "ModuleScript",    "Shared module scripts")
CreateToggle("Script (Client Run)", "ScriptClientRun", "Server scripts run on client")

-- REMOTES
CreateSection("Remotes", "📡")
CreateToggle("RemoteEvent",         "RemoteEvent",     "Network events (fire & forget)")
CreateToggle("RemoteFunction",      "RemoteFunction",  "Network functions (invoke/return)")
CreateToggle("Bindables",           "Bindables",       "Local bindable events & functions")

-- SERVICES
CreateSection("Services", "⚙️")
CreateToggle("ReplicatedFirst",     "ReplicatedFirst", "Loads before everything else")
CreateToggle("StarterGui",          "StarterGui",      "UI scripts and frames")
CreateToggle("StarterPack",         "StarterPack",     "Tools given to player on join")
CreateToggle("StarterPlayer",       "StarterPlayer",   "PlayerScripts & CharacterScripts")
CreateToggle("Lighting",            "Lighting",        "Atmosphere, sky & post-effects")

-- REPORTS
CreateSection("Reports", "📊")
CreateToggle("Script Index",        "ScriptIndex",     "List all scripts with paths")
CreateToggle("Hierarchy Tree",      "HierarchyTree",   "Full instance hierarchy")
CreateToggle("Game Info",           "GameInfo",        "Metadata, creator & asset info")

-- PERFORMANCE
CreateSection("Performance", "⚡")
CreateToggle("Chunk Yield (no freeze)", "ChunkYield",  "Yield between chunks to avoid lag")

-- ADVANCED
CreateSection("Advanced", "🔧")
CreateDropdown("Output Format",      "OutputFormat",   {"Lua", "JSON", "Plain Text"})
CreateToggle("Decompile Timeout",    "DecompileTimeout","Cancel stuck decompilations")
CreateStepper("Timeout Duration",    "TimeoutDuration", "s",
    {0, 10, 20, 30, 60, 90, 120, 180, 300})
CreateStepper("Max File Size",       "MaxFileSize",     "MB",
    {0, 1, 2, 5, 10, 25, 50, 100})
CreateToggle("Include Disabled Scripts", "IncludeDisabledScripts", "Dump scripts that are disabled")
CreateToggle("Dump Properties",      "DumpProperties",  "Include instance properties")
CreateToggle("Detect Obfuscation",   "DetectObfuscation","Flag obfuscated scripts")
CreateToggle("Auto-copy Summary",    "AutoCopySummary", "Copy summary to clipboard on done")

-- REPORTS (ADVANCED)
CreateSection("Reports (Advanced)", "📈")
CreateToggle("JSON Export",          "JSONExport",      "Export full dump as JSON")
CreateToggle("Dependency Graph",     "DependencyGraph", "Map module require() dependencies")
CreateToggle("Size Breakdown",       "SizeBreakdown",   "Show size stats per script")

-- ══════════════════ DUMPER LOGIC ══════════════════

local isDumping = false
local dumpResults = {}
local totalDumped = 0

local function SetStatus(text, color)
    StatusLabel.Text = "● " .. text
    StatusLabel.TextColor3 = color or Theme.Success
end

local function GetScriptsFromService(service, scriptTypes)
    local found = {}
    local ok, svc = pcall(function() return game:GetService(service) end)
    if not ok or not svc then return found end

    for _, desc in ipairs(svc:GetDescendants()) do
        local className = desc.ClassName
        if scriptTypes[className] then
            table.insert(found, desc)
        end
    end
    return found
end

local function GetRemotes()
    local found = {}
    for _, desc in ipairs(game:GetDescendants()) do
        if Config.RemoteEvent and desc:IsA("RemoteEvent") then
            table.insert(found, {obj = desc, type = "RemoteEvent"})
        elseif Config.RemoteFunction and desc:IsA("RemoteFunction") then
            table.insert(found, {obj = desc, type = "RemoteFunction"})
        elseif Config.Bindables and (desc:IsA("BindableEvent") or desc:IsA("BindableFunction")) then
            table.insert(found, {obj = desc, type = desc.ClassName})
        end
    end
    return found
end

local function GetFullPath(obj)
    local path = {}
    local current = obj
    while current and current ~= game do
        table.insert(path, 1, current.Name)
        current = current.Parent
    end
    return "game." .. table.concat(path, ".")
end

local function DecompileScript(script)
    -- Try executor decompile APIs
    if decompile then
        local ok, src = pcall(decompile, script)
        if ok and src and #src > 0 then return src end
    end
    if getscriptbytecode then
        return "-- [Bytecode only - no decompiler available]\n-- Path: " .. GetFullPath(script)
    end
    return "-- [Source not available]\n-- Path: " .. GetFullPath(script)
end

local function BuildHierarchyTree(root, indent)
    indent = indent or 0
    local lines = {}
    local prefix = string.rep("  ", indent) .. (indent > 0 and "└─ " or "")
    table.insert(lines, prefix .. root.Name .. " [" .. root.ClassName .. "]")
    for _, child in ipairs(root:GetChildren()) do
        for _, line in ipairs(BuildHierarchyTree(child, indent + 1)) do
            table.insert(lines, line)
        end
    end
    return lines
end

local function RunDump()
    if isDumping then return end
    isDumping = true
    dumpResults = {}
    totalDumped = 0

    DumpBtn.Text = "  ⏳  DUMPING..."
    DumpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    SetStatus("Initializing dump...", Theme.Warning)

    local scriptTypes = {}
    if Config.LocalScript    then scriptTypes["LocalScript"]   = true end
    if Config.ModuleScript   then scriptTypes["ModuleScript"]  = true end
    if Config.ScriptClientRun then scriptTypes["Script"]       = true end

    local services = {}
    if Config.ReplicatedFirst  then table.insert(services, "ReplicatedFirst") end
    if Config.StarterGui       then table.insert(services, "StarterGui") end
    if Config.StarterPack      then table.insert(services, "StarterPack") end
    if Config.StarterPlayer    then table.insert(services, "StarterPlayer") end
    if Config.Lighting         then table.insert(services, "Lighting") end

    local allScripts = {}

    -- Collect scripts from services
    for _, svcName in ipairs(services) do
        SetStatus("Scanning " .. svcName .. "...", Theme.Warning)
        if Config.ChunkYield then task.wait(0.05) end

        local found = GetScriptsFromService(svcName, scriptTypes)
        for _, s in ipairs(found) do
            table.insert(allScripts, s)
        end
    end

    SetStatus("Found " .. #allScripts .. " scripts. Dumping...", Theme.Warning)
    task.wait(0.1)

    -- Dump each script
    for i, script in ipairs(allScripts) do
        if not (Config.IncludeDisabledScripts == false and script:IsA("BaseScript") and not script.Enabled) then
            local source = DecompileScript(script)
            local path   = GetFullPath(script)
            local size   = #source

            -- Detect obfuscation
            local obfuscated = false
            if Config.DetectObfuscation then
                obfuscated = source:find("\\%d%d%d") ~= nil
                          or source:find("require%(%d+%d+%d+%d%d%d%d%d%d%d") ~= nil
                          or (source:find("[^%w%s%p]") ~= nil)
            end

            table.insert(dumpResults, {
                name       = script.Name,
                class      = script.ClassName,
                path       = path,
                source     = source,
                size       = size,
                obfuscated = obfuscated,
                disabled   = script:IsA("BaseScript") and not script.Enabled,
            })
            totalDumped = totalDumped + 1
        end

        if Config.ChunkYield and i % 5 == 0 then
            SetStatus("Dumping " .. i .. " / " .. #allScripts, Theme.Warning)
            task.wait(0.02)
        end
    end

    -- Dump remotes
    local remotes = GetRemotes()
    SetStatus("Collecting remotes...", Theme.Warning)
    task.wait(0.05)

    -- Build summary
    local summary = {}
    table.insert(summary, "=== " .. TOOL_NAME .. " " .. VERSION .. " ===")
    table.insert(summary, "Game: " .. game.Name)
    table.insert(summary, "PlaceId: " .. tostring(game.PlaceId))
    table.insert(summary, "Time: " .. os.date and os.date("%Y-%m-%d %H:%M:%S") or "N/A")
    table.insert(summary, "")
    table.insert(summary, "Scripts dumped: " .. totalDumped)
    table.insert(summary, "Remotes found:  " .. #remotes)
    table.insert(summary, "")

    if Config.ScriptIndex then
        table.insert(summary, "--- SCRIPT INDEX ---")
        for i, r in ipairs(dumpResults) do
            local flags = ""
            if r.obfuscated then flags = flags .. " [OBFUSCATED]" end
            if r.disabled   then flags = flags .. " [DISABLED]" end
            table.insert(summary, string.format("[%d] %s (%s) - %d bytes%s", i, r.name, r.class, r.size, flags))
            table.insert(summary, "    " .. r.path)
        end
        table.insert(summary, "")
    end

    if Config.HierarchyTree then
        table.insert(summary, "--- HIERARCHY TREE ---")
        local treeLines = BuildHierarchyTree(game)
        for _, line in ipairs(treeLines) do
            table.insert(summary, line)
        end
        table.insert(summary, "")
    end

    if Config.GameInfo then
        table.insert(summary, "--- GAME INFO ---")
        table.insert(summary, "Name:     " .. game.Name)
        table.insert(summary, "PlaceId:  " .. tostring(game.PlaceId))
        table.insert(summary, "JobId:    " .. game.JobId)
        table.insert(summary, "Creator:  " .. tostring(game.CreatorId))
        table.insert(summary, "")
    end

    if #remotes > 0 then
        table.insert(summary, "--- REMOTES ---")
        for _, r in ipairs(remotes) do
            table.insert(summary, "[" .. r.type .. "] " .. GetFullPath(r.obj))
        end
        table.insert(summary, "")
    end

    if Config.SizeBreakdown then
        table.insert(summary, "--- SIZE BREAKDOWN ---")
        local sorted = {}
        for _, r in ipairs(dumpResults) do table.insert(sorted, r) end
        table.sort(sorted, function(a, b) return a.size > b.size end)
        for i = 1, math.min(10, #sorted) do
            local r = sorted[i]
            table.insert(summary, string.format("#%d  %-30s  %d bytes", i, r.name, r.size))
        end
        table.insert(summary, "")
    end

    -- Full dump
    table.insert(summary, "")
    table.insert(summary, "=== SCRIPT SOURCES ===")
    for _, r in ipairs(dumpResults) do
        table.insert(summary, "\n-- ==========================================")
        table.insert(summary, "-- Name:  " .. r.name)
        table.insert(summary, "-- Class: " .. r.class)
        table.insert(summary, "-- Path:  " .. r.path)
        table.insert(summary, "-- Size:  " .. r.size .. " bytes")
        if r.obfuscated then
            table.insert(summary, "-- ⚠ OBFUSCATED SCRIPT DETECTED")
        end
        table.insert(summary, "-- ==========================================")
        table.insert(summary, r.source)
    end

    -- JSON export
    if Config.JSONExport then
        local jsonData = {
            tool    = TOOL_NAME,
            version = VERSION,
            game    = {name = game.Name, placeId = game.PlaceId},
            scripts = dumpResults,
            remotes = {},
        }
        for _, r in ipairs(remotes) do
            table.insert(jsonData.remotes, {type = r.type, path = GetFullPath(r.obj)})
        end
        local ok, jsonStr = pcall(HttpService.JSONEncode, HttpService, jsonData)
        if ok then
            table.insert(summary, "\n=== JSON EXPORT ===")
            table.insert(summary, jsonStr)
        end
    end

    local finalStr = table.concat(summary, "\n")

    -- Copy to clipboard
    if Config.AutoCopySummary then
        pcall(setclipboard, finalStr)
    end

    -- Try to write to file
    local saved = false
    if writefile then
        pcall(function()
            writefile("NovaDumper_" .. tostring(game.PlaceId) .. ".txt", finalStr)
            saved = true
        end)
    end

    -- Also try to put in clipboard if not done already
    if not Config.AutoCopySummary then
        pcall(setclipboard, finalStr)
    end

    isDumping = false
    DumpBtn.Text = "  ✓  DONE!"
    DumpBtn.BackgroundColor3 = Theme.Success

    local statusMsg = "Dumped " .. totalDumped .. " scripts, " .. #remotes .. " remotes"
    if saved then statusMsg = statusMsg .. " • Saved to file" end
    SetStatus(statusMsg, Theme.Success)

    task.wait(3)
    DumpBtn.Text = "  ▶  START DUMP"
    DumpBtn.BackgroundColor3 = Theme.Accent
    SetStatus("ready", Theme.Success)
end

DumpBtn.MouseButton1Click:Connect(function()
    if not isDumping then
        task.spawn(RunDump)
    end
end)

-- ══════════════════ DRAGGING ══════════════════
local dragging, dragInput, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ══════════════════ OPEN ANIMATION ══════════════════
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 340, 0, 560),
    Position = UDim2.new(0.5, -170, 0.5, -280),
}):Play()

print("[" .. TOOL_NAME .. "] " .. VERSION .. " loaded successfully!")
print("Game: " .. game.Name .. " | PlaceId: " .. tostring(game.PlaceId))
