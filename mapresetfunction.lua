local module = {}

function module.Tag()
	
end



function module.MapReset()
	workspace:WaitForChild("Enviroment1"):Destroy()
	wait(0.2)
	local clonedEnviroment1 = game.ServerStorage.Enviroment1:Clone()
	clonedEnviroment1.Parent = game.Workspace
	wait(0.2)
	workspace:WaitForChild("Enviroment2"):Destroy()
	wait(0.2)
	local clonedEnviroment2 = game.ServerStorage.Enviroment2:Clone()
	clonedEnviroment2.Parent = game.Workspace
end

function module.MapResetGui()
	workspace:WaitForChild("Enviroment1"):Destroy()
	wait(0.2)
	local clonedEnviroment1 = game.ServerStorage.Enviroment1:Clone()
	clonedEnviroment1.Parent = game.Workspace
	wait(0.2)
	workspace:WaitForChild("Enviroment2"):Destroy()
	wait(0.2)
	local clonedEnviroment2 = game.ServerStorage.Enviroment2:Clone()
	clonedEnviroment2.Parent = game.Workspace
	game.ServerScriptService.MapResettimer.Enabled = false
	wait(1)
	game.ServerScriptService.MapResettimer.Enabled = true
end

return module
