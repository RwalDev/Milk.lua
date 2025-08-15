Here’s the complete documentation you can drop into your repo as README.md. It covers every feature in the merged MilkUI, with usage for PC and mobile, all elements, modals, effects, settings, and persistence.

# MilkUI — Full Documentation

A modern Roblox UI library with a “Milk / EvilMilk” vibe:
- Movable, resizable, edge-snapping window with Mac-style traffic lights
- Tabs → Collapsible Sections → Elements
- Blur-on-open, smooth tweens, hover + ripple FX, click SFX
- Loader, Key System (local/remote), Support panel
- CenterTop status bar, Toast notifications, Tooltips
- Settings persistence (memory/file/bridge) + window position/size persistence
- Mobile-only floating toggle button (FAB)

### Contents
- Install
- Quick start
- Window options (MilkUI.new)
- Window API
- Tabs, Sections, Elements
- Modals and overlays
- Status, Toasts, Tooltips, SFX
- Settings persistence and server bridge
- Mobile features
- Customization and styling
- Performance tips
- Troubleshooting
- Compliance notes
- Changelog

### Quick start
```lua
local win = MilkUI.new({
  Title = "Milk.lua",
  SubTitle = "Blue + Red vibes",
  Theme = "BlueRed",     -- "Milk" | "EvilMilk" | "BlueRed"
  Glass = true,          -- optional glassmorphism
  BlurOnOpen = true,
  BlurSize = 20,
  KeyToggle = Enum.KeyCode.RightControl,
  MobileFAB = true,      -- show mobile-only floating toggle button
  Size = UDim2.fromOffset(560, 400),
})

-- Settings provider (file if available; else memory)
win.Settings:UseFile("milkui_settings.json")

-- Build UI
local tab = win:AddTab("Blatant", "⚡")
local s1  = tab.Section("Controls")
local s2  = tab.Section("More")

-- Toggle with persistence
local initGod, saveGod = win.Settings:Bind("god_mode", false)
s1:AddToggle("God Mode", initGod, saveGod)

-- Slider with persistence
local initSpd, saveSpd = win.Settings:Bind("speed", 25)
s1:AddSlider("Speed", 0, 100, initSpd, saveSpd)

-- Other elements
s1:AddTextbox("Title", "Any minds?", function(txt) win:Notify({icon="💬", title="Input", message=txt}) end)
s1:AddButton("Ping", function() win:Notify({icon="✅", title="Pong", message="Clicked", kind="success"}) end)

local ddInit, ddSave = win.Settings:Bind("mode", "Silent")
local setMode = s2:AddDropdown("Mode", {"Silent","Rage","Legit"}, nil, ddSave)
setMode(ddInit)

s2:AddKeybind("Toggle UI", Enum.KeyCode.RightControl, function() win:Toggle() end)
s2:AddColorRGB("Accent", Color3.fromRGB(56,144,255), function(c) print("Color:", c) end)
s2:AddLabel("This is a label")

-- Status HUD
win.CenterTopStatus.Show("Schedule", Color3.fromRGB(255,70,95))
win.CenterTopStatus.Update(0.35)
task.delay(2, function() win.CenterTopStatus.Hide() end)
```

### Window options (MilkUI.new)
```lua
local win = MilkUI.new({
  Title: string,              -- window title
  SubTitle: string?,          -- small subtitle under title
  Theme: "Milk" | "EvilMilk" | "BlueRed",
  Glass: boolean?,            -- glassmorphism (soft transparency + noise)
  BlurOnOpen: boolean?,       -- default true
  BlurSize: number?,          -- default 18
  KeyToggle: Enum.KeyCode?,   -- default RightControl
  MobileFAB: boolean?,        -- default true (only shows on mobile/touch)
  Size: UDim2?,               -- default 560x400
  Position: UDim2?,           -- default centered
})
```

### Window API
- Visibility and blur
  - win:Open()
  - win:Close()
  - win:Toggle()
  - win:SetBlur(enabled: boolean, size?: number)
- Tabs
  - win:AddTab(name: string, iconText?: string) -> tab
