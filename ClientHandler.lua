local PLACEHOLDER_IMAGE = "rbxassetid://0"
local Players = game:GetService('Players')
local TweenService = game:GetService('TweenService')
local firemenu = game.Players.LocalPlayer.PlayerGui:WaitForChild('FireMenu').Frame
local shopgui = game.Players.LocalPlayer.PlayerGui:WaitForChild('ShopMenu')
local Maingui = game.Players.LocalPlayer.PlayerGui:WaitForChild('Main')
local modgui = game.Players.LocalPlayer.PlayerGui:WaitForChild('ModMenu')
local uis = game:GetService('UserInputService')
local selecting = false
local mouse = game.Players.LocalPlayer:GetMouse()

-- refrences for the selection scope and button sfx
local mortar_pos = game:GetService('ReplicatedStorage'):WaitForChild('MortarVision')
local sfx = firemenu.sfx
local MarketplaceService = game:GetService("MarketplaceService")

-- Outline is the black selection around which arc is selected and time modifier is the default arc selection.
local outline = 5
local timemodifier = 1.6


-- directories for the buttons
local higharc = firemenu:WaitForChild('HighArc')
local lowarc = firemenu:WaitForChild('LowArc')
local selectbutton = firemenu:WaitForChild('selectbutton')
local firebutton = firemenu:WaitForChild('Fire')
local cancelbutton = firemenu:WaitForChild('cancelbutton')
local barragebutton = firemenu:WaitForChild('barragebutton')
local barragecount = firemenu:WaitForChild('barragecount')
local airstrikebutton = firemenu:WaitForChild('airstrikebutton')
local airstrikecount = firemenu:WaitForChild('airstrikecount')

local shopbutton = Maingui:WaitForChild('buttons').shopbutton
local adminbutton = Maingui:WaitForChild('buttons').adminbutton
local gamestate = false

-- Temporary hitposition so it wont error if the player fires before selecting a hit position.
local hitpos = game.Workspace.pos2.Position

-- arc selectors, higher number is a lower arc
higharc.MouseButton1Click:Connect(function()
	--sfx.PlaybackSpeed = math.random(0.8, 1.2)
	sfx:Play()
	timemodifier = 1.6
	higharc.BorderSizePixel = outline
	lowarc.BorderSizePixel = 0
end)

-- arc selectors, higher number is a lower arc
lowarc.MouseButton1Click:Connect(function()
	--sfx.PlaybackSpeed = math.random(0.8, 1.2)
	sfx:Play()
	timemodifier = 2.5
	higharc.BorderSizePixel = 0
	lowarc.BorderSizePixel = outline
end)

-- Server - Client event to set client gamestate to false.
game.ReplicatedStorage.StoppedEvent.OnClientEvent:Connect(function()
	gamestate = false
	--print("Stopped")
end)

-- Checks to see if there is already a projectile, if not fires server with data.
firebutton.MouseButton1Click:Connect(function()
	if gamestate == false then
		gamestate = true
		game.ReplicatedStorage.Send:FireServer(timemodifier, hitpos)
		print("Single Fire Called")
	else
		print("Wait Until Current Target Is Hit")
	end

end)

-- Select button and cloning the crosshair
selectbutton.MouseButton1Click:Connect(function()
	--sfx.PlaybackSpeed = math.random(0.8, 1.2)
	sfx:Play()
	if selecting == false then
		selecting = true
		local new = mortar_pos:Clone()
		new.Name = game.Players.LocalPlayer.Name..'_MortarVis'
		new.Parent = workspace
		mouse.TargetFilter = new
		while selecting == true do
			task.wait()
			if selecting then
				workspace:WaitForChild(game.Players.LocalPlayer.Name..'_MortarVis'):MoveTo(mouse.Hit.Position)
			end
		end
	else
		selecting = false
		workspace:WaitForChild(game.Players.LocalPlayer.Name..'_MortarVis'):Destroy()
	end

	--print(selecting)

end)

-- Getting the position when clicking while selecting.
mouse.Button1Up:Connect(function()
	if selecting == true then
		hitpos = mouse.Hit.Position
		--print('Mouse Position is: '..tostring(hitpos))
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		--ReplicatedStorage:WaitForChild('Position'):FireServer(hitpos)
		selecting = false
		workspace:WaitForChild(game.Players.LocalPlayer.Name..'_MortarVis'):Destroy()
		--print(selecting)
	end
end)

