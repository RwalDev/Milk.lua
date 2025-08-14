-- Made By Rwal :3
-- Great Milk UI Library
-- Repo: https://github.com/RwalDev/Milk.lua

local MilkUI = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LOCAL_PLAYER = Players.LocalPlayer
local PLAYER_GUI = LOCAL_PLAYER:WaitForChild("PlayerGui")

-- Utils
local function twn(obj, info, goals)
	return TweenService:Create(obj, info, goals)
end

local function inst(className, props, children)
	local o = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			o[k] = v
		end
	end
	if children then
		for _, c in ipairs(children) do
			c.Parent = o
		end
	end
	return o
end

local function round(n, decimals)
	local m = 10 ^ (decimals or 0)
	return math.floor(n * m + 0.5) / m
end

-- Draggable (with onDragEnd callback mobile supported, so you dont hate me lol)
local function makeDraggable(frame, dragHandle, onDragEnd)
	local dragging = false
	local dragStart, startPos

	local function onInputBegan(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if onDragEnd then task.defer(onDragEnd) end
				end
			end)
		end
	end

	local function onInputChanged(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging and dragStart and startPos then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end

	local handle = dragHandle or frame
	handle.InputBegan:Connect(onInputBegan)
	UserInputService.InputChanged:Connect(onInputChanged)
end

-- Shadow
local function addShadow(parent)
	local shadow = inst("ImageLabel", {
		Name = "Shadow",
		Size = UDim2.new(1, 60, 1, 60),
		Position = UDim2.fromOffset(-30, -30),
		BackgroundTransparency = 1,
		Image = "rbxassetid://5028857084",
		ImageTransparency = 0.3,
		ImageColor3 = Color3.new(0,0,0),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(24,24,276,276),
		ZIndex = 0
	})
	shadow.Parent = parent
end

-- Themes (MORE SOON FUCKERSSSSSSS)
local Themes = {
	Milk = {
		Name = "Milk",
		Accent = Color3.fromRGB(56, 144, 255),
		Accent2 = Color3.fromRGB(151, 204, 255),
		Red = Color3.fromRGB(255, 76, 76),
		BG = Color3.fromRGB(16, 16, 20),
		Panel = Color3.fromRGB(22, 22, 26),
		Stroke = Color3.fromRGB(50, 50, 58),
		Text = Color3.fromRGB(240, 240, 255),
		Muted = Color3.fromRGB(170, 170, 190)
	},
	EvilMilk = {
		Name = "EvilMilk",
		Accent = Color3.fromRGB(255, 70, 95),
		Accent2 = Color3.fromRGB(255, 120, 120),
		Red = Color3.fromRGB(255, 76, 76),
		BG = Color3.fromRGB(14, 14, 18),
		Panel = Color3.fromRGB(20, 20, 24),
		Stroke = Color3.fromRGB(55, 55, 62),
		Text = Color3.fromRGB(245, 235, 240),
		Muted = Color3.fromRGB(170, 160, 170)
	},
	BlueRed = {
		Name = "BlueRed",
		Accent = Color3.fromRGB(56, 144, 255),
		Accent2 = Color3.fromRGB(255, 70, 95),
		Red = Color3.fromRGB(255, 70, 95),
		BG = Color3.fromRGB(15, 15, 19),
		Panel = Color3.fromRGB(22, 22, 26),
		Stroke = Color3.fromRGB(48, 48, 54),
		Text = Color3.fromRGB(240, 240, 255),
		Muted = Color3.fromRGB(170, 170, 190)
	}
}

-- Blur (Effects)
local blurEffect = Lighting:FindFirstChild("MilkUI_BlurEffect")
if not blurEffect then
	blurEffect = inst("BlurEffect", {Name = "MilkUI_BlurEffect", Enabled = false, Size = 18})
	blurEffect.Parent = Lighting
end

-- Elements
local function newToggle(theme, text, default, callback)
	local holder = inst("Frame", {Name="Toggle", BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,0,40)}, {
		inst("UICorner", {CornerRadius = UDim.new(0,8)}),
		inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.4}),
	})
	local label = inst("TextLabel", {Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = theme.Text, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0,0.5), Position = UDim2.new(0,12,0.5,0), Size = UDim2.new(1,-90,1,0), TextXAlignment = Enum.TextXAlignment.Left})
	label.Parent = holder

	local btn = inst("TextButton", {Text = "", BackgroundColor3 = Color3.fromRGB(40,40,46), Size = UDim2.fromOffset(44,22), AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-12,0.5,0), AutoButtonColor=false})
	btn.Parent = holder
	inst("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = btn
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.4}).Parent = btn

	local knob = inst("Frame", {BackgroundColor3 = default and theme.Accent or theme.Muted, Size = UDim2.fromOffset(18,18), Position = UDim2.new(default and 1 or 0, default and -22 or 4, 0.5, -9)})
	knob.Parent = btn
	inst("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = knob

	local state = default or false
	local function setState(v)
		state = v
		twn(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(v and 1 or 0, v and -22 or 4, 0.5, -9),
			BackgroundColor3 = v and theme.Accent or theme.Muted
		}):Play()
		if callback then
			task.spawn(function() callback(state) end)
		end
	end

	btn.MouseButton1Click:Connect(function() setState(not state) end)
	setState(state)
	return holder, function(v) setState(v) end
end

local function newButton(theme, text, callback)
	local holder = inst("TextButton", {Name="Button", Text = text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextColor3 = theme.Text, BackgroundColor3 = theme.Accent, Size = UDim2.new(1,0,0,36), AutoButtonColor = false})
	inst("UICorner", {CornerRadius = UDim.new(0,8)}).Parent = holder
	holder.MouseButton1Click:Connect(function()
		if callback then task.spawn(callback) end
	end)
	return holder
end

