local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local rbxClassic = {}

local tweensForButtonHoldBegin = {}
local tweensForButtonHoldEnd = {}
local tweensForFadeOut = {}
local tweensForFadeIn = {}

local tweenInfoOutHalfSecond = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfoFast = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfoQuick = TweenInfo.new(0.06, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local promptUI;

-- Create Prompt. This is just a Roblox example. For real implementations, it's recommended to design the UI Prefab, and save it for use.
do
	local function createProgressBarGradient(parent, leftSide)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromScale(0.5, 1)
		frame.Position = UDim2.fromScale(leftSide and 0 or 0.5, 0)
		frame.BackgroundTransparency = 1
		frame.ClipsDescendants = true
		frame.Parent = parent

		local image = Instance.new("ImageLabel")
		image.BackgroundTransparency = 1
		image.Size = UDim2.fromScale(2, 1)
		image.Position = UDim2.fromScale(leftSide and 0 or -1, 0)
		image.Image = "rbxasset://textures/ui/Controls/RadialFill.png"
		image.Parent = frame

		local gradient = Instance.new("UIGradient")
		gradient.Transparency = NumberSequence.new {
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(.4999, 0),
			NumberSequenceKeypoint.new(.5, 1),
			NumberSequenceKeypoint.new(1, 1)
		}
		gradient.Rotation = leftSide and 180 or 0
		gradient.Parent = image

		return gradient
	end

	local function createCircularProgressBar()
		local bar = Instance.new("Frame")
		bar.Name = "CircularProgressBar"
		bar.Size = UDim2.fromOffset(58, 58)
		bar.AnchorPoint = Vector2.new(0.5, 0.5)
		bar.Position = UDim2.fromScale(0.5, 0.5)
		bar.BackgroundTransparency = 1

		local gradient1 = createProgressBarGradient(bar, true)
		local gradient2 = createProgressBarGradient(bar, false)

		local progress = Instance.new("NumberValue")
		progress.Name = "Progress"
		progress.Parent = bar
		progress.Changed:Connect(function(value)
			local angle = math.clamp(value * 360, 0, 360)
			gradient1.Rotation = math.clamp(angle, 180, 360)
			gradient2.Rotation = math.clamp(angle, 0, 180)
		end)

		return bar
	end

	promptUI = Instance.new("BillboardGui")
	promptUI.Name = "Prompt"
	promptUI.AlwaysOnTop = true
	promptUI.ResetOnSpawn = false

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(0.5, 1)
	frame.BackgroundTransparency = 1
	frame.BackgroundColor3 = Color3.new(0.07, 0.07, 0.07)
	frame.Parent = promptUI

	local roundedCorner = Instance.new("UICorner")
	roundedCorner.Parent = frame

	local inputFrame = Instance.new("Frame")
	inputFrame.Name = "InputFrame"
	inputFrame.Size = UDim2.fromScale(1, 1)
	inputFrame.BackgroundTransparency = 1
	inputFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY
	inputFrame.Parent = frame

	local resizeableInputFrame = Instance.new("Frame")
	resizeableInputFrame.Name = "ResizeableInputFrame"
	resizeableInputFrame.Size = UDim2.fromScale(1, 1)
	resizeableInputFrame.Position = UDim2.fromScale(0.5, 0.5)
	resizeableInputFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	resizeableInputFrame.BackgroundTransparency = 1
	resizeableInputFrame.Parent = inputFrame

	local inputFrameScaler = Instance.new("UIScale")
	inputFrameScaler.Parent = resizeableInputFrame

	local actionText = Instance.new("TextLabel")
	actionText.Name = "ActionText"
	actionText.Size = UDim2.fromScale(1, 1)
	actionText.Font = Enum.Font.GothamSemibold
	actionText.TextSize = 19
	actionText.BackgroundTransparency = 1
	actionText.TextTransparency = 1
	actionText.TextColor3 = Color3.new(1, 1, 1)
	actionText.TextXAlignment = Enum.TextXAlignment.Left
	actionText.Parent = frame

	table.insert(tweensForButtonHoldBegin, TweenService:Create(actionText, tweenInfoFast, { TextTransparency = 1 }))
	table.insert(tweensForButtonHoldEnd, TweenService:Create(actionText, tweenInfoFast, { TextTransparency = 0 }))
	table.insert(tweensForFadeOut, TweenService:Create(actionText, tweenInfoFast, { TextTransparency = 1 }))
	table.insert(tweensForFadeIn, TweenService:Create(actionText, tweenInfoFast, { TextTransparency = 0 }))

	local objectText = Instance.new("TextLabel")
	objectText.Name = "ObjectText"
	objectText.Size = UDim2.fromScale(1, 1)
	objectText.Font = Enum.Font.GothamSemibold
	objectText.TextSize = 14
	objectText.BackgroundTransparency = 1
	objectText.TextTransparency = 1
	objectText.TextColor3 = Color3.new(0.7, 0.7, 0.7)
	objectText.TextXAlignment = Enum.TextXAlignment.Left
	objectText.Parent = frame

	table.insert(tweensForButtonHoldBegin, TweenService:Create(objectText, tweenInfoFast, { TextTransparency = 1 }))
	table.insert(tweensForButtonHoldEnd, TweenService:Create(objectText, tweenInfoFast, { TextTransparency = 0 }))
	table.insert(tweensForFadeOut, TweenService:Create(objectText, tweenInfoFast, { TextTransparency = 1 }))
	table.insert(tweensForFadeIn, TweenService:Create(objectText, tweenInfoFast, { TextTransparency = 0 }))

	table.insert(tweensForButtonHoldBegin, TweenService:Create(frame, tweenInfoFast, { Size = UDim2.fromScale(0.5, 1), BackgroundTransparency = 1 }))
	table.insert(tweensForButtonHoldEnd, TweenService:Create(frame, tweenInfoFast, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0.2 }))
	table.insert(tweensForFadeOut, TweenService:Create(frame, tweenInfoFast, { Size = UDim2.fromScale(0.5, 1), BackgroundTransparency = 1 }))
	table.insert(tweensForFadeIn, TweenService:Create(frame, tweenInfoFast, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0.2 }))

	local roundFrame = Instance.new("Frame")
	roundFrame.Name = "RoundFrame"
	roundFrame.Size = UDim2.fromOffset(48, 48)

	roundFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	roundFrame.Position = UDim2.fromScale(0.5, 0.5)
	roundFrame.BackgroundTransparency = 1
	roundFrame.Parent = resizeableInputFrame

	local roundedFrameCorner = Instance.new("UICorner")
	roundedFrameCorner.CornerRadius = UDim.new(0.5, 0)
	roundedFrameCorner.Parent = roundFrame

	table.insert(tweensForFadeOut, TweenService:Create(roundFrame, tweenInfoQuick, { BackgroundTransparency = 1 }))
	table.insert(tweensForFadeIn, TweenService:Create(roundFrame, tweenInfoQuick, { BackgroundTransparency = 0.5 }))

	local icon = Instance.new("ImageLabel")
	icon.Name = "ButtonImage"
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Size = UDim2.fromOffset(24, 24)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.BackgroundTransparency = 1
	icon.ImageTransparency = 1
	icon.Parent = resizeableInputFrame
	table.insert(tweensForFadeOut, TweenService:Create(icon, tweenInfoQuick, { ImageTransparency = 1 }))
	table.insert(tweensForFadeIn, TweenService:Create(icon, tweenInfoQuick, { ImageTransparency = 0 }))

	local icon = Instance.new("ImageLabel")
	icon.Name = "ButtonTextImage"
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Size = UDim2.fromOffset(36, 36)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.BackgroundTransparency = 1
	icon.ImageTransparency = 1
	icon.Visible = false
	icon.Parent = resizeableInputFrame
	table.insert(tweensForFadeOut, TweenService:Create(icon, tweenInfoQuick, { ImageTransparency = 1 }))
	table.insert(tweensForFadeIn, TweenService:Create(icon, tweenInfoQuick, { ImageTransparency = 0 }))

	local buttonText = Instance.new("TextLabel")
	buttonText.Name = "ButtonText"
	buttonText.Position = UDim2.fromOffset(0, -1)
	buttonText.Size = UDim2.fromScale(1, 1)
	buttonText.Font = Enum.Font.GothamSemibold
	buttonText.TextSize = 14
	buttonText.BackgroundTransparency = 1
	buttonText.TextTransparency = 1
	buttonText.TextColor3 = Color3.new(1, 1, 1)
	buttonText.TextXAlignment = Enum.TextXAlignment.Center
	buttonText.Parent = resizeableInputFrame
	buttonText.Visible = false

	table.insert(tweensForFadeOut, TweenService:Create(buttonText, tweenInfoQuick, { TextTransparency = 1 }))
	table.insert(tweensForFadeIn, TweenService:Create(buttonText, tweenInfoQuick, { TextTransparency = 0 }))

	local circleBar = createCircularProgressBar()
	circleBar.Visible = false
	circleBar.Parent = resizeableInputFrame
	table.insert(tweensForButtonHoldEnd, TweenService:Create(circleBar.Progress, tweenInfoOutHalfSecond, { Value = 0 }))

	promptUI.Parent = LocalPlayer.PlayerGui
