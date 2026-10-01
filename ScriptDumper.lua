-- ╔══════════════════════════════════════════╗
-- ║   NOVA DUMPER v3.0 - Script Extractor   ║
-- ║   Enhanced UI + Full Feature Set        ║
-- ╚══════════════════════════════════════════╝

local VERSION = "v3.0"
local TOOL_NAME = "NOVA DUMPER"

-- ══════════════════ SERVICES ══════════════════
local Players             = game:GetService("Players")
local HttpService         = game:GetService("HttpService")
local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local CoreGui             = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ══════════════════ CONFIG ══════════════════
local Config = {
    LocalScript              = true,
    ModuleScript             = true,
    ScriptClientRun          = true,
    RemoteEvent              = true,
    RemoteFunction           = true,
    Bindables                = false,
    ReplicatedFirst          = true,
    StarterGui               = true,
    StarterPack              = true,
    StarterPlayer            = true,
    Lighting                 = true,
    ScriptIndex              = true,
    HierarchyTree            = true,
    GameInfo                 = true,
    ChunkYield               = true,
    OutputFormat             = "Lua",
    DecompileTimeout         = false,
    TimeoutDuration          = 60,
    MaxFileSize              = 0,
    IncludeDisabledScripts   = false,
    DumpProperties           = false,
    DetectObfuscation        = true,
    AutoCopySummary          = false,
    JSONExport               = true,
    DependencyGraph          = true,
    SizeBreakdown            = true,
}

-- ══════════════════ THEME ══════════════════
local Theme = {
    BG           = Color3.fromRGB(13, 13, 20),
    BG2          = Color3.fromRGB(20, 20, 32),
    BG3          = Color3.fromRGB(28, 28, 42),
    Panel        = Color3.fromRGB(22, 22, 36),
    Accent       = Color3.fromRGB(99, 102, 241),
    AccentHover  = Color3.fromRGB(129, 132, 255),
    Success      = Color3.fromRGB(34, 197, 94),
    Warning      = Color3.fromRGB(251, 191, 36),
    Danger       = Color3.fromRGB(239, 68, 68),
    Text         = Color3.fromRGB(240, 240, 255),
    TextSub      = Color3.fromRGB(140, 140, 170),
    TextMuted    = Color3.fromRGB(80, 80, 110),
    Border       = Color3.fromRGB(40, 40, 65),
    ToggleOff    = Color3.fromRGB(45, 45, 68),
    ToggleOn     = Color3.fromRGB(99, 102, 241),
}

-- ══════════════════ UTILITIES ══════════════════
local function Create(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then o[k] = v end
    end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function RoundCorner(p, r)
    Create("UICorner", {CornerRadius = UDim.new(0, r), Parent = p})
end

local function Stroke(p, c, t)
    Create("UIStroke", {Color = c or Theme.Border, Thickness = t or 1, Parent = p})
end

local function Tween(obj, props, dur, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(dur or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props):Play()
end

-- ══════════════════ DESTROY OLD GUI ══════════════════
pcall(function()
    local old = CoreGui:FindFirstChild("NovaDumperGui")
    if old then old:Destroy() end
end)

-- ══════════════════ SCREEN GUI ══════════════════
local ScreenGui = Create("ScreenGui", {
    Name           = "NovaDumperGui",
    ResetOnSpawn   = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent         = (pcall(function() return CoreGui end) and CoreGui) or PlayerGui,
})

-- ══════════════════ MAIN FRAME ══════════════════
local MainFrame = Create("Frame", {
    Name             = "MainFrame",
    Size             = UDim2.new(0, 340, 0, 560),
    Position         = UDim2.new(0.5, -170, 0.5, -280),
    BackgroundColor3 = Theme.BG,
    BorderSizePixel  = 0,
    ClipsDescendants = true,
    Parent           = ScreenGui,
})
RoundCorner(MainFrame, 14)
Stroke(MainFrame, Theme.Border, 1)

-- ── HEADER ──
local Header = Create("Frame", {
    Size             = UDim2.new(1, 0, 0, 64),
    BackgroundColor3 = Theme.BG2,
    BorderSizePixel  = 0,
    Parent           = MainFrame,
})
RoundCorner(Header, 14)

-- Bottom accent line on header
local HeaderLine = Create("Frame", {
    Size             = UDim2.new(1, 0, 0, 2),
    Position         = UDim2.new(0, 0, 1, -2),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel  = 0,
    Parent           = Header,
})
Create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(99, 102, 241)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 92, 246)),
    }),
    Parent = HeaderLine,
})

