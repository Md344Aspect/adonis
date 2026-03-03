--[=[
    ╔══════════════════════════════════════════════════════════╗
    ║                  novoline · library · v3                 ║
    ║    singleton · pixel-perfect · theme-aware · clean API  ║
    ╚══════════════════════════════════════════════════════════╝

    SINGLETON GUARD
    ───────────────
    If the library was already loaded the previous ScreenGui is
    destroyed before a new one is built. The guard key lives in _G
    so it survives re-executions in the same Lua VM.

    QUICK REFERENCE
    ───────────────
    local Lib = require(...)   -- or loadstring(...)()

    local Win = Lib:CreateWindow({
        Title   = "novoline",
        Tabs    = { "combat", "movement", "visuals", "settings" },
        Keybind = Enum.KeyCode.RightShift,
        Theme   = "Default",  -- "Default"|"Dark"|"Light"|"Blood"|"Ocean"|"Mint"
    })

    Win:SetTheme("Blood")                   -- runtime theme swap
    Win:SetWatermark("novoline.priv | 60fps")
    Win:Toggle()                            -- same as pressing the keybind
    Win:SetVisible(false)
    Win:SetKeybind(Enum.KeyCode.Insert)
    Win:SwitchTab("visuals")
    print(Win:GetActiveTab())
    print(Win:GetTheme())

    local sec = Win:CreateSection("combat", "Left", "aimbot")
    sec.Container  → Frame  — parent your elements here
    sec.Title      → TextLabel
    sec.Frame      → outer section Frame
    sec:SetTitle("new title")

    Win:Destroy()   -- destroy one window
    Lib:Destroy()   -- destroy all windows + full cleanup
]=]

-- ─────────────────────────────────────────────────────────────────────────────
-- SINGLETON GUARD
-- ─────────────────────────────────────────────────────────────────────────────
local GUARD_KEY = "__novoline_library__"
if _G[GUARD_KEY] then
    local old = _G[GUARD_KEY]
    if type(old.Destroy) == "function" then
        pcall(old.Destroy, old)
    end
    _G[GUARD_KEY] = nil
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Services
-- ─────────────────────────────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ─────────────────────────────────────────────────────────────────────────────
-- Constants
-- ─────────────────────────────────────────────────────────────────────────────
local FONT = Font.new(
    "rbxasset://fonts/families/SourceCodePro.json",
    Enum.FontWeight.Regular,
    Enum.FontStyle.Normal
)

