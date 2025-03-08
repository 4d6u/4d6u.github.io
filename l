
----------------------------------------------------------------------------Clone----------------------------------------------------------------------------

local function Clone<Original>(ToClone: any & Original): (Original, boolean)
	local Type = typeof(ToClone)

	if Type == "function" and (clonefunc or clonefunction) then
		return (clonefunc or clonefunction)(ToClone), true
	elseif Type == "Instance" and (cloneref or clonereference) then
		return (cloneref or clonereference)(ToClone), true
	elseif Type == "table" then
		local function deepcopy(orig, copies: { [any]: any }?)
			local Copies = copies or {}
			local orig_type, copy = typeof(orig), nil

			if orig_type == 'table' then
				if Copies[orig] then
					copy = Copies[orig]
				else		
					copy = {}

					Copies[orig] = copy

					for orig_key, orig_value in next, orig, nil do
						copy[deepcopy(orig_key, Copies)] = deepcopy(orig_value, Copies)
					end

					(setrawmetatable or setmetatable)(copy, deepcopy((getrawmetatable or getmetatable)(orig), Copies))
				end
			elseif orig_type == 'Instance' or orig_type == 'function' then
				copy = Clone(orig)
			else
				copy = orig
			end

			return copy
		end

		return deepcopy(ToClone), true
	else
		return ToClone, false
	end
end
----------------------------------------------------------------------------Assets----------------------------------------------------------------------------

local assets = {
	-- // Other
	["blur"] = "rbxassetid://14898786664",
	-- // Math
	["add"] = "rbxassetid://104139909383590",
	["info"] = "rbxassetid://109646362097217",
	["alert"] = "rbxassetid://139385364959450",
	["close"] = "rbxassetid://77367799578664",
	["remove"] = "rbxassetid://137055312496892",
	-- // Cloud
	["cloud"] = "rbxassetid://117141460305133",
	["cloud-off"] = "rbxassetid://134447236078140",
	["cloud-cog"] = "rbxassetid://128517603711091",
	["cloud-alert"] = "rbxassetid://94021481559742",
	["cloud-download"] = "rbxassetid://113347432173040",
}

local Pallet = {
	Main = Color3.fromRGB(26, 25, 26),
	Text = Color3.fromRGB(200, 200, 200),
	Font = Enum.Font.Gotham,
	FontSemiBold = Font.fromName("Montserrat", Enum.FontWeight.SemiBold),
	Tween = TweenInfo.new(0.16, Enum.EasingStyle.Linear)
}

----------------------------------------------------------------------------Variables----------------------------------------------------------------------------

local HTTP = Clone(game:GetService("HttpService"))
local Tween = Clone(game:GetService("TweenService"))
local Run = Clone(game:GetService("RunService"))
local TEXT = Clone(game:GetService("TextService"))
local Content = Clone(game:GetService("ContentProvider"))
local Market = Clone(game:GetService("MarketplaceService"))
local Input = Clone(game:GetService("UserInputService"))
local GUI = Clone(game:GetService("GuiService"))

local Library = {
	Name = "NixLib",
	Version = "1.0",
	ThreadFix = (setthreadidentity or set_thread_identity) and true or false,
	Place = game.PlaceId,
	NotificationsEnabled = true,
	TweenEnabled = true,
	FadeEnabled = true,
	Config = {},
	Modules = {},
	Profiles = {},
	Tabs = {},
	Windows = {}
}

local tween = {
	tweens = {},
	tweenstwo = {}
}

----------------------------------------------------------------------------Executor Support----------------------------------------------------------------------------

if identifyexecutor and table.find({"Velocity"}, ({identifyexecutor()})[1]) then
	local JsonWrite
JsonWrite = hookfunction(writefile, function(Event,...)

    if (Event):match("%.json$") ~= nil then
        warn((Event):gsub("%.json$", ".txt"),...)
        return JsonWrite((Event):gsub("%.json$", ".txt"),...)
    else
        warn(Event,...)
        return JsonWrite(Event,...)
    end

end)

local JasonRead
JasonRead = hookfunction(readfile, function(Event,...)

    if (Event):match("%.json$") ~= nil then
        warn((Event):gsub("%.json$", ".txt"),...)
        return JasonRead((Event):gsub("%.json$", ".txt"),...)
    else
        warn(Event,...)
        return JasonRead(Event,...)
    end

end)
end

local isfile = isfile or function(File)
	local success, result = pcall(function()
		return readfile(File)
	end)
	return success and result ~= nil and result ~= ''
end