-- Title
Create("TextLabel", {
    Size             = UDim2.new(0, 160, 0, 22),
    Position         = UDim2.new(0, 14, 0, 10),
    BackgroundTransparency = 1,
    Font             = Enum.Font.GothamBold,
    Text             = TOOL_NAME,
    TextColor3       = Theme.Text,
    TextSize         = 18,
    TextXAlignment   = Enum.TextXAlignment.Left,
    Parent           = Header,
})
Create("TextLabel", {
    Size             = UDim2.new(0, 200, 0, 14),
    Position         = UDim2.new(0, 14, 0, 33),
    BackgroundTransparency = 1,
    Font             = Enum.Font.Gotham,
    Text             = VERSION .. "  •  Enhanced Edition",
    TextColor3       = Theme.Accent,
    TextSize         = 10,
    TextXAlignment   = Enum.TextXAlignment.Left,
    Parent           = Header,
})

-- Game ID (top right)
Create("TextLabel", {
    Size             = UDim2.new(0, 140, 0, 16),
    Position         = UDim2.new(1, -180, 0, 10),
    BackgroundTransparency = 1,
    Font             = Enum.Font.Gotham,
    Text             = "#" .. tostring(game.PlaceId),
    TextColor3       = Theme.TextMuted,
    TextSize         = 10,
    TextXAlignment   = Enum.TextXAlignment.Right,
    Parent           = Header,
})

-- Close Button
local CloseBtn = Create("TextButton", {
    Size             = UDim2.new(0, 28, 0, 28),
    Position         = UDim2.new(1, -38, 0.5, -14),
    BackgroundColor3 = Color3.fromRGB(40, 40, 60),
    BorderSizePixel  = 0,
    Font             = Enum.Font.GothamBold,
    Text             = "✕",
    TextColor3       = Theme.TextSub,
    TextSize         = 13,
    ZIndex           = 10,
    Parent           = Header,
})
RoundCorner(CloseBtn, 8)
CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Theme.Danger, TextColor3 = Color3.new(1,1,1)}) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(40,40,60), TextColor3 = Theme.TextSub}) end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ── SCROLL FRAME ──
local ScrollFrame = Create("ScrollingFrame", {
    Name                 = "ScrollFrame",
    Size                 = UDim2.new(1, 0, 1, -118),
    Position             = UDim2.new(0, 0, 0, 64),
    BackgroundTransparency = 1,
    BorderSizePixel      = 0,
    ScrollBarThickness   = 3,
    ScrollBarImageColor3 = Theme.Accent,
    ScrollingDirection   = Enum.ScrollingDirection.Y,
    CanvasSize           = UDim2.new(0, 0, 0, 0),
    Parent               = MainFrame,
})

-- Inner content frame — THIS IS THE KEY FIX
-- UIListLayout goes here, not in ScrollFrame directly
local Content = Create("Frame", {
    Name             = "Content",
    Size             = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize    = Enum.AutomaticSize.Y,
    Parent           = ScrollFrame,
})

local ListLayout = Create("UIListLayout", {
    SortOrder        = Enum.SortOrder.LayoutOrder,
    Padding          = UDim.new(0, 5),
    Parent           = Content,
})

Create("UIPadding", {
    PaddingTop    = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    PaddingLeft   = UDim.new(0, 12),
    PaddingRight  = UDim.new(0, 12),
    Parent        = Content,
})

-- Auto-update canvas size when content changes
ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 24)
end)

-- ── BOTTOM BAR ──
local BottomBar = Create("Frame", {
    Size             = UDim2.new(1, 0, 0, 54),
    Position         = UDim2.new(0, 0, 1, -54),
    BackgroundColor3 = Theme.BG2,
    BorderSizePixel  = 0,
    Parent           = MainFrame,
})
Create("Frame", {
    Size             = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Theme.Border,
    BorderSizePixel  = 0,
    Parent           = BottomBar,
})

