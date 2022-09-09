local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local customUI = {}

local promptUI = script.PromptUI

customUI.Gui = promptUI

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

function customUI:Show(prompt, inputType, gui)
	if _lastTrove then
		warn("Last Trove failed to cleanup ???")

		_cleanupTrove()
	end
	_isShown = true
	
	_lastTrove = {}

	if inputType == Enum.ProximityPromptInputType.Gamepad then
		if customUI.GamepadButtonImage[prompt.GamepadKeyCode] then
			icon.Image = customUI.GamepadButtonImage[prompt.GamepadKeyCode]
		end
	elseif inputType == Enum.ProximityPromptInputType.Touch then
		icon.Image = "rbxasset://textures/ui/Controls/TouchTapIcon.png"
	else
		icon.Image = "rbxasset://textures/ui/Controls/key_single.png"

		local buttonTextString = UserInputService:GetStringForKeyCode(prompt.KeyboardKeyCode)
		
		local buttonTextImage = customUI.KeyboardButtonImage[prompt.KeyboardKeyCode]

		if buttonTextImage == nil then
			buttonTextImage = customUI.KeyboardButtonIconMapping[buttonTextString]
		end

		if buttonTextImage == nil then
			local keyCodeMappedText = customUI.KeyCodeToTextMapping[prompt.KeyboardKeyCode]
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
		_troveAdd(customUI.MakeClickable(promptUI, prompt)) -- MakeClickable returns an invislbe button. Needs to be cleaned up.
	end

	if prompt.HoldDuration > 0 then
		_troveAdd(prompt.PromptButtonHoldBegan:Connect(function()
			-- tweens to do when held
		end))

		_troveAdd(prompt.PromptButtonHoldEnded:Connect(function()
			-- tweens to do when heldEnd
		end))
	end

	_troveAdd(prompt.Triggered:Connect(function()
		-- tweens to do when triggered
	end))

	_troveAdd(prompt.TriggerEnded:Connect(function()
		-- tweens to do when triggered
	end))

	local actionText = promptUI.Frame.ActionText
	local objectText = promptUI.Frame.ObjectText

	local function updateUIFromPrompt()
		-- todo: Use AutomaticSize instead of GetTextSize when that feature becomes available
	end

	local changedConnection = prompt.Changed:Connect(updateUIFromPrompt)
	updateUIFromPrompt()

	promptUI.Adornee = prompt.Parent

	promptUI.Enabled = true
end

function customUI:Hide()
	_isShown = false
	
	_cleanupTrove()

	
	if _isShown then return end

	promptUI.Adornee = nil
	promptUI.Enabled = false
end

return customUI