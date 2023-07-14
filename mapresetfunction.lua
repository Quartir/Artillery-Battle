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


function module.Tag(p, player)
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

function module.MapResetGui()
	local clone = game.ServerStorage.Enviroment:Clone()
	game.Workspace.Enviroment:Destroy()
	clone.Parent = game.Workspace
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
