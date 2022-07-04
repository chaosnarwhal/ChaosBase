ChaosBase.AmmoTypes = {}

function ChaosBase:AddAmmoType(tbl)
    table.Add(ChaosBase.AmmoTypes, tbl)
end

local batteryammo = {
    {
        Name = "ammo_chaos_battery",
        Text = "Don't give yourself this ammo. It will only break your weapons.",
        DMG = DMG_BULLET,
        DamagePlayer = 0,
        DamageNPC = 0,
        Tracer = TRACER_LINE_AND_WHIZ,
        Force = 500,
        SplashMin = 5,
        SplashMax = 10,
        MaxCarry = 100,
    }
}

ChaosBase:AddAmmoType(batteryammo)

hook.Add("Initialize", "chaos_SetupAmmoTypes", function()
    for k, v in pairs(ChaosBase.AmmoTypes) do
        if CLIENT then
            language.Add("" .. v.Name .. "_ammo", v.Text)
        end

        game.AddAmmoType({
            name = v.Name,
            dmgtype = v.DMG,
            tracer = v.Tracer,
            plydmg = v.DamagePlayer,
            npcdmg = v.DamageNPC,
            force = v.Force,
            minsplash = v.SplashMin,
            maxsplash = v.SplashMax,
            maxcarry = v.MaxCarry
        })
    end
end)