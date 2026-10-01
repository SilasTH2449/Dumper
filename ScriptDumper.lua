-- ╔══════════════════════════════════════════════════╗
-- ║   NOVA DUMPER v4.0 - FPS Edition               ║
-- ║   Remote Spy + FPS Tools + Script Extractor    ║
-- ╚══════════════════════════════════════════════════╝

local VERSION = "v4.0 FPS"
local TOOL_NAME = "NOVA DUMPER"

-- ══════════════════ SERVICES ══════════════════
local Players             = game:GetService("Players")
local HttpService         = game:GetService("HttpService")
local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local RunService          = game:GetService("RunService")
local CoreGui             = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ══════════════════ CONFIG ══════════════════
local Config = {
    -- SCRIPTS
    LocalScript              = true,
    ModuleScript             = true,
    ScriptClientRun          = true,
    -- REMOTES
    RemoteEvent              = true,
    RemoteFunction           = true,
    Bindables                = false,
    -- SERVICES
    ReplicatedFirst          = true,
    StarterGui               = true,
    StarterPack              = true,
    StarterPlayer            = true,
    Lighting                 = true,
    -- REPORTS
    ScriptIndex              = true,
    HierarchyTree            = true,
    GameInfo                 = true,
    -- PERFORMANCE
    ChunkYield               = true,
    -- ADVANCED
    OutputFormat             = "Lua",
    DecompileTimeout         = false,
    TimeoutDuration          = 60,
    MaxFileSize              = 0,
    IncludeDisabledScripts   = false,
    DumpProperties           = false,
    DetectObfuscation        = true,
    AutoCopySummary          = false,
    -- REPORTS ADVANCED
    JSONExport               = true,
    DependencyGraph          = true,
    SizeBreakdown            = true,
    -- ══ REMOTE SPY ══
    RemoteSpy                = true,
    SpyRemoteEvents          = true,
    SpyRemoteFunctions       = true,
    SpyBindables             = false,
    LogArguments             = true,
    FilterDuplicates         = true,
    MaxSpyLogs               = 200,
    -- ══ FPS TOOLS ══
    WeaponDumper             = true,
    AnimationDumper          = true,
    PlayerDataSpy            = true,
    AntiCheatDetector        = true,
    HitboxInspector          = true,
    DamageRemoteFinder       = true,
    LeaderstatsLogger        = true,
    CharacterLogger          = true,
}

-- ══════════════════ THEME ══════════════════
local Theme = {
    BG           = Color3.fromRGB(13, 13, 20),
    BG2          = Color3.fromRGB(20, 20, 32),
    BG3          = Color3.fromRGB(28, 28, 42),
    Panel        = Color3.fromRGB(22, 22, 36),
    PanelHover   = Color3.fromRGB(30, 30, 48),
    Accent       = Color3.fromRGB(99, 102, 241),
    AccentHover  = Color3.fromRGB(129, 132, 255),
    AccentPurple = Color3.fromRGB(139, 92, 246),
    Success      = Color3.fromRGB(34, 197, 94),
    Warning      = Color3.fromRGB(251, 191, 36),
    Danger       = Color3.fromRGB(239, 68, 68),
    Orange       = Color3.fromRGB(249, 115, 22),
    Cyan         = Color3.fromRGB(34, 211, 238),
    Pink         = Color3.fromRGB(236, 72, 153),
    Text         = Color3.fromRGB(240, 240, 255),
    TextSub      = Color3.fromRGB(140, 140, 170),
    TextMuted    = Color3.fromRGB(80, 80, 110),
    Border       = Color3.fromRGB(40, 40, 65),
    ToggleOff    = Color3.fromRGB(45, 45, 68),
    ToggleOn     = Color3.fromRGB(99, 102, 241),
    -- Tab colors
    TabDump      = Color3.fromRGB(99, 102, 241),
    TabSpy       = Color3.fromRGB(236, 72, 153),
    TabFPS       = Color3.fromRGB(249, 115, 22),
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
    Create("UICorner", {CornerRadius = UDim.new(0, r or 8), Parent = p})
end

local function Stroke(p, c, t)
    Create("UIStroke", {Color = c or Theme.Border, Thickness = t or 1, Parent = p})
end

local function Tween(obj, props, dur, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(dur or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props):Play()
end

local function Gradient(parent, c1, c2, rot)
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, c1),
            ColorSequenceKeypoint.new(1, c2),
        }),
        Rotation = rot or 0,
        Parent = parent,
    })
end

local function ArgToString(v, depth)
    depth = depth or 0
    if depth > 2 then return "..." end
    local t = typeof(v)
    if t == "string"   then return '"' .. tostring(v):sub(1, 60) .. '"' end
    if t == "number"   then return tostring(v) end
    if t == "boolean"  then return tostring(v) end
    if t == "nil"      then return "nil" end
    if t == "Instance" then return v.ClassName .. ' "' .. v.Name .. '"' end
    if t == "Vector3"  then return string.format("V3(%.2f,%.2f,%.2f)", v.X, v.Y, v.Z) end
    if t == "CFrame"   then return string.format("CF(%.1f,%.1f,%.1f)", v.X, v.Y, v.Z) end
    if t == "table" then
        local parts = {}
        for k, val in pairs(v) do
            table.insert(parts, tostring(k) .. "=" .. ArgToString(val, depth+1))
            if #parts >= 4 then table.insert(parts, "..."); break end
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    end
    return t .. "(" .. tostring(v):sub(1, 30) .. ")"