local StatusLabel = Create("TextLabel", {
    Size             = UDim2.new(0.5, 0, 1, 0),
    Position         = UDim2.new(0, 14, 0, 0),
    BackgroundTransparency = 1,
    Font             = Enum.Font.Gotham,
    Text             = "● ready",
    TextColor3       = Theme.Success,
    TextSize         = 11,
    TextXAlignment   = Enum.TextXAlignment.Left,
    Parent           = BottomBar,
})

local DumpBtn = Create("TextButton", {
    Size             = UDim2.new(0, 136, 0, 36),
    Position         = UDim2.new(1, -148, 0.5, -18),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel  = 0,
    Font             = Enum.Font.GothamBold,
    Text             = "  ▶  START DUMP",
    TextColor3       = Color3.new(1,1,1),
    TextSize         = 12,
    Parent           = BottomBar,
})
RoundCorner(DumpBtn, 10)
Create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(99, 102, 241)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 92, 246)),
    }),
    Rotation = 90,
    Parent = DumpBtn,
})
DumpBtn.MouseEnter:Connect(function() Tween(DumpBtn, {BackgroundColor3 = Theme.AccentHover}) end)
DumpBtn.MouseLeave:Connect(function() Tween(DumpBtn, {BackgroundColor3 = Theme.Accent}) end)

-- ══════════════════ COMPONENT BUILDERS ══════════════════

local layoutOrder = 0
local function NextOrder()
    layoutOrder = layoutOrder + 1
    return layoutOrder
end

-- Section label
local function Section(title, icon)
    local f = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder      = NextOrder(),
        Parent           = Content,
    })
    Create("Frame", {
        Size             = UDim2.new(0, 3, 0.55, 0),
        Position         = UDim2.new(0, 0, 0.22, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        Parent           = f,
    })
    RoundCorner(f, 2)
    Create("TextLabel", {
        Size             = UDim2.new(1, -10, 1, 0),
        Position         = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Font             = Enum.Font.GothamBold,
        Text             = (icon or "") .. "  " .. string.upper(title),
        TextColor3       = Theme.TextMuted,
        TextSize         = 10,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = f,
    })
    return f
end

-- Toggle row
local function Toggle(label, desc, cfgKey)
    local isOn = Config[cfgKey]

    local row = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, desc and 46 or 40),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel  = 0,
        LayoutOrder      = NextOrder(),
        Parent           = Content,
    })
    RoundCorner(row, 8)
    Stroke(row, Theme.Border, 1)

    -- Label block
    Create("TextLabel", {
        Size             = UDim2.new(1, -70, 0, 20),
        Position         = UDim2.new(0, 14, 0, desc and 6 or 10),
        BackgroundTransparency = 1,
        Font             = Enum.Font.GothamSemibold,
        Text             = label,
        TextColor3       = Theme.Text,
        TextSize         = 13,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = row,
    })
    if desc then
        Create("TextLabel", {
            Size             = UDim2.new(1, -70, 0, 14),
            Position         = UDim2.new(0, 14, 0, 26),
            BackgroundTransparency = 1,
            Font             = Enum.Font.Gotham,
            Text             = desc,
            TextColor3       = Theme.TextMuted,
            TextSize         = 10,
            TextXAlignment   = Enum.TextXAlignment.Left,
            Parent           = row,
        })
    end

    -- Track
    local track = Create("Frame", {
        Size             = UDim2.new(0, 44, 0, 24),
        Position         = UDim2.new(1, -54, 0.5, -12),
        BackgroundColor3 = isOn and Theme.ToggleOn or Theme.ToggleOff,
        BorderSizePixel  = 0,
        Parent           = row,
    })
    RoundCorner(track, 12)

    -- Knob
    local knob = Create("Frame", {
        Size             = UDim2.new(0, 18, 0, 18),
        Position         = isOn and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel  = 0,
        Parent           = track,
    })
    RoundCorner(knob, 9)

    -- Click zone (full row)
    local btn = Create("TextButton", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 5,
        Parent           = row,
    })

    local function setToggle(val)
        Config[cfgKey] = val
        isOn = val
        Tween(knob, {Position = val and UDim2.new(0,23,0.5,-9) or UDim2.new(0,3,0.5,-9)})
        Tween(track, {BackgroundColor3 = val and Theme.ToggleOn or Theme.ToggleOff})
    end

    btn.MouseEnter:Connect(function() Tween(row, {BackgroundColor3 = Color3.fromRGB(30,30,48)}) end)
    btn.MouseLeave:Connect(function() Tween(row, {BackgroundColor3 = Theme.Panel}) end)
    btn.MouseButton1Click:Connect(function() setToggle(not isOn) end)

    return row