-- Cancels Event
cancelbutton.MouseButton1Click:Connect(function()
	--sfx.PlaybackSpeed = math.random(0.8, 1.2)
	sfx:Play()
	if gamestate == true then
		gamestate = false
		game.ReplicatedStorage.Cancel:FireServer()
		print("Canceled")
	end
end)

-- Barrage Event
barragebutton.MouseButton1Click:Connect(function()
	--sfx.PlaybackSpeed = math.random(0.8, 1.2)
	sfx:Play()
	if gamestate == false then
		gamestate = true
		game.ReplicatedStorage.Barrage:FireServer(timemodifier, hitpos)
	end
end)

airstrikebutton.MouseButton1Click:Connect(function()
	sfx:Play()
	if gamestate == false then
		gamestate = true
		--warn('fireserver')
		game.ReplicatedStorage.airstrike:FireServer(timemodifier, hitpos)
	end
end)


local function ShopRefresh()
	local table = game.ReplicatedStorage.dataask:InvokeServer("Shop0")
	--print(table)
	shopgui.Main.Cashdisplay.currentCash.Text = table[1].." Cash"
	shopgui.Main.speedbutton.CurrentLVL.Text = table[2]
	shopgui.Main.explosionbutton.CurrentLVL.Text = table[3]
	shopgui.Main.barragereplenishbutton.CurrentLVL.Text = table[4]
	shopgui.Main.moneybutton.CurrentLVL.Text = table[5]
	shopgui.Main.speedbutton.Cost.Text = table[6].." Cash"
	shopgui.Main.explosionbutton.Cost.Text = table[7].." Cash"
	shopgui.Main.barragereplenishbutton.Cost.Text = table[8].." Cash"
	shopgui.Main.moneybutton.Cost.Text = table[9].." Cash"

end

shopbutton.MouseButton1Click:Connect(function()
	--print("hi")
	if shopgui.Enabled == false then
		shopgui.Enabled = true
		ShopRefresh()
	else
		shopgui.Enabled = false
	end
end)

local function buyerror(datatype)
	if datatype == 1 then
		print("Not Enough Cash")
		shopgui.Main.ErrorLabel.TextTransparency = 0
		shopgui.Main.ErrorLabel.Text = "Not Enough Cash"
		local tweenGoal = {
			['TextTransparency'] = 1
			--['Position'] = UDim2.new(0.031, 0, 0.094, 0)
		}
		local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		local fadetween = TweenService:Create(shopgui.Main.ErrorLabel, tweenInfo, tweenGoal)
		fadetween:Play()
	end

	if datatype == 2 then
		print("Current Purchase not finished")
		shopgui.Main.ErrorLabel.TextTransparency = 0
		shopgui.Main.ErrorLabel.Text = "Purcase in Progress"
		local tweenGoal = {
			['TextTransparency'] = 1
			--['Position'] = UDim2.new(0.031, 0, 0.094, 0)
		}
		local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		local fadetween = TweenService:Create(shopgui.Main.ErrorLabel, tweenInfo, tweenGoal)
		fadetween:Play()
	end
end

local function tweenModel(model, CF, info)
	local CFrameValue = Instance.new("CFrameValue")
	CFrameValue.Value = model:GetPivot()

	CFrameValue:GetPropertyChangedSignal("Value"):connect(function()
		model:PivotTo(CFrame.new(CFrameValue.Value.Position, CF.Position) * CFrame.Angles(0,math.rad(90), 0))
	end)

	local tween = TweenService:Create(CFrameValue, info, {Value = CF})
	tween:Play()
	
	tween.Completed:connect(function()
		CFrameValue:Destroy()
		--model:Destroy()
	end)
end

