
-- ProfileTemplate table is what empty profiles will default to.
-- Updating the template will not include missing template values
--   in existing player profiles!
local SETTINGS = {

	ProfileTemplate = {
		Barrages = 5,
		LogInTimes = 0,
		Cash = 0,
		SpeedUpgrade = 0,
		ExplosionSizeUpgrade = 0,
		BarrageReplenishUpgrade = 0,
		MoneyMultiplier = 0,
		Admin = false,
		Banned = false,
	},

	Products = { -- developer_product_id = function(profile)
		[1575591152] = function(profile)
			profile.Data.Barrages += 25
		end,
		[1577497360] = function(profile)
			profile.Data.Cash += 200
		end,

		[1577492040] = function(profile)
			profile.Data.Cash += 500
		end,

		[1577496269] = function(profile)
			profile.Data.Cash += 1000
		end,

		[1577496816] = function(profile)
			profile.Data.Cash += 5000
		end,
	},

	PurchaseIdLog = 50, -- Store this amount of purchase id's in MetaTags;
	-- This value must be reasonably big enough so the player would not be able
	-- to purchase products faster than individual purchases can be confirmed.
	-- Anything beyond 30 should be good enough.

}


local admins = {
	423797931, -- me
	2422070330, -- alt
}
----- Loaded Modules -----

local ProfileService = require(game.ServerScriptService.ProfileService)
local mapresetmodule = require(game.ServerScriptService.mapresetfunction)

----- Private Variables -----

local Players = game:GetService("Players")
local TweenService = game:GetService('TweenService')
local MarketplaceService = game:GetService("MarketplaceService")
local ms = game:GetService("MessagingService")

local ProfileStore = ProfileService.GetProfileStore(
	"PlayerData",
	SETTINGS.ProfileTemplate
)

local Profiles = {} -- [player] = profile

----- Private Functions -----

Players.CharacterAutoLoads = false

local function printclient(player, returnprint)
	local printdata = returnprint.." PrintClient"
	print(returnprint, "(To Client", player.Name..')')
	game.ReplicatedStorage.databack:FireClient(player, 2, printdata)
end

local function GetPlayerProfileAsync(player) --> [Profile] / nil
	-- Yields until a Profile linked to a player is loaded or the player leaves
	local profile = Profiles[player]
	while profile == nil and player:IsDescendantOf(Players) == true do
		task.wait()
		profile = Profiles[player]
	end
	return profile
end

local function OnServerLogin(player, profile)
	profile.Data.LogInTimes = profile.Data.LogInTimes + 1
	local joinmessage = (player.Name .. " has logged in " .. tostring(profile.Data.LogInTimes).. " time" .. ((profile.Data.LogInTimes > 1) and "s" or ""))
	printclient(player, joinmessage)
	--GiveCash(profile, 100)
	--print(player.Name .. " owns " .. tostring(profile.Data.Barrages) .. " barrages now!")
	--print(player.Name .. " owns " .. tostring(profile.Data.Cash) .. " cash now!")
	print(profile, tostring(player).."'s profile.")
	print("OnServerLogin Completed for "..player.Name)
end

local function LSRefresh(player, location)
	print("LSRefresh", location)
	player.PlayerGui:WaitForChild('Main')
	local profile = GetPlayerProfileAsync(player)
	player.leaderstats.Cash.Value = profile.Data.Cash
	player.leaderstats.Logins.Value = profile.Data.LogInTimes
	player.Character.Humanoid.WalkSpeed = ((profile.Data.SpeedUpgrade + 1) * 10) + 16
	game.ReplicatedStorage.databack:FireClient(player, 3)
	if profile.Data.Admin == false then
		if table.find(admins, player.UserId) then
			profile.Data.Admin = true
		end
	end

	if profile.Data.Admin == true then
		--game.ReplicatedStorage.databack:FireClient(player, 4)
		player.PlayerGui.Main.buttons.adminbutton.Visible = true
		--printclient(player, "Welcome Admin")
	end
end

