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
	if props then for k,v in pairs(props) do o[k] = v end end
	if children then for _,c in ipairs(children) do c.Parent = o end end
	return o
end

local function round(n, d) local m=10^(d or 0) return math.floor(n*m+0.5)/m end
local function colorLerp(a,b,t) return Color3.new(a.R+(b.R-a.R)*t, a.G+(b.G-a.G)*t, a.B+(b.B-a.B)*t) end
local function lighten(c,t) return colorLerp(c, Color3.new(1,1,1), t) end
local function darken(c,t)  return colorLerp(c, Color3.new(0,0,0), t) end

-- Hover FX
local function wireHover(btn)
	if not btn or not btn:IsA("TextButton") then return end
	local base = btn.BackgroundColor3
	btn.MouseEnter:Connect(function()
		if btn.AutoButtonColor == false and btn.BackgroundTransparency < 1 then
			twn(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = lighten(btn.BackgroundColor3, 0.06)}):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		if btn.AutoButtonColor == false and btn.BackgroundTransparency < 1 then
			twn(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = base}):Play()
		end
	end)
	btn.MouseButton1Down:Connect(function()
		if btn.AutoButtonColor == false and btn.BackgroundTransparency < 1 then
			twn(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = darken(btn.BackgroundColor3, 0.08)}):Play()
		end
	end)
	btn.MouseButton1Up:Connect(function()
		if btn.AutoButtonColor == false and btn.BackgroundTransparency < 1 then
			twn(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = base}):Play()
		end
	end)
end

-- Ripple FX
local function attachRipple(btn)
	if not btn or not btn:IsA("TextButton") then return end
	if btn:GetAttribute("milk_ripple") then return end
	btn:SetAttribute("milk_ripple", true)
	btn.ClipsDescendants = true
	local lastPos
	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			lastPos = input.Position
		end
	end)
	btn.MouseButton1Click:Connect(function()
		local r = Instance.new("Frame")
		r.BackgroundColor3 = Color3.new(1,1,1)
		r.BackgroundTransparency = 0.7
		r.AnchorPoint = Vector2.new(0.5,0.5)
		local cx = lastPos and (lastPos.X - btn.AbsolutePosition.X) or (btn.AbsoluteSize.X/2)
		local cy = lastPos and (lastPos.Y - btn.AbsolutePosition.Y) or (btn.AbsoluteSize.Y/2)
		r.Position = UDim2.fromOffset(cx, cy)
		r.Size = UDim2.fromOffset(0,0)
		r.ZIndex = btn.ZIndex + 1
		r.Parent = btn
		local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(1,0) corner.Parent = r
		local maxS = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.6
		twn(r, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(maxS, maxS),
			BackgroundTransparency = 1,
		}):Play()
		task.delay(0.4, function() if r then r:Destroy() end end)
	end)
end

-- Drag
local function makeDraggable(frame, dragHandle, onDragEnd)
	local dragging = false
	local dragStart, startPos
	local function began(input)
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
	local function changed(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging and dragStart and startPos then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end
	local handle = dragHandle or frame
	handle.InputBegan:Connect(began)
	UserInputService.InputChanged:Connect(changed)
end

-- Shadow
local function addShadow(parent)
	local s = inst("ImageLabel", {
		Name="Shadow", Size=UDim2.new(1,60,1,60), Position=UDim2.fromOffset(-30,-30),
		BackgroundTransparency=1, Image="rbxassetid://5028857084", ImageTransparency=0.3,
		ImageColor3=Color3.new(0,0,0), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(24,24,276,276), ZIndex=0
	})
	s.Parent = parent
end

-- Themes
local Themes = {
	Milk = {
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

-- Shared blur
local blurEffect = Lighting:FindFirstChild("MilkUI_BlurEffect")
if not blurEffect then
	blurEffect = inst("BlurEffect", {Name="MilkUI_BlurEffect", Enabled=false, Size=18})
	blurEffect.Parent = Lighting
end

-- Elements: Toggle
local function newToggle(theme, text, default, callback)
	local holder = inst("Frame", {Name="Toggle", BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,0,40)}, {
		inst("UICorner", {CornerRadius = UDim.new(0,8)}),
		inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.4}),
	})
	local label = inst("TextLabel", {
		Text=text, Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text,
		BackgroundTransparency=1, AnchorPoint=Vector2.new(0,0.5),
		Position=UDim2.new(0,12,0.5,0), Size=UDim2.new(1,-90,1,0), TextXAlignment=Enum.TextXAlignment.Left
	}); label.Parent = holder
	local btn = inst("TextButton", {
		Text="", BackgroundColor3=Color3.fromRGB(40,40,46), AutoButtonColor=false,
		Size=UDim2.fromOffset(44,22), AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-12,0.5,0)
	}); btn.Parent = holder
	inst("UICorner", {CornerRadius=UDim.new(1,0)}).Parent = btn
	inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.4}).Parent = btn
	wireHover(btn); attachRipple(btn)
	local knob = inst("Frame", {
		BackgroundColor3=(default and theme.Accent or theme.Muted),
		Size=UDim2.fromOffset(18,18), Position=UDim2.new(default and 1 or 0, default and -22 or 4, 0.5, -9)
	}); knob.Parent = btn
	inst("UICorner", {CornerRadius=UDim.new(1,0)}).Parent = knob
	local state = default or false
	local function setState(v)
		state = v
		twn(knob, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(v and 1 or 0, v and -22 or 4, 0.5, -9),
			BackgroundColor3 = v and theme.Accent or theme.Muted
		}):Play()
		if callback then task.spawn(function() callback(state) end) end
	end
	btn.MouseButton1Click:Connect(function() setState(not state) end)
	setState(state)
	return holder, function(v) setState(v) end
end

-- Elements: Button
local function newButton(theme, text, callback)
	local holder = inst("TextButton", {
		Name="Button", Text=text, Font=Enum.Font.GothamSemibold, TextSize=14,
		TextColor3=theme.Text, BackgroundColor3=theme.Accent, Size=UDim2.new(1,0,0,36), AutoButtonColor=false
	})
	inst("UICorner", {CornerRadius=UDim.new(0,8)}).Parent = holder
	wireHover(holder); attachRipple(holder)
	holder.MouseButton1Click:Connect(function() if callback then task.spawn(callback) end end)
	return holder
end

-- Elements: Slider
local function newSlider(theme, text, min, max, default, callback)
	local holder = inst("Frame", {Name="Slider", BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,0,52)}, {
		inst("UICorner", {CornerRadius=UDim.new(0,8)}),
		inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.4}),
	})
	local label = inst("TextLabel", {Text=text, Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundTransparency=1, Position=UDim2.new(0,12,0,6), Size=UDim2.new(1,-24,0,18), TextXAlignment=Enum.TextXAlignment.Left}); label.Parent = holder
	local valueLbl = inst("TextLabel", {Text=tostring(default or min), Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=theme.Muted, BackgroundTransparency=1, AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-12,0,6), Size=UDim2.new(0,60,0,18), TextXAlignment=Enum.TextXAlignment.Right}); valueLbl.Parent = holder
	local track = inst("Frame", {BackgroundColor3=Color3.fromRGB(40,40,46), Size=UDim2.new(1,-24,0,6), Position=UDim2.new(0,12,1,-16)}); track.Parent = holder
	inst("UICorner", {CornerRadius=UDim.new(1,0)}).Parent = track
	local fill = inst("Frame", {BackgroundColor3=theme.Accent, Size=UDim2.new(0,0,1,0)}); fill.Parent = track
	inst("UICorner", {CornerRadius=UDim.new(1,0)}).Parent = fill
	local knob = inst("Frame", {BackgroundColor3=theme.Accent, Size=UDim2.fromOffset(10,10), Position=UDim2.fromOffset(0,-2)}); knob.Parent = track
	inst("UICorner", {CornerRadius=UDim.new(1,0)}).Parent = knob
	local v = math.clamp(default or min, min, max)
	local function setValue(n, fire)
		v = math.clamp(round(n, 0), min, max)
		local a = (v - min) / (max - min)
		twn(fill, TweenInfo.new(0.08), {Size = UDim2.new(a, 0, 1, 0)}):Play()
		knob.Position = UDim2.new(a, -5, 0, -2)
		valueLbl.Text = tostring(v)
		if callback and (fire ~= false) then task.spawn(function() callback(v) end) end
	end
	local dragging = false
	local function updateFromX(x) local abs = track.AbsolutePosition.X local size = track.AbsoluteSize.X local rel = math.clamp((x - abs) / size, 0, 1) local n = min + rel * (max - min) setValue(n) end
	track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true updateFromX(input.Position.X) end end)
	UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateFromX(input.Position.X) end end)
	setValue(v, false)
	return holder, function(n) setValue(n, true) end
end

-- Elements: Textbox
local function newTextbox(theme, title, placeholder, callback)
	local holder = inst("Frame", {Name="Textbox", BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,0,44)}, {
		inst("UICorner", {CornerRadius=UDim.new(0,8)}),
		inst("UIStroke", {Name="Stroke", Color=theme.Stroke, Thickness=1, Transparency=0.4}),
	})
	local label = inst("TextLabel", {Text=title, Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundTransparency=1, AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,12,0.5,0), Size=UDim2.new(0,120,1,0), TextXAlignment=Enum.TextXAlignment.Left}); label.Parent = holder
	local box = inst("TextBox", {PlaceholderText=placeholder or "", Text="", Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, PlaceholderColor3=theme.Muted, BackgroundColor3=Color3.fromRGB(28,28,34), Size=UDim2.new(1,-140,0,30), Position=UDim2.new(0,132,0.5,-15), ClearTextOnFocus=false}); box.Parent = holder
	inst("UICorner", {CornerRadius=UDim.new(0,6)}).Parent = box
	inst("UIStroke", {Name="FocusStroke", Color=theme.Accent, Thickness=1, Transparency=0.85}).Parent = box
	box.Focused:Connect(function() box.FocusStroke.Transparency = 0.2 end)
	box.FocusLost:Connect(function(enter) box.FocusStroke.Transparency = 0.85 if callback then task.spawn(function() callback(box.Text, enter) end) end end)
	return holder, function(txt) box.Text = txt end
end