game.ReplicatedStorage.databack.OnClientEvent:Connect(function(datatype, data, data2)
	
	if datatype == 1 then
		barragecount.Text = data
		print(data)
		print("databack: Barrage Refresh")
	end

	if datatype == 2 then
		print(data)
		
	end

	if datatype == 3 then
		ShopRefresh()
		print("databack: ShopRefresh")
	end

	if datatype == 4 then
		wait(0.5)
		Players.LocalPlayer.PlayerGui.Main.buttons.adminbutton.Visible = true
		print("databack: Admin Gui")
	end
	
	if datatype == 4 then
		--warn("datatype")
		local building = game.ReplicatedStorage.tempclone:Clone()
		building.Parent = game.Workspace
		building:MoveTo(Players.LocalPlayer.Character.HumanoidRootPart.Position)
		local clone = game.ReplicatedStorage.A10:Clone()
		clone.Parent = game.Workspace
		clone.sfx:Play()
		local Waypoints = {
			[1] = hitpos + Vector3.new(2000, 100, 0),
			[2] = hitpos + Vector3.new(-1000, 100, 0)
		}
		
		clone:PivotTo(CFrame.new(Waypoints[1]))
		
		
		local Point = Waypoints[2]
			
		local seconds = (clone:GetPivot().Position - Point).Magnitude * 0.0035
		
		
		print(seconds)
		local info = TweenInfo.new(seconds, Enum.EasingStyle.Linear)
		tweenModel(clone, CFrame.new(Point), info)
		task.wait(seconds * 0.35)
		for i = 0, 12, 1 do
			local missle = game.ReplicatedStorage.missle:Clone()
			missle.Parent = game.Workspace.Missles
			missle.Position = clone.wings.CFrame.Position
			local direction = (clone.canopy.CFrame.Position + Vector3.new(0,-4,0)) - (clone.body.CFrame.Position + Vector3.new(0,-2,0))
			missle:ApplyImpulse(direction * 2000)
			missle.sfx:Play()
			missle.Touched:Connect(function(p)
				if not p:FindFirstAncestor('A10') then
					print('hi')
					local explosion = Instance.new('Explosion')
					explosion.Parent = game.Workspace.Missles
					explosion.BlastRadius = 13
					explosion.Position = missle.Position
					missle:Destroy()
				end
				
			end
			)
			wait(seconds * 0.025)
		end
		task.wait(seconds * 0.50)
		clone:Destroy()
		for i, v in pairs(game.Workspace.Missles:GetChildren()) do
			v:Destroy()
		end
	end
	gamestate = false
end)

--[[
game.ReplicatedStorage.clientexplosion.OnClientEvent:Connect(function( piece, explosionsize)
	local explosion = Instance.new("Explosion")
	explosion.Position = piece
	explosion.BlastRadius = explosionsize
	explosion.DestroyJointRadiusPercent = 10
	explosion.BlastPressure = 50000
	explosion.Parent = game.Workspace
end)
]]

local purchasing = false
shopgui.Main.speedbutton.MouseButton1Click:Connect(function()
	if purchasing == false then
		purchasing = true
		local state = game.ReplicatedStorage.dataask:InvokeServer("Shop1")
		if state == true then
			ShopRefresh()
		else
			buyerror(1)
		end

		purchasing = false
	else
		buyerror(2)
	end

end)

shopgui.Main.explosionbutton.MouseButton1Click:Connect(function()
	if purchasing == false then
		purchasing = true
		local state = game.ReplicatedStorage.dataask:InvokeServer("Shop2")
		if state == true then
			ShopRefresh()
		else
			buyerror(1)
		end

		purchasing = false
	else
		buyerror(2)
	end
end)

shopgui.Main.barragereplenishbutton.MouseButton1Click:Connect(function()
	if purchasing == false then
		purchasing = true
		local state = game.ReplicatedStorage.dataask:InvokeServer("Shop3")
		if state == true then
			ShopRefresh()
		else
			buyerror(1)
		end

		purchasing = false
	else
		buyerror(2)
	end
end)

shopgui.Main.moneybutton.MouseButton1Click:Connect(function()
	if purchasing == false then
		purchasing = true
		local state = game.ReplicatedStorage.dataask:InvokeServer("Shop4")
		if state == true then
			ShopRefresh()
		else
			buyerror(1)
		end

		purchasing = false
	else
		buyerror(2)
	end
end)

local buycooldown = false

shopgui.Main.Cashdisplay.addCash.MouseButton1Click:Connect(function()
	if shopgui.DevProducts.Visible == true then
		shopgui.DevProducts.Visible = false
	else
		shopgui.DevProducts.Visible = true
	end
end)

shopgui.DevProducts.ScrollingFrame.TwoHundredCash.MouseButton1Click:Connect(function()
	if buycooldown == false then
		buycooldown = true
		MarketplaceService:PromptProductPurchase(Players.LocalPlayer, 1577497360)
		print("Buy attempted")
		wait(3)
		buycooldown = false
	else
		buyerror(2)
	end

end)

shopgui.DevProducts.ScrollingFrame.FiveHundredCash.MouseButton1Click:Connect(function()
	if buycooldown == false then
		buycooldown = true
		MarketplaceService:PromptProductPurchase(Players.LocalPlayer, 1577492040)
		wait(3)
		buycooldown = false
	else
		buyerror(2)
	end

end)