end

-- ══════════════════ DESTROY OLD ══════════════════
pcall(function()
    local old = CoreGui:FindFirstChild("NovaDumperGui")
    if old then old:Destroy() end
end)

-- ══════════════════ ROOT GUI ══════════════════
local ScreenGui = Create("ScreenGui", {
    Name           = "NovaDumperGui",
    ResetOnSpawn   = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent         = (pcall(function() return CoreGui end) and CoreGui) or PlayerGui,
})

-- ══════════════════ MAIN WINDOW ══════════════════
local MainFrame = Create("Frame", {
    Name             = "MainFrame",
    Size             = UDim2.new(0, 360, 0, 600),
    Position         = UDim2.new(0.5, -180, 0.5, -300),
    BackgroundColor3 = Theme.BG,
    BorderSizePixel  = 0,
    ClipsDescendants = true,
    Parent           = ScreenGui,
})
RoundCorner(MainFrame, 14)
Stroke(MainFrame, Theme.Border, 1)

-- ══════════════════ HEADER ══════════════════
local Header = Create("Frame", {
    Size             = UDim2.new(1, 0, 0, 56),
    BackgroundColor3 = Theme.BG2,
    BorderSizePixel  = 0,
    Parent           = MainFrame,
})
RoundCorner(Header, 14)

-- Gradient accent line
local AccentBar = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 1, -2),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Parent = Header,
})
Gradient(AccentBar, Theme.Accent, Theme.AccentPurple)

Create("TextLabel", {
    Size = UDim2.new(0, 200, 0, 22),
    Position = UDim2.new(0, 14, 0, 8),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = TOOL_NAME,
    TextColor3 = Theme.Text,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header,
})
Create("TextLabel", {
    Size = UDim2.new(0, 220, 0, 14),
    Position = UDim2.new(0, 14, 0, 31),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = VERSION .. "  |  FPS Ready",
    TextColor3 = Theme.Orange,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header,
})
Create("TextLabel", {
    Size = UDim2.new(0, 120, 0, 14),
    Position = UDim2.new(1, -170, 0, 12),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "#" .. tostring(game.PlaceId),
    TextColor3 = Theme.TextMuted,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = Header,
})

-- Close
local CloseBtn = Create("TextButton", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -38, 0.5, -14),
    BackgroundColor3 = Color3.fromRGB(40, 40, 60),
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    Text = "✕",
    TextColor3 = Theme.TextSub,
    TextSize = 13,
    ZIndex = 10,
    Parent = Header,
})
RoundCorner(CloseBtn, 8)
CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Theme.Danger, TextColor3 = Color3.new(1,1,1)}) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(40,40,60), TextColor3 = Theme.TextSub}) end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ══════════════════ TAB BAR ══════════════════
local TabBar = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 56),
    BackgroundColor3 = Theme.BG2,
    BorderSizePixel = 0,
    Parent = MainFrame,
})

Create("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, -1),
    BackgroundColor3 = Theme.Border,
    BorderSizePixel = 0,
    Parent = TabBar,
})

local TabLayout = Create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 0),
    Parent = TabBar,
})

local tabDefs = {
    {name = "DUMP",    icon = "📦", color = Theme.TabDump,   order = 1},
    {name = "SPY",     icon = "👁",  color = Theme.TabSpy,    order = 2},
    {name = "FPS",     icon = "🎯", color = Theme.TabFPS,    order = 3},
}

local TabBtns = {}
local TabIndicators = {}

for _, def in ipairs(tabDefs) do
    local btn = Create("TextButton", {
        Size = UDim2.new(1/#tabDefs, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = def.icon .. "  " .. def.name,
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        LayoutOrder = def.order,
        Parent = TabBar,
    })
    local indicator = Create("Frame", {
        Size = UDim2.new(0.6, 0, 0, 2),
        Position = UDim2.new(0.2, 0, 1, -2),
        BackgroundColor3 = def.color,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = btn,
    })
    RoundCorner(indicator, 1)
    TabBtns[def.name] = {btn = btn, color = def.color, indicator = indicator}
end

-- ══════════════════ PAGE CONTAINER ══════════════════
local PageContainer = Create("Frame", {
    Size = UDim2.new(1, 0, 1, -150),
    Position = UDim2.new(0, 0, 0, 96),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Parent = MainFrame,
})

local function MakePage()
    local scroll = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        Parent = PageContainer,
    })
    local inner = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = scroll,
    })
    local layout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = inner,
    })
    Create("UIPadding", {
        PaddingTop    = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft   = UDim.new(0, 12),
        PaddingRight  = UDim.new(0, 12),
        Parent = inner,
    })
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
    end)
    return scroll, inner
end

local DumpPage, DumpContent = MakePage()
local SpyPage, SpyContent = MakePage()
local FPSPage, FPSContent = MakePage()

local Pages = {DUMP = DumpPage, SPY = SpyPage, FPS = FPSPage}
local currentTab = "DUMP"