----------------------------------------------------------------------------Main GUI----------------------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = HTTP:GenerateGUID(true)
ScreenGui.DisplayOrder = math.huge
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = (function() -- https://github.com/Pepsied-5229/Pepsi-UI-Library/blob/main/Pepsi-UI-Library.lua#L503
	local success, result = pcall(function()
		return (gethui or get_hidden_ui)()
	end)

	if success and result then
		return result
	end

	success, result = pcall(function()
		local CoreGui = game:GetService("CoreGui")

		CoreGui:GetFullName()

		return CoreGui
	end)

	if success and result then
		return result
	end

	success, result = pcall(function()
		return (game:IsLoaded() or game.Loaded:Wait() or true) and game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 10)
	end)

	if success and result then
		return result
	end

	success, result = pcall(function()
		local StarterGui = game:GetService("StarterGui")

		StarterGui:GetFullName()

		return StarterGui
	end)

	if success and result then
		return result
	end

	return error("How did you even find an executor as bad as that???",0)
end)()

local ScaledGui = Instance.new("Frame")
ScaledGui.Name = "ScaledGui"
ScaledGui.Size = UDim2.fromScale(1, 1)
ScaledGui.BackgroundTransparency = 1
ScaledGui.Parent = ScreenGui
local ClickGui = Instance.new("Frame")
ClickGui.Name = "ClickGui"
ClickGui.Size = UDim2.fromScale(1, 1)
ClickGui.BackgroundTransparency = 1
ClickGui.Parent = ScaledGui
local Notifications = Instance.new("Folder")
Notifications.Name = "Notifications"
Notifications.Parent = ScaledGui
----------------------------------------------------------------------------Library Functions----------------------------------------------------------------------------

function tween:Tween(obj, tweeninfo, goal, tab)
    tab = tab or self.tweens
    if tab[obj] then
        tab[obj]:Cancel()
        tab[obj] = nil
    end

    if obj.Parent then
        tab[obj] = Tween:Create(obj, tweeninfo, goal)
        tab[obj].Completed:Once(function()
            if tab then
                tab[obj] = nil
                tab = nil
            end
        end)
        tab[obj]:Play()
    else
        for i, v in goal do
            obj[i] = v
        end
    end
end

function tween:Cancel(obj)
    if self.tweens[obj] then
        self.tweens[obj]:Cancel()
        self.tweens[obj] = nil
    end
end

local function removeTags(str)
	str = str:gsub('<br%s*/>', '\n')
	return str:gsub('<[^<>]->', '')
end

local function Darken(color, amount)
	local h, s, v = color:ToHSV()
	return Color3.fromHSV(h, s, math.clamp(select(3, Pallet.Main:ToHSV()) > 0.5 and v + amount or v - amount, 0, 1))
end

local function Brighten(color, amount)
	local h, s, v = color:ToHSV()
	return Color3.fromHSV(h, s, math.clamp(select(3, Pallet.Main:ToHSV()) > 0.5 and v - amount or v + amount, 0, 1))
end

local function Corner(parent, radius)
	local corner = Instance.new('UICorner')
	corner.CornerRadius = radius or UDim.new(0, 5)
	corner.Parent = parent

	return corner
end

local function Blur(parent)
	local blur = Instance.new('ImageLabel')
	blur.Name = 'Blur'
	blur.Size = UDim2.new(1, 89, 1, 52)
	blur.Position = UDim2.fromOffset(-48, -31)
	blur.BackgroundTransparency = 1
	blur.Image = assets["blur"]
	blur.ScaleType = Enum.ScaleType.Slice
	blur.SliceCenter = Rect.new(52, 31, 261, 502)
	blur.Parent = parent

	return blur
end

scale = Instance.new('UIScale')
scale.Scale = math.max(ScreenGui.AbsoluteSize.X / 1920, 0.6)
scale.Parent = ScaledGui

