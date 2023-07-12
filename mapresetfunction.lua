local stfolders = game.Workspace.Enviroment:GetChildren()

for i, v in ipairs(stfolders) do
	v.Name = i
	local clone = v:Clone()
	clone.Parent = game.ServerStorage.Enviroment
end



local module = {}


local hits = {
	
}

print('Map Reset System Initialized')

--local function IsInDictionary(tbl, target)
--	for i, v in hits do
--		if i == target then
--			return true
--		end
--	end
--	return false
--end


function module.Tag(p)
	local folder = p:FindFirstAncestorOfClass('Folder')
	if folder then
		hits[folder] = {}
		hits[folder] = {
			['time'] = os.time()
		}
		print(hits)
		print(folder)
	end
end

--[[
while true do
	for i, v in pairs(hits) do
		--if v[current] > os.time() - 5 then
			-- destroy() the folder
			-- clone the folder from replicatedstorage
		--end
	end
end
]]

function module.MapReset()
	--workspace:WaitForChild("Enviroment1"):Destroy()
	--wait(0.2)
	--local clonedEnviroment1 = game.ServerStorage.Enviroment1:Clone()
	--clonedEnviroment1.Parent = game.Workspace
	--wait(0.2)
	--workspace:WaitForChild("Enviroment2"):Destroy()
	--wait(0.2)
	--local clonedEnviroment2 = game.ServerStorage.Enviroment2:Clone()
	--clonedEnviroment2.Parent = game.Workspace
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

function tblremovekey(tbl, key)
	local element = table[key]
	tbl[key] = nil
	return element
end

local ResetLoop = coroutine.wrap(function()
	while true do
		task.wait(0.1)
		for i, v in hits do
			if v['time'] <= (os.time() - 10) then
				print('gone bud')
				v['time'] = os.time() + 600
				if typeof(i) == "Instance" then
					i:Destroy()
					local clone = game.ServerStorage.Enviroment[i.Name]:Clone()
					clone.Parent = game.Workspace.Enviroment
				end
			end
			--print(i, 'i', v, 'v')
		end
		
	end
end)

ResetLoop()

return module