local function OnCharacterAdded(player)
	local profile = GetPlayerProfileAsync(player)
	-- Create a container for leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	printclient(player, "Character Added")
	-- Create one leaderstat value
	local vScore = Instance.new("IntValue")
	vScore.Name = "Cash"
	vScore.Value = profile.Data.Cash
	vScore.Parent = leaderstats
	local eScore = Instance.new("IntValue")
	eScore.Name = "Logins"
	eScore.Value = profile.Data.LogInTimes
	eScore.Parent = leaderstats

	-- Add to player (displaying it)
	leaderstats.Parent = player
	LSRefresh(player, "OnCharacterAdded")

end

local function Economics(player, datatype)
	local profile = GetPlayerProfileAsync(player)
	if datatype == 0 then
		local speedcost = 50 + (20 * profile.Data.SpeedUpgrade)
		local explosioncost = 50 + (20 * profile.Data.ExplosionSizeUpgrade)
		local barragecost = 50 + (20 * profile.Data.BarrageReplenishUpgrade)
		local moneycost = 50 + (20 * profile.Data.MoneyMultiplier)
		local returntable = {
			profile.Data.Cash,
			profile.Data.SpeedUpgrade,
			profile.Data.ExplosionSizeUpgrade,
			profile.Data.BarrageReplenishUpgrade,
			profile.Data.MoneyMultiplier,
			speedcost,
			explosioncost,
			barragecost,
			moneycost
		}
		return returntable
	end

	if datatype == 1 then
		local speedcost = 50 + (20 * profile.Data.SpeedUpgrade)
		if profile.Data.Cash >= speedcost then
			profile.Data.Cash = profile.Data.Cash - speedcost
			profile.Data.SpeedUpgrade = profile.Data.SpeedUpgrade + 1
			player.Character.Humanoid.WalkSpeed = ((profile.Data.SpeedUpgrade + 1) * 10) + 16
			return true
		else
			return false
		end
	end

	if datatype == 2 then
		local explosioncost = 50 + (20 * profile.Data.ExplosionSizeUpgrade)
		if profile.Data.Cash >= explosioncost then
			profile.Data.Cash = profile.Data.Cash - explosioncost
			profile.Data.ExplosionSizeUpgrade = profile.Data.ExplosionSizeUpgrade + 1
			return true
		else
			return false
		end
	end

	if datatype == 3 then
		local barragecost = 50 + (20 * profile.Data.BarrageReplenishUpgrade)
		if profile.Data.Cash >= barragecost then
			profile.Data.Cash = profile.Data.Cash - barragecost
			profile.Data.BarrageReplenishUpgrade = profile.Data.BarrageReplenishUpgrade + 1
			return true
		else
			return false
		end
	end

	if datatype == 4 then
		local moneycost = 50 + (20 * profile.Data.MoneyMultiplier)
		if profile.Data.Cash >= moneycost then
			profile.Data.Cash = profile.Data.Cash - moneycost
			profile.Data.MoneyMultiplier = profile.Data.MoneyMultiplier + 1
			return true
		else
			return false
		end
	end

	if datatype == 5 then
		local addedmoney = math.floor(15 + (profile.Data.MoneyMultiplier * 5))
		profile.Data.Cash = profile.Data.Cash + addedmoney
		local clone = game.ReplicatedStorage.Money:Clone()
		clone.Name = player.Name..profile.Data.Cash
		clone.Parent = player.PlayerGui.Main.buttons
		clone.Text = "+"..addedmoney.." Cash"
		clone.Rotation = math.random(-50, 50)
		clone.BackgroundTransparency = 1
		clone.TextTransparency = 0
		clone.Position = UDim2.new(math.random(-0.5,0.5), 0, math.random(-6, -4), 0)
		clone.TextSize = math.random(50, 100)
		local tweenGoal = {
			['TextTransparency'] = 1,
			['Rotation'] = math.random(-50, 50)
			--['Position'] = UDim2.new(0.031, 0, 0.094, 0)
		}
		local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		local fadetween = TweenService:Create(clone, tweenInfo, tweenGoal)
		fadetween:Play()
		print("attempted")
		--game.ReplicatedStorage.databack:FireClient(player, 4, addedmoney)
	end

	LSRefresh(player, 'Economics')
end