local dragging = false
local function Draggable(gui, window)
	gui.InputBegan:Connect(function(inputObj)
		if window and not window.Visible then return end
		if
			(inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
			and (inputObj.Position.Y - gui.AbsolutePosition.Y < 40 or window)
		then
			dragging = false
			local dragPosition = Vector2.new(
				gui.AbsolutePosition.X - inputObj.Position.X,
				gui.AbsolutePosition.Y - inputObj.Position.Y + GUI:GetGuiInset().Y
			) / scale.Scale

			local changed = Input.InputChanged:Connect(function(input)
				if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
					dragging = true
					local position = input.Position
					if Input:IsKeyDown(Enum.KeyCode.LeftShift) then
						dragPosition = (dragPosition // 3) * 3
						position = (position // 3) * 3
					end
					gui.Position = UDim2.fromOffset((position.X / scale.Scale) + dragPosition.X, (position.Y / scale.Scale) + dragPosition.Y)
				end
			end)

			local ended
			ended = inputObj.Changed:Connect(function()
				if inputObj.UserInputState == Enum.UserInputState.End then
					if changed then
						changed:Disconnect()
					end
					if ended then
						ended:Disconnect()
					end
				end
			end)
		end
	end)
end

local fontsize = Instance.new('GetTextBoundsParams')
fontsize.Width = math.huge

local tooltip = Instance.new("TextLabel")
tooltip.Name = "Tooltip"
tooltip.Position = UDim2.fromScale(-1, -1)
tooltip.ZIndex = 5
tooltip.BackgroundColor3 = Darken(Pallet.Main, .02)
tooltip.Text = ''
tooltip.TextColor3 = Darken(Pallet.Text, .16)
toolblur = Blur(tooltip)
Corner(tooltip)
local toolstrokebkg = Instance.new('Frame')
toolstrokebkg.Size = UDim2.new(1, -2, 1, -2)
toolstrokebkg.Position = UDim2.fromOffset(1, 1)
toolstrokebkg.ZIndex = 6
toolstrokebkg.BackgroundTransparency = 1
toolstrokebkg.Parent = tooltip
local toolstroke = Instance.new('UIStroke')
toolstroke.Color = Brighten(Pallet.Main, 0.02)
toolstroke.Parent = toolstrokebkg
Corner(toolstrokebkg, UDim.new(0, 4))

local getfontsize = function(text, size, font)
	fontsize.Text = text
	fontsize.Size = size
	if typeof(font) == 'Font' then
		fontsize.Font = font
	end
	return TEXT:GetTextBoundsAsync(fontsize)
end

local function Tooltip(gui, text)
	if not text then return end

	local function tooltipMoved(x, y)
		local right = x + 16 + tooltip.Size.X.Offset > (scale.Scale * 1920)
		tooltip.Position = UDim2.fromOffset(
			(right and x - (tooltip.Size.X.Offset * scale.Scale) - 16 or x + 16) / scale.Scale,
			((y + 11) - (tooltip.Size.Y.Offset / 2)) / scale.Scale
		)
		tooltip.Visible = toolblur.Visible
	end

	gui.MouseEnter:Connect(function(x, y)
		local tooltipSize = getfontsize(text, tooltip.TextSize, Pallet.Font)
		tooltip.Size = UDim2.fromOffset(tooltipSize.X + 10, tooltipSize.Y + 10)
		tooltip.Text = text
		tooltipMoved(x, y)
	end)
	gui.MouseMoved:Connect(tooltipMoved)
	gui.MouseLeave:Connect(function()
		tooltip.Visible = false
	end)
end


----------------------------------------------------------------------------New Window----------------------------------------------------------------------------

function Library:Window(Config)
    Config = Config or {}

    if not Config.Title then
		local success, result = pcall(function()
			return Market:GetProductInfo(Library.Place).Name
		end)

		Config.Title = success and result or "Window"
    end

    Library.MinimizeKey = if typeof(Config.MinimizeKey) == "EnumItem" and Config.MinimizeKey.EnumType == Enum.KeyCode then Config.MinimizeKey else Enum.KeyCode.LeftControl
    Library.Theme = if typeof(Config.Theme) == "string" then Config.Theme else "Dark"

	local size = UDim2.fromScale(math.max(getfontsize(removeTags(Config.Title), 31, Pallet.FontSemiBold).X + 10, 266) / ScreenGui.AbsoluteSize.X, 63 / ScreenGui.AbsoluteSize.Y)
	-- // The main window
    local Window = Instance.new("TextButton")
    Window.BackgroundColor3 = Darken(Pallet.Main, .02)
    Window.BorderSizePixel = 0
    Window.Position = UDim2.fromOffset(28, 14)
    Window.Size = size
    Window.Text = ""
    Window.AutoButtonColor = false
    Window.Parent = ClickGui
    Corner(Window)
    Blur(Window)
    Draggable(Window)

	-- // The title
	local Title = Instance.new("TextLabel")
	Title.BackgroundTransparency = 1
	Title.BorderSizePixel = 0
	Title.Position = UDim2.fromScale(0.039,0.251)
	Title.Size = UDim2.fromScale(1,.45)
	Title.FontFace = Pallet.FontSemiBold
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.RichText = true
	Title.TextScaled = true
    Title.TextWrapped = true
	Title.Text = "<stroke color='#FFFFFF' joins='round' thickness='0.3' transparency='0.5'>"..Config.Title.."</stroke>"
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Window

	-- // The tabs
	local Tabs = Instance.new("Frame")
	Tabs.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	Tabs.BorderSizePixel = 0
	Tabs.Position = UDim2.fromScale(0, 1.1)
	Tabs.Size = UDim2.fromScale(1,5)
	Tabs.Parent = Window
	Corner(Tabs)
	local tabblur = Blur(Tabs)

	local windowOpen = true
	local tabsOpen = true

	-- // Minimize
    Input.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Library.MinimizeKey and not gameProcessed then
			windowOpen = not windowOpen
			if Library.TweenEnabled then
				local ssize = windowOpen and size or UDim2.fromScale(0,0)
				tween:Tween(Window, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
					Size = ssize
				})
			end
		end
    end)

	-- // Invisible
	Window:GetPropertyChangedSignal("Size"):Connect(function()
	    if Window.Size.X.Scale <= 0 then
		    Window.Visible = false
	    else
		    Window.Visible = true
	    end
	end)

	-- // Click to close
	Window.MouseButton1Click:Connect(function()
		if dragging then return end
		tabsOpen = not tabsOpen
		if Library.TweenEnabled then
			local size = tabsOpen and UDim2.fromScale(1,5) or UDim2.fromScale(1,0)
			local transparency = tabsOpen and 0 or 1
			tween:Tween(Tabs, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = size
			})
			tween:Tween(tabblur, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				ImageTransparency = transparency
			})
		end
	end)

	Tabs:GetPropertyChangedSignal("Size"):Connect(function()
		if Tabs.Size == UDim2.fromScale(1,0) then
			Tabs.Visible = false
		else
			Tabs.Visible = true
		end
	end)