end

rbxClassic.Gui = promptUI

local _lastTrove;

local function _troveAdd(item)
	table.insert(_lastTrove, item)
	
	return item
end

local function _cleanupTrove()
	if not _lastTrove then return warn("Attempt to cleanup with no trove") end

	for index, value in ipairs(_lastTrove) do
		local t = typeof(value)

		if t == "function" then
			value()
		elseif t == "thread" then
			coroutine.close(value)
		end
		if t == "Instance" then
			value:Destroy()
		elseif t == "RBXScriptConnection" then
			value:Disconnect()
		elseif t == "table" then
			if typeof(value.Destroy) == "function" then
				value:Destroy()
			elseif typeof(value.Disconnect) == "function" then
				value:Disconnect()
			end
		else
			error("Failed to get cleanup function for object " .. t .. ": " .. tostring(value), 3)
		end
	end

	table.clear(_lastTrove)
	_lastTrove = nil
end

local _isShown = false

function rbxClassic:Show(prompt, inputType, gui)
	if _lastTrove then
		warn("Last Trove failed to cleanup ???")

		_cleanupTrove()
	end
	_isShown = true
	
	_lastTrove = {}

	local resizeableInputFrame = promptUI.Frame.InputFrame.ResizeableInputFrame
	-- local inputFrameScaler = resizeableInputFrame.UIScale

	-- local inputFrameScaleFactor = inputType == Enum.ProximityPromptInputType.Touch and 1.6 or 1.33
	-- table.insert(tweensForButtonHoldBegin, TweenService:Create(inputFrameScaler, tweenInfoFast, { Scale = inputFrameScaleFactor }))
	-- table.insert(tweensForButtonHoldEnd, TweenService:Create(inputFrameScaler, tweenInfoFast, { Scale = 1 }))

	local icon = resizeableInputFrame.ButtonImage

	if inputType == Enum.ProximityPromptInputType.Gamepad then
		if rbxClassic.GamepadButtonImage[prompt.GamepadKeyCode] then
			icon.Image = rbxClassic.GamepadButtonImage[prompt.GamepadKeyCode]
		end
	elseif inputType == Enum.ProximityPromptInputType.Touch then
		icon.Image = "rbxasset://textures/ui/Controls/TouchTapIcon.png"
	else
		icon.Image = "rbxasset://textures/ui/Controls/key_single.png"

		local buttonTextString = UserInputService:GetStringForKeyCode(prompt.KeyboardKeyCode)
		
		local buttonTextImage = rbxClassic.KeyboardButtonImage[prompt.KeyboardKeyCode]

		if buttonTextImage == nil then
			buttonTextImage = rbxClassic.KeyboardButtonIconMapping[buttonTextString]
		end

		if buttonTextImage == nil then
			local keyCodeMappedText = rbxClassic.KeyCodeToTextMapping[prompt.KeyboardKeyCode]
			if keyCodeMappedText then
				buttonTextString = keyCodeMappedText
			end
		end

		if buttonTextImage then
			resizeableInputFrame.ButtonTextImage.Visible = true
			icon.Image = buttonTextImage
		elseif buttonTextString ~= nil and buttonTextString ~= '' then
			local buttonText = resizeableInputFrame.ButtonText
			buttonText.Visible = true

			if string.len(buttonTextString) > 2 then
				buttonText.TextSize = 12
			end

			buttonText.Text = buttonTextString
		else
			error("ProximityPrompt '" .. prompt.Name .. "' has an unsupported keycode for rendering UI: " .. tostring(prompt.KeyboardKeyCode))
		end
	end

	if inputType == Enum.ProximityPromptInputType.Touch or prompt.ClickablePrompt then
		_troveAdd(rbxClassic.MakeClickable(promptUI, prompt)) -- MakeClickable returns an invislbe button. Needs to be cleaned up.
	end

	if prompt.HoldDuration > 0 then
		local circTweenBegin  =_troveAdd(TweenService:Create(
			resizeableInputFrame.CircularProgressBar.Progress, 
			TweenInfo.new(prompt.HoldDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), 
			{ Value = 1 }))

		resizeableInputFrame.CircularProgressBar.Visible = true

		_troveAdd(prompt.PromptButtonHoldBegan:Connect(function()
			for _, tween in ipairs(tweensForButtonHoldBegin) do
				tween:Play()
			end
			
			circTweenBegin:Play()
		end))

		_troveAdd(prompt.PromptButtonHoldEnded:Connect(function()
			for _, tween in ipairs(tweensForButtonHoldEnd) do
				tween:Play()
			end
		end))
	end

	_troveAdd(prompt.Triggered:Connect(function()
		for _, tween in ipairs(tweensForFadeOut) do
			tween:Play()
		end
	end))

	_troveAdd(prompt.TriggerEnded:Connect(function()
		for _, tween in ipairs(tweensForFadeIn) do
			tween:Play()
		end
	end))

	local actionText = promptUI.Frame.ActionText
	local objectText = promptUI.Frame.ObjectText

	local function updateUIFromPrompt()
		-- todo: Use AutomaticSize instead of GetTextSize when that feature becomes available
		local actionTextSize = TextService:GetTextSize(prompt.ActionText, 19, Enum.Font.GothamSemibold, Vector2.new(1000, 1000))
		local objectTextSize = TextService:GetTextSize(prompt.ObjectText, 14, Enum.Font.GothamSemibold, Vector2.new(1000, 1000))
		local maxTextWidth = math.max(actionTextSize.X, objectTextSize.X)
		local promptHeight = 72
		local promptWidth = 72
		local textPaddingLeft = 72

		if (prompt.ActionText ~= nil and prompt.ActionText ~= '') or
			(prompt.ObjectText ~= nil and prompt.ObjectText ~= '') then
			promptWidth = maxTextWidth + textPaddingLeft + 24
		end

		local actionTextYOffset = 0
		if prompt.ObjectText ~= nil and prompt.ObjectText ~= '' then
			actionTextYOffset = 9
		end
		actionText.Position = UDim2.new(0.5, textPaddingLeft - promptWidth/2, 0, actionTextYOffset)
		objectText.Position = UDim2.new(0.5, textPaddingLeft - promptWidth/2, 0, -10)

		actionText.Text = prompt.ActionText
		objectText.Text = prompt.ObjectText
		actionText.AutoLocalize = prompt.AutoLocalize
		actionText.RootLocalizationTable = prompt.RootLocalizationTable

		objectText.AutoLocalize = prompt.AutoLocalize
		objectText.RootLocalizationTable = prompt.RootLocalizationTable

		promptUI.Size = UDim2.fromOffset(promptWidth, promptHeight)
		promptUI.SizeOffset = Vector2.new(prompt.UIOffset.X / promptUI.Size.Width.Offset, prompt.UIOffset.Y / promptUI.Size.Height.Offset)
	end

	local changedConnection = prompt.Changed:Connect(updateUIFromPrompt)
	updateUIFromPrompt()

	promptUI.Adornee = prompt.Parent

	promptUI.Enabled = true

	for _, tween in ipairs(tweensForFadeIn) do
		tween:Play()
	end
end

function rbxClassic:Hide()
	_isShown = false
	
	_cleanupTrove()

	local aTween;

	for _, tween in ipairs(tweensForFadeOut) do
		if not aTween then aTween = tween end

		tween:Play()
	end

	aTween.Completed:Wait()
	
	if _isShown then return end
	
	local resizeableInputFrame = promptUI.Frame.InputFrame.ResizeableInputFrame
	resizeableInputFrame.ButtonTextImage.Visible = false
	resizeableInputFrame.ButtonText.Visible = false
	resizeableInputFrame.CircularProgressBar.Visible = false

	promptUI.Adornee = nil
	promptUI.Enabled = false
end

return rbxClassic