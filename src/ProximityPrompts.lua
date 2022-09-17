--[[
	Notes : 

	ProximityPrompts only show one prompt at a time. As such, when implementing ProximityPrompts, we
	only need to have one gui created. From then on, that same GUI Instance will be routinely hidden and shown
	(as well as having its connections cleaned up when it is hidden).

	Initialization of the GUI should execute immediately as it's executed via 'require(module)'	

	A metatable is also provided via : 'setmetatable(require(module), ProximityPromptMetaTable)'
]]

local proximityPromptService = game:GetService"ProximityPromptService"

local ProximityPromptMetaTable = {}
ProximityPromptMetaTable.__index = ProximityPromptMetaTable

ProximityPromptMetaTable.GamepadButtonImage = {
	[Enum.KeyCode.ButtonX] = "rbxasset://textures/ui/Controls/xboxX.png",
	[Enum.KeyCode.ButtonY] = "rbxasset://textures/ui/Controls/xboxY.png",
	[Enum.KeyCode.ButtonA] = "rbxasset://textures/ui/Controls/xboxA.png",
	[Enum.KeyCode.ButtonB] = "rbxasset://textures/ui/Controls/xboxB.png",
	[Enum.KeyCode.DPadLeft] = "rbxasset://textures/ui/Controls/dpadLeft.png",
	[Enum.KeyCode.DPadRight] = "rbxasset://textures/ui/Controls/dpadRight.png",
	[Enum.KeyCode.DPadUp] = "rbxasset://textures/ui/Controls/dpadUp.png",
	[Enum.KeyCode.DPadDown] = "rbxasset://textures/ui/Controls/dpadDown.png",
	[Enum.KeyCode.ButtonSelect] = "rbxasset://textures/ui/Controls/xboxmenu.png",
	[Enum.KeyCode.ButtonL1] = "rbxasset://textures/ui/Controls/xboxLS.png",
	[Enum.KeyCode.ButtonR1] = "rbxasset://textures/ui/Controls/xboxRS.png",
}

ProximityPromptMetaTable.KeyboardButtonImage = {
	[Enum.KeyCode.Backspace] = "rbxasset://textures/ui/Controls/backspace.png",
	[Enum.KeyCode.Return] = "rbxasset://textures/ui/Controls/return.png",
	[Enum.KeyCode.LeftShift] = "rbxasset://textures/ui/Controls/shift.png",
	[Enum.KeyCode.RightShift] = "rbxasset://textures/ui/Controls/shift.png",
	[Enum.KeyCode.Tab] = "rbxasset://textures/ui/Controls/tab.png",
}

ProximityPromptMetaTable.KeyboardButtonIconMapping = {
	["'"] = "rbxasset://textures/ui/Controls/apostrophe.png",
	[","] = "rbxasset://textures/ui/Controls/comma.png",
	["`"] = "rbxasset://textures/ui/Controls/graveaccent.png",
	["."] = "rbxasset://textures/ui/Controls/period.png",
	[" "] = "rbxasset://textures/ui/Controls/spacebar.png",
}

ProximityPromptMetaTable.KeyCodeToTextMapping = {
	[Enum.KeyCode.LeftControl] = "Ctrl",
	[Enum.KeyCode.RightControl] = "Ctrl",
	[Enum.KeyCode.LeftAlt] = "Alt",
	[Enum.KeyCode.RightAlt] = "Alt",
	[Enum.KeyCode.F1] = "F1",
	[Enum.KeyCode.F2] = "F2",
	[Enum.KeyCode.F3] = "F3",
	[Enum.KeyCode.F4] = "F4",
	[Enum.KeyCode.F5] = "F5",
	[Enum.KeyCode.F6] = "F6",
	[Enum.KeyCode.F7] = "F7",
	[Enum.KeyCode.F8] = "F8",
	[Enum.KeyCode.F9] = "F9",
	[Enum.KeyCode.F10] = "F10",
	[Enum.KeyCode.F11] = "F11",
	[Enum.KeyCode.F12] = "F12",
}

-- 	if inputType == Enum.ProximityPromptInputType.Touch or prompt.ClickablePrompt
ProximityPromptMetaTable.MakeClickable = function(promptUI, prompt)
	local button = Instance.new("TextButton")
	button.Name = "_invisibleButton"
	button.BackgroundTransparency = 1
	button.TextTransparency = 1
	button.Size = UDim2.fromScale(1, 1)
	button.Parent = promptUI

	local buttonDown = false

	button.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and
			input.UserInputState ~= Enum.UserInputState.Change then
			prompt:InputHoldBegin()
			buttonDown = true
		end
	end)
	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			if buttonDown then
				buttonDown = false
				prompt:InputHoldEnd()
			end
		end
	end)

	promptUI.Active = true

	return button