local function SwitchTab(name)
    currentTab = name
    for n, page in pairs(Pages) do
        page.Visible = (n == name)
    end
    for n, t in pairs(TabBtns) do
        if n == name then
            Tween(t.btn, {TextColor3 = t.color})
            Tween(t.indicator, {BackgroundTransparency = 0})
        else
            Tween(t.btn, {TextColor3 = Theme.TextMuted})
            Tween(t.indicator, {BackgroundTransparency = 1})
        end
    end
end

for name, t in pairs(TabBtns) do
    t.btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
end

-- ══════════════════ BOTTOM BAR ══════════════════
local BottomBar = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 54),
    Position = UDim2.new(0, 0, 1, -54),
    BackgroundColor3 = Theme.BG2,
    BorderSizePixel = 0,
    Parent = MainFrame,
})
Create("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Theme.Border,
    BorderSizePixel = 0,
    Parent = BottomBar,
})

local StatusLabel = Create("TextLabel", {
    Size = UDim2.new(0.55, 0, 1, 0),
    Position = UDim2.new(0, 14, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "● ready",
    TextColor3 = Theme.Success,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = BottomBar,
})

local DumpBtn = Create("TextButton", {
    Size = UDim2.new(0, 136, 0, 36),
    Position = UDim2.new(1, -148, 0.5, -18),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    Text = "  ▶  START DUMP",
    TextColor3 = Color3.new(1,1,1),
    TextSize = 12,
    Parent = BottomBar,
})
RoundCorner(DumpBtn, 10)
Gradient(DumpBtn, Theme.Accent, Theme.AccentPurple, 90)
DumpBtn.MouseEnter:Connect(function() Tween(DumpBtn, {BackgroundColor3 = Theme.AccentHover}) end)
DumpBtn.MouseLeave:Connect(function() Tween(DumpBtn, {BackgroundColor3 = Theme.Accent}) end)

-- ══════════════════ UI COMPONENTS ══════════════════

local layoutOrder = 0
local function NextOrder() layoutOrder += 1; return layoutOrder end

local function Section(parent, title, icon, color)
    local f = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder = NextOrder(),
        Parent = parent,
    })
    local bar = Create("Frame", {
        Size = UDim2.new(0, 3, 0.55, 0),
        Position = UDim2.new(0, 0, 0.22, 0),
        BackgroundColor3 = color or Theme.Accent,
        BorderSizePixel = 0,
        Parent = f,
    })
    RoundCorner(bar, 2)
    Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = (icon or "") .. "  " .. string.upper(title),
        TextColor3 = color or Theme.TextMuted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f,
    })
    return f
end

local function Toggle(parent, label, desc, cfgKey, color)
    local isOn = Config[cfgKey]
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, desc and 46 or 40),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        LayoutOrder = NextOrder(),
        Parent = parent,
    })
    RoundCorner(row, 8)
    Stroke(row, Theme.Border, 1)

    Create("TextLabel", {
        Size = UDim2.new(1, -70, 0, 20),
        Position = UDim2.new(0, 14, 0, desc and 6 or 10),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = label,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    if desc then
        Create("TextLabel", {
            Size = UDim2.new(1, -70, 0, 14),
            Position = UDim2.new(0, 14, 0, 27),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = desc,
            TextColor3 = Theme.TextMuted,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })
    end

    local onColor = color or Theme.ToggleOn
    local track = Create("Frame", {
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -54, 0.5, -12),
        BackgroundColor3 = isOn and onColor or Theme.ToggleOff,
        BorderSizePixel = 0,
        Parent = row,
    })
    RoundCorner(track, 12)

    local knob = Create("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = isOn and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0,
        Parent = track,
    })
    RoundCorner(knob, 9)

    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 5,
        Parent = row,
    })

    local function set(val)
        Config[cfgKey] = val; isOn = val
        Tween(knob, {Position = val and UDim2.new(0,23,0.5,-9) or UDim2.new(0,3,0.5,-9)})
        Tween(track, {BackgroundColor3 = val and onColor or Theme.ToggleOff})
    end

    btn.MouseEnter:Connect(function() Tween(row, {BackgroundColor3 = Theme.PanelHover}) end)
    btn.MouseLeave:Connect(function() Tween(row, {BackgroundColor3 = Theme.Panel}) end)
    btn.MouseButton1Click:Connect(function() set(not isOn) end)
    return row
end