local function newSlider(theme, text, min, max, default, callback)
	local holder = inst("Frame", {Name="Slider", BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,0,52)}, {
		inst("UICorner", {CornerRadius = UDim.new(0,8)}),
		inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.4}),
	})
	local label = inst("TextLabel", {Text = text, Font = Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundTransparency=1, AnchorPoint=Vector2.new(0,0), Position=UDim2.new(0,12,0,6), Size=UDim2.new(1,-24,0,18), TextXAlignment=Enum.TextXAlignment.Left})
	label.Parent = holder
	local valueLbl = inst("TextLabel", {Text = tostring(default or min), Font = Enum.Font.GothamSemibold, TextSize=14, TextColor3=theme.Muted, BackgroundTransparency=1, AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-12,0,6), Size=UDim2.new(0,60,0,18), TextXAlignment=Enum.TextXAlignment.Right})
	valueLbl.Parent = holder
	local track = inst("Frame", {BackgroundColor3=Color3.fromRGB(40,40,46), Size=UDim2.new(1,-24,0,6), Position=UDim2.new(0,12,1,-16)})
	track.Parent = holder
	inst("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = track

	local fill = inst("Frame", {BackgroundColor3=theme.Accent, Size=UDim2.new(0,0,1,0)})
	fill.Parent = track
	inst("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = fill

	local knob = inst("Frame", {BackgroundColor3=theme.Accent, Size=UDim2.fromOffset(10,10), Position=UDim2.fromOffset(0,-2)})
	knob.Parent = track
	inst("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = knob

	local v = math.clamp(default or min, min, max)

	local function setValue(n, fire)
		v = math.clamp(round(n, 0), min, max)
		local alpha = (v - min) / (max - min)
		twn(fill, TweenInfo.new(0.08), {Size = UDim2.new(alpha, 0, 1, 0)}):Play()
		knob.Position = UDim2.new(alpha, -5, 0, -2)
		valueLbl.Text = tostring(v)
		if callback and (fire ~= false) then
			task.spawn(function() callback(v) end)
		end
	end

	local dragging = false
	local function updateFromX(x)
		local abs = track.AbsolutePosition
		local size = track.AbsoluteSize
		local rel = math.clamp((x - abs.X) / size.X, 0, 1)
		local n = min + rel * (max - min)
		setValue(n)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateFromX(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateFromX(input.Position.X)
		end
	end)

	setValue(v, false)
	return holder, function(n) setValue(n, true) end
end

local function newTextbox(theme, title, placeholder, callback)
	local holder = inst("Frame", {Name="Textbox", BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,0,44)}, {
		inst("UICorner", {CornerRadius = UDim.new(0,8)}),
		inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.4}),
	})
	local label = inst("TextLabel", {Text = title, Font = Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundTransparency=1, AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,12,0.5,0), Size=UDim2.new(0,120,1,0), TextXAlignment = Enum.TextXAlignment.Left})
	label.Parent = holder
	local box = inst("TextBox", {PlaceholderText = placeholder or "", Text = "", Font = Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, PlaceholderColor3=theme.Muted, BackgroundColor3=Color3.fromRGB(28,28,34), Size=UDim2.new(1,-140,0,30), Position=UDim2.new(0,132,0.5,-15), ClearTextOnFocus=false})
	box.Parent = holder
	inst("UICorner", {CornerRadius = UDim.new(0,6)}).Parent = box
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.5}).Parent = box

	box.FocusLost:Connect(function(enterPressed)
		if callback then
			task.spawn(function() callback(box.Text, enterPressed) end)
		end
	end)

	return holder, function(txt) box.Text = txt end
end

local function newDropdown(theme, title, items, defaultIndex, callback)
	local holder = inst("Frame", {Name="Dropdown", BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,0,44)}, {
		inst("UICorner", {CornerRadius = UDim.new(0,8)}),
		inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.4}),
	})
	local label = inst("TextLabel", {Text = title, Font = Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundTransparency=1, AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,12,0.5,0), Size=UDim2.new(0,120,1,0), TextXAlignment = Enum.TextXAlignment.Left})
	label.Parent = holder
	local btn = inst("TextButton", {Text = "", BackgroundColor3 = Color3.fromRGB(28,28,34), Size=UDim2.new(1,-140,0,30), Position=UDim2.new(0,132,0.5,-15), AutoButtonColor=false})
	btn.Parent = holder
	inst("UICorner", {CornerRadius = UDim.new(0,6)}).Parent = btn
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.5}).Parent = btn

	local text = inst("TextLabel", {Text = "Select...", Font = Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundTransparency=1, Size = UDim2.new(1,-30,1,0), TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0,8,0,0)})
	text.Parent = btn
	local chev = inst("TextLabel", {Text = "▼", Font = Enum.Font.GothamBold, TextSize=14, TextColor3=theme.Muted, BackgroundTransparency=1, Size = UDim2.new(0,30,1,0), AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,0,0,0), TextXAlignment = Enum.TextXAlignment.Center})
	chev.Parent = btn

	local listHolder = inst("Frame", {Name="List", BackgroundColor3 = Color3.fromRGB(28,28,34), Size=UDim2.new(1,-140,0,0), Position=UDim2.new(0,132,0,44), Visible = false})
	listHolder.Parent = holder
	inst("UICorner", {CornerRadius = UDim.new(0,6)}).Parent = listHolder
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.5}).Parent = listHolder

	local sf = inst("ScrollingFrame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=3, ScrollBarImageColor3=theme.Accent})
	sf.Parent = listHolder
	local layout = inst("UIListLayout", {Padding = UDim.new(0,4), SortOrder = Enum.SortOrder.LayoutOrder})
	layout.Parent = sf
	inst("UIPadding", {PaddingTop = UDim.new(0,6), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6), PaddingBottom = UDim.new(0,6)}).Parent = sf

	local function refreshCanvas()
		sf.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshCanvas)

	local current = nil
	local function setSelected(labelText)
		text.Text = labelText
		current = labelText
		if callback then task.spawn(function() callback(current) end) end
	end

	local function toggleList(show)
		listHolder.Visible = show
		twn(listHolder, TweenInfo.new(0.12), {Size = UDim2.new(1, -140, 0, show and 128 or 0)}):Play()
		chev.Text = show and "▲" or "▼"
	end

	btn.MouseButton1Click:Connect(function()
		toggleList(not listHolder.Visible)
	end)

	for _, item in ipairs(items or {}) do
		local opt = inst("TextButton", {Text = item, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = theme.Text, BackgroundColor3 = Color3.fromRGB(36,36,42), Size=UDim2.new(1,0,0,28), AutoButtonColor=false})
		inst("UICorner", {CornerRadius = UDim.new(0,6)}).Parent = opt
		inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.6}).Parent = opt
		opt.Parent = sf
		opt.MouseButton1Click:Connect(function()
			setSelected(item)
			toggleList(false)
		end)
	end

	if defaultIndex and items and items[defaultIndex] then
		setSelected(items[defaultIndex])
	end

	return holder, function(value)
		setSelected(value)
	end
