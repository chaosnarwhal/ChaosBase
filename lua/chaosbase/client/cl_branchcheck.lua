AddCSLuaFile()

ChaosBase = ChaosBase or {}

surface.CreateFont("branchcheck_24", {
    font = "Roboto",
    size = 24,
    weight = 1000,
})

local frameColor = Color(47, 54, 64)
local buttonColor = Color(53, 59, 72)
local buttonColorConfirm = Color(0, 200, 0)

function ChaosBase.OpenBranchMenu()
    local scrw, scrh = ScrW(), ScrH()

    if IsValid(ChaosBase.BranchMenu) or IsValid(ChaosBase.HELPGIF) then
        ChaosBase.BranchMenu:Remove()
    end

    local frameW, frameH, animTime, animDelay, animEase = scrw * 0.5, scrh * 0.5, 1.8, 0, 0.1
    ChaosBase.BranchMenu = vgui.Create("DFrame")
    ChaosBase.BranchMenu:SetTitle("")
    ChaosBase.BranchMenu:SetSizable(false)
    ChaosBase.BranchMenu:ShowCloseButton(false)
    ChaosBase.BranchMenu:MakePopup(true)
    ChaosBase.BranchMenu:SetSize(0, 0)
    ChaosBase.BranchMenu:Center()
    local isAnimating = true

    ChaosBase.BranchMenu:SizeTo(frameW, frameH, animTime, animDelay, animEase, function()
        isAnimating = false
    end)

    ChaosBase.BranchMenu.Paint = function(me, w, h)
        surface.SetDrawColor(frameColor)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("If you are not on the x86-64 branch you may encounter instability or crashes. Please consider swapping to the dev branch.", "branchcheck_24", w / 2, h * 0.05, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local HelpGif = ChaosBase.BranchMenu:Add("HTML")
    HelpGif:SetSize(0, 0)
    HelpGif:SizeTo(frameW * 0.75, frameH * 0.75, animTime, animDelay, animEase)
    HelpGif:OpenURL("https://b.catgirlsare.sexy/yjOL7AeZOwzE.gif")
    local buttonClose = ChaosBase.BranchMenu:Add("DButton")
    buttonClose:Dock(BOTTOM)
    buttonClose:SetText("")
    buttonClose:SetSize(50, 50)
    local speed = 0.5
    local barStatus = 100

    buttonClose.Paint = function(me, w, h)
        if me:IsHovered() then
            barStatus = math.Clamp(barStatus + speed * FrameTime(), 0, 1)
        else
            barStatus = math.Clamp(barStatus - speed * FrameTime(), 0, 1)
        end

        surface.SetDrawColor(buttonColor)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(buttonColorConfirm)
        surface.DrawRect(0, 0, w * barStatus, h)
        draw.SimpleText("I Understand and wont complain about Crashes.", "branchcheck_24", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    buttonClose.DoClick = function(me)
        if barStatus == 1 then
            ChaosBase.BranchMenu:Remove()
        end
    end

    ChaosBase.BranchMenu.Think = function(me)
        if isAnimating then
            me:Center()
        end
    end

    HelpGif.Think = function(me)
        if isAnimating then
            me:Center()
        end
    end
end

hook.Add("InitPostEntity", "BranchChecker", function()
    if BRANCH ~= "x86-64" then
        ChaosBase.OpenBranchMenu()
    else
        print("You're on the dev branch. Enjoy.")
    end
end)

concommand.Add("BranchCheck", ChaosBase.OpenBranchMenu)