local function Stepper(parent, label, cfgKey, unit, vals)
    local idx = 1
    for i, v in ipairs(vals) do if v == Config[cfgKey] then idx = i break end end

    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        LayoutOrder = NextOrder(),
        Parent = parent,
    })
    RoundCorner(row, 8); Stroke(row, Theme.Border, 1)

    Create("TextLabel", {
        Size = UDim2.new(0.55, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = label, TextColor3 = Theme.Text,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local ctrl = Create("Frame", {
        Size = UDim2.new(0, 110, 0, 28),
        Position = UDim2.new(1, -120, 0.5, -14),
        BackgroundColor3 = Theme.BG3, BorderSizePixel = 0, Parent = row,
    })
    RoundCorner(ctrl, 7); Stroke(ctrl, Theme.Border, 1)

    Create("TextButton", {
        Size = UDim2.new(0,28,1,0), BackgroundTransparency=1,
        Font=Enum.Font.GothamBold, Text="−", TextColor3=Theme.TextSub, TextSize=16, Parent=ctrl,
    }).MouseButton1Click:Connect(function() idx=math.max(1,idx-1); Config[cfgKey]=vals[idx] end)

    local vl = Create("TextLabel", {
        Size=UDim2.new(1,-56,1,0), Position=UDim2.new(0,28,0,0),
        BackgroundTransparency=1, Font=Enum.Font.GothamBold,
        Text="", TextColor3=Theme.Accent, TextSize=12, Parent=ctrl,
    })

    Create("TextButton", {
        Size=UDim2.new(0,28,1,0), Position=UDim2.new(1,-28,0,0),
        BackgroundTransparency=1, Font=Enum.Font.GothamBold,
        Text="+", TextColor3=Theme.TextSub, TextSize=16, Parent=ctrl,
    }).MouseButton1Click:Connect(function() idx=math.min(#vals,idx+1); Config[cfgKey]=vals[idx] end)

    local function refresh()
        local v=vals[idx]; Config[cfgKey]=v
        vl.Text = v==0 and "OFF" or (tostring(v)..(unit or ""))
        vl.TextColor3 = v==0 and Theme.TextMuted or Theme.Accent
    end
    refresh()
    return row
end

local function Dropdown(parent, label, cfgKey, opts)
    local cur = Config[cfgKey]
    local row = Create("Frame", {
        Size=UDim2.new(1,0,0,40), BackgroundColor3=Theme.Panel,
        BorderSizePixel=0, ClipsDescendants=false,
        LayoutOrder=NextOrder(), ZIndex=20, Parent=parent,
    })
    RoundCorner(row,8); Stroke(row,Theme.Border,1)
    Create("TextLabel", {
        Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1, Font=Enum.Font.GothamSemibold,
        Text=label, TextColor3=Theme.Text, TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=20, Parent=row,
    })
    local btn=Create("TextButton", {
        Size=UDim2.new(0,90,0,26), Position=UDim2.new(1,-100,0.5,-13),
        BackgroundColor3=Theme.BG3, BorderSizePixel=0,
        Font=Enum.Font.GothamSemibold, Text=cur.." ▾",
        TextColor3=Theme.Accent, TextSize=12, ZIndex=20, Parent=row,
    })
    RoundCorner(btn,7); Stroke(btn,Theme.Border,1)
    local popup=Create("Frame", {
        Size=UDim2.new(0,100,0,#opts*32),
        Position=UDim2.new(1,-100,1,4),
        BackgroundColor3=Theme.BG2, BorderSizePixel=0,
        Visible=false, ZIndex=50, Parent=row,
    })
    RoundCorner(popup,8); Stroke(popup,Theme.Border,1)
    Create("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Parent=popup})
    for i,opt in ipairs(opts) do
        local ob=Create("TextButton", {
            Size=UDim2.new(1,0,0,32), BackgroundTransparency=1,
            Font=Enum.Font.GothamSemibold, Text=opt,
            TextColor3=opt==cur and Theme.Accent or Theme.TextSub,
            TextSize=12, ZIndex=50, LayoutOrder=i, Parent=popup,
        })
        ob.MouseButton1Click:Connect(function()
            cur=opt; Config[cfgKey]=opt; btn.Text=opt.." ▾"; popup.Visible=false
            for _,c in ipairs(popup:GetChildren()) do
                if c:IsA("TextButton") then c.TextColor3=(c.Text==opt) and Theme.Accent or Theme.TextSub end
            end
        end)
    end
    local open=false
    btn.MouseButton1Click:Connect(function()
        open=not open; popup.Visible=open; btn.Text=cur..(open and " ▴" or " ▾")
    end)
    return row
end

local function InfoBanner(parent)
    local f=Create("Frame", {
        Size=UDim2.new(1,0,0,50), BackgroundColor3=Color3.fromRGB(18,22,42),
        BorderSizePixel=0, LayoutOrder=NextOrder(), Parent=parent,
    })
    RoundCorner(f,8); Stroke(f,Color3.fromRGB(50,60,110),1)
    Create("TextLabel", {
        Size=UDim2.new(1,-14,0,22), Position=UDim2.new(0,14,0,6),
        BackgroundTransparency=1, Font=Enum.Font.GothamBold,
        Text="⚡  "..(game.Name~="" and game.Name or "Unknown Game"),
        TextColor3=Theme.Text, TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd, Parent=f,
    })
    Create("TextLabel", {
        Size=UDim2.new(1,-14,0,16), Position=UDim2.new(0,14,0,28),
        BackgroundTransparency=1, Font=Enum.Font.Gotham,
        Text="PlaceId: "..tostring(game.PlaceId).."   •   Players: "..#Players:GetPlayers(),
        TextColor3=Theme.TextMuted, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=f,
    })
    return f
end

-- Action Button (เพื่อ trigger FPS tools)
local function ActionButton(parent, label, icon, color, callback)
    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = color or Theme.Accent,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = (icon or "") .. "  " .. label,
        TextColor3 = Color3.new(1,1,1),
        TextSize = 13,
        LayoutOrder = NextOrder(),
        Parent = parent,
    })
    RoundCorner(btn, 8)
    Gradient(btn, color or Theme.Accent, (color or Theme.Accent):Lerp(Color3.new(0,0,0), 0.3), 90)
    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = (color or Theme.Accent):Lerp(Color3.new(1,1,1),0.1)}) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = color or Theme.Accent}) end)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
    return btn