-- Elements: Dropdown (fixed, outside-click close, no clipping in sections)
local function newDropdown(theme, title, items, defaultIndex, callback)
	local ROW_H, PAD, GAP, MAX_VISIBLE = 28, 6, 4, 6
	local holder = inst("Frame", {Name="Dropdown", BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,0,44), ClipsDescendants=true, ZIndex=2}, {
		inst("UICorner", {CornerRadius=UDim.new(0,8)}),
		inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.4}),
	})
	local label = inst("TextLabel", {Text=title, Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundTransparency=1, AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,12,0.5,0), Size=UDim2.new(0,120,1,0), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3}); label.Parent = holder
	local btn = inst("TextButton", {Text="", BackgroundColor3=Color3.fromRGB(28,28,34), AutoButtonColor=false, Size=UDim2.new(1,-140,0,30), Position=UDim2.new(0,132,0.5,-15), ZIndex=3}); btn.Parent = holder
	inst("UICorner", {CornerRadius=UDim.new(0,6)}).Parent = btn
	inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.5}).Parent = btn
	wireHover(btn); attachRipple(btn)
	local text = inst("TextLabel", {Text="Select...", Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundTransparency=1, Size=UDim2.new(1,-30,1,0), Position=UDim2.new(0,8,0,0), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4}); text.Parent = btn
	local chev = inst("TextLabel", {Text="▼", Font=Enum.Font.GothamBold, TextSize=14, TextColor3=theme.Muted, BackgroundTransparency=1, Size=UDim2.new(0,30,1,0), AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,0,0,0), TextXAlignment=Enum.TextXAlignment.Center, ZIndex=4}); chev.Parent = btn
	local listHolder = inst("Frame", {Name="List", BackgroundColor3=Color3.fromRGB(28,28,34), Size=UDim2.new(1,-140,0,0), Position=UDim2.new(0,132,0,44), Visible=false, ZIndex=4, ClipsDescendants=true}); listHolder.Parent = holder
	inst("UICorner", {CornerRadius=UDim.new(0,6)}).Parent = listHolder
	inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.5}).Parent = listHolder
	local sf = inst("ScrollingFrame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=3, ScrollBarImageColor3=theme.Accent, ZIndex=5}); sf.Parent = listHolder
	local layout = inst("UIListLayout", {Padding=UDim.new(0,GAP), SortOrder=Enum.SortOrder.LayoutOrder}); layout.Parent = sf
	inst("UIPadding", {PaddingTop=UDim.new(0,PAD), PaddingLeft=UDim.new(0,PAD), PaddingRight=UDim.new(0,PAD), PaddingBottom=UDim.new(0,PAD)}).Parent = sf
	local isOpen, options, outsideConn = false, items or {}, nil
	local function targetHeightFor(count) local vis = math.min(count, MAX_VISIBLE) return vis*(ROW_H+GAP) + PAD*2 - GAP end
	local function disconnectOutside() if outsideConn then outsideConn:Disconnect() outsideConn=nil end end
	local function openList()
		if isOpen then return end
		isOpen = true
		listHolder.Visible = true
		local th = targetHeightFor(#options)
		twn(listHolder, TweenInfo.new(0.12), {Size=UDim2.new(1,-140,0,th)}):Play()
		twn(holder, TweenInfo.new(0.12), {Size=UDim2.new(1,0,0,44+th+PAD)}):Play()
		chev.Text = "▲"
		disconnectOutside()
		outsideConn = UserInputService.InputBegan:Connect(function(input,gp)
			if gp then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			local p = input.Position
			local function inside(gui) local a=gui.AbsolutePosition local s=gui.AbsoluteSize return p.X>=a.X and p.X<=a.X+s.X and p.Y>=a.Y and p.Y<=a.Y+s.Y end
			if not inside(listHolder) and not inside(btn) then
				isOpen = false
				twn(listHolder, TweenInfo.new(0.12), {Size=UDim2.new(1,-140,0,0)}):Play()
				twn(holder, TweenInfo.new(0.12), {Size=UDim2.new(1,0,0,44)}):Play()
				task.delay(0.12, function() if listHolder then listHolder.Visible=false end end)
				chev.Text="▼"
				disconnectOutside()
			end
		end)
	end
	local function closeList()
		if not isOpen then return end
		isOpen=false
		twn(listHolder, TweenInfo.new(0.12), {Size=UDim2.new(1,-140,0,0)}):Play()
		twn(holder, TweenInfo.new(0.12), {Size=UDim2.new(1,0,0,44)}):Play()
		task.delay(0.12, function() if listHolder then listHolder.Visible=false end end)
		chev.Text="▼"
		disconnectOutside()
	end
	btn.MouseButton1Click:Connect(function() if isOpen then closeList() else openList() end end)
	local function rebuild()
		for _, c in ipairs(sf:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
		for _, item in ipairs(options) do
			local opt = inst("TextButton", {Text=item, Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundColor3=Color3.fromRGB(36,36,42), AutoButtonColor=false, Size=UDim2.new(1,0,0,ROW_H), ZIndex=6})
			inst("UICorner", {CornerRadius=UDim.new(0,6)}).Parent = opt
			inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.6}).Parent = opt
			opt.Parent = sf
			opt.MouseEnter:Connect(function() twn(opt, TweenInfo.new(0.08), {BackgroundColor3=Color3.fromRGB(44,44,52)}):Play() end)
			opt.MouseLeave:Connect(function() twn(opt, TweenInfo.new(0.08), {BackgroundColor3=Color3.fromRGB(36,36,42)}):Play() end)
			attachRipple(opt)
			opt.MouseButton1Click:Connect(function()
				text.Text = item
				if callback then task.spawn(function() callback(item) end) end
				closeList()
			end)
		end
		task.defer(function()
			local content = layout.AbsoluteContentSize.Y + PAD*2
			sf.CanvasSize = UDim2.new(0,0,0,content)
			sf.ScrollBarThickness = (#options > MAX_VISIBLE) and 3 or 0
		end)
	end
	rebuild()
	if defaultIndex and options[defaultIndex] then text.Text = tostring(options[defaultIndex]) end
	return holder, function(value) text.Text = tostring(value) if callback then task.spawn(function() callback(value) end) end end
end

-- Elements: Keybind
local function newKeybind(theme, title, defaultKeyCode, callback)
	local holder = inst("Frame", {Name="Keybind", BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,0,44)}, {
		inst("UICorner", {CornerRadius=UDim.new(0,8)}),
		inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.4}),
	})
	local label = inst("TextLabel", {Text=title, Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundTransparency=1, AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,12,0.5,0), Size=UDim2.new(0,120,1,0), TextXAlignment=Enum.TextXAlignment.Left}); label.Parent = holder
	local btn = inst("TextButton", {Text=(defaultKeyCode and defaultKeyCode.Name) or "None", Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundColor3=Color3.fromRGB(28,28,34), Size=UDim2.new(1,-140,0,30), Position=UDim2.new(0,132,0.5,-15), AutoButtonColor=false}); btn.Parent = holder
	inst("UICorner", {CornerRadius=UDim.new(0,6)}).Parent = btn
	inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.5}).Parent = btn
	wireHover(btn); attachRipple(btn)
	local binding = defaultKeyCode
	local listening = false
	local function setBinding(kc) binding = kc btn.Text = binding and binding.Name or "None" end
	btn.MouseButton1Click:Connect(function() listening = true btn.Text = "Press a key..." end)
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if listening then
			if input.UserInputType == Enum.UserInputType.Keyboard then setBinding(input.KeyCode) else setBinding(nil) end
			listening = false
		else
			if binding and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == binding then if callback then task.spawn(callback) end end
		end
	end)
	return holder, setBinding
end

-- Elements: ColorRGB (fixed)
local function newColorRGB(theme, title, defaultColor, callback)
	local holder = inst("Frame", {Name="ColorRGB", BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,0,92)}, {
		inst("UICorner", {CornerRadius=UDim.new(0,8)}),
		inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.4}),
	})
	local label = inst("TextLabel", {Text=title, Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundTransparency=1, Position=UDim2.new(0,12,0,6), Size=UDim2.new(1,-24,0,18), TextXAlignment=Enum.TextXAlignment.Left}); label.Parent = holder
	local preview = inst("Frame", {BackgroundColor3=defaultColor or theme.Accent, Size=UDim2.new(0,32,0,32), Position=UDim2.new(1,-44,0,8)}); preview.Parent = holder
	inst("UICorner", {CornerRadius=UDim.new(0,6)}).Parent = preview
	inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.5}).Parent = preview
	local function makeSliderRow(text, default, onChanged)
		local row = inst("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,-24,0,22), Position=UDim2.new(0,12,0,0)})
		local t = inst("TextLabel", {Text=text, Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Muted, BackgroundTransparency=1, AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,0,0.5,0), Size=UDim2.new(0,20,1,0)}); t.Parent = row
		local track = inst("Frame", {BackgroundColor3=Color3.fromRGB(40,40,46), Size=UDim2.new(1,-30,0,6), Position=UDim2.new(0,30,0.5,-3)}); track.Parent = row
		inst("UICorner", {CornerRadius=UDim.new(1,0)}).Parent = track
		local startA = (default or 0)/255
		local fill = inst("Frame", {BackgroundColor3=theme.Accent, Size=UDim2.new(startA,0,1,0)}); fill.Parent = track
		inst("UICorner", {CornerRadius=UDim.new(1,0)}).Parent = fill
		local knob = inst("Frame", {BackgroundColor3=theme.Accent, Size=UDim2.fromOffset(10,10), Position=UDim2.new(startA,-5,0,-2)}); knob.Parent = track
		inst("UICorner", {CornerRadius=UDim.new(1,0)}).Parent = knob
		local v = default or 0
		local dragging = false
		local function setV(n) v = math.clamp(math.floor(n + 0.5), 0, 255) local a=v/255 fill.Size=UDim2.new(a,0,1,0) knob.Position=UDim2.new(a,-5,0,-2) onChanged(v) end
		track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true local abs=track.AbsolutePosition.X local size=track.AbsoluteSize.X local rel=math.clamp((input.Position.X-abs)/size,0,1) setV(rel*255) end end)
		UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end end)
		UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then local abs=track.AbsolutePosition.X local size=track.AbsoluteSize.X local rel=math.clamp((input.Position.X-abs)/size,0,1) setV(rel*255) end end)
		return row, setV
	end
	local r = defaultColor and math.floor(defaultColor.R*255) or 56
	local g = defaultColor and math.floor(defaultColor.G*255) or 144
	local b = defaultColor and math.floor(defaultColor.B*255) or 255
	local function fire() local c = Color3.fromRGB(r,g,b) preview.BackgroundColor3 = c if callback then task.spawn(function() callback(c) end) end end
	local rRow = makeSliderRow("R", r, function(n) r=n fire() end) rRow.Position = UDim2.new(0,12,0,30) rRow.Parent = holder
	local gRow = makeSliderRow("G", g, function(n) g=n fire() end) gRow.Position = UDim2.new(0,12,0,52) gRow.Parent = holder
	local bRow = makeSliderRow("B", b, function(n) b=n fire() end) bRow.Position = UDim2.new(0,12,0,74) bRow.Parent = holder
	fire()
	return holder, function(c) r=math.floor(c.R*255) g=math.floor(c.G*255) b=math.floor(c.B*255) fire() end
end