end

local function newKeybind(theme, title, defaultKeyCode, callback)
	local holder = inst("Frame", {Name="Keybind", BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,0,44)}, {
		inst("UICorner", {CornerRadius = UDim.new(0,8)}),
		inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.4}),
	})
	local label = inst("TextLabel", {Text = title, Font = Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundTransparency=1, AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,12,0.5,0), Size=UDim2.new(0,120,1,0), TextXAlignment = Enum.TextXAlignment.Left})
	label.Parent = holder
	local btn = inst("TextButton", {Text = (defaultKeyCode and defaultKeyCode.Name) or "None", Font = Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundColor3 = Color3.fromRGB(28,28,34), Size=UDim2.new(1,-140,0,30), Position=UDim2.new(0,132,0.5,-15), AutoButtonColor=false})
	btn.Parent = holder
	inst("UICorner", {CornerRadius = UDim.new(0,6)}).Parent = btn
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.5}).Parent = btn

	local binding = defaultKeyCode
	local listening = false

	local function setBinding(kc)
		binding = kc
		btn.Text = binding and binding.Name or "None"
	end

	btn.MouseButton1Click:Connect(function()
		listening = true
		btn.Text = "Press a key..."
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if listening then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				setBinding(input.KeyCode)
				listening = false
			else
				setBinding(nil)
				listening = false
			end
		else
			if binding and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == binding then
				if callback then task.spawn(callback) end
			end
		end
	end)

	return holder, setBinding
end

