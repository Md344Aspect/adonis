--[=[
    ╔══════════════════════════════════════════════════════╗
    ║                  novoline · library                  ║
    ║         pixel-perfect · theme-aware · v2            ║
    ╚══════════════════════════════════════════════════════╝

    QUICK REFERENCE
    ───────────────
    local Win = Library:CreateWindow({
        Title   = "novoline",
        Tabs    = {"combat","movement","visuals","settings"},
        Keybind = Enum.KeyCode.RightShift,   -- toggle visibility
        Theme   = "Default",                 -- or "Dark","Light","Blood","Ocean","Mint"
    })

    Win:SetTheme("Blood")                    -- swap theme at runtime

    local sec = Win:CreateSection("combat","Left","aimbot")
    -- sec.Container  → parent your elements here
    -- sec.Title      → TextLabel
    -- sec.Frame      → the section Frame itself

    Win:SetWatermark("novoline.priv | 60fps")
    Win:Destroy()
]=]

local Library = {}
Library.__index = Library

-- ─────────────────────────────────────────────────────────────────────────────
-- Services
-- ─────────────────────────────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ─────────────────────────────────────────────────────────────────────────────
-- Font  (single source of truth)
-- ─────────────────────────────────────────────────────────────────────────────
local FONT = Font.new(
    [[rbxasset://fonts/families/SourceCodePro.json]],
    Enum.FontWeight.Regular,
    Enum.FontStyle.Normal
)

-- ─────────────────────────────────────────────────────────────────────────────
-- Themes
-- ─────────────────────────────────────────────────────────────────────────────
--[[
    Every color in the UI is driven by one of these keys.
    To add a new theme: copy "Default" and change the values.

    Key             Used on
    ───────────     ──────────────────────────────────────────────────
    BorderOuter     layer1 bg, watermark outer bg        (5 px ring)
    Background      __main bg, __tabs bg, __Contentsec   (main fill)
    BorderInner     __main border, __tabs border, section border
    TabInactive     inactive tab button background
    TabActive       active  tab button background
    TextPrimary     active tab text, section titles, watermark label
    TextMuted       inactive tab text
    WatermarkBG     _waterMarkMain background
    Accent          active-tab indicator stripe (1 px top border trick)
                    — set same as TabActive for a flat look,
                      or a vivid color for a colored stripe.
]]
local Themes = {
    Default = {
        BorderOuter  = Color3.fromRGB(41,  41,  41 ),
        Background   = Color3.fromRGB(27,  27,  27 ),
        BorderInner  = Color3.fromRGB(81,  81,  81 ),
        TabInactive  = Color3.fromRGB(32,  32,  32 ),
        TabActive    = Color3.fromRGB(42,  42,  42 ),
        TextPrimary  = Color3.fromRGB(255, 255, 255),
        TextMuted    = Color3.fromRGB(160, 160, 160),
        WatermarkBG  = Color3.fromRGB(31,  31,  31 ),
        Accent       = Color3.fromRGB(42,  42,  42 ),   -- flat
    },
    Dark = {
        BorderOuter  = Color3.fromRGB(18,  18,  18 ),
        Background   = Color3.fromRGB(10,  10,  10 ),
        BorderInner  = Color3.fromRGB(50,  50,  50 ),
        TabInactive  = Color3.fromRGB(15,  15,  15 ),
        TabActive    = Color3.fromRGB(28,  28,  28 ),
        TextPrimary  = Color3.fromRGB(230, 230, 230),
        TextMuted    = Color3.fromRGB(110, 110, 110),
        WatermarkBG  = Color3.fromRGB(12,  12,  12 ),
        Accent       = Color3.fromRGB(28,  28,  28 ),
    },
    Light = {
        BorderOuter  = Color3.fromRGB(190, 190, 190),
        Background   = Color3.fromRGB(235, 235, 235),
        BorderInner  = Color3.fromRGB(150, 150, 150),
        TabInactive  = Color3.fromRGB(215, 215, 215),
        TabActive    = Color3.fromRGB(200, 200, 200),
        TextPrimary  = Color3.fromRGB(20,  20,  20 ),
        TextMuted    = Color3.fromRGB(100, 100, 100),
        WatermarkBG  = Color3.fromRGB(210, 210, 210),
        Accent       = Color3.fromRGB(200, 200, 200),
    },
    Blood = {
        BorderOuter  = Color3.fromRGB(60,  10,  10 ),
        Background   = Color3.fromRGB(22,  8,   8  ),
        BorderInner  = Color3.fromRGB(110, 30,  30 ),
        TabInactive  = Color3.fromRGB(35,  12,  12 ),
        TabActive    = Color3.fromRGB(55,  18,  18 ),
        TextPrimary  = Color3.fromRGB(255, 200, 200),
        TextMuted    = Color3.fromRGB(160, 90,  90 ),
        WatermarkBG  = Color3.fromRGB(30,  10,  10 ),
        Accent       = Color3.fromRGB(180, 30,  30 ),
    },
    Ocean = {
        BorderOuter  = Color3.fromRGB(10,  30,  55 ),
        Background   = Color3.fromRGB(8,   20,  40 ),
        BorderInner  = Color3.fromRGB(30,  70,  120),
        TabInactive  = Color3.fromRGB(12,  28,  52 ),
        TabActive    = Color3.fromRGB(18,  45,  80 ),
        TextPrimary  = Color3.fromRGB(190, 220, 255),
        TextMuted    = Color3.fromRGB(90,  130, 175),
        WatermarkBG  = Color3.fromRGB(10,  24,  46 ),
        Accent       = Color3.fromRGB(30,  100, 200),
    },
    Mint = {
        BorderOuter  = Color3.fromRGB(15,  45,  35 ),
        Background   = Color3.fromRGB(10,  28,  22 ),
        BorderInner  = Color3.fromRGB(35,  90,  70 ),
        TabInactive  = Color3.fromRGB(14,  38,  30 ),
        TabActive    = Color3.fromRGB(22,  60,  48 ),
        TextPrimary  = Color3.fromRGB(190, 255, 225),
        TextMuted    = Color3.fromRGB(90,  160, 130),
        WatermarkBG  = Color3.fromRGB(12,  32,  25 ),
        Accent       = Color3.fromRGB(40,  200, 130),
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Internal helpers
-- ─────────────────────────────────────────────────────────────────────────────

-- Create an instance, set properties, optionally parent it.
local function Create(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

-- Smooth tween helper (short internal tweens for theme swaps).
local TWEEN_INFO = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function Tween(inst, props)
    TweenService:Create(inst, TWEEN_INFO, props):Play()
end

--[[
    MakeDraggable(target, handle)
    target  – the GuiObject that physically moves
    handle  – the GuiObject the user must click-drag on
    Both must be GuiObjects with InputBegan available.
    The handle needs Active = true (or be a Button) for InputBegan to fire.
]]
local function MakeDraggable(target, handle)
    local dragging = false
    local origin, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            origin    = input.Position
            startPos  = target.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - origin
            target.Position = UDim2.new(
                startPos.X.Scale,  startPos.X.Offset + d.X,
                startPos.Y.Scale,  startPos.Y.Offset + d.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Library:CreateWindow
-- ─────────────────────────────────────────────────────────────────────────────
function Library:CreateWindow(config)
    config = config or {}

    local tabs         = config.Tabs    or {"combat","movement","visuals","settings"}
    local keybind      = config.Keybind or Enum.KeyCode.RightShift
    local themeName    = config.Theme   or "Default"
    local theme        = Themes[themeName] or Themes.Default

    -- ── All themed objects registered here so SetTheme can repaint them ────────
    -- Each entry: { instance, propertyName, themeKey }
    local themedObjects = {}

    local function T(inst, prop, key)
        themedObjects[#themedObjects + 1] = { inst, prop, key }
        inst[prop] = theme[key]
    end

    -- ─────────────────────────────────────────────────────────────────────────
    -- ScreenGui
    -- ─────────────────────────────────────────────────────────────────────────
    local screenGui = Create("ScreenGui", {
        Name           = "_1",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn   = false,
    }, PlayerGui)

    -- ─────────────────────────────────────────────────────────────────────────
    -- WINDOW
    -- ─────────────────────────────────────────────────────────────────────────
    --  Outer ring  __layer1  850 × 500
    --  5 px border on all sides → inner frame 840 × 490 centered inside
    -- ─────────────────────────────────────────────────────────────────────────
    local layer1 = Create("Frame", {
        Name            = "__layer1",
        ZIndex          = 5,
        BorderSizePixel = 0,
        Size            = UDim2.fromOffset(850, 500),
        Position        = UDim2.new(0.20685, 0, 0.19101, 0),
        BorderColor3    = Color3.fromRGB(0, 0, 0),
        LayoutOrder     = 1,
    }, screenGui)
    T(layer1, "BackgroundColor3", "BorderOuter")

    -- ─────────────────────────────────────────────────────────────────────────
    --  Inner main  __main  840 × 490  (centered in layer1)
    -- ─────────────────────────────────────────────────────────────────────────
    local main = Create("Frame", {
        Name        = "__main",
        ZIndex      = 6,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size        = UDim2.fromOffset(840, 490),
        Position    = UDim2.new(0.5, 0, 0.5, 0),
        LayoutOrder = 1,
    }, layer1)
    T(main, "BackgroundColor3", "Background")
    T(main, "BorderColor3",     "BorderInner")

    -- Window drag — user drags __main, __layer1 moves.
    -- Sections are children of __main so they travel with it, never drag alone.
    MakeDraggable(layer1, main)

    -- ─────────────────────────────────────────────────────────────────────────
    --  Tabs bar  __tabs  830 × 40
    --  Sits 5 px from top inside __main (840 wide, so 5 px each side = 830).
    --  Center Y: 0.0502 × 490 = 24.6 px → top edge ≈ 4.6 px, bottom ≈ 44.6 px.
    -- ─────────────────────────────────────────────────────────────────────────
    local tabsBar = Create("Frame", {
        Name        = "__tabs",
        ZIndex      = 6,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size        = UDim2.fromOffset(830, 40),
        Position    = UDim2.new(0.5, 0, 0.0502, 0),
        LayoutOrder = 1,
    }, main)
    T(tabsBar, "BackgroundColor3", "Background")
    T(tabsBar, "BorderColor3",     "BorderInner")

    -- ─────────────────────────────────────────────────────────────────────────
    --  Actual tab buttons row  __ActualtabsMAX4  820 × 30
    --  Centered in __tabs (830 → 820 = 5 px each side; 40 → 30 = 5 px top/bot).
    --  UIListLayout horizontal, gap = 0.008 × 820 ≈ 6.5 px.
    --  4 tabs × 200 px + 3 gaps × 6.56 px = 819.7 ≈ 820 ✓
    -- ─────────────────────────────────────────────────────────────────────────
    local actualTabs = Create("Frame", {
        Name                   = "__ActualtabsMAX4",
        ZIndex                 = 6,
        BackgroundTransparency = 1,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        Size                   = UDim2.fromOffset(820, 30),
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        BorderColor3           = Color3.fromRGB(81, 81, 81),
        LayoutOrder            = 1,
    }, tabsBar)
    -- BackgroundColor3 irrelevant (transparent) but register anyway so theme
    -- swap doesn't need a special case.

    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Padding       = UDim.new(0.008, 0),   -- ≈ 6.56 px gap
        Wraps         = true,
    }, actualTabs)

    -- ─────────────────────────────────────────────────────────────────────────
    --  Content section  __Contentsec  830 × 433
    --  Center Y = 0.5451 × 490 = 267.1 px
    --    top    = 267.1 − 216.5 =  50.6 px (tabs bottom 44.6 + ~6 px gap ✓)
    --    bottom = 267.1 + 216.5 = 483.6 px (490 − 483.6 = 6.4 px gap ✓)
    --  UIPadding: left 1, right 1, bottom −1 (matches original exactly)
    -- ─────────────────────────────────────────────────────────────────────────
    local contentSec = Create("Frame", {
        Name        = "__Contentsec",
        ZIndex      = 6,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size        = UDim2.fromOffset(830, 433),
        Position    = UDim2.new(0.5, 0, 0.5451, 0),
        LayoutOrder = 1,
    }, main)
    T(contentSec, "BackgroundColor3", "Background")
    T(contentSec, "BorderColor3",     "BorderInner")

    Create("UIPadding", {
        PaddingLeft   = UDim.new(0, 1),
        PaddingRight  = UDim.new(0, 1),
        PaddingBottom = UDim.new(0, -1),
    }, contentSec)

    -- ─────────────────────────────────────────────────────────────────────────
    --  WATERMARK
    --  Outer ring  _waterMarkLayer1  118 × 30
    --    5 px ring → inner 108 × 20 centered
    --  Same Y as window (0.19101), sits left of it (0.11769).
    --  Active = true so InputBegan fires → enables drag.
    --  On GUI close: Active → false (visible, zero interaction).
    -- ─────────────────────────────────────────────────────────────────────────
    local wmLayer = Create("Frame", {
        Name            = "_waterMarkLayer1",
        BorderSizePixel = 0,
        BorderColor3    = Color3.fromRGB(0, 0, 0),
        Size            = UDim2.fromOffset(118, 30),
        Position        = UDim2.new(0.11769, 0, 0.19101, 0),
        Active          = true,
    }, screenGui)
    T(wmLayer, "BackgroundColor3", "BorderOuter")

    local wmMain = Create("Frame", {
        Name        = "_waterMarkMain",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size        = UDim2.fromOffset(108, 20),
        Position    = UDim2.new(0.5, 0, 0.5, 0),
    }, wmLayer)
    T(wmMain, "BackgroundColor3", "WatermarkBG")
    T(wmMain, "BorderColor3",     "BorderInner")

    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
    }, wmMain)

    local wmLabel = Create("TextLabel", {
        Name                   = "TextLabel",
        TextStrokeTransparency = 0,
        BorderSizePixel        = 0,
        TextSize               = 14,
        BackgroundTransparency = 1,
        FontFace               = FONT,
        Size                   = UDim2.fromOffset(95, 15),
        BorderColor3           = Color3.fromRGB(0, 0, 0),
        Text                   = "novoline.priv",
        Position               = UDim2.new(0, 0, 0.1, 0),
    }, wmMain)
    T(wmLabel, "TextColor3",       "TextPrimary")
    T(wmLabel, "BackgroundColor3", "WatermarkBG")   -- transparent anyway

    -- Watermark has its own independent drag; the window drag does NOT affect it.
    MakeDraggable(wmLayer, wmLayer)

    -- ─────────────────────────────────────────────────────────────────────────
    -- Tab buttons + tab-page visibility
    -- ─────────────────────────────────────────────────────────────────────────
    local tabButtons = {}                            -- [name] = TextButton
    local tabPages   = {}                            -- [name] = {left,right}
    local activeTab  = nil

    -- Each active tab gets a 1 px top "accent stripe" via a thin Frame child.
    -- This is purely cosmetic and theme-aware.
    local tabStripes = {}   -- [name] = Frame

    local function switchTab(tabName)
        for name, btn in pairs(tabButtons) do
            local isActive = (name == tabName)
            Tween(btn, {
                BackgroundColor3 = isActive and theme.TabActive or theme.TabInactive,
                TextColor3       = isActive and theme.TextPrimary or theme.TextMuted,
            })
            if tabStripes[name] then
                tabStripes[name].Visible = isActive
            end
        end
        for name, pages in pairs(tabPages) do
            local vis = (name == tabName)
            if pages.left  then pages.left.Visible  = vis end
            if pages.right then pages.right.Visible = vis end
        end
        activeTab = tabName
    end

    -- Build up to 4 tab buttons.
    -- Each button: 200 × 30 px, SourceCodePro 14 px.
    for i, tabName in ipairs(tabs) do
        if i > 4 then break end

        local btn = Create("TextButton", {
            Name        = "tab" .. i,
            ZIndex      = 7,
            TextSize    = 14,
            FontFace    = FONT,
            Size        = UDim2.fromOffset(200, 30),
            Text        = tabName,
            LayoutOrder = i,
        }, actualTabs)
        T(btn, "BackgroundColor3", "TabInactive")
        T(btn, "BorderColor3",     "BorderInner")
        T(btn, "TextColor3",       "TextMuted")

        -- 1 px accent stripe at top of button (hidden unless active)
        local stripe = Create("Frame", {
            Name            = "_accent",
            ZIndex          = 8,
            BorderSizePixel = 0,
            Size            = UDim2.new(1, 0, 0, 1),
            Position        = UDim2.new(0, 0, 0, 0),
            Visible         = false,
        }, btn)
        T(stripe, "BackgroundColor3", "Accent")

        tabButtons[tabName] = btn
        tabStripes[tabName] = stripe
        tabPages[tabName]   = {}

        btn.MouseButton1Click:Connect(function()
            switchTab(tabName)
        end)
    end

    -- Activate first tab by default.
    if #tabs > 0 then
        -- Force instant paint (no tween on first draw)
        local first = tabs[1]
        activeTab = first
        for name, btn in pairs(tabButtons) do
            local isActive = (name == first)
            btn.BackgroundColor3 = isActive and theme.TabActive    or theme.TabInactive
            btn.TextColor3       = isActive and theme.TextPrimary  or theme.TextMuted
            btn.BorderColor3     = theme.BorderInner
            if tabStripes[name] then
                tabStripes[name].Visible = isActive
            end
        end
    end

    -- ─────────────────────────────────────────────────────────────────────────
    -- Keybind toggle
    -- ─────────────────────────────────────────────────────────────────────────
    local guiVisible = true

    local function setGuiVisible(state)
        guiVisible     = state
        layer1.Visible = state
        -- Watermark stays rendered.
        -- Active = true  → GUI open  → draggable
        -- Active = false → GUI closed → display-only, receives no input
        wmLayer.Active = state
    end

    local keybindConn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == keybind then
            setGuiVisible(not guiVisible)
        end
    end)

    -- ─────────────────────────────────────────────────────────────────────────
    -- Window object
    -- ─────────────────────────────────────────────────────────────────────────
    local Window = {}
    Window._screenGui    = screenGui
    Window._contentSec   = contentSec
    Window._tabPages     = tabPages
    Window._tabButtons   = tabButtons
    Window._tabStripes   = tabStripes
    Window._tabs         = tabs
    Window._wmLabel      = wmLabel
    Window._wmLayer      = wmLayer
    Window._keybindConn  = keybindConn
    Window._themedObjects= themedObjects
    Window._currentTheme = themeName

    -- ── SetTheme ──────────────────────────────────────────────────────────────
    --[[
        Window:SetTheme(name)
        Instantly swaps every themed property with a short tween.
        name must be a key in the Themes table above.
        Invalid names are ignored silently.
    ]]
    function Window:SetTheme(name)
        local t = Themes[name]
        if not t then
            warn("[library] unknown theme: " .. tostring(name))
            return
        end
        theme = t
        self._currentTheme = name

        -- Repaint all registered objects
        for _, entry in ipairs(self._themedObjects) do
            local inst, prop, key = entry[1], entry[2], entry[3]
            if inst and inst.Parent then
                Tween(inst, { [prop] = t[key] })
            end
        end

        -- Repaint tab buttons (active / inactive state is dynamic)
        for tName, btn in pairs(self._tabButtons) do
            local isActive = (tName == activeTab)
            Tween(btn, {
                BackgroundColor3 = isActive and t.TabActive   or t.TabInactive,
                TextColor3       = isActive and t.TextPrimary or t.TextMuted,
                BorderColor3     = t.BorderInner,
            })
        end

        -- Repaint accent stripes
        for _, stripe in pairs(self._tabStripes) do
            if stripe and stripe.Parent then
                Tween(stripe, { BackgroundColor3 = t.Accent })
            end
        end
    end

    -- ── CreateSection ─────────────────────────────────────────────────────────
    --[[
        Window:CreateSection(tabName, side, sectionTitle)

        Pixel spec (from original design):
          sectionFrame   406 × 419  inside __Contentsec (830 × 433)
          Left  center X = 0.2504  × 830 = 207.8 px  (left edge ≈ 4.8 px)
          Right center X = 0.74924 × 830 = 621.9 px  (right edge ≈ 824.9 px)
          Both  center Y = 0.50061 × 433 = 216.8 px  (≈ 7 px top, 7 px bot)

          titleLabel    200 × 36  at (0.25185, 0, −0.01909, 0)
            X offset = 0.25185 × 406 = 102.3 px  (centers title in 406 px frame)
            Y offset = −0.01909 × 419 = −8 px    (floats above top border)

          elementContainer  391 × 390  centered at (0.50011, 0.5194)
            X = 0.50011 × 406 ≈ 203 px  (truly centered)
            Y = 0.5194  × 419 ≈ 217.6 px → top ≈ 22.6 px (just below 36 px title)

        Sections are parented inside contentSec → they are NOT independently
        draggable. They travel with the window.
    ]]
    function Window:CreateSection(tabName, side, sectionTitle)
        assert(side == "Left" or side == "Right",
            "[library] side must be 'Left' or 'Right', got: " .. tostring(side))
        assert(self._tabPages[tabName],
            "[library] unknown tab: " .. tostring(tabName))

        local isLeft = (side == "Left")

        -- Pixel-perfect positions from original design
        local posX          = isLeft and 0.2504   or 0.74924
        local frameName     = isLeft and "_sectionLeftEXAMPLE"   or "_sectionRightEXAMPLE"
        local containerName = isLeft and "_elementContainerLeft" or "_elementContainerRight"
        local titleName     = isLeft and "_sectionLeftTitle"     or "_sectionRightTitle"
        local defaultTitle  = isLeft and "sectionLeft"           or "sectionRight"

        -- Section frame  406 × 419
        local sectionFrame = Create("Frame", {
            Name        = frameName,
            ZIndex      = 6,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size        = UDim2.fromOffset(406, 419),
            Position    = UDim2.new(posX, 0, 0.50061, 0),
            LayoutOrder = 1,
        }, contentSec)
        T(sectionFrame, "BackgroundColor3", "Background")
        T(sectionFrame, "BorderColor3",     "BorderInner")

        -- Title label  200 × 36  floating 8 px above top edge
        local titleLabel = Create("TextLabel", {
            Name                   = titleName,
            TextStrokeTransparency = 0,
            BorderSizePixel        = 0,
            TextSize               = 14,
            BackgroundTransparency = 1,
            FontFace               = FONT,
            Size                   = UDim2.fromOffset(200, 36),
            BorderColor3           = Color3.fromRGB(0, 0, 0),
            Text                   = sectionTitle or defaultTitle,
            Position               = UDim2.new(0.25185, 0, -0.01909, 0),
        }, sectionFrame)
        T(titleLabel, "TextColor3",       "TextPrimary")
        T(titleLabel, "BackgroundColor3", "Background")

        -- Element container  391 × 390  (transparent, you parent elements here)
        local elementContainer = Create("Frame", {
            Name                   = containerName,
            ZIndex                 = 6,
            BackgroundTransparency = 1,
            AnchorPoint            = Vector2.new(0.5, 0.5),
            Size                   = UDim2.fromOffset(391, 390),
            Position               = UDim2.new(0.50011, 0, 0.5194, 0),
            BorderColor3           = Color3.fromRGB(81, 81, 81),
            LayoutOrder            = 1,
        }, sectionFrame)
        -- BackgroundColor3 irrelevant (transparent) — no T() needed

        -- Register with tab system
        if isLeft then
            self._tabPages[tabName].left  = sectionFrame
        else
            self._tabPages[tabName].right = sectionFrame
        end

        sectionFrame.Visible = (tabName == activeTab)

        return {
            Container = elementContainer,
            Title     = titleLabel,
            Frame     = sectionFrame,
        }
    end

    -- ── SetWatermark ──────────────────────────────────────────────────────────
    function Window:SetWatermark(text)
        self._wmLabel.Text = text
    end

    -- ── Destroy ───────────────────────────────────────────────────────────────
    function Window:Destroy()
        self._keybindConn:Disconnect()
        self._screenGui:Destroy()
    end

    return Window
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Expose themes list so callers can enumerate available themes
-- ─────────────────────────────────────────────────────────────────────────────
Library.Themes = Themes

return Library
