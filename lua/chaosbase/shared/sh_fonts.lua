if SERVER then
	AddCSLuaFile()
	return
end

surface.CreateFont( "reach_ammocounter", {
	font = "Agency FB", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 128,
	weight = 1,
	blursize = 0,
	scanlines = 4,
	antialias = false,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = true,
	outline = false,
} )

surface.CreateFont( "ce_ammocounter", {
	font = "Oxanium", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 80,
	weight = 100,
	blursize = 0,
	scanlines = 6,
	antialias = false,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "h3_ammocounter", {
	font = "Oxanium", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 58,
	weight = 300,
	blursize = 0,
	scanlines = 4,
	antialias = false,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "343_ammocounter", {
	font = "Spaceport 2006", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 36,
	weight = 100,
	blursize = 0,
	scanlines = 1,
	antialias = false,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )