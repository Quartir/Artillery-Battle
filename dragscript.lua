local UserInputService = game:GetService("UserInputService")

local MainFrame = script.Parent.Parent
local RepositioningFrame = MainFrame:WaitForChild("drag")

local Camera = workspace:WaitForChild("Camera")

local DragMousePosition
local FramePosition

local Draggable = false

RepositioningFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		Draggable = true
		DragMousePosition = Vector2.new(input.Position.X, input.Position.Y)
		FramePosition = Vector2.new(MainFrame.Position.X.Scale, MainFrame.Position.Y.Scale)
	end
end)

RepositioningFrame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		Draggable = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if Draggable == true then
		local NewPosition = FramePosition + ((Vector2.new(input.Position.X, input.Position.Y) - DragMousePosition) / Camera.ViewportSize)
		MainFrame.Position = UDim2.new(NewPosition.X, 0, NewPosition.Y, 0)
	end
end)