end

-- ══════════════════ BUILD: DUMP PAGE ══════════════════
InfoBanner(DumpContent)
Section(DumpContent, "Scripts", "📜")
Toggle(DumpContent, "LocalScript",          "Client-side Lua scripts",      "LocalScript")
Toggle(DumpContent, "ModuleScript",         "Shared module scripts",         "ModuleScript")
Toggle(DumpContent, "Script (Client Run)",  "Server scripts on client",      "ScriptClientRun")

Section(DumpContent, "Remotes", "📡")
Toggle(DumpContent, "RemoteEvent",          "Network fire-and-forget",       "RemoteEvent")
Toggle(DumpContent, "RemoteFunction",       "Network invoke / return",       "RemoteFunction")
Toggle(DumpContent, "Bindables",            "Local bindable events",         "Bindables")

Section(DumpContent, "Services", "⚙️")
Toggle(DumpContent, "ReplicatedFirst",      "Loads before everything",       "ReplicatedFirst")
Toggle(DumpContent, "StarterGui",           "UI scripts & frames",           "StarterGui")
Toggle(DumpContent, "StarterPack",          "Tools given on join",           "StarterPack")
Toggle(DumpContent, "StarterPlayer",        "PlayerScripts & Char scripts",  "StarterPlayer")
Toggle(DumpContent, "Lighting",             "Atmosphere & post effects",     "Lighting")

Section(DumpContent, "Reports", "📊")
Toggle(DumpContent, "Script Index",         "List all scripts with paths",   "ScriptIndex")
Toggle(DumpContent, "Hierarchy Tree",       "Full instance tree",            "HierarchyTree")
Toggle(DumpContent, "Game Info",            "Metadata, creator & JobId",     "GameInfo")

Section(DumpContent, "Performance", "⚡")
Toggle(DumpContent, "Chunk Yield (no freeze)", "Yield between chunks",       "ChunkYield")

Section(DumpContent, "Advanced", "🔧")
Dropdown(DumpContent, "Output Format",      "OutputFormat", {"Lua", "JSON", "Plain Text"})
Toggle(DumpContent, "Decompile Timeout",    "Cancel stuck decompile",        "DecompileTimeout")
Stepper(DumpContent, "Timeout Duration",    "TimeoutDuration", "s", {0,10,20,30,60,90,120,180,300})
Stepper(DumpContent, "Max File Size",       "MaxFileSize", "MB", {0,1,2,5,10,25,50,100})
Toggle(DumpContent, "Include Disabled",     "Dump disabled scripts too",     "IncludeDisabledScripts")
Toggle(DumpContent, "Dump Properties",      "Include instance properties",   "DumpProperties")
Toggle(DumpContent, "Detect Obfuscation",   "Flag obfuscated scripts",       "DetectObfuscation")
Toggle(DumpContent, "Auto-copy Summary",    "Copy result to clipboard",      "AutoCopySummary")

Section(DumpContent, "Reports (Advanced)", "📈")
Toggle(DumpContent, "JSON Export",          "Export dump as JSON",           "JSONExport")
Toggle(DumpContent, "Dependency Graph",     "Map require() dependencies",    "DependencyGraph")
Toggle(DumpContent, "Size Breakdown",       "Top scripts by size",           "SizeBreakdown")

-- ══════════════════ BUILD: SPY PAGE ══════════════════

-- Spy log display
local spyLogs = {}
local spyConnections = {}
local spyActive = false

Section(SpyContent, "Remote Spy", "👁", Theme.Pink)
Toggle(SpyContent, "Spy RemoteEvents",     "Log all fired events",           "SpyRemoteEvents",     Theme.Pink)
Toggle(SpyContent, "Spy RemoteFunctions",  "Log invoke calls & responses",   "SpyRemoteFunctions",  Theme.Pink)
Toggle(SpyContent, "Spy Bindables",        "Log local bindable calls",        "SpyBindables",        Theme.Pink)
Toggle(SpyContent, "Log Arguments",        "Show argument values",            "LogArguments",        Theme.Pink)
Toggle(SpyContent, "Filter Duplicates",    "Hide repeated identical calls",   "FilterDuplicates",    Theme.Pink)
Stepper(SpyContent, "Max Log Lines",       "MaxSpyLogs", "", {50,100,200,500,1000})

-- Spy Controls
local SpyStartBtn = ActionButton(SpyContent, "START SPY", "👁", Theme.Pink, nil)
local SpyClearBtn = ActionButton(SpyContent, "CLEAR LOG", "🗑", Color3.fromRGB(60,60,80), nil)
local SpySaveBtn  = ActionButton(SpyContent, "SAVE LOG",  "💾", Color3.fromRGB(34,100,80), nil)