local function PlayerAdded(player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			Profiles[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)
		if player:IsDescendantOf(Players) == true then
			Profiles[player] = profile
			print("Profile Loaded")
			-- A profile has been successfully loaded:
			OnServerLogin(player, profile)
			local BarrageAddLoop = coroutine.wrap(function(player, profile)
				local privatebarrages = profile.Data.Barrages
				printclient(player, "Barrage Loop Initialized")
				if MarketplaceService:UserOwnsGamePassAsync(player.UserId, 203171282) then
					privatebarrages = "Inf"
					game.ReplicatedStorage.databack:FireClient(player, 1, privatebarrages)
				else
					while player:IsDescendantOf(Players) do
						game.ReplicatedStorage.databack:FireClient(player, 1, privatebarrages)
						local timer = math.floor(2 * (60 / (1 + profile.Data.BarrageReplenishUpgrade)))
						for i = timer, 0, -1 do
							game.Players[player.Name].PlayerGui:WaitForChild("FireMenu").Frame.barragetimer.Text = i
							--	printclient(player, "Looped"..i)
							task.wait(1)
						end
						profile.Data.Barrages = profile.Data.Barrages + 1
						privatebarrages = profile.Data.Barrages
						printclient(player, "Attempted to add barrage")

					end
				end
				print("BarrageAddLoop Completed for "..player.Name)
			end)
			BarrageAddLoop(player, profile)

		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		--   Roblox servers trying to load this profile at the same time:
		player:Kick()
	end
	if profile.Data.Banned == true then
		player:Kick('You have been banned! Appeal in dizzy.')
	end
	if table.find(admins, player.UserId) then
		profile.Data.Admin = true
		print("Granted")
	end
	player.CharacterAdded:Connect(function(Character)
		OnCharacterAdded(player)
		Character.Humanoid.Died:Connect(function()
			wait(3)
			player:LoadCharacter()
		end)
	end)
	player:LoadCharacter()
end

function PurchaseIdCheckAsync(profile, purchase_id, grant_product_callback) --> Enum.ProductPurchaseDecision
	-- Yields until the purchase_id is confirmed to be saved to the profile or the profile is released

	if profile:IsActive() ~= true then

		return Enum.ProductPurchaseDecision.NotProcessedYet

	else

		local meta_data = profile.MetaData

		local local_purchase_ids = meta_data.MetaTags.ProfilePurchaseIds
		if local_purchase_ids == nil then
			local_purchase_ids = {}
			meta_data.MetaTags.ProfilePurchaseIds = local_purchase_ids
		end

		-- Granting product if not received:

		if table.find(local_purchase_ids, purchase_id) == nil then
			while #local_purchase_ids >= SETTINGS.PurchaseIdLog do
				table.remove(local_purchase_ids, 1)
			end
			table.insert(local_purchase_ids, purchase_id)
			task.spawn(grant_product_callback)
		end

		-- Waiting until the purchase is confirmed to be saved:

		local result = nil

		local function check_latest_meta_tags()
			local saved_purchase_ids = meta_data.MetaTagsLatest.ProfilePurchaseIds
			if saved_purchase_ids ~= nil and table.find(saved_purchase_ids, purchase_id) ~= nil then
				result = Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end

		check_latest_meta_tags()

		local meta_tags_connection = profile.MetaTagsUpdated:Connect(function()
			check_latest_meta_tags()
			-- When MetaTagsUpdated fires after profile release:
			if profile:IsActive() == false and result == nil then
				result = Enum.ProductPurchaseDecision.NotProcessedYet
			end
		end)

		while result == nil do
			task.wait()
		end

		meta_tags_connection:Disconnect()

		return result

	end

end

local function GrantProduct(player, product_id)
	-- We shouldn't yield during the product granting process!
	local profile = Profiles[player]
	local product_function = SETTINGS.Products[product_id]
	if product_function ~= nil then
		product_function(profile)
		print(player, "Bought", product_id)
		LSRefresh(player)
	else
		warn("ProductId " .. tostring(product_id) .. " has not been defined in Products table")
	end
end

local function ProcessReceipt(receipt_info)

	local player = Players:GetPlayerByUserId(receipt_info.PlayerId)

	if player == nil then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local profile = GetPlayerProfileAsync(player)

	if profile ~= nil then

		return PurchaseIdCheckAsync(
			profile,
			receipt_info.PurchaseId,
			function()
				GrantProduct(player, receipt_info.ProductId)
			end
		)

	else
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

end

-- Explode func
local function explode(player, piece, p)
	--local sfxclone = game.ServerStorage.sfx:Clone()
	--sfxclone.Parent = workspace
	local profile = GetPlayerProfileAsync(player)
	piece.sfx:Destroy()
	mapresetmodule.Tag(p)
	local explosionsize = (profile.Data.ExplosionSizeUpgrade * 2) + 5
	local explosion = Instance.new("Explosion")
	explosion.Position = piece.Position
	explosion.BlastRadius = explosionsize
	explosion.DestroyJointRadiusPercent = 10
	explosion.BlastPressure = 50000
	explosion.Parent = game.Workspace
	--game.ReplicatedStorage.clientexplosion:FireAllClients(piece.Position, explosionsize)
	piece:Destroy()
	Economics(player, 5)
	--task.wait(0.5)
end

-- Barrage func -Needs randomization and mabye higher damage size.
local function barrage(player, timemodifier, hitpos)

	--	print("barrage Called")
	local armed = false
	local armed1 = false
	local armed2 = false
	local gamestate = true
	local pos1 = game.Workspace.pos1.Position
	--print(pos1)
	local pos2 = hitpos
	--print(pos2)

	local clone2 = game.ServerStorage.Projectile:Clone()
	clone2.Name = player.Name.."Projectile2"
	clone2.Position = pos1
	clone2.Parent = workspace

	local clone1 = game.ServerStorage.Projectile:Clone()
	clone1.Name = player.Name.."Projectile1"
	clone1.Position = pos1
	clone1.Parent = workspace

	local clone = game.ServerStorage.Projectile:Clone()
	clone.Name = player.Name.."Projectile"
	clone.Position = pos1
	clone.Parent = workspace


	local starttime = os.clock()
	local direction = pos2 - pos1
	local duration = math.log(1.001 + direction.Magnitude * 0.01, timemodifier)
	local force = direction / duration + Vector3.new(0, game.Workspace.Gravity * duration * 0.5, 0)
	--print(timemodifier)
	game.Workspace.Mortar.launchsfx:Play()
	--print(duration, "Time until target")

	clone2:ApplyImpulse(force * clone2.AssemblyMass)
	clone2:SetNetworkOwner(nil)
	clone2.whistle:Play()
	wait(0.5)

	clone1:ApplyImpulse(force * clone1.AssemblyMass)
	clone1:SetNetworkOwner(nil)
	clone1.whistle:Play()
	wait(0.5)

	clone:ApplyImpulse(force * clone.AssemblyMass)
	clone:SetNetworkOwner(nil)
	clone.whistle:Play()


	coroutine.wrap(function()
		armed1 = false
		armed2 = false
		armed = false
		wait(0.2)
		clone.Transparency = 0
		clone2.Transparency = 0
		clone1.Transparency = 0
		wait(0.1)
		armed1 = true
		armed2 = true
		armed = true
		--print("Thread Exited, Warhead Armed")
	end)()
	
	clone.Touched:Connect(function(p)
		if armed == true then
			print("Touched")
			gamestate = false
			armed = false
			explode(player, clone, p)
		end

	end)

	clone2.Touched:Connect(function(p)
		if armed2 == true then
			print("Touched")
			armed2 = false
			explode(player, clone2, p)	
		end

	end)

	clone1.Touched:Connect(function(p)
		if armed1 == true then
			print("Touched")
			armed1 = false
			explode(player, clone1, p)
		end

	end)

	game.ReplicatedStorage.Cancel.OnServerEvent:Connect(function()
		print("Server Canceled")
		gamestate = false
		clone:Destroy()
		clone1:Destroy()
		clone2:Destroy()
	end)
	local fortheonetime = false
	while true do 
		task.wait()
		local currenttime = os.clock()

		local timesincestart = currenttime - starttime


		local realtime = duration - timesincestart

		local realtimecut = realtime * 10
		realtimecut = math.floor(realtimecut)
		realtimecut = realtimecut / 10

		if realtime >= 0 then
			player.PlayerGui.FireMenu.Frame.Countdown.Text = realtimecut
		end
		-- print(realtimecut, "Time until target")

		if realtime <= 0 then
			if fortheonetime == false then
				print("Ended")
				fortheonetime = true
			end
			--gamestate = false
			player.PlayerGui.FireMenu.Frame.Countdown.Text = "Impact"
			--explode(clone)
		end

		if realtime <= -5 then
			print("Timeout")
			--gamestate = false
			player.PlayerGui.FireMenu.Frame.Countdown.Text = "Impact"
			--explode(clone)
		end

		if gamestate == false then
			game.ReplicatedStorage.StoppedEvent:FireClient(player)
			return
		end
	end	
end

local function singlefire(player, timemodifier, hitpos)

	local armed = false
	local gamestate = true
	local pos1 = game.Workspace.pos1.Position
	print(pos1)
	local pos2 = hitpos
	print(pos2)

	local starttime = os.clock()		
	local direction = pos2 - pos1
	local duration = math.log(1.001 + direction.Magnitude * 0.01, timemodifier)
	local force = direction / duration + Vector3.new(0, game.Workspace.Gravity * duration * 0.5, 0)
	print(force)
	print(timemodifier)
	game.Workspace.Mortar.launchsfx:Play()
	--print(duration, "Time until target")

	local clone = game.ServerStorage.Projectile:Clone()
	clone.Name = player.Name.."Projectile"
	clone.Position = pos1
	clone.Parent = workspace
	clone:ApplyImpulse(force * clone.AssemblyMass)
	clone:SetNetworkOwner(nil)
	clone.whistle:Play()

	coroutine.wrap(function()
		armed = false
		wait(0.2)
		clone.Transparency = 0
		wait(0.5)
		armed = true
		print("Thread Exited, Warhead Armed")
	end)()

	clone.Touched:Connect(function(p)
		if armed == true then
			print("Touched")
			gamestate = false
			armed = false
			explode(player, clone, p)
			player.PlayerGui.FireMenu.Frame.Countdown.Text = "Impact"
		end

	end)

	game.ReplicatedStorage.Cancel.OnServerEvent:Connect(function()
		print("Server Canceled")
		gamestate = false
		clone:Destroy()
	end)

	while true do 
		task.wait()
		local currenttime = os.clock()

		local timesincestart = currenttime - starttime


		local realtime = duration - timesincestart

		local realtimecut = realtime * 10
		realtimecut = math.floor(realtimecut)
		realtimecut = realtimecut / 10

		player.PlayerGui.FireMenu.Frame.Countdown.Text = realtimecut
		-- print(realtimecut, "Time until target")

		if realtime <= 0 then
			print("Ended")
			--gamestate = false
			player.PlayerGui.FireMenu.Frame.Countdown.Text = "Impact"
			--explode(clone)
		end

		if realtime <= -2 then
			warn("Timeout")
			gamestate = false
			--gamestate = false
			player.PlayerGui.FireMenu.Frame.Countdown.Text = "Impact"
			--explode(clone)
		end

		if gamestate == false then
			game.ReplicatedStorage.StoppedEvent:FireClient(player)
			return
		end
	end
end

local function A10Strike(player, timemodifier, hitpos)
	--warn("a10function")
	game.ReplicatedStorage.databack:FireAllClients(4, timemodifier, hitpos)
	
end

local function datarespond(player, datatype)
	--print("Data Resquest started.")

	if datatype == "Shop0" then
		return Economics(player, 0)
	end

	if datatype == "Shop1" then
		LSRefresh(player, 'shop1')
		return Economics(player, 1)
	end

	if datatype == "Shop2" then
		LSRefresh(player, 'shop2')
		return Economics(player, 2)
	end

	if datatype == "Shop3" then
		LSRefresh(player, 'shop3')
		return Economics(player, 3)
	end

	if datatype == "Shop4" then
		LSRefresh(player, 'shop4')
		return Economics(player, 4)
	end
end

local function shutdown()
	game.Players.ChildAdded:connect(
		function(h)
			h:Kick("Server Is Shutting Down: Rejoin")
		end
	)
	for _, i in pairs(game.Players:GetChildren()) do
		i:Kick('Server Is Shutting Down: Rejoin')
	end
end

ms:SubscribeAsync("Kick", function(message)
	local name = message.Data
	if pcall(function() Players[name]:Kick() end) then 
		print("success")
	end
end)
-- through some Gui or either something on the client,  fire an event to do this

local function kickasync(playerName)
	local player = Players:FindFirstChild(playerName) 
	if player then player:Kick() 
	else
		ms:PublishAsync("Kick", playerName)
	end
end

local function GetUserId(Value)
	if not tonumber(Value) and Players:FindFirstChild(tostring(Value)) then
		return Players:FindFirstChild(tostring(Value)).UserId
	else
		local Id = false

		local SuccesId, ReturnName = pcall(function()
			Players:GetNameFromUserIdAsync(Value)
			Id = Value
		end)

		local SuccesName, ReturnId = pcall(function()
			Id = Players:GetUserIdFromNameAsync(Value)
		end)
		return Id
	end
end

local function IsPlrInServer(target)
	local tbl = Players:GetPlayers()
	for i, v in pairs(tbl) do
		if v.Name == target then
			return true
		end
	end
	return false
end

local function ExecuteString(plr, datatype, cmd)
	if datatype == 1 then
		local profile = GetPlayerProfileAsync(plr)
		if profile.Data.Admin == true then
			local success, er = pcall(function()
				local func = loadstring(cmd)

				func()
			end)

			if er then
				print(er)
				return er
			end

			if success then
				print(success)
				return success
			end
		else
			plr:Kick("lil bro")
			return
		end
	end
end

local function adminhandler(player, target, datatype, reason, amount)

	if datatype == 1 then
		if not table.find(admins, target.UserId) then
			print("Kicking", target)
			kickasync(target)
		end
	end

	if datatype == 2 then
		if not table.find(admins, target.UserId) then
			local id = GetUserId(target)
			local success = ProfileStore:WipeProfileAsync("Player_" .. id)
			if success == true then
				print(success)
				kickasync(target)
			else
				warn(success)
			end
		end
	end

	if datatype == 3 then
		local profile = GetPlayerProfileAsync(target)
		if profile.Data[reason] == nil then
		else
			profile.Data[reason] = amount
			LSRefresh(target, 'Admin Data Change')
			print(profile.Data[reason])
		end
		print(tostring(profile.Data[reason]))
	end

	if datatype == 4 then
		mapresetmodule.MapResetGui()
	end

	if datatype == 5 then
		player.Character:MoveTo(target.Character.HumanoidRootPart.Position)
	end

	if datatype == 6 then
		target.Character:MoveTo(player.Character.HumanoidRootPart.Position)
	end

	if datatype == 7 then
		shutdown()
	end

	if datatype == 8 then
		if reason == 1 then
			MarketplaceService:PromptProductPurchase(target, 1577497360)
		end
		if reason == 2 then
			MarketplaceService:PromptProductPurchase(target, 1577492040)
		end
		if reason == 3 then
			MarketplaceService:PromptProductPurchase(target, 1577496269)
		end
		if reason == 4 then
			MarketplaceService:PromptProductPurchase(target, 1577496816)
		end
		if reason == 5 then
			MarketplaceService:PromptProductPurchase(target, 1575591152)
		end
	end
	
	if datatype == 9 then
		if not table.find(admins, target.UserId) then
			local playertable = Players:GetPlayers()
			local yurr = IsPlrInServer(target)
			local uid = GetUserId(target)
			if not yurr then
				local profile = ProfileStore:LoadProfileAsync(
					"Player_" .. uid,
					function(place_id, game_job_id)
						-- place_id and game_job_id identify the Roblox server that has
						--   this profile currently locked. In rare cases, if the server
						--   crashes, the profile will stay locked until ForceLoaded by
						--   a new session.
						return "ForceLoad"
					end)
				if amount == 1 then
					profile.Data.Banned = true
					kickasync(target)
				end
				
				if amount == 2 then
					profile.Data.Banned = false
				end
				
				--print(profile)
				profile:Release()
			else
				local target2 = Players:WaitForChild(target)
				local profile = GetPlayerProfileAsync(target2)
				if amount == 1 then
					profile.Data.Banned = true
					target:Kick('You have been banned! Appeal in dizzy.')
				end

				if amount == 2 then
					profile.Data.Banned = false
				end

			end
		end
		
	end
end

game.ReplicatedStorage.dataask.OnServerInvoke = datarespond
game.ReplicatedStorage.execute.OnServerInvoke = ExecuteString
----- Initialize -----

-- In case Players have joined the server earlier than this script ran:
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

MarketplaceService.ProcessReceipt = ProcessReceipt
----- Connections -----

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local profile = Profiles[player]
	if profile ~= nil then
		profile:Release()
	end
end)