local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED  = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ─────────────────────────────────────────────────────────────────────────────
-- Themes
-- ─────────────────────────────────────────────────────────────────────────────
--[[
    Key            Used on
    ───────────    ─────────────────────────────────────────────────
    BorderOuter    layer1 bg, watermark outer ring         (5 px rim)
    Background     __main, __tabs, __Contentsec, sections
    BorderInner    __main, __tabs, section borders
    TabInactive    inactive tab button background
    TabActive      active  tab button background
    TextPrimary    active tab, section titles, watermark text
    TextMuted      inactive tab text
    WatermarkBG    watermark inner frame background
    Accent         1 px top stripe on the active tab button
                   (set equal to TabActive for a flat/invisible stripe)
]]
local Themes = {
    Default = {
        BorderOuter = Color3.fromRGB(41,  41,  41 ),
        Background  = Color3.fromRGB(27,  27,  27 ),
        BorderInner = Color3.fromRGB(81,  81,  81 ),
        TabInactive = Color3.fromRGB(32,  32,  32 ),
        TabActive   = Color3.fromRGB(42,  42,  42 ),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextMuted   = Color3.fromRGB(160, 160, 160),
        WatermarkBG = Color3.fromRGB(31,  31,  31 ),
        Accent      = Color3.fromRGB(42,  42,  42 ),
    },
    Dark = {
        BorderOuter = Color3.fromRGB(18,  18,  18 ),
        Background  = Color3.fromRGB(10,  10,  10 ),
        BorderInner = Color3.fromRGB(50,  50,  50 ),
        TabInactive = Color3.fromRGB(15,  15,  15 ),
        TabActive   = Color3.fromRGB(28,  28,  28 ),
        TextPrimary = Color3.fromRGB(230, 230, 230),
        TextMuted   = Color3.fromRGB(110, 110, 110),
        WatermarkBG = Color3.fromRGB(12,  12,  12 ),
        Accent      = Color3.fromRGB(28,  28,  28 ),
    },
    Light = {
        BorderOuter = Color3.fromRGB(190, 190, 190),
        Background  = Color3.fromRGB(235, 235, 235),
        BorderInner = Color3.fromRGB(150, 150, 150),
        TabInactive = Color3.fromRGB(215, 215, 215),
        TabActive   = Color3.fromRGB(200, 200, 200),
        TextPrimary = Color3.fromRGB(20,  20,  20 ),
        TextMuted   = Color3.fromRGB(100, 100, 100),
        WatermarkBG = Color3.fromRGB(210, 210, 210),
        Accent      = Color3.fromRGB(200, 200, 200),
    },
    Blood = {
        BorderOuter = Color3.fromRGB(60,  10,  10 ),
        Background  = Color3.fromRGB(22,  8,   8  ),
        BorderInner = Color3.fromRGB(110, 30,  30 ),
        TabInactive = Color3.fromRGB(35,  12,  12 ),
        TabActive   = Color3.fromRGB(55,  18,  18 ),
        TextPrimary = Color3.fromRGB(255, 200, 200),
        TextMuted   = Color3.fromRGB(160, 90,  90 ),
        WatermarkBG = Color3.fromRGB(30,  10,  10 ),
        Accent      = Color3.fromRGB(180, 30,  30 ),
    },
    Ocean = {
        BorderOuter = Color3.fromRGB(10,  30,  55 ),
        Background  = Color3.fromRGB(8,   20,  40 ),
        BorderInner = Color3.fromRGB(30,  70,  120),
        TabInactive = Color3.fromRGB(12,  28,  52 ),
        TabActive   = Color3.fromRGB(18,  45,  80 ),
        TextPrimary = Color3.fromRGB(190, 220, 255),
        TextMuted   = Color3.fromRGB(90,  130, 175),
        WatermarkBG = Color3.fromRGB(10,  24,  46 ),
        Accent      = Color3.fromRGB(30,  100, 200),
    },
    Mint = {
        BorderOuter = Color3.fromRGB(15,  45,  35 ),
        Background  = Color3.fromRGB(10,  28,  22 ),
        BorderInner = Color3.fromRGB(35,  90,  70 ),
        TabInactive = Color3.fromRGB(14,  38,  30 ),
        TabActive   = Color3.fromRGB(22,  60,  48 ),
        TextPrimary = Color3.fromRGB(190, 255, 225),
        TextMuted   = Color3.fromRGB(90,  160, 130),
        WatermarkBG = Color3.fromRGB(12,  32,  25 ),
        Accent      = Color3.fromRGB(40,  200, 130),
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Internal utilities
-- ─────────────────────────────────────────────────────────────────────────────

local function resolveTheme(name)
    local t = Themes[name]
    if not t then
        local keys = {}
        for k in next, Themes do keys[#keys + 1] = k end
        error(("[novoline] unknown theme %q — valid: %s"):format(
            tostring(name), table.concat(keys, ", ")), 2)
    end
    return t
end

-- Instance factory: create, set props, parent.
local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in next, props do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

-- Fire-and-forget tween.
local function tw(inst, info, props)
    TweenService:Create(inst, info, props):Play()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- ThemeRegistry
-- Tracks every (instance, property, themeKey) created so SetTheme can
-- repaint the whole UI in one pass.
-- ─────────────────────────────────────────────────────────────────────────────
local ThemeRegistry = {}
ThemeRegistry.__index = ThemeRegistry

function ThemeRegistry.new()
    return setmetatable({ _e = {} }, ThemeRegistry)
end

-- Register and immediately paint with current theme.
function ThemeRegistry:bind(inst, prop, key, theme)
    self._e[#self._e + 1] = { inst, prop, key }
    inst[prop] = theme[key]
end

-- Repaint every registered binding with a tween.
function ThemeRegistry:apply(theme, tweenInfo)
    for _, e in next, self._e do
        if e[1] and e[1].Parent then
            tw(e[1], tweenInfo, { [e[2]] = theme[e[3]] })
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Draggable
-- Returns a cleanup function.
-- ─────────────────────────────────────────────────────────────────────────────
local function makeDraggable(target, handle)
    local dragging = false
    local origin, base

    local c1 = handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            origin   = i.Position
            base     = target.Position
        end
    end)

    local c2 = UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - origin
            target.Position = UDim2.new(
                base.X.Scale, base.X.Offset + d.X,
                base.Y.Scale, base.Y.Offset + d.Y
            )
        end
    end)

    local c3 = UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return function() c1:Disconnect() c2:Disconnect() c3:Disconnect() end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Library
-- ─────────────────────────────────────────────────────────────────────────────
local Library    = {}
Library.__index  = Library
Library.Themes   = Themes
Library._windows = {}

function Library:CreateWindow(config)
    config = config or {}

    local tabNames = config.Tabs    or { "combat", "movement", "visuals", "settings" }
    local keybind  = config.Keybind or Enum.KeyCode.RightShift
    local theme    = resolveTheme(config.Theme or "Default")
    local reg      = ThemeRegistry.new()
    local cleanups = {}

    local function addCleanup(fn) cleanups[#cleanups + 1] = fn end

    -- Shorthand: bind to registry and paint immediately
    local function bind(inst, prop, key)
        reg:bind(inst, prop, key, theme)
    end

    -- ── ScreenGui ─────────────────────────────────────────────────────────────
    local screenGui = new("ScreenGui", {
        Name           = "_1",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn   = false,
    }, PlayerGui)

    -- ── Outer ring  __layer1  850 × 500 ──────────────────────────────────────
    local layer1 = new("Frame", {
        Name            = "__layer1",
        ZIndex          = 5,
        BorderSizePixel = 0,
        BorderColor3    = Color3.fromRGB(0, 0, 0),
        Size            = UDim2.fromOffset(850, 500),
        Position        = UDim2.new(0.20685, 0, 0.19101, 0),
        LayoutOrder     = 1,
    }, screenGui)
    bind(layer1, "BackgroundColor3", "BorderOuter")

    -- ── Inner main  __main  840 × 490 (5 px border all sides) ────────────────
    local main = new("Frame", {
        Name        = "__main",
        ZIndex      = 6,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size        = UDim2.fromOffset(840, 490),
        Position    = UDim2.new(0.5, 0, 0.5, 0),
        LayoutOrder = 1,
    }, layer1)
    bind(main, "BackgroundColor3", "Background")
    bind(main, "BorderColor3",     "BorderInner")

    -- Drag: grab __main, move __layer1. Sections inside = not independently draggable.
    addCleanup(makeDraggable(layer1, main))

    -- ── Tabs bar  __tabs  830 × 40 ───────────────────────────────────────────
    --  centerY = 0.0502 × 490 = 24.6 px → top edge ≈ 4.6 px ✓
    local tabsBar = new("Frame", {
        Name        = "__tabs",
        ZIndex      = 6,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size        = UDim2.fromOffset(830, 40),
        Position    = UDim2.new(0.5, 0, 0.0502, 0),
        LayoutOrder = 1,
    }, main)
    bind(tabsBar, "BackgroundColor3", "Background")
    bind(tabsBar, "BorderColor3",     "BorderInner")

    -- ── Tab buttons row  __ActualtabsMAX4  820 × 30 ─────────────────────────
    --  4 × 200 + 3 × (0.008 × 820 ≈ 6.56) = 819.7 ≈ 820 ✓
    local tabRow = new("Frame", {
        Name                   = "__ActualtabsMAX4",
        ZIndex                 = 6,
        BackgroundTransparency = 1,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        Size                   = UDim2.fromOffset(820, 30),
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        BorderColor3           = Color3.fromRGB(81, 81, 81),
        LayoutOrder            = 1,
    }, tabsBar)

    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Padding       = UDim.new(0.008, 0),
    }, tabRow)

    -- ── Content area  __Contentsec  830 × 433 ────────────────────────────────
    --  centerY = 0.5451 × 490 = 267.1 → top 50.6 px (tabs end 44.6 + 6 gap) ✓
    local contentSec = new("Frame", {
        Name        = "__Contentsec",
        ZIndex      = 6,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size        = UDim2.fromOffset(830, 433),
        Position    = UDim2.new(0.5, 0, 0.5451, 0),
        LayoutOrder = 1,
    }, main)
    bind(contentSec, "BackgroundColor3", "Background")
    bind(contentSec, "BorderColor3",     "BorderInner")

    new("UIPadding", {
        PaddingLeft   = UDim.new(0, 1),
        PaddingRight  = UDim.new(0, 1),
        PaddingBottom = UDim.new(0, -1),
    }, contentSec)

    -- ── Watermark  118 × 30 outer / 108 × 20 inner ───────────────────────────
    local wmOuter = new("Frame", {
        Name            = "_waterMarkLayer1",
        BorderSizePixel = 0,
        BorderColor3    = Color3.fromRGB(0, 0, 0),
        Size            = UDim2.fromOffset(118, 30),
        Position        = UDim2.new(0.11769, 0, 0.19101, 0),
        Active          = true,  -- required for InputBegan on a plain Frame
    }, screenGui)
    bind(wmOuter, "BackgroundColor3", "BorderOuter")

    local wmInner = new("Frame", {
        Name        = "_waterMarkMain",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size        = UDim2.fromOffset(108, 20),
        Position    = UDim2.new(0.5, 0, 0.5, 0),
    }, wmOuter)
    bind(wmInner, "BackgroundColor3", "WatermarkBG")
    bind(wmInner, "BorderColor3",     "BorderInner")

    new("UIPadding", { PaddingLeft = UDim.new(0, 6) }, wmInner)

    local wmLabel = new("TextLabel", {
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
    }, wmInner)
    bind(wmLabel, "TextColor3",       "TextPrimary")
    bind(wmLabel, "BackgroundColor3", "WatermarkBG")

    addCleanup(makeDraggable(wmOuter, wmOuter))

    -- ── Tab state ─────────────────────────────────────────────────────────────
    local tabButtons = {}
    local tabStripes = {}
    local tabPages   = {}
    local activeTab  = nil

    local function applyTabColors(name, isActive)
        local btn    = tabButtons[name]
        local stripe = tabStripes[name]
        if not btn then return end
        tw(btn, TWEEN_FAST, {
            BackgroundColor3 = isActive and theme.TabActive   or theme.TabInactive,
            TextColor3       = isActive and theme.TextPrimary or theme.TextMuted,
        })
        if stripe then stripe.Visible = isActive end
    end

    local function switchTab(name)
        if not tabButtons[name] then return end
        for n in next, tabButtons do applyTabColors(n, n == name) end
        for n, pages in next, tabPages do
            local vis = (n == name)
            if pages.left  then pages.left.Visible  = vis end
            if pages.right then pages.right.Visible = vis end
        end
        activeTab = name
    end

    -- Build tab buttons (max 4, each 200 × 30)
    for i = 1, math.min(#tabNames, 4) do
        local name = tabNames[i]

        local btn = new("TextButton", {
            Name        = "tab" .. i,
            ZIndex      = 7,
            TextSize    = 14,
            FontFace    = FONT,
            Size        = UDim2.fromOffset(200, 30),
            Text        = name,
            LayoutOrder = i,
        }, tabRow)
        bind(btn, "BackgroundColor3", "TabInactive")
        bind(btn, "BorderColor3",     "BorderInner")
        bind(btn, "TextColor3",       "TextMuted")

        -- 1 px top accent stripe
        local stripe = new("Frame", {
            Name            = "_accent",
            ZIndex          = 8,
            BorderSizePixel = 0,
            Size            = UDim2.new(1, 0, 0, 1),
            Position        = UDim2.new(0, 0, 0, 0),
            Visible         = false,
        }, btn)
        bind(stripe, "BackgroundColor3", "Accent")

        tabButtons[name] = btn
        tabStripes[name] = stripe
        tabPages[name]   = {}

        btn.MouseButton1Click:Connect(function() switchTab(name) end)
    end

    -- Activate first tab — instant paint (no tween on first draw)
    if #tabNames > 0 then
        activeTab = tabNames[1]
        for name, btn in next, tabButtons do
            local isActive = (name == activeTab)
            btn.BackgroundColor3     = isActive and theme.TabActive   or theme.TabInactive
            btn.TextColor3           = isActive and theme.TextPrimary or theme.TextMuted
            btn.BorderColor3         = theme.BorderInner
            tabStripes[name].Visible = isActive
        end
    end

    -- ── Keybind ───────────────────────────────────────────────────────────────
    local guiVisible = true

    local function setVisible(state)
        guiVisible     = state
        layer1.Visible = state
        wmOuter.Active = state   -- false = renders but absorbs zero input
    end

    local kbConn = UserInputService.InputBegan:Connect(function(i, processed)
        if processed then return end
        if i.KeyCode == keybind then setVisible(not guiVisible) end
    end)
    addCleanup(function() kbConn:Disconnect() end)

    -- ── Private state table (closure-based, unexposed) ─────────────────────────
    local _state = {
        screenGui  = screenGui,
        contentSec = contentSec,
        tabPages   = tabPages,
        tabButtons = tabButtons,
        tabStripes = tabStripes,
        wmLabel    = wmLabel,
        wmOuter    = wmOuter,
        reg        = reg,
        cleanups   = cleanups,
        destroyed  = false,
        -- mutable refs shared with closures above
        theme_ref  = function() return theme end,
    }

    -- ─────────────────────────────────────────────────────────────────────────
    -- Window object
    -- ─────────────────────────────────────────────────────────────────────────
    local Window   = {}
    Window.__index = Window

    -- ── Window:SetTheme(name) ─────────────────────────────────────────────────
    function Window:SetTheme(name)
        assert(not _state.destroyed, "[novoline] called after Destroy()")
        local t = resolveTheme(name)
        theme = t   -- update upvalue used by switchTab / applyTabColors

        _state.reg:apply(t, TWEEN_MED)

        for n, btn in next, _state.tabButtons do
            local isActive = (n == activeTab)
            tw(btn, TWEEN_MED, {
                BackgroundColor3 = isActive and t.TabActive   or t.TabInactive,
                TextColor3       = isActive and t.TextPrimary or t.TextMuted,
                BorderColor3     = t.BorderInner,
            })
            tw(_state.tabStripes[n], TWEEN_MED, { BackgroundColor3 = t.Accent })
        end
    end

    -- ── Window:GetTheme() → string ────────────────────────────────────────────
    function Window:GetTheme()
        for name, t in next, Themes do
            if t == theme then return name end
        end
        return "Custom"
    end

    -- ── Window:SetWatermark(text) ─────────────────────────────────────────────
    function Window:SetWatermark(text)
        assert(not _state.destroyed, "[novoline] called after Destroy()")
        _state.wmLabel.Text = tostring(text)
    end

    -- ── Window:SetVisible(bool) ───────────────────────────────────────────────
    function Window:SetVisible(state)
        assert(not _state.destroyed, "[novoline] called after Destroy()")
        setVisible(state)
    end

    -- ── Window:Toggle() ───────────────────────────────────────────────────────
    function Window:Toggle()
        assert(not _state.destroyed, "[novoline] called after Destroy()")
        setVisible(not guiVisible)
    end

    -- ── Window:IsVisible() → bool ─────────────────────────────────────────────
    function Window:IsVisible()
        return guiVisible
    end

    -- ── Window:SetKeybind(Enum.KeyCode) ───────────────────────────────────────
    function Window:SetKeybind(keyCode)
        assert(not _state.destroyed, "[novoline] called after Destroy()")
        keybind = keyCode
    end

    -- ── Window:SwitchTab(name) ────────────────────────────────────────────────
    function Window:SwitchTab(name)
        assert(not _state.destroyed, "[novoline] called after Destroy()")
        assert(_state.tabPages[name], "[novoline] unknown tab: " .. tostring(name))
        switchTab(name)
    end

    -- ── Window:GetActiveTab() → string ────────────────────────────────────────
    function Window:GetActiveTab()
        return activeTab
    end

    -- ── Window:CreateSection(tabName, side, title) → Section ─────────────────
    --[[
        Pixel spec (locked to original design):
          sectionFrame    406 × 419  inside __Contentsec (830 × 433)
          Left  centerX = 0.2504  × 830 = 207.8 px  (left edge ≈ 4.8 px)
          Right centerX = 0.74924 × 830 = 621.9 px  (right edge ≈ 824.9 px)
          Both  centerY = 0.50061 × 433 = 216.8 px  (≈ 7 px top & bottom)

          titleLabel      200 × 36  at (0.25185, 0, -0.01909, 0)
            X = 102.3 px from left edge (visual center in 406 px frame)
            Y = -8 px (floats above the section top border)

          elementContainer 391 × 390  at (0.50011, 0.5194)
            topEdge = 217.6 - 195 = 22.6 px (clears 36 px title) ✓
    ]]
    function Window:CreateSection(tabName, side, title)
        assert(not _state.destroyed, "[novoline] called after Destroy()")
        assert(side == "Left" or side == "Right",
            ("[novoline] side must be 'Left' or 'Right', got %q"):format(tostring(side)))
        assert(_state.tabPages[tabName],
            ("[novoline] unknown tab %q"):format(tostring(tabName)))

        local isLeft = (side == "Left")
        local posX   = isLeft and 0.2504 or 0.74924

        -- Section frame  406 × 419
        local frame = new("Frame", {
            Name        = isLeft and "_sectionLeft" or "_sectionRight",
            ZIndex      = 6,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size        = UDim2.fromOffset(406, 419),
            Position    = UDim2.new(posX, 0, 0.50061, 0),
            LayoutOrder = 1,
        }, _state.contentSec)
        _state.reg:bind(frame, "BackgroundColor3", "Background",  theme)
        _state.reg:bind(frame, "BorderColor3",     "BorderInner", theme)

        -- Title label  200 × 36  floating −8 px above top border
        local titleLabel = new("TextLabel", {
            Name                   = isLeft and "_sectionLeftTitle" or "_sectionRightTitle",
            TextStrokeTransparency = 0,
            BorderSizePixel        = 0,
            TextSize               = 14,
            BackgroundTransparency = 1,
            FontFace               = FONT,
            Size                   = UDim2.fromOffset(200, 36),
            BorderColor3           = Color3.fromRGB(0, 0, 0),
            Text                   = title or (isLeft and "sectionLeft" or "sectionRight"),
            Position               = UDim2.new(0.25185, 0, -0.01909, 0),
        }, frame)
        _state.reg:bind(titleLabel, "TextColor3",       "TextPrimary", theme)
        _state.reg:bind(titleLabel, "BackgroundColor3", "Background",  theme)

        -- Element container  391 × 390  (transparent — parent elements here)
        local container = new("Frame", {
            Name                   = isLeft and "_elementContainerLeft" or "_elementContainerRight",
            ZIndex                 = 6,
            BackgroundTransparency = 1,
            AnchorPoint            = Vector2.new(0.5, 0.5),
            Size                   = UDim2.fromOffset(391, 390),
            Position               = UDim2.new(0.50011, 0, 0.5194, 0),
            BorderColor3           = Color3.fromRGB(81, 81, 81),
            LayoutOrder            = 1,
        }, frame)

        -- Register with tab visibility system
        _state.tabPages[tabName][isLeft and "left" or "right"] = frame
        frame.Visible = (tabName == activeTab)

        -- ── Section object ─────────────────────────────────────────────────────
        local Section = {}
        Section.Container = container    -- Frame — parent elements here
        Section.Title     = titleLabel   -- TextLabel
        Section.Frame     = frame        -- outer Frame

        function Section:SetTitle(text)
            titleLabel.Text = tostring(text)
        end

        function Section:SetVisible(state)
            frame.Visible = state
        end

        return Section
    end

    -- ── Window:Destroy() ──────────────────────────────────────────────────────
    function Window:Destroy()
        if _state.destroyed then return end
        _state.destroyed = true
        for _, fn in next, _state.cleanups do pcall(fn) end
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
    end

    Library._windows[#Library._windows + 1] = Window
    return setmetatable({}, Window)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Library:Destroy()
-- ─────────────────────────────────────────────────────────────────────────────
function Library:Destroy()
    for _, win in next, self._windows do pcall(win.Destroy, win) end
    self._windows = {}
    _G[GUARD_KEY] = nil
end

_G[GUARD_KEY] = Library
return Library