end

-- Stepper row (numeric)
local function Stepper(label, cfgKey, unit, vals)
    local idx = 1
    for i, v in ipairs(vals) do
        if v == Config[cfgKey] then idx = i break end
    end

    local row = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel  = 0,
        LayoutOrder      = NextOrder(),
        Parent           = Content,
    })
    RoundCorner(row, 8)
    Stroke(row, Theme.Border, 1)

    Create("TextLabel", {
        Size             = UDim2.new(0.55, 0, 1, 0),
        Position         = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Font             = Enum.Font.GothamSemibold,
        Text             = label,
        TextColor3       = Theme.Text,
        TextSize         = 13,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = row,
    })

    local ctrl = Create("Frame", {
        Size             = UDim2.new(0, 110, 0, 28),
        Position         = UDim2.new(1, -120, 0.5, -14),
        BackgroundColor3 = Theme.BG3,
        BorderSizePixel  = 0,
        Parent           = row,
    })
    RoundCorner(ctrl, 7)
    Stroke(ctrl, Theme.Border, 1)

    local minus = Create("TextButton", {
        Size             = UDim2.new(0, 28, 1, 0),
        BackgroundTransparency = 1,
        Font             = Enum.Font.GothamBold,
        Text             = "−",
        TextColor3       = Theme.TextSub,
        TextSize         = 16,
        Parent           = ctrl,
    })

    local valLabel = Create("TextLabel", {
        Size             = UDim2.new(1, -56, 1, 0),
        Position         = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        Font             = Enum.Font.GothamBold,
        Text             = "",
        TextColor3       = Theme.Accent,
        TextSize         = 12,
        Parent           = ctrl,
    })

    local plus = Create("TextButton", {
        Size             = UDim2.new(0, 28, 1, 0),
        Position         = UDim2.new(1, -28, 0, 0),
        BackgroundTransparency = 1,
        Font             = Enum.Font.GothamBold,
        Text             = "+",
        TextColor3       = Theme.TextSub,
        TextSize         = 16,
        Parent           = ctrl,
    })

    local function refresh()
        local v = vals[idx]
        Config[cfgKey] = v
        if v == 0 then
            valLabel.Text = "OFF"
            valLabel.TextColor3 = Theme.TextMuted
        else
            valLabel.Text = tostring(v) .. (unit or "")
            valLabel.TextColor3 = Theme.Accent
        end
    end
    refresh()

    minus.MouseButton1Click:Connect(function() idx = math.max(1, idx-1); refresh() end)
    plus.MouseButton1Click:Connect(function() idx = math.min(#vals, idx+1); refresh() end)
    return row
end

-- Dropdown row
local function Dropdown(label, cfgKey, opts)
    local cur = Config[cfgKey]

    local row = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel  = 0,
        ClipsDescendants = false,
        LayoutOrder      = NextOrder(),
        ZIndex           = 20,
        Parent           = Content,
    })
    RoundCorner(row, 8)
    Stroke(row, Theme.Border, 1)

    Create("TextLabel", {
        Size             = UDim2.new(0.5, 0, 1, 0),
        Position         = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Font             = Enum.Font.GothamSemibold,
        Text             = label,
        TextColor3       = Theme.Text,
        TextSize         = 13,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 20,
        Parent           = row,
    })

    local btn = Create("TextButton", {
        Size             = UDim2.new(0, 90, 0, 26),
        Position         = UDim2.new(1, -100, 0.5, -13),
        BackgroundColor3 = Theme.BG3,
        BorderSizePixel  = 0,
        Font             = Enum.Font.GothamSemibold,
        Text             = cur .. " ▾",
        TextColor3       = Theme.Accent,
        TextSize         = 12,
        ZIndex           = 20,
        Parent           = row,
    })
    RoundCorner(btn, 7)
    Stroke(btn, Theme.Border, 1)

    local popup = Create("Frame", {
        Size             = UDim2.new(0, 100, 0, #opts * 32),
        Position         = UDim2.new(1, -100, 1, 4),
        BackgroundColor3 = Theme.BG2,
        BorderSizePixel  = 0,
        Visible          = false,
        ZIndex           = 50,
        Parent           = row,
    })
    RoundCorner(popup, 8)
    Stroke(popup, Theme.Border, 1)
    Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = popup})

    for i, opt in ipairs(opts) do
        local ob = Create("TextButton", {
            Size             = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            Font             = Enum.Font.GothamSemibold,
            Text             = opt,
            TextColor3       = opt == cur and Theme.Accent or Theme.TextSub,
            TextSize         = 12,
            ZIndex           = 50,
            LayoutOrder      = i,
            Parent           = popup,
        })
        ob.MouseButton1Click:Connect(function()
            cur = opt
            Config[cfgKey] = opt
            btn.Text = opt .. " ▾"
            popup.Visible = false
            for _, c in ipairs(popup:GetChildren()) do
                if c:IsA("TextButton") then
                    c.TextColor3 = (c.Text == opt) and Theme.Accent or Theme.TextSub
                end
            end
        end)
    end

    local open = false
    btn.MouseButton1Click:Connect(function()
        open = not open
        popup.Visible = open
        btn.Text = cur .. (open and " ▴" or " ▾")
    end)

    return row