-- Log box
Section(SpyContent, "Live Log", "📋", Theme.Pink)
local LogBox = Create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 0, 220),
    BackgroundColor3 = Color3.fromRGB(10, 10, 18),
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Theme.Pink,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    LayoutOrder = NextOrder(),
    Parent = SpyContent,
})
RoundCorner(LogBox, 8); Stroke(LogBox, Theme.Border, 1)

local LogInner = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = LogBox,
})
local LogLayout = Create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 1),
    Parent = LogInner,
})
Create("UIPadding", {
    PaddingTop=UDim.new(0,6), PaddingBottom=UDim.new(0,6),
    PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8),
    Parent=LogInner,
})
LogLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    LogBox.CanvasSize = UDim2.new(0,0,0, LogLayout.AbsoluteContentSize.Y+16)
    LogBox.CanvasPosition = Vector2.new(0, math.huge) -- auto scroll to bottom
end)

local logCount = 0
local lastLog = ""

local function AddLog(text, color)
    if Config.FilterDuplicates and text == lastLog then return end
    lastLog = text
    logCount += 1
    if logCount > Config.MaxSpyLogs then
        local children = LogInner:GetChildren()
        for _, c in ipairs(children) do
            if c:IsA("TextLabel") then c:Destroy(); logCount -= 1; break end
        end
    end
    local lbl = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        Text = text,
        TextColor3 = color or Theme.TextSub,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        LayoutOrder = logCount,
        Parent = LogInner,
    })
end

local function StartSpy()
    if spyActive then return end
    spyActive = true
    spyLogs = {}
    AddLog("[ SPY STARTED ]", Theme.Pink)

    for _, obj in ipairs(game:GetDescendants()) do
        if Config.SpyRemoteEvents and obj:IsA("RemoteEvent") then
            local conn = obj.OnClientEvent:Connect(function(...)
                local args = Config.LogArguments and table.pack(...) or nil
                local txt = "[EVENT] " .. obj.Name
                if args then
                    local parts = {}
                    for i=1, args.n do table.insert(parts, ArgToString(args[i])) end
                    txt = txt .. "  ← " .. table.concat(parts, ", ")
                end
                table.insert(spyLogs, txt)
                AddLog(txt, Theme.Cyan)
            end)
            table.insert(spyConnections, conn)
        end

        if Config.SpyRemoteFunctions and obj:IsA("RemoteFunction") then
            local origCallback = obj.OnClientInvoke
            -- Hook invoke calls from server
            obj.OnClientInvoke = function(...)
                local args = Config.LogArguments and table.pack(...) or nil
                local txt = "[FUNC] " .. obj.Name
                if args then
                    local parts = {}
                    for i=1, args.n do table.insert(parts, ArgToString(args[i])) end
                    txt = txt .. "  → " .. table.concat(parts, ", ")
                end
                table.insert(spyLogs, txt)
                AddLog(txt, Theme.Warning)
                if origCallback then return origCallback(...) end
            end
        end

        if Config.SpyBindables and obj:IsA("BindableEvent") then
            local conn = obj.Event:Connect(function(...)
                local txt = "[BIND] " .. obj.Name
                table.insert(spyLogs, txt)
                AddLog(txt, Theme.TextSub)
            end)
            table.insert(spyConnections, conn)
        end
    end

    SpyStartBtn.Text = "  🔴  SPY ACTIVE"
    Tween(SpyStartBtn, {BackgroundColor3 = Theme.Danger})
    spyActive = true
end

local function StopSpy()
    for _, c in ipairs(spyConnections) do pcall(function() c:Disconnect() end) end
    spyConnections = {}
    spyActive = false
    AddLog("[ SPY STOPPED ]", Theme.Danger)
    SpyStartBtn.Text = "  👁  START SPY"
    Tween(SpyStartBtn, {BackgroundColor3 = Theme.Pink})
end

SpyStartBtn.MouseButton1Click:Connect(function()
    if spyActive then StopSpy() else StartSpy() end
end)