-- Fire event
game.ReplicatedStorage.Send.OnServerEvent:Connect(function(player, timemodifier, hitpos)
	singlefire(player, timemodifier, hitpos)
	--local armed = false
	--local gamestate = true
	--local pos1 = game.Workspace.pos1.Position
	--print(pos1)
	--local pos2 = hitpos
	--print(pos2)

	--local starttime = os.clock()		
	--local direction = pos2 - pos1
	--local duration = math.log(1.001 + direction.Magnitude * 0.01, timemodifier)
	--local force = direction / duration + Vector3.new(0, game.Workspace.Gravity * duration * 0.5, 0)
	--print(timemodifier)
	--game.Workspace.Mortar.launchsfx:Play()
	----print(duration, "Time until target")

	--local clone = game.ServerStorage.Projectile:Clone()
	--clone.Name = player.Name.."Projectile"
	--clone.Position = pos1
	--clone.Parent = workspace
	--clone:ApplyImpulse(force * clone.AssemblyMass)
	--clone:SetNetworkOwner(nil)
	--clone.whistle:Play()

	--coroutine.wrap(function()
	--	armed = false
	--	wait(0.2)
	--	clone.Transparency = 0
	--	wait(0.5)
	--	armed = true
	--	print("Thread Exited, Warhead Armed")
	--end)()

	--clone.Touched:Connect(function(p)
	--	if armed == true then
	--		print("Touched")
	--		gamestate = false
	--		armed = false
	--		explode(player, clone, p)
	--		player.PlayerGui.FireMenu.Frame.Countdown.Text = "Impact"
	--	end

	--end)

	--game.ReplicatedStorage.Cancel.OnServerEvent:Connect(function()
	--	print("Server Canceled")
	--	gamestate = false
	--	clone:Destroy()
	--end)

	--while true do 
	--	task.wait()
	--	local currenttime = os.clock()

	--	local timesincestart = currenttime - starttime


	--	local realtime = duration - timesincestart

	--	local realtimecut = realtime * 10
	--	realtimecut = math.floor(realtimecut)
	--	realtimecut = realtimecut / 10

	--	player.PlayerGui.FireMenu.Frame.Countdown.Text = realtimecut
	--	-- print(realtimecut, "Time until target")

	--	if realtime <= 0 then
	--		print("Ended")
	--		--gamestate = false
	--		player.PlayerGui.FireMenu.Frame.Countdown.Text = "Impact"
	--		--explode(clone)
	--	end

	--	if realtime <= -2 then
	--		warn("Timeout")
	--		gamestate = false
	--		--gamestate = false
	--		player.PlayerGui.FireMenu.Frame.Countdown.Text = "Impact"
	--		--explode(clone)
	--	end

	--	if gamestate == false then
	--		game.ReplicatedStorage.StoppedEvent:FireClient(player)
	--		return
	--	end
	--end	
end)