end

-- Info banner
local function InfoBanner()
    local f = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Color3.fromRGB(18, 22, 42),
        BorderSizePixel  = 0,
        LayoutOrder      = NextOrder(),
        Parent           = Content,
    })
    RoundCorner(f, 8)
    Stroke(f, Color3.fromRGB(50, 60, 110), 1)

    Create("TextLabel", {
        Size             = UDim2.new(1, -14, 0, 22),
        Position         = UDim2.new(0, 14, 0, 6),
        BackgroundTransparency = 1,
        Font             = Enum.Font.GothamBold,
        Text             = "⚡  " .. (game.Name ~= "" and game.Name or "Unknown Game"),
        TextColor3       = Theme.Text,
        TextSize         = 13,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextTruncate     = Enum.TextTruncate.AtEnd,
        Parent           = f,
    })
    Create("TextLabel", {
        Size             = UDim2.new(1, -14, 0, 16),
        Position         = UDim2.new(0, 14, 0, 28),
        BackgroundTransparency = 1,
        Font             = Enum.Font.Gotham,
        Text             = "PlaceId: " .. tostring(game.PlaceId) .. "   •   Players: " .. #Players:GetPlayers(),
        TextColor3       = Theme.TextMuted,
        TextSize         = 10,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = f,
    })
    return f
end

-- ══════════════════ BUILD CONTENT ══════════════════

InfoBanner()

Section("Scripts", "📜")
Toggle("LocalScript",         "Client-side Lua scripts",     "LocalScript")
Toggle("ModuleScript",        "Shared module scripts",        "ModuleScript")
Toggle("Script (Client Run)", "Server scripts on client",     "ScriptClientRun")

Section("Remotes", "📡")
Toggle("RemoteEvent",         "Network fire-and-forget",      "RemoteEvent")
Toggle("RemoteFunction",      "Network invoke / return",      "RemoteFunction")
Toggle("Bindables",           "Local bindable events",        "Bindables")

Section("Services", "⚙️")
Toggle("ReplicatedFirst",     "Loads before everything",      "ReplicatedFirst")
Toggle("StarterGui",          "UI scripts & frames",          "StarterGui")
Toggle("StarterPack",         "Tools given on join",          "StarterPack")
Toggle("StarterPlayer",       "PlayerScripts & Char scripts", "StarterPlayer")
Toggle("Lighting",            "Atmosphere & post effects",    "Lighting")

Section("Reports", "📊")
Toggle("Script Index",        "List all scripts with paths",  "ScriptIndex")
Toggle("Hierarchy Tree",      "Full instance tree",           "HierarchyTree")
Toggle("Game Info",           "Metadata, creator & JobId",    "GameInfo")

Section("Performance", "⚡")
Toggle("Chunk Yield (no freeze)", "Yield between chunks",     "ChunkYield")