SpyClearBtn.MouseButton1Click:Connect(function()
    for _, c in ipairs(LogInner:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    spyLogs = {}; logCount = 0; lastLog = ""
end)

SpySaveBtn.MouseButton1Click:Connect(function()
    local out = table.concat(spyLogs, "\n")
    if writefile then pcall(function() writefile("NovaSpy_"..tostring(game.PlaceId)..".lua", out) end) end
    pcall(setclipboard, out)
    AddLog("[ LOG SAVED/COPIED ]", Theme.Success)
end)

-- ══════════════════ BUILD: FPS PAGE ══════════════════

Section(FPSContent, "FPS Tools", "🎯", Theme.Orange)

-- Weapon Dumper
Toggle(FPSContent, "Weapon Dumper",       "Dump weapons & tool stats",       "WeaponDumper",      Theme.Orange)
Toggle(FPSContent, "Animation Dumper",    "Find all AnimationId in game",     "AnimationDumper",   Theme.Orange)
Toggle(FPSContent, "Damage Remote Finder","Find remotes likely related to dmg","DamageRemoteFinder",Theme.Orange)

Section(FPSContent, "Player Info", "👤", Theme.Cyan)
Toggle(FPSContent, "Player Data Spy",     "Dump leaderstats & attributes",    "PlayerDataSpy",     Theme.Cyan)
Toggle(FPSContent, "Leaderstats Logger",  "Log stat changes over time",       "LeaderstatsLogger", Theme.Cyan)
Toggle(FPSContent, "Character Logger",    "Log character/hitbox info",        "CharacterLogger",   Theme.Cyan)
Toggle(FPSContent, "Hitbox Inspector",    "Measure hitbox sizes",             "HitboxInspector",   Theme.Cyan)

Section(FPSContent, "Security", "🛡", Theme.Danger)
Toggle(FPSContent, "Anti-Cheat Detector", "Detect AC patterns in scripts",   "AntiCheatDetector", Theme.Danger)

ActionButton(FPSContent, "RUN FPS SCAN", "🎯", Theme.Orange, function()
    SetStatus("Running FPS scan...", Theme.Warning)
    task.spawn(function()
        local results = {}
        local function ln(s) table.insert(results, s or "") end

        ln("=== NOVA DUMPER FPS SCAN ===")
        ln("Game: " .. game.Name .. "  |  " .. tostring(game.PlaceId))
        ln("")

        -- Weapon Dumper
        if Config.WeaponDumper then
            ln("--- WEAPONS & TOOLS ---")
            local toolSources = {
                game:GetService("StarterPack"),
                LocalPlayer.Backpack,
                LocalPlayer.Character,
            }
            for _, src in ipairs(toolSources) do
                pcall(function()
                    for _, tool in ipairs(src:GetDescendants()) do
                        if tool:IsA("Tool") then
                            ln("[TOOL] " .. tool.Name)
                            -- Try read damage / config values
                            for _, v in ipairs(tool:GetDescendants()) do
                                if v:IsA("NumberValue") or v:IsA("IntValue") then
                                    ln("  [VALUE] " .. v.Name .. " = " .. tostring(v.Value))
                                end
                                if v:IsA("ModuleScript") then
                                    ln("  [MODULE] " .. v.Name)
                                end
                            end
                        end
                    end
                end)
            end
            ln("")
        end

        -- Animation Dumper
        if Config.AnimationDumper then
            ln("--- ANIMATIONS ---")
            local seen = {}
            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("Animation") and not seen[obj.AnimationId] then
                    seen[obj.AnimationId] = true
                    ln("[ANIM] " .. obj.Name .. "  →  " .. obj.AnimationId)
                end
            end
            ln("")
        end

        -- Damage Remote Finder
        if Config.DamageRemoteFinder then
            ln("--- DAMAGE-RELATED REMOTES ---")
            local dmgKeywords = {"damage","dmg","hit","hurt","kill","shoot","fire","bullet","attack","health","hp"}
            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local lower = obj.Name:lower()
                    for _, kw in ipairs(dmgKeywords) do
                        if lower:find(kw) then
                            ln("[" .. obj.ClassName .. "] " .. obj.Name .. "  @  " .. obj:GetFullName())
                            break
                        end
                    end
                end
            end
            ln("")
        end

        -- Player Data Spy
        if Config.PlayerDataSpy then
            ln("--- PLAYER DATA / LEADERSTATS ---")
            for _, plr in ipairs(Players:GetPlayers()) do
                ln("[PLAYER] " .. plr.Name .. " (" .. tostring(plr.UserId) .. ")")
                -- Leaderstats
                local ls = plr:FindFirstChild("leaderstats")
                if ls then
                    for _, v in ipairs(ls:GetChildren()) do
                        ln("  " .. v.Name .. " = " .. tostring(v.Value))
                    end
                end
                -- Attributes
                local attrs = plr:GetAttributes()
                for k, v in pairs(attrs) do
                    ln("  [attr] " .. k .. " = " .. tostring(v))
                end
                -- Character hitbox
                if Config.HitboxInspector and plr.Character then
                    local char = plr.Character
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hrp then ln("  HRP Size: " .. tostring(hrp.Size)) end
                    if hum then
                        ln("  Health: " .. tostring(hum.Health) .. "/" .. tostring(hum.MaxHealth))
                        ln("  WalkSpeed: " .. tostring(hum.WalkSpeed))
                        ln("  JumpPower: " .. tostring(hum.JumpPower))
                    end
                end
            end
            ln("")
        end

        -- Anti-Cheat Detector
        if Config.AntiCheatDetector then
            ln("--- ANTI-CHEAT DETECTION ---")
            local acKeywords = {"anticheat","anti_cheat","ac","cheatdetect","sanity","validate","verify","check","ban","kick"}
            local acFound = {}
            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("LocalScript") or obj:IsA("ModuleScript") or obj:IsA("Script") then
                    local lower = obj.Name:lower()
                    for _, kw in ipairs(acKeywords) do
                        if lower:find(kw) then
                            table.insert(acFound, "[AC?] " .. obj.ClassName .. " '" .. obj.Name .. "'  @  " .. obj:GetFullName())
                            break
                        end
                    end
                end
            end
            if #acFound > 0 then
                for _, l in ipairs(acFound) do ln(l) end
            else
                ln("No obvious AC scripts found by name.")
            end
            ln("")
        end

        local final = table.concat(results, "\n")
        if writefile then pcall(function() writefile("NovaFPS_"..tostring(game.PlaceId)..".lua", final) end) end
        pcall(setclipboard, final)

        SetStatus("FPS scan done! Saved/copied ✓", Theme.Success)
        task.wait(3)
        SetStatus("ready", Theme.Success)
    end)
end)

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
    local lines = {string.rep("  ",depth)..(depth>0 and "└─ " or "")..root.Name.." ["..root.ClassName.."]"}
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
    SetStatus("Starting...", Theme.Warning)

    local svcNames = {}
    if Config.ReplicatedFirst then table.insert(svcNames,"ReplicatedFirst") end
    if Config.StarterGui      then table.insert(svcNames,"StarterGui") end
    if Config.StarterPack     then table.insert(svcNames,"StarterPack") end
    if Config.StarterPlayer   then table.insert(svcNames,"StarterPlayer") end
    if Config.Lighting        then table.insert(svcNames,"Lighting") end

    local typeFilter = {}
    if Config.LocalScript     then typeFilter.LocalScript  = true end
    if Config.ModuleScript    then typeFilter.ModuleScript = true end
    if Config.ScriptClientRun then typeFilter.Script       = true end

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
                if Config.RemoteEvent    and d:IsA("RemoteEvent")    then table.insert(remotes,{t="RemoteEvent",    o=d}) end
                if Config.RemoteFunction and d:IsA("RemoteFunction")  then table.insert(remotes,{t="RemoteFunction", o=d}) end
                if Config.Bindables and (d:IsA("BindableEvent") or d:IsA("BindableFunction")) then table.insert(remotes,{t=d.ClassName,o=d}) end
            end
        end
    end

    SetStatus("Found "..#scripts.." scripts...", Theme.Warning)
    task.wait(0.05)

    local results = {}
    for i, s in ipairs(scripts) do
        local src = Decompile(s)
        local obf = Config.DetectObfuscation and (src:find("\\%d%d%d") ~= nil)
        table.insert(results, {name=s.Name, class=s.ClassName, path=GetPath(s), src=src, size=#src, obf=obf})
        if Config.ChunkYield and i%5==0 then SetStatus("Dumping "..i.."/"..#scripts, Theme.Warning); task.wait(0.02) end
    end

    local out = {}
    local function ln(s) table.insert(out, s or "") end

    ln("=== "..TOOL_NAME.." "..VERSION.." ===")
    ln("Game: "..game.Name.."  |  PlaceId: "..tostring(game.PlaceId))
    ln("")

    if Config.GameInfo then
        ln("--- GAME INFO ---")
        ln("Name: "..game.Name)
        ln("PlaceId: "..tostring(game.PlaceId))
        ln("CreatorId: "..tostring(game.CreatorId))
        ln("JobId: "..tostring(game.JobId))
        ln("")
    end

    if Config.ScriptIndex then
        ln("--- SCRIPT INDEX ("..#results..") ---")
        for i,r in ipairs(results) do
            ln(string.format("[%d] %s (%s) %d bytes%s", i, r.name, r.class, r.size, r.obf and " ⚠OBFUSC" or ""))
            ln("    "..r.path)
        end
        ln("")
    end

    if #remotes > 0 then
        ln("--- REMOTES ("..#remotes..") ---")
        for _,r in ipairs(remotes) do ln("["..r.t.."] "..GetPath(r.o)) end
        ln("")
    end

    if Config.SizeBreakdown then
        local s2={table.unpack(results)}
        table.sort(s2, function(a,b) return a.size>b.size end)
        ln("--- SIZE BREAKDOWN (top 10) ---")
        for i=1,math.min(10,#s2) do ln(string.format("#%-2d %-30s %d bytes",i,s2[i].name,s2[i].size)) end
        ln("")
    end

    if Config.HierarchyTree then
        ln("--- HIERARCHY TREE ---")
        for _,l in ipairs(BuildTree(game)) do ln(l) end
        ln("")
    end

    ln("=== SOURCES ===")
    for _,r in ipairs(results) do
        ln(""); ln("-- ════════════════════════════════")
        ln("-- Script : "..r.name); ln("-- Class  : "..r.class)
        ln("-- Path   : "..r.path); ln("-- Size   : "..r.size.." bytes"..(r.obf and "  ⚠" or ""))
        ln("-- ════════════════════════════════"); ln(r.src)
    end

    if Config.JSONExport then
        local ok, js = pcall(HttpService.JSONEncode, HttpService, {
            tool=TOOL_NAME, version=VERSION,
            game={name=game.Name, placeId=game.PlaceId},
            scripts=results, remotes=remotes
        })
        if ok then ln(""); ln("=== JSON ==="); ln(js) end
    end

    local final = table.concat(out, "\n")
    local saved = false
    if writefile then
        pcall(function() writefile("NovaDump_"..tostring(game.PlaceId)..".lua", final); saved = true end)
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
TweenService:Create(MainFrame,
    TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Size=UDim2.new(0,360,0,600), Position=UDim2.new(0.5,-180,0.5,-300)}
):Play()

-- Default tab
SwitchTab("DUMP")

print("[NOVA DUMPER] "..VERSION.." loaded | "..game.Name.." | "..tostring(game.PlaceId))