shopgui.DevProducts.ScrollingFrame.OneThousandCash.MouseButton1Click:Connect(function()
	if buycooldown == false then
		buycooldown = true
		MarketplaceService:PromptProductPurchase(Players.LocalPlayer, 1577496269)
		wait(3)
		buycooldown = false
	else
		buyerror(2)
	end

end)

shopgui.DevProducts.ScrollingFrame.FiveThousandCash.MouseButton1Click:Connect(function()
	if buycooldown == false then
		buycooldown = true
		MarketplaceService:PromptProductPurchase(Players.LocalPlayer, 1577496816)
		wait(3)
		buycooldown = false
	else
		buyerror(2)
	end

end)

shopgui.DevProducts.ScrollingFrame.TwentyFiveBarrage.MouseButton1Click:Connect(function()
	if buycooldown == false then
		buycooldown = true
		MarketplaceService:PromptProductPurchase(Players.LocalPlayer, 1575591152)
		wait(3)
		buycooldown = false
	else
		buyerror(2)
	end

end)



-- Mod Menu Stuff

function FindPlayers(String)
	local t = {}
	for i,v in pairs(game:GetService("Players"):GetChildren()) do
		if (string.sub(string.lower(v.Name),1,string.len(String))) == string.lower(String) then
			table.insert(t, v.Name)
		end
	end
	return t
end

local function NewButton(player)
	local clone = game.ReplicatedStorage.temp:Clone()
	clone.Parent = modgui.Frame.ScrollingFrame
	clone.playername.Text = player
	clone.Name = player

	local userId = Players:FindFirstChild(player).UserId
	local thumbType = Enum.ThumbnailType.AvatarBust
	local thumbSize = Enum.ThumbnailSize.Size60x60
	local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
	clone.playerimage.Image = (isReady and content) or PLACEHOLDER_IMAGE
end

local canidates = FindPlayers(modgui.Frame.TextBox.Text)

-- first time listing
for i, v in pairs(canidates) do
	task.wait()
	if modgui.Frame.ScrollingFrame:FindFirstChild(v) then
		--already there
	else
		NewButton(v)
	end
end
for i, v in pairs(modgui.Frame.ScrollingFrame:GetChildren()) do
	if v.Name == "UIListLayout" then
		-- ignore that
	else
		if table.find(canidates, v.Name) then
			--print("There")
		else
			v:Destroy()
		end
	end

end

local function updateplayerlist()
	local canidates = FindPlayers(modgui.Frame.TextBox.Text)

	for i, v in pairs(canidates) do
		task.wait()
		if modgui.Frame.ScrollingFrame:FindFirstChild(v) then
			--already there
		else
			NewButton(v)
		end
	end

	for i, v in pairs(modgui.Frame.ScrollingFrame:GetChildren()) do
		if v.Name == "UIListLayout" then
			-- ignore that
		else
			if not table.find(canidates, v.Name) then
				v:Destroy()
			end
		end

	end
end


modgui.Frame.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
	updateplayerlist()
end)

adminbutton.MouseButton1Click:Connect(function()
	if modgui.Enabled == false then
		modgui.Enabled = true
		updateplayerlist()
	else
		modgui.Enabled = false
	end
end)

modgui.Frame.closebutton.MouseButton1Click:Connect(function()
	modgui.Enabled = false
end)

-- Options
modgui.Frame.Options.Kick.MouseButton1Click:Connect(function()
	if #tostring(modgui.Frame.TextBox.Text) > 0 then
		local target = tostring(modgui.Frame.TextBox.Text)
		game.ReplicatedStorage.adminsend:FireServer(target, 1, tostring(modgui.Frame.Reason.Text))
	end

end)

modgui.Frame.Options.ForceWipe.MouseButton1Click:Connect(function()
	if modgui.Frame.AreYouSure.Visible == true then
		modgui.Frame.AreYouSure.Visible = false
	else
		modgui.Frame.AreYouSure.Visible = true
	end
end)

modgui.Frame.AreYouSure.yes.MouseButton1Click:Connect(function()
	if #tostring(modgui.Frame.TextBox.Text) > 0 then
		local target = tostring(modgui.Frame.TextBox.Text)
		game.ReplicatedStorage.adminsend:FireServer(target, 2)
	end
end)

modgui.Frame.AreYouSure.no.MouseButton1Click:Connect(function()
	modgui.Frame.AreYouSure.Visible = false
end)