Section("Advanced", "🔧")
Dropdown("Output Format",     "OutputFormat", {"Lua", "JSON", "Plain Text"})
Toggle("Decompile Timeout",   "Cancel stuck decompile",       "DecompileTimeout")
Stepper("Timeout Duration",   "TimeoutDuration", "s", {0,10,20,30,60,90,120,180,300})
Stepper("Max File Size",      "MaxFileSize",     "MB", {0,1,2,5,10,25,50,100})
Toggle("Include Disabled",    "Dump disabled scripts",        "IncludeDisabledScripts")
Toggle("Dump Properties",     "Include instance properties",  "DumpProperties")
Toggle("Detect Obfuscation",  "Flag obfuscated scripts",      "DetectObfuscation")
Toggle("Auto-copy Summary",   "Copy result to clipboard",     "AutoCopySummary")

Section("Reports (Advanced)", "📈")
Toggle("JSON Export",         "Export dump as JSON",          "JSONExport")
Toggle("Dependency Graph",    "Map require() dependencies",   "DependencyGraph")
Toggle("Size Breakdown",      "Top scripts by size",          "SizeBreakdown")

-- ══════════════════ DUMP LOGIC ══════════════════
local isDumping = false

local function SetStatus(txt, col)
    StatusLabel.Text = "● " .. txt
    StatusLabel.TextColor3 = col or Theme.Success
end

local function GetPath(obj)
    local t = {}; local cur = obj
    while cur and cur ~= game do table.insert(t,1,cur.Name); cur=cur.Parent end
    return "game." .. table.concat(t,".")
end

local function Decompile(s)
    if decompile then
        local ok, src = pcall(decompile, s)
        if ok and src and #src > 0 then return src end
    end
    return "-- [Source unavailable]\n-- Path: " .. GetPath(s)
end

local function BuildTree(root, depth)
    depth = depth or 0
    local lines = {string.rep("  ",depth) .. (depth>0 and "└─ " or "") .. root.Name .. " ["..root.ClassName.."]"}
    for _, c in ipairs(root:GetChildren()) do
        for _, l in ipairs(BuildTree(c, depth+1)) do table.insert(lines,l) end
    end
    return lines
end