-- Elements: MultiSelect
local function newMultiSelect(theme, title, items, defaultList, callback)
	local selected = {}
	if typeof(defaultList) == "table" then for _,v in ipairs(defaultList) do selected[v] = true end end
	local holder = inst("Frame", {Name="MultiSelect", BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,0,44), ClipsDescendants=true}, {
		inst("UICorner",{CornerRadius=UDim.new(0,8)}), inst("UIStroke",{Color=theme.Stroke, Thickness=1, Transparency=0.4})
	})
	local label = inst("TextLabel",{Text=title,Font=Enum.Font.Gotham,TextSize=14,TextColor3=theme.Text,BackgroundTransparency=1,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,12,0.5,0),Size=UDim2.new(0,120,1,0),TextXAlignment=Enum.TextXAlignment.Left}); label.Parent=holder
	local btn = inst("TextButton",{Text="",BackgroundColor3=Color3.fromRGB(28,28,34),AutoButtonColor=false,Size=UDim2.new(1,-140,0,30),Position=UDim2.new(0,132,0.5,-15)}); btn.Parent=holder
	inst("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=btn
	inst("UIStroke",{Color=theme.Stroke, Thickness=1, Transparency=0.5}).Parent=btn
	wireHover(btn); attachRipple(btn)
	local text = inst("TextLabel",{Text="Select...",Font=Enum.Font.Gotham,TextSize=14,TextColor3=theme.Text,BackgroundTransparency=1,Size=UDim2.new(1,-30,1,0),Position=UDim2.new(0,8,0,0),TextXAlignment=Enum.TextXAlignment.Left}); text.Parent=btn
	local chev = inst("TextLabel",{Text="▼",Font=Enum.Font.GothamBold,TextSize=14,TextColor3=theme.Muted,BackgroundTransparency=1,Size=UDim2.new(0,30,1,0),AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),TextXAlignment=Enum.TextXAlignment.Center}); chev.Parent=btn
	local listHolder = inst("Frame",{BackgroundColor3=Color3.fromRGB(28,28,34),Size=UDim2.new(1,-140,0,0),Position=UDim2.new(0,132,0,44),Visible=false,ClipsDescendants=true}); listHolder.Parent=holder
	inst("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=listHolder
	inst("UIStroke",{Color=theme.Stroke,Thickness=1,Transparency=0.5}).Parent=listHolder
	local sf = inst("ScrollingFrame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),CanvasSize=UDim2.new(0,0,0,0),ScrollBarThickness=3,ScrollBarImageColor3=theme.Accent}); sf.Parent=listHolder
	local layout = inst("UIListLayout",{Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder}); layout.Parent=sf
	inst("UIPadding",{PaddingTop=UDim.new(0,6),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,6)}).Parent=sf
	local isOpen=false local outsideConn
	local function refreshLabel()
		local count=0 for _,v in pairs(selected) do if v then count+=1 end end
		if count==0 then text.Text="Select..." elseif count==1 then for k,v in pairs(selected) do if v then text.Text=k break end end else text.Text = tostring(count).." selected" end
	end
	local function disconnectOutside() if outsideConn then outsideConn:Disconnect() outsideConn=nil end end
	local function openList()
		if isOpen then return end
		isOpen=true listHolder.Visible=true
		local count = #items
		local th = math.min(count,6)*(28+4) + 12-4
		twn(listHolder, TweenInfo.new(0.12), {Size=UDim2.new(1,-140,0,th)}):Play()
		twn(holder, TweenInfo.new(0.12), {Size=UDim2.new(1,0,0,44+th+6)}):Play()
		chev.Text="▲"
		disconnectOutside()
		outsideConn = UserInputService.InputBegan:Connect(function(input,gp)
			if gp then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			local p = input.Position
			local function inside(gui) local a=gui.AbsolutePosition local s=gui.AbsoluteSize return p.X>=a.X and p.X<=a.X+s.X and p.Y>=a.Y and p.Y<=a.Y+s.Y end
			if not inside(listHolder) and not inside(btn) then
				isOpen=false
				twn(listHolder, TweenInfo.new(0.12), {Size=UDim2.new(1,-140,0,0)}):Play()
				twn(holder, TweenInfo.new(0.12), {Size=UDim2.new(1,0,0,44)}):Play()
				task.delay(0.12,function() if listHolder then listHolder.Visible=false end end)
				chev.Text="▼"
				disconnectOutside()
			end
		end)
	end
	local function toggleList()
		if isOpen then
			isOpen=false
			twn(listHolder, TweenInfo.new(0.12), {Size=UDim2.new(1,-140,0,0)}):Play()
			twn(holder, TweenInfo.new(0.12), {Size=UDim2.new(1,0,0,44)}):Play()
			task.delay(0.12,function() if listHolder then listHolder.Visible=false end end)
			chev.Text="▼"
			disconnectOutside()
		else openList() end
	end
	btn.MouseButton1Click:Connect(toggleList)
	for _,item in ipairs(items or {}) do
		local row = inst("TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=Color3.fromRGB(36,36,42),Size=UDim2.new(1,0,0,28)})
		inst("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=row
		inst("UIStroke",{Color=theme.Stroke,Thickness=1,Transparency=0.6}).Parent=row
		row.Parent=sf
		local chk = inst("Frame",{BackgroundColor3=selected[item] and theme.Accent or Color3.fromRGB(46,46,52), Size=UDim2.fromOffset(16,16), Position=UDim2.new(0,8,0.5,-8)})
		chk.Parent=row inst("UICorner",{CornerRadius=UDim.new(0,4)}).Parent=chk
		local lbl = inst("TextLabel",{Text=item,Font=Enum.Font.Gotham,TextSize=14,TextColor3=theme.Text,BackgroundTransparency=1,Position=UDim2.new(0,32,0,0),Size=UDim2.new(1,-36,1,0),TextXAlignment=Enum.TextXAlignment.Left})
		lbl.Parent=row
		row.MouseButton1Click:Connect(function()
			selected[item] = not selected[item]
			twn(chk, TweenInfo.new(0.12), {BackgroundColor3 = selected[item] and theme.Accent or Color3.fromRGB(46,46,52)}):Play()
			refreshLabel()
			if callback then
				local out = {} for k,v in pairs(selected) do if v then table.insert(out, k) end end
				task.spawn(function() callback(out) end)
			end
		end)
	end
	task.defer(function()
		sf.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
		refreshLabel()
	end)
	return holder, function(list) selected = {} for _,v in ipairs(list or {}) do selected[v]=true end refreshLabel() if callback then task.spawn(function() callback(list or {}) end) end end
end

-- Elements: Number (stepper with hold acceleration)
local function newNumber(theme, title, min, max, step, default, callback)
	min = min or 0; max = max or 100; step = step or 1
	local value = math.clamp(default or min, min, max)
	local holder = inst("Frame",{Name="Number",BackgroundColor3=theme.Panel,Size=UDim2.new(1,0,0,44)},{
		inst("UICorner",{CornerRadius=UDim.new(0,8)}),
		inst("UIStroke",{Color=theme.Stroke,Thickness=1,Transparency=0.4}),
	})
	local label = inst("TextLabel",{Text=title,Font=Enum.Font.Gotham,TextSize=14,TextColor3=theme.Text,BackgroundTransparency=1,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,12,0.5,0),Size=UDim2.new(0,120,1,0),TextXAlignment=Enum.TextXAlignment.Left})
	label.Parent=holder
	local box = inst("TextBox",{Text=tostring(value),Font=Enum.Font.Gotham,TextSize=14,TextColor3=theme.Text,BackgroundColor3=Color3.fromRGB(28,28,34),Size=UDim2.new(0,80,0,30),Position=UDim2.new(1,-92,0.5,-15),ClearTextOnFocus=false})
	box.Parent=holder inst("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=box inst("UIStroke",{Color=theme.Stroke,Thickness=1,Transparency=0.5}).Parent=box
	local minus = inst("TextButton",{Text="−",AutoButtonColor=false,Font=Enum.Font.GothamSemibold,TextSize=16,TextColor3=theme.Text,BackgroundColor3=theme.Accent,Size=UDim2.new(0,26,0,30),Position=UDim2.new(1,-126,0.5,-15)})
	local plus  = inst("TextButton",{Text="+", AutoButtonColor=false,Font=Enum.Font.GothamSemibold,TextSize=16,TextColor3=theme.Text,BackgroundColor3=theme.Accent,Size=UDim2.new(0,26,0,30),Position=UDim2.new(1,-38,0.5,-15)})
	minus.Parent=holder plus.Parent=holder inst("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=minus inst("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=plus
	wireHover(minus); attachRipple(minus); wireHover(plus); attachRipple(plus)
	local function setVal(v, fire)
		value = math.clamp(tonumber(v) or value, min, max)
		value = round(value/step)*step
		box.Text = tostring(value)
		if fire and callback then task.spawn(function() callback(value) end) end
	end
	box.FocusLost:Connect(function() setVal(box.Text, true) end)
	local function nudge(dir) setVal(value + step*dir, true) end
	local function hold(btn, dir)
		nudge(dir)
		local t = 0.5
		task.spawn(function()
			task.wait(0.25)
			while btn and btn.Parent and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				nudge(dir); task.wait(t); t = math.max(0.05, t*0.85)
			end
		end)
	end
	minus.MouseButton1Click:Connect(function() nudge(-1) end)
	plus.MouseButton1Click:Connect(function() nudge(1) end)
	minus.MouseButton1Down:Connect(function() hold(minus, -1) end)
	plus.MouseButton1Down:Connect(function() hold(plus, 1) end)
	return holder, function(v) setVal(v, true) end
end

-- Elements: Segment (segmented control)
local function newSegment(theme, title, items, defaultIndex, callback)
	local holder = inst("Frame",{Name="Segment",BackgroundColor3=theme.Panel,Size=UDim2.new(1,0,0,64)},{
		inst("UICorner",{CornerRadius=UDim.new(0,8)}),
		inst("UIStroke",{Color=theme.Stroke,Thickness=1,Transparency=0.4}),
	})
	local label = inst("TextLabel",{Text=title,Font=Enum.Font.Gotham,TextSize=14,TextColor3=theme.Text,BackgroundTransparency=1,Position=UDim2.new(0,12,0,8),Size=UDim2.new(1,-24,0,18),TextXAlignment=Enum.TextXAlignment.Left})
	label.Parent=holder
	local bar = inst("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-24,0,30),Position=UDim2.new(0,12,0,28)}); bar.Parent=holder
	local list = inst("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,6), HorizontalAlignment=Enum.HorizontalAlignment.Left}); list.Parent=bar
	local idx = math.clamp(defaultIndex or 1, 1, #items)
	local buttons = {}
	local function select(i)
		idx = i
		for k,b in ipairs(buttons) do
			twn(b, TweenInfo.new(0.12), {BackgroundColor3 = (k==idx and theme.Accent or Color3.fromRGB(28,28,34))}):Play()
		end
		if callback then task.spawn(function() callback(items[idx], idx) end) end
	end
	for i,name in ipairs(items or {}) do
		local b = inst("TextButton",{Text=name, AutoButtonColor=false, Font=Enum.Font.GothamSemibold, TextSize=13, TextColor3=theme.Text, BackgroundColor3=Color3.fromRGB(28,28,34), Size=UDim2.new(0, math.max(60, 10 + (#name*7)), 1, 0)})
		inst("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=b
		inst("UIStroke",{Color=theme.Stroke,Thickness=1,Transparency=0.6}).Parent=b
		wireHover(b); attachRipple(b)
		b.Parent=bar
		b.MouseButton1Click:Connect(function() select(i) end)
		table.insert(buttons, b)
	end
	task.defer(function() select(idx) end)
	return holder, function(i) select(i) end
end

--========================
-- Builder
--========================
function MilkUI.new(props)
	props = props or {}
	local theme = Themes[props.Theme or "Milk"]
	local glass = props.Glass == true
	local title = props.Title or "MilkUI"
	local subtitle = props.SubTitle
	local blurOnOpen = (props.BlurOnOpen ~= false)
	local blurSize = props.BlurSize or 18
	local toggleKey = props.KeyToggle or Enum.KeyCode.RightControl

	-- Screen
	local screen = inst("ScreenGui", {Name="MilkUI", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=9999})
	screen.Parent = PLAYER_GUI

	-- Helpers
	local function viewport()
		-- reliable UI size
		return screen.AbsoluteSize.X > 0 and screen.AbsoluteSize or ((workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1920,1080))
	end

	-- Global SFX + FX
	local sfxEnabled = true
	local sfxClick = Instance.new("Sound") sfxClick.Name="Milk_Click" sfxClick.SoundId="rbxassetid://9118823101" sfxClick.Volume=0.35 sfxClick.Parent=screen
	local function attachSFX(gui)
		if gui:IsA("TextButton") and not gui:GetAttribute("milk_sfx") then
			gui:SetAttribute("milk_sfx", true)
			gui.MouseButton1Click:Connect(function() if sfxEnabled then sfxClick:Play() end end)
		end
	end
	local function wireFX(obj)
		if obj:IsA("TextButton") then attachRipple(obj) end
		attachSFX(obj)
	end
	for _,d in ipairs(screen:GetDescendants()) do wireFX(d) end
	screen.DescendantAdded:Connect(wireFX)

	-- Main window
	local main = inst("Frame", {Name="Window", BackgroundColor3=theme.BG, Size=props.Size or UDim2.fromOffset(560,400), Position=props.Position or UDim2.new(0.5,-280,0.5,-200)})
	main.Parent = screen
	inst("UICorner", {CornerRadius=UDim.new(0,10)}).Parent = main
	inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.4}).Parent = main
	addShadow(main)

	-- Scale pop for open/close
	local mainScale = Instance.new("UIScale")
	mainScale.Scale = 1
	mainScale.Parent = main

	-- Topbar
	local topbar = inst("Frame", {BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,0,36)})
	topbar.Parent = main
	inst("UICorner", {CornerRadius=UDim.new(0,10)}).Parent = topbar
	inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.5}).Parent = topbar
	local grad = inst("UIGradient", {Rotation=0, Color=ColorSequence.new({
		ColorSequenceKeypoint.new(0, theme.Accent), ColorSequenceKeypoint.new(1, theme.Accent2)
	}), Transparency=NumberSequence.new(0.8)})
	grad.Parent = topbar

	local titleLbl = inst("TextLabel", {Text=title, Font=Enum.Font.GothamSemibold, TextSize=16, TextColor3=theme.Text, BackgroundTransparency=1, AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,86,0.5,0), Size=UDim2.new(1,-100,1,0), TextXAlignment=Enum.TextXAlignment.Left})
	titleLbl.Parent = topbar
	if subtitle then
		local sub = inst("TextLabel", {Text=subtitle, Font=Enum.Font.Gotham, TextSize=12, TextColor3=theme.Muted, BackgroundTransparency=1, AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,86,0.5,12), Size=UDim2.new(1,-100,1,0), TextXAlignment=Enum.TextXAlignment.Left})
		sub.Parent = topbar
	end

	-- Mac traffic lights
	local lights = inst("Frame", {BackgroundTransparency=1, Size=UDim2.new(0,72,1,0), Position=UDim2.new(0,10,0,0)}); lights.Parent = topbar
	local lightsList = inst("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, HorizontalAlignment=Enum.HorizontalAlignment.Left, VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0,8)}); lightsList.Parent = lights
	local function light(name, color)
		local b = inst("TextButton", {Name=name, Text="", AutoButtonColor=false, BackgroundColor3=color, Size=UDim2.fromOffset(12,12)})
		inst("UICorner", {CornerRadius=UDim.new(1,0)}).Parent = b
		inst("UIStroke", {Color=Color3.new(0,0,0), Transparency=0.2}).Parent = b
		wireHover(b); attachRipple(b)
		b.Parent = lights
		return b
	end
	local btnClose = light("Close", Color3.fromRGB(255,95,87))
	local btnMin   = light("Minimize", Color3.fromRGB(255,189,46))
	local btnRest  = light("Restore", Color3.fromRGB(40,200,64))

	-- Body (sidebar + pages)
	local body = inst("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,-36), Position=UDim2.new(0,0,0,36)})
	body.Parent = main
	local sidebar = inst("Frame", {BackgroundColor3=theme.Panel, Size=UDim2.new(0,140,1,0)}); sidebar.Parent = body
	inst("UICorner", {CornerRadius=UDim.new(0,10)}).Parent = sidebar
	inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.5}).Parent = sidebar
	local tabList = inst("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder, HorizontalAlignment=Enum.HorizontalAlignment.Center}); tabList.Parent = sidebar
	inst("UIPadding", {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}).Parent = sidebar

	local pageArea = inst("Frame", {BackgroundColor3=theme.Panel, Size=UDim2.new(1,-150,1,0), Position=UDim2.new(0,150,0,0)})
	pageArea.Parent = body
	inst("UICorner", {CornerRadius=UDim.new(0,10)}).Parent = pageArea
	inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.5}).Parent = pageArea

	local pages = inst("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)}); pages.Parent = pageArea
	local pageLayout = inst("UIPageLayout", {FillDirection=Enum.FillDirection.Vertical, EasingStyle=Enum.EasingStyle.Quad, EasingDirection=Enum.EasingDirection.Out, TweenTime=0.25}); pageLayout.Parent = pages

	-- Optional glassmorphism
	if glass then
		main.BackgroundTransparency = 0.1
		pageArea.BackgroundTransparency = 0.15
		sidebar.BackgroundTransparency = 0.15
		topbar.BackgroundTransparency = 0.1
		local noise = inst("ImageLabel", {Name="GlassNoise", BackgroundTransparency=1, Image="rbxassetid://13010780166", ImageTransparency=0.82, ScaleType=Enum.ScaleType.Tile, TileSize=UDim2.fromOffset(128,128), Size=UDim2.fromScale(1,1), ZIndex=0})
		noise.Parent = main
	end

	-- Loader
	local loader = inst("Frame", {BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.2, Visible=false, Size=UDim2.fromScale(1,1)}); loader.Parent = main
	local loaderCard = inst("Frame", {BackgroundColor3=theme.Panel, Size=UDim2.fromOffset(260,126), Position=UDim2.new(0.5,-130,0.5,-63)}); loaderCard.Parent = loader
	inst("UICorner",{CornerRadius=UDim.new(0,10)}).Parent=loaderCard
	inst("UIStroke",{Color=theme.Stroke, Thickness=1, Transparency=0.4}).Parent=loaderCard
	local lTitle = inst("TextLabel",{Text="Loading...",Font=Enum.Font.GothamSemibold,TextSize=16,TextColor3=theme.Text,BackgroundTransparency=1,Position=UDim2.new(0,16,0,16),Size=UDim2.new(1,-32,0,20),TextXAlignment=Enum.TextXAlignment.Left}); lTitle.Parent=loaderCard
	local lSub = inst("TextLabel",{Text="Please wait",Font=Enum.Font.Gotham,TextSize=12,TextColor3=theme.Muted,BackgroundTransparency=1,Position=UDim2.new(0,16,0,40),Size=UDim2.new(1,-32,0,18),TextXAlignment=Enum.TextXAlignment.Left}); lSub.Parent=loaderCard
	local bar = inst("Frame",{BackgroundColor3=Color3.fromRGB(40,40,46),Size=UDim2.new(1,-32,0,8),Position=UDim2.new(0,16,0,80)}); bar.Parent=loaderCard
	inst("UICorner",{CornerRadius=UDim.new(1,0)}).Parent=bar
	local barFill = inst("Frame",{BackgroundColor3=theme.Accent, Size=UDim2.new(0,0,1,0)}); barFill.Parent=bar
	inst("UICorner",{CornerRadius=UDim.new(1,0)}).Parent=barFill

	-- Key System
	local keyModal = inst("Frame",{BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.2, Visible=false, Size=UDim2.fromScale(1,1)}); keyModal.Parent = main
	local keyCard = inst("Frame",{BackgroundColor3=theme.Panel, Size=UDim2.fromOffset(320,170), Position=UDim2.new(0.5,-160,0.5,-85)}); keyCard.Parent=keyModal
	inst("UICorner",{CornerRadius=UDim.new(0,10)}).Parent=keyCard
	inst("UIStroke",{Color=theme.Stroke, Thickness=1, Transparency=0.4}).Parent=keyCard
	inst("TextLabel",{Text="Enter Key",Font=Enum.Font.GothamSemibold,TextSize=16,TextColor3=theme.Text,BackgroundTransparency=1,Position=UDim2.new(0,16,0,14),Size=UDim2.new(1,-32,0,20),TextXAlignment=Enum.TextXAlignment.Left}).Parent=keyCard
	local keyBox = inst("TextBox",{PlaceholderText="Paste your key here",Text="",Font=Enum.Font.Gotham,TextSize=14,TextColor3=theme.Text,PlaceholderColor3=theme.Muted,BackgroundColor3=Color3.fromRGB(28,28,34),Size=UDim2.new(1,-32,0,32),Position=UDim2.new(0,16,0,52),ClearTextOnFocus=false}); keyBox.Parent=keyCard
	inst("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=keyBox
	inst("UIStroke",{Color=theme.Stroke, Thickness=1, Transparency=0.5}).Parent=keyBox
	local verifyBtn = inst("TextButton",{Text="Verify",Font=Enum.Font.GothamSemibold,TextSize=14,TextColor3=theme.Text,BackgroundColor3=theme.Accent,Size=UDim2.new(1,-32,0,32),Position=UDim2.new(0,16,0,98),AutoButtonColor=false}); verifyBtn.Parent=keyCard
	inst("UICorner",{CornerRadius=UDim.new(0,8)}).Parent=verifyBtn
	wireHover(verifyBtn); attachRipple(verifyBtn)
	local statusLbl = inst("TextLabel",{Text="",Font=Enum.Font.Gotham,TextSize=12,TextColor3=theme.Muted,BackgroundTransparency=1,Position=UDim2.new(0,16,0,136),Size=UDim2.new(1,-32,0,18),TextXAlignment=Enum.TextXAlignment.Left}); statusLbl.Parent=keyCard

	-- Support panel
	local supportModal = inst("Frame",{BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.2, Visible=false, Size=UDim2.fromScale(1,1)}); supportModal.Parent=main
	local supportCard = inst("Frame",{BackgroundColor3=theme.Panel, Size=UDim2.fromOffset(360,190), Position=UDim2.new(0.5,-180,0.5,-95)}); supportCard.Parent=supportModal
	inst("UICorner",{CornerRadius=UDim.new(0,10)}).Parent=supportCard
	inst("UIStroke",{Color=theme.Stroke, Thickness=1, Transparency=0.4}).Parent=supportCard
	local supTitle = inst("TextLabel",{Text="Support",Font=Enum.Font.GothamSemibold,TextSize=16,TextColor3=theme.Text,BackgroundTransparency=1,Position=UDim2.new(0,16,0,14),Size=UDim2.new(1,-32,0,20),TextXAlignment=Enum.TextXAlignment.Left}); supTitle.Parent=supportCard
	local supText = inst("TextLabel",{Text="Join our community:",Font=Enum.Font.Gotham,TextSize=14,TextColor3=theme.Muted,BackgroundTransparency=1,Position=UDim2.new(0,16,0,44),Size=UDim2.new(1,-32,0,20),TextXAlignment=Enum.TextXAlignment.Left}); supText.Parent=supportCard
	local inviteBox = inst("TextBox",{Text="",ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=14,TextColor3=theme.Text,BackgroundColor3=Color3.fromRGB(28,28,34),Size=UDim2.new(1,-32,0,32),Position=UDim2.new(0,16,0,72)}); inviteBox.Parent=supportCard
	inst("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=inviteBox
	inst("UIStroke",{Color=theme.Stroke, Thickness=1, Transparency=0.5}).Parent=inviteBox
	local copyBtn = inst("TextButton",{Text="Copy",Font=Enum.Font.GothamSemibold,TextSize=14,TextColor3=theme.Text,BackgroundColor3=theme.Accent,Size=UDim2.new(0,80,0,32),Position=UDim2.new(1,-96,0,114),AutoButtonColor=false}); copyBtn.Parent=supportCard
	inst("UICorner",{CornerRadius=UDim.new(0,8)}).Parent=copyBtn
	wireHover(copyBtn); attachRipple(copyBtn)
	inst("TextLabel",{Text="Copy uses available clipboard APIs only. Keep usage within Roblox policies.",Font=Enum.Font.Gotham,TextSize=12,TextColor3=theme.Muted,BackgroundTransparency=1,Position=UDim2.new(0,16,0,152),Size=UDim2.new(1,-32,0,18),TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left}).Parent=supportCard
	copyBtn.MouseButton1Click:Connect(function()
		local code = inviteBox.Text or ""
		local ok=false
		pcall(function()
			if setclipboard then setclipboard(code) ok=true
			elseif syn and syn.write_clipboard then syn.write_clipboard(code) ok=true end
		end)
		copyBtn.Text = ok and "Copied!" or "Unavailable"
		task.delay(1.2, function() if copyBtn then copyBtn.Text="Copy" end end)
	end)

	-- Confirm close modal
	local confirmModal = inst("Frame",{Name="ConfirmClose", BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.2, Visible=false, Size=UDim2.fromScale(1,1)}); confirmModal.Parent = main
	local ccCard = inst("Frame",{BackgroundColor3=theme.Panel, Size=UDim2.fromOffset(320,160), Position=UDim2.new(0.5,-160,0.5,-80)}); ccCard.Parent=confirmModal
	inst("UICorner",{CornerRadius=UDim.new(0,10)}).Parent=ccCard
	inst("UIStroke",{Color=theme.Stroke, Thickness=1, Transparency=0.4}).Parent=ccCard
	inst("TextLabel",{Text="Are you sure you want to close and destroy this UI?",Font=Enum.Font.Gotham,TextSize=14,TextWrapped=true,TextColor3=theme.Text,BackgroundTransparency=1,Position=UDim2.new(0,16,0,16),Size=UDim2.new(1,-32,0,60),TextXAlignment=Enum.TextXAlignment.Left}).Parent=ccCard
	local ccRow = inst("Frame",{BackgroundTransparency=1, Size=UDim2.new(1,-32,0,36), Position=UDim2.new(0,16,0,104)}); ccRow.Parent=ccCard
	local ccList = inst("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8), HorizontalAlignment=Enum.HorizontalAlignment.Right}); ccList.Parent=ccRow
	local ccCancel = inst("TextButton",{Text="Cancel",Font=Enum.Font.GothamSemibold,TextSize=14,TextColor3=theme.Text,BackgroundColor3=Color3.fromRGB(40,40,46),Size=UDim2.fromOffset(110,36),AutoButtonColor=false}); inst("UICorner",{CornerRadius=UDim.new(0,8)}).Parent=ccCancel; wireHover(ccCancel); attachRipple(ccCancel); ccCancel.Parent=ccRow
	local ccDestroy = inst("TextButton",{Text="Destroy",Font=Enum.Font.GothamSemibold,TextSize=14,TextColor3=theme.Text,BackgroundColor3=theme.Red,Size=UDim2.fromOffset(110,36),AutoButtonColor=false}); inst("UICorner",{CornerRadius=UDim.new(0,8)}).Parent=ccDestroy; wireHover(ccDestroy); attachRipple(ccDestroy); ccDestroy.Parent=ccRow

	-- CenterTop status bar
	local ctWrap = inst("Frame",{Name="CenterTopStatus", Parent=screen, BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0), Position=UDim2.new(0.5,0,0,10), Size=UDim2.fromOffset(320,44), Visible=false})
	local ctCard = inst("Frame",{BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,1,0)}); ctCard.Parent=ctWrap
	inst("UICorner",{CornerRadius=UDim.new(0,10)}).Parent=ctCard
	inst("UIStroke",{Color=theme.Stroke, Thickness=1, Transparency=0.4}).Parent=ctCard
	local ctText = inst("TextLabel",{Text="Status",Font=Enum.Font.GothamSemibold,TextSize=14,TextColor3=theme.Text,BackgroundTransparency=1,Position=UDim2.new(0,12,0,8),Size=UDim2.new(1,-24,0,18),TextXAlignment=Enum.TextXAlignment.Left}); ctText.Parent=ctCard
	local ctTrack = inst("Frame",{BackgroundColor3=Color3.fromRGB(40,40,46),Size=UDim2.new(1,-24,0,8),Position=UDim2.new(0,12,1,-14)}); ctTrack.Parent=ctCard
	inst("UICorner",{CornerRadius=UDim.new(1,0)}).Parent=ctTrack
	local ctFill = inst("Frame",{BackgroundColor3=theme.Red,Size=UDim2.new(0,0,1,0)}); ctFill.Parent=ctTrack
	inst("UICorner",{CornerRadius=UDim.new(1,0)}).Parent=ctFill
	local function CT_Show(text, color) ctText.Text = text or "Status" if color then ctFill.BackgroundColor3=color end ctWrap.Visible=true end
	local function CT_Update(p) local a=math.clamp(p or 0,0,1) twn(ctFill, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=UDim2.new(a,0,1,0)}):Play() end
	local function CT_Hide() ctWrap.Visible=false end

	-- Toasts + history
	local notifHistory = {}
	local toastArea = inst("Frame", {Name="Toasts", Parent=screen, BackgroundTransparency=1, AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-12,0,12), Size=UDim2.fromOffset(300,0)})
	local toastList = inst("UIListLayout",{Padding=UDim.new(0,8), HorizontalAlignment=Enum.HorizontalAlignment.Right, VerticalAlignment=Enum.VerticalAlignment.Top, SortOrder=Enum.SortOrder.LayoutOrder}); toastList.Parent=toastArea
	local function notify(opts)
		opts = opts or {}
		local color = opts.color or (opts.kind=="success" and Color3.fromRGB(40,200,64)) or (opts.kind=="error" and theme.Red) or theme.Accent
		local dur = math.max(1.2, opts.duration or 2.6)

		table.insert(notifHistory, {
			t = os.time(),
			title = opts.title or "Notification",
			message = opts.message or "",
			icon = opts.icon or "",
			kind = opts.kind or "info"
		})

		local card = inst("Frame",{BackgroundColor3=theme.Panel, Size=UDim2.fromOffset(300,68)})
		inst("UICorner",{CornerRadius=UDim.new(0,10)}).Parent=card
		inst("UIStroke",{Color=theme.Stroke, Thickness=1, Transparency=0.4}).Parent=card
		card.Parent=toastArea
		local bar = inst("Frame",{BackgroundColor3=color, Size=UDim2.new(0,0,0,3), Position=UDim2.new(0,0,1,-3)}); inst("UICorner",{CornerRadius=UDim.new(1,0)}).Parent=bar; bar.Parent=card

		local x = 12
		if opts.icon then inst("TextLabel",{Text=opts.icon,Font=Enum.Font.GothamBold,TextSize=16,TextColor3=theme.Text,BackgroundTransparency=1,Position=UDim2.new(0,12,0,10),Size=UDim2.new(0,20,0,20)}).Parent=card x=36 end
		inst("TextLabel",{Text=opts.title or "Notification",Font=Enum.Font.GothamSemibold,TextSize=14,TextColor3=theme.Text,BackgroundTransparency=1,Position=UDim2.new(0,x,0,8),Size=UDim2.new(1,-x-12,0,18),TextXAlignment=Enum.TextXAlignment.Left}).Parent=card
		inst("TextLabel",{Text=opts.message or "",Font=Enum.Font.Gotham,TextSize=12,TextColor3=theme.Muted,BackgroundTransparency=1,Position=UDim2.new(0,x,0,30),Size=UDim2.new(1,-x-12,0,18),TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true}).Parent=card

		if opts.actionText and opts.onAction then
			local act = inst("TextButton",{Text=opts.actionText,Font=Enum.Font.GothamSemibold,TextSize=12,TextColor3=theme.Text,BackgroundColor3=color,AutoButtonColor=false,Size=UDim2.new(0,76,0,22),AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,10)})
			inst("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=act
			wireHover(act); attachRipple(act)
			act.Parent=card
			act.MouseButton1Click:Connect(function() pcall(opts.onAction) end)
		end

		card.Position = UDim2.fromOffset(24,0)
		twn(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position=UDim2.fromOffset(0,0)}):Play()
		twn(bar, TweenInfo.new(dur), {Size=UDim2.new(1,0,0,3)}):Play()
		task.delay(dur, function()
			if card.Parent then
				twn(card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position=UDim2.fromOffset(24,0)}):Play()
				task.delay(0.18, function() if card then card:Destroy() end end)
			end
		end)
	end

	-- Notification Center
	local noteModal = inst("Frame",{Name="Milk_Notes", Parent=screen, BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.2, Visible=false, Size=UDim2.fromScale(1,1), ZIndex=40000})
	local noteCard = inst("Frame",{BackgroundColor3=theme.Panel, Size=UDim2.fromOffset(380,320), Position=UDim2.new(0.5,-190,0.35,-100)}); noteCard.Parent = noteModal
	inst("UICorner",{CornerRadius=UDim.new(0,10)}).Parent=noteCard
	inst("UIStroke",{Color=theme.Stroke,Thickness=1,Transparency=0.4}).Parent=noteCard
	inst("TextLabel",{Text="Notifications",Font=Enum.Font.GothamSemibold,TextSize=16,TextColor3=theme.Text,BackgroundTransparency=1,Position=UDim2.new(0,12,0,10),Size=UDim2.new(1,-24,0,20),TextXAlignment=Enum.TextXAlignment.Left}).Parent=noteCard
	local clearBtn = inst("TextButton",{Text="Clear",AutoButtonColor=false,Font=Enum.Font.GothamSemibold,TextSize=12,TextColor3=theme.Text,BackgroundColor3=theme.Accent,Size=UDim2.new(0,60,0,24),Position=UDim2.new(1,-72,0,8)})
	clearBtn.Parent=noteCard inst("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=clearBtn wireHover(clearBtn); attachRipple(clearBtn)
	local noteList = inst("ScrollingFrame",{BackgroundTransparency=1,Size=UDim2.new(1,-24,1,-52),Position=UDim2.new(0,12,0,44),CanvasSize=UDim2.new(0,0,0,0),ScrollBarThickness=3,ScrollBarImageColor3=theme.Accent})
	noteList.Parent=noteCard
	local noteLayout = inst("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder}); noteLayout.Parent=noteList
	local function noteCanvas() noteList.CanvasSize=UDim2.new(0,0,0,noteLayout.AbsoluteContentSize.Y + 12) end
	noteLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(noteCanvas)
	local function buildNotes()
		for _,c in ipairs(noteList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
		for i = #notifHistory, 1, -1 do
			local n = notifHistory[i]
			local row = inst("Frame",{BackgroundColor3=Color3.fromRGB(28,28,34), Size=UDim2.new(1,0,0,44)})
			inst("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=row
			inst("UIStroke",{Color=theme.Stroke,Thickness=1,Transparency=0.6}).Parent=row
			row.Parent=noteList
			inst("TextLabel",{Text=n.icon,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=theme.Text,BackgroundTransparency=1,Position=UDim2.new(0,8,0,12),Size=UDim2.new(0,20,0,20)}).Parent=row
			inst("TextLabel",{Text=n.title,Font=Enum.Font.GothamSemibold,TextSize=14,TextColor3=theme.Text,BackgroundTransparency=1,Position=UDim2.new(0,32,0,6),Size=UDim2.new(1,-40,0,18),TextXAlignment=Enum.TextXAlignment.Left}).Parent=row
			inst("TextLabel",{Text=n.message,Font=Enum.Font.Gotham,TextSize=12,TextColor3=theme.Muted,BackgroundTransparency=1,Position=UDim2.new(0,32,0,24),Size=UDim2.new(1,-40,0,16),TextXAlignment=Enum.TextXAlignment.Left}).Parent=row
		end
		noteCanvas()
	end
	clearBtn.MouseButton1Click:Connect(function() table.clear(notifHistory) buildNotes() end)

	-- Tooltips (single global mouse-move)
	local tip = inst("Frame",{Name="MilkTooltip", Parent=screen, Visible=false, BackgroundColor3=Color3.fromRGB(20,20,24), BackgroundTransparency=0.1, Size=UDim2.fromOffset(0,0), ZIndex=99999})
	inst("UICorner",{CornerRadius=UDim.new(0,6)}).Parent=tip
	inst("UIStroke",{Color=Color3.fromRGB(70,70,78), Thickness=1, Transparency=0.4}).Parent=tip
	local tipLbl = inst("TextLabel",{Parent=tip, BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=12, TextColor3=theme.Text, Text="", Size=UDim2.new(1,-12,1,-8), Position=UDim2.new(0,6,0,4), ZIndex=100000})
	UserInputService.InputChanged:Connect(function(input)
		if tip.Visible and input.UserInputType == Enum.UserInputType.MouseMovement then
			tip.Position = UDim2.fromOffset(input.Position.X + 12, input.Position.Y + 12)
		end
	end)
	local function attachTooltip(guiObj, text)
		if not guiObj or not guiObj.IsA or not guiObj:IsA("GuiObject") then return end
		guiObj.MouseEnter:Connect(function()
			tipLbl.Text = text or ""
			tip.Size = UDim2.fromOffset(math.max(48, tipLbl.TextBounds.X + 16), 26)
			tip.Visible = true
		end)
		guiObj.MouseLeave:Connect(function() tip.Visible = false end)
	end

	-- Tabs + sections (collapsible)
	local tabCount = 0
	local currentTabBtn = nil
	local currentTabInner = nil

	local function closeAllDropdowns()
		for _, d in ipairs(pages:GetDescendants()) do
			if d:IsA("Frame") and d.Name == "List" and d.Visible then
				local holder = d.Parent
				d.Visible = false
				d.Size = UDim2.new(1,-140,0,0)
				if holder and holder:IsA("Frame") and (holder.Name == "Dropdown" or holder.Name == "MultiSelect") then
					holder.Size = UDim2.new(1,0,0,44)
				end
			end
		end
	end

	local function addTab(name, iconText)
		tabCount += 1
		local tabBtn = inst("TextButton",{Text=(iconText and iconText.."  " or "")..name, AutoButtonColor=false, Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=theme.Text, BackgroundColor3=Color3.fromRGB(28,28,34), Size=UDim2.new(1,0,0,34)})
		tabBtn.Parent=sidebar
		inst("UICorner",{CornerRadius=UDim.new(0,8)}).Parent=tabBtn
		local inner = inst("UIStroke",{Color=theme.Stroke, Thickness=1, Transparency=0.6}); inner.Parent=tabBtn
		wireHover(tabBtn); attachRipple(tabBtn)

		local tabPage = inst("ScrollingFrame",{BackgroundTransparency=1, Size=UDim2.new(1,-16,1,-16), Position=UDim2.new(0,8,0,8), CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=4, ScrollBarImageColor3=theme.Accent})
		local layout = inst("UIListLayout",{Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}); layout.Parent=tabPage
		inst("UIPadding",{PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}).Parent=tabPage

		local pageWrap = inst("Frame",{BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)}); pageWrap.Parent=pages; tabPage.Parent=pageWrap
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() tabPage.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 16) end)

		local function activate()
			if currentTabBtn and currentTabInner then
				twn(currentTabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28,28,34)}):Play()
				currentTabInner.Color = theme.Stroke
				currentTabInner.Transparency = 0.6
			end
			currentTabBtn = tabBtn
			currentTabInner = inner
			twn(tabBtn, TweenInfo.new(0.15), {BackgroundColor3 = theme.Accent}):Play()
			inner.Color = darken(theme.Accent, 0.25)
			inner.Transparency = 0.4

			pageLayout:JumpTo(pageWrap)
			closeAllDropdowns()
		end
		tabBtn.MouseButton1Click:Connect(activate)
		if tabCount == 1 then activate() end

		local function addSection(sectionTitle)
			local sec = inst("Frame",{BackgroundColor3=theme.BG, Size=UDim2.new(1,0,0,40), ClipsDescendants=true}); sec.Parent=tabPage
			inst("UICorner",{CornerRadius=UDim.new(0,8)}).Parent=sec
			inst("UIStroke",{Color=theme.Stroke, Thickness=1, Transparency=0.5}).Parent=sec

			local headerBtn = inst("TextButton",{Text=sectionTitle, Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=theme.Text, BackgroundTransparency=1, Size=UDim2.new(1,-40,0,28), Position=UDim2.new(0,12,0,6), AutoButtonColor=false, TextXAlignment=Enum.TextXAlignment.Left})
			headerBtn.Parent=sec
			local arrow = inst("TextLabel",{Text="▼", Font=Enum.Font.GothamBold, TextSize=14, TextColor3=theme.Muted, BackgroundTransparency=1, Size=UDim2.new(0,24,0,24), AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-8,0,8), TextXAlignment=Enum.TextXAlignment.Center})
			arrow.Parent=sec

			local list = inst("UIListLayout",{Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}); list.Parent=sec
			local pad = inst("UIPadding",{PaddingTop=UDim.new(0,30), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8), PaddingBottom=UDim.new(0,8)}); pad.Parent=sec

			local collapsed=false
			local function resize()
				if collapsed then
					twn(sec, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=UDim2.new(1,0,0,40)}):Play()
				else
					local h = pad.PaddingTop.Offset + pad.PaddingBottom.Offset + list.AbsoluteContentSize.Y + 24
					sec.Size = UDim2.new(1,0,0, h)
				end
			end
			list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)
			local function setCollapsed(v) collapsed=v arrow.Text = v and "►" or "▼" resize() end
			headerBtn.MouseButton1Click:Connect(function() setCollapsed(not collapsed) end)

			-- API per section
			local sectionApi = {}
			function sectionApi:AddToggle(txt, default, cb) local el, set = newToggle(theme, txt, default, cb) el.Parent=sec resize() return set end
			function sectionApi:AddButton(txt, cb) local el = newButton(theme, txt, cb) el.Parent=sec resize() return el end
			function sectionApi:AddSlider(txt, a,b, d, cb) local el, set = newSlider(theme, txt, a,b, d, cb) el.Parent=sec resize() return set end
			function sectionApi:AddTextbox(ttl, place, cb) local el, set = newTextbox(theme, ttl, place, cb) el.Parent=sec resize() return set end
			function sectionApi:AddDropdown(ttl, items, idx, cb) local el, set = newDropdown(theme, ttl, items, idx, cb) el.Parent=sec resize() return set end
			function sectionApi:AddKeybind(ttl, key, cb) local el, set = newKeybind(theme, ttl, key, cb) el.Parent=sec resize() return set end
			function sectionApi:AddColorRGB(ttl, col, cb) local el, set = newColorRGB(theme, ttl, col, cb) el.Parent=sec resize() return set end
			function sectionApi:AddLabel(text, muted)
				local holder = inst("Frame",{BackgroundColor3=theme.Panel, Size=UDim2.new(1,0,0,34)})
				inst("UICorner",{CornerRadius=UDim.new(0,8)}).Parent=holder
				inst("UIStroke",{Color=theme.Stroke, Thickness=1, Transparency=0.5}).Parent=holder
				holder.Parent=sec
				local lbl = inst("TextLabel",{Text=text, Font=Enum.Font.Gotham, TextSize=14, TextColor3 = (muted and theme.Muted or theme.Text), BackgroundTransparency=1, Size=UDim2.new(1,-24,1,0), Position=UDim2.new(0,12,0,0), TextXAlignment=Enum.TextXAlignment.Left})
				lbl.Parent=holder
				resize()
				return lbl
			end
			function sectionApi:AddMultiSelect(title, items, defaultList, cb) local el, set = newMultiSelect(theme, title, items, defaultList, cb) el.Parent=sec resize() return set end
			function sectionApi:AddNumber(title, min, max, step, default, cb) local el, set = newNumber(theme, title, min, max, step, default, cb) el.Parent=sec resize() return set end
			function sectionApi:AddSegment(title, items, defaultIndex, cb) local el, set = newSegment(theme, title, items, defaultIndex, cb) el.Parent=sec resize() return set end

			return sectionApi
		end

		return { Section = addSection, Button = tabBtn }
	end

	-- Window control + blur
	local isOpen = true
	local minimized = false
	local function setBlur(enabled, size) if blurEffect then blurEffect.Size = size or blurSize blurEffect.Enabled = enabled end end
	local function open()
		main.Visible = true
		mainScale.Scale = 0.96
		twn(mainScale, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
		if blurOnOpen then setBlur(true) end
		isOpen = true
	end
	local function close()
		local tw = twn(mainScale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.98})
		tw:Play()
		task.delay(0.12, function()
			main.Visible = false
			mainScale.Scale = 1
			if blurOnOpen then setBlur(false) end
			isOpen = false
		end)
	end
	local function toggle() if isOpen then close() else open() end end

	-- Minimize / RestoreDown
	local preMinSize, preMinPos = main.Size, main.Position
	local function minimize()
		if minimized then return end
		preMinSize, preMinPos = main.Size, main.Position
		body.Visible=false
		twn(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=UDim2.new(preMinSize.X.Scale, preMinSize.X.Offset, 0, 36)}):Play()
		minimized=true
	end
	local function restoreDown()
		if not minimized then return end
		body.Visible=true
		twn(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=preMinSize, Position=preMinPos}):Play()
		minimized=false
	end
	local function confirmClose() confirmModal.Visible=true end

	-- Edge + Corner snap + maximize
	local SNAP_MARGIN, SNAP_THRESHOLD = 12, 24
	local snapState = "normal" -- normal|left|right|max|tl|tr|bl|br
	local preSnapSize, preSnapPos = main.Size, main.Position
	local function cachePreRect() preSnapSize=main.Size preSnapPos=main.Position end
	local function applySnap(state)
		body.Visible = true
		local vp = viewport()
		local fullW, fullH = vp.X, vp.Y
		local halfW, halfH = math.floor(fullW/2), math.floor(fullH/2)
		local m = SNAP_MARGIN

		if state == "max" then
			twn(main, TweenInfo.new(0.18), {Position=UDim2.fromOffset(m, m), Size=UDim2.fromOffset(fullW - m*2, fullH - m*2)}):Play()
		elseif state == "left" then
			twn(main, TweenInfo.new(0.18), {Position=UDim2.fromOffset(m, m), Size=UDim2.fromOffset(halfW - math.floor(m*1.5), fullH - m*2)}):Play()
		elseif state == "right" then
			twn(main, TweenInfo.new(0.18), {Position=UDim2.fromOffset(halfW + math.floor(m*0.5), m), Size=UDim2.fromOffset(halfW - math.floor(m*1.5), fullH - m*2)}):Play()
		elseif state == "tl" then
			twn(main, TweenInfo.new(0.18), {Position=UDim2.fromOffset(m, m), Size=UDim2.fromOffset(halfW - math.floor(m*1.5), halfH - math.floor(m*1.5))}):Play()
		elseif state == "tr" then
			twn(main, TweenInfo.new(0.18), {Position=UDim2.fromOffset(halfW + math.floor(m*0.5), m), Size=UDim2.fromOffset(halfW - math.floor(m*1.5), halfH - math.floor(m*1.5))}):Play()
		elseif state == "bl" then
			twn(main, TweenInfo.new(0.18), {Position=UDim2.fromOffset(m, halfH + math.floor(m*0.5)), Size=UDim2.fromOffset(halfW - math.floor(m*1.5), halfH - math.floor(m*1.5))}):Play()
		elseif state == "br" then
			twn(main, TweenInfo.new(0.18), {Position=UDim2.fromOffset(halfW + math.floor(m*0.5), halfH + math.floor(m*0.5)), Size=UDim2.fromOffset(halfW - math.floor(m*1.5), halfH - math.floor(m*1.5))}):Play()
		end
		snapState = state
	end
	local function restoreFromSnap() if snapState~="normal" then twn(main, TweenInfo.new(0.18), {Position=preSnapPos, Size=preSnapSize}):Play() snapState="normal" end end
	local function toggleMaximize()
		if minimized then restoreDown() return end
		if snapState=="max" then restoreFromSnap() else if snapState=="normal" then cachePreRect() end applySnap("max") end
	end
	local function snapCheck()
		if minimized then return end
		local vp = viewport()
		local pos = main.AbsolutePosition
		local size = main.AbsoluteSize
		local nearTop    = pos.Y <= SNAP_THRESHOLD
		local nearLeft   = pos.X <= SNAP_THRESHOLD
		local nearRight  = (pos.X + size.X) >= (vp.X - SNAP_THRESHOLD)
		local nearBottom = (pos.Y + size.Y) >= (vp.Y - SNAP_THRESHOLD)

		if nearTop and nearLeft then if snapState=="normal" then cachePreRect() end applySnap("tl") return end
		if nearTop and nearRight then if snapState=="normal" then cachePreRect() end applySnap("tr") return end
		if nearBottom and nearLeft then if snapState=="normal" then cachePreRect() end applySnap("bl") return end
		if nearBottom and nearRight then if snapState=="normal" then cachePreRect() end applySnap("br") return end

	if nearTop then
	if snapState == "normal" then
		cachePreRect()
	end
	applySnap("max")
	return