- Mac buttons and resizing
  - win:Minimize()               -- collapse to topbar
  - win:RestoreDown()            -- restore from minimize
  - win:DestroyUI()              -- open confirm modal, destroy on confirm
  - win:Maximize()               -- fill viewport (with margin)
  - win:Restore()                -- restore from maximize/snap
  - win:SnapLeft()               -- left half
  - win:SnapRight()              -- right half
  - win:IsMaximized() -> boolean
- Mobile FAB
  - win:SetMobileToggleVisible(bool)
  - win:SetMobileToggleIcon(text: string)
- Window bounds persistence
  - Automatically saved on move/resize (Settings key: "__milk_win_bounds")
  - win:RestoreSavedBounds()     -- re-apply saved bounds (useful after switching provider)

### Interactions
- Drag the topbar to move
- Resize from edges/corner
- Snap: drag to top (maximize), left/right (half)
- Double-click topbar to toggle maximize
- Mac traffic lights:
  - Red = Close (confirm+destroy)
  - Yellow = Minimize
  - Green = Maximize/Restore

### Tabs, Sections, Elements
### Tabs
```lua
local tab = win:AddTab("Player", "👤")  -- emoji or icon text allowed
```

### Sections (collapsible)
```lua
local sec = tab.Section("Section Header")
-- Click the section header to collapse/expand
```

### Elements (all return a setter or instance)
- Toggle
  - sec:AddToggle(label: string, default: boolean, callback: (state: boolean) -> ()) -> set(newState: boolean)
- Button
  - sec:AddButton(text: string, callback: () -> ()) -> TextButton
- Slider
  - sec:AddSlider(label: string, min: number, max: number, default: number, callback: (value: number) -> ()) -> set(newValue: number)
- Textbox
  - sec:AddTextbox(title: string, placeholder: string, callback: (text: string, enterPressed: boolean) -> ()) -> setText(text: string)
- Dropdown (fixed: expands holder to avoid clipping; closes on outside click)
  - sec:AddDropdown(title: string, items: {string}, defaultIndex?: number, callback: (value: string) -> ()) -> setValue(value: string)
- Keybind
  - sec:AddKeybind(title: string, defaultKeyCode?: Enum.KeyCode, callback: () -> ()) -> setBinding(Enum.KeyCode | nil)
- ColorRGB (R/G/B sliders + preview)
  - sec:AddColorRGB(title: string, defaultColor?: Color3, callback: (color: Color3) -> ()) -> setColor(Color3)
- Label
  - sec:AddLabel(text: string, muted?: boolean) -> TextLabel

### Element usage boxes
Toggle
```lua
local init, save = win.Settings:Bind("god", false)
local setGod = sec:AddToggle("God Mode", init, save)
-- setGod(true)
```

Button
```lua
sec:AddButton("Ping", function()
  win:Notify({icon="✅", title="Pong", message="Clicked", kind="success"})
end)
```

Slider
```lua
local init, save = win.Settings:Bind("fov", 90)
local setFov = sec:AddSlider("FOV", 60, 120, init, save)
```

Textbox
```lua
local setName = sec:AddTextbox("Name", "Type here...", function(text) print("name:", text) end)
-- setName("Player1")
```

Dropdown
```lua
local init, save = win.Settings:Bind("mode", "Silent")
local setMode = sec:AddDropdown("Mode", {"Silent","Rage","Legit"}, nil, save)
setMode(init)
```

Keybind
```lua
local setHotkey = sec:AddKeybind("Toggle UI", Enum.KeyCode.RightControl, function()
  win:Toggle()
end)
-- setHotkey(Enum.KeyCode.RightAlt)
```

ColorRGB
```lua
local setAccent = sec:AddColorRGB("Accent", Color3.fromRGB(56,144,255), function(c)
  print("Color:", c)
end)
-- setAccent(Color3.fromRGB(255,70,95))
```

Label
```lua
sec:AddLabel("Info line")
sec:AddLabel("Muted note", true)
```

Modals and overlays
Loader
```lua
win:ShowLoader({ title = "Loading UI", subtitle = "Initializing..." })
task.wait(0.7)
win:HideLoader()
```

