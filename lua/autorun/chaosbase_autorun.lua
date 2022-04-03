AddCSLuaFile()

ChaosBase = {}

ChaoticLoader = {}

local COLOR_PRINT_HEAD = Color(244, 167, 66)
local COLOR_PRINT_GOOD = Color(0, 160, 220)
local COLOR_PRINT_BAD = Color(255, 127, 127)
local COLOR_PRINT_LOADED = Color(0,255,0)

function ChaoticLoader.Print(is_err, ...)
	local args = { ... }
	local body_color

	if isstring(is_err) then
		table.insert(args, 1, is_err)
		body_color = COLOR_PRINT_GOOD
	else
		body_color = is_err and COLOR_PRINT_BAD or COLOR_PRINT_GOOD
	end

	for k, v in pairs(args) do args[k] = tostring(v) end
	MsgC(COLOR_PRINT_HEAD, "[ChaoticLoader] > ", body_color, table.concat(args), "\n")
end


local dir = "chaosbase/"

if SERVER then 
	local files, directories = file.Find( dir.."*", "LUA" )
	for i, folder in pairs( directories ) do
		local files, directories = file.Find( dir .. folder .. "/*", "LUA" )
		for i, f in pairs( files ) do
			if string.StartWith( f, "sh_" ) then
				include( dir .. folder .. "/" .. f )
				AddCSLuaFile( dir .. folder .. "/" .. f )
			elseif string.StartWith( f, "sv_" ) then
				include( dir .. folder .. "/" .. f )
			elseif string.StartWith( f, "cl_" ) then
				AddCSLuaFile( dir .. folder .. "/" .. f )
			end
			ChaoticLoader.Print("[Chaos Weapon Base] loaded "..f)
		end
	end
	ChaoticLoader.Print("[Chaos Weapon Base] Addon Initialized.")
else
	local files, directories = file.Find( dir.."*", "LUA" )
	for i, folder in pairs( directories ) do
		local files, directories = file.Find( dir .. folder .. "/*", "LUA" )
		for i, f in pairs( files ) do
			if string.StartWith( f, "sh_" ) or string.StartWith( f, "config_" ) then
				include( dir .. folder .. "/" .. f )
			elseif string.StartWith( f, "cl_" ) then
				include( dir .. folder .. "/" .. f )
			end
			ChaoticLoader.Print("[Chaos Weapon Base] Loaded "..f)
		end
	end
	ChaoticLoader.Print("[Chaos Weapon Base] Addon Initialized.")
end