-- Barrage checking.
game.ReplicatedStorage.Barrage.OnServerEvent:Connect(function(player, timemodifier, hitpos)

	local profile = GetPlayerProfileAsync(player)

	if MarketplaceService:UserOwnsGamePassAsync(player.UserId, 203171282) then
		printclient(player, "User Owned Gamepass, Fire barrage")
		game.ReplicatedStorage.databack:FireClient(player, 1, "Inf")
		barrage(player, timemodifier, hitpos)

	else if profile.Data.Barrages > 0 then

			profile.Data.Barrages = profile.Data.Barrages - 1
			printclient(player, profile.Data.Barrages.." Barrages Left")
			game.ReplicatedStorage.databack:FireClient(player, 1, profile.Data.Barrages)
			barrage(player, timemodifier, hitpos)
		end
	end
end)

game.ReplicatedStorage.airstrike.OnServerEvent:Connect(function(player, timemodifier, hitpos)
	--warn("onservereventa10")
	A10Strike(player, timemodifier, hitpos)
end)
--Admin Events
game.ReplicatedStorage.adminsend.OnServerEvent:Connect(function(player, target, datatype, reason, amount)
	local profile = GetPlayerProfileAsync(player)
	if profile.Data.Admin == true then
		print(player, target, datatype, reason, amount)
		adminhandler(player, target, datatype, reason, amount)
	else
		player:Kick("lil bro")
		return
	end
end)
	
