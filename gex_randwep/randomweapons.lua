-- Goldeneye X Weapon Randomizer (that does include "Disabled" or "Nothing",
-- and is actually based on a text list.)

-- However, this program is totally geared towards Goldeneye X VR usage.

local args = {...}

print("Perfect Dark and Goldeneye X Weapon Set Randomizer")

if #args == 0 then
	-- running without arguments
	print("usage: lua randomweapons.lua (listpath) [options]")
	print("\nAvailable options include:")
	print("\t'unique': Unique weapons only (not yet implemented).")
	print("\t'shield6','armor6': Enforce Shield/Body Armor in Slot 6.")
	return
end

-- first argument: path to the list; a text file separated by newlines.
local filePath = args[1]

-- option for enforcing unique slots (not implemented yet)
local uniqueOnly = false

-- option for replacing last slot with body armor/shield
local armorInSlot6 = false
local pdArmor = false

if #args > 1 then
	for k,v in pairs(args) do
		if v == "unique" then uniqueOnly = true end

		if v == "armor6" or v == "shield6" then
			armorInSlot6 = true
			if v == "shield6" then pdArmor = true end
		end
	end
end

local fileLines = {}
for weapon in io.lines(filePath) do
	table.insert(fileLines,weapon)
end

math.randomseed(os.time())

local weaponOut = {}
local numsOut = {} -- todo: used for unique checking

for i=1,6 do
	local slotNum = math.random(#fileLines)
	if uniqueOnly then
		-- search current values in numsOut for slotNum
	end

	-- successful
	table.insert(numsOut,i,slotNum)
	table.insert(weaponOut,i,string.format("%d: %s",i,fileLines[slotNum]))
end

if armorInSlot6 then
	if pdArmor then -- Perfect Dark
		weaponOut[6] = "6: Shield"
	else -- Goldeneye X
		weaponOut[6] = "6: Body Armor"
	end
end

for k,v in pairs(weaponOut) do
	print(v)
end