local function newColorRGB(theme, title, defaultColor, callback)
	local holder = inst("Frame", {Name="ColorRGB", BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,0,92)}, {
		inst("UICorner", {CornerRadius = UDim.new(0,8)}),
		inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.4}),
	})
	local label = inst("TextLabel", {Text = title, Font = Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundTransparency=1, AnchorPoint=Vector2.new(0,0), Position=UDim2.new(0,12,0,6), Size=UDim2.new(1,-24,0,18), TextXAlignment = Enum.TextXAlignment.Left})
	label.Parent = holder

	local preview = inst("Frame", {BackgroundColor3=defaultColor or theme.Accent, Size=UDim2.new(0,32,0,32), Position=UDim2.new(1,-44,0,8)})
	preview.Parent = holder
	inst("UICorner", {CornerRadius = UDim.new(0,6)}).Parent = preview
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.5}).Parent = preview

	local function makeSliderRow(text, default, onChanged)
		local row = inst("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,-24,0,22), Position=UDim2.new(0,12,0,0)})
		local t = inst("TextLabel", {Text = text, Font = Enum.Font.Gotham, TextSize=14, TextColor3=theme.Muted, BackgroundTransparency=1, AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,0,0.5,0), Size=UDim2.new(0,20,1,0)})
		t.Parent = row
		local track = inst("Frame", {BackgroundColor3=Color3.fromRGB(40,40,46), Size=UDim2.new(1,-30,0,6), Position=UDim2.new(0,30,0.5,-3)})
		track.Parent = row
		inst("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = track
		local fill = inst("Frame", {BackgroundColor3=theme.Accent, Size=UDim2.new((default or 0)/255,0,1,0)})
		fill.Parent = track
		inst("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = fill
		local knob = inst("Frame", {BackgroundColor3=theme.Accent, Size=UDim2.fromOffset(10,10), Position=UDim2.new((default or 0)/255,-5,0,-2)})
		knob.Parent = track
		inst("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = knob

		local v = default or 0
		local dragging = false
		local function setV(n)
			v = math.clamp(math.floor(n+0.5), 0, 255)
			local a = v/255
			fill.Size = UDim2.new(a,0,1,0)
			knob.Position = UDim2.new(a,-5,0,-2)
			onChanged(v)
		end

		track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				local abs = track.AbsolutePosition.X
				local size = track.AbsoluteSize.X
				local rel = math.clamp((input.Position.X - abs) / size, 0, 1)
				setV(rel*255)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local abs = track.AbsolutePosition.X
				local size = track.AbsoluteSize.X
				local rel = math.clamp((input.Position.X - abs) / size, 0, 1)
				setV(rel*255)
			end
		end)

		return row, function(n) setV(n) end
	end

	local r,g,b =  defaultColor and math.floor(defaultColor.R*255) or 56, defaultColor and math.floor(defaultColor.G*255) or 144, defaultColor and math.floor(defaultColor.B*255) or 255
	local function fire()
		local c = Color3.fromRGB(r,g,b)
		preview.BackgroundColor3 = c
		if callback then task.spawn(function() callback(c) end) end
	end

	local rRow = makeSliderRow("R", r, function(n) r = n; fire() end)
	rRow[1].Position = UDim2.new(0,12,0,30)
	rRow[1].Parent = holder
	local gRow = makeSliderRow("G", g, function(n) g = n; fire() end)
	gRow[1].Position = UDim2.new(0,12,0,52)
	gRow[1].Parent = holder
	local bRow = makeSliderRow("B", b, function(n) b = n; fire() end)
	bRow[1].Position = UDim2.new(0,12,0,74)
	bRow[1].Parent = holder

	fire()
	return holder, function(c)
		r = math.floor(c.R*255); g = math.floor(c.G*255); b = math.floor(c.B*255)
		fire()
	end
end

-- Builder
function MilkUI.new(props)
	props = props or {}
	local theme = Themes[props.Theme or "Milk"]
	local title = props.Title or "MilkUI"
	local subtitle = props.SubTitle
	local blurOnOpen = (props.BlurOnOpen ~= false)
	local blurSize = props.BlurSize or 18
	local toggleKey = props.KeyToggle or Enum.KeyCode.RightControl

	-- ScreenGui
	local screen = inst("ScreenGui", {Name="MilkUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 9999})
	screen.Parent = PLAYER_GUI

	-- Main window
	local main = inst("Frame", {Name="Window", BackgroundColor3 = theme.BG, Size = props.Size or UDim2.fromOffset(540, 380), Position = props.Position or UDim2.new(0.5,-270,0.5,-190)})
	main.Parent = screen
	inst("UICorner", {CornerRadius = UDim.new(0,10)}).Parent = main
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.4}).Parent = main
	addShadow(main)

	-- Topbar
	local topbar = inst("Frame", {BackgroundColor3 = theme.Panel, Size = UDim2.new(1,0,0,36)})
	topbar.Parent = main
	inst("UICorner", {CornerRadius = UDim.new(0,10)}).Parent = topbar
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.5}).Parent = topbar
	local grad = inst("UIGradient", {Rotation = 0, Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, theme.Accent),
		ColorSequenceKeypoint.new(1, theme.Accent2)
	}), Transparency = NumberSequence.new(0.8)})
	grad.Parent = topbar

	local titleLbl = inst("TextLabel", {Text = title, Font = Enum.Font.GothamSemibold, TextSize = 16, TextColor3 = theme.Text, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0,0.5), Position = UDim2.new(0,86,0.5,0), Size=UDim2.new(1,-100,1,0), TextXAlignment = Enum.TextXAlignment.Left})
	titleLbl.Parent = topbar
	if subtitle then
		local sub = inst("TextLabel", {Text = subtitle, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = theme.Muted, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0,0.5), Position = UDim2.new(0,86,0.5,12), Size=UDim2.new(1,-100,1,0), TextXAlignment = Enum.TextXAlignment.Left})
		sub.Parent = topbar
	end

	-- Mac-style traffic lights
	local lights = inst("Frame", {Name = "TrafficLights", BackgroundTransparency = 1, Size = UDim2.new(0, 72, 1, 0), Position = UDim2.new(0, 10, 0, 0)})
	lights.Parent = topbar
	local lightsList = inst("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Left, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8)})
	lightsList.Parent = lights
	local function makeLight(name, color)
		local b = inst("TextButton", {Name = name, Text = "", AutoButtonColor = false, BackgroundColor3 = color, Size = UDim2.fromOffset(12, 12)})
		inst("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = b
		inst("UIStroke", {Color = Color3.new(0,0,0), Transparency = 0.2}).Parent = b
		b.Parent = lights
		return b
	end
	local btnClose = makeLight("Close", Color3.fromRGB(255,95,87))
	local btnMin   = makeLight("Minimize", Color3.fromRGB(255,189,46))
	local btnRest  = makeLight("Restore", Color3.fromRGB(40,200,64))

	-- Body: sidebar + pages
	local body = inst("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,-36), Position = UDim2.new(0,0,0,36)})
	body.Parent = main

	local sidebar = inst("Frame", {BackgroundColor3 = theme.Panel, Size = UDim2.new(0, 140, 1, 0)})
	sidebar.Parent = body
	inst("UICorner", {CornerRadius = UDim.new(0,10)}).Parent = sidebar
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.5}).Parent = sidebar
	local tabList = inst("UIListLayout", {Padding = UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center})
	tabList.Parent = sidebar
	inst("UIPadding", {PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), PaddingBottom = UDim.new(0,8)}).Parent = sidebar

	local pageArea = inst("Frame", {BackgroundColor3 = theme.Panel, Size = UDim2.new(1,-150,1,-0), Position = UDim2.new(0,150,0,0)})
	pageArea.Parent = body
	inst("UICorner", {CornerRadius = UDim.new(0,10)}).Parent = pageArea
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.5}).Parent = pageArea

	local pages = inst("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0)})
	pages.Parent = pageArea
	local pageLayout = inst("UIPageLayout", {FillDirection = Enum.FillDirection.Vertical, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out, TweenTime = 0.25})
	pageLayout.Parent = pages

	-- Loader overlay
	local loader = inst("Frame", {BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.2, Visible = false, Size = UDim2.fromScale(1,1)})
	loader.Parent = main
	local loaderCard = inst("Frame", {BackgroundColor3 = theme.Panel, Size = UDim2.fromOffset(260,126), Position = UDim2.new(0.5,-130,0.5,-63)})
	loaderCard.Parent = loader
	inst("UICorner", {CornerRadius = UDim.new(0,10)}).Parent = loaderCard
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.4}).Parent = loaderCard
	local lTitle = inst("TextLabel", {Text = "Loading...", Font = Enum.Font.GothamSemibold, TextSize=16, TextColor3=theme.Text, BackgroundTransparency=1, Position=UDim2.new(0,16,0,16), Size=UDim2.new(1,-32,0,20), TextXAlignment = Enum.TextXAlignment.Left})
	lTitle.Parent = loaderCard
	local lSub = inst("TextLabel", {Text = "Please wait", Font = Enum.Font.Gotham, TextSize=12, TextColor3=theme.Muted, BackgroundTransparency=1, Position=UDim2.new(0,16,0,40), Size=UDim2.new(1,-32,0,18), TextXAlignment = Enum.TextXAlignment.Left})
	lSub.Parent = loaderCard
	local bar = inst("Frame", {BackgroundColor3 = Color3.fromRGB(40,40,46), Size = UDim2.new(1,-32,0,8), Position = UDim2.new(0,16,0,80)})
	bar.Parent = loaderCard
	inst("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = bar
	local barFill = inst("Frame", {BackgroundColor3 = theme.Accent, Size = UDim2.new(0,0,1,0)})
	barFill.Parent = bar
	inst("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = barFill

	-- Key System modal
	local keyModal = inst("Frame", {BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency=0.2, Visible=false, Size = UDim2.fromScale(1,1)})
	keyModal.Parent = main
	local keyCard = inst("Frame", {BackgroundColor3 = theme.Panel, Size = UDim2.fromOffset(320,170), Position = UDim2.new(0.5,-160,0.5,-85)})
	keyCard.Parent = keyModal
	inst("UICorner", {CornerRadius = UDim.new(0,10)}).Parent = keyCard
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.4}).Parent = keyCard
	inst("TextLabel", {Text = "Enter Key", Font = Enum.Font.GothamSemibold, TextSize=16, TextColor3=theme.Text, BackgroundTransparency=1, Position=UDim2.new(0,16,0,14), Size=UDim2.new(1,-32,0,20), TextXAlignment = Enum.TextXAlignment.Left}).Parent = keyCard
	local keyBox = inst("TextBox", {PlaceholderText="Paste your key here", Text="", Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, PlaceholderColor3=theme.Muted, BackgroundColor3=Color3.fromRGB(28,28,34), Size=UDim2.new(1,-32,0,32), Position=UDim2.new(0,16,0,52), ClearTextOnFocus=false})
	keyBox.Parent = keyCard
	inst("UICorner", {CornerRadius = UDim.new(0,6)}).Parent = keyBox
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.5}).Parent = keyBox
	local verifyBtn = inst("TextButton", {Text="Verify", Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=theme.Text, BackgroundColor3 = theme.Accent, Size=UDim2.new(1,-32,0,32), Position=UDim2.new(0,16,0,98), AutoButtonColor=false})
	verifyBtn.Parent = keyCard
	inst("UICorner", {CornerRadius = UDim.new(0,8)}).Parent = verifyBtn
	local statusLbl = inst("TextLabel", {Text="", Font=Enum.Font.Gotham, TextSize=12, TextColor3=theme.Muted, BackgroundTransparency=1, Position=UDim2.new(0,16,0,136), Size=UDim2.new(1,-32,0,18), TextXAlignment = Enum.TextXAlignment.Left})
	statusLbl.Parent = keyCard

	-- Support panel
	local supportModal = inst("Frame", {BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency=0.2, Visible=false, Size = UDim2.fromScale(1,1)})
	supportModal.Parent = main
	local supportCard = inst("Frame", {BackgroundColor3 = theme.Panel, Size = UDim2.fromOffset(360,190), Position = UDim2.new(0.5,-180,0.5,-95)})
	supportCard.Parent = supportModal
	inst("UICorner", {CornerRadius = UDim.new(0,10)}).Parent = supportCard
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.4}).Parent = supportCard
	local supTitle = inst("TextLabel", {Text = "Support", Font = Enum.Font.GothamSemibold, TextSize=16, TextColor3=theme.Text, BackgroundTransparency=1, Position = UDim2.new(0,16,0,14), Size = UDim2.new(1,-32,0,20), TextXAlignment = Enum.TextXAlignment.Left})
	supTitle.Parent = supportCard
	local supText = inst("TextLabel", {Text = "Join our community:", Font = Enum.Font.Gotham, TextSize=14, TextColor3=theme.Muted, BackgroundTransparency=1, Position = UDim2.new(0,16,0,44), Size = UDim2.new(1,-32,0,20), TextXAlignment = Enum.TextXAlignment.Left})
	supText.Parent = supportCard
	local inviteBox = inst("TextBox", {Text="", ClearTextOnFocus=false, Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundColor3=Color3.fromRGB(28,28,34), Size=UDim2.new(1,-32,0,32), Position=UDim2.new(0,16,0,72)})
	inviteBox.Parent = supportCard
	inst("UICorner", {CornerRadius = UDim.new(0,6)}).Parent = inviteBox
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.5}).Parent = inviteBox
	local copyBtn = inst("TextButton", {Text="Copy", Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=theme.Text, BackgroundColor3=theme.Accent, Size=UDim2.new(0,80,0,32), Position=UDim2.new(1,-96,0,114), AutoButtonColor=false})
	copyBtn.Parent = supportCard
	inst("UICorner", {CornerRadius = UDim.new(0,8)}).Parent = copyBtn
	inst("TextLabel", {Text = "Copy uses available clipboard APIs only. Keep usage within Roblox policies.", Font=Enum.Font.Gotham, TextSize=12, TextColor3=theme.Muted, BackgroundTransparency=1, Position=UDim2.new(0,16,0,152), Size=UDim2.new(1,-32,0,18), TextWrapped=true, TextXAlignment = Enum.TextXAlignment.Left}).Parent = supportCard
	copyBtn.MouseButton1Click:Connect(function()
		local code = inviteBox.Text or ""
		local ok = false
		pcall(function()
			if setclipboard then setclipboard(code) ok = true
			elseif syn and syn.write_clipboard then syn.write_clipboard(code) ok = true end
		end)
		copyBtn.Text = ok and "Copied!" or "Unavailable"
		task.delay(1.2, function() if copyBtn then copyBtn.Text = "Copy" end end)
	end)

	-- Confirm close modal
	local confirmModal = inst("Frame", {Name="ConfirmClose", BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.2, Visible = false, Size = UDim2.fromScale(1,1)})
	confirmModal.Parent = main
	local ccCard = inst("Frame", {BackgroundColor3 = theme.Panel, Size = UDim2.fromOffset(320, 160), Position = UDim2.new(0.5, -160, 0.5, -80)})
	ccCard.Parent = confirmModal
	inst("UICorner", {CornerRadius = UDim.new(0,10)}).Parent = ccCard
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.4}).Parent = ccCard
	inst("TextLabel", {Text = "Are you sure you want to close and destroy this UI?", Font = Enum.Font.Gotham, TextSize = 14, TextWrapped = true, TextColor3 = theme.Text, BackgroundTransparency = 1, Position = UDim2.new(0,16,0,16), Size = UDim2.new(1, -32, 0, 60), TextXAlignment = Enum.TextXAlignment.Left}).Parent = ccCard
	local ccRow = inst("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,-32,0,36), Position = UDim2.new(0,16,0,104)})
	ccRow.Parent = ccCard
	local ccList = inst("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0,8), HorizontalAlignment = Enum.HorizontalAlignment.Right})
	ccList.Parent = ccRow
	local ccCancel = inst("TextButton", {Text = "Cancel", Font = Enum.Font.GothamSemibold, TextSize = 14, TextColor3 = theme.Text, BackgroundColor3 = Color3.fromRGB(40,40,46), Size = UDim2.fromOffset(110, 36), AutoButtonColor = false})
	inst("UICorner", {CornerRadius = UDim.new(0,8)}).Parent = ccCancel
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.5}).Parent = ccCancel
	ccCancel.Parent = ccRow
	local ccDestroy = inst("TextButton", {Text = "Destroy", Font = Enum.Font.GothamSemibold, TextSize = 14, TextColor3 = theme.Text, BackgroundColor3 = theme.Red, Size = UDim2.fromOffset(110, 36), AutoButtonColor = false})
	inst("UICorner", {CornerRadius = UDim.new(0,8)}).Parent = ccDestroy
	ccDestroy.Parent = ccRow

	-- CenterTop Status Bar
	local ctWrap = inst("Frame", {Name = "CenterTopStatus", Parent = screen, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10), Size = UDim2.fromOffset(320, 44), Visible = false})
	local ctCard = inst("Frame", {BackgroundColor3 = theme.Panel, Size = UDim2.new(1,0,1,0)})
	ctCard.Parent = ctWrap
	inst("UICorner", {CornerRadius = UDim.new(0, 10)}).Parent = ctCard
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.4}).Parent = ctCard
	local ctText = inst("TextLabel", {Text = "Status", Font = Enum.Font.GothamSemibold, TextSize = 14, TextColor3 = theme.Text, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 8), Size = UDim2.new(1, -24, 0, 18), TextXAlignment = Enum.TextXAlignment.Left})
	ctText.Parent = ctCard
	local ctTrack = inst("Frame", {Name = "Track", BackgroundColor3 = Color3.fromRGB(40,40,46), Size = UDim2.new(1, -24, 0, 8), Position = UDim2.new(0, 12, 1, -14)})
	ctTrack.Parent = ctCard
	inst("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = ctTrack
	local ctFill = inst("Frame", {Name = "Fill", BackgroundColor3 = theme.Red, Size = UDim2.new(0, 0, 1, 0)})
	ctFill.Parent = ctTrack
	inst("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = ctFill

	local function CT_Show(text, color)
		ctText.Text = text or "Status"
		if color then ctFill.BackgroundColor3 = color end
		ctWrap.Visible = true
	end
	local function CT_Update(progress)
		local a = math.clamp(progress or 0, 0, 1)
		twn(ctFill, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(a, 0, 1, 0)}):Play()
	end
	local function CT_Hide()
		ctWrap.Visible = false
	end

	-- Toasts container
	local toastArea = inst("Frame", {Name = "Toasts", Parent = screen, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1, -12, 0, 12), Size = UDim2.fromOffset(300, 0)})
	local toastList = inst("UIListLayout", {Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder})
	toastList.Parent = toastArea

	local function notify(opts)
		opts = opts or {}
		local color = opts.color
		if not color then
			if opts.kind == "success" then color = Color3.fromRGB(40,200,64)
			elseif opts.kind == "error" then color = theme.Red
			else color = theme.Accent
			end
		end
		local dur = math.max(1.2, opts.duration or 2.6)

		local card = inst("Frame", {BackgroundColor3 = theme.Panel, Size = UDim2.fromOffset(300, 64)})
		inst("UICorner", {CornerRadius = UDim.new(0,10)}).Parent = card
		inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.4}).Parent = card
		card.Parent = toastArea

		local barBtm = inst("Frame", {BackgroundColor3 = color, Size = UDim2.new(0, 0, 0, 3), Position = UDim2.new(0,0,1,-3)})
		inst("UICorner", {CornerRadius = UDim.new(1,0)}).Parent = barBtm
		barBtm.Parent = card

		local title = inst("TextLabel", {Text = opts.title or "Notification", Font = Enum.Font.GothamSemibold, TextSize = 14, TextColor3 = theme.Text, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 8), Size = UDim2.new(1, -40, 0, 18), TextXAlignment = Enum.TextXAlignment.Left})
		title.Parent = card

		local msg = inst("TextLabel", {Text = opts.message or "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = theme.Muted, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 30), Size = UDim2.new(1, -40, 0, 18), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
		msg.Parent = card

		card.Position = UDim2.fromOffset(24, 0)
		twn(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(0,0)}):Play()
		twn(barBtm, TweenInfo.new(dur), {Size = UDim2.new(1, 0, 0, 3)}):Play()

		task.delay(dur, function()
			if card.Parent then
				twn(card, TweenInfo.new(0.18), {Position = UDim2.fromOffset(24,0)}):Play()
				task.delay(0.18, function() if card then card:Destroy() end end)
			end
		end)
	end

	-- Tabs + Sections
	local tabCount = 0
	local currentTabBtn = nil
	local function addTab(name, iconText)
		tabCount += 1
		local tabBtn = inst("TextButton", {Text = (iconText and iconText.."  " or "")..name, AutoButtonColor=false, Font = Enum.Font.GothamSemibold, TextSize=14, TextColor3=theme.Text, BackgroundColor3=Color3.fromRGB(28,28,34), Size = UDim2.new(1, -0, 0, 34)})
		tabBtn.Parent = sidebar
		inst("UICorner", {CornerRadius = UDim.new(0,8)}).Parent = tabBtn
		inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.6}).Parent = tabBtn

		local tabPage = inst("ScrollingFrame", {BackgroundTransparency=1, Size = UDim2.new(1,-16,1,-16), Position = UDim2.new(0,8,0,8), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 4, ScrollBarImageColor3 = theme.Accent})
		local layout = inst("UIListLayout", {Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
		layout.Parent = tabPage
		inst("UIPadding", {PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), PaddingBottom = UDim.new(0,8)}).Parent = tabPage

		local pageWrap = inst("Frame", {BackgroundTransparency=1, Size = UDim2.new(1,0,1,0)})
		pageWrap.Parent = pages
		tabPage.Parent = pageWrap

		local function updateCanvas()
			tabPage.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 16)
		end
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

		local function activate()
			if currentTabBtn == tabBtn then return end
			if currentTabBtn then
				twn(currentTabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28,28,34)}):Play()
			end
			currentTabBtn = tabBtn
			twn(tabBtn, TweenInfo.new(0.15), {BackgroundColor3 = theme.Accent}):Play()
			pageLayout:JumpTo(pageWrap)
		end
		tabBtn.MouseButton1Click:Connect(activate)
		if tabCount == 1 then activate() end

		local function addSection(sectionTitle)
			local sec = inst("Frame", {BackgroundColor3 = theme.BG, Size=UDim2.new(1,0,0,40)})
			sec.Parent = tabPage
			inst("UICorner", {CornerRadius = UDim.new(0,8)}).Parent = sec
			inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.5}).Parent = sec

			local header = inst("TextLabel", {Text = sectionTitle, Font = Enum.Font.GothamSemibold, TextSize=14, TextColor3=theme.Text, BackgroundTransparency=1, AnchorPoint=Vector2.new(0,0), Position=UDim2.new(0,12,0,8), Size=UDim2.new(1,-24,0,18), TextXAlignment = Enum.TextXAlignment.Left})
			header.Parent = sec

			local list = inst("UIListLayout", {Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
			list.Parent = sec
			local pad = inst("UIPadding", {PaddingTop = UDim.new(0,30), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), PaddingBottom = UDim.new(0,8)})
			pad.Parent = sec

			local function resize()
				sec.Size = UDim2.new(1,0,0, pad.PaddingTop.Offset + pad.PaddingBottom.Offset + list.AbsoluteContentSize.Y + 24)
			end
			list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)

			local sectionApi = {}
			function sectionApi:AddToggle(txt, default, cb)
				local el, setter = newToggle(theme, txt, default, cb)
				el.Parent = sec; resize(); return setter
			end
			function sectionApi:AddButton(txt, cb)
				local el = newButton(theme, txt, cb)
				el.Parent = sec; resize(); return el
			end
			function sectionApi:AddSlider(txt, min, max, default, cb)
				local el, setter = newSlider(theme, txt, min, max, default, cb)
				el.Parent = sec; resize(); return setter
			end
			function sectionApi:AddTextbox(title, placeholder, cb)
				local el, setter = newTextbox(theme, title, placeholder, cb)
				el.Parent = sec; resize(); return setter
			end
			function sectionApi:AddDropdown(title, items, defaultIndex, cb)
				local el, setter = newDropdown(theme, title, items, defaultIndex, cb)
				el.Parent = sec; resize(); return setter
			end
			function sectionApi:AddKeybind(title, defaultKeyCode, cb)
				local el, setter = newKeybind(theme, title, defaultKeyCode, cb)
				el.Parent = sec; resize(); return setter
			end
			function sectionApi:AddColorRGB(title, defaultColor, cb)
				local el, setter = newColorRGB(theme, title, defaultColor, cb)
				el.Parent = sec; resize(); return setter
			end
			function sectionApi:AddLabel(text, muted)
				local holder = inst("Frame", {BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,0,34)})
				inst("UICorner", {CornerRadius = UDim.new(0,8)}).Parent = holder
				inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.5}).Parent = holder
				holder.Parent = sec
				local lbl = inst("TextLabel", {Text = text, Font = Enum.Font.Gotham, TextSize=14, TextColor3 = (muted and theme.Muted or theme.Text), BackgroundTransparency=1, Size=UDim2.new(1,-24,1,0), Position = UDim2.new(0,12,0,0), TextXAlignment = Enum.TextXAlignment.Left})
				lbl.Parent = holder
				resize()
				return lbl
			end

			return sectionApi
		end

		return { Section = addSection }
	end

	-- Window Control / Blur
	local isOpen = true
	local minimized = false
	local function setBlur(enabled, size)
		if blurEffect then
			blurEffect.Size = size or blurSize
			blurEffect.Enabled = enabled
		end
	end
	local function open()
		main.Visible = true
		if blurOnOpen then setBlur(true) end
		isOpen = true
	end
	local function close()
		main.Visible = false
		if blurOnOpen then setBlur(false) end
		isOpen = false
	end
	local function toggle()
		if isOpen then close() else open() end
	end

	-- Minimize / RestoreDown
	local preMinSize = main.Size
	local preMinPos = main.Position
	local function minimize()
		if minimized then return end
		preMinSize = main.Size
		preMinPos = main.Position
		body.Visible = false
		twn(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(preMinSize.X.Scale, preMinSize.X.Offset, 0, 36)}):Play()
		minimized = true
	end
	local function restoreDown()
		if not minimized then return end
		body.Visible = true
		twn(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = preMinSize, Position = preMinPos}):Play()
		minimized = false
	end
	local function confirmClose()
		confirmModal.Visible = true
	end

	-- Snap + Maximize
	local SNAP_MARGIN = 12
	local SNAP_THRESHOLD = 24
	local snapState = "normal" -- "normal" | "left" | "right" | "max"
	local preSnapSize = main.Size
	local preSnapPos = main.Position
	local function cachePreRect()
		preSnapSize = main.Size
		preSnapPos = main.Position
	end
	local function applySnap(state)
		body.Visible = true
		local vp = screen.AbsoluteSize
		local fullW, fullH = vp.X, vp.Y
		if state == "max" then
			twn(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(SNAP_MARGIN, SNAP_MARGIN),
				Size = UDim2.fromOffset(fullW - SNAP_MARGIN*2, fullH - SNAP_MARGIN*2)
			}):Play()
		elseif state == "left" then
			local halfW = math.floor(fullW/2)
			twn(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(SNAP_MARGIN, SNAP_MARGIN),
				Size = UDim2.fromOffset(halfW - math.floor(SNAP_MARGIN*1.5), fullH - SNAP_MARGIN*2)
			}):Play()
		elseif state == "right" then
			local halfW = math.floor(fullW/2)
			twn(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(halfW + math.floor(SNAP_MARGIN*0.5), SNAP_MARGIN),
				Size = UDim2.fromOffset(halfW - math.floor(SNAP_MARGIN*1.5), fullH - SNAP_MARGIN*2)
			}):Play()
		end
		snapState = state
	end
	local function restoreFromSnap()
		if snapState ~= "normal" then
			twn(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = preSnapPos, Size = preSnapSize}):Play()
			snapState = "normal"
		end
	end
	local function toggleMaximize()
		if minimized then
			restoreDown()
			return
		end
		if snapState == "max" then
			restoreFromSnap()
		else
			if snapState == "normal" then cachePreRect() end
			applySnap("max")
		end
	end
	local function snapCheck()
		if minimized then return end
		local vp = screen.AbsoluteSize
		local absPos = main.AbsolutePosition
		local absSize = main.AbsoluteSize
		if absPos.Y <= SNAP_THRESHOLD then
			if snapState == "normal" then cachePreRect() end
			applySnap("max"); return
		end
		if absPos.X <= SNAP_THRESHOLD then
			if snapState == "normal" then cachePreRect() end
			applySnap("left"); return
		end
		if (absPos.X + absSize.X) >= (vp.X - SNAP_THRESHOLD) then
			if snapState == "normal" then cachePreRect() end
			applySnap("right"); return
		end
		if snapState ~= "normal" then restoreFromSnap() end
	end

	local cam = workspace.CurrentCamera
	if cam then
		cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			if snapState ~= "normal" then
				applySnap(snapState)
			end
		end)
	end

	-- Dragging
	makeDraggable(main, topbar, snapCheck)

	-- Double-click topbar to toggle maximize
	do
		local lastClick = 0
		topbar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local now = tick()
				if now - lastClick <= 0.3 then
					toggleMaximize()
				end
				lastClick = now
			end
		end)
	end

	-- Wire Mac buttons
	btnMin.MouseButton1Click:Connect(minimize)
	btnRest.MouseButton1Click:Connect(function()
		if minimized then restoreDown() else toggleMaximize() end
	end)
	btnClose.MouseButton1Click:Connect(confirmClose)

	-- Confirm modal handlers
	ccCancel.MouseButton1Click:Connect(function()
		confirmModal.Visible = false
	end)
	ccDestroy.MouseButton1Click:Connect(function()
		if blurOnOpen and blurEffect then blurEffect.Enabled = false end
		screen:Destroy()
	end)

	-- Hotkey to toggle UI
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == toggleKey then
			toggle()
		end
	end)

	-- API
	local api = {}

	function api:Open() open() end
	function api:Close() close() end
	function api:Toggle() toggle() end
	function api:SetBlur(enabled, size) setBlur(enabled, size) end
	function api:AddTab(name, iconText) return addTab(name, iconText) end

	function api:ShowLoader(opts)
		opts = opts or {}
		loader.Visible = true
		lTitle.Text = opts.title or "Loading..."
		lSub.Text = opts.subtitle or "Please wait"
		barFill.Size = UDim2.new(0,0,1,0)
		barFill.Size = UDim2.new(0.08,0,1,0)
		task.wait(0.08)
		twn(barFill, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.65,0,1,0)}):Play()
	end
	function api:HideLoader()
		twn(barFill, TweenInfo.new(0.25), {Size = UDim2.new(1,0,1,0)}):Play()
		task.delay(0.3, function() loader.Visible = false end)
	end

	function api:RequireKey(cfg)
		cfg = cfg or {mode = "local"}
		keyModal.Visible = true
		statusLbl.Text = ""
		verifyBtn.Text = "Verify"
		local function setStatus(txt, good)
			statusLbl.Text = txt
			statusLbl.TextColor3 = good and theme.Accent or theme.Muted
		end
		local function finish()
			keyModal.Visible = false
			if cfg.onAuthorized then task.spawn(cfg.onAuthorized) end
		end
		verifyBtn.MouseButton1Click:Connect(function()
			local key = keyBox.Text
			if (cfg.mode == "local") then
				local ok = false
				for _, k in ipairs(cfg.allowedKeys or {}) do
					if key == k then ok = true break end
				end
				if ok then setStatus("Authorized.", true) task.delay(0.5, finish) else setStatus("Invalid key.", false) end
			elseif (cfg.mode == "remote") then
				setStatus("Verifying...", false)
				local success, result = pcall(function()
					local url = assert(cfg.verifyUrl, "verifyUrl required for remote mode")
					local res = HttpService:RequestAsync({
						Url = url, Method = "POST",
						Headers = cfg.headers or {["Content-Type"] = "application/json"},
						Body = HttpService:JSONEncode({key = key, userId = LOCAL_PLAYER.UserId})
					})
					return res
				end)
				if success and result.Success then
					local ok = false
					local parsed = nil
					pcall(function() parsed = HttpService:JSONDecode(result.Body) end)
					if type(parsed) == "table" then ok = (parsed.ok == true or parsed.valid == true) else ok = (result.StatusCode == 200) end
					if ok then setStatus("Authorized.", true) task.delay(0.5, finish) else setStatus("Denied.", false) end
				else
					setStatus("Network error.", false)
				end
			end
		end)
	end

	function api:ShowSupport(props)
		props = props or {}
		supTitle.Text = props.title or "Support"
		inviteBox.Text = props.inviteText or "https://discord.gg/CZyUfby7gk"
		copyBtn.Text = props.copyText or "Copy"
		supportModal.Visible = true
	end

	-- Mac buttons API
	function api:Minimize() minimize() end
	function api:RestoreDown() restoreDown() end
	function api:DestroyUI() confirmClose() end

	-- Snap/maximize API
	function api:Maximize() if snapState ~= "max" then if snapState=="normal" then cachePreRect() end applySnap("max") end end
	function api:Restore() restoreFromSnap() end
	function api:SnapLeft() if snapState=="normal" then cachePreRect() end applySnap("left") end
	function api:SnapRight() if snapState=="normal" then cachePreRect() end applySnap("right") end
	function api:IsMaximized() return snapState == "max" end

	-- CenterTop status API
	api.CenterTopStatus = { Show = CT_Show, Update = CT_Update, Hide = CT_Hide }

	-- Toasts
	function api:Notify(o) notify(o) end

	-- SETTINGS MANAGER
	local settings = {
		_provider = "memory",
		_filename = "milkui_settings.json",
		_state = {},
		_loaded = true
	}
	local function safeJSONDecode(str)
		local ok, data = pcall(function() return HttpService:JSONDecode(str) end)
		return ok and data or nil
	end
	local function safeJSONEncode(tbl)
		local ok, data = pcall(function() return HttpService:JSONEncode(tbl) end)
		return ok and data or "{}"
	end
	function settings:UseMemory(initial)
		self._provider = "memory"; self._state = initial or {}; self._loaded = true
	end
	function settings:UseFile(filename)
		self._provider = "file"; self._filename = filename or self._filename; self._loaded = true
		local ok, content = pcall(function() if readfile then return readfile(self._filename) end end)
		if ok and type(content) == "string" then self._state = safeJSONDecode(content) or {} else self._state = self._state or {} end
	end
	function settings:_save()
		if self._provider == "file" and writefile then pcall(function() writefile(self._filename, safeJSONEncode(self._state)) end) end
	end
	function settings:Get(key, default)
		local v = self._state[key]
		if v == nil then return default end
		return v
	end
	function settings:Set(key, value)
		self._state[key] = value
		self:_save()
	end
	function settings:Bind(key, default)
		local init = self:Get(key, default)
		local function onChange(v) self:Set(key, v) end
		return init, onChange
	end
	function settings:UseBridge(remoteFunction)
		self._provider = "bridge"; self._loaded = false; self._remote = remoteFunction
		task.spawn(function()
			local ok, data = pcall(function() return self._remote:InvokeServer("load") end)
			if ok and type(data) == "table" then self._state = data end
			self._loaded = true
		end)
		function self:_save()
			if not self._remote then return end
			pcall(function() self._remote:InvokeServer("save", self._state) end)
		end
	end
	api.Settings = settings

	-- Init
	local function initOpen()
		open()
	end
	initOpen()

	return api
end

return MilkUI






















































































































































































































































































































































































-- 1500 lines -- why your still heres? --