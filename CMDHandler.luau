-- ReplicatedStorage → CMDHandler (ModuleScript)

local Utils = {}

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- NOTIFICATION SYSTEM 
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local Version = "ALPHA_v1.0.3"

function Utils.Version()
	return Version
end


local myverycoolnotifsystem = Instance.new("ScreenGui")
myverycoolnotifsystem.Name = "myverycoolnotifsystem"
myverycoolnotifsystem.Parent = game:GetService("CoreGui")
myverycoolnotifsystem.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
myverycoolnotifsystem.ResetOnSpawn = false

function Utils:Notify(TitleText, Desc, Delay)
	Delay = Delay or 4

	local Notification = Instance.new("Frame")
	local Line         = Instance.new("Frame")
	local Warning      = Instance.new("ImageLabel")
	local UICorner     = Instance.new("UICorner")
	local Title        = Instance.new("TextLabel")
	local Description  = Instance.new("TextLabel")

	Notification.Name = "Notification"
	Notification.Parent = myverycoolnotifsystem
	Notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Notification.BackgroundTransparency = 0.400
	Notification.BorderSizePixel = 0
	Notification.Position = UDim2.new(1, 5, 0, 75)
	Notification.Size = UDim2.new(0, 450, 0, 60)

	Line.Name = "Line"
	Line.Parent = Notification
	Line.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
	Line.BorderSizePixel = 0
	Line.Position = UDim2.new(0, 0, 0.938461304, 0)
	Line.Size = UDim2.new(0, 0, 0, 4)

	Warning.Name = "Warning"
	Warning.Parent = Notification
	Warning.BackgroundTransparency = 1.000
	Warning.Position = UDim2.new(0.0258302614, 0, 0.0897435844, 0)
	Warning.Size = UDim2.new(0, 44, 0, 49)
	Warning.Image = "rbxassetid://3944668821"
	Warning.ImageColor3 = Color3.fromRGB(241, 196, 15)
	Warning.ScaleType = Enum.ScaleType.Fit

	UICorner.CornerRadius = UDim.new(0, 20)
	UICorner.Parent = Warning

	Title.Name = "Title"
	Title.Parent = Notification
	Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title.BackgroundTransparency = 1.000
	Title.Position = UDim2.new(0.161, 0, 0.155, 0)
	Title.Size = UDim2.new(0, 205, 0, 15)
	Title.Text = TitleText or "Notification"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextSize = 12
	Title.TextStrokeTransparency = 0.500
	Title.TextXAlignment = Enum.TextXAlignment.Left

	Description.Name = "Description"
	Description.Parent = Notification
	Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Description.BackgroundTransparency = 1.000
	Description.Position = UDim2.new(0.161, 0, 0.483, 0)
	Description.Size = UDim2.new(0, 205, 0, 18)
	Description.Text = Desc or ""
	Description.TextColor3 = Color3.fromRGB(199, 199, 199)
	Description.TextSize = 12
	Description.TextStrokeTransparency = 0.500
	Description.TextXAlignment = Enum.TextXAlignment.Left

	-- Slide in
	Notification:TweenPosition(
		UDim2.new(1, -400, 0, 75),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Sine,
		0.35,
		true
	)

	task.wait(0.35)

	-- Progress bar
	Line:TweenSize(
		UDim2.new(0, 450, 0, 4),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Linear,
		Delay,
		true
	)

	task.wait(Delay)

	-- Slide out
	Notification:TweenPosition(
		UDim2.new(1, 5, 0, 75),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Sine,
		0.35,
		true
	)

	task.wait(0.35)
	Notification:Destroy()
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- FEATURE: Swim
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local swim = {}
do
	local active = false
	local connections = {}

	local function cleanup()
		for _, c in ipairs(connections) do
			pcall(function() c:Disconnect() end)
		end
		table.clear(connections)
	end

	local function getParts()
		local char = player.Character
		if not char then return nil end
		local hum = char:FindFirstChildWhichIsA("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
			or char:FindFirstChild("Torso")
			or char:FindFirstChild("UpperTorso")
		return hum, root
	end

	function swim:Activate()
		if active then 
			Utils:Notify("Swim", "Already active", 2.5)
			return 
		end

		local hum, root = getParts()
		if not (hum and root) then return end

		local oldGravity = workspace.Gravity
		workspace.Gravity = 0
		active = true

		table.insert(connections, hum.Died:Connect(function()
			workspace.Gravity = oldGravity or 196.2
			cleanup()
			active = false
		end))

		for _, state in Enum.HumanoidStateType:GetEnumItems() do
			if state ~= Enum.HumanoidStateType.Swimming then
				hum:SetStateEnabled(state, false)
			end
		end
		hum:ChangeState(Enum.HumanoidStateType.Swimming)

		table.insert(connections, RunService.Heartbeat:Connect(function()
			if not root or not hum or not hum.Parent then return end
			if hum.MoveDirection.Magnitude > 0 then return end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then return end
			root.Velocity = Vector3.zero
		end))

		table.insert(connections, player.CharacterAdded:Connect(function()
			cleanup()
			active = false
		end))

		Utils:Notify("Swim Mode", "Air swimming enabled (zero gravity)", 4)
	end

	function swim:Deactivate()
		if not active then return end

		local hum = getParts() -- only need humanoid here
		if hum then
			workspace.Gravity = 196.2
			for _, state in Enum.HumanoidStateType:GetEnumItems() do
				hum:SetStateEnabled(state, true)
			end
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end

		cleanup()
		active = false

		Utils:Notify("Swim Mode", "Air swimming disabled", 3)
	end

	function swim:Toggle()
		if self:IsActive() then
			self:Deactivate()
		else
			self:Activate()
		end
	end

	function swim:IsActive()
		return active
	end
end

Utils.Swim = swim

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- COMMAND REGISTRATION
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Utils:AddCMD = Utils:AddCMD or function(name, desc, callback)
	-- Fallback if someone uses old syntax — but you should use :AddCMD
	warn("Use Utils:AddCMD instead of Utils.Add")
end

if Utils.AddCMD then
	Utils:AddCMD("swim", "Enables air swimming / zero-gravity mode", function()
		Utils.Swim:Activate()
	end)

	Utils:AddCMD("unswim", "Disables air swimming", function()
		Utils.Swim:Deactivate()
	end)

	Utils:AddCMD("toggleswim", "Toggles air swimming on/off", function()
		Utils.Swim:Toggle()
	end)

	Utils:AddCMD("swimstatus", "Shows current swim status", function()
		Utils:Notify("Swim Status", Utils.Swim:IsActive() and "Enabled" or "Disabled", 3)
	end)
end

Utils:Notify("CMDHandler", "Loaded • Commands: swim, unswim, toggleswim", 5)

return Utils
