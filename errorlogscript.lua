local button = script.Parent
local TweenService = game:GetService('TweenService')

local tweenGoal = {
	['Size'] = UDim2.new(0, 331, 0, 192)
	--['Position'] = UDim2.new(0.031, 0, 0.094, 0)
}
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local fadetween = TweenService:Create(button.Frame, tweenInfo, tweenGoal)

print("attempted")

local tweenGoal = {
	['Size'] = UDim2.new(0, 331, 0, 0)
	--['Position'] = UDim2.new(0.031, 0, 0.094, 0)
}
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local fadetweenin = TweenService:Create(button.Frame, tweenInfo, tweenGoal)

local tweenGoal = {
	['TextTransparency'] = 0
	--['Position'] = UDim2.new(0.031, 0, 0.094, 0)
}
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local fadetweent = TweenService:Create(button.Frame.ScrollingFrame.TextBox, tweenInfo, tweenGoal)

local tweenGoal = {
	['TextTransparency'] = 1
	--['Position'] = UDim2.new(0.031, 0, 0.094, 0)
}
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local fadetweenint = TweenService:Create(button.Frame.ScrollingFrame.TextBox, tweenInfo, tweenGoal)
print("attempted")

local state = false
button.MouseButton1Click:Connect(function()
	
	if state == false then
		state = true
		fadetween:Play()
		fadetweent:Play()
	else
		state = false
		fadetweenin:Play()
		fadetweenint:Play()
		print("chat")
		
	end
	button.ErrorDisplay.Transparency = 1
end)