end

if nearLeft then
	if snapState == "normal" then
		cachePreRect()
	end
	applySnap("left")
	return
end

if nearRight then
	if snapState == "normal" then
		cachePreRect()
	end
	applySnap("right")
	return
end

if snapState ~= "normal" then
	restoreFromSnap()
end

	local cam = workspace.CurrentCamera
	if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(function() if snapState~="normal" then applySnap(snapState) end end) end

	-- Drag + dblclick maximize
	makeDraggable(main, topbar, snapCheck)
	do
		local lastClick = 0
		topbar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local now = os.clock()
				if now - lastClick <= 0.3 then toggleMaximize() end
				lastClick = now
			end
		end)
	end

	-- Resizable (edges + corner)
	local MIN_W, MIN_H = 460, 260
	local function attachResize(handle, opts)
		local resizing=false local startPos,startSize,startMouse
		handle.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 then
				resizing=true startPos=main.Position startSize=main.Size startMouse=input.Position
				input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then resizing=false if snapCheck then snapCheck() end end end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not resizing or input.UserInputType~=Enum.UserInputType.MouseMovement then return end
			local dx = input.Position.X - startMouse.X
			local dy = input.Position.Y - startMouse.Y
			local w = math.max(MIN_W, startSize.X.Offset + ((opts.right and dx or 0) + (opts.left and -dx or 0)))
			local h = math.max(MIN_H, startSize.Y.Offset + ((opts.bottom and dy or 0) + (opts.top and -dy or 0)))
			local x = startPos.X.Offset + (opts.left and dx or 0)
			local y = startPos.Y.Offset + (opts.top and dy or 0)
			main.Size = UDim2.fromOffset(w,h)
			main.Position = UDim2.new(startPos.X.Scale, x, startPos.Y.Scale, y)
		end)
	end
	local function edgeHandle(name,size,pos) local f=Instance.new("Frame") f.Name=name f.BackgroundTransparency=1 f.Size=size f.Position=pos f.Parent=main return f end
	local hLeft   = edgeHandle("ResizeLeft",   UDim2.new(0,8, 1,-12), UDim2.new(0,0, 0,6))
	local hRight  = edgeHandle("ResizeRight",  UDim2.new(0,8, 1,-12), UDim2.new(1,-8, 0,6))
	local hTop    = edgeHandle("ResizeTop",    UDim2.new(1,-12, 0,8), UDim2.new(0,6, 0,0))
	local hBottom = edgeHandle("ResizeBottom", UDim2.new(1,-12, 0,8), UDim2.new(0,6, 1,-8))
	local hBR     = edgeHandle("ResizeBR",     UDim2.new(0,14, 0,14), UDim2.new(1,-14, 1,-14))
	attachResize(hLeft,   {left=true})
	attachResize(hRight,  {right=true})
	attachResize(hTop,    {top=true})
	attachResize(hBottom, {bottom=true})
	attachResize(hBR,     {right=true, bottom=true})

	-- Wire Mac buttons
	btnMin.MouseButton1Click:Connect(minimize)
	btnRest.MouseButton1Click:Connect(function() if minimized then restoreDown() else toggleMaximize() end end)
	btnClose.MouseButton1Click:Connect(confirmClose)
	ccCancel.MouseButton1Click:Connect(function() confirmModal.Visible=false end)
	ccDestroy.MouseButton1Click:Connect(function() if blurOnOpen and blurEffect then blurEffect.Enabled=false end screen:Destroy() end)

	-- Hotkey toggle
	UserInputService.InputBegan:Connect(function(input, gp) if gp then return end if input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==toggleKey then toggle() end end)

	-- ESC closes overlays and dropdowns
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
			if supportModal.Visible then supportModal.Visible = false return end
			if confirmModal.Visible then confirmModal.Visible = false return end
			-- close dropdowns
			closeAllDropdowns()
		end
	end)

	-- Mobile-only FAB
	local showFAB = if props.MobileFAB == nil then true else props.MobileFAB
	local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local fab = inst("TextButton", {
		Name="Milk_FAB", Parent=screen, Text="☰", Visible=isMobile and showFAB, AutoButtonColor=false,
		BackgroundColor3=theme.Accent, TextColor3=theme.Text, Font=Enum.Font.GothamSemibold, TextSize=16,
		AnchorPoint=Vector2.new(1,1), Position=UDim2.new(1,-14,1,-14), Size=UDim2.fromOffset(44,44), ZIndex=100000
	})
	inst("UICorner", {CornerRadius=UDim.new(1,0)}).Parent = fab
	inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.4}).Parent = fab
	local fabShadow = inst("ImageLabel", {BackgroundTransparency=1, Image="rbxassetid://5028857084", ImageTransparency=0.4, ImageColor3=Color3.new(0,0,0), ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(24,24,276,276), Size=UDim2.new(1,30,1,30), Position=UDim2.fromOffset(-15,-15), ZIndex=99999})
	fabShadow.Parent = fab
	makeDraggable(fab, fab)
	wireHover(fab); attachRipple(fab)
	fab.MouseButton1Click:Connect(function()
		twn(fab, TweenInfo.new(0.08), {Size=UDim2.fromOffset(40,40)}):Play()
		task.delay(0.1, function() twn(fab, TweenInfo.new(0.08), {Size=UDim2.fromOffset(44,44)}):Play() end)
		toggle()
	end)

	-- Command Palette
	local palette = { reg = {}, open = false }
	local palModal = inst("Frame", {Name="Milk_Palette", Parent=screen, BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.2, Visible = false, Size = UDim2.fromScale(1,1), ZIndex = 50000})
	local palCard = inst("Frame", {BackgroundColor3 = theme.Panel, Size = UDim2.fromOffset(420, 280), Position = UDim2.new(0.5,-210,0.3,-80)}); palCard.Parent = palModal
	inst("UICorner", {CornerRadius = UDim.new(0,10)}).Parent = palCard
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.4}).Parent = palCard
	local palBox = inst("TextBox", {PlaceholderText="Type a command...", Text="", ClearTextOnFocus=false, Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, PlaceholderColor3=theme.Muted, BackgroundColor3=Color3.fromRGB(28,28,34), Size=UDim2.new(1,-24,0,32), Position=UDim2.new(0,12,0,12)}); palBox.Parent = palCard
	inst("UICorner", {CornerRadius = UDim.new(0,6)}).Parent = palBox
	inst("UIStroke", {Color = theme.Stroke, Thickness = 1, Transparency = 0.5}).Parent = palBox
	local palList = inst("ScrollingFrame", {BackgroundTransparency=1, Size=UDim2.new(1,-24,1,-64), Position=UDim2.new(0,12,0,52), CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=3, ScrollBarImageColor3=theme.Accent})
	palList.Parent = palCard
	local palLayout = inst("UIListLayout", {Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder})
	palLayout.Parent = palList
	local function palCanvas() palList.CanvasSize = UDim2.new(0,0,0, palLayout.AbsoluteContentSize.Y + 12) end
	palLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(palCanvas)
	local function palScore(q, s) q=string.lower(q) s=string.lower(s) if q=="" then return 0 end local p=string.find(s,q,1,true) return p and (1000 - p*10 - #s) or -1 end
	local function palRebuild(filter)
		for _,c in ipairs(palList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
		local scored = {}
		for _,it in ipairs(palette.reg) do
			local best = math.max(palScore(filter or "", it.name), palScore(filter or "", it.tags or ""))
			if best >= 0 then table.insert(scored, {score=best, item=it}) end
		end
		table.sort(scored, function(a,b) return a.score > b.score end)
		for _,e in ipairs(scored) do
			local it = e.item
			local row = inst("TextButton", {Text = it.name, AutoButtonColor=false, Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.Text, BackgroundColor3=Color3.fromRGB(28,28,34), Size=UDim2.new(1,0,0,28)})
			inst("UICorner", {CornerRadius=UDim.new(0,6)}).Parent = row
			inst("UIStroke", {Color=theme.Stroke, Thickness=1, Transparency=0.6}).Parent = row
			row.Parent = palList
			row.MouseButton1Click:Connect(function() palModal.Visible=false palette.open=false pcall(it.cb) end)
		end
		palCanvas()
	end
	local function palOpen() palette.open=true palModal.Visible=true palBox.Text="" palBox:CaptureFocus() palRebuild("") end
	local function palClose() palette.open=false palModal.Visible=false end
	palBox:GetPropertyChangedSignal("Text"):Connect(function() palRebuild(palBox.Text) end)
	-- Hotkeys: Ctrl/Cmd + K
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftMeta)
			if ctrl and input.KeyCode == Enum.KeyCode.K then
				if palette.open then palClose() else palOpen() end
			end
		end
	end)
	-- FAB long-press to open palette
	do
		local touchStart = 0
		fab.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				touchStart = os.clock()
			end
		end)
		fab.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				if os.clock() - touchStart >= 0.35 then palOpen() end
			end
		end)
	end

	-- API
	local api = {}

	function api:Open() open() end
	function api:Close() close() end
	function api:Toggle() toggle() end
	function api:SetBlur(enabled, size) setBlur(enabled, size) end
	function api:AddTab(name, iconText) return addTab(name, iconText) end

	function api:ShowLoader(opts) opts=opts or {} loader.Visible=true lTitle.Text=opts.title or "Loading..." lSub.Text=opts.subtitle or "Please wait"
		barFill.Size=UDim2.new(0,0,1,0) task.wait(0.06) twn(barFill, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=UDim2.new(0.65,0,1,0)}):Play() end
	function api:HideLoader() twn(barFill, TweenInfo.new(0.25), {Size=UDim2.new(1,0,1,0)}):Play() task.delay(0.3,function() loader.Visible=false end) end

	-- RequireKey (no stacked handlers)
	do
		local verifyConn = nil
		function api:RequireKey(cfg)
			cfg = cfg or {mode="local"}
			keyModal.Visible = true
			statusLbl.Text = ""
			verifyBtn.Text = "Verify"

			local function setStatus(txt, good) statusLbl.Text=txt statusLbl.TextColor3 = good and theme.Accent or theme.Muted end
			local function finish() keyModal.Visible=false if cfg.onAuthorized then task.spawn(cfg.onAuthorized) end end

			if verifyConn then verifyConn:Disconnect() verifyConn=nil end
			verifyConn = verifyBtn.MouseButton1Click:Connect(function()
				local key = keyBox.Text
				if cfg.mode == "local" then
					local ok=false for _,k in ipairs(cfg.allowedKeys or {}) do if key==k then ok=true break end end
					if ok then setStatus("Authorized.", true) task.delay(0.5, finish) else setStatus("Invalid key.", false) end
				else
					setStatus("Verifying...", false)
					local ok, res = pcall(function()
						local url = assert(cfg.verifyUrl, "verifyUrl required for remote mode")
						return HttpService:RequestAsync({
							Url=url, Method="POST",
							Headers=cfg.headers or {["Content-Type"]="application/json"},
							Body=HttpService:JSONEncode({key=key, userId=LOCAL_PLAYER.UserId})
						})
					end)
					if ok and res.Success then
						local pass=false local parsed pcall(function() parsed = HttpService:JSONDecode(res.Body) end)
						pass = (type(parsed)=="table" and (parsed.ok==true or parsed.valid==true)) or (res.StatusCode==200)
						if pass then setStatus("Authorized.", true) task.delay(0.5, finish) else setStatus("Denied.", false) end
					else setStatus("Network error.", false) end
				end
			end)
		end
	end

	function api:ShowSupport(props) props=props or {} supTitle.Text=props.title or "Support" inviteBox.Text=props.inviteText or "discord.gg/your-code" copyBtn.Text=props.copyText or "Copy" supportModal.Visible=true end

	-- Mac/snap API
	function api:Minimize() minimize() end
	function api:RestoreDown() restoreDown() end
	function api:DestroyUI() confirmClose() end
	function api:Maximize() if snapState~="max" then if snapState=="normal" then cachePreRect() end applySnap("max") end end
	function api:Restore() restoreFromSnap() end
	function api:SnapLeft() if snapState=="normal" then cachePreRect() end applySnap("left") end
	function api:SnapRight() if snapState=="normal" then cachePreRect() end applySnap("right") end
	function api:SnapTL() if snapState=="normal" then cachePreRect() end applySnap("tl") end
	function api:SnapTR() if snapState=="normal" then cachePreRect() end applySnap("tr") end
	function api:SnapBL() if snapState=="normal" then cachePreRect() end applySnap("bl") end
	function api:SnapBR() if snapState=="normal" then cachePreRect() end applySnap("br") end
	function api:IsMaximized() return snapState=="max" end

	-- Status / Toasts / Tooltips / SFX / Notes
	api.CenterTopStatus = { Show=CT_Show, Update=CT_Update, Hide=CT_Hide }
	function api:Notify(o) notify(o) end
	function api:OpenNotifications() buildNotes() noteModal.Visible = true end
	function api:CloseNotifications() noteModal.Visible = false end
	function api:Tooltip(instance, text) attachTooltip(instance, text) end
	function api:SetSFX(on) sfxEnabled = not (on == false) end
	function api:SetSFXSound(soundId, volume) if soundId then sfxClick.SoundId = soundId end if volume then sfxClick.Volume = volume end end
	function api:SetMobileToggleVisible(visible) fab.Visible = visible and (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) or false end
	function api:SetMobileToggleIcon(text) if text then fab.Text = text end end

	-- Command Palette API + built-ins
	api.CommandPalette = {
		Register = function(_, name, cb, tags) table.insert(palette.reg, {name=name, cb=cb, tags=tags}) return #palette.reg end,
		Open = palOpen,
		Close = palClose
	}
	api.CommandPalette:Register("Toggle UI", function() api:Toggle() end, "show hide")
	api.CommandPalette:Register("Maximize", function() api:Maximize() end, "snap fit")
	api.CommandPalette:Register("Restore", function() api:Restore() end, "snap fit")
	api.CommandPalette:Register("Open Notifications", function() api:OpenNotifications() end, "history log alerts")

	-- Settings manager
	local settings = { _provider="memory", _filename="milkui_settings.json", _state={}, _loaded=true }
	local function safeDecode(s) local ok,d = pcall(function() return HttpService:JSONDecode(s) end) return ok and d or nil end
	local function safeEncode(t) local ok,s = pcall(function() return HttpService:JSONEncode(t) end) return ok and s or "{}" end
	function settings:UseMemory(init) self._provider="memory" self._state=init or {} self._loaded=true end
	function settings:UseFile(filename) self._provider="file" self._filename=filename or self._filename self._loaded=true
		local ok, content = pcall(function() if readfile then return readfile(self._filename) end end)
		if ok and type(content)=="string" then self._state=safeDecode(content) or {} end end
	function settings:_save() if self._provider=="file" and writefile then pcall(function() writefile(self._filename, safeEncode(self._state)) end) end end
	function settings:Get(key, default) local v=self._state[key] if v==nil then return default end return v end
	function settings:Set(key, val) self._state[key]=val self:_save() end
	function settings:Bind(key, default) local init=self:Get(key, default) local function onChange(v) self:Set(key,v) end return init, onChange end
	function settings:UseBridge(remoteFunction)
		self._provider="bridge" self._loaded=false self._remote=remoteFunction
		task.spawn(function() local ok,d = pcall(function() return self._remote:InvokeServer("load") end) if ok and type(d)=="table" then self._state=d end self._loaded=true end)
		function self:_save() if not self._remote then return end pcall(function() self._remote:InvokeServer("save", self._state) end) end
	endS
	api.Settings = settings
	function api:SettingsProvider() return settings end

	-- Window bounds persistence
	do
		local rect = api.Settings:Get("__milk_win_bounds", nil)
		if rect and rect.w and rect.h then
			main.Size = UDim2.fromOffset(rect.w, rect.h)
			main.Position = UDim2.new(0, rect.x, 0, rect.y)
		end
		local function saveBounds()
			local r = { x = main.Position.X.Offset, y = main.Position.Y.Offset, w = main.Size.X.Offset, h = main.Size.Y.Offset }
			api.Settings:Set("__milk_win_bounds", r)
		end
		main:GetPropertyChangedSignal("Position"):Connect(saveBounds)
		main:GetPropertyChangedSignal("Size"):Connect(saveBounds)
	end
	function api:RestoreSavedBounds()
		local rect = api.Settings:Get("__milk_win_bounds")
		if rect and rect.w and rect.h then
			main.Size = UDim2.fromOffset(rect.w, rect.h)
			main.Position = UDim2.new(0, rect.x, 0, rect.y)
		end
	end

	-- Init open
	local function doOpen() main.Visible = true if blurOnOpen then setBlur(true) end end
	doOpen()

	return api
end

return MilkUI
































































































































    
-- why are you here nigga this is end of the source
