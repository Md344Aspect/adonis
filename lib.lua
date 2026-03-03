local Library = {}
Library.__index = Library

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Utility
local function Create(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		inst[k] = v
	end
	if parent then inst.Parent = parent end
	return inst
end

local function MakeDraggable(dragTarget, dragHandle)
	local dragging = false
	local dragStart, startPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = dragTarget.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			dragTarget.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

--[[ 
	Library:CreateWindow(config)
	config = {
		Title = "window name",   -- shown nowhere visually but used internally
		Tabs = {"combat", "movement", "visuals", "settings"}  -- up to 4 tabs
	}
	Returns: Window object
	
	Window:CreateSection(tab, side, title)
	  tab  = tab name string (must match one of the Tabs)
	  side = "Left" or "Right"
	  title = section label text
	  Returns: Section object with .Container (the element container Frame)

	Window:SetWatermark(text)
	  Updates the watermark label text

	Window:Destroy()
	  Removes the entire GUI
]]

function Library:CreateWindow(config)
	config = config or {}
	local tabs = config.Tabs or {"combat", "movement", "visuals", "settings"}
	local title = config.Title or "window"

	-- Root ScreenGui
	local screenGui = Create("ScreenGui", {
		Name = "_1",
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
	}, PlayerGui)

	-- Outer border layer
	local layer1 = Create("Frame", {
		Name = "__layer1",
		ZIndex = 5,
		BackgroundColor3 = Color3.fromRGB(41, 41, 41),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 850, 0, 500),
		Position = UDim2.new(0.20685, 0, 0.19101, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		LayoutOrder = 1,
	}, screenGui)

	-- Main inner frame
	local main = Create("Frame", {
		Name = "__main",
		ZIndex = 6,
		BackgroundColor3 = Color3.fromRGB(27, 27, 27),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 840, 0, 490),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BorderColor3 = Color3.fromRGB(81, 81, 81),
		LayoutOrder = 1,
	}, layer1)

	-- Make window draggable via the main frame
	MakeDraggable(layer1, main)

	-- Tabs bar container
	local tabsBar = Create("Frame", {
		Name = "__tabs",
		ZIndex = 6,
		BackgroundColor3 = Color3.fromRGB(27, 27, 27),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 830, 0, 40),
		Position = UDim2.new(0.5, 0, 0.0502, 0),
		BorderColor3 = Color3.fromRGB(81, 81, 81),
		LayoutOrder = 1,
	}, main)

	-- Actual tabs row (max 4)
	local actualTabs = Create("Frame", {
		Name = "__ActualtabsMAX4",
		ZIndex = 6,
		BackgroundColor3 = Color3.fromRGB(27, 27, 27),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 820, 0, 30),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BorderColor3 = Color3.fromRGB(81, 81, 81),
		LayoutOrder = 1,
	}, tabsBar)

	Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0.008, 0),
		Wraps = true,
	}, actualTabs)

	-- Content section
	local contentSec = Create("Frame", {
		Name = "__Contentsec",
		ZIndex = 6,
		BackgroundColor3 = Color3.fromRGB(27, 27, 27),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 830, 0, 433),
		Position = UDim2.new(0.5, 0, 0.5451, 0),
		BorderColor3 = Color3.fromRGB(81, 81, 81),
		LayoutOrder = 1,
	}, main)

	Create("UIPadding", {
		PaddingRight = UDim.new(0, 1),
		PaddingLeft = UDim.new(0, 1),
		PaddingBottom = UDim.new(0, -1),
	}, contentSec)

	-- Watermark
	local wmLayer = Create("Frame", {
		Name = "_waterMarkLayer1",
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(41, 41, 41),
		Size = UDim2.new(0, 118, 0, 30),
		Position = UDim2.new(0.11769, 0, 0.19101, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
	}, screenGui)

	local wmMain = Create("Frame", {
		Name = "_waterMarkMain",
		BackgroundColor3 = Color3.fromRGB(31, 31, 31),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 108, 0, 20),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BorderColor3 = Color3.fromRGB(81, 81, 81),
	}, wmLayer)

	Create("UIPadding", {
		PaddingLeft = UDim.new(0, 6),
	}, wmMain)

	local wmLabel = Create("TextLabel", {
		TextStrokeTransparency = 0,
		BorderSizePixel = 0,
		TextSize = 14,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		FontFace = Font.new([[rbxasset://fonts/families/Nunito.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(0, 95, 0, 15),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Text = [[novoline.priv]],
		Position = UDim2.new(0, 0, 0.1, 0),
	}, wmMain)

	-- Tab buttons + content page visibility tracking
	local tabButtons = {}
	local tabPages = {}   -- tabName -> { left: Frame, right: Frame }
	local activeTab = nil

	local function switchTab(tabName)
		-- Dim all tabs, show only active
		for name, btn in pairs(tabButtons) do
			if name == tabName then
				btn.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				btn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
				btn.TextColor3 = Color3.fromRGB(160, 160, 160)
			end
		end
		-- Show/hide content sections
		for name, pages in pairs(tabPages) do
			local visible = (name == tabName)
			if pages.left then pages.left.Visible = visible end
			if pages.right then pages.right.Visible = visible end
		end
		activeTab = tabName
	end

	-- Build tab buttons (max 4)
	for i, tabName in ipairs(tabs) do
		if i > 4 then break end
		local btn = Create("TextButton", {
			Name = "tab" .. i,
			TextSize = 14,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundColor3 = Color3.fromRGB(32, 32, 32),
			FontFace = Font.new([[rbxasset://fonts/families/Nunito.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			Size = UDim2.new(0, 200, 0, 30),
			BorderColor3 = Color3.fromRGB(81, 81, 81),
			Text = tabName,
			LayoutOrder = i,
		}, actualTabs)

		tabButtons[tabName] = btn
		tabPages[tabName] = {}

		btn.MouseButton1Click:Connect(function()
			switchTab(tabName)
		end)
	end

	-- Activate first tab by default
	if #tabs > 0 then
		switchTab(tabs[1])
	end

	-- Window object
	local Window = {}
	Window._screenGui = screenGui
	Window._contentSec = contentSec
	Window._tabPages = tabPages
	Window._tabs = tabs
	Window._wmLabel = wmLabel

	--[[
		Window:CreateSection(tabName, side, sectionTitle)
		Creates a Left or Right section panel under the given tab.
		Returns a Section table with:
		  .Container  -> the transparent Frame where you add elements
		  .Title      -> the TextLabel showing sectionTitle
	]]
	function Window:CreateSection(tabName, side, sectionTitle)
		assert(side == "Left" or side == "Right", "side must be 'Left' or 'Right'")
		assert(self._tabPages[tabName], "Tab '" .. tabName .. "' does not exist")

		local isLeft = (side == "Left")
		local posX = isLeft and 0.2504 or 0.74924
		local name = isLeft and "_sectionLeftEXAMPLE" or "_sectionRightEXAMPLE"
		local containerName = isLeft and "_elementContainerLeft" or "_elementContainerRight"
		local titleName = isLeft and "_sectionLeftTitle" or "_sectionRightTitle"

		local sectionFrame = Create("Frame", {
			Name = name,
			ZIndex = 6,
			BackgroundColor3 = Color3.fromRGB(27, 27, 27),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(0, 406, 0, 419),
			Position = UDim2.new(posX, 0, 0.50061, 0),
			BorderColor3 = Color3.fromRGB(81, 81, 81),
			LayoutOrder = 1,
		}, contentSec)

		local sectionTitle_ = Create("TextLabel", {
			Name = titleName,
			TextStrokeTransparency = 0,
			BorderSizePixel = 0,
			TextSize = 14,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			FontFace = Font.new([[rbxasset://fonts/families/Nunito.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(0, 200, 0, 36),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = sectionTitle or (side == "Left" and "sectionLeft" or "sectionRight"),
			Position = UDim2.new(0.25185, 0, -0.01909, 0),
		}, sectionFrame)

		local elementContainer = Create("Frame", {
			Name = containerName,
			ZIndex = 6,
			BackgroundColor3 = Color3.fromRGB(27, 27, 27),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(0, 391, 0, 390),
			Position = UDim2.new(0.50011, 0, 0.5194, 0),
			BorderColor3 = Color3.fromRGB(81, 81, 81),
			LayoutOrder = 1,
		}, sectionFrame)

		-- Register and respect tab visibility
		if isLeft then
			self._tabPages[tabName].left = sectionFrame
		else
			self._tabPages[tabName].right = sectionFrame
		end

		-- Hide if not the active tab
		sectionFrame.Visible = (tabName == activeTab)

		return {
			Container = elementContainer,
			Title = sectionTitle_,
			Frame = sectionFrame,
		}
	end

	--[[
		Window:SetWatermark(text)
		Updates the watermark label.
	]]
	function Window:SetWatermark(text)
		self._wmLabel.Text = text
	end

	--[[
		Window:Destroy()
		Removes the entire GUI.
	]]
	function Window:Destroy()
		self._screenGui:Destroy()
	end

	return Window
end

return Library
