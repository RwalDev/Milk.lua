# MilkUI

Sexy, smooth, draggable UI with tabs/sections/elements, blur-on-open, loader, key system, support panel, Mac-style topbar buttons, and a CenterTop status bar.

## Features
- Movable window with tweened transitions + soft shadows
- Tabs → Sections → Elements (Toggle, Button, Slider, Textbox, Dropdown, Keybind, RGB color)
- Themes: `Milk` (blue), `EvilMilk` (red), `BlueRed` (mixed)
- Blur when opened; blur off when closed (configurable)
- Loading screen modal (animated)
- Key System (local or remote HTTP verification)
- Support panel (safe “copy” behavior only if clipboard APIs exist)
- Mac-style window buttons
- CenterTop status bar (text + progress)


## Quick Start
```lua
local win = MilkUI.new({
	Title = "Milk.lua", -- title
	SubTitle = "custom ui lol", -- subtitle
	Theme = "EvilMilk", -- Themes: `Milk` (blue), `EvilMilk` (red), `BlueRed` (mixed)
	BlurOnOpen = true, -- blur option
	KeyToggle = Enum.KeyCode.RightControl, -- keybind
	Size = UDim2.fromOffset(560, 400), -- size
})

-- Optional: Loader
win:ShowLoader({title = "Loading UI", subtitle = "Initializing..."})
task.wait(0.8)
win:HideLoader()

-- Tabs/Sections/Elements
local t = win:AddTab("Blatant", "⚡")
local s = t.Section("Section")
s:AddToggle("God Mode", false, function(v) print("God Mode:", v) end)
s:AddSlider("Speed", 0, 100, 25, function(v) print("Speed:", v) end)
s:AddTextbox("Title", "Any minds?", function(txt) print(txt) end)
s:AddDropdown("Mode", {"Silent","Rage","Legit"}, 1, function(choice) print(choice) end)
s:AddKeybind("Toggle UI", Enum.KeyCode.RightControl, function() win:Toggle() end)
s:AddColorRGB("Accent", Color3.fromRGB(56,144,255), function(c) print(c) end)

-- CenterTop status bar
win.CenterTopStatus.Show("Schedule", Color3.fromRGB(255,70,95))
win.CenterTopStatus.Update(0.3)
```