modgui.Frame.Options.MapReset.MouseButton1Click:Connect(function()
	game.ReplicatedStorage.adminsend:FireServer("Blank", 4)
end)

modgui.Frame.Options.TP.MouseButton1Click:Connect(function()
	local target = Players:WaitForChild(tostring(modgui.Frame.TextBox.Text))
	game.ReplicatedStorage.adminsend:FireServer(target, 5)
end)

modgui.Frame.Options.Bring.MouseButton1Click:Connect(function()
	local target = Players:WaitForChild(tostring(modgui.Frame.TextBox.Text))
	game.ReplicatedStorage.adminsend:FireServer(target, 6)
end)

modgui.Frame.Options.Shutdown.MouseButton1Click:Connect(function()
	game.ReplicatedStorage.adminsend:FireServer("Blank", 7)
end)

-- Dev Product stuff
modgui.Frame.Options.DevProductTest.MouseButton1Click:Connect(function()
	if modgui.Frame.DevProductsgui.Visible == true then
		modgui.Frame.DevProductsgui.Visible = false
	else
		modgui.Frame.DevProductsgui.Visible = true
	end
end)
modgui.Frame.DevProductsgui.ScrollingFrame.TwoHundredCash.MouseButton1Click:Connect(function()
	local target = Players:WaitForChild(tostring(modgui.Frame.TextBox.Text))
	game.ReplicatedStorage.adminsend:FireServer(target, 8, 1)
end)

modgui.Frame.DevProductsgui.ScrollingFrame.FiveHundredCash.MouseButton1Click:Connect(function()
	local target = Players:WaitForChild(tostring(modgui.Frame.TextBox.Text))
	game.ReplicatedStorage.adminsend:FireServer(target, 8, 2)
end)

modgui.Frame.DevProductsgui.ScrollingFrame.OneThousandCash.MouseButton1Click:Connect(function()
	local target = Players:WaitForChild(tostring(modgui.Frame.TextBox.Text))
	game.ReplicatedStorage.adminsend:FireServer(target, 8, 3)
end)

modgui.Frame.DevProductsgui.ScrollingFrame.FiveThousandCash.MouseButton1Click:Connect(function()
	local target = Players:WaitForChild(tostring(modgui.Frame.TextBox.Text))
	game.ReplicatedStorage.adminsend:FireServer(target, 8, 4)
end)

modgui.Frame.DevProductsgui.ScrollingFrame.TwentyFiveBarrage.MouseButton1Click:Connect(function()
	local target = Players:WaitForChild(tostring(modgui.Frame.TextBox.Text))
	game.ReplicatedStorage.adminsend:FireServer(target, 8, 5)
end)

modgui.Frame.Options.Ban.MouseButton1Click:Connect(function()
	local target = tostring(modgui.Frame.TextBox.Text)
	game.ReplicatedStorage.adminsend:FireServer(target, 9, tonumber(modgui.Frame.Amount.Text), 1)
end)

modgui.Frame.Options.Unban.MouseButton1Click:Connect(function()
	local target = tostring(modgui.Frame.TextBox.Text)
	game.ReplicatedStorage.adminsend:FireServer(target, 9, tonumber(modgui.Frame.Amount.Text), 2)
end)


-- Data Write Admin Menu
modgui.Frame.Options.DataWrite.MouseButton1Click:Connect(function()
	if modgui.Frame.datawritegui.Visible == true then
		modgui.Frame.datawritegui.Visible = false
	else
		modgui.Frame.datawritegui.Visible = true
	end
end)

modgui.Frame.datawritegui.ScrollingFrame.GiveAdmin.MouseButton1Click:Connect(function()
	local target = Players:WaitForChild(tostring(modgui.Frame.TextBox.Text))
	game.ReplicatedStorage.adminsend:FireServer(target, 3, 'Admin', true)
end)

modgui.Frame.datawritegui.ScrollingFrame.TakeAdmin.MouseButton1Click:Connect(function()
	local target = Players:WaitForChild(tostring(modgui.Frame.TextBox.Text))
	game.ReplicatedStorage.adminsend:FireServer(target, 3, 'Admin', false)
end)

modgui.Frame.datawritegui.ScrollingFrame.MoneyMultiplier.MouseButton1Click:Connect(function()
	local target = Players:WaitForChild(tostring(modgui.Frame.TextBox.Text))
	game.ReplicatedStorage.adminsend:FireServer(target, 3, 'MoneyMultiplier', tonumber(modgui.Frame.Amount.Text))
end)