Key System
- Local mode
```lua
win:RequireKey({
  mode = "local",
  allowedKeys = {"MY-KEY-1", "MY-KEY-2"},
  onAuthorized = function() print("OK") end
})
```
- Remote mode (client HTTP; consider server bridge)
```lua
win:RequireKey({
  mode = "remote",
  verifyUrl = "https://your.api/verify",
  headers = {["Content-Type"] = "application/json"},
  onAuthorized = function() print("OK") end
})
```

Support panel
```lua
win:ShowSupport({ title = "Community", inviteText = "discord.gg/your-code", copyText = "Copy" })
```

### Status, Toasts, Tooltips, SFX
CenterTop status bar
```lua
win.CenterTopStatus.Show("Schedule", Color3.fromRGB(255,70,95))
win.CenterTopStatus.Update(0.35)  -- 0..1
win.CenterTopStatus.Hide()
```

Toasts (icon + action)
```lua
win:Notify({icon="💾", title="Saved", message="Settings persisted", kind="success"})
win:Notify({
  icon="⚠️", title="Heads up", message="Edge snap enabled",
  duration=4, actionText="Learn more", onAction=function() print("clicked") end
})
```

Tooltips
```lua
local btn = sec:AddButton("Hover me", function() end)
win:Tooltip(btn, "Runs an action")
```

SFX
```lua
win:SetSFX(true)                          -- enable click SFX
win:SetSFXSound("rbxassetid://12345678")  -- change click sound
```

### Settings persistence and server bridge
Providers
- Memory: in-session default (no disk)
- File: readfile/writefile JSON
- Bridge: RemoteFunction to server (DataStore)

### API
```lua
win.Settings:UseMemory(initialTable?)
win.Settings:UseFile(filename?)                 -- "milkui_settings.json" default
win.Settings:UseBridge(RemoteFunction)
win.Settings:Get(key, default?) -> any
win.Settings:Set(key, value)
win.Settings:Bind(key, default) -> (initialValue, onChange)
```

### Binding pattern
```lua
local init, save = win.Settings:Bind("speed", 25)
local setSpeed = sec:AddSlider("Speed", 0, 100, init, save)
```
Client:
```lua
win.Settings:UseBridge(game.ReplicatedStorage.MilkUI_SettingsRF)
-- If you switch provider after building window, re-apply saved bounds:
win:RestoreSavedBounds()
```

### Mobile features
- Floating Action Button (FAB) appears only on touch devices (no keyboard) by default.
- Draggable FAB; toggles the UI visibility.
- Control it:
```lua
win:SetMobileToggleVisible(true)
win:SetMobileToggleIcon("≡")
```

### Customization and styling
- Themes: "Milk" (blue), "EvilMilk" (red), "BlueRed" (mix). Edit the Themes table to tune colors.
- Glassmorphism: set Glass=true in MilkUI.new for subtle transparency and noise.
- Animations: tweens are Quad/Out at 0.12–0.2s for responsiveness.
- Hover/ripple FX and SFX are auto-wired to TextButtons. You can override via your own styling if needed.

### Performance tips
- Build UI once. Use the returned setter functions to update values without rebuilding controls.
- Keep toast count and durations reasonable.
- Long-running callbacks should use task.spawn (library already does this for you).
- Avoid spamming RequireKey; it de-duplicates button connections but keep modals lean.

### Troubleshooting
- UI doesn’t appear
  - Ensure MilkUI ModuleScript is in ReplicatedStorage and you require it from a LocalScript.
  - Check output for typos if you manually edited code.
- Dropdown overlaps/clips
  - Fixed: dropdown expands its holder (no overlay). If you still override ClipsDescendants, ensure sections can grow.
- Key modal verify firing twice
  - Fixed: handler is de-duplicated. If you wrapped RequireKey yourself multiple times, ensure you call it once per need.
- File provider not saving
  - readfile/writefile work only in specific environments. Fallback to UseMemory or UseBridge.
- Clipboard “Unavailable”
  - setclipboard/syn.write_clipboard aren’t always present; display the code for manual copy.

### Compliance notes
- External links (including Discord) are restricted by Roblox rules. Use the Support panel responsibly.
- Don’t gate core gameplay behind external key systems in public experiences; follow Roblox Terms of Use.
- Don’t store sensitive data client-side; use the Bridge provider to save via server/DataStore.
