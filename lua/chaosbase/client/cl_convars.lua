--[[
    ClientConVars table doc:
    name = data:
    def  - default value
    desc - description of var
    min  - minimum value
    max  - maximum value
    usri - userinfo
]]

ChaosBase.ClientConVars = {
    --VIEWMODEL SECTION
    ["chaosbase_vmoffset_x"]            = { def = 0 },
    ["chaosbase_vmoffset_y"]            = { def = 0 },
    ["chaosbase_vmoffset_z"]            = { def = 0 },
    ["chaosbase_vm_offset_fov"]         = { def = 75 },
    ["chaosbase_vm_multiplier_fov"]     = { def = 0 },
    ["chaosbase_vm_add_ads"]            = { def = 0 },
    ["chaosbase_cheapscopesv2_ratio"]   = { def = 0 },
    ["chaosbase_vmflip"]                = { def = 0 },

    --BINDS SECTION
    ["chaosbase_altbindsonly"]          = { def = 0, usri = true },
    ["chaosbase_altsafety"]             = { def = 0, usri = true },
    ["chaosbase_altfgckey"]             = { def = 0, usri = true },


    ["chaosbase_dev_shootinfo"]         = { def = 0},
    ["chaosbase_toggleads"]             = { def = 0},

    --Scopes
    ["chaosbase_cheapscopes"]           = { def = 0},
    ["chaosbase_scopepp_refract"]       = { def = 0},
    ["chaosbase_scopepp_refract_ratio"] = { def = 0},
    ["chaosbase_scopepp"]               = { def = 0},

}

for name, data in pairs(ChaosBase.ClientConVars) do
    CreateClientConVar(name, data.def, true, data.usri or false, data.desc, data.min, data.max)
end