modgui.Frame.datawritegui.ScrollingFrame.ExplosionSizeUpgrade.MouseButton1Click:Connect(function()
	local target = Players:WaitForChild(tostring(modgui.Frame.TextBox.Text))
	game.ReplicatedStorage.adminsend:FireServer(target, 3, 'ExplosionSizeUpgrade', tonumber(modgui.Frame.Amount.Text))
end)

modgui.Frame.datawritegui.ScrollingFrame.SpeedUpgrade.MouseButton1Click:Connect(function()
	local target = Players:WaitForChild(tostring(modgui.Frame.TextBox.Text))
	game.ReplicatedStorage.adminsend:FireServer(target, 3, 'SpeedUpgrade', tonumber(modgui.Frame.Amount.Text))
end)

modgui.Frame.datawritegui.ScrollingFrame.Cash.MouseButton1Click:Connect(function()
	local target = Players:WaitForChild(tostring(modgui.Frame.TextBox.Text))
	game.ReplicatedStorage.adminsend:FireServer(target, 3, 'Cash', tonumber(modgui.Frame.Amount.Text))
end)

modgui.Frame.datawritegui.ScrollingFrame.LogInTimes.MouseButton1Click:Connect(function()
	local target = Players:WaitForChild(tostring(modgui.Frame.TextBox.Text))
	game.ReplicatedStorage.adminsend:FireServer(target, 3, 'LogInTimes', tonumber(modgui.Frame.Amount.Text))
end)

modgui.Frame.datawritegui.ScrollingFrame.BarrageReplenishSpeed.MouseButton1Click:Connect(function()
	local target = Players:WaitForChild(tostring(modgui.Frame.TextBox.Text))
	game.ReplicatedStorage.adminsend:FireServer(target, 3, 'BarrageReplenishUpgrade', tonumber(modgui.Frame.Amount.Text))
end)

modgui.Frame.datawritegui.ScrollingFrame.Barrages.MouseButton1Click:Connect(function()
	local target = Players:WaitForChild(tostring(modgui.Frame.TextBox.Text))
	game.ReplicatedStorage.adminsend:FireServer(target, 3, 'Barrages', tonumber(modgui.Frame.Amount.Text))
end)

-- Executor
modgui.Frame.Options.executor.MouseButton1Click:Connect(function()
	if modgui.Frame.ExecutorGui.Visible == true then
		modgui.Frame.ExecutorGui.Visible = false
	else
		modgui.Frame.ExecutorGui.Visible = true
	end
end)

modgui.Frame.ExecutorGui.ExecuteButton.MouseButton1Click:Connect(function()
	local cmd = modgui.Frame.ExecutorGui.ScrollingFrame.Frame.TextBox.Text
	print("Execute called")
	local log = game.ReplicatedStorage.execute:InvokeServer(1, cmd)
	if log == true then
		modgui.Frame.ExecutorGui.ErrorLogOpen.ErrorDisplay.Transparency = 0
		modgui.Frame.ExecutorGui.ErrorLogOpen.ErrorDisplay.BackgroundColor3 = Color3.new(0, 1, 0)
		modgui.Frame.ExecutorGui.ErrorLogOpen.Frame.ScrollingFrame.TextBox.TextColor3 = Color3.new(0, 1, 0)
		modgui.Frame.ExecutorGui.ErrorLogOpen.Frame.ScrollingFrame.TextBox.Text = tostring(log)
	else
		modgui.Frame.ExecutorGui.ErrorLogOpen.ErrorDisplay.Transparency = 0
		modgui.Frame.ExecutorGui.ErrorLogOpen.ErrorDisplay.BackgroundColor3 = Color3.new(1, 0, 0)
		modgui.Frame.ExecutorGui.ErrorLogOpen.Frame.ScrollingFrame.TextBox.TextColor3 = Color3.new(1, 0, 0)
		modgui.Frame.ExecutorGui.ErrorLogOpen.Frame.ScrollingFrame.TextBox.Text = tostring(log)
		modgui.Frame.ExecutorGui.ErrorLogOpen.Frame.ScrollingFrame.TextBox.TextTransparency = 1
	end
end)

modgui.Frame.ExecutorGui.ClearButton.MouseButton1Click:Connect(function()
	modgui.Frame.ExecutorGui.ScrollingFrame.Frame.TextBox.Text = ""
end)

modgui.Frame.ExecutorGui.CloseButton.MouseButton1Click:Connect(function()
	modgui.Frame.ExecutorGui.Visible = false
end)
