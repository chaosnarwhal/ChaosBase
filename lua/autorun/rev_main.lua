--Serverside Convars

if GetConVar("sv_rev_weapon_strip") == nil then
	CreateConVar("sv_rev_weapon_strip", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "Allow the removal of empty weapons? 1 for true, 0 for false")
	--print("Weapon strip/removal con var created")
end
	
if GetConVar("sv_rev_range_modifier") == nil then
	CreateConVar("sv_rev_range_modifier", "0.5", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "This controls how much the range affects damage.  0.5 means the maximum loss of damage is 0.5.")
	--print("Dry fire con var created")
end
	
if GetConVar("sv_rev_allow_dryfire") == nil then
	CreateClientConVar("sv_rev_allow_dryfire", 1, true, true)
	--print("Dry fire con var created")
end


if GetConVar("sv_rev_near_wall") == nil then
	CreateConVar("sv_rev_near_wall", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Pull up your weapon and disable shooting when you're too close to a wall?" )
	--print("Near wall con var created")
end

if GetConVar("sv_rev_damage_multiplier") == nil then
	CreateConVar("sv_rev_damage_multiplier", "1", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "Multiplier for rev base projectile damage.")
	--print("Damage Multiplier con var created")
end

if GetConVar("sv_rev_damage_mult_min") == nil then
	CreateConVar("sv_rev_damage_mult_min", "0.95", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "This is the lower range of a random damage factor.")
	--print("Damage Multiplier con var created")
end

if GetConVar("sv_rev_damage_mult_max") == nil then
	CreateConVar("sv_rev_damage_mult_max", "1.05", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "This is the lower range of a random damage factor.")
	--print("Damage Multiplier con var created")
end

if GetConVar("sv_rev_default_clip") == nil then
	CreateConVar("sv_rev_default_clip", "-1", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "How many clips will a weapon spawn with? Negative reverts to default values.")
	--print("Default clip size con var created")
end

if GetConVar("sv_rev_viewbob_intensity") == nil then
	CreateConVar("sv_rev_viewbob_intensity", "1", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "How much the player view itself bobs.")
	--print("Viewbob intensity con var created")
end

if GetConVar("sv_rev_gunbob_intensity") == nil then
	CreateConVar("sv_rev_gunbob_intensity", "1", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "How much the gun itself bobs.")
	--print("Viewbob intensity con var created")
end
	
if GetConVar("sv_rev_unique_slots") == nil then
	CreateConVar("sv_rev_unique_slots", "1", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "Give rev-based Weapons unique slots? 1 for true, 0 for false. RESTART AFTER CHANGING.")
	--print("Unique slot con var created")
end
	
if GetConVar("sv_rev_force_multiplier") == nil then
	CreateConVar("sv_rev_force_multiplier", "1", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "Arrow force multiplier (not arrow velocity, but how much force they give on impact).")
	--print("Arrow force con var created")
end
	
if GetConVar("sv_rev_dynamicaccuracy") == nil then
	CreateConVar("sv_rev_dynamicaccuracy", "1", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "Dynamic acuracy?  (e.g.more accurate on crouch, less accurate on jumping.")
	--print("DynAcc con var created")
end
	
if GetConVar("sv_rev_ammo_detonation") == nil then
	CreateConVar("sv_rev_ammo_detonation", "1", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "Ammo Detonation?  (e.g. shoot ammo until it explodes) ")
	--print("DynAcc con var created")
end
	
if GetConVar("sv_rev_ammo_detonation_mode") == nil then
	CreateConVar("sv_rev_ammo_detonation_mode", "2", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "Ammo Detonation Mode?  (0=Bullets,1=Blast,2=Mix) ")
	--print("DynAcc con var created")
end
	
if GetConVar("sv_rev_ammo_detonation_chain") == nil then
	CreateConVar("sv_rev_ammo_detonation_chain", "1", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "Ammo Detonation Chain?  (0=Ammo boxes don't detonate other ammo boxes, 1 you can chain them together) ")
	--print("DynAcc con var created")
end
	
if GetConVar("sv_rev_scope_gun_speed_scale") == nil then
	CreateConVar("sv_rev_scope_gun_speed_scale", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "Scale player sensitivity based on player move speed?")
end
	
if GetConVar("sv_rev_bullet_penetration") == nil then
	CreateConVar("sv_rev_bullet_penetration", "1", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "Allow bullet penetration?")
end
	
if GetConVar("sv_rev_bullet_ricochet") == nil then
	CreateConVar("sv_rev_bullet_ricochet", "1", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "Allow bullet ricochet?")
end
	
if GetConVar("sv_rev_holdtype_dynamic") == nil then
	CreateConVar("sv_rev_holdtype_dynamic", "1", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "Allow dynamic holdtype?")
end
	
if GetConVar("sv_rev_compatibility_movement") == nil then
	CreateConVar("sv_rev_compatibility_movement", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "Disable custom movement speed for increased compatibility?")
end
	
if GetConVar("sv_rev_compatibility_clientframe") == nil then
	CreateConVar("sv_rev_compatibility_clientframe", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "This should be used if you have an addon that breaks rev Base's aiming or other features, but you don't want to remove it.")
end

if GetConVar("sv_rev_compatibility_footstep") == nil then
	CreateConVar("sv_rev_compatibility_footstep", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, "This should be used if you have an addon that breaks rev Base's running, sprinting, etc. animations.")
end

--Clientside Convars

if CLIENT then

	if GetConVar("cl_rev_vmoffset_x") == nil then
		CreateConVar("cl_rev_vmoffset_x", 0, {FCVAR_USERINFO, FCVAR_ARCHIVE})
	end
	
	if GetConVar("chaosbase_dev_shootinfo") == nil then
		CreateConVar("chaosbase_dev_shootinfo", 0, 0, "Show debug overlay firing information. Only works when developer is set to 1.", 0, 3)
	end

	if GetConVar("cl_rev_vmoffset_y") == nil then
		CreateConVar("cl_rev_vmoffset_y", 0, {FCVAR_USERINFO, FCVAR_ARCHIVE})
	end
	
	if GetConVar("cl_rev_vmoffset_z") == nil then
		CreateConVar("cl_rev_vmoffset_z", 0, {FCVAR_USERINFO, FCVAR_ARCHIVE})
	end

	if GetConVar("cl_rev_scope_sensitivity_autoscale") == nil then
		CreateClientConVar("cl_rev_scope_sensitivity_autoscale", 100, true, true)
		--print("Scope sensitivity autoscale con var created")
	end
		
	if GetConVar("cl_rev_scope_sensitivity") == nil then
		CreateClientConVar("cl_rev_scope_sensitivity", 100, true, true)
		--print("Scope sensitivity con var created")
	end
		
	if GetConVar("cl_rev_ironsights_toggle") == nil then
		CreateClientConVar("cl_rev_ironsights_toggle", 1, true, true)
		--print("Ironsights toggle con var created")
	end
		
	if GetConVar("cl_rev_ironsights_resight") == nil then
		CreateClientConVar("cl_rev_ironsights_resight", 1, true, true)
		--print("Ironsights resight con var created")
	end
		
	--Crosshair Params
	
	if GetConVar("cl_rev_hud_crosshair_length") == nil then
		CreateClientConVar("cl_rev_hud_crosshair_length", 1, true, true)
	end
		
	if GetConVar("cl_rev_hud_crosshair_length_use_pixels") == nil then
		CreateClientConVar("cl_rev_hud_crosshair_length_use_pixels", 0, true, true)
	end
		
	if GetConVar("cl_rev_hud_crosshair_width") == nil then
		CreateClientConVar("cl_rev_hud_crosshair_width", 1, true, true)
	end
		
	if GetConVar("cl_rev_hud_crosshair_enable_custom") == nil then
		CreateClientConVar("cl_rev_hud_crosshair_enable_custom", 1, true, true)
		--print("Custom crosshair con var created")
	end
		
	if GetConVar("cl_rev_hud_crosshair_gap_scale") == nil then
		CreateClientConVar("cl_rev_hud_crosshair_gap_scale", 1, true, true)
	end
	
	if GetConVar("cl_rev_hud_crosshair_dot") == nil then
		CreateClientConVar("cl_rev_hud_crosshair_dot", 0, true, true)
	end
	
	--Crosshair Color
	if GetConVar("cl_rev_hud_crosshair_color_r") == nil then
		CreateClientConVar("cl_rev_hud_crosshair_color_r", 225, true, true)
		--print("Crosshair tweaking con vars created")
	end
		
	if GetConVar("cl_rev_hud_crosshair_color_g") == nil then
		CreateClientConVar("cl_rev_hud_crosshair_color_g", 225, true, true)
	end
		
	if GetConVar("cl_rev_hud_crosshair_color_b") == nil then
		CreateClientConVar("cl_rev_hud_crosshair_color_b", 225, true, true)
	end
		
	if GetConVar("cl_rev_hud_crosshair_color_a") == nil then
		CreateClientConVar("cl_rev_hud_crosshair_color_a", 200, true, true)
	end
	--Crosshair Outline
	if GetConVar("cl_rev_hud_crosshair_outline_color_r") == nil then
		CreateClientConVar("cl_rev_hud_crosshair_outline_color_r", 5, true, true)
	end
		
	if GetConVar("cl_rev_hud_crosshair_outline_color_g") == nil then
		CreateClientConVar("cl_rev_hud_crosshair_outline_color_g", 5, true, true)
	end
		
	if GetConVar("cl_rev_hud_crosshair_outline_color_b") == nil then
		CreateClientConVar("cl_rev_hud_crosshair_outline_color_b", 5, true, true)
	end
		
	if GetConVar("cl_rev_hud_crosshair_outline_color_a") == nil then
		CreateClientConVar("cl_rev_hud_crosshair_outline_color_a", 200, true, true)
	end
		
	if GetConVar("cl_rev_hud_crosshair_outline_width") == nil then
		CreateClientConVar("cl_rev_hud_crosshair_outline_width", 1, true, true)
	end
		
	if GetConVar("cl_rev_hud_crosshair_outline_enabled") == nil then
		CreateClientConVar("cl_rev_hud_crosshair_outline_enabled", 1, true, true)
	end
	
	--Other stuff
	
	if GetConVar("cl_rev_hud_ammodata_fadein") == nil then
		CreateClientConVar("cl_rev_hud_ammodata_fadein", 0.2, true, true)
	end
		
	if GetConVar("cl_rev_hud_hangtime") == nil then
		CreateClientConVar("cl_rev_hud_hangtime", 1, true, true)
	end
		
	if GetConVar("cl_rev_hud_enabled") == nil then
		CreateClientConVar("cl_rev_hud_enabled", 1, true, true)
	end
		
	if GetConVar("cl_rev_fx_gasblur") == nil then
		CreateClientConVar("cl_rev_fx_gasblur", 1, true, true)
	end
		
	if GetConVar("cl_rev_fx_muzzlesmoke") == nil then
		CreateClientConVar("cl_rev_fx_muzzlesmoke", 1, true, true)
	end
		
	if GetConVar("cl_rev_fx_impact_enabled") == nil then
		CreateClientConVar("cl_rev_fx_impact_enabled", 1, true, true)
	end
		
	if GetConVar("cl_rev_fx_impact_ricochet_enabled") == nil then
		CreateClientConVar("cl_rev_fx_impact_ricochet_enabled", 1, true, true)
	end

	if GetConVar("cl_rev_fx_impact_ricochet_sparks") == nil then
		CreateClientConVar("cl_rev_fx_impact_ricochet_sparks", 6, true, true)
	end

	if GetConVar("cl_rev_fx_impact_ricochet_sparklife") == nil then
		CreateClientConVar("cl_rev_fx_impact_ricochet_sparklife", 2, true, true)
	end
	
	--viewbob 
	
		
	if GetConVar("cl_rev_viewbob_drawing") == nil then
		CreateClientConVar("cl_rev_viewbob_drawing", 0, true, true)
	end
	
	if GetConVar("cl_rev_viewbob_reloading") == nil then
		CreateClientConVar("cl_rev_viewbob_reloading", 1, true, true)
	end

	if GetConVar("cl_rev_vmflip") == nil then
		CreateClientConVar("cl_rev_vmflip", 0, true, true)
	end

	if GetConVar("cl_rev_vm_offset_fov") == nil then
		CreateClientConVar("cl_rev_vm_offset_fov", 0, true, true)
	end

	if GetConVar("cl_rev_vm_multiplier_fov") == nil then
		CreateClientConVar("cl_rev_vm_multiplier_fov", 0, true, true)
	end

	if GetConVar("chaosbase_vm_fov") == nil then
		CreateClientConVar("chaosbase_vm_fov", 0, true, true)
	end

	if GetConVar("chaosbase_vm_add_ads") == nil then
		CreateClientConVar("chaosbase_vm_add_ads", 0, true, true)
	end

	if GetConVar("chaosbase_cheapscopesv2_ratio") == nil then
		CreateClientConVar("chaosbase_cheapscopesv2_ratio", 0, true, true)
	end

	if GetConVar("chaosbase__cheapscopes") == nil then
		CreateClientConVar("chaosbase__cheapscopes", 0, true, true)
	end
	
	
end

--[[
Hook: PlayerTick
Function: Weapon Logic
Used For: Main weapon "think" logic
]]--

--[[
hook.Add("PlayerTick", "PlayerTickRev", function(plyv)

	wep = plyv:GetActiveWeapon()

	if wep:IsValid() and wep.PlayerThink and (wep.Base == "rev_base") then
		wep:PlayerThink(plyv)
	end
end)
]]--

--[[
Hook: PreRender & PreDrawViewModel
Function: Weapon Logic & Calculating Viewmodel offsets
Used For: Per-frame weapon "think" logic & viewmodel sway, offset and flips?
]]

if CLIENT then


	local st_old, host_ts, cheats, vec, ang
	host_ts = GetConVar("host_timescale")
	cheats = GetConVar("sv_cheats")
	vec = Vector()
	ang = Angle()

	local IsGameUIVisible = gui and gui.IsGameUIVisible

	--[[
	--PreRender
	hook.Add("PreRender", "PreRender_RevBase", function()

		if not IsValid(ply) then
			ply = LocalPlayer()
			return
		end

		wep = ply:GetActiveWeapon()

		if wep:IsValid() and wep.PlayerThinkClientFrame and (wep.Base == "rev_base") then
			wep:PlayerThinkClientFrame(ply)
		end
			
	end)
	]]

	--PreDrawViewModel
	hook.Add("PreDrawViewModel", "RevCalculateViewmodel", function(vm, plyv, wepv)
		if not wepv:IsValid() or not (wepv.Base == "chaos_base") then return end

		local st = SysTime()
		st_old = st_old or st

		local delta = st - st_old
		st_old = st

		if game.SinglePlayer() and IsGameUIVisible and IsGameUIVisible() then return end

		delta = delta * game.GetTimeScale() * 1

		--Weapon SWAY code does not work, needs re-write.
		--wepv:Sway(vec, ang, delta)
		wepv:CalculateViewModelOffset(delta)
		wepv:CalculateViewModelFlip()

	end)



end

if game.AddParticles then
	game.AddParticles("particles/rev_smoke.pcf")
end

hook.Add( "AddToolMenuCategories", "RevGunBaseCategory", function()
	spawnmenu.AddToolCategory( "Options", "WeaponSettings", "#Revival Gun Base" )
end )

hook.Add( "PopulateToolMenu", "RevGunBaseCategorySettings", function()
	spawnmenu.AddToolMenuOption( "Options", "WeaponSettings", "Client", "#Client", "", "", function( panel )
		panel:ClearControls()
		panel:CheckBox( "ViewModel Flip", "cl_rev_vmflip")
		panel:NumSlider( "ViewModel offset x", "cl_rev_vmoffset_x", -10, 10 )
		panel:NumSlider( "ViewModel offset y", "cl_rev_vmoffset_y", -10, 10 )
		panel:NumSlider( "ViewModel offset z", "cl_rev_vmoffset_z", -10, 10 )
		-- Add stuff here
	end )
end )