--[[
    Panel table doc:
    id (any number) = data:
    type
    type args

    types:
    h - header                        text
    c - control help                  text
    b - checkbox                      text var
    i - integer slider                text var min max
    f - float slider (2 nums after .) text var min max
    m - color mixer                   text r g b a
    p - press or button               text func
    t - textbox                       text string
    o - combo box                     text var choices (key - cvar, value - text)
    d - binder                        text var
    (you can add custom types in ChaosBase.GeneratePanelElements's AddControl table)

    Generate elements via ChaosBase.GeneratePanelElements:
    panel, panel table with data

    Add menu generation to ChaosBase.ClientMenus:
    name = data:
    text - header text
    func - generator function
]]

local ViewmodelPanel = {
    { type = "b", text = "Flip Viewmodel?", var = "chaosbase_vmflip", min = 0, max = 1 },
    { type = "i", text = "Viewmodel FOV Offset", var = "chaosbase_vm_offset_fov", min = 50, max = 170 },
    { type = "i", text = "Viewmodel Offset x", var = "chaosbase_vmoffset_x", min = -10, max = 10 },
    { type = "i", text = "Viewmodel Offset y", var = "chaosbase_vmoffset_y", min = -10, max = 10 },
    { type = "i", text = "Viewmodel Offset z", var = "chaosbase_vmoffset_z", min = -10, max = 10 },
}

local OptionsPanel = {
    { type = "h", text = "ChaosBase Options" },
    { type = "b", text = "Draw Crosshair?", var = "chaosbase_crosshair", min = 0, max = 1 },
    { type = "b", text = "Disable Other Muzzle Effects", var = "chaosbase_muzzle_effect", min = 0, max = 1 },
    { type = "b", text = "Toggle Ironsights?", var = "chaosbase_ironsights_toggle", min = 0, max = 1 },
    { type = "b", text = "Toggle Ironsights Resight?", var = "chaosbase_ironsights_resight", min = 0, max = 1 },
    { type = "b", text = "Toggle Responsive Ironsights  (mixed held down/toggle)", var = "chaosbase_ironsights_responsive", min = 0, max = 1 },
    { type = "f", text = "Held Time Threshhold", var = "chaosbase_ironsights_responsive_timer", min = 0.01, max = 2 },
    { type = "c", text = "ChaosBase has been a 6 month project and will probably be many more. Please report any Bugs to a Dev or Chaosnarwhal/Meliodas. Thank you for playing revival and thank you for being beautiful." },

}

function ChaosBase.NetworkConvar(convar, value, p)
    if not LocalPlayer():IsAdmin() then return end
    if (p.TickCreated or 0) == UnPredictedCurTime() then return end
    if value == true or value == false then
        value = value and 1 or 0
    end
    if IsColor(value) then
        value = tostring(value.r) .. " " .. tostring(value.g) .. " " .. tostring(value.b) .. " " .. tostring(value.a)
    end

    local command = convar .. " " .. tostring(value)

    local timername = "change" .. convar

    if timer.Exists(timername) then
        timer.Remove(timername)
    end

    timer.Create(timername, 0.25, 1, function()
        net.Start("chaosbase_sendconvar")
        net.WriteString(command)
        net.SendToServer()
    end)
end

function ChaosBase.GeneratePanelElements(panel, table)
    local AddControl = {
        ["h"] = function(p, d) return p:Help(d.text) end,
        ["c"] = function(p, d) return p:ControlHelp(d.text) end,
        ["b"] = function(p, d) return p:CheckBox(d.text, d.var) end,
        ["i"] = function(p, d) return p:NumSlider(d.text, d.var, d.min, d.max, 0) end,
        ["f"] = function(p, d) return p:NumSlider(d.text, d.var, d.min, d.max, 2) end,
        ["m"] = function(p, d) --return p:AddControl("color", { Label = d.text, Red = d.r, Green = d.g, Blue = d.b, Alpha = d.a })
            local ctrl = vgui.Create("DColorMixer", p)
            ctrl:SetLabel( d.text ) ctrl:SetConVarR( d.r ) ctrl:SetConVarG( d.g ) ctrl:SetConVarB( d.b ) ctrl:SetConVarA( d.a )
            p:AddItem( ctrl ) return ctrl
        end,
        ["p"] = function(p, d) local b = p:Button(d.text) b.DoClick = d.func return b end,
        ["t"] = function(p, d) return p:TextEntry(d.text, d.var) end,
        ["o"] = function(p, d) local cb = p:ComboBox(d.text, d.var) for k, v in pairs(d.choices) do cb:AddChoice(v, k) end return cb end,
        ["d"] = function(p, d)
                local s = vgui.Create("DSizeToContents", p) s:SetSizeX(false) s:Dock(TOP) s:InvalidateLayout()
                local l = vgui.Create("DLabel", s) l:SetText(d.text) l:SetTextColor(Color(0, 0, 0)) l:Dock(TOP) l:SetContentAlignment(5)
                local bd = vgui.Create("DBinder", s)
                if input.LookupBinding(d.var) then bd:SetValue(input.GetKeyCode(input.LookupBinding(d.var))) end
                bd.OnChange = function(b, k)
                    if k and input.GetKeyName(k) then
                        local str = input.LookupKeyBinding(k)
                        if str then
                            str = string.Replace(str, d.var .. "; ", "")
                            str = string.Replace(str, d.var, "")
                            chat.AddText(Color(255, 255, 255), "Type into console: ", Color(255, 128, 0), "bind " .. input.GetKeyName(k) .. " \"" .. str .. "; " .. d.var .. "\"")
                        else
                            chat.AddText(Color(255, 255, 255), "Type into console: ", Color(255, 128, 0), "bind " .. input.GetKeyName(k) .. " " .. d.var .. "")
                        end
                    end
                end
                bd:Dock(TOP) p:AddItem(s) return s end
    }

    local concommands = {
        ["b"] = true,
        ["i"] = true,
        ["f"] = true,
        ["m"] = true,
        ["t"] = true,
    }

    for _, data in SortedPairs(table) do
        local p = AddControl[data.type](panel, data)

        if concommands[data.type] and data.sv then
            p.TickCreated = UnPredictedCurTime()
            if data.type == "b" then
                p.OnChange = function(self, bval)
                    ChaosBase.NetworkConvar(data.var, bval, self)
                end
            elseif data.type == "i" or data.type == "f" or data.type == "m" or data.type == "t" then
                p.OnValueChanged = function(self, bval)
                    ChaosBase.NetworkConvar(data.var, bval, self)
                end
            end
        end
    end
end

local ViewmodelPresets = {
    ["Default Preset"] = {
        chaosbase_vmflip = "0",
        chaosbase_crosshair = "1",
        chaosbase_vm_offset_fov = "75",
        chaosbase_vmoffset_x = "0",
        chaosbase_vmoffset_y = "0",
        chaosbase_vmoffset_z = "0",
    }
}

function ChaosBase_Options_Viewmodel(panel, no_preset)
    if not no_preset then
        panel:AddControl("ComboBox", {
            MenuButton = "1",
            Label      = "Presets",
            Folder     = "chaosbase_vm",
            CVars      = { "" },
            Options    = ViewmodelPresets
        })
    end

    ChaosBase.GeneratePanelElements(panel, ViewmodelPanel)
end

local OptionsPresets = {
    ["Default Preset"] = {
        chaosbase_crosshair = "1",
        chaosbase_ironsights_toggle = "0",
        chaosbase_ironsights_resight = "0",
        chaosbase_ironsights_responsive = "0",
        chaosbase_ironsights_responsive_timer = "0.175",
    }
}

function ChaosBase_Options_Main(panel, no_preset)
    if not no_preset then
        panel:AddControl("ComboBox", {
            MenuButton = "1",
            Label      = "Presets",
            Folder     = "chaosbase_options",
            CVars      = { "" },
            Options    = OptionsPresets
        })
    end

    ChaosBase.GeneratePanelElements(panel, OptionsPanel)
end

ChaosBase.ClientMenus = {
    ["ChaosBase_Options_Viewmodel"] = { text = "Viewmodel", func = ChaosBase_Options_Viewmodel, tbl = ViewmodelPanel },
    ["ChaosBase_Options_Options"] = { text = "Options", func = ChaosBase_Options_Main, tbl = OptionsPanel },
}

hook.Add("PopulateToolMenu", "ChaosBase_Options", function()
    for menu, data in pairs(ChaosBase.ClientMenus) do
        spawnmenu.AddToolMenuOption("Options", "ChaosBase", menu, data.text, "", "", data.func)
    end
end)