end

function Library:Notification(Config)
    Config = Config or {}

	local i = #Notifications:GetChildren() + 1
	local Notification = Instance.new("TextButton")
	Notification.Name = "Notification"
	Notification.AutoButtonColor = false
	Notification.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	Notification.Size = UDim2.fromOffset(math.max(getfontsize(removeTags(Config.Text), 14, Pallet.Font).X + 80, 266), 75)
	Notification.Position = UDim2.new(1, 0, 1, -(29 + (78 * i)))
	Notification.BorderColor3 = Color3.new()
	Notification.Text = ""
	Notification.Parent = Notifications
	Corner(Notification)
	Blur(Notification)

	Notification.MouseButton1Click:Connect(function()
		if Library.TweenEnabled then
			tween:Tween(Notification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
				AnchorPoint = Vector2.new(0, 0)
			})
		end
		task.wait(.2)
		Notification:ClearAllChildren()
		Notification:Destroy()
	end)

	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.new(0, 6, 0, 6)
	Title.Size = UDim2.new(0.621254444, 0, 0.230740383, 0)
	Title.Font = Enum.Font.Gotham
	Title.RichText = true
	Title.Text = "<stroke color='#FFFFFF' joins='round' thickness='0.3' transparency='0.5'>"..(Config.Title or "Notification").."</stroke>"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextSize = 16
	Title.TextWrapped = true
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Notification

	local ImageButton = Instance.new("ImageButton")

	--Properties:
	
	ImageButton.Parent = game.StarterGui.ScreenGui
	ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageButton.BorderSizePixel = 0
	ImageButton.Position = UDim2.new(0.0255241562, 0, 0.126822159, 0)
	ImageButton.Size = UDim2.new(0, 100, 0, 100)
	ImageButton.Image = "rbxasset://sky/moon.jpg"

	
	local Text = Instance.new("TextLabel")
	Text.Name = "Text"
	Text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Text.BackgroundTransparency = 1.000
	Text.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Text.BorderSizePixel = 0
	Text.Position = UDim2.new(0, 6, 0, 24)
	Text.Size = UDim2.new(0.95111084, 0, 0.656202078, 0)
	Text.Font = Enum.Font.GothamMedium
	Text.Text = Config.Text
	Text.TextColor3 = Color3.fromRGB(180, 180, 180)
	Text.TextSize = 14.000
	Text.TextWrapped = true
	Text.TextXAlignment = Enum.TextXAlignment.Left
	Text.TextYAlignment = Enum.TextYAlignment.Top
	Text.Parent = Notification

	local Timer = Instance.new("Frame")
	Timer.Name = "Timer"
    Timer.BorderSizePixel = 0
	Timer.BackgroundColor3 = Color3.fromRGB(220,220,220)
	Timer.Position = UDim2.new(0, 0, 0.96, 0)
	Timer.Size = UDim2.new(1, 0, 0, 3)
	Timer.Parent = Notification

	if Library.TweenEnabled then
		tween:Tween(Notification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
			AnchorPoint = Vector2.new(1, 0)
		})
		tween:Tween(Timer, TweenInfo.new((Config.Time or 3), Enum.EasingStyle.Linear), {
			Size = UDim2.fromOffset(0, 2)
		})
	end

	task.delay((Config.Time or 3), function()
		if Library.TweenEnabled then
			tween:Tween(Notification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
				AnchorPoint = Vector2.new(0, 0)
			})
		end
		task.wait(.2)
		Notification:ClearAllChildren()
		Notification:Destroy()
	end)
end

return Library