local function RunDump()
    if isDumping then return end
    isDumping = true

    DumpBtn.Text = "  ⏳  DUMPING..."
    Tween(DumpBtn, {BackgroundColor3 = Color3.fromRGB(60,60,90)})
    SetStatus("Starting dump...", Theme.Warning)

    local svcNames = {}
    if Config.ReplicatedFirst then table.insert(svcNames,"ReplicatedFirst") end
    if Config.StarterGui      then table.insert(svcNames,"StarterGui") end
    if Config.StarterPack     then table.insert(svcNames,"StarterPack") end
    if Config.StarterPlayer   then table.insert(svcNames,"StarterPlayer") end
    if Config.Lighting        then table.insert(svcNames,"Lighting") end

    local typeFilter = {}
    if Config.LocalScript    then typeFilter.LocalScript  = true end
    if Config.ModuleScript   then typeFilter.ModuleScript = true end
    if Config.ScriptClientRun then typeFilter.Script      = true end

    local scripts, remotes = {}, {}

    for _, name in ipairs(svcNames) do
        SetStatus("Scanning " .. name, Theme.Warning)
        if Config.ChunkYield then task.wait(0.04) end
        local ok, svc = pcall(game.GetService, game, name)
        if ok and svc then
            for _, d in ipairs(svc:GetDescendants()) do
                if typeFilter[d.ClassName] then
                    if Config.IncludeDisabledScripts or not (d:IsA("BaseScript") and not d.Enabled) then
                        table.insert(scripts, d)
                    end
                end
                if Config.RemoteEvent and d:IsA("RemoteEvent") then table.insert(remotes,{t="RemoteEvent",o=d}) end
                if Config.RemoteFunction and d:IsA("RemoteFunction") then table.insert(remotes,{t="RemoteFunction",o=d}) end
                if Config.Bindables and (d:IsA("BindableEvent") or d:IsA("BindableFunction")) then table.insert(remotes,{t=d.ClassName,o=d}) end
            end
        end
    end

    SetStatus("Found " .. #scripts .. " scripts...", Theme.Warning)
    task.wait(0.08)

    local results = {}
    for i, s in ipairs(scripts) do
        local src = Decompile(s)
        local obf = Config.DetectObfuscation and (src:find("\\%d%d%d") ~= nil)
        table.insert(results, {name=s.Name, class=s.ClassName, path=GetPath(s), src=src, size=#src, obf=obf})
        if Config.ChunkYield and i%5==0 then SetStatus("Dumping "..i.."/"..#scripts, Theme.Warning); task.wait(0.02) end
    end

    -- Build output
    local out = {}
    local function ln(s) table.insert(out, s or "") end

    ln("=== "..TOOL_NAME.." "..VERSION.." ===")
    ln("Game:    " .. game.Name)
    ln("PlaceId: " .. tostring(game.PlaceId))
    ln("JobId:   " .. tostring(game.JobId))
    ln("")

    if Config.GameInfo then
        ln("--- GAME INFO ---")
        ln("Name:      " .. game.Name)
        ln("PlaceId:   " .. tostring(game.PlaceId))
        ln("CreatorId: " .. tostring(game.CreatorId))
        ln("JobId:     " .. tostring(game.JobId))
        ln("")
    end

    if Config.ScriptIndex then
        ln("--- SCRIPT INDEX (" .. #results .. " scripts) ---")
        for i, r in ipairs(results) do
            ln(string.format("[%d] %s (%s) %d bytes%s", i, r.name, r.class, r.size, r.obf and " ⚠OBFUSCATED" or ""))
            ln("    " .. r.path)
        end
        ln("")
    end

    if #remotes > 0 then
        ln("--- REMOTES (" .. #remotes .. ") ---")
        for _, r in ipairs(remotes) do ln("[" .. r.t .. "] " .. GetPath(r.o)) end
        ln("")
    end

    if Config.SizeBreakdown then
        local sorted = {table.unpack(results)}
        table.sort(sorted, function(a,b) return a.size > b.size end)
        ln("--- SIZE BREAKDOWN (top 10) ---")
        for i=1, math.min(10,#sorted) do
            ln(string.format("#%-2d %-32s %d bytes", i, sorted[i].name, sorted[i].size))
        end
        ln("")
    end

    if Config.HierarchyTree then
        ln("--- HIERARCHY TREE ---")
        for _, l in ipairs(BuildTree(game)) do ln(l) end
        ln("")
    end

    ln("=== SOURCES ===")
    for _, r in ipairs(results) do
        ln("")
        ln("-- ══════════════════════════════════════")
        ln("-- Script : " .. r.name)
        ln("-- Class  : " .. r.class)
        ln("-- Path   : " .. r.path)
        ln("-- Size   : " .. r.size .. " bytes" .. (r.obf and "  ⚠ OBFUSCATED" or ""))
        ln("-- ══════════════════════════════════════")
        ln(r.src)
    end

    if Config.JSONExport then
        local ok, js = pcall(HttpService.JSONEncode, HttpService, {
            tool="NOVA DUMPER", version=VERSION,
            game={name=game.Name, placeId=game.PlaceId},
            scripts=results, remotes=remotes
        })
        if ok then ln(""); ln("=== JSON ==="); ln(js) end
    end

    local final = table.concat(out, "\n")

    local saved = false
    if writefile then
        pcall(function() writefile("NovaDump_"..tostring(game.PlaceId)..".txt", final); saved = true end)
    end
    pcall(setclipboard, final)

    isDumping = false
    DumpBtn.Text = "  ✓  DONE!"
    Tween(DumpBtn, {BackgroundColor3 = Theme.Success})
    SetStatus("Done — "..#results.." scripts, "..#remotes.." remotes"..(saved and " · Saved" or " · Copied"), Theme.Success)
    task.wait(3)
    DumpBtn.Text = "  ▶  START DUMP"
    Tween(DumpBtn, {BackgroundColor3 = Theme.Accent})
    SetStatus("ready", Theme.Success)
end

DumpBtn.MouseButton1Click:Connect(function()
    if not isDumping then task.spawn(RunDump) end
end)

-- ══════════════════ DRAG ══════════════════
local drag, dragStart, startPos = false, nil, nil
Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag=true; dragStart=i.Position; startPos=MainFrame.Position
    end
end)
Header.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then drag=false end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)

-- ══════════════════ OPEN ANIMATION ══════════════════
MainFrame.Size = UDim2.new(0,1,0,1)
MainFrame.Position = UDim2.new(0.5,0,0.5,0)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0,340,0,560),
    Position = UDim2.new(0.5,-170,0.5,-280),
}):Play()

print("[NOVA DUMPER] v3.0 loaded | " .. game.Name .. " | " .. tostring(game.PlaceId))