end

local m = {}

local requiredFields = {
	"Gui",
	"Show",
	"Hide",
}

local proximityPromptStyles = {}

function m:AddStyle(s : ModuleScript)
	local newStyle = require(s)

	if getmetatable(newStyle) then
		warn(s.Name .. " has a metatable. Is this intended?")
	else
		setmetatable(newStyle, ProximityPromptMetaTable)
	end

	for _, field in ipairs(requiredFields) do
		assert(newStyle[field], "Missing required field '" .. field .. "'")

		if field == "Gui" then
			assert(not newStyle.Gui.ResetOnSpawn, "Gui for '" .. s.Name .. "' has 'ResetOnSpawn' enabled.")
		end
	end

	proximityPromptStyles[s.Name] = newStyle
end

function m:AddStyles(cont : Folder)
	for index, s in ipairs(cont:GetChildren()) do
		local newStyle = require(s)

		if getmetatable(newStyle) then
			warn(s.Name .. " has a metatable. Is this intended?")
		else
			setmetatable(newStyle, ProximityPromptMetaTable)
		end

		for _, field in ipairs(requiredFields) do
			assert(newStyle[field], "Missing required field '" .. field .. "'")

			if field == "Gui" then
				assert(not newStyle.Gui.ResetOnSpawn, "Gui for '" .. s.Name .. "' has 'ResetOnSpawn' enabled.")
			end
		end

		proximityPromptStyles[s.Name] = newStyle
	end
end

local typeTriggeredCallbacks = {}
local typeGuards = {}

function m:AddTriggeredCallback(promptType, callback)
	local theseCallbacks= typeTriggeredCallbacks[promptType]

	if not theseCallbacks then
		theseCallbacks = {}
		typeTriggeredCallbacks[promptType] = theseCallbacks
	end

	assert(not table.find(theseCallbacks, callback), "Duplicate guard function found")

	table.insert(theseCallbacks, callback)
end

function m:RemoveTriggeredCallback(promptType, callback)
	local theseCallbacks = typeTriggeredCallbacks[promptType]

	if not theseCallbacks then
		theseCallbacks = {}
		typeTriggeredCallbacks[promptType] = theseCallbacks

		return
	end

	table.remove(theseCallbacks, table.find(theseCallbacks, callback))
end

-- Guard functions return 'true' to guard the function call.
function m:AddTypeGuard(promptType, guardF)
	local theseGuards = typeGuards[promptType]

	if not theseGuards then
		theseGuards = {}
		typeGuards[promptType] = theseGuards
	end

	assert(not table.find(theseGuards, guardF), "Duplicate guard function found")

	table.insert(theseGuards, guardF)
end

function m:RemoveTypeGuard(promptType, guardF)
	local theseGuards = typeGuards[promptType]

	if not theseGuards then
		theseGuards = {}
		typeGuards[promptType] = theseGuards

		return
	end

	table.remove(theseGuards, table.find(theseGuards, guardF))
end

local wassert = function(cond, msg)
	if not cond then
		warn(msg)
	end
end

proximityPromptService.PromptShown:Connect(function(prompt, inputType)
	local promptType = proximityPromptStyles[prompt:GetAttribute"Type"]

	wassert(promptType, "Missing prompt 'Type' for prompt in '" .. prompt.Parent.Name .. "'")

	for _, guardF in ipairs(typeGuards[promptType] or {}) do
		if guardF(prompt) then return end
	end

	if prompt.Style == Enum.ProximityPromptStyle.Custom then
		local style = proximityPromptStyles[prompt:GetAttribute"Style"]
 
		assert(style, "Provided a custom proximity prompt, but no style was found for Attribute'Style' : '" .. tostring(prompt:GetAttribute"Style") .. "'")

		style:Show(prompt, inputType, promptType)

		prompt.PromptHidden:ConnectOnce(function()
			style:Hide()
		end)
	end

	local _tConn = prompt.Triggered:Connect(function()
		for _, callback in ipairs(typeTriggeredCallbacks[promptType] or {}) do
			callback(prompt)
		end
	end)
end)

return m